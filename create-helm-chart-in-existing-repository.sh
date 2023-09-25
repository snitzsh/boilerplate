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
    for dependency in *; do
      for chart in  "${dependency}/"*; do
        echo "${chart}"
        (
          cd "./${dependency}/${chart}" &&
          helm create "${chart}" &&
          mv ./"${chart}"/{.,}* ./
          rm ./templates/*.yaml
          rm -rf ./"${chart}"
          git add .
          git commit --no-edit -m "Initial commit of chart ${dependency}/${chart}."
        )
        exit 1
        if ! [ -f "$chart/Chart.yaml" ]; then
          logger "INFO"  "Creating helm-chart for ${dependency}/${chart} repo." "${func_name}"
        # else
        #   logger "WARN" "Chart.yaml already exist for ${repository} repo." "${func_name}"
        fi
        # exit 1
      done

    done
  )
}

main () {
  createHelmChartInExistingRepository
}

main
