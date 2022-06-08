## -------------------------------------------------- ##
##           GITPOD-ENHANCED DOCKERFILE 2             ##
##              MIT © 2022 @nberlette                 ##
## -------------------------------------------------- ##

FROM gitpod/workspace-full

LABEL org.opencontainers.image.title="Gitpod Enhanced"
LABEL org.opencontainers.image.description="Turbocharged Gitpod Workspace image, forked from gitpod/workspace-full."
LABEL org.opencontainers.image.author="Nicholas Berlette <nick@berlette.com>"
LABEL org.opencontainers.image.source="https://github.com/nberlette/gitpod-enhanced"
LABEL org.opencontainers.image.license="MIT"
LABEL repository="https://github.com/nberlette/gitpod-enhanced"
LABEL maintainer="nberlette"

WORKDIR /home/gitpod

# update system packages and cleanup cache
ARG DEBIAN_FRONTEND=noninteractive
RUN sudo apt-get -y update && sudo apt-get -y upgrade && sudo rm -rf /var/lib/apt/lists/*

USER gitpod

# update/upgrade/cleanup homebrew packages
RUN brew update && brew upgrade && brew cleanup

# install + configure pnpm to run from a new location
# then setup Node.js LTS (long-term support)
RUN curl -fsSL https://get.pnpm.io/install.sh | bash - ; \
    pnpm env use --global lts 2>/dev/null; \
    export PNPM_HOME="$HOME/.local/share/pnpm"; \
    export PATH="$PNPM_HOME:$PATH"; pnpm setup; \
    # update pnpm (if needed) and add CLI packages
    pnpm add --global \
        pnpm \
        nuxi \
        turbo \
        vercel \
        wrangler \
        miniflare \
        netlify-cli \
        @railway/cli \
        dotenv-vault ; \
    # install some of my preferred development toolkit
    pnpm add --global \
        zx \
        harx \
        esno \
        vite \
        degit \
        bumpp \
        serve \
        unbuild \
        vitest \
        eslint \
        vue-cli \
        @brlt/n \
        prettier \
        typescript \
        @brlt/utils \
        @brlt/prettier \
        @changesets/cli \
        @brlt/eslint-config ;

# copy a couple files needed for the next couple steps
COPY --chown=gitpod:gitpod [ ".tarignore", ".Brewfile", "/home/gitpod/" ]

# clone and extract dotfiles into homedir, filtering with .tarignore file
RUN curl -fsSL "https://github.com/nberlette/dotfiles/archive/main.tar.gz" | \
    tar -xz -C "$HOME" --overwrite -X ~/.tarignore --wildcards --anchored \
    --ignore-case --exclude-backups --exclude-vcs --backup=existing --totals \
    --strip-components=1 -o --owner=gitpod --group=gitpod ;

# clean some things up; append new gitconfig file -> existing .gitconfig (if any)
RUN cat "$HOME/gitconfig" >> "$HOME/.gitconfig" && \
    rm -f "$HOME/gitconfig" 2>/dev/null; \
    # backup existing .gitignore and rename gitignore -> .gitignore
    rm -f "$HOME/.gitignore" &>/dev/null; \
    mv -f "$HOME/gitignore" "$HOME/.gitignore" &>/dev/null ; \
    # append .nix-profile inclusion to .bash_profile; remove .profile
    echo -e '\n[ -r /home/gitpod/.nix-profile/etc/profile.d/nix.sh ] && . /home/gitpod/.nix-profile/etc/profile.d/nix.sh;\n' \
    >> "$HOME/.bash_profile" ; \
    rm -f "$HOME/.profile" ;

# configure homebrew prefix and add to path - we will dedupe it later; its a total mess.
RUN export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}"; \
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"; \
    # install the homebrew packages from ~/.Brewfile, show success message if all goes well
    brew bundle install --global --no-lock && \
    echo -e "\n\e[1;92;7m SUCCESS! \e[0;1;3;92m gitpod-enhanced setup completed \e[0m\n";

# hooray!
