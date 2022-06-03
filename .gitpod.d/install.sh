#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# ask for password right away
sudo -v

# shellcheck disable=SC2120
function curdir()
{
  dirname -- "$(realpath -Lmq "${1:-"${BASH_SOURCE[0]}"}" 2> /dev/null)"
}

# function is_interactive()
# {
#   [ -n "${NONINTERACTIVE:+x}" ] && return 1;
#   # if we're in CI/CD, return code 1 immediately
#   [ -n "$CI" ] && return 1;
#   # no? okay, lets check for tty based on stdin, stdout, stderr
#   [ -t 0 ] && [ -t 1 ] && [ -t 2 ] && return 0
#   # no? then we will check shellargs for -i as a last resort
#   case $- in (*i*) return 0 ;; esac
#   # ..... no?! you're still here? throw an error >_>
#   return 2
# }

# does what it says
function homebrew_determine_prefix()
{
  # are we running macOS?
  if [[ "$(uname -s)" == *[Dd]arwin* ]]; then
    # check for arm64 (apple silicon) install location (/opt/homebrew)
    if [ -d "/opt/homebrew/bin" ]; then
      export HOMEBREW_PREFIX="/opt/homebrew/bin"
    # no? fallback to /usr/local/bin
    else
      export HOMEBREW_PREFIX="/usr/local/bin"
    fi
  # no... then how about Linux?
  elif [[ "$(uname -s)" == [Ll]inux ]]; then
    # check for linuxbrew folder existence
    if [ -e "/home/linuxbrew/.linuxbrew/bin" ]; then
      # set the homebrew prefix variable
      export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew/bin"
    # fallback to /usr/local/bin
    else
      export HOMEBREW_PREFIX="/usr/local/bin"
    fi
  fi
}

# configure homebrew prefix and PATH
function homebrew_postinstall()
{
  # proceed only if HOMEBREW_PREFIX is set and the executable file exists
  if [ -n "${HOMEBREW_PREFIX-}" ] && [ -x "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/brew}" ]; then
    # ensure the homebrew location is in our $PATH
    if ! echo -n "$PATH" | grep -q "$HOMEBREW_PREFIX"; then
      export PATH="$HOMEBREW_PREFIX:$PATH"
    fi
    printf '\n\033[1;92m ✓ OKAY \033[0;1;2;92m %s \033[0m\n\n' "Homebrew installed at ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/brew}"
    echo -e '\neval "$(${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/brew} shellenv)"' >> .bashrc
    eval "$(${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/brew} shellenv)"
  else
    printf '\n\033[1;91m ⚠︎ ERROR \033[0;1;2;91m %s \033[0m\n\n' "Homebrew installation failed!"
    exit 1
  fi
}

# install homebrew (if needed)
function homebrew_install()
{
  local INSTALLER_LOCATION="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
	if command -v curl &>/dev/null; then
		curl -fsSL "$INSTALLER_LOCATION" | bash - 2>&1
	elif command -v wget &>/dev/null; then
		wget -qO- "$INSTALLER_LOCATION" | bash - 2>&1
	else
		echo "curl or wget required to install homebrew"
		return 1
	fi
	homebrew_determine_prefix 2>&1 && homebrew_postinstall 2>&1
}


# install some commonly-used global packages. the bare minimum.
function setup_brew()
{
	local HOMEBREW_BUNDLE_FILE
  homebrew_determine_prefix 2>&1
  # install homebrew if not already installed
  command -v brew &>/dev/null || homebrew_install 2>&1

	# set our brewfile location
	export HOMEBREW_BUNDLE_FILE="$(curdir)/.Brewfile"

	if [ -f "$HOMEBREW_BUNDLE_FILE" ] && [ -r "$HOMEBREW_BUNDLE_FILE" ]; then
		# make sure its executable...
		[ -x "$HOMEBREW_BUNDLE_FILE" ] || chmod +x "$HOMEBREW_BUNDLE_FILE" 2> /dev/null
		# and then execute it
		brew bundle install 2>&1
	fi
}

# setup our new homedir with symlinks to all the dotfiles
function main()
{
	local rsyncfiles rsyncexclude rsyncinclude git_file
	local -a rsyncargs=("-avh" "--recursive" "--perms" "--times" "--checksum" "--human-readable" "--progress")

	# set the default locations for .rsyncfiles and .rsyncexclude files
	rsyncfiles=".rsyncfiles"
	rsyncexclude=".rsyncexclude"
	rsyncinclude=".rsyncinclude"

	# exclude files matching glob patterns in the file .rsyncexclude
	[ -n "${rsyncexclude-}" ] && [ -r "${rsyncexclude-}" ] \
		&& rsyncargs+=(--exclude-from="${rsyncexclude-}")

	# include files with glob patterns in the file .rsyncinclude
	[ -n "${rsyncinclude-}" ] && [ -r "${rsyncinclude-}" ] \
		&& rsyncargs+=(--include-from="${rsyncinclude-}")

	# explicitly list files to copy in .rsyncfiles
	[ -n "${rsyncfiles-}" ] && [ -r "${rsyncfiles-}" ] \
		&& rsyncargs+=(--files-from="${rsyncfiles-}")

	# now do the damn thang!
	rsync "${rsyncargs[@]}" "$(curdir)" "$HOME"

	return 0
}

main "$@" ||  exit $?
