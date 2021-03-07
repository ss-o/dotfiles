#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ PIP INSTALL SUPPORT
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP

check_pip_state() {
    success=0

    check_pip=$(which pip)
    check_pip2=$(which pip2)
    check_pip3=$(which pip3)

    if [ "$check_pip" ]; then
        pip install buster
        success=$(expr $success + 1)
    else
        MSGINFO "Command 'pip' was not found on path..."
    fi

    if [ "$check_pip2" ]; then
        pip2 install buster
        success=$(expr $success + 1)
    else
        MSGINFO "Command 'pip2' was not found on path..."
    fi

    if [ "$check_pip3" ]; then
        pip3 install buster
        success=$(expr $success + 1)
    else
        MSGINFO "Command 'pip3' was not found on path..."
    fi

    # Checking if pip was found and 'buster' was successfully installed.
    if [ "$success" -eq "0" ]; then
        MSGINFO "Command pip cannot be found on your system."
        MSGINFO "Trying to install pip for Python"
        # Trying to install pip for different OSs (MacOS and Linux)
        if [ "$(uname)" == "Darwin" ]; then
            MSGINFO 'Mac OS detected.'
            sudo easy_install pip
            sudo pip install --upgrade virtualenv
            sudo pip install buster
        elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
            MSGINFO 'Linux detected.'
            if CMD apt; then
                sudo apt-get install python-setuptools python-dev build-essential
                sudo easy_install pip
                sudo pip install --upgrade virtualenv
                sudo pip install buster
            fi
            if CMD pacman; then
                sudo pacman -Sy python-setuptools python python-pip --noconfirm --needed
                sudo pip install --upgrade virtualenv
                sudo pip install buster
            fi
        else
            MSGINFO 'Operating System not supported yet.'
            exit 1
        fi
    fi
    MSGINFO 'Done! Dependencies appears to be okay.'
    exit 0
}
while true; do
    check_pip_state
done
