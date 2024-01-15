#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-hc/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - On the works...
#
# NOTE:
#   - This command creates a custom-resources definition as a file
#     on each helm-chart repository.
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
  utilLooperHelmChartRepositories "hc-create-custom-resoure-definitions"
}

main