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
RUN export PNPM_HOME="$HOME/.local/share/pnpm"; \
    export PATH="$HOME/.local/share/pnpm:$PATH"; \
    which pnpm &>/dev/null || { \
       curl -fsSL https://get.pnpm.io/install.sh | bash - && \
       pnpm env --global use 16.15.0 ; \
    }; pnpm i -g pnpm @brlt/n ;

# configure our homebrew prefix (if it does not already exist) + add to PATH
# then make sure we have GNU coreutils and rsync (for install.sh)
RUN export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}"; \
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"; \
    export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"; \
    brew install rsync coreutils ;

# set workdir to our homedir
WORKDIR /home/gitpod

# add the .gitpod.d directory containing our dotfiles and installer
ADD --chown=gitpod:gitpod .gitpod.d ".gitpod.d"

# set exec permissions for installer, just in case
RUN chmod +x .gitpod.d/install.sh

# run the installer in non-interactive mode, then remove the .gitpod.d directory
RUN NON_INTERACTIVE=1 .gitpod.d/install.sh && \
    sudo rm -rf .gitpod.d && \
    echo fin.
