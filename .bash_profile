#!/usr/bin/env bash
###############################################################################
##                            ~ GITPOD-ENHANCED ~                            ##
####          Turbocharged Development Image for Gitpod Workspaces         ####
###############################################################################
#####  MIT License (c) 2022+ Nicholas Berlette - <https://git.io/gitpod>  #####
###############################################################################

# shellcheck shell=bash
# shellcheck disable=SC2178,SC2125,SC2059,SC2155,SC2086
# shellcheck source=/dev/null

#### FUNCTIONS #################################################################

function get_var () {
    eval 'printf "%s\n" "${'"$1"'}"'
}

function set_var () {
    eval "$1=\"\$2\""
}

function dedupe_path () {
    local pathvar_name pathvar_value deduped_path
    pathvar_name="${1:-PATH}"
    pathvar_value="$(get_var "$pathvar_name")"
    deduped_path="$(perl -e 'print join(":",grep { not $seen{$_}++ } split(/:/, $ARGV[0]))' "$pathvar_value")"
    set_var "$pathvar_name" "$deduped_path"
}

#### experimental GNUPG (PGP) support
function __gpg_gitconfig () {
    # set default key in gitconfig (optional)
    [ -n "${GPG_KEY_ID-}" ] && git config --global user.signingkey "${GPG_KEY_ID-}" ;

    # enable signing for commits and tags by default
    git config --global commit.gpgsign "true" ;
    git config --global tag.gpgsign "true" ;
}

function __gpg_vscode () {
    local VSCODE SETTINGS_JSON
    # ensure a .vscode folder exists
    VSCODE="/workspace/.vscode-remote"
    [ -d "$VSCODE" ] || mkdir -p "$VSCODE"; 

    # ensure a valid settings.json file exists
    SETTINGS_JSON="$VSCODE/settings.json"
    [ -f "$SETTINGS_JSON" ] || echo "{}" > "$SETTINGS_JSON" ;

    # use jq to edit .vscode/settings.json, enable pgp signing
    # shellcheck disable=SC2005
    echo "$(jq '.["git.enableCommitSigning"]=true | .' "$SETTINGS_JSON")" > "$SETTINGS_JSON" || return 1;
}

function __gpg_init () {
    unset GPG_CONFIGURED;
    local PINENTRY_CONF GPG_CONF
    PINENTRY_CONF='pinentry-mode loopback'
    GPG_CONF="$HOME/.gnupg/gpg.conf" ;

    touch "$GPG_CONF";
    
    if ! grep -q "$PINENTRY_CONF" "$GPG_CONF" > /dev/null 2>&1; then
        echo "$PINENTRY_CONF" >> "$GPG_CONF"
    fi

    # import our base64-encoded secret key/keys (dangerous)
    gpg --batch --import <(echo "${GPG_KEY-}" | base64 -d) > /dev/null 2>&1 ;

    # setup gitconfig and vscode settings for gpg signatures
    __gpg_gitconfig ;
    __gpg_vscode ;

    # reload gpg-agent
    gpg-connect-agent reloadagent /bye > /dev/null 2>&1 ;

    export GPG_CONFIGURED=1 ;
}

# TODO: #6 implement SSH-key integration at runtime
function __ssh_init () {
    if [ -n "$SSH_KEY" ]; then 
        return 0;
    fi
    return 1;
}

#### Authenticate GitHub CLI on start if a PAT ($GITHUB_TOKEN) exists in Gitpod
# TODO: #7 [feature] convert gh auth login to dotfiles (.config/gh)
function __gh_login () {
    local __GH_TOKEN
    if [ -n "$GITHUB_TOKEN" ] && which gh > /dev/null 2>&1; then
        # GitHub CLI doesn't authenticate if $GITHUB_TOKEN is in use.
        # so we copy to a local variable and unset the global one. (janky)
        __GH_TOKEN=${GITHUB_TOKEN-} && unset GITHUB_TOKEN;
        # now we login with $__GH_TOKEN and error out on failure
        echo -n "${__GH_TOKEN-}" | 
            gh auth login --with-token 2>/dev/null && return 0;
        # still here? stop script, bad login
        return 1;
    fi
}

## xpm: cross-package-manager
## uses pnpm, if available, and falls back to npm if not.
function xpm () {
    # if we don't have pnpm, let's get it
    if ! which pnpm > /dev/null 2>&1; then
        if which curl > /dev/null 2>&1; then
            curl -fsSL https://get.pnpm.io/install.sh | bash - > /dev/null 2>&1;
        else
            wget -qO- https://get.pnpm.io/install.sh | bash - > /dev/null 2>&1;
        fi
        xpm "$@";
    fi
    pnpm "$@" || npm "$@";
}

