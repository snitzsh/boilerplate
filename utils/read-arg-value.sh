#!/bin/bash

#
# TODO:
#   - validate return
#   - if arg $1, $2 and $3 is null, get defaults
#
# NOTE:
#   - only accepts --arg, not -a
#
# DESCRIPTION:
#   - null
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function utilReadArgValue () {
  local -a func_name="$1"
  local -a query_name="$2"
  local -a arg="$3" # cmd or flags
  local -a arg_2="$4" # raw yaml (as string)

  case "${query_name}" in
    "<[command]>")
      # here get the defaults if "$3" is null
      # The challenge here is to chain the --flags that depend on each other
      ;;
    "*")
      ;;
  esac
  # shellcheck disable=SC2016
  _func_name="${func_name}" \
  _arg="${arg}" \
  _arg_2="${arg_2}" \
  yq \
    -n \
    '
      env(_arg) as $_arg
      | env(_arg_2) as $_arg_2
      | $_arg_2[]
      | select(.arg == $_arg)
      | .value
    '
}
