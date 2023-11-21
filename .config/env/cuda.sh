typeset -gx CUDA_HOME=/opt/cuda
typeset -gx LD_LIBRARY_PATH=${CUDA_HOME}/lib

case ":${PATH}:" in
*":${CUDA_HOME}/bin:"*) ;;
*) typeset -gx PATH="${CUDA_HOME}/bin:${PATH}" ;;
esac

case ":${LD_LIBRARY_PATH}:" in
*":${CUDA_HOME}/lib:"*) ;;
*) typeset -gx PATH="${CUDA_HOME}/lib:${LD_LIBRARY_PATH}" ;;
esac
