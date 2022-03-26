#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2178,SC2125,SC2059,SC2155,SC2086
# shellcheck source=/dev/null

###############################################################################
##                            ~ GITPOD-ENHANCED ~                            ##
####          Turbocharged Development Image for Gitpod Workspaces         ####
###############################################################################
### MIT (c) Nicholas Berlette - <https://git.io/gitpod> <https://gitpod.tk> ###
###############################################################################

#### ORIGINAL .BASH_PROFILE CONTENTS ##########################################
[ -s "$HOME/.profile" ] && source "$HOME/.profile"
# Load RVM into a shell session *as a function*
[ -s "$HOME/.rvm/scripts/rvm" ] && source "$HOME/.rvm/scripts/rvm"

#### FUNCTIONS ################################################################
function get_var() {
	eval 'printf "%s\n" "${'"$1"'}"'
}
function set_var() {
	eval "$1=\"\$2\""
}
function dedupe_path() {
	local pathvar_name pathvar_value deduped_path
	pathvar_name="${1:-PATH}"
	pathvar_value="$(get_var "$pathvar_name")"
	deduped_path="$(perl -e 'print join(":",grep { not $seen{$_}++ } split(/:/, $ARGV[0]))' "$pathvar_value")"
	set_var "$pathvar_name" "$deduped_path"
}
function get_json() {
	local path file
	file="${1:-"/workspace/.vscode-remote/settings.json"}"
	path="${2:-git.enableCommitSigning}"
	jq '.["'$path'"]' "$file" 2> /dev/null || return $?
}
function set_json() {
	local path value file
	file="${1:-"/workspace/.vscode-remote/settings.json"}"
	path="${2:-git.enableCommitSigning}"
	value="${3:-true}"

	# shellcheck disable=SC2005
	jq '.["'$path'"]=$value | .' "$file" 2> /dev/null || return $?
}
function __gpg_gitconfig() {
	[ -n "${GPG_KEY_ID-}" ] && git config --global user.signingkey "${GPG_KEY_ID-}"
	git config --global commit.gpgsign "true"
	git config --global tag.gpgsign "true"
}
function __gpg_vscode() {
	local VSCODE SETTINGS_JSON
	VSCODE="/workspace/.vscode-remote"
	[ -d "$VSCODE" ] || mkdir -p "$VSCODE"
	SETTINGS_JSON="$VSCODE/settings.json"
	[ -f "$SETTINGS_JSON" ] || echo "{}" > "$SETTINGS_JSON"
	if [[ "$(get_json "$SETTINGS_JSON" git.enableCommitSigning)" != 'true' ]]; then
		set_json "$SETTINGS_JSON" 'git.enableCommitSigning' 'true'
	fi
}

function __gpg_init() {
	local PINENTRY_CONF GPG_CONF
	PINENTRY_CONF='pinentry-mode loopback'
	GPG_CONF="$HOME/.gnupg/gpg.conf"

	unset -v GPG_CONFIGURED
	touch "$GPG_CONF"
	if ! grep -q "$PINENTRY_CONF" "$GPG_CONF" > /dev/null 2>&1; then
		echo "$PINENTRY_CONF" >> "$GPG_CONF"
	fi

	# import our base64-encoded secret key/keys (dangerous)
	gpg --batch --import <(echo "${GPG_KEY-}" | base64 -d) >&/dev/null

	# setup gitconfig and vscode settings for gpg signatures
	__gpg_gitconfig
	__gpg_vscode

	gpgconf --kill gpg-agent
	gpg-connect-agent reloadagent /bye >&/dev/null

	export GPG_CONFIGURED=1
}

# TODO: #6 implement SSH-key integration at runtime
function __ssh_init() {
	if [ -n "$SSH_KEY" ]; then
		return 0
	fi
	return 1
}

#### Authenticate GitHub CLI on start if a PAT ($GITHUB_TOKEN) exists in Gitpod
# TODO: #7 [feature] convert gh auth login to dotfiles (.config/gh)
function __gh_login() {
	local __GH_TOKEN
	if [ -n "$GITHUB_TOKEN" ] && which gh > /dev/null 2>&1; then
		# GitHub CLI doesn't authenticate if $GITHUB_TOKEN is in use.
		# so we copy to a local variable and unset the global one. (janky)
		__GH_TOKEN=${GITHUB_TOKEN-} && unset GITHUB_TOKEN
		# now we login with $__GH_TOKEN and error out on failure
		echo -n "${__GH_TOKEN-}" \
			| gh auth login --with-token 2> /dev/null && return 0
		# still here? stop script, bad login
		return 1
	fi
}

