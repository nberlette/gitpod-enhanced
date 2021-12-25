## -------------------------------------------------- ##
##            GITPOD-ENHANCED DOCKERFILE              ##
##              MIT © 2021 @nberlette                 ##
## -------------------------------------------------- ##

FROM gitpod/workspace-full

LABEL org.opencontainers.image.title="Gitpod Enhanced"
LABEL org.opencontainers.image.description="An enhanced fork of Gitpod's workspace-full image."
LABEL org.opencontainers.image.author="Nicholas Berlette <nick@berlette.com>"
LABEL org.opencontainers.image.source="https://github.com/nberlette/gitpod-enhanced"
LABEL org.opencontainers.image.licenses="MIT"

RUN sudo apt-get -y update && sudo apt-get -y install \
    git-extras \
    neovim \
 && sudo rm -rf /var/lib/apt/lists/*

USER gitpod

RUN brew install \
    fzf \
    gh

# https://git.io/git-ps1 - short url for git-prompt.sh in git/git repo
ADD --chown=gitpod "https://git.io/git-ps1" "/home/gitpod/.bashrc.d/00-gitpod-enhanced"

RUN chmod 0755 "/home/gitpod/.bashrc.d/00-gitpod-enhanced"

ADD --chown=gitpod .bashrc "/home/gitpod/.gitpod-enhanced"

RUN echo -e "\n\n#### nberlette/gitpod-enhanced ####\n$(cat /home/gitpod/.gitpod-enhanced)" \
    >> /home/gitpod/.bashrc.d/00-gitpod-enhanced && rm -f /home/gitpod/.gitpod-enhanced

ENV PATH="/home/gitpod/.yarn/bin:$PATH"

RUN yarn global add --non-interactive --no-progress pnpm @antfu/ni degit
