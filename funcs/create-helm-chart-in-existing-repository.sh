#!/bin/bash
# shellcheck source=/dev/null

source "${SNITZSH_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - null
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
createHelmChartInExistingRepository () {
  local -r func_name="${FUNCNAME[0]}"
  local -a regions_name_arr=()

  # Get region names
  while IFS= read -r value; do
    regions_name_arr+=("${value}")
  done < <(utilQueryClustersYaml "get-regions-name")

  (
    cd "$SNITZSH_PATH/helm-charts" &&
    for dependency_name in *; do
      local chart_name=""
      for chart in  "${dependency_name}/"*; do
        chart_name=$(echo "${chart}" | yq -r 'split("/") | .[1]')
        for region_name in "${regions_name_arr[@]}"; do
          # Get cluster names
          local -a clusters_name_arr=()
          while IFS= read -r value; do
            clusters_name_arr+=("${value}")
          done < <(utilQueryClustersYaml "get-{region_name}-clusters-name" "${region_name}")

          for cluster_name in "${clusters_name_arr[@]}"; do
            (
              cd "./${dependency_name}/${chart_name}" &&
              mkdir -p ./"${region_name}/${cluster_name}"
              (
                cd "./${region_name}/${cluster_name}" &&
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
              )
            )
          done
        done
      done
    done
  )
}
#
# TODO:
#   - maybe we much create a function to sync our helm-charts/ and respositories in git.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Exectues the function(s)
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
main () {
  # utilGetRepositories
  createHelmChartInExistingRepository
}

main
