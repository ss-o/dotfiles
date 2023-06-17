#!/usr/bin/env bash

# Hosts required
declare -a hosts=(
  core.internal
)

# Units to mount
declare -a units=(
  sshfs_pictures
  sshfs_storage
  sshfs_videos
  sshfs_music
)

check_hosts() {
  [[ -n ${RUN_QUIET} ]] || echo -ne "Hosts: "
  # Ping internal hosts
  for host in "${hosts[@]}"; do
    [[ -n ${RUN_QUIET} ]] || echo -ne "${host}: "
    # Check the exit code of the ping command
    if ping -c 1 "${host}" &>/dev/null; then
      [[ -n ${RUN_QUIET} ]] || echo -e "✓ "
      return 0
    else
      [[ -n ${RUN_QUIET} ]] || echo -e "✗ "
      return 1
    fi
  done
  echo
}

remote_sshfs_mount() {
  [[ -n ${RUN_QUIET} ]] || echo -ne "Mount: "
  for unit in "${units[@]}"; do
    systemctl --user is-active --quiet "${unit}".service
    activated=$?
    [[ -n ${RUN_QUIET} ]] || echo -ne "${unit}: "
    if [[ ${activated} -ne 0 ]]; then
      systemctl --user start "${unit}".service
      [[ -n ${RUN_QUIET} ]] || echo -ne "✓ "
    else
      systemctl --user stop "${unit}".service
      [[ -n ${RUN_QUIET} ]] || echo -ne "✗ "
    fi
  done
  echo
  systemctl --user daemon-reload
  command sync
}

main() {
  declare opt=$1
  shift
  case ${opt} in
  -q | --quiet) RUN_QUIET=true ;;
  *) true ;;
  esac
  check_hosts && remote_sshfs_mount "$@"

  unset opt
}

main "$@"
