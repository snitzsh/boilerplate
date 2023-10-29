#!/bin/bash
# shellcheck source=/dev/null

source "${SNITZSH_PATH}/boilerplate/funcs/source-funcs.sh"
source "${SNITZSH_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - null
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
  utilLooperClustersHelmCharts "g-clusters-put-{dependency_name}-{chart_name}-to-latest-version"
}

main
