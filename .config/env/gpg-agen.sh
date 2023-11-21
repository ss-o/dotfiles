if (( $+commands[gpg-connect-agent] )); then
  typeset -gx GPG_TTY=$(tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null
fi
