#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ SETUP GO
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir" || return
source "$curr_dir/../utilities.sh"
source "$curr_dir/../versions.sh"
source "$curr_dir/../os.sh"
SET_BOO || SET_TRAP
if ! NOCMD lsb_release; then
    NOTIFY "LSB-RELEASE required to install go."
    exit 1
fi
TITLE "Installing Go ${versionGo}"

MSGINFO "$DISTRO $UARCH $LSBVER"
sleep 1
while true; do

    case $UARCH in
    x86_64)
        CURLL "https://dl.google.com/go/go${versionGo}.linux-amd64.tar.gz" "go.tar.gz"
        tar xvf go.tar.gz
        ;;
    aarch64)
        CURLL "https://dl.google.com/go/go${versionGo}.linux-arm64.tar.gz" "go.tar.gz"
        tar xvf go.tar.gz
        ;;
    *) MSGERROR "Unknown platform" ;;
    esac

    if [[ -d /usr/local/go ]]; then
        sudo rm -rf /usr/local/go
    fi
    sudo mv go /usr/local
    rm go.tar.gz -f

    [[ -d "$HOME/go" ]] && export GOPATH="$HOME/go"
    [[ -d "/usr/local/go" ]] && export GOROOT="/usr/local/go"

    go get -u github.com/nsf/gocode
    # sebdah/vim-delve
    go get github.com/derekparker/delve/cmd/dlv

    # popular golang libs
    go get -u github.com/sirupsen/logrus
    go get -u github.com/spf13/cobra/cobra
    go get -u github.com/golang/dep/cmd/dep
    go get -u github.com/fatih/structs
    go get -u github.com/gorilla/mux
    go get -u github.com/gorilla/handlers
    go get -u github.com/parnurzeal/gorequest
    go get -u github.com/urfave/cli
    go get -u github.com/apex/log/...

    #    go get github.com/davecheney/httpstat
    #    go get github.com/joho/godotenv
    #    go get github.com/briandowns/spinner
    #    go get github.com/donutloop/toolkit/worker
    MSGINFO "SHELL reload needed to finish GO installation"
    exit 0
done
