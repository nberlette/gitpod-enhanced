## -------------------------------------------------- ##
##           GITPOD-ENHANCED DOCKERFILE 2             ##
##              MIT © 2022 @nberlette                 ##
## -------------------------------------------------- ##

FROM gitpod/workspace-full

# container metadata
LABEL org.opencontainers.image.title="Gitpod Enhanced"
LABEL org.opencontainers.image.description="An enhanced fork of Gitpod's workspace-full image."
LABEL org.opencontainers.image.author="Nicholas Berlette <nick@berlette.com>"
LABEL org.opencontainers.image.source="https://github.com/nberlette/gitpod-enhanced"
LABEL org.opencontainers.image.license="MIT"
LABEL repository="https://github.com/nberlette/gitpod-enhanced"
LABEL maintainer="nberlette"

# update and upgrade stuff
ARG DEBIAN_FRONTEND=noninteractive
RUN brew update && brew upgrade && brew cleanup
# RUN sudo apt-get -y update && sudo apt-get -y upgrade && sudo rm -rf /var/lib/apt/lists/*

# make sure we are running this as the user 'gitpod'
USER gitpod

# configure pnpm 
RUN export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; \
    which pnpm &>/dev/null || curl -fsSL https://get.pnpm.io/install.sh | bash - ; \
    pnpm setup ;
    
# setup node.js v16.15.1 since 17.x has some nasty breaking changes
RUN NODE_VERSION=16.15.1 pnpm env use --global "${NODE_VERSION:-lts}";
# update pnpm if needed, add hosting provider packages
RUN pnpm add -g pnpm@latest vercel wrangler miniflare netlify-cli @railway/cli;
# add development toolkit packages I use a lot
RUN pnpm add -g typescript ts-node @types/node eslint prettier degit harx sirv-cli bumpp\
                @brlt/eslint-config @brlt/n @brlt/prettier @brlt/utils ;

# configure homebrew prefix (if it does not already exist) + add to PATH
RUN export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}"; \
    echo -n "$PATH" | grep -q "${HOMEBREW_PREFIX-}/bin" || export PATH="$HOMEBREW_PREFIX/bin:$PATH"; \
    export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"; 

WORKDIR /home/gitpod

# copy a couple files needed for the next couple steps
COPY --chown=gitpod:gitpod [ ".tarignore", ".Brewfile", "/home/gitpod/" ]

# clone and extract dotfiles into homedir, filtering with .tarignore file
RUN curl -fsSL "https://github.com/nberlette/dotfiles/archive/main.tar.gz" | \
    tar -xz -C "$HOME" --overwrite -X ~/.tarignore --wildcards --anchored \
    --ignore-case --exclude-backups --exclude-vcs --backup=existing --totals \
    --strip-components=1 -o --owner=gitpod --group=gitpod ;
    
# clean some things up; append new gitconfig file -> existing .gitconfig (if any)
RUN cat "$HOME/gitconfig" >> "$HOME/.gitconfig" ; \
    # remove old gitconfig file, rename gitignore -> .gitignore
    rm -f "$HOME/gitconfig" 2>/dev/null; \
    # backup existing .gitignore and rename gitignore -> .gitignore
    mv -f "$HOME/.gitignore" "$HOME/.gitignore~" 2>/dev/null; \
    mv -f "$HOME/gitignore" "$HOME/.gitignore" 2>/dev/null; \
    # append .nix-profile inclusion to .bash_profile; remove .profile
    echo -e '\n[ -r /home/gitpod/.nix-profile/etc/profile.d/nix.sh ] && . /home/gitpod/.nix-profile/etc/profile.d/nix.sh;\n' >> "$HOME/.bash_profile"; \
    rm -f "$HOME/.profile" ;
    
# install the homebrew packages from ~/.Brewfile, show success message if all goes well
RUN brew bundle install --global --no-lock && brew cleanup && \
    echo -e "\n\e[1;92;7m SUCCESS! \e[0;1;3;92m gitpod-enhanced setup completed \e[0m\n" ; 
