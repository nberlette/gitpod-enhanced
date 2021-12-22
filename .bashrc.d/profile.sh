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
alias commit='git commit -S'

# my two most common typos
alias gitignore='git ignore'
alias ignore='git ignore'
alias gitingore='git ignore'
alias ingore='git ignore'

#################################
#### PROFILE.SH 
#################################

export TZ='America/Los_Angeles'

export GIT_PS1_SHOWUPSTREAM='auto verbose name git' 
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_DESCRIBE_STYLE='tag'
export GIT_PS1_OMITSPARSESTATE=1
export GIT_PS1_STATESEPARATOR=''
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_PREFIX="\[\e]0;\u \W\e\]\[\e[1;7;33m\] gitpod \[\e[0m\]\[\e[7;36m\] …/\W \[\e[0m\e[1m\] "
export GIT_PS1_SUFFIX="\[\e[0m\e[1;32;6m\]\$\[\e[0m\] "
export GIT_PS1_FORMAT=" git:%s "

which __git_ps1 > /dev/null || source "$HOME/.bashrc.d/10-prompt";

export PROMPT_COMMAND="__git_ps1 \"$GIT_PS1_PREFIX\" \"$GIT_PS1_SUFFIX\" \"$GIT_PS1_FORMAT\"";

#### CONFIGURE  @antfu/ni  ####
if [ ! -f "$HOME/.nirc" ]; then 
    echo -e "defaultAgent=${defaultAgent:-pnpm}\nglobalAgent=${globalAgent:-yarn}\n" > "$HOME/.nirc";
fi

#### ADD YARN GLOBAL BIN TO PATH ####
set_var PATH "$(yarn global bin):$PATH"
dedupe_path PATH

#### SAFELY ADD GLOBAL PKGS WITH YARN
############################################
__yarn_global_add () {
  for pkg in "${@}"; do which "$pkg" > /dev/null || yarn global add "$pkg"; done
}
#__yarn_global_add pnpm @antfu/ni degit typescript ts-standard ts-node @types/node

