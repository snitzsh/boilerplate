#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - null
#
# NOTE:
#   - Creates AWS eks cluster.
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
clusterCreate () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  # Region Name is not the region of aws!
  local -r region_name="${args[0]}"
  local -r cluster_name="${args[1]}"

  eksctl \
    create \
      cluster \
        --region us-east-1 \
        --profile k8s-admin \
        --name "${cluster_name}" \
        --nodegroup-name standard-workers \
        --node-type t4g.large \
        --nodes 1 \
        --managed
}
