load_dbx () {
    mkdir -p $HOME/.config/dbxcli
    if [ -n "$DROPBOX_PERSONAL_TOKEN" ]; then
        echo "{\"\":{\"personal\":\"$DROPBOX_PERSONAL_TOKEN\"}}" > $HOME/.config/dbxcli/auth.json
    fi
}

load_ssh_keys() {
  local ssh_path="$HOME/.ssh"
  local project_id="${BWS_PROJECT_ID:?'BWS_PROJECT_ID undefined in ~/.bws'}"

  mkdir -p "$ssh_path"
  echo "load ssh keys and ssh config file..."

  local secrets
  secrets=$(bws secret list "$project_id" -o json 2>/dev/null) || {
    echo "Erreur: impossible de récupérer les secrets BWS (BWS_ACCESS_TOKEN défini ?)" >&2
    return 1
  }

  echo "$secrets" \
    | jq -c '.[] | select(.key | startswith("SSH_"))' \
    | while IFS= read -r item; do
        local bws_key filename value
        bws_key=$(echo "$item" | jq -r '.key')
        value=$(echo "$item"   | jq -r '.value')
        filename="${bws_key#SSH_}"

        printf '%s' "$value" > "$ssh_path/$filename"

        if [[ "$filename" == "config" ]]; then
          chmod 644 "$ssh_path/$filename"
        else
          chmod 600 "$ssh_path/$filename"
        fi
        echo "  ✓ $filename"
      done
}


dbxpush () {
  if [ $# -ne 1 ]; then
    echo "fichier manquant"
    return 1
  fi
  local fichier_local="$1"
  local dest="tmp/$(basename "$fichier_local")"
  if [ -f "$fichier_local" ]; then
    dbxcli put $fichier_local $dest
  fi
  if [ -d "$fichier_local" ]; then
    dbxcli put $fichier_local $dest
  fi 
}

dbxget () {
  if [ $# -ne 1 ]; then
    echo "fichier manquant"
    return 1
  fi
  local fichier="$1"
  dbxcli get "tmp/$fichier"
}

dbxclean () {
  dbxcli rm tmp/* --force
}

load_all() {
  load_ssh_keys
  load_dbx
}

# Function to create schema from docker compose files
dockercompose2png () {
    if ! command_exists sketchviz ; then
        echo "sketchviz n'est pas installé. Installation en cours..."
        cd /tmp || exit
        git clone https://github.com/gpotter2/sketchviz.git
        cd sketchviz || exit
        npm install -g
        npm install commander
        cd ..
        rm -rf /tmp/sketchviz
        echo "Installation de sketchviz terminée."
    fi

    if ! command_exists rsvg-convert ; then
        echo "rsvg-convert n'est pas installé. Installation en cours..."
        if command_exists brew ; then
            brew install librsvg
        else
            echo "Homebrew n'est pas installé. Veuillez installer Homebrew et réessayer."
            exit 1
        fi
    fi

  # Exécution de la commande docker-compose-viz
  docker run --rm -it --name dcv -v "$(pwd)":/input pmsipilot/docker-compose-viz render ./docker-compose.yaml -f -m dot --background=transparent -vvvv
  
  # Conversion du fichier .dot en .svg
  sketchviz docker-compose.dot docker-compose.svg
  
  # Conversion du fichier .svg en .png
  rsvg-convert --background-color=white docker-compose.svg > docker-compose.png

  rm docker-compose.svg
}

function mkcd {
  mkdir -p $1
  cd $1
}

function note {
  mkdir -p $HOME/brouillon
  echo "date: $(date)" >> $HOME/notes/draft.txt
  echo "$@" >>  $HOME/notes/draft.txt
  echo "" >> $HOME/notes/draft.txt
}
# Extract archives - use: extract <file>
# Based on http://dotfiles.org/~pseup/.bashrc
function extract() {
	if [ -f "$1" ] ; then
		local filename=$(basename "$1")
		local foldername="${filename%%.*}"
		local fullpath=`perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1"`
		local didfolderexist=false
		if [ -d "$foldername" ]; then
			didfolderexist=true
			read -p "$foldername already exists, do you want to overwrite it? (y/n) " -n 1
			echo
			if [[ $REPLY =~ ^[Nn]$ ]]; then
				return
			fi
		fi
		mkdir -p "$foldername" && cd "$foldername"
		case $1 in
			*.tar.bz2) tar xjf "$fullpath" ;;
			*.tar.gz) tar xzf "$fullpath" ;;
			*.tar.xz) tar Jxvf "$fullpath" ;;
			*.tar.Z) tar xzf "$fullpath" ;;
			*.tar) tar xf "$fullpath" ;;
			*.taz) tar xzf "$fullpath" ;;
			*.tb2) tar xjf "$fullpath" ;;
			*.tbz) tar xjf "$fullpath" ;;
			*.tbz2) tar xjf "$fullpath" ;;
			*.tgz) tar xzf "$fullpath" ;;
			*.txz) tar Jxvf "$fullpath" ;;
			*.zip) unzip "$fullpath" ;;
			*) echo "'$1' cannot be extracted via extract()" && cd .. && ! $didfolderexist && rm -r "$foldername" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# AWS
awslogin() {
  local profile
  profile=$(aws configure list-profiles | fzf --height=20 --prompt="AWS Profile: ") || return 1

  aws sso login --no-browser --profile "$profile" || return 1

  export AWS_PROFILE="$profile"

  echo "Fetching EKS clusters across all regions..."

  # All enabled regions for the account; fall back to profile region on error
  local regions
  regions=$(aws ec2 describe-regions --profile "$profile" \
    --query 'Regions[].RegionName' --output text 2>/dev/null | tr '\t' '\n')
  [[ -z "$regions" ]] && regions=$(aws configure get region --profile "$profile" 2>/dev/null)

  # Query every region in parallel, write "cluster\tregion" lines to tmp files
  local tmpdir
  tmpdir=$(mktemp -d)

  # Suppress background job start/end notifications ([1] 1234 / [1] done ...)
  setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR

  local r
  for r in ${(f)regions}; do
    {
      aws eks list-clusters --profile "$profile" --region "$r" \
        --query 'clusters[]' --output text 2>/dev/null \
        | tr '\t' '\n' | grep -v '^$' | sed "s|$|\t$r|" > "$tmpdir/$r"
    } &
  done
  wait

  local clusters_with_region
  clusters_with_region=$(cat "$tmpdir"/* 2>/dev/null)
  rm -rf "$tmpdir"

  if [[ -z "$clusters_with_region" ]]; then
    echo "No EKS clusters found for profile '$profile', skipping kubeconfig update."
    return 0
  fi

  local selection
  selection=$(echo "$clusters_with_region" | column -t -s $'\t' \
    | fzf --height=20 --prompt="EKS Cluster: ") || return 0

  local cluster region
  cluster=$(echo "$selection" | awk '{print $1}')
  region=$(echo "$selection" | awk '{print $2}')

  aws eks update-kubeconfig --name="$cluster" --profile "$profile" --region "$region"
}