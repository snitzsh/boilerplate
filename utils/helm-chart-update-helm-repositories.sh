#!/bin/bash

#
# TODO:
#   - null
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
utilHelmChartUpdateHelmRepositories () {
  local -r func_name="${FUNCNAME[0]}"
  local -a args=("$@")
  local -r dependency_name="${args[2]}"
  if ! helm repo update "${dependency_name}" &> /dev/null ; then
    logger "ERROR" "Helm repo '${dependency_name}' was not updated." "${func_name}"
  else
    logger "INFO" "Helm repo '${dependency_name}' was updated." "${func_name}"
  fi
}
