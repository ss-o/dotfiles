#!/usr/bin/env sh
# -*- mode: sh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=sh sw=2 ts=2 et
# ============================================================================= #
trap '' INT QUIT TERM
# ============================================================================= #
# shellcheck source=/dev/null
dosync_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0" || true)")" && pwd -P)"
[ -z "${sync_dir}" ] && sync_dir=${dosync_dir}
_time_stamp=$(date +%D)

_user_home="${HOME}"
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
_is_tty="${_is_tty:-no}"
_is_piped="${_is_piped:-no}"
# ============================================================================== #
info_block() {
  printf "\033[1;46m"
  printf '%*s\n' "${COLUMNS:-$(tput cols || true)}" '' | tr ' ' ' '
  printf '%-*s\n' "${COLUMNS:-$(tput cols || true)}" "▓▒░ $1" | tr ' ' ' '
  printf '%*s' "${COLUMNS:-$(tput cols || true)}" '' | tr ' ' ' '
  printf "\e[0m"
  printf "\n"
}

note_block() {
  printf "\033[1;42m"
  printf '%*s\n' "${COLUMNS:-$(tput cols || true)}" '' | tr ' ' ' '
  printf '%-*s\n' "${COLUMNS:-$(tput cols || true)}" "▓▒░ $1" | tr ' ' ' '
  printf '%*s' "${COLUMNS:-$(tput cols || true)}" '' | tr ' ' ' '
  printf "\e[0m"
  printf "\n"
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
    printf "%s${col}"
    printf '%s' "$1"
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
  printf "\033[34;1m▓▒░\033[32;01m ✔ \033[00m» "
  say -green "$1"
  printf "\033[00m"
}

say_err() {
  printf "\033[34;01m▓▒░\033[31;01m ✘ \033[00m» "
  say -red "$1" >&2
  printf "\033[00m"
  exit 1
}

say_info() {
  printf "\033[34;1m▓▒░\033[32;01m ✔ \033[00m» "
  say -cyan "$1"
  printf "\033[00m"
}

say_log() {
  [ -d "${_backup_dir}" ] || mkdir -p "${_backup_dir}"
  say_info "$1 -- $(date)" | tee -a "${_logfile}" >/dev/null
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
    _current_os='Unknown'
    ;;
  esac
  say "$_supported_os" | grep -q "$_current_os"
  match=$?
  if [ $match -eq 0 ]; then
    say -n "${_current_os}"
    return 0
  else
    say_err "Unsupported OS: ${_current_os}"
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
    _current_arch='Unknown'
    ;;
  esac
  say "$_supported_cpu" | grep -q "$_current_arch"
  match=$?
  if [ $match -eq 0 ]; then
    say -n "${_current_arch}"
    return 0
  else
    say_err "Unsupported CPU: ${_current_arch}"
  fi
}

_is_git() { [ ! -d .git ] && say_err "Not a git repository"; }
_has_terminal() { [ -t 0 ]; }
_is_tty() { _has_terminal; }
_is_piped() { ! [ -t 1 ]; }
_is_root() { [ "$(id -u)" -eq 0 ]; }

_check_commands() {
  for cdps in ${_required_cmds}; do
    command -v "${cdps}" >/dev/null 2>&1 || {
      say_err "Required: ${cdps}"
    }
  done
}

_remove_broken_links() {
  find "${_user_home}" -maxdepth 2 -name ".*" -type l | while read -r f1; do
    if [ -L "$f1" ] && ! [ -e "$f1" ]; then
      command rm -f "${f1}" && say_info "Removed dangling symlink: ${f1}"
    fi
  done
  find "${_user_home_config}" -maxdepth 2 -name "*" -type l | while read -r f2; do
    if [ -L "$f2" ] && ! [ -e "$f2" ]; then
      command rm -f "${f2}" && say_info "Removed dangling symlink: ${f2}"
    fi
  done
}

_init_local() {
  builtin cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  _is_git
  builtin cd || return 1
}

_git_origin() {
  builtin cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  if [ -d .git ]; then
    ORIGIN=$(git config -l | grep remote.origin.url | awk -F'=' '{print $2}') || true
  fi
  builtin cd || return 1
}

_git_pull() {
  _git_origin
  builtin cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  _is_git
  say -cyan "Pulling latest changes from ${ORIGIN}"
  command git pull "${_git_opt}"
  say -cyan "Pulling latest changes for submodules"
  # Required if a submodule origin changed
  command git submodule "${_git_sub_opt}" sync
  command git submodule "${_git_sub_opt}" update --init --recursive
  command git submodule "${_git_sub_opt}" update --remote --merge
  command git submodule "${_git_sub_opt}" foreach --recursive git fetch
  builtin cd || return 1
}

_git_commit() {
  _git_origin
  builtin cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  say -cyan "Committing latest changes to the repository"
  command git commit -a "${_git_opt}"
  builtin cd || return 1
}

_git_push() {
  _git_origin
  builtin cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  say -cyan "Pushing changes upstream to ${ORIGIN}"
  command git push "${_git_opt}"
  say -cyan "Pushing changes for submodules"
  command git push "${_git_sub_opt}" --recurse-submodules=on-demand
  command git submodule "${_git_sub_opt}" foreach --recursive git push
  builtin cd || return 1
}

