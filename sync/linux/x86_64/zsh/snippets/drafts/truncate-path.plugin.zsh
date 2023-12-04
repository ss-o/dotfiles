# Shrink directory paths, e.g. /home/me/foo/bar/quux -> ~/f/b/quux.
#
# For a fish-style working directory in your command prompt, add the following
# to your theme or zshrc:
#
#   setopt prompt_subst
#   PS1='%n@%m $(truncate_path -f)>'
#
# The following options are available:
#
#   -f, --fish       fish simulation, equivalent to -l -s -t.
#   -l, --last       Print the last directory's full name.
#   -s, --short      Truncate directory names to the first character. Without
#                    -s, names are truncated without making them ambiguous.
#   -t, --tilde      Substitute ~ for the home directory.
#   -T, --nameddirs  Substitute named directories as well.
#
# The long options can also be set via zstyle, like
#   zstyle :prompt:truncate_path fish yes
#
# Note: Directory names containing two or more consecutive spaces are not yet
# supported.
#
# Keywords: prompt directory truncate shrink collapse fish
#
# Copyright (C) 2008 by Daniel Friesel <derf@xxxxxxxxxxxxxxxxxx>
# License: WTFPL <http://www.wtfpl.net>
#
# Ref: https://www.zsh.org/mla/workers/2009/msg00415.html
#      https://www.zsh.org/mla/workers/2009/msg00419.html

truncate_path() {
        setopt local_options
        setopt rc_quotes null_glob

        typeset -i lastfull=0
        typeset -i short=0
        typeset -i tilde=0
        typeset -i named=0

        if zstyle -t ':prompt:truncate_path' fish; then
                lastfull=1
                short=1
                tilde=1
        fi
        if zstyle -t ':prompt:truncate_path' nameddirs; then
                tilde=1
                named=1
        fi
        zstyle -t ':prompt:truncate_path' last && lastfull=1
        zstyle -t ':prompt:truncate_path' short && short=1
        zstyle -t ':prompt:truncate_path' tilde && tilde=1

        while [[ $1 == -* ]]; do
                case $1 in
                        -f|--fish)
                                lastfull=1
                                short=1
                                tilde=1
                        ;;
                        -h|--help)
                                print 'Usage: truncate_path [-f -l -s -t] [directory]'
                                print ' -f, --fish      fish-simulation, like -l -s -t'
                                print ' -l, --last      Print the last directory''s full name'
                                print ' -s, --short     Truncate directory names to the first character'
                                print ' -t, --tilde     Substitute ~ for the home directory'
                                print ' -T, --nameddirs Substitute named directories as well'
                                print 'The long options can also be set via zstyle, like'
                                print '  zstyle :prompt:truncate_path fish yes'
                                return 0
                        ;;
                        -l|--last) lastfull=1 ;;
                        -s|--short) short=1 ;;
                        -t|--tilde) tilde=1 ;;
                        -T|--nameddirs)
                                tilde=1
                                named=1
                        ;;
                esac
                shift
        done

        typeset -a tree expn
        typeset result part dir=${1-$PWD}
        typeset -i i

        [[ -d $dir ]] || return 0

        if (( named )) {
                for part in ${(k)nameddirs}; {
                        [[ $dir == ${nameddirs[$part]}(/*|) ]] && dir=${dir/#${nameddirs[$part]}/\~$part}
                }
        }
        (( tilde )) && dir=${dir/#$HOME/\~}
        tree=(${(s:/:)dir})
        (
                if [[ $tree[1] == \~* ]] {
                        cd -q ${~tree[1]}
                        result=$tree[1]
                        shift tree
                } else {
                        cd -q /
                }
                for dir in $tree; {
                        if (( lastfull && $#tree == 1 )) {
                                result+="/$tree"
                                break
                        }
                        expn=(a b)
                        part=''
                        i=0
                        until [[ (( ${#expn} == 1 )) || $dir = $expn || $i -gt 99 ]]  do
                                (( i++ ))
                                part+=$dir[$i]
                                expn=($(print ${part}*(-/)))
                                (( short )) && break
                        done
                        result+="/$part"
                        cd -q $dir
                        shift tree
                }
                print ${result:-/}
        )
}

## vim:ft=zsh
