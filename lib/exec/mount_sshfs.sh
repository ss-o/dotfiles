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
      echo "Mounted: ${unit}"
      systemctl --user daemon-reload
      command sync
    else
      echo "Unit ${unit} already mounted"
    fi
  done
}

remote_sshfs_unmount() {
  for unit in "${units[@]}"; do
    systemctl --user is-active --quiet "${unit}".service
    activated=$?
    if [[ ${activated} -ne 0 ]]; then
      echo "Unit ${unit} not mounted"
    else
      systemctl --user stop "${unit}".service
      echo "Unmounted: ${unit}"
      systemctl --user daemon-reload
      command sync
    fi
  done
}

opt=$1
case ${opt} in
mount) remote_sshfs_mount ;;
unmount) remote_sshfs_unmount ;;
*)
  echo "Option required: mount/unmount"
  exit 1
  ;;
esac
