## -------------------------------------------------- ##
##            GITPOD-ENHANCED DOCKERFILE              ##
##              MIT © 2021 @nberlette                 ##
## -------------------------------------------------- ##

FROM gitpod/workspace-full:latest

LABEL org.opencontainers.image.title="Gitpod Enhanced" \
      org.opencontainers.image.description="Gitpod's official workspace-full image, with enhancements." \
      org.opencontainers.image.author="Nicholas Berlette <nick@berlette.com>" \
      org.opencontainers.image.url="https://github.com/nberlette/gitpod-enhanced#readme" \
      org.opencontainers.image.source="https://github.com/nberlette/gitpod-enhanced" \
      org.opencontainers.image.licenses="MIT" 

RUN brew install fzf && brew install gh

RUN sudo apt-get -y update \
 && sudo apt-get -y install git-extras neovim

ADD "https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh" /home/gitpod/.bashrc.d/10-prompt
COPY .bashrc.d/profile.sh /home/gitpod/.bashrc.d/11-profile

## -------------------------------------------------- ##
##        END OF GITPOD-ENHANCED DOCKERFILE           ##
## -------------------------------------------------- ##
