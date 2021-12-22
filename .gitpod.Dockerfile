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
RUN brew install fzf
RUN sudo apt-get -y update \
 && sudo apt-get -y install git-extras neovim
COPY .bashrc.d/prompt.sh $HOME/.bashrc.d/10-prompt
COPY .bashrc.d/profile.sh $HOME/.bashrc.d/10-profile

## -------------------------------------------------- ##
##             END OF GITPOD DOCKERFILE               ##
## -------------------------------------------------- ##
