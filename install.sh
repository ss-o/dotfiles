#!/usr/bin/env bash
# -*- mode: sh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=sh sw=2 ts=2 et
# shellcheck disable=SC2317 # Unreachable code for defensive programming
# ----------------------------------------------------------------------------
# cleanup: Perform cleanup operations before script exit
#
# Arguments: None
# Returns: 0
# ----------------------------------------------------------------------------
cleanup() {
  # Cleanup temporary files and restore state if needed
  say_info "Cleaning up..."
  return 0
}

trap 'cleanup' INT QUIT TERM

# ----------------------------------------------------------------------------
# handle_error: Enhanced error handling with detailed reporting and logging
#
# Arguments:
#   $1 - Error message to display
#   $2 - Command that failed
#   $3 - Line number where error occurred
# Returns: Exits script with error code or returns error code if continuing
# ----------------------------------------------------------------------------
handle_error() {
  _exit_code=$?
  _error_msg="$1"
  _error_cmd="$2"
  _error_line="$3"

  say_err "Error: ${_error_msg} (command: ${_error_cmd}, line: ${_error_line}, exit code: ${_exit_code})"
  # Optionally log to file
  say_log "ERROR: ${_error_msg} (command: ${_error_cmd}, line: ${_error_line}, exit code: ${_exit_code})" >>"${_logfile}"

  # Option to continue despite errors
  if [[ ${_continue_on_error:-false} == "true" ]]; then
    say_warn "Continuing despite error..."
    return "${_exit_code}"
  else
    return "${_exit_code}"
  fi
}

# ============================================================================= #
# shellcheck source=/dev/null
dosync_dir="$(command cd -P -- "$(dirname -- "$(command -v -- "$0" || true)")" && pwd -P)"
[[ -z ${sync_dir} ]] && sync_dir=${dosync_dir}
[[ -z ${_user_home} ]] && _user_home="${HOME}"

_time_stamp=$(date +%Y-%m-%d_%H-%M-%S)
_backup_dir="${_user_home}/.backup/${_time_stamp}"
_logfile="${_user_home}/.backup/${_time_stamp}/install.log"
_user_home_config="${_user_home}/.config"
_sync_file="${sync_dir}/sync.config"

# Settings
_git_opt="-q"
_git_sub="-q"
_git_sub_opt="-q"
_required_cmds="zsh git grep find ln mkdir"
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
  [[ ${_is_quiet} == "true" ]] && return 0
  printf '\033[1;46m%-*s\033[0m\n' "${COLUMNS:-$(tput cols || true)}" "▓▒░ ★ » $1" | tr ' ' ' '
  return 0
}

note_block() {
  # Don't print anything if we're in quiet mode
  [[ ${_is_quiet} == "true" ]] && return 0
  printf '\033[1;42m%-*s\033[0m\n' "${COLUMNS:-$(tput cols || true)}" "▓▒░ ★ » $1" | tr ' ' ' '
  return 0
}

say() {
  while [[ -n $1 ]]; do
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
  [[ ${one_line} == 1 ]] || printf "\n"
}

err() {
  say -red "$1" >&2
  return 1
}

say_ok() {
  # Don't print anything if we're in quiet mode
  [[ ${_is_quiet} == "true" ]] && return 0

  printf "\033[34;1m▓▒░\033[32;01m ✔ \033[00m» "
  say -green "$1"
  printf "\033[00m"
  return 0
}

say_info() {
  # Don't print anything if we're in quiet mode
  [[ ${_is_quiet} == "true" ]] && return 0

  printf "\033[34;1m▓▒░\033[35;01m ❢ \033[00m» "
  say -magenta "$1"
  printf "\033[00m"
  return 0
}

say_warn() {
  # Don't print anything if we're in quiet mode
  [[ ${_is_quiet} == "true" ]] && return 0

  printf "\033[34;1m▓▒░\033[33;01m ❢ \033[00m» "
  say -yellow "$1"
  printf "\033[00m"
  return 0
}

say_err() {
  printf "\033[34;01m▓▒░\033[31;01m ✘ \033[00m» "
  say -red "$1" >&2
  printf "\033[00m"
  return 1
}

# ----------------------------------------------------------------------------
# say_log: Log a message to the logfile with timestamp
#
# Arguments:
#   $1 - Message to log
# Returns: 0 on success
# ----------------------------------------------------------------------------
say_log() {
  ensure_dir "${_backup_dir}"
  say_info "$1 -- $(date || true)" | command tee -a "${_logfile}" >/dev/null
}

