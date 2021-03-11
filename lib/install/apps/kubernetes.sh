#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ KUBERNETES
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP
while true; do
    TITLE "Installing Kubernetes"
    git clone https://github.com/kubernetes/kubernetes ~/.kubernetes
    cd ~/.kubernetes && make quick-release
    exit 0
done
