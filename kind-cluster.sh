#!/bin/bash

# Dashboard Installation:
# - https://istio.io/latest/docs/setup/platform-setup/kind/

PLATFORM="snitzsh"

kindClusterCreate () {
  kind create cluster --name "${PLATFORM}"
  kubectl config get-contexts
  kubectl config use-context kind-"${PLATFORM}"
}

kindClusterCreateDashboard() {
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
}

# Create after pods are available
kindClusterCreateServiceAccount () {
  kubectl create serviceaccount -n kubernetes-dashboard admin-user
}

kindClusterCreateRoleBinding () {
  kubectl create clusterrolebinding -n kubernetes-dashboard admin-user --clusterrole cluster-admin --serviceaccount=kubernetes-dashboard:admin-user
}

kindClusterGetDashboardToken () {
  token=$(kubectl -n kubernetes-dashboard create token admin-user)
  echo "${token}"
}

kindClusterGetPods () {
  kubectl get pod -n kubernetes-dashboard
}

main () {
  kindClusterCreate
}

# URL:
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/