# ----------------------------------------------------------------------------
# ensure_dir: Create directory if it doesn't exist
#
# Arguments:
#   $1 - Directory path to create
# Returns: 0 on success, exits on failure
# ----------------------------------------------------------------------------
ensure_dir() {
  if [[ ! -d $1 ]]; then
    command mkdir -p "$1" || say_err "Failed to create directory: $1"
    say_info "Created directory: $1"
  fi
  return 0
}

# ----------------------------------------------------------------------------
# ensure_file: Create file if it doesn't exist, ensuring parent dir exists
#
# Arguments:
#   $1 - File path to create
# Returns: 0 on success, exits on failure
# ----------------------------------------------------------------------------
ensure_file() {
  if [[ ! -f $1 ]]; then
    ensure_dir "$(dirname "$1")"
    command touch "$1" || say_err "Failed to create file: $1"
    say_info "Created file: $1"
  fi
  return 0
}

# ----------------------------------------------------------------------------
# _get_os: Detect the current operating system
#
# Arguments: None
# Returns: 0 if supported OS, 1 otherwise
# ----------------------------------------------------------------------------
_get_os() {
  _current_os=$(uname | tr '[:upper:]' '[:lower:]')
  case "${_current_os}" in
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

# ----------------------------------------------------------------------------
# _get_arch: Detect the current CPU architecture
#
# Arguments: None
# Returns: 0 if supported architecture, 1 otherwise
# ----------------------------------------------------------------------------
_get_arch() {
  _current_arch=$(uname -m | tr '[:upper:]' '[:lower:]')
  case "${_current_arch}" in
  x86_64 | amd64) _current_arch='x86_64' ;;
  i?86 | x86) _current_arch='386' ;;
  armv8* | aarch64 | arm64) _current_arch='aarch64' ;;
  *) _current_arch='unknown' ;;
  esac
  say "${_supported_cpu}" | command grep -q "${_current_arch}"
  return $?
}

# ----------------------------------------------------------------------------
# _go_to: Change to specified directory
#
# Arguments:
#   $1 - Directory path
# Returns: Exits script on failure
# ----------------------------------------------------------------------------
_go_to() { command cd "$1" || say_err "Failed to enter directory %s."; }

# ----------------------------------------------------------------------------
# _go_back: Return to previous directory
#
# Arguments: None
# Returns: Exits script on failure
# ----------------------------------------------------------------------------
_go_back() { command cd "${OLDPWD}" || say_err "Failed return to previous directory."; }

# ----------------------------------------------------------------------------
# _check_git: Verify current directory is a git repository and has origin
#
# Arguments: None
# Returns: 0 on success, exits on critical failure
# ----------------------------------------------------------------------------
_check_git() {
  if [[ ! -d .git ]]; then
    say_err "Not a git repository"
  else
    ORIGIN=$(command git config -l | command grep -i remote.origin.url | awk -F'=' '{print $2}')
    [[ -z ${ORIGIN} ]] && say_err "No git origin found"
  fi
  return 0
}

# ----------------------------------------------------------------------------
# _has_terminal: Check if stdin is connected to a terminal
#
# Arguments: None
# Returns: 0 if stdin is a terminal, 1 otherwise
# ----------------------------------------------------------------------------
_has_terminal() { [[ -t 0 ]]; }

# ----------------------------------------------------------------------------
# _is_tty: Alias for _has_terminal
#
# Arguments: None
# Returns: 0 if stdin is a terminal, 1 otherwise
# ----------------------------------------------------------------------------
_is_tty() { _has_terminal; }

# ----------------------------------------------------------------------------
# _is_piped: Check if stdout is piped
#
# Arguments: None
# Returns: 0 if stdout is piped, 1 otherwise
# ----------------------------------------------------------------------------
_is_piped() { [[ ! -t 1 ]]; }

# ----------------------------------------------------------------------------
# _is_root: Check if the script is running as root
#
# Arguments: None
# Returns: 0 if user is root, 1 otherwise
# ----------------------------------------------------------------------------
_is_root() { [[ "$(id -u || true)" -eq 0 ]]; }

# ----------------------------------------------------------------------------
# _check_deps: Verify all required dependencies are available
#
# Arguments: None
# Returns: 0 on success, exits on missing dependency
# ----------------------------------------------------------------------------
_check_deps() {
  for deps in ${_required_cmds}; do
    command -v "${deps}" >/dev/null 2>&1 || {
      say_err "Missing required dependency: ${deps}"
    }
  done
  return 0
}

