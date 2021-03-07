#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ SETUP PYENV
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
source "$curr_dir/../versions.sh"
SET_BOO || SET_TRAP

build_pyenv() {

    TITLE "Installing Pyenv"

    MSGINFO "Cloning to ~/.pyenv"
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv

    export PATH="$PATH:$HOME/.pyenv/bin"

    MSGINFO "Installing Python-${versionPython}"
    pyenv install "${versionPython}"
    pyenv global "${versionPython}"
    pyenv rehash

    if ! type -P python &>/dev/null; then
        set +e
        python2="$(type -P python2 2>/dev/null)"
        python3="$(type -P python3 2>/dev/null)"
        set -e
        if [ -n "$python3" ]; then
            MSGINFO "Python uses $python3"
        elif [ -n "$python2" ]; then
            MSGINFO "Python uses $python2"
        fi
    fi

    MSGINFO "Installing Tools using PIP"
    python="${PYTHON:-python}"
    python="$(type -P "$python")"
    $python -m pip install --upgrade pip setuptools wheel
    pip install autopep8
    pip install black
    pip install cheat
    pip install django
    pip install faker
    pip install flake8
    pip install httpie
    pip install importmagic
    pip install jupyter
    pip install litecli
    pip install matplotlib
    pip install pipenv
    pip install poetry
    pip install progressbar2
    pip install pydoc_utils
    pip install pyflakes
    pip install pylint
    pip install python-language-server
    pip install pygments
    pip install virtualenv
    pip install virtualenvwrapper
    pip install yapf
    pip install thefuck
    #    pip list --user | cut -d" " -f 1 | tail -n +3 | xargs pip install -U --user

    MSGINFO "Installing Pyenv doctor"
    git clone https://github.com/pyenv/pyenv-doctor.git "$(pyenv root)/plugins/pyenv-doctor"
    pyenv doctor
    exit 0
}
while true; do
    build_pyenv
done
