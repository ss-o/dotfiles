#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ RVM
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP

if ! NOCMD curl; then
    NOTIFY "CURL required to install composer."
    exit 1
fi

while true; do
    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    curl -sSL https://get.rvm.io | bash -s stable --rails
    exit 0
done
