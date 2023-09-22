#!/usr/bin/env sh

## --- Rsync (Everyone seems to like -z, but it is much slower for me)
#
#    a: archive mode - rescursive, preserves owner, preserves permissions, preserves modification times, preserves group, copies symlinks as symlinks, preserves device files.
#    H: preserves hard-links
#    A: preserves ACLs
#    X: preserves extended attributes
#    x: don't cross file-system boundaries
#    v: increase verbosity
#    --numeric-ds: don't map uid/gid values by user/group name
#    --delete: delete extraneous files from dest dirs (differential clean-up during sync)
#    --progress: show progress during transfer
#
# [ rsync -aHAXxv --numeric-ids --delete --progress -e "ssh -T -c arcfour -o Compression=no -x" user@<source>:<source_dir> <dest_dir> ]

## --- SSH
#
#    T: turn off pseudo-tty to decrease cpu load on destination.
#    c arcfour: use the weakest but fastest SSH encryption. Must specify "Ciphers arcfour" in sshd_config on destination.
#    o Compression=no: Turn off SSH compression.
#    x: turn off X forwarding if it is on by default.
#
# [ rsync -aHAXxv --numeric-ids --delete --progress -e "ssh -T -o -c aes128-gcm@openssh.com Compression=no -x" [source_dir] [dest_host:/dest_dir] ]

#!/bin/bash
# Fast rsync command

# Set the RSYNC_ARGS.
UNAME="$(uname -s)"
case "${UNAME}" in
Linux* | Darwin*)
  RSYNC_ARGS="-aHAXxv --numeric-ids --delete --progress -e"
  ;;
# Windows filesystems do not support extended attributes (the "-X" option)
CYGWIN* | MINGW*)
  RSYNC_ARGS="-aHAxv --numeric-ids --delete --progress -e"
  ;;
*)
  echo "ERROR: Running on unknown system! Exiting!"
  return 1
  ;;
esac

# Set the SSH_ARGS
SSH_ARGS="-T -o -c aes128-gcm@openssh.com Compression=no -x"

# Get the rest of the args from the caller
USER=$1
SOURCE=$2
SOURCE_DIR=$3
DEST_DIR=$4

rsync "${RSYNC_ARGS}" "ssh ${SSH_ARGS}" "${USER}"@"${SOURCE}":"${SOURCE_DIR}" "${DEST_DIR}"
