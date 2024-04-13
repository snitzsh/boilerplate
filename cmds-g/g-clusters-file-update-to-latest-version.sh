#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-g/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - support arguments
#
# NOTE:
#   - It will update all dependency chart version
#   - It only allows north-america/dev cluster, for lower environments another
#     command should be executed.
#
# DESCRIPTION:
#   - Updates the version of each dependency/chart's version located in the
#     ../clusters.yaml to latests.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function main () {
  utilLooperClustersHelmCharts "g-clusters-file-update-to-latest-version"
}

main
