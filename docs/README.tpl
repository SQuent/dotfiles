# Dotfiles

**Welcome to my Dotfiles repository!** This collection contains all the configurations for my personal machines and servers.

---

### What are Dotfiles?
Dotfiles are hidden configuration files (prefixed with a `.`) in Unix-like systems. They store settings for shells, editors, and various tools, allowing for easy customization and consistency across different environments.

---

### Why Store Dotfiles in Git?
- **Effortless Deployment:** Easily set up new environments.
- **Synchronization:** Keep your settings synced across multiple devices.
- **Rollback:** Revert changes with ease.
- **Backup:** Ensure nothing is lost.

---

### Dotbot: The Dotfile Manager
I use [Dotbot](https://github.com/anishathalye/dotbot) to manage these dotfiles. It not only handles symlinks but also manages package installations and scripts. Symlinks allow you to maintain all your dotfiles in a central Git directory, linking them to the appropriate locations on disk.

---

### Installation Modes
- **Linux:** Full setup via apt bootstrap + Homebrew + common configuration.
- **macOS:** Setup via Homebrew only — no apt, font handling via `~/Library/Fonts`.

---

## Getting Started

### Installation
```bash
git clone https://github.com/SQuent/dotfiles.git && cd dotfiles && ./install
```
The script auto-detects the OS (`Darwin` or `Linux`) and runs the appropriate steps.

### Testing in Docker (Linux)
````bash
git clone https://github.com/SQuent/dotfiles.git && cd dotfiles
docker build . -t dotfiles:linux -f Dockerfile --progress=plain
docker run -it dotfiles:linux
````

---

## Dotbot in Action

### Installation Script
The installation script is a wrapper around [Dotbot](https://github.com/anishathalye/dotbot) with the following features:
- Auto-detects the OS (`uname -s`) — no flags required.
- Logs actions to `install.log`.
- Checks and installs prerequisites before running Dotbot.
- Syncs and updates Dotbot plugins via git submodules.
- Splits configuration across three files: `common.conf.yaml`, `linux.conf.yaml`, `mac.conf.yaml`.

---

### Dotbot Steps

**Linux (3 passes):**
1. Bootstrap: `apt-get update/upgrade`, install `curl`, `python3`, `git`, `python3-dev`.
2. Pass 1 — `linux.conf.yaml` (`--only apt`): install APT packages.
3. Pass 2 — `common.conf.yaml`: clean, create folders, symlinks, Homebrew install + packages, mise tool install.
4. Pass 3 — `linux.conf.yaml` (`--except apt`): Linux-specific brew (`trash-cli`), sudoers, default shell, font cache.

**macOS (2 passes):**
1. Check Xcode Command Line Tools, set Homebrew PATH.
2. Pass 1 — `common.conf.yaml`: clean, create folders, symlinks, Homebrew install + packages, mise tool install.
3. Pass 2 — `mac.conf.yaml`: macOS-specific brew (`trash`), `~/Library/Fonts` symlink.

---

## Features

### XDG Directories
Manage the location of configuration files using the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) for a clutter-free home directory. These are declared in [`config/.profile`](config/.profile).

---

### Shell: Zsh Configuration

[Zsh](http://zsh.sourceforge.net/), or the Z Shell, is a powerful and highly customizable Unix shell that extends the Bourne shell (`sh`).

```bash
config/zsh
├── .zshrc
├── aliases.zsh           # Personal Aliases
├── functions.zsh         # Personal Functions
├── history.zsh           # History Management 
├── import-plugins.zsh    # Plugins to install
└── setup-antigen.zsh     # Zsh plugin installer
```

#### Plugins
- **Syntax Highlighting:** [`zsh-users/zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting)
- **Extra Completions:** [`zsh-users/zsh-completions`](https://github.com/zsh-users/zsh-completions)
- **Auto Suggestions:** [`zsh-users/zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions)
- **Kubectl Aliases:** [`dbz/kube-aliases`](https://github.com/Dbz/kube-aliases)
- **Alias Tips:** [`djui/alias-tips`](https://github.com/djui/alias-tips)

#### Shell History Management
Handled in [`config/zsh/history.zsh`](config/zsh/history.zsh).  
I bind the arrow keys to search through the history for commands that start with the current input.

#### Machine-Local Config (not tracked)
For machine-specific settings that should never be committed, create `~/.zshenv`.


---

### Visualization Tools
- [**Starship:**](https://github.com/starship/starship) For a minimal, fast, and customizable prompt. Config stored in [`config/starship.toml`](config/starship.toml).
- [**EZA:**](https://github.com/eza-community/eza) Enhanced `ls` command for better file listing. 
  **Color:**
  ```bash
  export EXA_COLORS="ur=34:uw=35:ux=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36"
  ```

- [**Bat:**](https://github.com/sharkdp/bat) A `cat` clone with syntax highlighting.

  ```bash
  if command_exists bat ; then
    alias cat="bat -pp"
  fi
  ```

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
[**fnox**](https://fnox.jdx.dev/) reads secrets from BWS and injects them as environment variables.

#### SSH Keys Management
SSH keys and the config are stored in BWS as secrets named `SSH_<filename>`.
```bash
load_ssh_keys   # fetches all SSH_* secrets from BWS → ~/.ssh/
```

---

### Multi-Git Management
Manage multiple Git profiles (github, gitlab, personal instance of gitlab) with [**mise**](https://mise.jdx.dev/) directory-level environment configuration.  
Each `git/` subdirectory has a `mise.toml` symlinked from dotfiles, which sets Git identity variables when entering the directory:

````
git
├── github          ← default identity
│   ├── helm-kuma-ingress-watcher
│   └── kuma-ingress-watcher
├── gitlab
│   └── dotfiles
├── nas
│   └── qlabv1
└── work
    └── Infrastructure

````

#### Pre-commit Auto-Install

A global `cd` mise hook automatically runs `pre-commit install` when entering to a git repo root.

---
### Version Management with mise

[**mise**](https://mise.jdx.dev/) manages multiple runtime versions per project.

#### Automatic Version Management

- **Auto-Discovery:** Detects `.tool-versions` and `mise.toml` files in project directories

---

### Quick save file
#### Dropbox Management

Sometimes, you need to quick save some files in an external storage. I use [Dropbox](https://www.dropbox.com/). 

First, ensure that you have the Dropbox CLI tool installed and configure your Dropbox access token as follows:

```bash
export DROPBOX_PERSONAL_TOKEN=
```

Dropbox integration functions include:

- **`load_dbx`**: Creates a configuration directory and sets up Dropbox CLI authentication using the `DROPBOX_PERSONAL_TOKEN`.

- **`dbxpush`**: Uploads a local file or directory to /tmp directory in Dropbox. Usage example:
  ```bash
  dbxpush <local-file-or-directory>
  ```

- **`dbxget`**: Downloads a file from /tmp directory in Dropbox to the local machine. Usage example:
  ```bash
  dbxget <remote-file>
  ```

- **`dbxclean`**: Cleans up temporary files in Dropbox. ( including config dir with token, but not the environment var with the token)

These functions are included in [`config/zsh/functions.zsh`](config/zsh/functions.zsh), which ensures efficient management of Dropbox operations within your setup.

---

### Multi-windows Terminal with Tmux

[**Tmux**](https://github.com/tmux/tmux) is a terminal multiplexer that allows you to manage multiple terminal sessions within a single window.

My Tmux configuration, stored in [`config/tmux/tmux.conf`](config/tmux/tmux.conf), includes:

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
- **Custom Screensaver:  Commented** - The lock screen is configured to display a [`cbonsai`](https://github.com/neauoire/CBonsai) animation after 180 seconds of inactivity. This can be switched to [`cmatrix`](https://github.com/abishekvashok/cmatrix) or [`asciiquarium`](https://github.com/cmatsuoka/asciiquarium) for alternative screensavers.

---

### Garbage Management with Trash

To avoid accidentally deleting files permanently, I replace `rm` with a trash tool:
- **Linux:** [`trash-cli`](https://github.com/andreafrancia/trash-cli) — follows the freedesktop.org trash spec.
- **macOS:** [`trash`](https://github.com/ali-rantakari/trash) — moves files to the macOS Trash.

Aliases are set for trash management in both cases.

---

### Editors

### Neovim

**[Neovim](https://neovim.io/)** configured with [LazyVim](https://www.lazyvim.org/).

- **Theme:** [`AlexvZyl/nordic.nvim`](https://github.com/AlexvZyl/nordic.nvim)

---

### Visual Studio Code

**[Visual Studio Code](https://code.visualstudio.com/)** is a code editor developed by Microsoft.

Dotfiles for VsCode are: 
- settings.json
- Profile

---

## Installed Packages

### APT Packages (Linux only)

| Package Name      | Description                                                  | Linux |
|-------------------|--------------------------------------------------------------|-------|
{{- range (datasource "apt_packages").apt_packages }}
| {{ .name }}       | {{ .description | default "No description" }}                | {{ if eq .in_linux "yes" }}✔️{{ else }}❌{{ end }} |
{{- end }}

---

### Brew Packages

| Package Name      | Description                                                  | Linux | macOS |
|-------------------|--------------------------------------------------------------|-------|-------|
{{- range (datasource "brew_packages").brew_packages }}
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