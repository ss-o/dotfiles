#!/usr/bin/env bash
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP

while true; do
    TITLE "Installing Circle-ci"
    curl -fLSs https://circle.ci/cli | sudo bash
    circleci update install
    exit 0
done
