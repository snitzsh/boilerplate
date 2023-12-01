#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Deletes AWS eks cluster.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
clusterDelete () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  # Region Name is not the region of aws!
  local -r region_name="${args[0]}"
  local -r cluster_name="${args[1]}"
  eksctl \
    delete \
      cluster \
        --region us-east-1 \
        --profile k8s-admin \
        --name "${cluster_name}"
}
