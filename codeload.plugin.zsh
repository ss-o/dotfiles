# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
#https://z.digitalclouds.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Autoload personal functions
fpath=("${0:h}/functions" "${fpath[@]}")
autoload -Uz $fpath[1]/*(.:t)

typeset -gA ZI
ZI[CODELOAD]="${ZI[PLUGINS]}/_local---config"