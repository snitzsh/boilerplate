#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - null
#
# NOTE:
#   - Use 'Lens' to access the cluster.
#
# DESCRIPTION:
#   - Get k8s cluster kubeconfig from cloud provider.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
clusterReadKubeconfig () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  # Region Name is not the region of aws!
  local -r region_name="${args[0]}"
  local -r cluster_name="${args[1]}"

  eksctl \
    utils \
      write-kubeconfig \
        --region us-east-1 \
        --cluster "${cluster_name}" \
        --profile k8s-admin
}
