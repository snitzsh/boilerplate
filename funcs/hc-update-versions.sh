#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Updates ./helm-chart-dependencies.yaml with what the ./helm-chart
#     repos ./helm-chart/<[repo]>.Chart.yaml version.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
funcHelmChartUpdateVersions () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r region_name="${args[0]}"
  local -r cluster_name="${args[1]}"
  local -r dependency_name="${args[2]}"
  local -r chart_name="${args[3]}"
  local -r file_dependency="${args[4]}"

  if [ -f "./Chart.yaml" ]; then
    echo "${region_name}"
  fi
}
