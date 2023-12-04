#!/usr/bin/env bash

# Hosts required
declare -a hosts=(
  'core.internal'
)

declare target_path='/srv/sshfs'
declare mount_options='follow_symlinks,allow_other,uid=1000,gid=1000'

sshfs_mount() {
  [[ -n ${RUN_QUIET} ]] || echo -ne "Hosts: "
  for host in "${hosts[@]}"; do
    [[ -n ${RUN_QUIET} ]] || echo -ne "${host} "
    if ping -c 1 "${host}" &>/dev/null; then
      if [[ ! -d "${target_path}/${host}" ]]; then
        mkdir -p "${target_path}/${host}"
      fi
      sshfs "${host}":/mnt/dietpi_userdata "${target_path}/${host}" -o "${mount_options}"
      [[ -n ${RUN_QUIET} ]] || echo -e "✓ "
      return 0
    else
      [[ -n ${RUN_QUIET} ]] || echo -e "✗ "
      return 1
    fi
  done
}

sshfs_umount() {
  for host in "${hosts[@]}"; do
    if ping -c 1 "${host}" &>/dev/null; then
      fusermount -u "${target_path}/${host}"
    fi
  done
}

main() {
  declare opt=$1
  shift
  case ${opt} in
  -q | --quiet) RUN_QUIET=true ;;
  -m | --mount) sshfs_mount ;;
  -u | --umount) sshfs_umount ;;
  *) true ;;
  esac
  unset opt
  return 0
}

main "$@"
