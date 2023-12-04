# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

if [ ! -n "$TERM" ] || [ "$TERM" = dumb ] || (( ! $+commands[grc] )); then
  return 1
else
  if (( ${#_grc_cmds[@]} == 0 )); then
  _grc_cmds=(
    'as'
    'ant'
    'blkid'
    'cc'
    'configure'
    'curl'
    'cvs'
    'df'
    'diff'
    'dig'
    'dnf'
    'docker'
    'docker-compose'
    'docker-machine'
    'du'
    'env'
    'fdisk'
    'findmnt'
    'free'
    'g++'
    'gas'
    'gcc'
    'getfacl'
    'getsebool'
    'gmake'
    'id'
    'ifconfig'
    'iostat'
    'ip'
    'iptables'
    'iwconfig'
    'journalctl'
    'kubectl'
    'last'
    'ldap'
    'lolcat'
    'ld'
    'ls'
    'lsattr'
    'lsblk'
    'lsmod'
    'lsof'
    'lspci'
    'make'
    'mount'
    'mtr'
    'mvn'
    'netstat'
    'nmap'
    'ntpdate'
    'php'
    'ping'
    'ping6'
    'proftpd'
    'ps'
    'sar'
    'semanage'
    'sensors'
    'showmount'
    'sockstat'
    'ss'
    'stat'
    'sysctl'
    'systemctl'
    'tcpdump'
    'traceroute'
    'traceroute6'
    'tune2fs'
    'ulimit'
    'uptime'
    'vmstat'
    'wdiff'
    'whois'
  )
  fi

  # Wrap commands in grc
  for _grc_cmd in "${_grc_cmds[@]}"; do
    if (( $+commands[$_grc_cmd] )); then
      eval "
        $_grc_cmd() {
          "command grc -es --colour=auto $_grc_cmd" "\$@"
        }
      "
    fi
  done

  unset _grc_cmd{s,}
fi
