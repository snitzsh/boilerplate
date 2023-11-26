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
clusterCreateCluster () {
  eksctl \
    create \
      cluster \
        --region us-east-1 \
        --profile k8s-admin \
        --name dev \
        --nodegroup-name standard-workers \
        --node-type t4g.large \
        --nodes 1 \
        --managed
}
