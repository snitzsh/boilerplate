#!/bin/bash

#
# TODO:
#   - add args
#   - There is an issuer when adding a comment to the porperty for empty array.
#     Some other function in boilerplate have this issue.
#
# NOTE:
#   - it loops throught the repositories cloned. ../helm-charts-configs/ directory.
#
# DESCRIPTION:
#   - Patches the dependencies on each helm-chart-repo's Chart.yaml file.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
funcHelmChartUpdateChartYamlFile () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  local -r dependency_name="${args[0]}"
  local -r chart_name="${args[1]}"
  local -r region_name="${args[2]}"
  local -r cluster_name="${args[3]}"
  local -r dependency_obj="${args[4]}"

  if [ -f "./Chart.yaml" ]; then
    # shellcheck disable=SC2016
    _func_name="${func_name}" \
    _dependency_obj="${dependency_obj}" \
    yq -ri '
      . as $chart_yaml
      | env(_dependency_obj) as $_dependency_obj
      | env(_func_name) as $_func_name
      | $chart_yaml.dependencies |= [
          {
            "name": $_dependency_obj.name,
            "version": $_dependency_obj.version,
            "repository": $_dependency_obj.repository
          }
        ]
      | ($chart_yaml.dependencies | key) line_comment=("This property was initially auto generated by {_func_name} in boilerplate repository." | sub("{_func_name}", $_func_name))
      | $chart_yaml
    ' "./Chart.yaml"

    local -a args_2=( \
      "${func_name}" \
      "Updated ${dependency_name}/${chart_name}/${region_name}/${cluster_name} helm chart. Executed by '${func_name}'." \
    )
    utilGitter "${args_2[@]}"
  fi
}
