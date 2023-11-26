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
clusterGetKubeconfig () {
  eksctl \
    utils \
      write-kubeconfig \
        --cluster dev \
        --region us-east-1 \
        --profile k8s-admin
}