# ----------------------------------------------------------------------------
# _check_system: Verify OS and architecture compatibility
#
# Arguments: None
# Returns: 0 on success, exits on unsupported system
# ----------------------------------------------------------------------------
_check_system() {
  _get_os || say_err "Unsupported OS: ${_current_os}"
  _get_arch || say_err "Unsupported CPU: ${_current_arch}"

  _sync_platform="${_current_os}/${_current_arch}"
  return 0
}

# ----------------------------------------------------------------------------
# _remove_broken_links: Find and delete broken symbolic links
#
# Arguments: None
# Returns: Exit code of the last find command
# ----------------------------------------------------------------------------
_remove_broken_links() {
  say_info "Checking for hidden dangling symlinks with depth 1 in ${_user_home}"
  command find "${_user_home}" -maxdepth 1 \( -name "*" -o -name ".*" \) -type l | while read -r f1; do
    if [[ -L ${f1} ]] && [[ ! -e ${f1} ]]; then
      command rm -f "${f1}" && say_info "Removed dangling symlink: ${f1}"
    fi
  done

  say_info "Checking for all dangling symlinks with depth 2 in ${_user_home_config}"
  command find "${_user_home_config}" -maxdepth 2 \( -name "*" -o -name ".*" \) -type l | while read -r f2; do
    if [[ -L ${f2} ]] && [[ ! -e ${f2} ]]; then
      command rm -f "${f2}" && say_info "Removed dangling symlink: ${f2}"
    fi
  done
  return $?
}

# ----------------------------------------------------------------------------
# _git_commit: Commit changes to the repository and submodules
#
# Arguments: None
# Returns: Exit code from git operations
# ----------------------------------------------------------------------------
_git_commit() {
  _go_to "${dosync_dir}" && _check_git
  say -cyan "Committing latest changes to the repository"
  git commit -a "${_git_opt}" -m "Sync on $(date || true)"
  if [[ -f .gitmodules ]]; then
    say -cyan "Committing latest changes for submodules"
    git submodule "${_git_sub_opt}" foreach --recursive git commit -a "${_git_opt}" -m "Sync on $(date || true)"
  fi
  _go_back
  return $?
}

# ----------------------------------------------------------------------------
# _git_push: Push changes to remote repositories
#
# Arguments: None
# Returns: Exit code from git operations
# ----------------------------------------------------------------------------
_git_push() {
  _go_to "${dosync_dir}" && _check_git
  say -cyan "Pushing changes upstream to ${ORIGIN}"
  git push "${_git_opt}"
  if [[ -f .gitmodules ]]; then
    say -cyan "Pushing changes for submodules"
    git push "${_git_sub_opt}" --recurse-submodules=on-demand
    git submodule "${_git_sub_opt}" foreach --recursive git push
  fi
  _go_back
  return $?
}

# ----------------------------------------------------------------------------
# _git_add: Add all changes to git staging
#
# Arguments: None
# Returns: Exit code from git operations
# ----------------------------------------------------------------------------
_git_add() {
  _check_git && _go_to "${dosync_dir}" && git add -A && git status -s
  if [[ -f .gitmodules ]]; then
    say -cyan "Adding changes for submodules"
    git submodule "${_git_sub_opt}" foreach --recursive git add -A
    git submodule "${_git_sub_opt}" foreach --recursive git status -s
  fi

  return $?
}

# ----------------------------------------------------------------------------
# _git_sync: Complete git synchronization (add, commit, push, pull)
#
# Arguments: None
# Returns: Exit code from git operations (fails if any step fails)
# ----------------------------------------------------------------------------
_git_sync() {
  _git_add && _git_commit && _git_push && _git_pull
  return $?
}

# ----------------------------------------------------------------------------
# _create_sync_location: Create platform-specific sync directory
#
# Arguments: None
# Returns: 0 on success, 1 if system detection fails
# ----------------------------------------------------------------------------
_create_sync_location() {
  _check_system
  if [[ -n ${_current_os} ]] && [[ -n ${_current_arch} ]]; then
    _sync_location="${dosync_dir}/sync/${_sync_platform}"
    if [[ ! -d ${_sync_location} ]]; then
      ensure_dir "${_sync_location}" || say_err "Failed to create sync location"
      say_ok "Created sync location: ${_sync_location}"
      return 0
    else
      say_ok "Location already exists: ${_sync_location}"
      return 0
    fi
  fi
  return 1
}

