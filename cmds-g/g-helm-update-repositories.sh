#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-g/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - support arguments
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - updates repos install by helm in local machine.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
main () {
  utilLooperHelmChartConfigsDependecies "global-helm-update-repositories"
}

main
