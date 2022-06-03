#!/usr/bin/env bash
# -*- coding: utf-8 -*-

## ------------------------------------------------------------------------ ##
##  .bashrc.d/core.sh                        Nicholas Berlette, 2022-06-02  ##
## ------------------------------------------------------------------------ ##
##    https://github.com/nberlette/dotfiles/blob/main/.bashrc.d/core.sh     ##
## ------------------------------------------------------------------------ ##
##              MIT © Nicholas Berlette <nick@berlette.com>                 ##
## ------------------------------------------------------------------------ ##

# set -o nounset           # make using undefined variables throw an error
# set -o errexit           # exit immediately if any command returns non-0
# set -o pipefail          # exit from pipe if any command within fails
set -o errtrace          # subshells should inherit error handlers/traps
shopt -s dotglob         # make * globs also match .hidden files
shopt -s inherit_errexit # make subshells inherit errexit behavior

# check for ostype
if ! hash ostype &> /dev/null; then
	function ostype()
	{
		uname -s | tr '[:upper:]' '[:lower:]' 2> /dev/null
	}
fi

# src - source multiple files or entire folders recursively, with sanity checks.
function src()
{
	local __file child
	for __file in "$@"; do
		__file="$(realpath -Lmq "$__file" 2> /dev/null || echo -n "$__file")"
		if [ -r "$__file" ] && [ -f "$__file" ]; then
			# shellcheck source=/dev/null
			source "$__file"
		elif [ -d "$__file" ]; then
			for child in "$__file"/**; do src "$child"; done
		fi
	done
}

# srx: executes src function for all arguments, with the -a flag enabled.
# basically a recursive version of dotenv. enables sourcing a whole folder,
# and exporting all its files' variables into the global environment.
# use with caution.
function srx()
{
	local __file
	for __file in "$@"; do
		__file="$(realpath -Lmq "$__file" 2> /dev/null || echo -n "$__file")"
		if [ -r "$__file" ]; then
			set -a
			src "$__file"
			set +a
		fi
	done
}

# dedupe_array_str: remove duplicate entries from a list string (or array string)
# this is the logic used to cleanup the PATH variable of all duplicates while
# maintaining original insertion order ;)
# Usage:
#   $ dedupe_array_str ["$DELIMITER"] "$VARIABLE"
# Example used for $PATH:
#   $ dedupe_array_str ":" "PATH" # : is for splitting string into an array
function dedupe_array_str()
{
	local OLD NEW _IFS="$IFS" SEP=":"
	if [ -n "$1" ] && [ ${#1} -eq 1 ]; then
		SEP="${1:-":"}"
		shift
	fi
	IFS="$SEP"
	OLD="${*}"
	IFS="$_IFS"
	NEW="$(perl -e 'print join("'"${SEP-}"'",grep { not $seen{$_}++ } split(/'"${SEP-}"'/, $ARGV[0]))' "$OLD")"
	# now cleanup any lingering delimiters
	NEW="${NEW#"$SEP"}"     # remove leading separators
	echo -n "${NEW%"$SEP"}" # remove trailing separators, and print the result
}

########
## functions used in .path to amend the $PATH variable
########
function get_var()
{
	eval 'printf "%s\n" "${'"$1"'}"'
}

function set_var()
{
	eval "$1=\"\$2\""
}

function dedupe_path()
{
	local pathvar_value deduped_path print_val set_val
	# print by default for backwards compatibility
	print_val=1

	while (($# > 0)); do
		if [[ $1 =~ ^([-]{1,2}p(rint)?)$ ]]; then
			print_val=1
			shift
			continue
		fi
		# how bout that for nested groups bruh
		if [[ $1 =~ ^([-]{1,2}s(et([-]?val(ue)?)?)?)$ ]]; then
			set_val=1
			shift
			continue
		fi
	done
	pathvar_value="${1:-$PATH}"
	# deduped_path="$(perl -e 'print join(":",grep { not $seen{$_}++ } split(/:/, $ARGV[0]))' "$pathvar_value")"
	deduped_path="$(dedupe_array_str ":" "${pathvar_value-}")"

	[ -n "$set_val" ] \
		&& set_var "$pathvar_name" "$deduped_path"

	[ -n "$print_val" ] \
		&& echo -n "$deduped_path"
}

# check for global_add
if ! hash global_add &> /dev/null; then
	# installs all arguments as global packages
	function global_add()
	{
		local pkg pkgs=("$@") agent=npm command="i -g"
		if command -v yarn &> /dev/null; then
			agent="$(command -v yarn)"
			command="global add"
		else
			agent="$(command -v pnpm 2> /dev/null || command -v npm 2> /dev/null)"
			command="i -g"
		fi
		$agent "$command" "${pkgs[@]}" &> /dev/null && {
			echo "Installed with $agent:"
			for pkg in "${pkgs[@]}"; do
				echo -e "\\033[1;32m ✓ $pkg \\033[0m"
				# || echo -e "\\033[1;48;2;230;30;30m 𐄂 ${pkg-}\\033[0m";
			done
		}
	}
fi
