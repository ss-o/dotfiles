#!/usr/bin/env bash
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP
while true; do
    echo "downloading Oh-my-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    exit 0
done
