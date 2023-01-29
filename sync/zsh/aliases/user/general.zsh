# GIT
alias add-editorconfig="wget -O - https://raw.githubusercontent.com/ss-o/ss-o/gh-pages/config/editorconfig > .editorconfig"
alias add-gitattributes="wget -O - https://raw.githubusercontent.com/ss-o/ss-o/gh-pages/config/gitattributes >> .gitattributes"
alias add-gitignore="wget -O - https://raw.githubusercontent.com/ss-o/ss-o/gh-pages/config/gitignore >> .gitignore"

# Arch Linux
#alias paru="paru --bottomup"

# System
alias freemem='sudo /sbin/sysctl -w vm.drop_caches=3'
alias reload!='exec "$SHELL" -l'
alias sys-info='echo OSTYPE=${OSTYPE} MACHTYPE=${MACHTYPE} CPUTYPE=${CPUTYPE}'
alias mm='micro'
alias host-ips="ip addr | grep inet | awk '{ print $2; }' | sed 's/\/.*$//' | sort"
alias history-topcmd='fc -ln 0 | awk '{print $1}' | sort | uniq -c | sort -nr | head'
alias sys-useradd='sudo useradd -s /usr/sbin/nologin -r -M'

# Lychee
alias docker-lychee='docker run --init -it -v `pwd`:/input lycheeverse/lychee'
alias docker-lychee-gh='docker run --init -it -v `pwd`:/input lycheeverse/lychee --github-token'

# Rclone
alias rclone-dedupe='rclone dedupe --by-hash --dedupe-mode newest'

# WireGuard
alias wg0-up="wg-quick up wg0"
alias wg0-down="wg-quick down wg0"

# Cloudflare
alias warp-on="sudo systemctl start warp-svc.service"
alias warp-off="sudo systemctl stop warp-svc.service"
alias warp="warp-cli"

# Google Cloud
alias gcloud-interactive='gcloud beta interactive'
# --- cloud-shell
alias cloud-shell-mount='gcloud cloud-shell get-mount-command ${HOME}/.sshfs/cloud-shell'
alias cloud-shell='gcloud cloud-shell ssh --authorize-session'
# ---compute
alias ssh-e2-set='gcloud compute config-ssh'
alias ssh-e2='gcloud compute ssh --zone "us-central1-a" "e2"  --project "digital-clouds"'
alias list-e2='gcloud compute instances list --filter="zone:us-central1-a"'