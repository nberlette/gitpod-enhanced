#!/usr/bin/env bash

## ------------------------------------------------------------------------ ##
##  .bash_aliases                            Nicholas Berlette, 2022-05-11  ##
## ------------------------------------------------------------------------ ##
##  https://github.com/nberlette/dotfiles/blob/main/.bash_aliases           ##
## ------------------------------------------------------------------------ ##

# make sure our .bin dir is in the PATH
if ! type -p osc &>/dev/null; then
  export PATH="$HOME/.bin:${DOTFILES_PREFIX:-"$HOME/.dotfiles/.bin"}:$PATH"
fi

alias bold="osc 01"
alias undl="osc 04"
alias ital="osc 03"
alias dark="osc 02"
alias flsh="osc 05"
alias inv="osc 07"
alias reset="osc 00"
alias blk="osc 38 02 00 00 00"
alias red="osc 01 31"
alias grn="osc 01 32"
alias ylw="osc 01 33"
alias orn="osc 01 38 02 255 143 51"
alias blu="osc 01 34"
alias mag="osc 01 35"
alias cyn="osc 01 36"
alias wht="osc 38 02 255 255 255"
alias gry="osc 37"
alias blk_b="osc 48 02 00 00 00"
alias red_b="osc 01 41"
alias grn_b="osc 01 42"
alias ylw_b="osc 01 43"
alias orn_b="osc 01 48 02 255 143 51"
alias blu_b="osc 01 44"
alias mag_b="osc 01 45"
alias cyn_b="osc 01 46"
alias wht_b="osc 48 02 255 255 255"

case "$(uname -s)" in
Darwin)
  # Mac specific aliases
  colorflag="-G --color=always"
  export COLORTERM=1
  export CLICOLOR_FORCE=$COLORTERM
  export FORCE_COLOR=1
  alias rebash="source \$HOME/.bash_profile"

  # visual studio code
  VSCODE_INSIDERS="/Applications/Visual Studio Code - Insiders.app"
  VSCODE_RELEASE="/Applications/Visual Studio Code.app"
  # shellcheck disable=SC2139
  {
    if [ -e "$VSCODE_INSIDERS" ]; then
      alias code="open -a \"$VSCODE_INSIDERS\""
    elif [ -e "$VSCODE_RELEASE" ]; then
      alias code="open -a \"$VSCODE_RELEASE\""
    fi
  }

  # finder.app
  alias finder="open -a '/System/Library/CoreServices/Finder.app'"

  # google chrome
  if ! which chrome &>/dev/null && [ -e "/Applications/Google Chrome.app" ]; then
    alias chrome="open -a '/Applications/Google Chrome.app'"

    # Kill all the tabs in Chrome to free up memory
    # [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
    alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"
  fi

  # iTerm2 (iTerm.app)
  if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
    if type -t it2setcolor &>/dev/null; then
      # change to 'Dark Background' preset theme
      alias godark="it2setcolor preset 'Dark Background'"
      alias darkmode="godark"

      # change to 'Light Background' preset theme
      alias golight="it2setcolor preset 'Light Background'"
      alias lightmode="golight"

      # change to [ theme name ] preset theme
      alias itheme="it2setcolor preset"
      alias themeit="it2setcolor preset"
      alias it2="it2setcolor preset"

      # change current tab's background color
      alias itab="it2setcolor tab"
      alias tabit="it2setcolor tab"
      alias tabcolor="it2setcolor tab"
    fi
    # for macbook pro touchbar models
    if type -t it2setkeylabel &>/dev/null; then
      alias itouch="it2setkeylabel"
      alias touchbar="it2setkeylabel"
      alias touchpush="it2setkeylabel push"
      alias touchpop="it2setkeylabel pop"
      alias touchset="it2setkeylabel set"
      alias statuskey="it2setkeylabel set status"
    fi
  fi
  ;;
Linux)
  colorflag="--color=always"
  export COLORTERM=1
  export CLICOLOR_FORCE=$COLORTERM
  export FORCE_COLOR=1
  if ! type -t xclip &>/dev/null; then
    brew install xclip &>/dev/null
  fi
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
  alias open="xdg-open"
  alias rebash="source \$HOME/.bashrc"
  ;;
esac

