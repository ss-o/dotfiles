# Globaly exported variables required by Go
typeset -gx GOPATH="${HOME}/.local/share/go"
typeset -gx GOBIN="${GOPATH}/bin" # Unordered because GOBIN uses GOPATH

case ":${PATH}:" in
*":${GOBIN}:"*) ;;
*) typeset -gx PATH="${GOBIN}:${PATH}" ;;
esac
