#!/bin/bash

#
# TODO:
#   - add args
#   - There is an issuer when adding a comment to the porperty for empty array.
#     Some other function in boilerplate have this issue.
#
# NOTE:
#   - it loops throught the repositories cloned. ../helm-charts/ directory.
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
  local -r args=("$@")
  local -r region_name="${args[0]}"
  local -r cluster_name="${args[1]}"
  local -r dependency_name="${args[2]}"
  local -r chart_name="${args[3]}"

  if [ -f "./Chart.yaml" ]; then
    local dependency_obj=""
    dependency_obj=$( \
      utilGetHelmChartDependency "${dependency_name}" "${chart_name}" \
    )
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
    git add .
    # this ensures only commit and push if there are changes.
    git diff --staged --quiet || (
      git commit --quiet -m "Updated chart's dependencies for ${region_name}/${cluster_name}." > /dev/null &&
      git push --quiet
      logger "INFO" "Updated chart ${chart_name}'s dependencies for dependency: '${dependency_name}'." "${func_name}"
      sleep 5
    )
  fi
}
