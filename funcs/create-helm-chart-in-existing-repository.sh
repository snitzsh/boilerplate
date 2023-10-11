#!/bin/bash
# shellcheck source=/dev/null

source "${SNITZSH_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Creates helm chart in a repository per cluster
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
createHelmChartInExistingRepository () {
  local -r func_name="${FUNCNAME[0]}"
  local -a regions=()

  # Get region names
  while IFS= read -r value; do
    regions+=("${value}")
  done < <( \
    echo "${PLATFORM_CLUSTERS_YAML}" \
    | yq -r '
        .regions
        | del(.. | select(tag == "!!map" and length == 0))
        | .
        | keys
        | .[]
      ' \
  )
  (
    cd "$SNITZSH_PATH/helm-charts" &&
    for dependency in *; do
      local chart_name=""
      for chart in  "${dependency}/"*; do
        chart_name=$(echo "${chart}" | yq -r 'split("/") | .[1]')
        for region in "${regions[@]}"; do
          echo "Region: $region"
          # Get cluster names
          local -a clusters=()
          # shellcheck disable=SC2016
          while IFS= read -r value; do
            clusters+=("${value}")
          done < <( echo "${PLATFORM_CLUSTERS_YAML}" \
            | region="${region}" \
              yq '
                env(region) as $region
                | .regions[$region].clusters
                | del(.. | select(tag == "!!map" and length == 0))
                | .
                | keys
                | .[]
              ' \
          )
          for cluster in "${clusters[@]}"; do
            (
              cd "./${dependency}/${chart_name}" &&
              mkdir -p ./"${region}/${cluster}"
              (
                cd "./${region}/${cluster}" &&
                if ! [ -f "./Chart.yaml" ]; then
                  # Initial files when creating the repo manually. Don't touch them
                  logger "INFO" "Creating helm chart ${chart_name} for dependency: '${dependency}'" "${func_name}"
                  helm create "${chart_name}" > /dev/null
                  mv ./"${chart_name}"/{.,}* ./
                  rm ./templates/*.yaml
                  rm -rf ./"${chart_name}"
                  git add .
                  git commit --quiet -m "Initial commit of chart_name ${dependency}/${chart_name}." > /dev/null
                  git push --quiet
                  sleep 5 # neccesary to let the machine time to git to commit and push and handle files
                else
                  logger "INFO" "helm chart '${chart_name}' already exist for dependency: '${dependency}'." "${func_name}"
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
#   - add notes, description, args
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - null
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
main () {
  createHelmChartInExistingRepository
}

main
