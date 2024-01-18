#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-r/source-funcs.sh"
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
  # utilLooperHelmChartConfigsRepositories "hc-c-update-helm-repositories"
  utilLooperHelmChartConfigsRepositories "r-create-license"
}

main