# @deprecated
# protip for aliasing all gnupg methods to their proper place
# for __ga in convert-keyring dirmngr dirmngr-client gpg gpg2 gpg-agent gpg-connect-agent gpg-error gpg-zip gpgconf gpgsm gpgsplit gpgtar gpgv kbxutil mpicalc watchgnupg starship gh fontforge; do
#     if [ -x "/usr/local/bin/${__ga-}" ]; then
#         # shellcheck disable=SC2139
#         alias "${__ga-}"="/usr/local/bin/${__ga-}"
#     else
#         if [ -x "/usr/bin/${__ga}" ]; then
#             sudo ln -sfn /usr/bin/"${__ga}" /usr/local/bin
#         elif [ -x "/home/linuxbrew/.linuxbrew/bin/${__ga}" ]; then
#             sudo ln -sfn /home/linuxbrew/.linuxbrew/bin/"${__ga}" /usr/local/bin
#         elif [ -x "/opt/homebrew/bin/${__ga-}" ]; then
#             sudo ln -sfn /opt/homebrew/bin/"${__ga-}" /usr/local/bin
#         fi
#     fi
# done
# unset -v __ga

# Date formatting string for ls command (macOS)
# dateflag="-D \$'  \e[2;3;4mM:\e[m%F\e[2mT\e[m%H\e[5m:\e[m%M\e[5m:\e[m%S\e[2m-%Z\e[m  '"
# datetimesep=$'\e[2;3m at \e[m'
# dateflag="-D \$' \\e[0;2;3mM:\\e[m \\e[2m%D\\e[m${datetimesep:- }\\e[2m%H\\e[5m:\\e[0;2m%M\\e[m '"

# adapted from https://github.com/nicowilliams/env/blob/master/.kshaliases#L2-L16
alias realias=". \$HOME/.bash_aliases"
alias valias="\${EDITOR:-vi} \$HOME/.bash_aliases"
alias rebash=". \$HOME/.bashrc"

alias vi="vim -X"
alias vim="vim -X"
alias gitb="git branch -a"
alias gitbl="git branch"
alias gitba="git branch -a"
alias gitd="git diff"
alias gitds="git diff --staged"
alias gitf="git format-patch main.."
alias gitfs="git format-patch --stdout main.."
alias gitdm="git diff main.."
alias gits="git status -uno"

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Shortcuts
alias dl="cd ~/Downloads"
alias g="git"
alias h="history"
alias gc='. $(type -t gitdate) && git commit -v '

# Always use color output for `ls`
if type -t gls &>/dev/null; then
  # shellcheck disable=SC2139
  alias ls="command gls ${colorflag-}"
else
  alias ls="command ls ${colorflag-}"
fi
# List all files colorized in long format
# shellcheck disable=SC2139

alias ll="ls -FAHlosh ${colorflag-}"

# List all files colorized in long format, including dot files
# shellcheck disable=SC2139
alias la="ls -loFAhHk -sa ${colorflag-}"

# List only directories
# shellcheck disable=SC2139
alias lsd="ls -lhF ${colorflag} | grep --color=always '^d'"

# Always enable colored `grep` output
alias grep='grep --color=auto '

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Get week number
alias week='date +%V'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# IP addresses
alias pubip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias ips="sudo ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\\: .*|GET \\/.*\""

# Canonical hex dump; some systems have this symlinked
type -p hexdump &>/dev/null &&
  command -v hd >/dev/null || alias hd="hexdump -C"

# OS X has no `md5sum`, so use `md5` as a fallback
type -p md5 &>/dev/null &&
  command -v md5sum >/dev/null || alias md5sum="md5"

# OS X has no `sha1sum`, so use `shasum` as a fallback
type -p shasum &>/dev/null &&
  command -v sha1sum >/dev/null || alias sha1sum="shasum"

# Trim new lines and copy to clipboard
alias trc="tr -d '\\n' | pbcopy"

# URL-encode strings
if type -p python &>/dev/null; then
  alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'
fi

# intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

if type -t lwp-request &>/dev/null; then
  # One of @janmoesen’s ProTip™s
  for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    # shellcheck disable=SC2139,SC2140
    alias "$method"="lwp-request -m \"$method\""
  done
fi

if type -t i3lock &>/dev/null; then
  # Lock the screen (when going AFK)
  alias afk="i3lock -c 000000"
fi

# vhosts
alias hosts='sudo nvim /etc/hosts'

# copy working directory
alias cwd='pwd | tr -d "\r\n" | pbcopy' # xclip -selection clipboard

# copy file interactive + verbose
alias cp='cp -i -v'

# move file interactive + verbose
alias mv='mv -i -v'

# untar
alias untar='tar xvf'

