#!/bin/bash

# shellcheck source=/dev/null
source "${PLATFORM_PATH}/boilerplate/funcs-hc/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Exectues the function(s)
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
main () {
  utilLooperHelmChartDependeciesFile "hc-create-_helpers-file"
}

main