# ----------------------------------------------------------------------------
# _parse_config: Parse configuration file for files to sync
#
# Arguments: None
# Returns: None, sets _files_src global variable
# ----------------------------------------------------------------------------
_parse_config() {
  _files_src="$(sed -n '/^\[files\]/,/^\[/p' "${_sync_file}" | grep -v '^\[' | grep -v '^#' | grep -v '^$' | sort -u)"
}

# ----------------------------------------------------------------------------
# _sync_config: Configure synchronization based on config file
#
# Arguments: None
# Returns: 0 on success, exits on failure
# ----------------------------------------------------------------------------
_sync_config() {
  _parse_config
  if [[ -z ${_files_src} ]]; then
    say_err "No files to sync found in ${_sync_file}"
  fi

  return 0
}

# ----------------------------------------------------------------------------
# _read: Parse file entry from configuration
#
# Arguments:
#   $1 - File specification in format "source:destination"
# Returns: None, sets multiple global variables
# ----------------------------------------------------------------------------
_read() {
  input="$1"
  shift
  src_file="${input%%:*}"
  dst_file="${input#*:}"
  [[ ${src_file} == "${input}" ]] && dst_file="" # No colon found

  if [[ -z ${src_file} ]]; then
    say_err "Invalid source file: ${src_file}"
  fi

  if [[ -z ${dst_file} ]]; then
    dst_file=".$(basename "${src_file}")"
  fi

  _sync_target="${_user_home}/${dst_file}"

  _check_system
  if [[ -n ${_sync_platform} ]]; then
    if [[ -s "${dosync_dir}/sync/${_sync_platform}/${src_file}" ]]; then
      _sync_src="${dosync_dir}/sync/${_sync_platform}/${src_file}"
    else
      _sync_src="${dosync_dir}/sync/${src_file}"
    fi
  fi

  if [[ ! -s ${_sync_src} ]]; then
    say_err "File ${_sync_src} doesn't exist, exiting"
  elif [[ -d ${_sync_src} ]]; then
    _sync_src_dir="${_sync_src}"
  else
    _sync_src_dir="$(dirname "${_sync_src}")"
    ensure_dir "${_sync_src_dir}" || say_err "Failed to create directory ${_sync_src_dir}"
  fi
}

# ----------------------------------------------------------------------------
# _show_progress: Display progress bar for sync operations
#
# Arguments:
#   $1 - Current item number
#   $2 - Total number of items
# Returns: None
# ----------------------------------------------------------------------------
_show_progress() {
  # Only show progress if not in quiet mode and connected to a terminal
  if [[ ${_is_quiet} == "false" ]] && [[ -t 1 ]]; then
    _current=$1
    _total=$2
    _percent=$(((_current * 100) / _total))
    _progress=$((_percent / 2))

    printf "\r[%-50s] %d%%" "$(printf '%0.s#' $(seq 1 "${_progress}"))" "${_percent}"
    [[ ${_current} -eq ${_total} ]] && printf "\n"
  fi
}

# ----------------------------------------------------------------------------
# _safe_operation: Execute command safely with error handling and dry run support
#
# Arguments: Command to execute and its arguments
# Returns: 0 on success or dry run, calls handle_error on failure
# ----------------------------------------------------------------------------
_safe_operation() {
  if [[ ${_is_dry_run:-false} == "true" ]]; then
    say_info "[DRY RUN] Would execute: $*"
    return 0
  else
    "$@" || handle_error "Operation failed" "$*" "${LINENO}"
    return $?
  fi
}

