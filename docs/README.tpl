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
- **Personal Machines:** Full setup including all configurations and packages.
- **Servers:** Minimal setup with terminal configurations and fewer packages.

---

## Getting Started

### Personal Machine Installation:
```bash
git clone https://github.com/SQuent/dotfiles.git && cd dotfiles && ./install
```
[Clone the repository] and run the installation script.


### Server Installation:
```bash
git clone https://github.com/SQuent/dotfiles.git && cd dotfiles && ./install -l
```
[Clone the repository] and run the server installation script with the `-l` option.

### Testing in Docker
You can build an image for both: 

**Personnal Machine:**
````bash
git clone https://github.com/SQuent/dotfiles.git && cd dotfiles
docker build . -t dotfiles:light -f Dockerfile.light --progress=plain 
docker run -it dotfiles:light

````

**Server:**
````bash
git clone https://github.com/SQuent/dotfiles.git && cd dotfiles
docker build . -t dotfiles:full -f Dockerfile --progress=plain 
docker run -it dotfiles:full

````

---

## Dotbot in Action

### Installation Script
The installation script is a wrapper around [Dotbot](https://github.com/anishathalye/dotbot) with the following features:
- Manages both personal and server deployments.
- Logs actions to `install.log`.
- Checks and installs prerequisites (e.g., `apt update`, `python3`, `git`, `curl`).
- Syncs and updates Dotbot plugins via git submodules.
- Executes Dotbot with apt packages installation to get prerequisites for other actions.
- Executes all Dotbot steps except apt packages installation.

---

### Dotbot Steps
1. Clean the `~/` directory.
2. Create necessary folders.
3. Link configuration files with symlinks.
4. Install APT packages.
5. Install Homebrew and packages if not already installed.
6. Install npm packages.
7. Configure the shell environment.

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
Sensitive data like secrets, SSH keys, and kubeconfigs are not committed to the dotfiles repository. These are stored in [Bitwarden](https://bitwarden.com/) SAAS and managed with [`bitwarden-cli`](https://github.com/bitwarden/cli) and functions in [`config/zsh/functions.zsh`](config/zsh/functions.zsh).

First, you need to install the CLI, [create client and secret id in Bitwarden](https://bitwarden.com/help/personal-api-key/), and configure `~/.bw` as follows:
```bash
export BW_CLIENTSECRET=
export BW_CLIENTID=
export BW_PSSWD=
export BW_SECRET_NOTE_ID=
export BW_SSH_FOLDER_ID=
```

#### Secret Management
Secrets are stored in a Bitwarden note (referenced by `BW_SECRET_NOTE_ID`). Functions to manage these secrets include:
- `load_secret`: Load secrets from Bitwarden and source them.
- `clean_secret`: Remove files with secrets.

#### SSH Keys Management
SSH key files and ssh config file are stored in a Bitwarden folder and managed using the `load_ssh_keys` function to populate the `~/.ssh` folder.

#### Kubeconfig Management

---

### Multi-Git Management
Manage multiple Git profiles (github, gitlab, personnal instance of gitlab) with [`direnv`](https://github.com/direnv/direnv).  
Loading environment variables in directories with specific organization repositories:

````
git
├── github
│   ├── helm-kuma-ingress-watcher
│   └── kuma-ingress-watcher
├── gitlab
│   ├── dotfiles
├── nas
│   └── qlabv1
└── work
    └── Infrastructure

````
And for each directory i have GIT VARS loaded from other environment VARS when i go to the dir:
````
export GIT_SSH_COMMAND="ssh -i ~/.ssh/gitlab_id_rsa -F /dev/null"
export GIT_AUTHOR_NAME=$USER_GIT_GITLAB
export GIT_AUTHOR_EMAIL=$EMAIL_GIT_GITLAB
export GIT_COMMITTER_NAME=$USER_GIT_GITLAB
export GIT_COMMITTER_EMAIL=$EMAIL_GIT_GITLAB
````
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

My Tmux configuration, stored in [`config/.tmux.conf`](config/.tmux.conf), includes:

- **Mouse Support:** Allows window resizing with the mouse and enables a context menu with a right-click on a window.
- **Custom Prefix Key:**
  - The default prefix key (`C-b`) is changed to `Ctrl + Space` for easier access.
  - `Ctrl + Space + v` for vertical splits.
  - `Ctrl + Space + h` for horizontal splits.
  - `Ctrl + Space + arrow keys (→, ←, ↑, ↓)` to switch between windows.
- **Custom Screensaver:** The lock screen is configured to display a [`cbonsai`](https://github.com/neauoire/CBonsai) animation after 180 seconds of inactivity. This can be switched to [`cmatrix`](https://github.com/abishekvashok/cmatrix) or [`asciiquarium`](https://github.com/cmatsuoka/asciiquarium) for alternative screensavers.

---

### Garbage Management with Trash

To avoid accidentally deleting files permanently, I use [trash-cli](https://github.com/andreafrancia/trash-cli). i replace rm by this. This tool moves files to the trash, allowing for easy recovery if needed. 
Aliases are set for trash management.

---

### Editors

### Neovim

**[Neovim](https://neovim.io/)** is an extensible and modular text editor based on Vim. I use a pre-built version of [NvChad](https://github.com/NvChad/NvChad), a framework for Neovim that provides a ready-to-use configuration with numerous plugins and enhancements.

---

### Visual Studio Code

**[Visual Studio Code](https://code.visualstudio.com/)** is a code editor developed by Microsoft.

Dotfiles for VsCode are: 
- settings.json
- Profile

---

## Installed Packages

### APT Packages

| Package Name      | Description                                                  | In Full | In Light |
|-------------------|--------------------------------------------------------------|---------|----------|
{{- range (datasource "apt_packages").apt_packages }}
| {{ .name }}       | {{ .description | default "No description" }}                | {{ if eq .in_full "yes" }}✔️{{ else }}❌{{ end }} | {{ if eq .in_light "yes" }}✔️{{ else }}❌{{ end }} |
{{- end }}

---

### Brew Packages

| Package Name      | Description                                                  | In Full | In Light |
|-------------------|--------------------------------------------------------------|---------|----------|
{{- range (datasource "brew_packages").brew_packages }}
| {{ .name }}       | {{ .description | default "No description" }}                | {{ if eq .in_full "yes" }}✔️{{ else }}❌{{ end }} | {{ if eq .in_light "yes" }}✔️{{ else }}❌{{ end }} |
{{- end }}

---