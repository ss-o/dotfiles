alias edit-aliases="${EDITOR:-vim} ${(%):-%N}"

# GIT
alias add-editorconfig="wget -O - https://raw.githubusercontent.com/ss-o/ss-o/gh-pages/config/editorconfig > .editorconfig"
alias add-gitattributes="wget -O - https://raw.githubusercontent.com/ss-o/ss-o/gh-pages/config/gitattributes >> .gitattributes"
alias add-gitignore="wget -O - https://raw.githubusercontent.com/ss-o/ss-o/gh-pages/config/gitignore >> .gitignore"
alias add-cloudflare-ca-pem="wget -O - https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.pem > Cloudflare_CA.pem"
alias add-cloudflare-ca-crt="wget -O - https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.crt > Cloudflare_CA.crt"
alias add-lychee-config='wget -O - https://github.com/lycheeverse/lychee/raw/master/lychee.example.toml'
alias add-trunk='curl https://get.trunk.io -fsSL | bash'
alias add-fly-cli='curl -L https://fly.io/install.sh | sh'

alias get-origin='command git config -l | grep remote.origin.url | awk -F'=' '{print $2}''

# Utilities
alias palette='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done'

# Node/Js
alias pm=pnpm

# GPG
alias gpg-gen-pass='command gpg --gen-random --armor 0 24'

# Zsh
alias options-status='setopt ksh_option_print && setopt'
alias zstyle-status='zstyle -L'

# --- System
# ------ Wrappers
alias reload!='exec "$SHELL" -l'

alias check-logs='command journalctl -p 3 -b -e'
alias check-symlinks='command find . -xtype l -print 2> /dev/null'
alias update-grub='f() {sudo grub-mkconfig -o /boot/grub/grub.cfg "$@"; unset -f f; }; f'
alias sys-info='echo OSTYPE=${OSTYPE} MACHTYPE=${MACHTYPE} CPUTYPE=${CPUTYPE}'
alias sys-useradd='sudo useradd -s /usr/sbin/nologin -r -M'
alias freemem='echo 3 | sudo tee /proc/sys/vm/drop_caches'
alias machine-id='cat /var/lib/dbus/machine-id | md5sum'
alias check-macpath='[[ -n "${(j::)${(M)path[@]:#/opt/local/bin}}" ]]'
alias kate='command kate >/dev/null 2>&1 "${@}" &!'
alias history-cmd-top="fc -ln 0 | awk '{print $1}' | sort | uniq -c | sort -nr | head"
alias mm='micro'

alias generate-boot-log="sudo journalctl -b | curl -F 'file=@-' 0x0.st"

# ------ Triage
#alias exec-cmds='function() {for i in `seq 50` ; $1; [[ ! $? = 0 ]] && break ; done;}'

# Files & Directories
alias dirs-size='du -h --max-depth=1 | sort -hr'

# Convert
alias ffmpeg-convert='f() {command ffmpeg -i $1 -c:v libx264 -crf 18 -preset slow -c:a aac -b:a 192k -ac 2 $2; unset -f f; }; f'
alias pandoc-html-to-pdf='f() {command pandoc ${1}.html -t latex -o ${2}.pdf; unset -f f; }; f'

# Trunk
alias check='trunk check --jobs $(nproc)'

# Lychee
alias docker-lychee='docker run --init -it -v $(pwd):/input lycheeverse/lychee'
alias docker-lychee-gh='docker run --init -it -v $(pwd):/input lycheeverse/lychee --github-token'

# Rclone
alias rclone-dedupe='rclone dedupe --by-hash --dedupe-mode newest'

# Network
alias get-public-ipv4='curl -sf "https://ipv4.icanhazip.com" || curl -sf "https://ifconfig.me" || curl -sf "zx2c4.com/ip"'
alias get-public-ipv6='curl -sf "https://ipv6.icanhazip.com"'
alias get-cidr="ip addr | grep inet | awk '{print $2}' | sort"
alias get-local-tasks-listen='lsof -i -P | grep -i listen'
alias get-local-tasks-established='lsof -i -P | grep -i established'
alias get-local-tcp-listen='netstat -an | grep LISTEN | grep tcp'
alias get-local-unix-listen='netstat -an | grep LISTEN | grep unix'
alias add-http-user='sudo htpasswd -c /etc/apache2/.htpasswd'
alias run-python-server='python -m http.server 8888'

# --- SSH
# ------ [ <tunnel port>:<destination address>:<destination port> ]
alias ssh-forward-3000='ssh -L 3000:localhost:3000'

# --- WireGuard
alias wg0-up="wg-quick up wg0"
alias wg0-down="wg-quick down wg0"

# ---Cloudflare
# ------ [ zero-trust ]
alias warp-on="sudo systemctl start warp-svc.service"
alias warp-off="sudo systemctl stop warp-svc.service"
alias warp="warp-cli"
# ------ [ info ]
alias get-cloudflare-ipv6='curl -sL "https://www.cloudflare.com/ips-v6"'
alias get-cloudflare-ipv4='curl -sL "https://www.cloudflare.com/ips-v4"'

# --- Google Cloud
alias gcloud-interactive='gcloud beta interactive'
# ------ [ cloud-shell ]
alias cloud-shell-mount='gcloud cloud-shell get-mount-command ${HOME}/.sshfs/cloud-shell'
alias cloud-shell='gcloud cloud-shell ssh --authorize-session'
# ------ [ compute ]
alias compute-ssh-config='gcloud compute config-ssh'
alias compute-ssh-e2='gcloud compute ssh --zone "us-central1-a" "e2" --project "digital-clouds"'
alias compute-list-us-central='gcloud compute instances list --filter="zone:us-central1-a"'

# API
# --- Check Licenses
alias gh-api='gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28"'
alias gh-get-licenses='gh-api /licenses'
alias gh-get-emojis='gh-api /emojis'
alias gh-get-gitignore-templates='gh-api /gitignore/templates'
