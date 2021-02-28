#!/usr/bin/env bash
# shellcheck source=/dev/null
. "$HOME/.dotfiles/lib/toolbox/utilities.sh"

echo "Your choice?"
SHOW_OPTIONS() {
    tput bold
    tput setaf 3
    echo "[0] Cancel install"
    echo "[1] Only Necessary Fonts"
    echo "[2] All Fonts Install [Nerd Fonts]"
    tput sgr0
}
INSTALL() {
    while [[ -z "$FONT" ]]; do
        tput bold && tput setaf 1
        read -r -p "$*[0/1/2]" ans
        tput setaf 4
        case $ans in
        [0]*)
            echo "Don't Install Fonts."
            FONT=0
            break
            ;;
        [1]*)
            echo "Install Necessary Fonts."
            CHECK_FONT_DIR
            FONT=1
            break
            ;;
        [2]*)
            echo "All Fonts Install."
            DO_ALL
            FONT=2
            ;;
        esac
        echo "Please answer again."
        SHOW_OPTIONS
    done
}

CHECK_FONT_DIR() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        local fontDir="/usr/share/fonts/"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        local fontDir="/Library/Fonts/"
    elif uname -a | grep FreeBSD; then
        local fontDir="/usr/local/share/fonts/"
    else
        echo "OS NOT SUPPORTED, couldn't install fonts."
        exit 1
    fi
    builtin cd $fontDir || exit 1
    sudo curl -fLo "Hack Bold Nerd Font Complete.ttf" https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/Bold/complete/Hack%20Bold%20Nerd%20Font%20Complete.ttf
    sudo curl -fLo "Hack Bold Italic Nerd Font Complete.ttf" https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/BoldItalic/complete/Hack%20Bold%20Italic%20Nerd%20Font%20Complete.ttf
    sudo curl -fLo "Hack Italic Nerd Font Complete.ttf" https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/Italic/complete/Hack%20Italic%20Nerd%20Font%20Complete.ttf
    sudo curl -fLo "Hack Regular Nerd Font Complete.ttf" https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
    sudo chmod 644 Hack*

    if ! [[ "$OSTYPE" == "darwin"* ]]; then
        fc-cache -f -v
    fi
    builtin cd "/tmp" || ERROR
}

DO_ALL() {
    git clone https://github.com/ryanoasis/nerd-fonts.git "/tmp/nerd-fonts"
    cd nerd-fonts && ./install.sh
    builtin cd .. || ERROR
}

SHOW_OPTIONS
tput bold && tput setaf 4
INSTALL "${@}"
tput sgr0
