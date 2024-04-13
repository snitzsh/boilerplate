#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - source file to access function in other script files.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function funcSourceHelmChartFuncs () {
  for func in "${PLATFORM_PATH}"/boilerplate/funcs-hc-c/*; do
    if [ "${func}" == "${PLATFORM_PATH}/boilerplate/funcs-hc-c/source-funcs.sh" ]; then
      continue
    fi
    source "${func}"
  done
}

funcSourceHelmChartFuncs
