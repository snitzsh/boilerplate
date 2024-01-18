#!/bin/bash
# shellcheck source=/dev/null

source "${PLATFORM_PATH}/boilerplate/funcs-hc-c/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - maybe we much create a function to sync our helm-charts-configs/ and respositories in git.
#   - Create a different logic when is a proprietary chart, meaning that we don't
#     need to loop per region_name, cluster_name
#     We may need to do a different repo (ex: helm-chart-rust-apis-configs) that
#     targets out own repo chart (helm-chart-rust-apis)
#     that we can use to this current logic that loops through each
#     `cluster_name` and `region_name`.
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
  utilLooperHelmChartConfigsRepositories "hc-c-create-helm-chart"
}

main