# shorthand methods for reporting success/warning/failure messages to the user
alias success='status success'
alias failure='status failure'
alias warning='status warning'

# Brew
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'

alias c='clear'
# shellcheck disable=SC2139
{
  # clear and list files at once
  alias cls="clear && ls ${colorflag-}"
  alias cll="clear && ls -loAFHhL ${colorflag-}"
  alias cla="clear && ls -loAFHhL ${colorflag-}"
  alias cl="clear && ls -loAF ${colorflag-}"
}
# verbose aliases
alias rm='rm -v -i'
alias rmr='rm -r'
alias rmrf='rm -rf'
alias rimraf='rm -rf'
alias cpr='cp -R'
alias mkdir='mkdir -p'
alias ln='ln -v'

# dirs and files
alias "cd.."="cd .."
alias t='touch'

# git
alias gitignore='git ignore'
alias ignore='git ignore'
alias gitingore='git ignore'
alias ingore='git ignore'

# ruby hack
alias gem='sudo gem'

# terrible names
alias pig='pnpm i -g'
alias nig='npm i -g'
alias yag='yarn global add'

# shellcheck source=/dev/null
alias pip2="$(type -t pip)"
alias pip='pip3'
alias python='python3'
alias venv="source '\$HOME/.venv/bin/activate'"

# YARN PACKAGE MANAGER
if type -t yarn &>/dev/null; then
  alias yarn="yarn --ignore-optional --ignore-platform --ignore-engines -s"
  alias yag='yarn global add'
  alias yg='yarn global'
  alias yga='yg add --ignore-platform --ignore-optional'
  alias ygr='yg remove'
  alias ya='yarn add --ignore-platform --ignore-optional'
  alias yr='yarn remove'
  alias yorn='yarn --offline'
  alias yporn='yarn --prefer-offline' # ynot?
fi

# NODE.JS
if type -t node &>/dev/null; then
  # node flags / options / etc.
  NODE_FLAGS=${NODE_FLAGS:-"--experimental-import-meta-resolve --experimental-json-modules --experimental-repl-await --experimental-specifier-resolution=node --experimental-vm-modules --max-old-space-size=4096 "} # --no-warnings --no-warnings-experimental-mode
  alias esnode="node --trace-warnings \$NODE_FLAGS"
  alias nodetsm="node --loader tsm -r dotenv/config \$NODE_FLAGS"
fi

# CLOUDFLARE: flarectl CLI
if type -t flarectl &>/dev/null; then
  alias flare="flarectl"
  alias cf=flarectl
  alias railgun="flarectl railgun"
fi

# CLOUDFLARE: wrangler CLI
if type -t wrangler &>/dev/null; then
  alias wr="wrangler"
  alias pages="wrangler pages"
  alias r2="wrangler r2"
  alias kvns="wrangler kv:namespace"
  alias kv="wrangler kv:key"
  alias kvbulk="wrangler kv:bulk"
fi

if type -t nvim >/dev/null 2>&1; then
  alias vim="nvim"
  alias vi="nvim"
  alias v="nvim"
else
  alias vim="vim"
  alias vi="vim"
  alias v="vim"
fi

# aws aliases
if type -t aws &>/dev/null; then
  alias ls3='aws s3 ls --human-readable --summarize'
  alias rls3='aws s3 ls --recursive'

  # aws cli shorthand
  for aws_cmd in s3 iam amplify apigateway appconfig ddb docdb dynamodb devicefarm ec2 ecr ecs lambda memorydb rds route53 ses sms sns sqs; do
    # shellcheck disable=SC2139
    {
      alias "${aws_cmd-}"="aws ${aws_cmd-}"
      alias "${aws_cmd-}-h"="aws ${aws_cmd-}"
    }
  done
  unset -v aws_cmd
fi

if ! hash docker &>/dev/null; then
  alias dk='docker'
  alias dkit='docker -it'
  alias dkr='docker run -it'
  alias dkc='docker compose'
  alias dkb='docker build -it'
  alias dkp='docker push'
  alias dkpull='docker pull'
fi

# GitHub CLI commands and shorthands
if type gh &>/dev/null; then
  alias mkgist="gh gist create"
  alias rmgist="gh gist delete"
  alias gisted='gh gist edit'
  alias fork='gh repo fork'
  alias clone='gh repo clone'
  alias repo='gh repo'
  alias reponew='gh repo create'
  alias newrepo='gh repo create'
  alias mkrepo='gh repo create'
fi
