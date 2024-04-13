#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-hc-c/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - null
#
# NOTE:
#   - USE WITH CAUSION: you may rewrite _helper.tpl specific functions manually
#     created by the DevOps.
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
  # utilGetRepositories
  utilLooperHelmChartConfigsRepositories "hc-c-create-_helpers-file"
}

main
