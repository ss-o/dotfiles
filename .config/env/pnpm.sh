typeset -gx PNPM_HOME="${HOME}/.local/share/pnpm"

case ":${PATH}:" in
*":${PNPM_HOME}:"*) ;;
*) typeset -gx PATH="${PNPM_HOME}:${PATH}" ;;
esac
