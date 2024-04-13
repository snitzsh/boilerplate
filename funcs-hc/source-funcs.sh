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
function funcSourceRepositoryFuncs () {
  for func in "${PLATFORM_PATH}"/boilerplate/funcs-hc/*; do
    if [ "${func}" == "${PLATFORM_PATH}/boilerplate/funcs-hc/source-funcs.sh" ]; then
      continue
    fi
    source "${func}"
  done
}

funcSourceRepositoryFuncs
