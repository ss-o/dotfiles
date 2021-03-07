#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ SETUP NVM
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
source "$curr_dir/../versions.sh"
SET_BOO || SET_TRAP

build_nvm() {
    TITLE "Installing NVM"

    [[ -d "$HOME/.nvm" ]] && sudo rm -r "$HOME/.nvm"
    MAKEMISSDIR "$HOME/.nvm"

    MSGINFO "Cloning NVM"
    NVM_DIR="$HOME/.nvm"
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    cd "$NVM_DIR"
    git checkout v${versionNvm}
    . "$NVM_DIR/nvm.sh"
    cd - >/dev/null 2>&1

    MSGINFO "Setting current owner as owner of ~/.nvm"
    chown ${USER:=$(/usr/bin/id -run)}:$USER -R ~/.nvm

    MSGINFO "Setting up NVM"
    nvm install v${versionNode}
    nvm use v${versionNode}
    nvm alias default v${versionNode}

    MSGINFO "Installing Npm"
    nvm install-latest-npm

    MSGINFO "Installing Npm tools"
    npm install -g typescript
    npm install -g markdown-it
    npm install -g npm
    npm install -g tldr
    npm install -g nb.sh

    MSGINFO "Setting python binding"
    npm config set python $(which python)

    sudo "$(which nb)" completions install

    MSGINFO "Installing Yarn"
    npm install -g gulp yarn --unsafe-perm

    MSGINFO "Installing Yarn tools"
    yarn global add heroku
    yarn global add jshint
    yarn global add prettier
    yarn global add typescript-language-server
    yarn global add bash-language-server
    yarn global add webpack
    exit 0
}
while true; do
    build_nvm
done
