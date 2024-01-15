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
funcHelmChartPostChart () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r dependency_name="${args[0]}"
  local -r chart_name="${args[1]}"
  local -r region_name="${args[2]}"
  local -r cluster_name="${args[3]}"
  # local -r dependency_obj="${args[4]}"

  if ! [ -f "./Chart.yaml" ]; then
    # Initial files when creating the repo manually. Don't touch them
    logger "INFO" "Creating helm chart ${chart_name} for dependency: '${dependency_name}' in '${region_name}/${cluster_name}/' directory." "${func_name}"
    helm create "${dependency_name}-${chart_name}" > /dev/null
    mv ./"${dependency_name}-${chart_name}"/{.,}* ./
    rm ./templates/*.yaml
    rm -rf ./"${dependency_name}-${chart_name}"
    # touch "${chart_name}-values.yaml"
    utilCreateHelmChartVersionsFolder
    # Clean up files.
    : > templates/tests/test-connection.yaml
    : > templates/_helpers.tpl
    : > templates/NOTES.txt
    : > values.yaml
    funcHelmChart_HelpersFile "${args[@]}"
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
    utilQueryHelmChartValuesYaml "${args_5[@]}"
    local -a args_2=( \
      "${func_name}" \
      "Create ${dependency_name}/${chart_name}/${region_name}/${cluster_name} helm chart." \
    )
    utilGitter "${args_2[@]}"
  else
    rm -rf './versions/versions'
    local -a args_2=( \
      "${func_name}" \
      "Delete ${dependency_name}/${chart_name}/${region_name}/${cluster_name} helm chart versions/versions duplicate folder." \
    )
    utilGitter "${args_2[@]}"

    logger "INFO" "helm chart '${chart_name}' already exist for dependency: '${dependency_name}' in '${region_name}/${cluster_name}/' directory." "${func_name}"
  fi
}
