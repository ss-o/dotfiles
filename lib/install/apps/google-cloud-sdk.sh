#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ SETUP GOOGLE-CLOUD-SDK
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP

while true; do
    TITLE "Installing Google Cloud SDK"
    curl https://sdk.cloud.google.com | bash
    test -L ${HOME}/.config/gcloud || rm -rf ${HOME}/.config/gcloud
    exit 0
done
