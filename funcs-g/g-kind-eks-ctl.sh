#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - creates kind cluster
#
# ARGS:
#   - $1  : ARRAY  :  ("<[region_name]> | required" "<[cluster_name]> | required" "<[dependency_name]> | required" "<[chart_name]> | required" "<[dependency]> | required" ) : array items must follow the order specified.
#
# RETURN:
#   - null
#
function funcEksCtl () {
  eksctl create cluster \
    --region us-east-1 \
    --profile k8s-admin \
    --name dev \
    --version 1.22 \
    --nodegroup-name standard-workers \
    --node-type t4g.large \
    --nodes 5 \
    --managed
    # --nodes-min 1 \
    # --nodes-max 10 \

  eksctl utils write-kubeconfig \
    --cluster dev \
    --region us-east-1 \
    --profile k8s-admin

  # Change name
  kubectl config rename-context k8-admin@dev.us-east-1.eksctl.io dev

  eksctl delete cluster \
    --region us-east-1 \
    --profile k8s-admin \
    --name dev

  aws ecr get-login-password \
    --region us-east-1 \
    --profile k8s-admin |
      docker login \
        --username AWS \
        --password-stdin \
        076081023637.dkr.ecr.us-east-1.amazonaws.com

  # TODO: with terraform, create ecr repositories and s3, etc

  docker tag apis-rust 076081023637.dkr.ecr.us-east-1.amazonaws.com/apis-rust:latest
  docker push 076081023637.dkr.ecr.us-east-1.amazonaws.com/apis-rust:latest
}

function funcKindClusterCreate () {
  # Clears all cache file. For local run this:
  docker system prune --all --force
  kind create cluster --name="${PLATFORM}" --config="./kind-config.yaml"
  kubectl cluster-info --context "kind-${PLATFORM}"
  kubectl config get-contexts
  kubectl config use-context kind-"${PLATFORM}"
  # minikube start --cpus 6 --memory 15987
  # bash ../infrastructure-helm/main.sh -a=install
}

# funcKindClusterCreateDashboard () {
#   kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
# }

# # Create after pods are available
# funcKindClusterCreateServiceAccount () {
#   kubectl create serviceaccount -n kubernetes-dashboard admin-user
# }

# funcKindClusterCreateRoleBinding () {
#   kubectl create clusterrolebinding -n kubernetes-dashboard admin-user --clusterrole cluster-admin --serviceaccount=kubernetes-dashboard:admin-user
# }

# funcKindClusterGetDashboardToken () {
#   token=$(kubectl -n kubernetes-dashboard create token admin-user)
#   echo "${token}"
# }

# funcKindClusterGetPods () {
#   kubectl get pod -n kubernetes-dashboard
# }

function deleteKindCluster () {
  PLATFORM="snitzsh"
  # bash ../infrastructure-helm/main.sh -a=uninstall
  kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete
  kind delete cluster --name="${PLATFORM}"
}
