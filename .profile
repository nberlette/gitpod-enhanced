
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
    local pathvar_name="${1:-PATH}"
    local pathvar_value="$(get_var "$pathvar_name")"
    local deduped_path="$(perl -e 'print join(":",grep { not $seen{$_}++ } split(/:/, $ARGV[0]))' "$pathvar_value")"
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
    # ensure a .vscode folder exists
    local VSCODE=/workspace/*/.vscode
    if ! test -d $VSCODE; then mkdir -p $VSCODE; fi

    # ensure a valid settings.json file exists
    local SETTINGS_JSON=$VSCODE/settings.json
    if ! test -e $SETTINGS_JSON; then echo "{}" > $SETTINGS_JSON ; fi

    # use jq to edit .vscode/settings.json, enable pgp signing
    echo "$(jq '.git.enableCommitSigning="true" | .' $SETTINGS_JSON 2>/dev/null)" > $SETTINGS_JSON || return 1;
}

function __gpg_init () {
    unset GPG_CONFIGURED;
    # import our base64-encoded secret key/keys (dangerous)
    gpg --batch --import <(echo "${GPG_KEY-}" | base64 -d) &&
        echo 'pinentry-mode loopback' >> "$HOME/.gnupg/gpg.conf" ;
    # reload gpg-agent
    gpg-connect-agent reloadagent /bye > /dev/null 2>&1 ;
    # set gitconfig values for gpg signatures
    __gpg_gitconfig
    # change vscode settings for git commit signing
    __gpg_vscode

    export GPG_CONFIGURED=1
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

export GIT_PS1_SHOWCOLORHINTS=${GIT_PS1_SHOWCOLORHINTS:-1}
export GIT_PS1_SHOWDIRTYSTATE=${GIT_PS1_SHOWDIRTYSTATE:-1}
export GIT_PS1_SHOWSTASHSTATE=${GIT_PS1_SHOWSTASHSTATE:-1}
export GIT_PS1_SHOWUNTRACKEDFILES=${GIT_PS1_SHOWUNTRACKEDFILES:-1}
export GIT_PS1_SHOWUPSTREAM=${GIT_PS1_SHOWUPSTREAM:-'auto'}
export GIT_PS1_OMITSPARSESTATE=${GIT_PS1_OMITSPARSESTATE:-1}
export GIT_PS1_STATESEPARATOR=${GIT_PS1_STATESEPARATOR:-' '}
export GIT_PS1_DESCRIBE_STYLE=${GIT_PS1_DESCRIBE_STYLE:-'tag'}
export GIT_PS1_HIDE_IF_PWD_IGNORED=${GIT_PS1_HIDE_IF_PWD_IGNORED:-''}

export GIT_PS1_PREFIX=${GIT_PS1_PREFIX:-"\[\e]0;\u \W\e\]\[\e[1;7;33m\] \u \[\e[0;7;36m\] \w \[\e[0;1m\]"}
export GIT_PS1_SUFFIX=${GIT_PS1_SUFFIX:-"\n\[\e[1;32;6m\]\$\[\e[0m\] "}
export GIT_PS1_FORMAT=${GIT_PS1_FORMAT:-" %s "}

#### dedupe our path
dedupe_path PATH && export PATH;

## initialize our gpg configuration (experimental)
if [[ -n "${GPG_KEY-}" && "${GPG_CONFIGURED-}X" == "X" ]]; then
    export GPG_TTY=$(tty) ;
    __gpg_init ;
fi

#### PROMPT_COMMAND - set __git_ps1 in pcmode to support color hinting
export PROMPT_COMMAND="__git_ps1 \"$GIT_PS1_PREFIX\" \"$GIT_PS1_SUFFIX\" \"$GIT_PS1_FORMAT\"";
