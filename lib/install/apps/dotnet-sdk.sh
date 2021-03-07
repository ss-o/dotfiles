#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ SETUP DOTNET
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP
if ! NOCMD wget; then
    NOTIFY "WGET required to install DOTNET"
    exit 1
fi

while true; do
    TITLE "Installing dotnet SDK"

    wget https://dotnet.microsoft.com/download/dotnet-core/scripts/v1/dotnet-install.sh
    bash dotnet-install.sh
    rm dotnet-install.sh

    MSGINFO "Reload SHELL to complete installation"

    exit 0
done
