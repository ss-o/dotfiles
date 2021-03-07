#!/usr/bin/env bash
# ============================================================================= #
#  ➜ ➜ ➜ SETUP COMPOSER
# ============================================================================= #
curr_dir="$(readlink -f "$0")"
curr_dir="${curr_dir%\/*}"
cd "$curr_dir"
source "$curr_dir/../utilities.sh"
SET_BOO || SET_TRAP || NEVER_ROOT
if ! NOCMD php; then
    NOTIFY "PHP required to install composer."
    exit 1
fi

TITLE "Installing Composer"
while true; do
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
    sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
    sudo rm /tmp/composer-setup.php
    exit 0
done
