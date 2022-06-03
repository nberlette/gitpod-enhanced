#!/usr/bin/env bash

# function dotfiles_banner() {
#   local LINESIZE MAXWIDTH ENDCAP LINECHAR PADDING FILENAME FILEPATH COPYRIGHT

#   COPYRIGHT='MIT © Nicholas Berlette <nick@berlette.com>'
#   FILENAME="${1:-"${BASH_SOURCE[0]}"}"
#   FILENAME="$(basename "$(realpath -- "$FILENAME")")"
#   FILEPATH="$(basename "$(realpath -- "$FILENAME")")"

#   ENDCAP='##'  # each line of the banner starts and finishes with $ENDCAP
#   PADDING=' '  # pad each line with a space next to each $ENDCAP
#   LINECHAR='-' # character repeated to connect endcaps from left to right
#   LINESIZE=80  # 80 columns wides
#   MAXWIDTH=$((LINESIZE - ${#ENDCAP} - ${#PADDING}))

#   function hr() {
#     # printf '%s%'$MAXWIDTH's%s\n' "${ENDCAP:-"#"}${PADDING:- }" "${LINECHAR:-"-"}" "${PADDING:- }${ENDCAP:-"#"}"
#     printf '%s%s%s\n' "$(endcap)" $'\033[1;2;34m'"$(printf '%-'"$MAXWIDTH"'s' " " | sed 's/ /'$LINECHAR'/g')"$'\033[0m' "$(endcap 2)"
#   }

#   function endcap() {
#     local E P
#     if [ -n "$1" ]; then
#       printf '%s\033[1;34m%s\033[0m' "${PADDING:-" "}" "${ENDCAP:-"#"}"
#     else
#       printf '\033[1;34m%s\033[0m%s' "${ENDCAP:-"#"}" "${PADDING:-" "}"
#     fi
#   }

#   function between() {
#     local LEFTSTR RIGHTSTR SPACELEN LEFTLEN RIGHTLEN
#     LEFTSTR=${1-} # left-aligned string
#     LEFTLEN="$(echo -n "$LEFTSTR" | wc -c)"
#     RIGHTSTR=${2-} # right-aligned stringee
#     RIGHTLEN="$(echo -n "$RIGHTSTR" | wc -c)"
#     SPACELEN=$((MAXWIDTH - RIGHTLEN - 2))
#     printf '%s %-'$SPACELEN's%s %s\n' "$(endcap)" "$LEFTSTR" "$RIGHTSTR" "$(endcap 2)"
#   }

#   function center() {
#     local STR STRLEN SPACELEN
#     STR="${1-}"
#     STRLEN="${#STR}"
#     SPACELEN=$((MAXWIDTH - ${#STR}))
#     SPACELEN=$((SPACELEN / 2))
#     printf '%s%'$SPACELEN's%s%'$SPACELEN's%s\n' "$(endcap)" " " "$STR" " " "$(endcap 2)"
#   }

#   printf '%s\n' "$(
#     hr
#     between "$FILENAME" $(jq -r .version package.json)
#     hr
#   )"
#   printf '%s\n' "$(
#     center "https://github.com/nberlette/dotfiles/blob/main/$FILENAME"
#     hr
#   )"
#   printf '%s\n' "$(
#     between "$(date -R)" "$(date +%F)"
#     hr
#   )"
#   echo ""
# }

# dotfiles_banner
