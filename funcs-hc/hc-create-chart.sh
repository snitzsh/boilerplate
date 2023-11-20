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
    # local -a args_2=( \
    #   "${func_name}" \
    #   "Update ${dependency_name}/${chart_name}/${region_name}/${cluster_name} helm chart." \
    # )
    (
      ls
      # cat .git/hooks/prepare-commit-msg.sample
      # rm -rf ./templates
      # rm .helmignore
      # rm Chart.yaml
      # rm values.yaml
      # git add .
      # git commit --quiet -m "Removed the chart files that are not needed for ${dependency_name}/${chart_name} " > /dev/null
      # git push --quiet
      # sleep 5 # neccesary to let the machine time to git to commit and push and handle files
    )
    logger "INFO" "helm chart '${chart_name}' already exist for dependency: '${dependency_name}' in '${region_name}/${cluster_name}/' directory." "${func_name}"
  fi
}

utilCreateHelmChartVersionsFolder () {
  local -a folders=( \
    "tgzs" \
    "manifests" \
    "values" \
    "diff-current-to-latest-version-values" \
    "diff-current-to-per-newer-version-values" \
  )
  for folder in "${folders[@]}"; do
    mkdir -p "versions/${folder}"
    (
      cd "versions/${folder}" &&
      # Creating a dummy file to force git to track the folders,
      # otherwise git will not push empty folder.
      if [ "${folder}" == "tgzs" ]; then
        touch _test.tgz
      else
        touch _test.yaml
      fi
    )
  done
}
