#!/usr/bin/env sh
# -*- mode: sh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=sh sw=2 ts=2 et
# ============================================================================= #
trap '' INT QUIT TERM
# ============================================================================= #
# shellcheck source=/dev/null
dosync_dir="$(command cd -P -- "$(dirname -- "$(command -v -- "$0" || true)")" && pwd -P)"
[ -z "${sync_dir}" ] && sync_dir=${dosync_dir}
[ -z "${_user_home}" ] && _user_home="${HOME}"

_time_stamp=$(date +%D)

_backup_dir="${_user_home}/.backup/${_time_stamp}"
_logfile="${_user_home}/.backup/${_time_stamp}/install.log"
_user_home_config="${_user_home}/.config"
_sync_file="${sync_dir}/sync.config"

# Settings
_git_opt="-q"
_git_sub="-q"
_git_sub_opt="-q"
_required_cmds="zsh git i_am_required me_too"
_supported_os="linux darwin"
_supported_cpu="x86_64 aarch64"
# ============================================================================== #

# Check environment ™
_is_quiet="${_is_quiet:-false}"
_is_tty="${_is_tty:-false}"
_is_piped="${_is_piped:-false}"
# ============================================================================== #
info_block() {
  # Don't print anything if we're in quiet mode
  [ "${_is_quiet}" = "true" ] && return 0
  printf '\033[1;46m%-*s\033[0m\n' "${COLUMNS:-$(tput cols || true)}" "▓▒░ ★ » $1" | tr ' ' ' '
}

note_block() {
  # Don't print anything if we're in quiet mode
  [ "${_is_quiet}" = "true" ] && return 0
  printf '\033[1;42m%-*s\033[0m\n' "${COLUMNS:-$(tput cols || true)}" "▓▒░ ★ » $1" | tr ' ' ' '
}

say() {
  while [ -n "$1" ]; do
    one_line=0
    case "$1" in
    -normal) col="\033[00m" ;;
    -black) col="\033[30;01m" ;;
    -red) col="\033[31;01m" ;;
    -green) col="\033[32;01m" ;;
    -yellow) col="\033[33;01m" ;;
    -blue) col="\033[34;01m" ;;
    -magenta) col="\033[35;01m" ;;
    -cyan) col="\033[36;01m" ;;
    -white) col="\033[37;01m" ;;
    -n)
      one_line=1
      shift
      continue
      ;;
    *)
      printf '%s\033[00m' "${1}"
      shift
      continue
      ;;
    esac
    shift
    printf "${col}%s\033[00m" "$1"
    shift
  done
  [ "${one_line}" = 1 ] || printf "\n"
}

err() {
  say -red "$1" >&2
  exit 1
}

say_ok() {
  # Don't print anything if we're in quiet mode
  [ "${_is_quiet}" = "true" ] && return 0

  printf "\033[34;1m▓▒░\033[32;01m ✔ \033[00m» "
  say -green "$1"
  printf "\033[00m"

  return 0
}

say_info() {
  # Don't print anything if we're in quiet mode
  [ "${_is_quiet}" = "true" ] && return 0

  printf "\033[34;1m▓▒░\033[35;01m ❢ \033[00m» "
  say -magenta "$1"
  printf "\033[00m"

  return 0
}

say_warn() {
  # Don't print anything if we're in quiet mode
  [ "${_is_quiet}" = "true" ] && return 0

  printf "\033[34;1m▓▒░\033[33;01m ❢ \033[00m» "
  say -yellow "$1"
  printf "\033[00m"
}

say_err() {
  printf "\033[34;01m▓▒░\033[31;01m ✘ \033[00m» "
  say -red "$1" >&2
  printf "\033[00m"
  exit 1
}

say_log() {
  [ -d "${_backup_dir}" ] || command mkdir -p "${_backup_dir}"
  say_info "$1 -- $(date || true)" | command tee -a "${_logfile}" >/dev/null
}
# ============================================================================== #
_get_os() {
  _current_os="$(command -v uname)"
  case $("${_current_os}" | tr '[:upper:]' '[:lower:]') in
  android*) _current_os='android' ;;
  darwin*) _current_os='darwin' ;;
  linux*) _current_os='linux' ;;
  freebsd*) _current_os='freebsd' ;;
  netbsd*) _current_os='netbsd' ;;
  openbsd*) _current_os='openbsd' ;;
  sunos*) _current_os='solaris' ;;
  msys* | cygwin* | mingw* | win*) _current_os='windows' ;;
  *) _current_os='unknown' ;;
  esac
  say "${_supported_os}" | command grep -q "${_current_os}"
  return $?
}

_get_arch() {
  _current_arch="$(command -v uname)"
  case $("${_current_arch}" -m | tr '[:upper:]' '[:lower:]') in
  x86_64 | amd64) _current_arch='x86_64' ;;
  i?86 | x86) _current_arch='386' ;;
  armv8* | aarch64 | arm64) _current_arch='aarch64' ;;
  *) _current_arch='unknown' ;;
  esac
  say "${_supported_cpu}" | command grep -q "${_current_arch}"
  return $?
}

