#!/usr/bin/env bash
if [ "$SHLVL" = 1 ]; then
  if which clear_console &>/dev/null
    then clear_console -q 2>/dev/null
  elif [ -x /usr/bin/clear_console ]
    then /usr/bin/clear_console -q 2>/dev/null
  fi # clear_console
fi

unset -v DOTFILES_INITIALIZED DOTFILES_CORE_INITIALIZED &>/dev/null
