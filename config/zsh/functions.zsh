unlock_bw_if_locked() {
  if [[ -z $BW_SESSION ]] ; then
    bw login --apikey
    >&2 echo 'bw locked - unlocking into a new session'
    export BW_SESSION="$(bw unlock  $BW_PSSWD --raw)"
  fi
}

load_dbx () {
    mkdir -p $HOME/.config/dbxcli
    if [ -n "$DROPBOX_PERSONAL_TOKEN" ]; then
        echo "{\"\":{\"personal\":\"$DROPBOX_PERSONAL_TOKEN\"}}" > $HOME/.config/dbxcli/auth.json
    fi
}

# get all secrets from bitwarden and source it
load_secret() {
    source ~/.bw
    unlock_bw_if_locked
    bw sync
    bw get notes $BW_SECRET_NOTE_ID > $HOME/.secret
    source $HOME/.secret
    load_dbx

}

# rm files with secrets
clean_secret() {
    rm $HOME/.secret $HOME/.config/dbxcli/auth.json $HOME/.bw
    rmtrash $HOME/.secret $HOME/.config/dbxcli/auth.json $HOME/.bw

}

# get all files from bitwarden ssh folder and push into ~/.ssh folder.
load_ssh_keys() {
    unlock_bw_if_locked
    bw sync
    json_data="$(bw list items --folderid $BW_SSH_FOLDER_ID)"
    ssh_path=$HOME/.ssh

    if [ !-d $ssh_path ]; then
        mkdir $ssh_path
    fi
    if [ -n "$json_data" ]; then
        jq -c '.[]' <<< "$json_data" | while read -r item; do
            name="$(jq -r '.name' <<< "$item")"
            notes="$(jq -r '.notes' <<< "$item")"
            if [ -n "$name" ]; then
            echo "$notes" > "$ssh_path/$name"
              echo "Fichier $ssh_path/$name créé avec les notes : $notes"
              chmod 600 $ssh_path/$name
            else
              echo "Champ 'name' manquant dans l'élément JSON : $item"
            fi
        done
    else
        echo "Tableau JSON vide ou non valide."
    fi
    
    if [ -e $ssh_path/config ]; then
        chmod 744 $ssh_path/config
    fi

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
  dbxcli get tmp/fichier
}

dbxclean () {
  dbxcli rm tmp/* --force
}

load_all() {
  load_secret
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

function reloadkc {
  # Check if kubectl is installed
  if ! command -v kubectl &> /dev/null; then
    echo "Error: 'kubectl' command is not installed. Please install it to proceed."
    return 1
  fi

  # Check if the ~/.kube/kubeconfig directory exists
  if [ ! -d "$HOME/.kube/kubeconfig" ]; then
    echo "Error: The directory ~/.kube/kubeconfig does not exist."
    return 1
  fi

  # Check if there are any files in ~/.kube/kubeconfig
  kube_files=$(find "$HOME/.kube/kubeconfig" -type f)
  if [ -z "$kube_files" ]; then
    echo "Error: No files found in ~/.kube/kubeconfig."
    return 1
  fi

  # If everything is OK, execute the export and configuration commands
  export KUBECONFIG="$HOME/.kube/config:$(echo "$kube_files" | tr '\n' ':')"
  kubectl config view --flatten > "$HOME/.kube/config"

  # Reset the KUBECONFIG variable
  export KUBECONFIG=""
  echo "KUBECONFIG has been successfully reloaded."
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