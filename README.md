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
Manage multiple Git profiles (github, gitlab, personal instance of gitlab) using a combination of [**fnox**](https://fnox.jdx.dev/) and [**mise**](https://mise.jdx.dev/) directory-level configuration.  
Each `git/` subdirectory has both a `fnox.toml` (git identity + tokens, from BWS) and a `mise.toml` (SSH key routing) symlinked from dotfiles:

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

- **Auto-Discovery:** Detects `mise.toml` files in project directories (also supports `.tool-versions`)

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
| build-essential       | Essential tools for building software (GCC, g++, make…)                | ✔️ |
| curl       | Command line tool for transferring data with URL syntax                | ✔️ |
| lsb-release       | Linux Standard Base distribution information                | ✔️ |
| ca-certificates       | Common CA certificates for SSL validation                | ✔️ |
| procps       | System utilities: ps, top, vmstat, kill…                | ✔️ |
| file       | Determine file type from content                | ✔️ |
| zsh       | Z Shell                | ✔️ |

---

### Brew Packages

| Package Name      | Description                                                  | Linux | macOS |
|-------------------|--------------------------------------------------------------|-------|-------|
| gnupg       | GNU Privacy Guard                | ✔️ | ✔️ |
| fontconfig       | Library for configuring and customizing font access                | ✔️ | ✔️ |
| wget       | Network downloader                | ✔️ | ✔️ |
| watch       | Execute a program periodically, showing output fullscreen                | ✔️ | ✔️ |
| yq       | YAML processor (like jq for YAML)                | ✔️ | ✔️ |
| jq       | Command-line JSON processor                | ✔️ | ✔️ |
| btop       | Better than htop                | ✔️ | ✔️ |
| scc       | For counting the lines of code, blank lines, comment lines, and physical lines of source code in many programming languages.                | ✔️ | ✔️ |
| duf       | Get info on mounted disks (better df)                | ✔️ | ✔️ |
| sd       | RegEx find and replace (better sed)                | ✔️ | ✔️ |
| mise       | Polyglot runtime version manager (asdf-compatible)                | ✔️ | ✔️ |
| tmux       | Terminal multiplexer                | ✔️ | ✔️ |
| fd       | Simple, fast and user-friendly alternative to 'find'                | ✔️ | ✔️ |
| starship       | Minimal, blazing-fast, and infinitely customizable prompt for any shell                | ✔️ | ✔️ |
| eza       | Listing files with info (better ls)                | ✔️ | ✔️ |
| bat       | Output highlighting (better cat)                | ✔️ | ✔️ |
| neovim       | Hyperextensible Vim-based text editor                | ✔️ | ✔️ |
| thefuck       | App which corrects your previous console command.                | ✔️ | ✔️ |
| fastfetch       | Show system data and distro info (replaces neofetch)                | ✔️ | ✔️ |
| tree       | Display directories as trees                | ✔️ | ✔️ |
| libyaml       | YAML Parser                | ✔️ | ✔️ |
| docker       | Platform to build, run, and share containerized applications                | ✔️ | ✔️ |
| docker-compose       | Define and run multi-container applications with Docker                | ✔️ | ✔️ |
| podman       | Tool for managing OCI containers and pods                | ✔️ | ✔️ |
| kubectx       | Switch faster between clusters and namespaces in kubectl                | ✔️ | ✔️ |
| kustomize       | Kubernetes native configuration management                | ✔️ | ✔️ |
| kdash       | Kubernetes dashboard app                | ✔️ | ✔️ |
| lazydocker       | Full Docker management app                | ✔️ | ✔️ |
| helm-docs       | Autogenerate doc for Helm charts                | ✔️ | ✔️ |
| krew       | plugin manager for kubectl command-line tool.                | ✔️ | ✔️ |
| derailed/k9s/k9s       | Kubernetes CLI to manage your clusters in style!                | ✔️ | ✔️ |
| ctop       | Container metrics and monitoring                | ✔️ | ✔️ |
| docker-completion       | Bash, Zsh and Fish completion for Docker                | ✔️ | ✔️ |
| gitlab-ci-local       | Build all pipeline or specific job locally                | ✔️ | ✔️ |
| k3sup       | Bootstrap Kubernetes with k3s over SSH < 1 min                | ✔️ | ✔️ |
| argocd-autopilot       | Bootstrap ArgoCD Autopilot                | ✔️ | ✔️ |
| pwgen       | Password generator                | ✔️ | ✔️ |
| fdupes       | Duplicate file finder                | ✔️ | ✔️ |
| gping       | Interactive ping tool, with graph                | ✔️ | ✔️ |
| httpie       | HTTP / API testing client                | ✔️ | ✔️ |
| entr       | Run command when files change (for testing when you change code directly launch program)                | ✔️ | ✔️ |
| ttygif       | Make gif from terminal                | ✔️ | ✔️ |
| tldr       | Simplified and community-driven man pages                | ✔️ | ✔️ |
| librsvg       | To use rsvg-convert docker-compose.svg > docker-compose.png                | ✔️ | ✔️ |
| asciiquarium       | Fish tank animation in your terminal                | ✔️ | ✔️ |
| cmatrix       | Console Matrix                | ✔️ | ✔️ |
| figlet       | Banner-like program prints strings as ASCII art                | ✔️ | ✔️ |
| cbonsai       | terminal bonzai in ASCII                | ✔️ | ✔️ |
| trash-cli       | CLI for the freedesktop.org trashcan (Linux)                | ✔️ | ❌ |
| trash       | CLI to move files to the macOS Trash (replaces Linux trash-cli)                | ❌ | ✔️ |
| coreutils       | GNU coreutils (gdate → date -I, etc.) — binaries exposed via gnubin                | ❌ | ✔️ |
| util-linux       | Linux util-linux tools: setsid, flock, etc.                | ❌ | ✔️ |

---

### mise Tools

| Package Name      | Description                                                  | Linux | macOS |
|-------------------|--------------------------------------------------------------|-------|-------|
| python       | Python programming language                | ✔️ | ✔️ |
| golang       | Go programming language                | ✔️ | ✔️ |
| terraform       | Infrastructure as code software tool                | ✔️ | ✔️ |
| terragrunt       | Thin wrapper for Terraform with extra tools for multiple modules                | ✔️ | ✔️ |
| opentofu       | Open source version of Terraform                | ✔️ | ✔️ |
| kubectl       | Kubernetes command-line tool                | ✔️ | ✔️ |
| helm       | The Kubernetes package manager                | ✔️ | ✔️ |
| minikube       | Run Kubernetes locally                | ✔️ | ✔️ |
| awscli       | Official Amazon AWS command-line interface                | ✔️ | ✔️ |
| packer       | Tool for creating identical machine images for multiple platforms                | ✔️ | ✔️ |
| poetry       | Python dependency management and packaging made easy                | ✔️ | ✔️ |
| pre-commit       | Framework for managing and running pre-commit hooks                | ✔️ | ✔️ |
| tflint       | Terraform linter                | ✔️ | ✔️ |
| fzf       | Command-line fuzzy finder                | ✔️ | ✔️ |
| act       | Run GitHub Actions locally                | ✔️ | ✔️ |
| glab       | CLI for GitLab                | ✔️ | ✔️ |
| gomplate       | Template renderer for generating files (e.g. README)                | ✔️ | ✔️ |
| fnox       | Local secrets manager, Fort Knox for your secrets                | ✔️ | ✔️ |
| bitwarden-secrets-manager       | Bitwarden Secrets Manager command-line interface                | ✔️ | ✔️ |
| rclone       | rsync for cloud storage                | ✔️ | ✔️ |

---