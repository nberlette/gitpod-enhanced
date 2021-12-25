## -------------------------------------------------- ##
##            GITPOD-ENHANCED DOCKERFILE              ##
##              MIT © 2021 @nberlette                 ##
## -------------------------------------------------- ##

FROM gitpod/workspace-full

LABEL org.opencontainers.image.title="Gitpod Enhanced" \
      org.opencontainers.image.description="An enhanced fork of Gitpod's workspace-full image." \
      org.opencontainers.image.author="Nicholas Berlette <nick@berlette.com>" \
      org.opencontainers.image.url="https://n.berlette.com/gitpod-enhanced" \
      org.opencontainers.image.source="https://github.com/nberlette/gitpod-enhanced" \
      org.opencontainers.image.licenses="MIT" 

RUN brew install fzf gh

USER root 

RUN apt-get -y update && apt-get -y install \
    git-extras \
    neovim \
 && rm -rf /var/lib/apt/lists/*

USER gitpod

# https://git.io/git-ps1 - short url for git-prompt.sh in git/git repo
ADD --chown=gitpod "https://git.io/git-ps1" "$HOME/.bashrc.d/10-prompt"
COPY .bash_profile "$HOME/.bashrc.d/20-profile"

RUN chmod 0755 "$HOME/.bashrc.d/10-prompt" \
 && chmod 0755 "$HOME/.bashrc.d/20-profile"