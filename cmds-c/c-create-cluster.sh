#!/bin/bash
# shellcheck source=/dev/null

source "${SNITZSH_PATH}/boilerplate/funcs-c/source-funcs.sh"
source "${SNITZSH_PATH}/boilerplate/utils/source-utils.sh"


#
# TODO:
#   - null
#
# NOTE:
#   - Excution ex:
#     bash main.sh c-create-cluster minikubes north-america dev
#     bash main.sh c-create-cluster aws north-america dev
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
main () {
  local -ar args=("$@")
  utilLooperClusters "${args[@]}"
}

main "$@"
