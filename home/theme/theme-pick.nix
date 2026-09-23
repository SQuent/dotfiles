{
  pkgs,
  lib,
  config,
  ...
}:
let
  selectionLib = builtins.readFile ./selection.sh;
  defaultTheme = import ./_default.nix;
in
# `theme-pick`: fzf over every base16 scheme in pkgs.base16-schemes
# (~200 files), previewing each scheme's swatches and name/author/variant. Selecting one
# writes this machine's theme override (read by home/theme/stylix.nix, outside
# the repo) and rebuilds via `hm-switch`. `theme-pick --reset` drops the
# override, back to home/theme/_default.nix.
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "theme-pick";
      runtimeInputs = [
        pkgs.fzf
        pkgs.gawk
        pkgs.gnugrep
        pkgs.coreutils
        pkgs.jq
        config.dotfiles.hmSwitch
      ];
      text = ''
        shopt -s nullglob

        themes_dir="${pkgs.base16-schemes}/share/themes"
        selection_file=${lib.escapeShellArg config.dotfiles.theme.selectionFile}
        default_kind=${lib.escapeShellArg defaultTheme.kind}
        default_value=${lib.escapeShellArg defaultTheme.value}

        ${selectionLib}

        # Base16 scheme yaml looks like:
        #   name: "Nord"
        #   author: "arcticicestudio"
        #   variant: "dark"
        #   palette:
        #     base00: "#2E3440"
        #     ...
        preview() {
          local file="$themes_dir/$1.yaml"
          awk -F'"' '/^[[:space:]]*base0[0-9A-Fa-f]:/ { gsub(/^#/, "", $2); print $2 }' "$file" |
            while read -r hex; do
              printf '\e[48;2;%d;%d;%dm  \e[0m' "0x''${hex:0:2}" "0x''${hex:2:2}" "0x''${hex:4:2}"
            done
          printf '\n\n'
          grep -E '^(name|author|variant):' "$file"
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

        list=$(for f in "$themes_dir"/*.yaml; do basename "$f" .yaml; done | sort)

        IFS=$'\t' read -r current_kind current source < <(read_selection)
        # Cursor starts on the current scheme; after wallpaper-pick there is
        # none, so it just starts at the top.
        [ "$current_kind" = "scheme" ] || current="$current ($current_kind)"
        pos=$(printf '%s\n' "$list" | grep -nxF "$current" | head -1 | cut -d: -f1)
        [ -n "$pos" ] || pos=1

        selected=$(
          printf '%s\n' "$list" | fzf \
            --sync \
            --bind "start:pos($pos)" \
            --preview "$0 --preview {}" \
            --preview-window=right:40% \
            --header="current: $current [$source]  |  enter: switch to this theme  |  theme-pick --reset: repo default"
        )

        [ -n "$selected" ] || exit 0

        write_selection "scheme" "$selected"

        echo "Switching to $selected..."
        exec hm-switch
      '';
    })
  ];
}
