#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-g/source-funcs.sh"
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
  utilLooperHelmChartDependecies "global-helm-update-repositories"
}

main
