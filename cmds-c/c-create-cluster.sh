#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-c/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"


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
function main () {
  local -ar args=("$@")
  utilLooperClusters "${args[@]}"
}

main "$@"
