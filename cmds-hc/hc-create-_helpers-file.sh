#!/bin/bash

# shellcheck source=/dev/null
source "${PLATFORM_PATH}/boilerplate/funcs-hc/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - read flags.yaml file
#
# NOTE:
#   - read flags.yaml file
#
# DESCRIPTION:
#   - read flags.yaml file
#
# ARGS:
#   - read flags.yaml file
#
# RETURN:
#   - read flags.yaml file
#
function main () {
  local -ar args=("$@")
  utilLooperHelmChartDependeciesFile "${args[@]}"
}

main "$@"
