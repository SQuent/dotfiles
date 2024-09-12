FROM ubuntu:jammy

ARG user=cynis
ARG group=cynis
ARG uid=1000

USER root

RUN groupadd -g ${uid} ${group} || true && \
    useradd -m -u ${uid} -g ${group} ${user} && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y sudo && \
    echo "%${group} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ENV DOTFILES_DIR="/home/${user}/dotfiles"

RUN mkdir -p $DOTFILES_DIR

COPY . $DOTFILES_DIR

RUN chown -R ${user}:${group} $DOTFILES_DIR

USER ${user}
WORKDIR /home/${user}

RUN $DOTFILES_DIR/install

# Définir l'entrée par défaut
ENTRYPOINT ["/bin/zsh", "-l"]