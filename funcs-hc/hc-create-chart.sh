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
function funcHelmChartCreateChart () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r dependency_name="${args[0]}"
  local -r chart_name="${args[1]}"

  if ! [ -f "./Chart.yaml" ]; then
    # Initial files when creating the repo manually. Don't touch them
    logger "INFO" "Creating helm chart ${chart_name} for dependency: '${dependency_name}' directory." "${func_name}"
    helm create "${chart_name}" > /dev/null
    mv ./"${chart_name}"/{.,}* ./
    rm ./templates/*.yaml
    rm -rf ./"${chart_name}"
    # Clean up files.
    : > templates/tests/test-connection.yaml
    : > templates/_helpers.tpl
    : > templates/NOTES.txt
    : > values.yaml
    funcHelmChart_HelpersFile "${args[@]}"
    local -a args_2=( \
      "create-common-props" \
      "${dependency_name}" \
      "${chart_name}" \
      "${func_name}" \
    )
    utilQueryHelmChartValuesYamlFile "${args_2[@]}"
    local -a args_3=( \
      "${func_name}" \
      "Create ${dependency_name}/${chart_name} helm chart." \
    )
    utilGitter "${args_3[@]}"
  else
    logger "ERROR" "helm chart '${chart_name}' already exist for dependency: '${dependency_name}'" "${func_name}"
  fi
}
