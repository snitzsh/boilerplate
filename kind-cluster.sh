#!/bin/bash

# Dashboard Installation:
# - https://istio.io/latest/docs/setup/platform-setup/kind/

# Docke Memory issues:
# https://stackoverflow.com/questions/58277794/diagnosing-high-cpu-usage-on-docker-for-mac
PLATFORM="snitzsh"

kindClusterCreate () {
  # Clears all cache file. For local run this:
  docker system prune --all --force
  kind create cluster --name="${PLATFORM}" --config="./kind-config.yaml"
  kubectl cluster-info --context "kind-${PLATFORM}"
  kubectl config get-contexts
  kubectl config use-context kind-"${PLATFORM}"
  # minikube start --cpus 6 --memory 15987
  # bash ../infrastructure-helm/main.sh -a=install
}

# kindClusterCreateDashboard() {
#   kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
# }

# # Create after pods are available
# kindClusterCreateServiceAccount () {
#   kubectl create serviceaccount -n kubernetes-dashboard admin-user
# }

# kindClusterCreateRoleBinding () {
#   kubectl create clusterrolebinding -n kubernetes-dashboard admin-user --clusterrole cluster-admin --serviceaccount=kubernetes-dashboard:admin-user
# }

# kindClusterGetDashboardToken () {
#   token=$(kubectl -n kubernetes-dashboard create token admin-user)
#   echo "${token}"
# }

# kindClusterGetPods () {
#   kubectl get pod -n kubernetes-dashboard
# }

deleteKindCluster () {
  # bash ../infrastructure-helm/main.sh -a=uninstall
  kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete
  kind delete cluster --name="${PLATFORM}"
}

main () {
  kindClusterCreate
}

main

# URL:
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
