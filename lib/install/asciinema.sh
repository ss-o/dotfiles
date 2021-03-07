#!/usr/bin/env bash
trap '' SIGINT SIGQUIT SIGTERM
# ============================================================================= #
# *** ➜ ➜ ➜ TEMPLATE FOR FUTURE INSTALLS
# ============================================================================= #
[ -z "$DOTFILES" ] && DOTFILES="$HOME/.dotfiles"
[ -z "$TERM" ] && TERM='xterm-256color'
# shellcheck source=/dev/null
. "$HOME/.dotfiles/lib/toolbox/utilities.sh"

if ! CMD python3; then
    MSG_ERR "Python3 is required. Exiting..."
    sleep 3
    exit 1
fi

INFORM_MSG()       { echo -e "Asciinema will be installed"; }
#PRE_INSTALL_MSG()  { echo -e ""; }
#INSTALL_MSG()      { echo -e ""; }
#POST_INSTALL()     { echo -e ""; }
#SUCCESS_MSG()      { echo -e ""; }

PRE_INSTALL() {
# Agree/confirm installation.
INFORM_MSG
if CONTINUE; then
INSTALL
else
exit 0
fi
}
INSTALL() {
# Execution  
git clone https://github.com/asciinema/asciinema.git
cd asciinema
python3 -m asciinema --version || ERROR
rm -rf asciinema 
SUCCESS
}

POST_INSTALL() {
# Complete installation or (if requires) display installation details    
MSG_INFO "Asciinema documentation: https://asciinema.org/docs/usage"
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
