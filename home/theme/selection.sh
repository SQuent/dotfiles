# Shared bash snippet, spliced into theme-pick.nix and wallpaper-pick.nix
#
# Expects $selection_file, $default_kind and $default_value to be set, and
# jq on PATH.

# Prints "<kind>\t<value>\t<source>": the local override if there is one,
# else the repo default.
read_selection() {
  if [ -f "$selection_file" ]; then
    jq -r '"\(.kind)\t\(.value)\toverride"' "$selection_file"
  else
    printf '%s\t%s\tdefault\n' "$default_kind" "$default_value"
  fi
}

write_selection() {
  mkdir -p "$(dirname "$selection_file")"
  jq -n --arg kind "$1" --arg value "$2" '{kind: $kind, value: $value}' > "$selection_file"
}

# Drops the local override, falling back to the repo default.
reset_selection() {
  rm -f "$selection_file"
}
