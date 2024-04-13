#!/bin/bash

#
# TODO:
#   - add args
#   - Make git commands executions optional to prevent issues.
#   - make sure when a new region is created, it copies what is in dev
#     instead of creating the chart by scratch.
#   - make sure to execute `bash main.sh hc-update-helmignore-file`
#     so helm ignores undersired folders.
#   - Only support one dependency per Chart.yaml. Probably may need to support
#     multi dependency support.
#   - find out if its neccesary to keep default test-connection, helpers.tpl, NOTES.txt,
#     currently it gets cleaned up.
#   - findout if we need key/values in values.yaml.
#
# NOTE:
#   - Repository must be cloned first.
#
#   - When it's a new repository, it does not contain a chart.
#     this function ensures it creates the helm-chart inside the repo.
#
#   - it loops throught the repositories cloned. ../helm-charts-configs/ directory.
#
# DESCRIPTION:
#   - Creates helm chart in a repository per region per cluster.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function funcHelmChartConfigsCreateChart () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r dependency_name="${args[0]}"
  local -r chart_name="${args[1]}"
  local -r region_name="${args[2]}"
  local -r cluster_name="${args[3]}"
  # local -r dependency_obj="${args[4]}"
  # local -r initial_chart_name="${args[5]}"

  if ! [ -f "./Chart.yaml" ]; then
    # Initial files when creating the repo manually. Don't touch them
    logger "INFO" "Creating helm chart ${chart_name} for dependency: '${dependency_name}' in '${region_name}/${cluster_name}/' directory." "${func_name}"
    # # TODO: make sure all repos Chart.yaml .name has a postfix of "-config", indead of "<[dependency_name]>-<[chart_name]>"
    helm create "${chart_name}-configs" > /dev/null
    mv ./"${chart_name}-configs"/{.,}* ./
    rm ./templates/*.yaml
    rm -rf ./"${chart_name}-configs"
    utilCreateHelmChartVersionsFolder
    # Clean up files.
    : > templates/tests/test-connection.yaml
    : > templates/_helpers.tpl
    : > templates/NOTES.txt
    : > values.yaml
    funcHelmChartConfigs_HelpersFile "${args[@]}"
    local -a args_5=( \
      "create-common-props" \
      "${dependency_name}" \
      "${chart_name}" \
      "${region_name}" \
      "${cluster_name}" \
      "${func_name}" \
      "null" \
      "null" \
      "null" \
      "[]" \
    )
    utilQueryHelmChartConfigsValuesYamlFile "${args_5[@]}"
    local -a args_2=( \
      "${func_name}" \
      "Create ${dependency_name}/${chart_name}/${region_name}/${cluster_name} helm chart." \
    )
    utilGitter "${args_2[@]}"
  else

    # shellcheck disable=SC2016
    # _chart_name="${chart_name}" \
    # yq \
    #   -ri \
    #   '
    #     env(_chart_name) as $_chart_name
    #     | with(.; .name |= $_chart_name + "-configs")
    #   ' Chart.yaml
    # # rm -rf './versions/versions'
    # local -a args_2=( \
    #   "${func_name}" \
    #   "Update ${dependency_name}/${chart_name}/${region_name}/${cluster_name} Chart.yaml .name prop." \
    # )
    # utilGitter "${args_2[@]}"

    logger "ERROR" "helm chart '${chart_name}' already exist for dependency: '${dependency_name}' in '${region_name}/${cluster_name}/' directory." "${func_name}"
  fi
}
