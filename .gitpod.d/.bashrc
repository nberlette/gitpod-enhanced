#!/usr/bin/env bash
# -*- coding: utf-8 -*-

## ------------------------------------------------------------------------ ##
## .bashrc                                    Nicholas Berlette, 2022-06-01 ##
## ------------------------------------------------------------------------ ##
##         https://github.com/nberlette/dotfiles/blob/main/.bashrc          ##
## ------------------------------------------------------------------------ ##
##              MIT © Nicholas Berlette <nick@berlette.com>                 ##
## ------------------------------------------------------------------------ ##

shell="$(command -v bash)"
export SHELL="$shell"

# if [ -z "${DOTFILES_INITIALIZED:+x}" ]; then
# source the .path file to make sure all programs and functions are accessible
# this also sources our core.sh file. and if it cant be found, it fails. HARD.
if [ -r ~/.path ]; then
  # shellcheck source=/dev/null
  { source ~/.path 2>/dev/null || source "${DOTFILES_PREFIX:-"$HOME/.dotfiles"}/.path" 2>/dev/null; } || exit $?;
fi

# include all files in .bashrc.d folder
src ~/.bashrc.d/*
# import all vars from .env + .extra into current environment
srx ~/.{env,extra} "${PWD-}"/.{env,env.d}
# include our core bash environment
src ~/.{exports,functions,bash_aliases}
# ruby version manager, cargo (rust), nix
src ~/.rvm/scripts/rvm ~/.cargo/env ~/.nix-profile/etc/profile.d/nix.sh
# bash completion
src "$HOMEBREW_PREFIX/etc/bash_completion.d" 2>/dev/null
# lesspipe
which lesspipe &>/dev/null && eval "$(SHELL="$shell" lesspipe)"
# dircolors: attractive color coded output for ls, grep, etc.
if which dircolors &>/dev/null; then
  [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors 2>/dev/null)" || eval "$(dircolors -b)"
fi
# export PATH="${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/bin:"}$PATH"
# clean up $PATH
if hash dedupe_path &>/dev/null; then export PATH="$(dedupe_path)"; fi

# make sure our gitconfig is up to date
# user.name, user.email, user.signingkey
if [ -z "$(git config --global user.name)" ] || [ -z "$(git config --global user.email)" ]; then
  if [ -n "$GIT_COMMITTER_NAME" ] || [ -n "$GIT_AUTHOR_NAME" ]; then
    git config --global user.name "${GIT_COMMITTER_NAME:-"$GIT_AUTHOR_NAME"}"
  fi
  if [ -n "$GIT_COMMITTER_EMAIL" ] || [ -n "$GIT_AUTHOR_EMAIL" ]; then
    git config --global user.email "${GIT_COMMITTER_EMAIL:-"$GIT_AUTHOR_EMAIL"}"
  fi
  if [ -z "$(git config --global user.signingkey)" ]; then
    git config --global user.signingkey "${GPG_KEY_ID:-"$GIT_COMMITTER_EMAIL"}"
  fi
fi

eval "$(starship init bash)"

# define our variable to indicate this file has already been executed
# export DOTFILES_INITIALIZED=1
# fi
