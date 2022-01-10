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
ADD --chown=gitpod "https://git.io/git-ps1" "/home/gitpod/.bashrc.d/00-gitpod"

RUN chmod 0755 "/home/gitpod/.bashrc.d/00-gitpod"

ADD --chown=gitpod .profile "/home/gitpod/.gitpod.profile"

RUN echo "\n\n#### gitpod-enhanced ####\n$(cat /home/gitpod/.gitpod.profile)" \
 >> /home/gitpod/.bashrc.d/00-gitpod && rm -f /home/gitpod/.gitpod.profile

ENV PATH="/home/gitpod/.yarn/bin:$PATH"

RUN yarn global add --non-interactive --no-progress \
    @antfu/ni \
    @types/node \
    degit \
    esm \
    pnpm \
    standard \
    typescript \
    tslib \
    tsm \
    ts-node \
    ts-standard
