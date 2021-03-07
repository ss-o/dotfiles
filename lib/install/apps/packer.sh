#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ PACKER
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP
while true; do
    mkdir -p $(go env GOPATH)/src/github.com/hashicorp
    git clone https://github.com/hashicorp/packer.git ~/.packer
    cd ~/.packer && make dev
    exit 0
done
