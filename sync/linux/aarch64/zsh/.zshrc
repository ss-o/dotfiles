# Standardized $0 Handling
# https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

_dietpi_aliases() {
  [[ -t 0 ]] && G_INTERACTIVE=1 || return 0
  if [[ -d /boot/dietpi ]]; then
    typeset -a dp_file; dp_file=( /boot/dietpi/dietpi-*(.) )
    typeset -a dp_file_names; dp_file_names=( ${dp_file#*/boot/dietpi/*} )

    G_SUDO(){ local input=$*; sudo bash -c ". /boot/dietpi/func/dietpi-globals && $input"; }

    for dp_alias in $dp_file_names; do
      builtin alias $dp_alias="G_SUDO /boot/dietpi/$dp_alias"
    done
  fi
}
_dietpi_aliases
