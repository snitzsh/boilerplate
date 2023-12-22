#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-c/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"


#
# TODO:
#   - null
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
main () {
  utilLooperClusters "delete-cluster"
}

main
