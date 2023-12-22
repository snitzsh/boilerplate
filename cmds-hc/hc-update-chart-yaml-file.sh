#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-hc/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - maybe we much create a function to sync our helm-charts/ and respositories in git.
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
  # utilGetRepositories
  utilLooperHelmChartRepositories "update-chart-yaml-file"
}

main