# ----------------------------------------------------------------------------
# _perform_sync: Core function to synchronize a list of files
#
# Arguments:
#   $1 - Multiline string of files to synchronize in source:dest format
# Returns: 0 on success, 1 if no files to sync
# ----------------------------------------------------------------------------
_perform_sync() {
  # Input is the list of files to sync
  _files_to_sync="$1"

  # Early return if no files to sync
  if [[ -z ${_files_to_sync} ]]; then
    say_warn "No files to synchronize"
    return 1
  fi

  # Calculate total files for progress display
  _total_files=$(echo "${_files_to_sync}" | wc -l)
  _current_file=0

  # Process each file
  printf '%s\n' "${_files_to_sync}" | while IFS= read -r file; do
    _current_file=$((_current_file + 1))
    #_show_progress "${_current_file}" "${_total_files}"
    _read "${file}"

    if [[ -L ${_sync_target} ]]; then
      # Verify if symlink points to correct destination
      _current_link=$(readlink "${_sync_target}")
      if [[ ${_current_link} == "${_sync_src}" ]]; then
        say_ok "SymLink: ${src_file} ➤ ${_sync_target} (already exists)"
      else
        say_warn "Invalid symlink at ${_sync_target}, recreating..."
        # Only back up if symlink target exists and isn't the same as our source
        if [[ -e ${_current_link} ]] && ! cmp -s "${_current_link}" "${_sync_src}"; then
          _make_backup="${_backup_dir}/${dst_file}"
          ensure_dir "$(dirname "${_make_backup}")"
          command cp -r "${_current_link}" "${_make_backup}" &&
            say_info "Backup: ${_current_link} ➤ ${_make_backup}"
        fi
        _safe_operation command rm -f "${_sync_target}" ||
          handle_error "Failed to remove existing target" "rm -f ${_sync_target}" "${LINENO}"
        _safe_operation command ln -s "${_sync_src}" "${_sync_target}" ||
          handle_error "Failed to create symlink" "ln -s ${_sync_src} ${_sync_target}" "${LINENO}"
        say_ok "SymLink: ${src_file} ➤ ${_sync_target} (fixed)"
      fi
    elif [[ -e ${_sync_target} ]]; then
      # Handle real file/directory (not a symlink)
      # Only back up if target isn't identical to source
      if [[ -f ${_sync_target} ]] && [[ -f ${_sync_src} ]]; then
        # For regular files, compare contents
        if ! cmp -s "${_sync_target}" "${_sync_src}"; then
          _make_backup="${_backup_dir}/${dst_file}"
          ensure_dir "$(dirname "${_make_backup}")"
          command cp -r "${_sync_target}" "${_make_backup}" &&
            say_info "Backup: ${_sync_target} ➤ ${_make_backup} (content differs)"
        else
          say_info "Content identical, no backup needed for ${_sync_target}"
        fi
      else
        # For directories or different file types, always back up
        _make_backup="${_backup_dir}/${dst_file}"
        ensure_dir "$(dirname "${_make_backup}")"
        command cp -r "${_sync_target}" "${_make_backup}" &&
          say_info "Backup: ${_sync_target} ➤ ${_make_backup}"
      fi

      _safe_operation command rm -rf "${_sync_target}" ||
        handle_error "Failed to remove existing target" "rm -rf ${_sync_target}" "${LINENO}"
      _safe_operation command ln -s "${_sync_src}" "${_sync_target}" ||
        handle_error "Failed to create symlink" "ln -s ${_sync_src} ${_sync_target}" "${LINENO}"
      say_ok "SymLink: ${src_file} ➤ ${_sync_target}"
    else
      # Create new symlink (no backup needed as target doesn't exist)
      ensure_dir "$(dirname "${_sync_target}")"
      _safe_operation command ln -s "${_sync_src}" "${_sync_target}" ||
        handle_error "Failed to create symlink" "ln -s ${_sync_src} ${_sync_target}" "${LINENO}"
      say_ok "SymLink: ${src_file} ➤ ${_sync_target} (new)"
    fi
  done

  # Return success
  return 0
}

# ----------------------------------------------------------------------------
# dosync: Synchronize default files from the config
#
# Arguments: None
# Returns: Exit code from _perform_sync
# ----------------------------------------------------------------------------
dosync() {
  _sync_config
  _perform_sync "${_files_src}"
}

