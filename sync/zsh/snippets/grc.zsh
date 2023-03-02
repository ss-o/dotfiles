if (( ! $+commands[grc] )); then
  return 1
fi

  if (( ${#_grc_cmds[@]} == 0 )); then
    _grc_cmds=(
      'cat' 'tail' 'configure' 'diff' 'make' 'gcc' 'g++' 'as' 'gas' 'ps'
      'ld' 'netstat' 'ping' 'ping6' 'traceroute' 'traceroute6' 'nmap' 'df'
      'mount' 'mtr' 'ifconfig' 'dig' 'ip'
     )
  fi

  # Wrap commands in grc
  for _grc_cmd in "${_grc_cmds[@]}"; do
    if (( ${+commands[${_grc_cmd}]} )); then
      eval "
        function ${_grc_cmd} {
          "grc -es --colour=auto ${_grc_cmd}" "\$@"
        }
      "
    fi
  done

unset _grc_cmd{s,}