## xpm: cross-package-manager
## uses pnpm, if available, and falls back to npm if not.
function xpm() {
	# if we don't have pnpm, let's get it
	if ! which pnpm > /dev/null 2>&1; then
		if which curl > /dev/null 2>&1; then
			curl -fsSL https://get.pnpm.io/install.sh | bash - > /dev/null 2>&1
		else
			wget -qO- https://get.pnpm.io/install.sh | bash - > /dev/null 2>&1
		fi
		xpm "$@"
	fi
	pnpm "$@" || npm "$@"
}

function __vercel() {
	local GLOBAL_CFG LOCAL_CFG __VC_CFG __VC_FLAGS
	# global vercel config (directory)
	GLOBAL_CFG=/workspace/.vercel
	LOCAL_CFG="${THEIA_WORKSPACE_ROOT-}/vercel.json"
	__VC_CFG="${GLOBAL_CFG:+"${GLOBAL_CFG-}/project.json"}"
	__VC_FLAGS=""

	if [[ "${1-}" == "login" ]]; then
		__VC_FLAGS+=" --oob"
	fi

	[ -n "${VERCEL_FLAGS-}" ] && __VC_FLAGS+=" ${VERCEL_FLAGS-}"
	[ -n "${VERCEL_TOKEN-}" ] && __VC_FLAGS+=" --token=${VERCEL_TOKEN-}"

	if [ -n "${GLOBAL_CFG-}" ]; then
		# shellcheck disable=SC2174
		[ -d "${GLOBAL_CFG-}" ] || mkdir -p -m 0755 "${GLOBAL_CFG-}"
		__VC_FLAGS+=" --global-config=${GLOBAL_CFG-}"
	fi

	if [ -n "${LOCAL_CFG-}" ] && [ -f "${LOCAL_CFG-}" ]; then
		__VC_FLAGS+=" --local-config=${LOCAL_CFG-}"
	fi

	__VC_FLAGS="$(echo "${__VC_FLAGS-}" | sed -e 's/^ *//' -e 's/ *$//')"
	eval "$(which vercel) ${__VC_FLAGS-} ${*}" && return 0
	return 1
}

## Vercel CLI Auto-Authentication
alias vercel="__vercel"
alias vc="__vercel"

function __path() {
	local NODE_V=$(node -v 2> /dev/null | tr -d '[a-zA-Z \s]')
	local DEFAULT_PATH="/home/gitpod/.nix-profile/bin:/home/gitpod/.pyenv/plugins/pyenv-virtualenv/shims:/home/gitpod/.nix-profile/bin:/home/gitpod/.sdkman/candidates/maven/current/bin:/home/gitpod/.sdkman/candidates/java/current/bin:/home/gitpod/.sdkman/candidates/gradle/current/bin:/home/gitpod/.pyenv/plugins/pyenv-virtualenv/shims:/home/gitpod/.rvm/gems/default/bin:/home/gitpod/.rvm/rubies/default/bin:/ide/bin/remote-cli:/home/gitpod/.yarn/bin:/workspace/.cargo/bin:/workspace/.rvm/bin:/workspace/.pip-modules/bin:/home/gitpod/.pyenv/bin:/home/gitpod/.pyenv/shims:/workspace/go/bin:/home/gitpod/go/bin:/home/gitpod/go-packages/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin/:/home/gitpod/.nvm/versions/node/${NODE_V:-v16.13.0}/bin:/home/gitpod/.cargo/bin:/usr/games:/home/gitpod/.rvm/bin:/home/gitpod/.nvm/versions/node/${NODE_V:-v16.13.0}/bin"
	# DEFAULT_PATH="$(dedupe_path DEFAULT_PATH)"
	PATH=${PATH:-$DEFAULT_PATH}
	if which yarn >&/dev/null; then
		PATH="$(yarn global bin):$(yarn global dir)/node_modules/.bin:$PATH"
	fi
	if which pnpm >&/dev/null; then
		PATH="$(pnpm -g bin 2> /dev/null):$PATH"
	fi
	if which dedupe_path >&/dev/null; then
		dedupe_path PATH
	fi
	export PATH
}

#### EXPORTS ##################################################################

__path 2> /dev/null

export TZ=${TZ:-'America/Los_Angeles'}

export GPG_TTY=$(tty)

[ -n "${GPG_KEY-}" ] && __gpg_init

[ -n "${SSH_KEY-}" ] && __ssh_init

[ -n "${GITHUB_TOKEN-}" ] && __gh_login

#### PROMPT_COMMAND - set __git_ps1 in pcmode to support color hinting
PROMPT_COMMAND+=' __git_ps1 "[$?] '"${GIT_PS1_PREFIX-}"'" "'"${GIT_PS1_SUFFIX-}"'" "'"${GIT_PS1_FORMAT:- %s }"'"'
export PROMPT_COMMAND
