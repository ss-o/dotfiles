# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# https://z.digitalclouds.dev/community/zsh_plugin_standard#standard-recommended-options
builtin emulate -L zsh ${=${options[xtrace]:#off}:+-o xtrace}
builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

# https://z.digitalclouds.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# https://z.digitalclouds.dev/community/zsh_plugin_standard#standard-plugins-hash
typeset -gA ZI Plugins ZState
Plugins[CODELOAD_REPO_DIR]="${0:h}"
ZI[CODELOAD]="${ZI[PLUGINS_DIR]}/_local---config" 

if [[ $AF_OFF != 1 ]]; then
  fpath=("${Plugins[CODELOAD_REPO_DIR]}/functions" "${fpath[@]}")
  autoload -Uz $fpath[1]/*(.:t)
  ZState[autoload_func]=1
  return 0
}
