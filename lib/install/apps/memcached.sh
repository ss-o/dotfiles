#!/usr/bin/env bash
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP
TITLE "Installing Memcached"
if EXEC apt; then
    sudo apt install -y memcached
elif EXEC pacman; then
    sudo pacman -S memcached --noconfirm --needed
fi
while true; do
    MSGINFO "Enabling memcached"
    sudo systemctl start memcached
    sudo systemctl enable memcached
    exit 0
done
