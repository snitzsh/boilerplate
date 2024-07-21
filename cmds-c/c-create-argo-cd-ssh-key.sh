
#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-c/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - create a ssh-genkey to create the key and upload it to github ssh.
#   - Figure out if there an http curl
#   - Do we need it for each cluster, if argo-cd is deploy per cluster.
#     we only need one if we shared eks cluster for service (third party,
#     argo-cd, argo-workflows, etc.)
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - null
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function main () {
  local -ar args=("$@")
  utilLooperClusters "${args[@]}"
}

main "$@"
