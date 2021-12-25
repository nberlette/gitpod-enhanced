## -------------------------------------------------- ##
##            GITPOD-ENHANCED DOCKERFILE              ##
##              MIT © 2021 @nberlette                 ##
## -------------------------------------------------- ##

FROM gitpod/workspace-base:latest

LABEL org.opencontainers.image.title="Gitpod Enhanced" 
LABEL org.opencontainers.image.description="An enhanced fork of Gitpod's workspace-full image."
LABEL org.opencontainers.image.author="Nicholas Berlette <nick@berlette.com>"
LABEL org.opencontainers.image.url="https://n.berlette.com/gitpod-enhanced"
LABEL org.opencontainers.image.source="https://github.com/nberlette/gitpod-enhanced"
LABEL org.opencontainers.image.licenses="MIT" 

USER root 

RUN apt-get -y update && apt-get -y install \
    git-extras \
    neovim \
 && rm -rf /var/lib/apt/lists/*

USER gitpod

RUN brew install fzf \
 && brew install gh

# https://git.io/git-ps1 - short url for git-prompt.sh in git/git repo
ADD --chown=gitpod "https://git.io/git-ps1" "$HOME/.bashrc.d/10-prompt"
COPY .bash_profile "$HOME/.bashrc.d/20-profile"

RUN chmod 0755 "$HOME/.bashrc.d/10-prompt" \
 && chmod 0755 "$HOME/.bashrc.d/20-profile"

ENV PATH="$(yarn global bin):$PATH"

RUN yarn global add pnpm @antfu/ni degit typescript@4.5.3 tslib @types/node ts-node esm