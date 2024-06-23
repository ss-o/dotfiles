#!/usr/bin/env bash

# TODO:
# sudo useradd --system --user-group -d /srv/sshfs -u 850 -s /usr/bin/nologin sshfs
# sudo chown :sshfs /srv/sshfs

# Hosts required
#declare -a hosts=(
#  'core.internal'
#)

declare host='core.internal'
declare host_path='/mnt/dietpi_userdata'
declare target_path='/srv/sshfs'
declare mount_options="_netdev,rw,nosuid,allow_other,uid=$UID,gid=850,default_permissions,follow_symlinks,idmap=user"

return_ok() {
  if [[ -z ${RUN_QUIET} ]]; then
    echo -e "Status: ✓"
  fi
  return 0
}

return_err() {
  if [[ -z ${RUN_QUIET} ]]; then
    echo -e "Status: ✗"
  fi
  clear_mount
  return 1
}

prepare_mount() {
  if [[ ! -d "${target_path}/${host}" ]]; then
    command mkdir -p "${target_path}/${host}"
  fi
}

clear_mount() {
  if [[ -d "${target_path}/${host}" ]]; then
    command rm -rf "${target_path}/${host}"
  fi
}

sshfs_mount() {
  [[ -n ${RUN_QUIET} ]] || echo -e "Hosts: ${host}"
  #  for host in "${hosts[@]}"; do
  if command ping -c 1 "${host}" &>/dev/null; then
    prepare_mount
    if command sshfs "${host}:${host_path}" "${target_path}/${host}" -o "${mount_options}"; then
      return_ok
    else
      return_err
    fi
  else
    [[ -n ${RUN_QUIET} ]] || echo -e "Error: failed to ping $host"
  fi
  #  done
}

sshfs_umount() {
  #  for host in "${hosts[@]}"; do
  if ping -c 1 "${host}" &>/dev/null; then
    fusermount -u "${target_path}/${host}" && clear_mount
  fi
  #  done
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
