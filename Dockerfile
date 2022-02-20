## -------------------------------------------------- ##
##            GITPOD-ENHANCED DOCKERFILE              ##
##              MIT © 2022 @nberlette                 ##
## -------------------------------------------------- ##

FROM gitpod/workspace-full

LABEL org.opencontainers.image.title="Gitpod Enhanced"
LABEL org.opencontainers.image.description="An enhanced fork of Gitpod's workspace-full image."
LABEL org.opencontainers.image.author="Nicholas Berlette <nick@berlette.com>"
LABEL org.opencontainers.image.source="https://github.com/nberlette/gitpod-enhanced"
LABEL org.opencontainers.image.license="MIT"

ARG DEBIAN_FRONTEND=noninteractive
RUN sudo apt-get -y update \
 && sudo apt-get -y install \
    git-extras \
    neovim \
 && sudo rm -rf /var/lib/apt/lists/*

USER gitpod

RUN brew update && brew install fzf gh

# https://git.io/git-ps1 - short url for git-prompt.sh in git/git repo
ADD --chown=gitpod "https://git.io/git-ps1" "/home/gitpod/.bashrc.d/00-git-ps1"

RUN chmod 0755 "/home/gitpod/.bashrc.d/00-git-ps1"

ADD --chown=gitpod:gitpod .aliases "/home/gitpod/.bashrc.d/00-aliases"
ADD --chown=gitpod:gitpod .prompt "/home/gitpod/.bashrc.d/00-prompt"
ADD --chown=gitpod:gitpod .profile "/home/gitpod/.bashrc.d/00-gitpod"

ENV PATH="/home/gitpod/.yarn/bin:$PATH"

RUN curl -fsSL https://get.pnpm.io/install.sh | sh -

RUN pnpm install --global \
   @antfu/ni turbo vercel \
   degit esm standard bundt uvu \
   eslint prettier prettier-plugin-sh shellcheck \
   @types/node typescript tslib tsm tsup ts-node \
   wrangler@beta miniflare cron-scheduler > /dev/null 2>&1;
