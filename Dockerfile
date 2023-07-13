FROM gitpod/workspace-full

LABEL org.opencontainers.image.title="Gitpod Enhanced"
LABEL org.opencontainers.image.description="Turbocharged Gitpod Workspace image based on gitpod/workspace-full."
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
RUN brew cleanup; brew update; brew upgrade;

# copy a couple files needed for the next couple steps
COPY --chown=gitpod:gitpod [ ".tarignore", ".Brewfile", "/home/gitpod/" ]

# pull down and extract nberlette/dotfiles with curl + tar
RUN curl -fsSL "https://github.com/nberlette/dotfiles/archive/main.tar.gz" | \
    tar -xz -C "$HOME" --overwrite -X ~/.tarignore --wildcards --anchored \
    --ignore-case --exclude-backups --exclude-vcs --backup=existing --totals \
    --strip-components=1 -o --owner=gitpod --group=gitpod ;

# clean some things up with .gitconfig and .gitignore
RUN rm -f "$HOME/.profile" &>/dev/null; \
    # fix unsafe permissions on .gnupg folder
    chmod 700 "$HOME/.gnupg";
    
# download and run standalone pnpm installer
RUN which pnpm &>/dev/null || { \
        curl -fsSL https://get.pnpm.io/install.sh | bash -; \
        pnpm env use --global lts 2>/dev/null; \
    }; 

# update pnpm and install some development tools
RUN pnpm add -g pnpm vercel wrangler miniflare netlify-cli @railway/cli dotenv-vault; pnpm add -g zx harx esno degit bumpp vitest eslint unbuild prettier typescript ; pnpm add -g @brlt/n @brlt/prettier @brlt/eslint-config ; 
    
    
RUN export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}"; \
    export DENO_INSTALL="${HOME}/.deno"; \
    export PATH="${DENO_INSTALL}/bin:${HOMEBREW_PREFIX}/bin:${PATH}"; \ 
    mkdir -p "$DENO_INSTALL"; \
    curl -fsSL https://deno.land/install.sh | sh - ; \
    chown -R gitpod "$DENO_INSTALL"; \
    echo '#!/usr/bin/env bash\\n\\nexport DENO_INSTALL="$HOME/.deno" PATH="$DENO_INSTALL/bin:$PATH";\\nwhich deno &>/dev/null || curl -fsSL https://deno.land/install.sh | sh -;\\nwhich deno &>/dev/null && deno upgrade --force --quiet --unstable;\\n' > "$HOME/.bashrc.d/123-deno" && \
    chmod +x "$HOME/.bashrc.d/123-deno" ;

# install the homebrew packages from ~/.Brewfile
RUN brew bundle install --global --no-lock ; \
    sudo ln -s $(which gpg) $(which gh) /usr/local/bin/ &>/dev/null; \
    mv -f "/home/gitpod/gitignore" "/home/gitpod/.gitignore" &>/dev/null; \
    mv -f "/home/gitpod/gitconfig" "/home/gitpod/.gitconfig" &>/dev/null; \
    echo -e "\n\e[1;92;7m SUCCESS! \e[0;1;3;92m gitpod-enhanced setup completed \e[0m\n";

## ----------------------------------------------------- ##
##        Gitpod Enhanced - https://git.io/gitpod        ##
## ----------------------------------------------------- ##
##                MIT © Nicholas Berlette                ##
## ----------------------------------------------------- ##
