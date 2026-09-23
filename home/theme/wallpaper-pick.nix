{
  pkgs,
  lib,
  config,
  paletteGenerator,
  ...
}:
let
  selectionLib = builtins.readFile ./selection.sh;
  defaultTheme = import ./_default.nix;
  wallpapersDir = "${config.dotfiles.path}/wallpapers";
in
# `wallpaper-pick`: fzf over the images in <repo>/wallpapers, previewing each
# with chafa plus the *exact* base16 palette Stylix's `stylix.image` derives
# from it, computed with `palette-generator`.
# Palettes are cached by filename under ~/.cache/stylix-wallpaper-pick.
#
# Selecting an image writes this machine's theme override (read by
# home/theme/stylix.nix, outside the repo) and rebuilds via `hm-switch`.
# `wallpaper-pick --reset` drops the override, back to home/theme/_default.nix.
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "wallpaper-pick";
      runtimeInputs = [
        pkgs.fzf
        pkgs.chafa
        pkgs.jq
        pkgs.coreutils
        pkgs.gnugrep
        paletteGenerator
        config.dotfiles.hmSwitch
      ];
      text = ''
        shopt -s nullglob nocaseglob

        wallpapers_dir=${lib.escapeShellArg wallpapersDir}
        cache_dir="$HOME/.cache/stylix-wallpaper-pick"
        selection_file=${lib.escapeShellArg config.dotfiles.theme.selectionFile}
        default_kind=${lib.escapeShellArg defaultTheme.kind}
        default_value=${lib.escapeShellArg defaultTheme.value}

        mkdir -p "$cache_dir"

        ${selectionLib}

        palette_json_for() {
          local image="$1" cache_file
          cache_file="$cache_dir/$(basename "$image").json"
          if [ ! -f "$cache_file" ]; then
            palette-generator either "$image" "$cache_file" > /dev/null
          fi
          echo "$cache_file"
        }

        swatches_for() {
          local json_file="$1" key hex
          for key in base00 base01 base02 base03 base04 base05 base06 base07 \
                     base08 base09 base0A base0B base0C base0D base0E base0F; do
            hex=$(jq -r ".\"$key\"" "$json_file")
            printf '\e[48;2;%d;%d;%dm  \e[0m' "0x''${hex:0:2}" "0x''${hex:2:2}" "0x''${hex:4:2}"
          done
          echo
        }

        preview() {
          local image="$wallpapers_dir/$1" json_file cols lines img_lines
          cols="''${FZF_PREVIEW_COLUMNS:-40}"
          lines="''${FZF_PREVIEW_LINES:-20}"
          # Leaves room under the image for the blank line + swatch row.
          img_lines=$(( lines > 3 ? lines - 3 : 1 ))
          chafa --format=symbols --size="''${cols}x''${img_lines}" "$image" 2> /dev/null
          echo
          json_file=$(palette_json_for "$image")
          swatches_for "$json_file"
        }

        if [ "''${1:-}" = "--preview" ]; then
          preview "$2"
          exit 0
        fi

        if [ "''${1:-}" = "--reset" ]; then
          reset_selection
          echo "Back to the repo default ($default_value)..."
          exec hm-switch
        fi

        wallpapers=("$wallpapers_dir"/*.jpg "$wallpapers_dir"/*.jpeg "$wallpapers_dir"/*.png "$wallpapers_dir"/*.webp)
        if [ ''${#wallpapers[@]} -eq 0 ]; then
          echo "No wallpapers in $wallpapers_dir — drop images in there and commit them." >&2
          exit 1
        fi

        IFS=$'\t' read -r current_kind current source < <(read_selection)
        [ "$current_kind" = "scheme" ] || current="$current ($current_kind)"

        selected=$(
          for image in "''${wallpapers[@]}"; do
            basename "$image"
          done | sort | fzf \
            --preview "$0 --preview {}" \
            --preview-window=right:50% \
            --header="current: $current [$source]  |  enter: switch to this wallpaper  |  wallpaper-pick --reset: repo default"
        )

        [ -n "$selected" ] || exit 0

        write_selection "wallpaper" "$selected"

        echo "Switching to $selected..."
        exec hm-switch
      '';
    })
  ];
}
