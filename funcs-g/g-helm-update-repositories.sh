#!/bin/bash

#
# TODO:
#   - add args, notes.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Update chart repository locally.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function funcGlobalHelmUpdateRepositories () {
  local -r func_name="${FUNCNAME[0]}"
  local -a args=("$@")
  local -r dependency_name="${args[0]}"
  if ! helm repo update "${dependency_name}" &> /dev/null ; then
    logger "ERROR" "Helm repo '${dependency_name}' was not updated. It could be that repo does not exit. For proprietary helm-charts, the repository where chart is hosted (ex: chartmuseum) may not be available for the initial deployment." "${func_name}"
  else
    logger "INFO" "Helm repo '${dependency_name}' was updated." "${func_name}"
  fi
}