_git_add() {
  builtin cd "${dosync_dir}" || say_err "Failed to enter dotfiles directory"
  command git add .
  builtin cd || return 1
}

_git_check_all() {
  _git_origin
  _git_add
  _git_commit
  _git_push
}

_sync_config() {
  if [ ! -s "${_sync_file}" ]; then
    if [ -s "${dosync_dir}/sync.config" ]; then
      _sync_file="${dosync_dir}/sync.config"
    else
      say_err "File ${dosync_dir}/sync.config doesn't exist, exiting"
    fi
  fi
}

_read_sync_config() {
  _files_src="$(sed -n '/\[files\]/,/\[endfiles\]/p' "${_sync_file}" | grep -v '^\[.*files]' | grep -v '^#')"
  _config_src="$(sed -n '/\[config\]/,/\[endconfig\]/p' "${_sync_file}" | grep -v '^\[.*config]' | grep -v '^#')"
  if [ -z "${_files_src}" ] && [ -z "${_config_src}" ]; then
    say_err "Specify files to sync in ${dosync_dir}/sync.config file"
  fi
}

_read() {
  srcfile="$(echo "${file}" | awk -F: '{print $1}')"
  dstfile="$(echo "${file}" | awk -F: '{print $2}')"
  srcconfig="$(echo "${configfile}" | awk -F: '{print $1}')"
  dstconfig="$(echo "${configfile}" | awk -F: '{print $2}')"

  [ "${dstfile}" = "" ] && dstfile=".$(basename "${srcfile}")"
  [ "${dstconfig}" = "" ] && dstconfig="$(basename "${srcconfig}")"

  _sync_src="${dosync_dir}/${srcfile}"
  _sync_config_src="${dosync_dir}/${srcconfig}"

  if [ -e "${_sync_src}" ]; then
    _sync_target="${_user_home}/${dstfile}"
  else
    _sync_target=""
  fi

  if [ -e "${_sync_config_src}" ]; then
    _sync_config_target="${_user_home_config}/${dstconfig}"
  else
    _sync_config_target=""
  fi
}

dosync() {
  _init_local
  _sync_config
  _read_sync_config
  _remove_broken_links
  for file in ${_files_src}; do
    _read "${file}"
    if [ -e "${_sync_target}" ] && ! [ -L "${_sync_target}" ]; then
      [ ! -d "${_backup_dir}" ] && command mkdir -p "${_backup_dir}"
      _make_backup="${_backup_dir}/$(basename "${file}")"
      say_log "Backup: ${_sync_target} -> ${_make_backup}"
      command cp -r "${_sync_target}" "${_make_backup}"
      command rm -rf "${_sync_target}"
      command ln -si "${_sync_src}" "${_sync_target}"
      say_ok "SymLink: ${_sync_src} -> ${_sync_target}"
    elif [ -e "${_sync_target}" ]; then
      command rm -f "${_sync_target}"
      command ln -si "${_sync_src}" "${_sync_target}"
      say_ok "SymLink: ${srcfile} ➤ ${_sync_target}"
    elif [ "${_sync_target}" != "" ]; then
      command ln -si "${_sync_src}" "${_sync_target}"
      say_ok "SymLink:${_sync_src} -> ${_sync_target}"
    else
      say_log "Source file ${_sync_config_src} doesn't exist, skipping"
    fi
    ${reset:-}
  done
  for configfile in ${_config_src}; do
    _read "${configfile}"
    if [ -e "${_sync_config_target}" ] && ! [ -L "${_sync_config_target}" ]; then
      [ ! -d "${_backup_dir}" ] && command mkdir -p "${_backup_dir}"
      _make_backup="${_backup_dir}/$(basename "${configfile}")"
      say_log "Backup: ${_sync_config_target} -> ${_make_backup}"
      command cp -r "${_sync_config_target}" "${_make_backup}"
      command rm -rf "${_sync_config_target}"
      command ln -si "${_sync_config_src}" "${_sync_config_target}"
      say_ok "SymLink:${srcconfig} ➤ ➤ ${_sync_config_target}"
    elif [ -e "${_sync_config_target}" ]; then
      command rm -f "${_sync_config_target}"
      command ln -si "${_sync_config_src}" "${_sync_config_target}"
      say_ok "SymLink: ${_sync_config_src} -> ${_sync_config_target}"
    elif [ "${_sync_config_target}" != "" ]; then
      command ln -si "${_sync_config_src}" "${_sync_config_target}"
      say_ok "SymLink: ${_sync_config_src} -> ${_sync_config_target}"
    else
      say_log "Source file ${_sync_config_src} doesn't exist, skipping"
    fi
    ${reset:-}
  done
}

_do_options() {
  [ $# = 0 ] && dosync
  while [ $# -gt 0 ]; do
    case $1 in
    -cu | --get-cpu) _get_arch ;;
    -os | --get-os) _get_os ;;
    -pl | --pull) _git_pull ;;
    -ga | --add) _git_add ;;
    -gc | --commit) _git_commit ;;
    -gp | --push) _git_push ;;
    -aa | --all) _git_check_all ;;
    -bl | --broken-links) _remove_broken_links ;;
    -cc | --check-commands) _check_commands "${@}" ;;
    *)
      say_err "Unknown option."
      ;;
    esac
    shift
  done
}

main() {
  _do_options "${@}"
  exit 0
}
while true; do
  main "${@}"
done