_go_to() { command cd "$1" || say_err "Failed to enter directory %s."; }
_go_back() { command cd "${OLDPWD}" || say_err "Failed return to previous directory."; }
_check_git() {
  if [ ! -d .git ]; then
    say_err "Not a git repository"
  else
    ORIGIN=$(command git config -l | command grep -i remote.origin.url | awk -F'=' '{print $2}')
    [ -z "${ORIGIN}" ] && say_err "No git origin found"
  fi
  return 0
}
_has_terminal() { [ -t 0 ]; }
_is_tty() { _has_terminal; }
_is_piped() { [ ! -t 1 ]; }
_is_root() { [ "$(id -u || true)" -eq 0 ]; }

_check_deps() {
  for deps in ${_required_cmds}; do
    command -v "${deps}" >/dev/null 2>&1 || {
      say_err "Missing required dependency: ${deps}"
    }
  done

  return 0
}

_check_system() {
  _get_os || say_err "Unsupported OS: ${_current_os}"
  _get_arch || say_err "Unsupported CPU: ${_current_arch}"

  _sync_platform="${_current_os}/${_current_arch}"
  if [ -n "${_sync_platform}" ]; then
    say "${_sync_platform}" | command grep -q "${_current_os}/${_current_arch}"
    return $?
  fi
}

_remove_broken_links() {
  command find "${_user_home}" -maxdepth 1 -name "*" -o -name ".*" -type l | while read -r f1; do
    if [ -L "${f1}" ] && [ ! -e "${f1}" ]; then
      command rm -f "${f1}" && say_info "Removed dangling symlink: ${f1}"
    fi
    command find "${_user_home_config}" -maxdepth 2 -name "*" -o -name ".*" -type l | while read -r f2; do
      if [ -L "${f2}" ] && [ ! -e "${f2}" ]; then
        command rm -f "${f2}" && say_info "Removed dangling symlink: ${f2}"
      fi
    done
  done
  say_ok "No broken symlinks"
}

_git_pull() {
  _go_to "${dosync_dir}" && _check_git
  say -cyan "Pulling latest changes from ${ORIGIN}"
  command git pull "${_git_opt}"
  if [ -f .gitmodules ]; then
    say -cyan "Pulling latest changes for submodules"
    command git submodule "${_git_sub_opt}" sync --recursive
    # Required if a submodule origin changed
    command git submodule "${_git_sub_opt}" update --init --recursive
    command git submodule "${_git_sub_opt}" foreach --recursive git fetch
    command git submodule "${_git_sub_opt}" foreach --recursive git pull
  fi
  _go_back
  return $?
}

_git_commit() {
  _go_to "${dosync_dir}" && _check_git
  say -cyan "Committing latest changes to the repository"
  command git commit -a "${_git_opt}" -m "Sync on $(date || true)"
  if [ -f .gitmodules ]; then
    say -cyan "Committing latest changes for submodules"
    command git submodule "${_git_sub_opt}" foreach --recursive git commit -a "${_git_opt}" -m "Sync on $(date || true)"
  fi
  _go_back
  return $?
}

_git_push() {
  _go_to "${dosync_dir}" && _check_git
  say -cyan "Pushing changes upstream to ${ORIGIN}"
  command git push "${_git_opt}"
  if [ -f .gitmodules ]; then
    say -cyan "Pushing changes for submodules"
    command git push "${_git_sub_opt}" --recurse-submodules=on-demand
    command git submodule "${_git_sub_opt}" foreach --recursive git push
  fi
  _go_back
  return $?
}

_git_add() {
  _check_git && _go_to "${dosync_dir}" && command git add -A && command git status -s
  if [ -f .gitmodules ]; then
    say -cyan "Adding changes for submodules"
    command git submodule "${_git_sub_opt}" foreach --recursive git add -A
    command git submodule "${_git_sub_opt}" foreach --recursive git status -s
  fi

  return $?
}
_git_sync() {
  _git_add && _git_commit && _git_push && _git_pull
  return $?
}

_create_sync_location() {
  _check_system
  if [ -n "${_current_os}" ] && [ -n "${_current_arch}" ]; then
    _sync_location="${dosync_dir}/sync/${_sync_platform}"
    if [ ! -d "${_sync_location}" ]; then
      command mkdir -p "${_sync_location}" || say_err "Failed to create sync location"
      say_ok "Created sync location: ${_sync_location}"
      return 0
    else
      say_ok "Location already exists: ${_sync_location}"
      return 0
    fi
  fi
  return 1
}

_sync_config() {
  if [ -s "${_sync_file}" ]; then
    _files_src="$(sed -n '/\[files\]/,/\[endfiles\]/p' "${_sync_file}" | grep -v '^\[.*files]' | grep -v '^#' | grep -v '^$' | sort -u)"
    if [ -z "${_files_src}" ]; then
      say_err "Specify files to sync in ${_sync_file} file"
    fi
    return 0
  else
    say_err "File ${_sync_file} doesn't exist, exiting"
  fi
}

