# This file defines Go environment and meant to be included in user or system files respectively, e.g.:
# user: ~/.profile, Zsh: ~/.zshenv, Bash: ~/.bash_profile, system-wide: /etc/profile, etc.

export GOPATH="${HOME}/.local/share/go"
export GOBIN="${GOPATH}/bin" # Unordered because GOBIN uses GOPATH
export PATH="${PATH}:${GOBIN}"
