#!/usr/bin/env bash
trap '' SIGINT SIGQUIT SIGTERM
# ============================================================================= #
# *** ➜ ➜ ➜ TEMPLATE FOR FUTURE INSTALLS
# ============================================================================= #
[ -z "$DOTFILES" ] && DOTFILES="$HOME/.dotfiles"
[ -z "$TERM" ] && TERM='xterm-256color'
# shellcheck source=/dev/null
. "$HOME/.dotfiles/lib/toolbox/utilities.sh"

#INFORM_MSG()       { echo -e ""; }
#PRE_INSTALL_MSG()  { echo -e ""; }
#INSTALL_MSG()      { echo -e ""; }
#POST_INSTALL()     { echo -e ""; }
#SUCCESS_MSG()      { echo -e ""; }

PRE_INSTALL() {
# Agree/confirm installation.
if CONTINUE; then

else

fi
}
INSTALL() {
# Execution    
}

POST_INSTALL() {
# Complete installation or (if requires) display installation details    
}

MAIN() {
    SET_BOO
    PRE_INSTALL
    INSTALL
    POST_INSTALL
}

while true; do
    MAIN "${@}" || ERROR "Failed to install"
    FINISHED
done



