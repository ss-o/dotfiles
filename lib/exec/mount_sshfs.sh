#!/usr/bin/env bash

declare -a units=(
  sshfs_pictures
  sshfs_storage
  sshfs_videos
  sshfs_music
)

remote_sshfs_mount() {
  for unit in "${units[@]}"; do
    systemctl --user is-active --quiet "${unit}".service
    activated=$?
    if [[ ${activated} -ne 0 ]]; then
      systemctl --user start "${unit}".service
      [[ -n ${RUN_QUIET} ]] || echo "Mounted: ${unit}"
      systemctl --user daemon-reload
      command sync
    else
      systemctl --user stop "${unit}".service
      [[ -n ${RUN_QUIET} ]] || echo "Unmounted: ${unit}"
      systemctl --user daemon-reload
      command sync
    fi
  done
}

main() {
  opt=$1
  case ${opt} in
  -q | --quiet) RUN_QUIET=true ;;
  *) true ;;
  esac
  remote_sshfs_mount "$@"
}

main "$@"
