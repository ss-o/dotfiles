#!/usr/bin/env bash
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP
if ! NOCMD curl; then
    NOTIFY "CURL required to install snap."
    exit 1
fi

TITLE "Installing snap"
if EXEC apt; then
    sudo apt install -y snapd
elif EXEC pacman; then
    sudo pacman -S snapd --noconfirm --needed
fi

while true; do
    MSGINFO "Enabling snapd & apparmor service" && echo
    sudo systemctl start snapd
    sudo systemctl enable snapd
    sudo systemctl start apparmor
    sudo systemctl enable apparmor

    MSGINFO "Reloading snap"
    sudo snap refresh
    MSGINFO "Installing snapcraft" && echo
    sudo snap install snapcraft --classic
    exit 0
done
