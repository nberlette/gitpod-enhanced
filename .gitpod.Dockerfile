## -------------------------------------------------- ##
##             CUSTOM GITPOD DOCKERFILE               ##
##              MIT © 2021 @nberlette                 ##
## -------------------------------------------------- ##

FROM gitpod/workspace-full:latest

LABEL org.opencontainers.image.title="Gitpod Workspace: Enhanced" \
      org.opencontainers.image.description="Custom gitpod workspace with git prompt and more." \
      org.opencontainers.image.url="https://github.com/nberlette/gitpod-enhanced#readme" \
      org.opencontainers.image.source="https://github.com/nberlette/gitpod-enhanced" \
      org.opencontainers.image.licenses="MIT"

USER root
RUN apt-get update \
 && apt-get install -y git-extras neovim
COPY .bashrc.d/prompt.sh $HOME/.bashrc.d/10-prompt
COPY .bashrc.d/profile.sh $HOME/.bashrc.d/10-profile

USER gitpod
RUN brew install fzf
RUN printf "\e[1;4;7;32m COMPLETED \e[0;1;32m have a great coding session! :)\e[0m"

## -------------------------------------------------- ##
##             END OF GITPOD DOCKERFILE               ##
## -------------------------------------------------- ##
