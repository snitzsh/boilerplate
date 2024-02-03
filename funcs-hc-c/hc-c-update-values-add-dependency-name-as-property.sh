#!/bin/bash

#
# TODO:
#   - place the property on the very top.
#
# NOTE:
#   - Must be executed after creating a helm-chart.
#     and after `funcHelmChartConfigsUpdateChartYamlFile`
#
# DESCRIPTION:
#   - Adds ./Chart.yaml dependencies[].name as properties in
#     values.yaml only if it does NOT exist.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#

funcHelmChartConfigsUpdateValuesAddDependencyNameAsProperty () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  local -r dependency_name="${args[0]}"
  local -r chart_name="${args[1]}"
  local -r region_name="${args[2]}"
  local -r cluster_name="${args[3]}"
  # local -r dependency_obj="${args[4]}"

  if [ -f "./Chart.yaml" ]; then
    local dependencies=""
    # NOTE:
    #   - removed comments because for properties with empty objects, yq will
    #     not place the comment after the '{}'. yq does not output the error
    #     for the first time, but the next attempt it will fail because it '{}'
    #     is below the property like this:
    #
    #     prop_name: # comment
    #     {}
    #
    dependencies=$( \
      yq \
        -r \
        '
          ... comments=""
          | .dependencies
        ' \
        "Chart.yaml" \
    )

    # NOTE: it will create props based for each item listed in .dependencies.
    # shellcheck disable=SC2016
    _func_name="${func_name}" \
    _dependencies="${dependencies}" \
    yq \
      -ri \
      '
        env(_dependencies) as $_dependencies
        | env(_func_name) as $_func_name
        | . as $obj
        | $_dependencies[]
        | .
        | with(select($obj[.name] == null);
            $obj[.name] = {}
            | ($obj[.name] | key) headComment=("This property was initially auto generated by {_func_name} in boilerplate repository." | sub("{_func_name}", $_func_name))
          )
        | $obj
      ' \
      "values.yaml"

    local -a args_2=( \
      "${func_name}" \
      "Updated ${dependency_name}/${chart_name}/${region_name}/${cluster_name} helm chart. Executed by '$func_name'." \
    )
    utilGitter "${args_2[@]}"
  fi
}
