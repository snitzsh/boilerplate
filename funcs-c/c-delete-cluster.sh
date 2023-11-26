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
clusterDeleteCluster () {
  eksctl \
    delete \
      cluster \
        --region us-east-1 \
        --profile k8s-admin \
        --name dev
}
