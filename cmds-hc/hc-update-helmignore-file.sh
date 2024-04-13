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
function main () {
  # utilLooperHelmChartConfigsRepositories "hc-c-update-helm-repositories"
  utilLooperHelmChartDependeciesFile "hc-update-helmignore-file"
}

main
