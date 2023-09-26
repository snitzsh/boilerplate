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
moveFileToTmp () {
  local -r file_name=$1
  mv ./"${file_name}" /tmp/
}

moveTmpToDir () {
  local -r file_name=$1
  mv /tmp/"${file_name}" ./
}

createHelmChartInExistingRepository () {
  local -r func_name="${FUNCNAME[0]}"
  (
    cd "$SNITZSH_PATH/helm-charts" &&
    for dependency in *; do
      local chart_name=""
      for chart in  "${dependency}/"*; do
        chart_name=$(echo "${chart}" | yq -r 'split("/") | .[1]')
        (
          cd "./${dependency}/${chart_name}" &&
          if ! [ -f "./Chart.yaml" ]; then
            # Initial files when creating the repo manually. Don't touch them
            moveFileToTmp .gitignore
            moveFileToTmp LICENSE
            moveFileToTmp README.md
            rm -rf ./*
            moveTmpToDir .gitignore
            moveTmpToDir LICENSE
            moveTmpToDir README.md
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
      done
    done
  )
}

main () {
  createHelmChartInExistingRepository
}

main
