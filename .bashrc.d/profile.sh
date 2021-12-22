#!/usr/bin/env bash
# shellcheck disable=SC2178
# shellcheck source=/dev/null

#################################
#### FUNCTIONS
#################################
get_var () {
    eval 'printf "%s\n" "${'"$1"'}"'
}
set_var () {
    eval "$1=\"\$2\""
}
dedupe_path () {
    local pathvar_name="${1:-PATH}"
    local pathvar_value="$(get_var "$pathvar_name")"
    local deduped_path="$(perl -e 'print join(":",grep { not $seen{$_}++ } split(/:/, $ARGV[0]))' "$pathvar_value")"
    set_var "$pathvar_name" "$deduped_path"
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
alias la='ls -st'
alias ll='ls -stFlog'

alias diff='diff --side-by-side --color=always'
alias dir='dir --color=auto'

alias grep='grep --color=always'
alias fgrep='grep -f --color=always'
alias egrep='grep -E --color=always'

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

# my two most common typos
alias gitignore='git ignore'
alias ignore='git ignore'
alias gitingore='git ignore'
alias ingore='git ignore'

#################################
#### PROFILE.SH - DEFAULTS
#################################

#### Localization
export TZ=${TZ:-'America/Los_Angeles'}

#### TODO: #1 write documentation on available options and how to customize
export GIT_PS1_SHOWCOLORHINTS=${GIT_PS1_SHOWCOLORHINTS:-1}
export GIT_PS1_SHOWDIRTYSTATE=${GIT_PS1_SHOWDIRTYSTATE:-1}
export GIT_PS1_SHOWSTASHSTATE=${GIT_PS1_SHOWSTASHSTATE:-1}
export GIT_PS1_SHOWUNTRACKEDFILES=${GIT_PS1_SHOWUNTRACKEDFILES:-1}
export GIT_PS1_SHOWUPSTREAM=${GIT_PS1_SHOWUPSTREAM:-'auto'}
export GIT_PS1_OMITSPARSESTATE=${GIT_PS1_OMITSPARSESTATE:-1}
export GIT_PS1_STATESEPARATOR=${GIT_PS1_STATESEPARATOR:-' '}
export GIT_PS1_DESCRIBE_STYLE=${GIT_PS1_DESCRIBE_STYLE:-tag}
export GIT_PS1_HIDE_IF_PWD_IGNORED=${GIT_PS1_HIDE_IF_PWD_IGNORED:-''}

export GIT_PS1_PREFIX=${GIT_PS1_PREFIX:-"\[\e]0;\u \W\e\]\[\e[1;7;33m\] \u \[\e[0;7;36m\] \w \[\e[0;1m\] "}
export GIT_PS1_SUFFIX=${GIT_PS1_SUFFIX:-"\[\e[0m\]\n\[\e[1;32;6m\]\$\[\e[0m\] "}
export GIT_PS1_FORMAT=${GIT_PS1_FORMAT:-" git:(%s) "}

#### ADD yarn global bin to PATH; deduplicate
PATH="$(yarn global bin):$PATH" && dedupe_path && export PATH;

#### SAFELY ADD GLOBAL PKGS WITH YARN
__global_add () {
  for pkg in "${@}"; do 
    if [ -e "$(yarn global dir)/node_modules/$pkg" ]; then
        yarn global add --prefer-offline --silent --no-progress "$pkg"
    fi
  done
}

#### GLOBAL: add degit + typescript support
__global_add degit typescript ts-standard ts-node @types/node

#### CONFIGURE  @antfu/ni 
[ ! -f "$HOME/.nirc" ] \
  && echo -e "defaultAgent=${defaultAgent:-pnpm}\nglobalAgent=${globalAgent:-yarn}\n" > "$HOME/.nirc";

__global_add pnpm @antfu/ni

#### PROMPT_COMMAND: ensure __git_ps1 exists -> export 
if ! which __git_ps1 > /dev/null; then
    [ -e /home/gitpod/.bashrc.d/*-prompt ] \
      && source /home/gitpod/.bashrc.d/*-prompt;
fi

export PROMPT_COMMAND="__git_ps1 \"$GIT_PS1_PREFIX\" \"$GIT_PS1_SUFFIX\" \"$GIT_PS1_FORMAT\"";