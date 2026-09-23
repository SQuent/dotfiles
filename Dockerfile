FROM ubuntu:jammy
ARG user=cynis
ARG group=cynis
ARG uid=1000

USER root

# Without pipefail, a failing `curl | sh` silently reports success.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y sudo curl ca-certificates git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${uid} ${group} || true && \
    useradd -m -u ${uid} -g ${group} ${user} && \
    echo "%${group} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ENV DOTFILES_DIR="/home/${user}/dotfiles"
WORKDIR /home/${user}

COPY . $DOTFILES_DIR
RUN chown -R ${user}:${group} $DOTFILES_DIR

# Same ./install every real machine uses; it detects no init system and
# installs Nix with --init none itself. USER/LOGNAME/HOME are overridden so
# home/default.nix resolves against ${user}, even though this still runs as
# root. Confirmed by testing: --init none leaves no persistent nix-daemon,
# and a non-root user can't reach a daemon-less multi-user store directly
# ("Permission denied" on the store lock) — root can, since it owns the
# store outright. The profile dir is pre-created since home-manager expects
# it to exist.
RUN install -d -m 0755 -o ${user} -g ${group} "/home/${user}/.local/state/nix/profiles" && \
    USER=${user} LOGNAME=${user} HOME="/home/${user}" "/home/${user}/dotfiles/install" && \
    chown -R ${user}:${group} /home/${user}

USER ${user}
WORKDIR /home/${user}

# ENTRYPOINT execs zsh directly (see below), bypassing login/PAM — nothing
# else would export these, and home-manager's own CLI needs $USER (e.g. to
# resolve /nix/var/nix/profiles/per-user/$USER/home-manager) or it dies
# with "unbound variable" under its `set -u`.
ENV USER=${user}
ENV LOGNAME=${user}

# Nix's mismatched-$HOME safety check makes the user-environment install
# land in root's own profile instead of ${user}'s (the process above is
# genuinely root). That path is fixed, independent of ${user}, so
# ENTRYPOINT can point at it directly — no PATH lookup or symlink needed.
# (home/zsh.nix's `nixDaemon` zshInit entry covers what a system zsh
# package's /etc/zprofile would otherwise set up for this login shell.)
ENTRYPOINT ["/nix/var/nix/profiles/per-user/root/profile/bin/zsh", "-l"]
