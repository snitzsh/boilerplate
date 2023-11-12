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
funcSourceHelmChartFuncs () {
  for func in "${SNITZSH_PATH}"/boilerplate/hc-funcs/*; do
    if [ "${func}" == "${SNITZSH_PATH}/boilerplate/hc-funcs/source-funcs.sh" ]; then
      continue
    fi
    source "${func}"
  done
}

funcSourceHelmChartFuncs
