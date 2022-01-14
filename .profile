# shellcheck shell=bash
# shellcheck disable=SC2178
# shellcheck source=/dev/null

#################################
#### FUNCTIONS
#################################

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

# shellcheck disable=SC2125
function __gpg_vscode () {
    local VSCODE SETTINGS_JSON
    # ensure a .vscode folder exists
    VSCODE="${THEIA_WORKSPACE_ROOT:-/workspace/*}/.vscode"
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
    if [ -n "$GITHUB_TOKEN" ]; then
        if which gh > /dev/null 2>&1; then
            # GitHub CLI doesn't allow us to authenticate if $GITHUB_TOKEN is also in use.
            __GH_TOKEN=${GITHUB_TOKEN-} && unset GITHUB_TOKEN;
            # shellcheck disable=SC2059
            echo -n "${__GH_TOKEN-}" | gh auth login --with-token > /dev/null 2>&1 || return 1;
            return 0;
        fi
    fi
}

#################################
#### ALIASES
#################################

alias c=clear
alias pip2=pip
alias pip=pip3
alias python=python3
alias ls='ls -HLAhk --color=always'
alias l='ls -st'
alias la='ls -stF'
alias ll='ls -stFlog'

alias diff='diff --side-by-side --color=always'
alias dir='dir --color=auto'

alias grep='grep --color=always'
alias fgrep='grep --color=always -f'
alias egrep='grep --color=always -E'

## Linux-specific date/time shorthands
alias _date_R="date +%R"
alias _date_D="date +%D"
alias _date_F="date +%F"
alias _time_iso="date -Iseconds"
alias _timestamp="date +%s"
alias _unix="date +%s"
alias _epoch="date +%s"

## clear and list files at once
alias cls='clear && ls'
alias cll='clear && ll'
alias cla='clear && la'
alias cl='clear && l'

alias mv='mv -v'
alias rm='rm -v -i'
alias mkdir='mkdir -p'
alias ..="cd .."
alias cd..='cd ..'
alias t='touch'

## common typos
alias gitignore='git ignore'
alias ignore='git ignore'
alias gitingore='git ignore'
alias ingore='git ignore'


#################################
#### PROFILE.SH - DEFAULTS
#################################

#### Localization
export TZ=${TZ:-'America/Los_Angeles'}

# TODO: #8 refactor method for checking/setting GIT_PS1_* defaults
export GIT_PS1_SHOWCOLORHINTS=${GIT_PS1_SHOWCOLORHINTS:-1}
export GIT_PS1_SHOWDIRTYSTATE=${GIT_PS1_SHOWDIRTYSTATE:-1}
export GIT_PS1_SHOWSTASHSTATE=${GIT_PS1_SHOWSTASHSTATE:-1}
export GIT_PS1_SHOWUNTRACKEDFILES=${GIT_PS1_SHOWUNTRACKEDFILES:-1}
export GIT_PS1_SHOWUPSTREAM=${GIT_PS1_SHOWUPSTREAM:-'auto'}
export GIT_PS1_OMITSPARSESTATE=${GIT_PS1_OMITSPARSESTATE:-1}
export GIT_PS1_STATESEPARATOR=${GIT_PS1_STATESEPARATOR:-' '}
export GIT_PS1_DESCRIBE_STYLE=${GIT_PS1_DESCRIBE_STYLE:-'tag'}
export GIT_PS1_HIDE_IF_PWD_IGNORED=${GIT_PS1_HIDE_IF_PWD_IGNORED:-''}

export GIT_PS1_PREFIX=${GIT_PS1_PREFIX:-"\[\e]0;\u \W\e\]\[\e[0m\e[7;36m\]\[\e[0;36;7m\] \W \[\e[0;36m\]\[\e[0;1m\]"}
export GIT_PS1_SUFFIX=${GIT_PS1_SUFFIX:-"\n\[\e[1;32;6m\]\$\[\e[0m\] "}
export GIT_PS1_FORMAT=${GIT_PS1_FORMAT:-" %s "}

dedupe_path PATH && export PATH;

## TODO: #5 fix gpg failure error on first start, temporary fix by calling __gpg_unlock
if [[ -n "${GPG_KEY-}" && "${GPG_CONFIGURED-}" != "1" ]]; then
    # shellcheck disable=SC2155    
    export GPG_TTY=$(tty);
    __gpg_init ;
fi

## TODO: experimental ssh configuration
if [[ -n "${SSH_KEY-}" && "${SSH_CONFIGURED-}" != "1" ]]; then
    __ssh_init ;
fi

if [[ -n "${GITHUB_TOKEN-}" ]]; then
    __gh_login ;
fi

#### PROMPT_COMMAND - set __git_ps1 in pcmode to support color hinting
export PROMPT_COMMAND="__git_ps1 \"${GIT_PS1_PREFIX-}\" \"${GIT_PS1_SUFFIX-}\" \"${GIT_PS1_FORMAT:- %s }\"";
