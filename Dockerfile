FROM gitpod/workspace-full

LABEL description "Gitpod Enhanced: a turbocharged fork of the official image gitpod/workspace-full."
LABEL repository "https://github.com/nberlette/gitpod-enhanced"
LABEL maintainer "Nicholas Berlette <nick@berlette.com>"

## -------------------------------------------------- ##
##   Gitpod Enhanced · Turbocharged Workspace Image   ##
##    https://github.com/nberlette/gitpod-enhanced    ##
## -------------------------------------------------- ##

ARG DEBIAN_FRONTEND=noninteractive
RUN sudo apt-get -y update && \
    sudo apt-get -y install git-extras neovim && \
    sudo rm -rf /var/lib/apt/lists/*

USER gitpod

RUN brew update && brew install fzf gh

## https://git.io/git-ps1 -> https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh
ADD --chown=gitpod:gitpod "https://git.io/git-ps1" "$HOME/.bashrc.d/00-git-ps1"
ADD --chown=gitpod:gitpod .bash_aliases "$HOME/.bashrc.d/00-aliases"
ADD --chown=gitpod:gitpod .bash_prompt "$HOME/.bashrc.d/01-prompt"
ADD --chown=gitpod:gitpod .bash_profile "$HOME/.bashrc.d/02-gitpod"

RUN chmod 0755 "$HOME"/.bashrc.d/*

RUN curl -fsSL https://get.pnpm.io/install.sh | sh -

ENV PATH="$HOME/.yarn/bin:$PATH"

RUN pnpm i -g @types/node typescript tslib tsm tsup ts-node >& /dev/null; \
    pnpm i -g turbo vercel wrangler@^0.0.17 miniflare@^2.3.0 cron-scheduler \
              @antfu/ni degit esm standard bundt uvu eslint prettier \
              prettier-plugin-sh shellcheck >& /dev/null ;
