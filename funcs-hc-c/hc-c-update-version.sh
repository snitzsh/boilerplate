#!/bin/bash

#
# TODO:
#   - The following must be true to automatically update a chart.
#     1) Check of diff versions/<[chart_version]>-values.yaml vs versions/<[chart_version]>-values.yaml
#     3) Check diff in ./values vs versions/<[chart_version]>-values.yaml
#        this one is tricky because we must check for property differences
#        since in ./values we only have the properties we need for the chart.
#   - make sure when update hc-c-...-configs to newer version the argo-cd.main.dependecies
#     are also updated.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Update the helm-chart version if it meets this criteria:
#     1) values.yaml has `.<[chart-name]>` prop
#     2) cluster.yaml has the same .version with what the repo have.
#        if not, then must check manually.
#     3) .version is < cluster.latest_version
#     4) if yaml merge to the new version is successfull.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function funcHelmChartConfigsUpdateVersion () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r dependency_name="${args[0]}"
  local -r chart_name="${args[1]}"
  local -r region_name="${args[2]}"
  local -r cluster_name="${args[3]}"
  local -r file_dependency="${args[4]}"

  if [ -f "./Chart.yaml" ] && [ -f "./values.yaml" ]; then

    local file_dependency_chart_version=""
    file_dependency_chart_version=$(\
      # shellcheck disable=SC2016
      _file_dependency="${file_dependency}" \
      yq \
        -nr \
        '
          env(_file_dependency) as $_file_dependency
          | $_file_dependency
          | .version
        ' \
    )

    local chart_file_chart_version=""
    chart_file_chart_version=$( \
      # shellcheck disable=SC2016
      _chart_name="${chart_name}" \
      yq \
        -r \
        '
          env(_chart_name) as $_chart_name
          | .dependencies[]
          | select(.name == $_chart_name)
          | .version
        ' "Chart.yaml" \
    )

    if [ "${file_dependency_chart_version}" != "${chart_file_chart_version}" ]; then
      logger "WARN" "helm chart '${dependency_name}/${chart_name}/${region_name}/${cluster_name}/' is NOT up-to-date." "${func_name}"
      # shellcheck disable=SC2016
      _chart_name="${chart_name}" \
      _file_dependency_chart_version="${file_dependency_chart_version}" \
      yq \
        -ri \
        '
          env(_chart_name) as $_chart_name
          | env(_file_dependency_chart_version) as $_file_dependency_chart_version
          | with(select(.dependencies[].name == $_chart_name);
              .dependencies[]
              | select(.name == $_chart_name)
              | .version = $_file_dependency_chart_version
            )
          | .
        ' "Chart.yaml"
      # Update Chart.lock
      helm dependency update
      local -a args_2=( \
        "${func_name}" \
        "helm chart ${dependency_name}/${chart_name}/${region_name}/${cluster_name} .dependencies[<[chart_name]>].version has been updated." \
      )
      utilGitter "${args_2[@]}"
    else
      logger "INFO" "helm chart '${dependency_name}/${chart_name}/${region_name}/${cluster_name}/' is already up-to-date." "${func_name}"
    fi
  fi
}
