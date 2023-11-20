#!/bin/bash

#
# TODO:
#   - add args
#   - Make git commands executions optional to prevent issues.
#   - make sure when a new region is created, it copies what is in dev
#     instead of creating the chart by scratch.
#   - make sure to execute `bash main.sh hc-update-helmignore-file`
#     so helm ignores undersired folders.
#
# NOTE:
#   - Repository must be cloned first.
#
#   - When it's a new repository, it does not contain a chart.
#     this function ensures it creates the helm-chart inside the repo.
#
#   - it loops throught the repositories cloned. ../helm-charts/ directory.
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
  local -r dependency_obj="${args[4]}"

  if ! [ -f "./Chart.yaml" ]; then
    # Initial files when creating the repo manually. Don't touch them
    logger "INFO" "Creating helm chart ${chart_name} for dependency: '${dependency_name}' in '${region_name}/${cluster_name}/' directory." "${func_name}"
    helm create "${chart_name}" > /dev/null
    mv ./"${chart_name}"/{.,}* ./
    rm ./templates/*.yaml
    rm -rf ./"${chart_name}"
    utilCreateHelmChartVersionsFolder
    local -a args_2=( \
      "${func_name}" \
      "Create ${dependency_name}/${chart_name}/${region_name}/${cluster_name} helm chart." \
    )
    utilGitter "${args_2[@]}"
  else
    logger "INFO" "helm chart '${chart_name}' already exist for dependency: '${dependency_name}' in '${region_name}/${cluster_name}/' directory." "${func_name}"
  fi
}
