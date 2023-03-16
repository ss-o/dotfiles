# ‑‑‑‑‑‑ ⸨ Zsh Options ⸩ ‑‑‑‑‑‑

#setopt always_to_end            # when completing from the middle of a word, move the cursor to the end of the words
#setopt append_history       	  # allow multiple terminal sessions to all append to one zsh command history
#setopt auto_cd                  # cd by typing the directory name if it's not a command
#setopt auto_list                # automatically lists choices on an ambiguous completion
#setopt auto_menu                # automatically use menu completion
#setopt auto_pushd               # make cd push the old directory onto the directory stack
#setopt bang_hist                # treat the '!' character, especially during expansion.
#setopt extended_glob            # treat #, ~, and ^ as part of patterns for filename generation
#setopt extended_history         # record timestamp of command in HISTFILE
#setopt no_glob_dots             # show dotfiles in completions
#setopt hist_expire_dups_first   # delete duplicates first when HISTFILE size exceeds HISTSIZE
#setopt hist_ignore_all_dups     # remove older duplicate entries from the history
#setopt hist_ignore_dups         # ignore duplicated commands history list
#setopt hist_ignore_space        # ignore commands that start with space
#setopt hist_reduce_blanks       # remove superfluous blanks from history items
#setopt hist_save_no_dups        # do not write A duplicate event to the history file
#setopt hist_verify              # show command with history expansion to the user before running it
#setopt inc_append_history       # write to the history file immediately, not when the shell exits.
#setopt interactive_comments     # allow comments even in interactive shells
#setopt multios                  # perform implicit tees or cats when multiple redirections are attempted
#setopt no_beep                  # don't beep on error
#setopt prompt_subst             # enable parameter expansion, command substitution, and arithmetic expansion in the prompt
#setopt transient_rprompt        # only show the rprompt on the current prompt
#setopt pushd_ignore_dups        # don't push multiple copies of the same directory onto the directory stack
#setopt share_history            # share command history data
#setopt long_list_jobs           # display PID when suspending processes as well
#setopt notify                   # report the status of backgrounds jobs immediately
#setopt no_sh_word_split         # use zsh style word splitting
#setopt unset                    # don't error out when unset parameters are used
#setopt nohup                    # don't send SIGHUP to background processes when the shell exits.
#unsetopt rm_star_silent         # ask for confirmation for rm * and rm path/