# ----------------------------------------------------------------------------
# dosync_tag: Synchronize files with a specific tag
#
# Arguments:
#   $1 - Tag name to synchronize
# Returns: 0 on success, 1 if tag not found, exits on error
# ----------------------------------------------------------------------------
dosync_tag() {
  tag="$1"
  if [[ -z ${tag} ]]; then
    say_err "No tag specified for sync-tag command"
  fi

  # Get files with the specified tag - FIXED SED COMMAND
  _files_src="$(sed -n "/^\[files:${tag}\]/,/^\[/p" "${_sync_file}" | grep -v '^\[' | grep -v '^#' | grep -v '^$' | sort -u)"
  if [[ -z ${_files_src} ]]; then
    say_warn "No files with tag '${tag}' found in ${_sync_file}"
    return 1
  fi

  # Use the common sync function
  _perform_sync "${_files_src}"
}

# ----------------------------------------------------------------------------
# dosync_all_tags: Synchronize all files from all tagged sections
#
# Arguments: None
# Returns: 0 on success, 1 if no tags found
# ----------------------------------------------------------------------------
dosync_all_tags() {
  info_block "Synchronizing all tagged sections"

  # Find all section headers matching [files:tagname] pattern
  all_tags=$(grep -o '^\[files:[^]]*\]' "${_sync_file}" | sed 's/^\[files:\(.*\)\]/\1/g' | sort -u)

  if [[ -z ${all_tags} ]]; then
    say_warn "No tagged sections found in ${_sync_file}"
    return 1
  fi

  say_info "Found $(echo "${all_tags}" | wc -l) tags to synchronize"

  # Process each tag
  echo "${all_tags}" | while IFS= read -r tag; do
    say_info "--- Processing tag: ${tag} ---"
    dosync_tag "${tag}"
    say_info "--- Completed tag: ${tag} ---"
  done
}

# ----------------------------------------------------------------------------
# rollback: Restore files from a previous backup
#
# Arguments:
#   $1 - Optional timestamp of backup to restore (e.g. 2023-05-17_12-34-56)
#        If not provided, lists available backups
# Returns: 0 on success, 1 if backup not found or no backups exist
# ----------------------------------------------------------------------------
rollback() {
  if [[ -z $1 ]]; then
    # Add check if backup directory exists
    if [[ ! -d "${_user_home}/.backup/" ]]; then
      say_warn "No backups found"
      return 1
    fi

    # List available backups
    command find "${_user_home}/.backup/" -maxdepth 1 -type d -name "20*" | sort -r | while read -r backup; do
      echo "$(basename "${backup}") ($(command find "${backup}" -type f | wc -l) files)"
    done
    return 0
  fi

  _restore_dir="${_user_home}/.backup/$1"
  if [[ ! -d ${_restore_dir} ]]; then
    say_err "Backup $1 not found"
  fi

  say_info "Restoring from backup: $1"
  command find "${_restore_dir}" -type f | while read -r file; do
    relative_path="${file#"${_restore_dir}"/}"
    target_path="${_user_home}/${relative_path}"
    if [[ -L ${target_path} ]]; then
      command rm -f "${target_path}"
    fi
    ensure_dir "$(dirname "${target_path}")"
    command cp -r "${file}" "${target_path}" &&
      say_ok "Restored: ${target_path}"
  done
}

# ----------------------------------------------------------------------------
# _do_options: Process and dispatch commands
#
# Arguments:
#   $1 - Command name (sync, clean, rollback, etc.)
#   $@ - Additional arguments for the command
# Returns: Exit code from the executed command
# ----------------------------------------------------------------------------
_do_options() {
  # Command is first argument, other arguments start from second position
  _run_cmd="$1"
  shift

  case "${_run_cmd}" in
  sync) dosync ;;
  clean) _remove_broken_links ;;
  rollback) rollback "$1" ;;        # Pass first argument only
  sync-tag) dosync_tag "$1" ;;      # Pass first argument only
  sync-all-tags) dosync_all_tags ;; # Added new command
  *) usage ;;
  esac
}

# ----------------------------------------------------------------------------
# usage: Display usage information and exit
#
# Arguments: None
# Returns: Does not return (exits with code 1)
# ----------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $0 [options] [command]

Options:
  -q        Quiet mode
  -d        Dry run mode
  -c CMD    Specify command

Commands:
  sync          Synchronize dotfiles (default)
  clean         Remove broken symlinks
  rollback      Restore files from backup
  sync-tag      Sync dotfiles with specific tag
  sync-all-tags Sync all tagged dotfiles

EOF
  return 0
}

# ----------------------------------------------------------------------------
# main: Main entry point for the script
#
# Arguments:
#   $@ - All command line arguments
# Returns: Exit code from the executed command
# ----------------------------------------------------------------------------
main() {
  # Initialize variables
  _cmd_=""
  _is_quiet=false
  _is_dry_run=false

  # Check dependencies early
  _check_deps || return 1

  # If no arguments are given, run sync by default
  [[ $# -eq 0 ]] && set -- "sync"

  while getopts ":qdc:" opt; do
    case "${opt}" in
    q) _is_quiet=true ;;
    d) _is_dry_run=true ;;
    c) _cmd_="${OPTARG}" ;;
    *) usage ;;
    esac
  done
  shift $((OPTIND - 1))

  # If command wasn't specified with -c, use first argument
  [[ -z ${_cmd_} ]] && [[ $# -gt 0 ]] && _cmd_="$1" && shift

  # Pass command name as first argument and remaining args
  _do_options "${_cmd_}" "$@"
  return $?
}

main "$@"