_read() {
  input="$1"
  shift
  src_file="$(printf '%s' "${input}" | awk -F: '{print $1}')"
  dst_file="$(printf '%s' "${input}" | awk -F: '{print $2}')"

  if [ -z "${src_file}" ]; then
    say_err "Invalid source file: ${src_file}"
  fi

  if [ -z "${dst_file}" ]; then
    dst_file=".$(basename "${src_file}")"
  fi

  _sync_target="${_user_home}/${dst_file}"

  _check_system
  if [ -n "${_sync_platform}" ]; then
    if [ -s "${dosync_dir}/sync/${_sync_platform}/${src_file}" ]; then
      _sync_src="${dosync_dir}/sync/${_sync_platform}/${src_file}"
    else
      _sync_src="${dosync_dir}/sync/${src_file}"
    fi
  fi

  if [ ! -s "${_sync_src}" ]; then
    say_err "File ${_sync_src} doesn't exist, exiting"
  elif [ -d "${_sync_src}" ]; then
    _sync_src_dir="${_sync_src}"
  else
    _sync_src_dir="$(dirname "${_sync_src}")"
    if [ ! -d "${_sync_src_dir}" ]; then
      command mkdir -p "${_sync_src_dir}" || say_err "Failed to create directory ${_sync_src_dir}"
    fi
  fi
}

dosync() {
  _sync_config

  for file in ${_files_src}; do
    _read "${file}"
    if [ -e "${_sync_target}" ] && [ ! -h "${_sync_target}" ]; then
      [ ! -d "${_backup_dir}" ] && command mkdir -p "${_backup_dir}"
      _make_backup="${_backup_dir}/$(basename "${file}")"
      say_info "Backup: ${_sync_target} ➤ ${_make_backup}"
      command cp -r "${_sync_target}" "${_make_backup}"
      command rm -rf "${_sync_target}"
      command ln -s "${_sync_src}" "${_sync_target}"
      say_ok "SymLink: ${src_file} ➤ ${_sync_target}"
    elif [ ! -L "${_sync_target}" ]; then
      command ln -s "${_sync_src}" "${_sync_target}"
      say_ok "SymLink: ${src_file} ➤ ${_sync_target}"
    else
      say_ok "SymLink: ${src_file} ➤ ${_sync_target}"
    fi
    ${reset:-}
  done
}

_do_options() {
  [ -n "$1" ] && _arg_="$1" && shift

  [ "${_is_debug}" = true ] && set -x

  if [ "${_cmd_}" = sync ]; then
    [ -z "${_arg_}" ] && _arg_="run"
    case "${_arg_}" in
    create) _create_sync_location ;;
    run) dosync ;;
    *?) say_warn "Sync argument unknown: ${_arg_}" ;;
    *) ;;
    esac
  elif [ "${_cmd_}" = git ]; then
    [ -z "${_arg_}" ] && _arg_="sync"
    case "${_arg_}" in
    pull) _git_pull ;;
    add) _git_add ;;
    commit) _git_commit ;;
    push) _git_push ;;
    sync) _git_sync ;;
    cmd) command git "${_arg_}" ;;
    *?) say_warn "Git argument unknown: ${_arg_}" ;;
    *) ;;
    esac
  elif [ "${_cmd_}" = clean ]; then
    [ -z "${_arg_}" ] && _arg_="symlink"
    case "${_arg_}" in
    symlink) _remove_broken_links ;;
    *?) say_warn "Clean argument unknown: ${_arg_}" ;;
    *) ;;
    esac
  fi
}

# Main function
#
# Usage: $0 [options] [arguments]
#
# Options:
#   -q, --quiet     [quiet mode]
#   -s, --sync      [sync arguments]
#   -g, --git       [git arguments]
#   -c, --clean     [clean arguments]
#
# [sync arguments]:
#   create          Create sync location for files
#
# [git arguments]:
#   pull            Pull changes from remote
#   add             Add changes to git
#   commit          Commit changes
#   push            Push changes to remote
#   sync           Check if there are any changes
#
# [clean arguments]:
#   symlink         Remove broken symlinks

main() {
  unset _cmd_ _arg_ _is_quiet _is_debug
  # If no arguments are given, run sync by default
  [ $# -eq 0 ] && _cmd_=sync && _do_options run && exit 0

  if ! temp="$(getopt -o qdgcs: --long quiet,debug,git,clean,quiet -n "$0" -- "$@")"; then
    exit 1
  fi

  eval set -- "${temp}"
  while :; do
    case "${1}" in
    q) _is_quiet=true ;;
    d) _is_debug=true ;;
    g) _cmd_=git ;;
    c) _cmd_=clean ;;
    s) _cmd_=sync ;;
    --)
      shift
      break
      ;;
    *) exit 1 ;;
    esac
    shift $((OPTIND - 1))
    echo "${_cmd_}"
    _do_options "$@"
  done
  return $?
}

main "$@"
