# ⸨ DietPi ⸩
@dietpi_aliases() {
  #[[ -t 0 ]] && G_INTERACTIVE=1 || return 0
  typeset G_INTERACTIVE=1

  if [[ -d /boot/dietpi ]]; then
    G_SUDO(){ local input=$*; emulate sh -c "source /boot/dietpi/func/dietpi-globals && sudo $input"; }
    () {
      local -a dp_file
      dp_file=( /boot/dietpi/dietpi-* )
      dp_file=( ${dp_file:t} )
      local dp_alias; for dp_alias in $dp_file; do
        alias $dp_alias="G_SUDO /boot/dietpi/${dp_alias}"
      done
    }
  fi
}
@dietpi_aliases; unset -f @dietpi_aliases
