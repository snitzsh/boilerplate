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
funcSourceRepositoryFuncs () {
  for func in "${SNITZSH_PATH}"/boilerplate/r-funcs/*; do
    if [ "${func}" == "${SNITZSH_PATH}/boilerplate/r-funcs/source-funcs.sh" ]; then
      continue
    fi
    source "${func}"
  done
}

funcSourceRepositoryFuncs
