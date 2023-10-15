#!/bin/bash

#
# TODO:
#   - add args
#
# NOTE:
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
utilHelmChartCreateChart () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r region_name="${args[0]}"
  local -r cluster_name="${args[1]}"
  local -r dependency_name="${args[2]}"
  local -r chart_name="${args[3]}"

  if ! [ -f "./Chart.yaml" ]; then
    # Initial files when creating the repo manually. Don't touch them
    logger "INFO" "Creating helm chart ${chart_name} for dependency: '${dependency_name}' in '${region_name}/${cluster_name}/' directory." "${func_name}"
    helm create "${chart_name}" > /dev/null
    mv ./"${chart_name}"/{.,}* ./
    rm ./templates/*.yaml
    rm -rf ./"${chart_name}"
    git add .
    git commit --quiet -m "Initial commit of chart_name ${dependency_name}/${chart_name} for ${region_name}/${cluster_name}." > /dev/null
    git push --quiet
    sleep 5 # neccesary to let the machine time to git to commit and push and handle files
  else
    logger "INFO" "helm chart '${chart_name}' already exist for dependency: '${dependency_name}' in '${region_name}/${cluster_name}/' directory." "${func_name}"
  fi
}
