#!/usr/bin/env sh
# -*- mode: sh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=sh sw=2 ts=2 et
# ============================================================================= #
trap '' INT QUIT TERM
# ============================================================================= #
# shellcheck source=/dev/null
dosync_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0" || true)")" && pwd -P)"
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
  if [ "${_is_quiet}" = "true" ]; then
    return 0
  fi
  printf '\033[1;46m%-*s\033[0m\n' "${COLUMNS:-$(tput cols || true)}" "▓▒░ ★ » $1" | tr ' ' ' '
}

note_block() {
  # Don't print anything if we're in quiet mode
  if [ "${_is_quiet}" = "true" ]; then
    return 0
  fi
  printf '\033[1;42m%-*s\033[0m\n' "${COLUMNS:-$(tput cols || true)}" "▓▒░ ★ » $1" | tr ' ' ' '
}

say() {
  while [ -n "$1" ]; do
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
      printf '%s' "$1"
      shift
      continue
      ;;
    esac
    shift
    printf "${col}%s" "$1"
    printf "\033[00m"
    shift
  done
  [ -z "${one_line}" ] && printf "\n"
}

err() {
  say -red "$1" >&2
  exit 1
}

say_ok() {
  # Don't print anything if we're in quiet mode
  if [ "${_is_quiet}" = "true" ]; then
    return 0
  fi

  printf "\033[34;1m▓▒░\033[32;01m ✔ \033[00m» "
  say -green "$1"
  printf "\033[00m"
}

say_info() {
  # Don't print anything if we're in quiet mode
  if [ "${_is_quiet}" = "true" ]; then
    return 0
  fi

  printf "\033[34;1m▓▒░\033[35;01m ❢ \033[00m» "
  say -magenta "$1"
  printf "\033[00m"
  return 0
}