function __vercel () {
	local GLOBAL_CFG LOCAL_CFG __VC_CFG __VC_FLAGS
    # global vercel config (directory)
	GLOBAL_CFG=/workspace/.vercel
	LOCAL_CFG="${THEIA_WORKSPACE_ROOT-}/vercel.json";
	__VC_CFG="${GLOBAL_CFG:+"${GLOBAL_CFG-}/project.json"}";
	__VC_FLAGS=""

    if [[ "${1-}" == "login" ]]; then
        __VC_FLAGS+=" --oob";
    fi

    [ -n "${VERCEL_FLAGS-}" ] && __VC_FLAGS+=" ${VERCEL_FLAGS-}";
    [ -n "${VERCEL_TOKEN-}" ] && __VC_FLAGS+=" --token=${VERCEL_TOKEN-}";

    if [ -n "${GLOBAL_CFG-}" ]; then
        # shellcheck disable=SC2174
		[ -d "${GLOBAL_CFG-}" ] || mkdir -p -m 0755 "${GLOBAL_CFG-}" ;
        __VC_FLAGS+=" --global-config=${GLOBAL_CFG-}";
    fi

    if [ -n "${LOCAL_CFG-}" ] && [ -f "${LOCAL_CFG-}" ]; then
        __VC_FLAGS+=" --local-config=${LOCAL_CFG-}";
    fi

    __VC_FLAGS="$(echo "${__VC_FLAGS-}" | sed -e 's/^ *//' -e 's/ *$//')";
    eval "$(which vercel) ${__VC_FLAGS-} ${*}" && return 0;
    return 1;
}

## Vercel CLI Auto-Authentication
alias vercel="__vercel"
alias vc="__vercel"

function __path () {
    local NODE_V=$(node -v 2>/dev/null);
	local DEFAULT_PATH="/home/gitpod/.nix-profile/bin:/home/gitpod/.pyenv/plugins/pyenv-virtualenv/shims:/home/gitpod/.nix-profile/bin:/home/gitpod/.sdkman/candidates/maven/current/bin:/home/gitpod/.sdkman/candidates/java/current/bin:/home/gitpod/.sdkman/candidates/gradle/current/bin:/home/gitpod/.pyenv/plugins/pyenv-virtualenv/shims:/home/gitpod/.rvm/gems/default/bin:/home/gitpod/.rvm/rubies/default/bin:/ide/bin/remote-cli:/home/gitpod/.yarn/bin:/workspace/.cargo/bin:/workspace/.rvm/bin:/workspace/.pip-modules/bin:/home/gitpod/.pyenv/bin:/home/gitpod/.pyenv/shims:/workspace/go/bin:/home/gitpod/go/bin:/home/gitpod/go-packages/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin/:/home/gitpod/.nvm/versions/node/${NODE_V:-v16.13.0}/bin:/home/gitpod/.cargo/bin:/usr/games:/home/gitpod/.rvm/bin:/home/gitpod/.nvm/versions/node/${NODE_V:-v16.13.0}/bin";
	# DEFAULT_PATH="$(dedupe_path DEFAULT_PATH)"
	PATH=${PATH:-$DEFAULT_PATH};
	if which yarn > /dev/null 2>&1; then
		PATH="$(yarn global bin):$(yarn global dir)/node_modules/.bin:$PATH";
	fi
	if which pnpm > /dev/null 2>&1; then 
		PATH="$(pnpm -g bin 2>/dev/null):$PATH";
    fi
	if which dedupe_path > /dev/null 2>&1; then 
		dedupe_path PATH; 
	fi
	export PATH="$PATH";
}


#### EXPORTS ##################################################################

export TZ=${TZ:-'America/Los_Angeles'}

## Remove dupes from our $PATH var
dedupe_path PATH;
export PATH;

export GPG_TTY=$(tty);

## TODO: GPG auto-configuration
[ -n "${GPG_KEY-}" ] && [ $GPG_CONFIGURED != 1 ] && 
    __gpg_init ;

## TODO: SSH auto-configuration
[ -n "${SSH_KEY-}" ] && [ $SSH_CONFIGURED != 1 ] && 
    __ssh_init ;

## GitHub CLI Auto-Authentication
[ -n "${GITHUB_TOKEN-}" ] &&
    __gh_login ;

## TODO: Wrangler CLI Auto-Authentication

#### PROMPT_COMMAND - set __git_ps1 in pcmode to support color hinting
export PROMPT_COMMAND="__git_ps1 \"\${?} ${GIT_PS1_PREFIX-}\" \"${GIT_PS1_SUFFIX-}\" \"${GIT_PS1_FORMAT:- %s }\"";
