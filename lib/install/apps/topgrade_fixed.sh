#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ IMPORTS
# ============================================================================= #
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$current_dir/../utilities.sh"
# ============================================================================= #
SET_BOO

get_topgrade() {
    TITLE "Installing TOPGRADE"
    gituser="r-darwish"
    gitrepo="topgrade"
    ARCH=$(uname -m)

    case $ARCH in
    'x86_64')
        get_download_url() {
            wget -q -nv -O- https://api.github.com/repos/$gituser/$gitrepo/releases/latest 2>/dev/null | jq -r '.assets[] | select(.browser_download_url | contains("x86_64-unknown-linux-gnu")) | .browser_download_url'
        }
        URL=$(get_download_url)
        echo "Found - $URL"
        ;;
    'aarch64')
        get_download_url() {
            wget -q -nv -O- https://api.github.com/repos/$gituser/$gitrepo/releases/latest 2>/dev/null | jq -r '.assets[] | select(.browser_download_url | contains("aarch64-unknown-linux-gnu")) | .browser_download_url'
        }
        URL=$(get_download_url)
        echo "Found - $URL"
        ;;
    'armv7l')
        get_download_url() {
            wget -q -nv -O- https://api.github.com/repos/$gituser/$gitrepo/releases/latest 2>/dev/null | jq -r '.assets[] | select(.browser_download_url | contains("armv7-unknown-linux-gnueabihf")) | .browser_download_url'
        }
        URL=$(get_download_url)
        echo "Found - $URL"
        ;;
    *)
        echo -ne "Platform not found. Failed download"
        sleep 1
        echo "Exiting... "
        exit 0
        ;;
    esac
}
    execute_binary() {
        mkdir -p "$HOME/.local/bin"
        install_dir="$HOME/.local/bin"
        BASE=$(basename $URL)
        wget -q -nv -O $BASE $URL
        if [ ! -f $BASE ]; then
            echo "Didn't download $URL properly.  Where is $BASE?"
            exit 1
        fi
        echo
        mv $BASE $install_dir
        echo "Moved to $install_dir"
        tarfile="$(cd $install_dir && find . -name "*.tar.gz")"
        cd $install_dir && tar -xzf $tarfile
        echo "Extracting files... "
        rm $tarfile
        echo "Removing unnecessary files "
        chmod +x "$install_dir/topgrade"
    }

main() {
  get_topgrade "$@"
  execute_binary "$@"
  SUCCESS "Done"
  MSGOK "Maintainer: Salvydas Lukosius | sall@w-ss.io"
  exit 0
}

while true; do
 main "$@"
done 