say_warn() {
  # Don't print anything if we're in quiet mode
  if [ "${_is_quiet}" = "true" ]; then
    return 0
  fi

  printf "\033[34;1m▓▒░\033[33;01m ❢ \033[00m» "
  say -yellow "$1"
  printf "\033[00m"
  return 1
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
  android*)
    _current_os='android'
    ;;
  darwin*)
    _current_os='darwin'
    ;;
  linux*)
    _current_os='linux'
    ;;
  freebsd*)
    _current_os='freebsd'
    ;;
  netbsd*)
    _current_os='netbsd'
    ;;
  openbsd*)
    _current_os='openbsd'
    ;;
  sunos*)
    _current_os='solaris'
    ;;
  msys* | cygwin* | mingw*)
    _current_os='windows'
    ;;
  nt | win*)
    _current_os='windows'
    ;;
  *)
    _current_os='unknown'
    ;;
  esac
  say "${_supported_os}" | grep -q "${_current_os}"
  match=$?
  if [ "${match}" -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

_get_arch() {
  _current_arch="$(command -v uname)"
  case $("${_current_arch}" -m | tr '[:upper:]' '[:lower:]') in
  x86_64 | amd64)
    _current_arch='x86_64'
    ;;
  i?86 | x86)
    _current_arch='386'
    ;;
  armv8* | aarch64 | arm64)
    _current_arch='aarch64'
    ;;
  *)
    _current_arch='unknown'
    ;;
  esac
  say "${_supported_cpu}" | grep -q "${_current_arch}"
  match=$?
  if [ "${match}" -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

_is_git() { [ ! -d .git ] && say_err "Not a git repository"; }
_has_terminal() { [ -t 0 ]; }
_is_tty() { _has_terminal; }
_is_piped() { [ ! -t 1 ]; }
_is_root() { [ "$(id -u || true)" -eq 0 ]; }

_check_deps() {
  for deps in ${_required_cmds}; do
    command -v "${deps}" >/dev/null 2>&1 || {
      say_err "Required: ${deps}"
    }
  done
}

_check_system() {
  _get_os || say_err "Unsupported OS: ${_current_os}"
  _get_arch || say_err "Unsupported CPU: ${_current_arch}"

  _sync_platform="${_current_os}/${_current_arch}"

  return 0
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
  return 0
}

_init_local() {
  command cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  _is_git
  command cd || return 1
}

_git_origin() {
  command cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  if [ -d .git ]; then
    ORIGIN=$(git config -l | grep remote.origin.url | awk -F'=' '{print $2}') || true
  fi
  command cd || return 1
}

_git_pull() {
  _git_origin
  command cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  _is_git
  say -cyan "Pulling latest changes from ${ORIGIN}"
  command git pull "${_git_opt}"
  say -cyan "Pulling latest changes for submodules"
  # Required if a submodule origin changed
  command git submodule "${_git_sub_opt}" sync
  command git submodule "${_git_sub_opt}" update --init --recursive
  command git submodule "${_git_sub_opt}" update --remote --merge
  command git submodule "${_git_sub_opt}" foreach --recursive git fetch
  command cd || return 1
}

_git_commit() {
  _git_origin
  command cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  say -cyan "Committing latest changes to the repository"
  command git commit -a "${_git_opt}"
  command cd || return 1
}

_git_push() {
  _git_origin
  command cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  say -cyan "Pushing changes upstream to ${ORIGIN}"
  command git push "${_git_opt}"
  say -cyan "Pushing changes for submodules"
  command git push "${_git_sub_opt}" --recurse-submodules=on-demand
  command git submodule "${_git_sub_opt}" foreach --recursive git push
  command cd || return 1
}

_git_add() {
  command cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  command git add .
  command cd || return 1
}

_git_check_all() {
  _git_origin
  _git_add
  _git_commit
  _git_push
}

_create_sync_location() {
  if [ -n "${_current_os}" ] && [ -n "${_current_arch}" ]; then

    _sync_location="${dosync_dir}/sync/${_sync_platform}"
    if [ ! -d "${_sync_location}" ]; then
      command mkdir -p "${_sync_location}" || say_err "Failed to create sync location"
    else
      say_ok "Location already exists: ${_sync_location}"
    fi
  fi

  return 0
}

_sync_config() {
  if [ ! -s "${_sync_file}" ]; then
    if [ -s "${dosync_dir}/sync.config" ]; then
      _sync_file="${dosync_dir}/sync.config"
    else
      say_err "File ${dosync_dir}/sync.config doesn't exist, exiting"
    fi
  fi

  _files_src="$(sed -n '/\[files\]/,/\[endfiles\]/p' "${_sync_file}" | grep -v '^\[.*files]' | grep -v '^#' | grep -v '^$' | sort -u)"
  _config_src="$(sed -n '/\[config\]/,/\[endconfig\]/p' "${_sync_file}" | grep -v '^\[.*config]' | grep -v '^#' | grep -v '^$' | sort -u)"
  if [ -z "${_files_src}" ] && [ -z "${_config_src}" ]; then
    say_err "Specify files to sync in ${dosync_dir}/sync.config file"
  fi
}

_read() {
  input="$1"
  srcfile="$(printf '%s' "${input}" | awk -F: '{print $1}')"
  dstfile="$(printf '%s' "${input}" | awk -F: '{print $2}')"

  [ -z "${dstfile}" ] && dstfile=".$(basename "${srcfile}")"
  [ -z "${dstconfig}" ] && dstconfig="$(basename "${srcfile}")"

  _sync_platform="${_current_os}/${_current_arch}"

  if [ -s "${dosync_dir}/sync/${_sync_platform}/${srcfile}" ]; then
    _sync_src="${dosync_dir}/sync/${_sync_platform}/${srcfile}"
  else
    _sync_src="${dosync_dir}/sync/${srcfile}"
  fi

  _sync_src_dir=$(dirname "${_sync_src}")
  _sync_config_src="${dosync_dir}/sync/${srcfile}"
  _sync_config_src_dir=$(dirname "${_sync_config_src}")
  _sync_target="${_user_home}/${dstfile}"
  _sync_config_target="${_user_home_config}/${dstfile}"
}

dosync() {
  _init_local
  _sync_config

  if [ -n "${_current_os}" ] && [ -n "${_current_arch}" ]; then
    note_block "Platform: ${_current_os}/${_current_arch}"
  fi

  for file in ${_files_src}; do
    _read "${file}"
    if [ -e "${_sync_target}" ] && [ ! -h "${_sync_target}" ]; then
      [ ! -d "${_backup_dir}" ] && command mkdir -p "${_backup_dir}"
      _make_backup="${_backup_dir}/$(basename "${file}")"
      say_info "Backup: ${_sync_target} ➤ ${_make_backup}"
      command cp -r "${_sync_target}" "${_make_backup}"
      command rm -rf "${_sync_target}"
      command ln -s "${_sync_src}" "${_sync_target}"
      say_ok "SymLink: ${srcfile} ➤ ${_sync_target}"
    elif [ -e "${_sync_target}" ]; then
      command rm -f "${_sync_target}"
      command ln -s "${_sync_src}" "${_sync_target}"
      say_ok "SymLink: ${srcfile} ➤ ${_sync_target}"
    else
      command mkdir -p "${_sync_src_dir}"
      command ln -s "${_sync_src}" "${_sync_target}"
      say_ok "SymLink: ${srcfile} ➤ ${_sync_target}"
    fi
    ${reset:-}
  done

  for configfile in ${_config_src}; do
    _read "${configfile}"
    if [ -e "${_sync_config_target}" ] && [ ! -h "${_sync_config_target}" ]; then
      [ ! -d "${_backup_dir}" ] && command mkdir -p "${_backup_dir}"
      _make_backup="${_backup_dir}/$(basename "${configfile}")"
      say_log "Backup: ${_sync_config_target} ➤ ${_make_backup}"
      command cp -r "${_sync_config_target}" "${_make_backup}"
      command rm -rf "${_sync_config_target}"
      command ln -s "${_sync_config_src}" "${_sync_config_target}"
      say_ok "SymLink:${srcfile} ➤ ${_sync_config_target}"
    elif [ -e "${_sync_config_target}" ]; then
      command rm -f "${_sync_config_target}"
      command ln -s "${_sync_config_src}" "${_sync_config_target}"
      say_ok "SymLink: ${_sync_config_src} ➤ ${_sync_config_target}"
    else
      command mkdir -p "${_sync_config_src_dir}"
      command ln -s "${_sync_config_src}" "${_sync_config_target}"
      say_ok "SymLink: ${_sync_config_src} ➤ ${_sync_config_target}"
    fi
    ${reset:-}
  done
}

_do_options() {
  _check_system
  [ -n "$1" ] && arg="$1" && shift

  if [ "${_cmd_sync}" = true ]; then
    case "${arg}" in
    create) _create_sync_location ;;
    *?) say_warn "Bad argument for sync: ${arg}" ;;
    *) dosync ;;
    esac
  fi

  if [ "${_cmd_git}" = true ]; then
    case "${arg}" in
    pull) _git_pull ;;
    add) _git_add ;;
    commit) _git_commit ;;
    push) _git_push ;;
    check) _git_check_all ;;
    *?) say_warn "Git argument unknown: ${arg}" ;;
    *) say_warn "Git missing argument" ;;
    esac
  fi
  if [ "${_cmd_clean}" = true ]; then
    case "${arg}" in
    symlink) _remove_broken_links ;;
    *?) say_warn "Clean argument unknown: ${arg}" ;;
    *) _remove_broken_links ;;
    esac
  fi

  return 0
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
#   check           Check if there are any changes
#
# [clean arguments]:
#   symlink         Remove broken symlinks

main() {
  # If no arguments are given, run sync by default
  [ $# -eq 0 ] && _cmd_sync=true

  # Parse options
  optspec=":qcsg-:"
  while getopts "${optspec}" optchar; do
    case "${optchar}" in
    # Short options
    q) _is_quiet=true ;;
    g) _cmd_git=true ;;
    c) _cmd_clean=true ;;
    s) _cmd_sync=true ;;
    -)
      case "${OPTARG}" in
      # Long options
      quiet) _is_quiet=true ;;
      git) _cmd_git=true ;;
      clean) _cmd_clean=true ;;
      sync) _cmd_sync=true ;;
      *) say_warn "Unknown option: --${OPTARG}" ;;
      esac
      ;;
    *) say_warn "Unknown option: -${OPTARG}" ;;
    esac
  done
  shift $((OPTIND - 1))

  _do_options "$@"

  return $?
}

main "$@"
