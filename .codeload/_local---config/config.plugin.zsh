# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# https://z.digitalclouds.dev/community/zsh_plugin_standard#standard-recommended-options
builtin emulate -L zsh ${=${options[xtrace]:#off}:+-o xtrace}
builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

# https://z.digitalclouds.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

typeset -gA ZI
ZI[CODELOAD_CONFIG_DIR]="${0:h}"
ZI[CODELOAD_ALIASES]="${ZI[CODELOAD_CONFIG_DIR]}/zsh/aliases"
