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
utilSyncHelmChartVersions () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r region_name="${args[0]}"
  local -r cluster_name="${args[1]}"
  local -r dependency_name="${args[2]}"
  local -r chart_name="${args[3]}"
  local -r file_dependency="${args[4]}"

  if [ -f "./Chart.yaml" ]; then
    # `helm` repo version
    local -r latest_version=$(helm show chart "${dependency_name}/${chart_name}" | yq '.version')
    # ./Chart repo version
    local -r current_version=$(yq '.dependencies[0].version' "./Chart.yaml")
    # ../helm-charts-dependencies.yaml dependency
    local -r file_dependency_version=$(echo "${file_dependency}" | yq '.version')



    utilIsSemVerValid "${current_version}"

    # latest_version_has_letters=$(utilVersionHasLetter "${latest_version}")
    # current_version_has_letters=$(utilVersionHasLetter "${current_version}")
    # file_dependency_version_has_letters=$(utilVersionHasLetter "${file_dependency_version}")


    # if [[ "${current_version_has_letters}" == "true" ]] ||
    #   [[ "${latest_version_has_letters}" == "true" ]] ||
    #   [[ "${file_dependency_version_has_letters}" == "true" ]]; then
    #   logger "WARN" "'helm show chart --devel ${dependency_name}/${chart_name}'s version '${latest_version}' and/or '${region_name}/${cluster_name}/${dependency_name}/${chart_name}/Chart.yaml's version '${current_version}', and/or '../helm-charts-dependencies.yaml's version '${file_dependency_version}' does not follow the version convention (0.0.0). It may need manual update from ${current_version} to ${latest_version}" "${func_name}"
    # fi

    # utilCompareVersions "${dependency_name}" "${chart_name}" "${current_version}" "${latest_version}"
  fi
}
