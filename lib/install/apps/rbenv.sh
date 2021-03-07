#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ SETUP RBENV
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
source "$curr_dir/../versions.sh"
source "$curr_dir/../os.sh"
# ============================================================================= #
#  ➜ ➜ ➜ TRAP
# ============================================================================= #
SET_BOO || SET_TRAP

rbenv_build() {
    if CMD apt; then
        apt-get-update-if-needed
    fi
    if EXEC rbenv; then
        MSGINFO "rbenv already install installed, want to reinstall?"
        if _confirm; then
            return
        else
            exit 0
        fi
    fi

    TITLE "Installing rbenv"
    if [ -d ~/.rbenv ]; then
        MSGINFO "Deleting previous installation"
        sudo rm -r ~/.rbenv
    fi

    MSGINFO "Cloning to ~/.rbenv"
    git clone https://github.com/Digital-Clouds/rbenv.git ~/.rbenv

    MSGINFO "Cloning ~/.rbenv/plugins/ruby-build"
    git clone https://github.com/Digital-Clouds/ruby-build.git ~/.rbenv/plugins/ruby-build

    [[ -d "$HOME/.rbenv" ]] && export PATH="$PATH:$HOME/.rbenv/bin"

    MSGINFO "Installing Ruby ${versionRuby}"
    rbenv install -v ${versionRuby} #Installing required version of Ruby
    rbenv global ${versionRuby}
    rbenv rehash

    MSGINFO "Runing gem install"
    gem install bundler rdoc rails mixlib-cli dapp

    MSGINFO "To verify that rbenv is properly set up, running rbenv doctor"
    sleep 2
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash
    exit 0
}
while true; do
    rbenv_build
done
