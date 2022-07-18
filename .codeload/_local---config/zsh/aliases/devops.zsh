# Google Cloud Shell
alias cloud-shell-mount='gcloud cloud-shell get-mount-command ${HOME}/.sshfs/cloud-shell'
alias cloud-shell='gcloud cloud-shell ssh --authorize-session'

# Linux
alias freemem='sudo /sbin/sysctl -w vm.drop_caches=3'

# OS
alias sys-info='echo OSTYPE=${OSTYPE} MACHTYPE=${MACHTYPE} CPUTYPE=${CPUTYPE}'

# WireGuard
alias wg0-up="wg-quick up wg0"
alias wg0-down="wg-quick down wg0"
alias wg1-up="wg-quick up wg1"
alias wg1-down="wg-quick down wg1"
alias guard-up="wg-quick up guard0"
alias guard-down="wg-quick down guard0"

# Cloudflare
# Warp
alias warp-on="sudo systemctl start warp-svc.service"
alias warp-off="sudo systemctl stop warp-svc.service"
alias warp="warp-cli"
