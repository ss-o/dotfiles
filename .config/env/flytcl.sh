typeset -gx FLYCTL_BIN="${HOME}/.local/share/fly/bin"

case ":${PATH}:" in
*":${FLYCTL_BIN}:"*) ;;
*) typeset -gx PATH="${FLYCTL_BIN}:${PATH}" ;;
esac
