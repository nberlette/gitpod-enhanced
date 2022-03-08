FROM gitpod/workspace-full

## -------------------------------------------------- ##
##   Gitpod Enhanced · Turbocharged Workspace Image   ##
##    https://github.com/nberlette/gitpod-enhanced    ##
## -------------------------------------------------- ##

LABEL description "Gitpod Enhanced: a turbocharged fork of gitpod/workspace-full."
LABEL repository "https://github.com/nberlette/gitpod-enhanced"
LABEL maintainer "Nicholas Berlette <nick@berlette.com>"

USER gitpod

ARG DEBIAN_FRONTEND=noninteractive
RUN sudo apt-get -y update && \
    sudo apt-get -y install git-extras neovim && \
    sudo rm -rf /var/lib/apt/lists/*

RUN brew update && brew install fzf gh

RUN curl -fsSL https://get.pnpm.io/install.sh | sh -

## https://git.io/git-ps1 is just an alias for:
## https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh
ADD --chown=gitpod:gitpod "https://git.io/git-ps1" "$HOME/.bashrc.d/00-git-ps1"

ADD --chown=gitpod:gitpod .bash_aliases "$HOME/.bashrc.d/00-aliases"
ADD --chown=gitpod:gitpod .bash_prompt "$HOME/.bashrc.d/01-prompt"
ADD --chown=gitpod:gitpod .bash_profile "$HOME/.bashrc.d/02-gitpod"

RUN chmod 0755 "$HOME"/.bashrc.d/*

ENV PATH="$HOME/.yarn/bin:$PATH"

RUN pnpm i -g @types/node typescript tslib tsm tsup ts-node 2>/dev/null; \
    pnpm i -g turbo vercel wrangler@beta miniflare@2.3.0 cron-scheduler \
              @antfu/ni degit esm standard bundt uvu eslint prettier \
              prettier-plugin-sh shellcheck 2>/dev/null ;
