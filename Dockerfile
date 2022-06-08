## -------------------------------------------------- ##
##           GITPOD-ENHANCED DOCKERFILE 2             ##
##              MIT © 2022 @nberlette                 ##
## -------------------------------------------------- ##

FROM gitpod/workspace-full

# container metadata
LABEL org.opencontainers.image.title="Gitpod Enhanced"
LABEL org.opencontainers.image.description="An enhanced fork of Gitpod's workspace-full image."
LABEL org.opencontainers.image.author="Nicholas Berlette <nick@berlette.com>"
LABEL org.opencontainers.image.source="https://github.com/nberlette/gitpod-enhanced"
LABEL org.opencontainers.image.license="MIT"
LABEL repository="https://github.com/nberlette/gitpod-enhanced"
LABEL maintainer="nberlette"

# update and upgrade stuff
ARG DEBIAN_FRONTEND=noninteractive
RUN brew update && brew upgrade && brew cleanup
# RUN sudo apt-get -y update && sudo apt-get -y upgrade && sudo rm -rf /var/lib/apt/lists/*

# make sure we are running this as the user 'gitpod'
USER gitpod

# configure pnpm and nodejs
RUN export NODE_VERSION=16.15.1; \
    export PNPM_HOME="$HOME/.local/share/pnpm"; \
    export PATH="$PNPM_HOME:$PATH"; \
    which pnpm &>/dev/null || \
          curl -fsSL https://get.pnpm.io/install.sh | sh - ; \
    pnpm env use --global "${NODE_VERSION:-lts}"; \
    pnpm setup && pnpm i -g pnpm @brlt/n ;

# configure homebrew prefix (if it does not already exist) + add to PATH
RUN export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}"; \
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"; \
    export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"; 

WORKDIR /home/gitpod

# copy a couple files needed for installation
COPY --chown=gitpod:gitpod [ ".tarignore", ".Brewfile", "/home/gitpod/" ]

# download dotfiles as .tar.gz from github, extract into homedir
RUN curl -fsSL "https://github.com/nberlette/dotfiles/archive/main.tar.gz" | \
    tar -xz -C "$HOME" --overwrite -X ~/.tarignore --wildcards --anchored \
    --ignore-case --exclude-backups --exclude-vcs --backup=existing --totals \
    --strip-components=1 -o --owner=gitpod --group=gitpod ;  \
    # install the homebrew packages from ~/.Brewfile
    brew bundle install --global --no-lock && brew cleanup --force ;

# clean some things up to finalize installation
RUN echo "\\n[ -e ~/.nix-profile/etc/profile.d/nix.sh ] && . ~/.nix-profile/etc/profile.d/nix.sh;\\n" >> "$HOME/.bash_profile"; \
    # append contents of .gitconfig to existing .gitconfig 
    cat "$HOME/gitconfig" >> "$HOME/.gitconfig" ; \
    # rename gitignore -> .gitignore
    mv -f "$HOME/.gitignore" "$HOME/.gitignore~" 2>/dev/null; \
    mv -f "$HOME/gitignore" "$HOME/.gitignore" 2>/dev/null; \
    # a lil housekeeping
    rm -f "$HOME/.profile" "$HOME/gitconfig" "$HOME/.tarignore" ; \
    # all done!
    echo -e "\n\e[1;92;7m SUCCESS \e[0;1;3;92m gitpod-enhanced setup completed! \e[0m\n" ; 
