# Dotfiles

**Welcome to my Dotfiles repository!** This collection contains all the configurations for my personal machines, managed declaratively with [Nix](https://nixos.org/) + [Home Manager](https://github.com/nix-community/home-manager).

---

### What are Dotfiles?
Dotfiles are hidden configuration files (prefixed with a `.`) in Unix-like systems. They store settings for shells, editors, and various tools.

---

### Why Store Dotfiles in Git?
- **Effortless Deployment:** Easily set up new environments.
- **Synchronization:** Keep your settings synced across multiple devices.
- **Rollback:** Revert changes with ease.

---

### Why Nix + Home Manager?
Nix is a package manager, but it comes with its own philosophy: declarative, and therefore reproducible, with rollback built in.
This is the exact idea dotfiles already chase, just applied to packages instead of config files. 
And it doesn't stop there: [**NixOS**](https://nixos.org/) turns that same philosophy into a whole operating system, while [**Home Manager**](https://github.com/nix-community/home-manager) nix community package, applies it one level down, to `$HOME`.
I run it standalone home manager. 

With a classic dotfiles manager, adding a new tool means touching several places (install script, config symlinks, alias). With Nix, it's one declarative block. 
And the same setup runs almost identically anywhere: macOS, Linux, even a plain Docker container.
The trade-off is a real learning curve, since it comes with its own language. 
But it's a smooth path to swith to NixOS one day.

[**Flakes**](https://nixos.wiki/wiki/Flakes) are a experimental feature of nix which pins dependencies to exact git commit with  ([`flake.nix`](flake.nix) + [`flake.lock`](flake.lock)).

---

### One Flake for All My Machines

Most Home Manager setups are tied to specific machine. I wanted this dotfiles to works on any machine with different username.
It support the OS/arch (`aarch64-darwin` / `x86_64-linux` / `aarch64-linux`).
So instead of hardcoding who I am and where my home is, the flake figures it out by itself (with --impure).

---

## Getting Started

### Installation
```bash
git clone https://github.com/SQuent/dotfiles.git && cd dotfiles && ./install
```
[`./install`](install)

### Updating

List previous generations:
```bash
hmg
```

Roll back to the previous generation:
```bash
hmrb
```

Update the Nix packages:
```bash
hmu
./install
```
To update a single input instead (e.g. just `nixpkgs`):
```bash
hmu nixpkgs
./install
```

### Testing in Docker
```bash
docker build -t dotfiles .
docker run -it dotfiles
```

### Working on this repo

`git commit` or `pc` run the [pre-commit hooks](.pre-commit-config.yaml).

---

## Repository Structure

```
.
├── flake.nix          — inputs, outputs (`homeConfigurations`, `devShells`, `apps`, `formatter`)
├── flake.lock         — pinned revisions
├── home/              — one module per program (packages + config + aliases colocated),
│   │                     every file auto-imported by import-tree, no list to maintain
│   ├── default.nix    — entrypoint: username/homeDirectory + the `dotfiles.path` option
│   ├── dirs.nix       — directories 
│   ├── hm-switch.nix  — the `hm-switch` binary (rebuild + activate)
│   ├── home-manager.nix — aliases for driving this flake
│   ├── packages.nix   — all packages with no config needed
│   ├── shell/          
│   ├── cli/
│   ├── dev/
│   ├── env/
│   └── theme/
├── wallpapers/ 
│
└── config/            — native config files sourced by a home/*.nix module
```

---

## Features

### XDG Directories
[XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) env vars, declared in [`home/shell/xdg.nix`](home/shell/xdg.nix).

---

### Shell: Zsh

- Configured in [`home/shell/zsh.nix`](home/shell/zsh.nix) (completion, history, plugins)
— functions kept as real shell logic in [`config/zsh/functions.zsh`](config/zsh/functions.zsh).

#### Plugins:
- [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting), [`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions) — native Home Manager toggles (`programs.zsh.syntaxHighlighting`/`autosuggestion.enable`).
- [`zsh-completions`](https://github.com/zsh-users/zsh-completions)
- [`alias-tips`](https://github.com/djui/alias-tips) — via `programs.zsh.antidote.plugins`.
- [`kube-aliases`](https://github.com/Dbz/kube-aliases) ([`home/dev/kubernetes.nix`](home/dev/kubernetes.nix)) — fetched via `programs.zsh.plugins`.
- [`nix-zsh-completions`](https://github.com/nix-community/nix-zsh-completions) — not configured explicitly: Home Manager adds it automatically to `home.packages` whenever `programs.zsh.enableCompletion` is set (which it is here).

#### Machine-Local Config (not tracked)
For machine-specific settings that should never be committed, create `~/.zshenv`.

---

### Terminal Experience
- [**Starship**](https://github.com/starship/starship) - prompt
- [**eza**](https://github.com/eza-community/eza) - replace listing (ll, la, tree...)
- [**zoxide**](https://github.com/ajeetdsouza/zoxide) - replace cd
- [**bat**](https://github.com/sharkdp/bat) - replace cat
- [**yazi**](https://github.com/sxyazi/yazi) - terminal file manager


### Theming with Stylix

Every tool's colors come from one place: [**Stylix**](https://stylix.danth.me/).

Switching theme is one of two commands: `theme-pick` (alias tp) to browse and pick a named scheme, or `wallpaper-pick` (alias wp). Those two commands launch rebuild after switching and don't modify the nix config.

Here default theme: [`home/theme/_default.nix`](home/theme/_default.nix).

---

### Editors

#### Neovim
[**Neovim**](https://neovim.io/) via [LazyVim](https://www.lazyvim.org/) (the [`lazyvim-nix`](https://github.com/pfassina/lazyvim-nix) flake input), configured in [`home/dev/nvim.nix`](home/dev/nvim.nix). Not Stylix-themed on purpose — keeps its own fixed colorscheme.

#### Visual Studio Code
[**Visual Studio Code**](https://code.visualstudio.com/) — `settings.json` + profile (not yet Nix-managed).

---

### Sensitive Data
Sensitive data (secrets, SSH keys, tokens) are not committed to this repository. They are stored in [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/) (BWS)

#### Bootstrap file (`~/.bws`, not committed)
Create `~/.bws` with your BWS credentials — this file is sourced at shell startup before fnox runs:
```bash
export BWS_ACCESS_TOKEN=
export BWS_PROJECT_ID=
```

#### Secret Management with fnox
[**fnox**](https://fnox.jdx.dev/) reads secrets from BWS and injects them as environment variables ([`home/env/fnox.nix`](home/env/fnox.nix), [`config/fnox/`](config/fnox)).

#### SSH Keys Management
SSH keys and config are stored in BWS as `SSH_<filename>` secrets:
```bash
load_ssh_keys   # fetches all SSH_* secrets from BWS → ~/.ssh/
```

---

### Multi-Git Management
Multiple Git identities (github, gitlab, work, nas), routed via [**fnox**](https://fnox.jdx.dev/) + [**mise**](https://mise.jdx.dev/) directory config. Each `git/<context>/` gets a `fnox.toml` + `mise.toml` from [`home/env/fnox.nix`](home/env/fnox.nix)/[`home/env/mise.nix`](home/env/mise.nix):

```
git
├── github          ← default identity
├── gitlab
├── nas
└── work
```

#### Pre-commit Auto-Install
A global mise `cd` hook ([`config/mise/global.toml`](config/mise/global.toml)) runs `pre-commit install` when entering a git repo root or `$HOME`.

---

### Version Management with mise

[**mise**](https://mise.jdx.dev/) manages multiple runtime versions per project, replace nix by mise for depandancies that can change per project.  Activated from [`home/env/mise.nix`](home/env/mise.nix).

#### Automatic Version Management

- **Auto-Discovery:** Detects `mise.toml` files in project directories (supports `.tool-versions`).


---

### Multi-windows Terminal with Tmux

[**Tmux**](https://github.com/tmux/tmux) is a terminal multiplexer that allows you to manage multiple terminal sessions within a single window.

My Tmux configuration, stored in [`home/cli/tmux.nix`](home/cli/tmux.nix), includes:

- **Right click for menu**

- **Custom Prefix Key:** `Ctrl+b` (tmux default)
  - `Ctrl+b and after v` — horizontal split (top/bottom)
  - `Ctrl+b and after h` — vertical split (left/right)
  - `Ctrl+b and after arrow keys (→, ←, ↑, ↓)` — switch between panes
  - `Ctrl+b and after w` — interactive session/window tree

- **Copy mode** (cross-platform, copies to system clipboard):
  - Mouse drag — select & copy
  - Double-click — select word & copy
  - Triple-click — select line & copy
- **Custom Screensaver: Commented** - The lock screen is configured to display a [`cbonsai`](https://github.com/neauoire/CBonsai) animation after 180 seconds of inactivity. This can be switched to [`cmatrix`](https://github.com/abishekvashok/cmatrix) or [`asciiquarium`](https://github.com/cmatsuoka/asciiquarium) for alternative screensavers.

---

### Garbage Management with Trash

`rm` is replaced by [`gtrash`](https://github.com/umlx5h/gtrash):

- `rm <file>`: move to trash
- `tl [regex]`: list trash
- `trs`: restore (interactive)
- `rmtrash <regex>`: delete from trash
- `tempty`: empty trash
- `ts`: trash summary


---

### Quick save file
#### Dropbox Management

Sometimes, you need to quick save some files in an external storage. I use [Dropbox](https://www.dropbox.com/) via [**rclone**](https://rclone.org/).

Dropbox credentials are stored in BWS and injected by fnox as `RCLONE_CONFIG_DBX_*` environment variables. The OAuth2 refresh token enables automatic token renewal.

Dropbox functions (defined in [`config/zsh/functions.zsh`](config/zsh/functions.zsh)):

- **`dbxpush`**: Uploads a local file or directory to `/tmp/` in Dropbox.
  ```bash
  dbxpush <local-file-or-directory>
  ```

- **`dbxget`**: Downloads a file from `/tmp/` in Dropbox to the current directory.
  ```bash
  dbxget <remote-file>
  ```

- **`dbxclean`**: Deletes all files under `/tmp/` in Dropbox.

---

## Installed Packages

### Nix Packages (`home.packages`, via Home Manager)

| Package Name      | Description                                                  | Linux | macOS |
|-------------------|--------------------------------------------------------------|-------|-------|
{{- range (datasource "nix_packages").nix_packages }}
| {{ .name }}       | {{ .description | default "No description" }}                | {{ if eq .in_linux "yes" }}✔️{{ else }}❌{{ end }} | {{ if eq .in_mac "yes" }}✔️{{ else }}❌{{ end }} |
{{- end }}

---

### mise Tools

| Package Name      | Description                                                  | Linux | macOS |
|-------------------|--------------------------------------------------------------|-------|-------|
{{- range (datasource "mise_packages").mise_packages }}
| {{ .name }}       | {{ .description | default "No description" }}                | {{ if eq .in_linux "yes" }}✔️{{ else }}❌{{ end }} | {{ if eq .in_mac "yes" }}✔️{{ else }}❌{{ end }} |
{{- end }}

---