#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# === Zi Loader === #

typeset -ghA ZI

# Source repository URL.
[[ -z $ZI[REPOSITORY] ]] && ZI[REPOSITORY]="https://github.com/z-shell/zi.git"
# Track branch or tag.
[[ -z $ZI[STREAM] ]] && ZI[STREAM]="main"

# https://wiki.zshell.dev/docs/guides/customization
# Where Zi should create all working directories.
[[ -z $ZI[HOME_DIR] ]] && ZI[HOME_DIR]="${HOME}/.zi"
# Directory where Zi code resides.
[[ -z $ZI[BIN_DIR] ]] && ZI[BIN_DIR]="${ZI[HOME_DIR]}/bin"
# Cache directory.
[[ -z $ZI[CACHE_DIR] ]] && ZI[CACHE_DIR]="${HOME}/.cache/zi"
# Directory for configuration files.
[[ -z $ZI[CONFIG_DIR] ]] && ZI[CONFIG_DIR]="${HOME}/.config/zi"

# User/Device specific directory for software/data files.
# https://wiki.zshell.dev/community/zsh_plugin_standard#global-parameter-with-prefix
: ${ZPFX:=${ZI[HOME_DIR]}/polaris}
# Zsh modules directory.
: ${ZI[ZMODULES_DIR]:=${ZI[HOME_DIR]}/zmodules}
# Path to .zcompdump file, with the file included (i.e. its name can be different).
: ${ZI[ZCOMPDUMP_PATH]:=${ZI[CACHE_DIR]}/.zcompdump}
# If set to 1, then mutes some of the Zi warnings, specifically the plugin already registered warning.
: ${ZI[MUTE_WARNINGS]:=0}
# Declare default history file and parameters
: ${HISTFILE:=${ZI[CACHE_DIR]}/.history}
[[ -e $HISTFILE ]] || { command mkdir -p ${HISTFILE:h}; command touch $HISTFILE; }
[[ -w $HISTFILE ]] && typeset -gx SAVEHIST=440000 HISTSIZE=441000 HISTFILE

# === Initiate Zi === #

# Get source from URL
get_source_from() {
  typeset -i exit_code=0
  if (( $+commands[curl] )); then
    command curl -fsSL "$1"; exit_code=$?
  elif (( $+commands[wget] )); then
    command wget -qO- "$1"; exit_code=$?
  else
    exit_code=255
  fi

  return $exit_code
}

# Check if URL is valid
check_src() {
  typeset -i exit_code=0
  typeset url="$1"
  if (( $+commands[curl] )); then
    command curl --output /dev/null --silent --show-error --location --head --fail "$url"; exit_code=$?
  elif (( $+commands[wget] )); then
    command wget --spider --quiet "$url"; exit_code=$?
  else
    exit_code=204
  fi

  return $exit_code
}

# Clone Zi repository if it doesn't exist
zzsetup() {
  builtin autoload colors; colors
  typeset -a git_refs
  typeset -i exit_code=0
  typeset tmp_dir show_process process_url

  if [[ ! -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
    tmp_dir="${TMPDIR:-/tmp}/zi"

    [[ -d $tmp_dir ]] || command mkdir -p $tmp_dir

    show_process="${tmp_dir}/git-process.zsh"
    process_url="https://raw.githubusercontent.com/z-shell/zi/main/lib/zsh/git-process-output.zsh"

    if [[ ! -f $show_process ]]; then
      if check_src $process_url; then
        get_source_from $process_url > "${tmp_dir}/git-process.zsh"
        command chmod a+x "${tmp_dir}/git-process.zsh"
      else
        return 1
      fi
    fi

    (( $+commands[clear] )) && command clear
    builtin print -P "%F{33}▓▒░ %F{160}Installing interactive & feature-rich plugin manager (%F{33}z-shell/zi%F{160})%f%b…\n"
    command mkdir -p "$ZI[BIN_DIR]" && \
    command chmod -R go-w "$ZI[HOME_DIR]" && command git clone --verbose --progress --branch \
      "$ZI[STREAM]" "$ZI[REPOSITORY]" "$ZI[BIN_DIR]" |& { command $show_process || command cat; }
    if [[ -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
      git_refs=("${(f@)$(builtin cd -q $ZI[BIN_DIR] && command git log --color --graph --abbrev-commit \
        --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' | head -5)}")
      builtin print
      builtin print -P "%F{33}▓▒░ %F{34}Successfully installed %F{160}(%F{33}z-shell/zi%F{160})%f%b\n"
      builtin print -rl -- "${git_refs[@]}"
      exit_code=0
    else
      builtin print -P "%F{160}▓▒░  The clone has failed…%f%b"
      builtin print -P "%F{160}▓▒░ %F{33} Please report the issue: %F{226}https://github.com/z-shell/zi/issues/new%f%b"
      exit_code=1
    fi
  fi

  return $exit_code
}

zzsource() {
  typeset -i exit_code=0
  if [[ -f "${ZI[BIN_DIR]}/zi.zsh" ]]; then
    source "${ZI[BIN_DIR]}/zi.zsh"
    exit_code=$?
  else
    zzsetup && zzsource
    exit_code=$?
  fi
  return $exit_code
}

# Load zi module if built
zzpmod() {
  typeset -i exit_code=0
  if [[ -f "${ZI[ZMODULES_DIR]}/zpmod/Src/zi/zpmod.so" ]]; then
    module_path+=( ${ZI[ZMODULES_DIR]}/zpmod/Src );
    zmodload zi/zpmod 2> /dev/null
    exit_code=$?
  fi
  return $exit_code
}

# Enable completion (completions should be loaded after zzsource)
zzcomps() {
  typeset -i exit_code=0
  if (( ${+_comps} )); then
    if [[ -f "${ZI[BIN_DIR]}/lib/_zi" ]]; then
      (( ${+_comps[zi]} )) || _comps[zi]="${ZI[BIN_DIR]}/lib/_zi"
    fi
    exit_code=$?
  fi
  return $exit_code
}

zzinit() {
  zzsource && zzcomps && zzpmod
  unset -f check_src get_source_from 2> /dev/null
  unset -f zzsetup zzsource zzcomps zzpmod zzinit 2> /dev/null
  unset exit_code 2> /dev/null
}
