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
#   - Creates helm-chart for repos that starts with `helm-chart-`
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
createHelmChartInExistingRepository () {
  local -r func_name="${FUNCNAME[0]}"
  (
    cd "$SNITZSH_PATH/helm-charts" &&
    for repository in *; do
      if ! [ -f "$repository/Chart.yaml" ]; then
        logger "INFO"  "Creating helm-chart for ${repository} repo." "${func_name}"
        (
          cd "./${repository}" &&
          helm create "${repository}" &&
          mv ./"${repository}"/{.,}* ./
          rm ./templates/*.yaml
          rm -rf ./"${repository}"
        )
      else
        logger "WARN" "Chart.yaml already exist for ${repository} repo." "${func_name}"
      fi
      exit 1
    done
  )
}

main () {
  createHelmChartInExistingRepository
}

main
