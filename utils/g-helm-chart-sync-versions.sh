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
    local -r latest_version=$( \
      # `helm` repo version
      helm show chart "${dependency_name}/${chart_name}" \
        | yq '.version' \
    )
    local -r current_version=$( \
      # ./Chart repo version
      yq '.dependencies[0].version' "./Chart.yaml" \
    )
    local -r file_dependency_version=$( \
      # ../helm-charts-dependencies.yaml -> dependency
      echo "${file_dependency}" | yq '.version' \
    )

    # Obj
    local -r latest_version_obj=$( \
      utilGetVersionAsObj "${latest_version}" \
    )
    local -r current_version_obj=$( \
      utilGetVersionAsObj "${current_version}" \
    )
    local -r file_dependency_version_obj=$( \
      utilGetVersionAsObj "${file_dependency_version}" \
    )
    # is_valid
    local -r is_latest_version_valid=$( \
      utilIsVersionObjQuery "is_valid" "${latest_version_obj}"
    )
    local -r is_current_version_valid=$( \
      utilIsVersionObjQuery "is_valid" "${current_version_obj}"
    )
    local -r is_file_dependency_version_valid=$( \
      utilIsVersionObjQuery "is_valid" "${file_dependency_version_obj}" \
    )

    if [[ "${is_latest_version_valid}" == "false" ]] ||
      [[ "${is_current_version_valid}" == "false" ]] ||
      [[ "${is_file_dependency_version_valid}" == "false" ]]; then
      logger "WARN" "'helm show chart --devel ${dependency_name}/${chart_name}'s version '${latest_version}' and/or '${region_name}/${cluster_name}/${dependency_name}/${chart_name}/Chart.yaml's version '${current_version}', and/or '../helm-charts-dependencies.yaml's version '${file_dependency_version}' does not follow the version convention (0.0.0). It may need manual update from ${current_version} to ${latest_version}" "${func_name}"
      exit 1 # skips loop
    fi
    # x_x_x_num
    local -r latest_version_x_x_x_num=$( \
      utilIsVersionObjQuery "x_x_x_num" "${latest_version_obj}"
    )
    local -r current_version_x_x_x_num=$( \
      utilIsVersionObjQuery "x_x_x_num" "${current_version_obj}"
    )
    # local -r file_dependency_version_x_x_x_num=$( \
    #   utilIsVersionObjQuery "x_x_x_num" "${file_dependency_version_obj}" \
    # )
    local -r latest_is_greater_than_current_version=$( \
      utilCompareVersions \
        "greater_than" \
        "${latest_version_x_x_x_num}" \
        "${current_version_x_x_x_num}" \
    )
  fi
}
