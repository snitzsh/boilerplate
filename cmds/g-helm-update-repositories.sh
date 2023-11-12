#!/bin/bash
# shellcheck source=/dev/null

source "${SNITZSH_PATH}/boilerplate/hc-funcs/source-funcs.sh"
source "${SNITZSH_PATH}/boilerplate/r-funcs/source-funcs.sh"
source "${SNITZSH_PATH}/boilerplate/utils/source-utils.sh"

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
