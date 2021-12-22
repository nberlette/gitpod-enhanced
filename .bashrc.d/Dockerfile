## -------------------------------------------------- ##
##             CUSTOM GITPOD DOCKERFILE               ##
##              MIT © 2021 @nberlette                 ##
## -------------------------------------------------- ##

FROM gitpod/workspace-full:latest

USER root
RUN apt-get update \
 && apt-get install -y git-extras neovim

USER gitpod
RUN brew install fzf

COPY ./prompt.sh $HOME/.bashrc.d/10-prompt
COPY ./profile.sh $HOME/.bashrc.d/10-profile

RUN printf "\e[1;4;7;32m COMPLETED \e[0;1;32m have a great coding session! :)\e[0m"

## -------------------------------------------------- ##
##             END OF GITPOD DOCKERFILE               ##
## -------------------------------------------------- ##
