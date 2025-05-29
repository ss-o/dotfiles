# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# ⸨ Dotfiles ZSH ⸩

typeset -gA DOTFILES
DOTFILES[ZSH]="${0:h}"
DOTFILES[ZSH_ALIASES]="${0:h}/aliases"
DOTFILES[ZSH_SNIPPETS]="${0:h}/snippets"
DOTFILES[ZSH_FUNCTIONS]="${0:h}/functions"
DOTFILES[ZSH_COMPLETIONS]="${0:h}/completions"

# https://wiki.zshell.dev/community/zsh_plugin_standard#funtions-directory
if [[ $PMSPEC != *f* ]]; then
  fpath+=( "${DOTFILES[ZSH_FUNCTIONS]}" )
fi

# ⸨ Initiate ⸩
@init(){
  setopt typeset_silent; typeset _init_1 _init_2 _init_3 _init_4
  zstyle ':zi:plugins:ssh-agent' quiet yes
  for _init_1 in ${DOTFILES[ZSH_FUNCTIONS]}/*; do autoload -Uz "${_init_1:t}"; done
  for _init_2 in ${DOTFILES[ZSH_COMPLETIONS]}/*; do ln -sf "${_init_2}" "${HOME}/.zi/completions/"; done
  for _init_3 in ${DOTFILES[ZSH_SNIPPETS]}/loaded/*.zsh; do source "$_init_3"; done
  for _init_4 in ${DOTFILES[ZSH_ALIASES]}/user/*.zsh; do source "$_init_4"; done
}; @init; unset -f @init
