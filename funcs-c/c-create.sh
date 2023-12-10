#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - find a way to list the available k8s versions supported.
#     based on that we can fetch the kubectl, helm, and helm-chart
#     supported version for k8s is running. Currently minikube using the latest.
#
# NOTE:
#   - Creates AWS eks cluster.
#
# DESCRIPTION:
#   - Creates cluster in locally or remote.
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
  local -r cluster_type="${args[0]}"
  local -r region_name="${args[1]}"
  local -r cluster_name="${args[2]}"
  local cluster_exist="false"
  case "${cluster_type}" in
    # TODO:
    #   - fetch the region from the cluster.yaml
    #
    "aws")
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
      ;;
    "minikube")
      local profile="${cluster_type}-${region_name}-${cluster_name}"
      cluster_exist=$(\
        minikube \
          profile \
            list -o json \
          | jq --arg profile "${profile}" \
              '
                .valid[]
                | select(.Name == $profile)
                | .Name == $profile
                | .
              ' \
      )

      # Creates cluster only if it does NOT exist.
      if [ "${cluster_exist}" != "true" ]; then
        minikube \
          start \
            --cpus 6 \
            --memory "8g" \
            --driver docker \
            --profile "${profile}" \
            --addons="metrics-server"
      else
        logger "WARN" "Cluster '${profile}' already exist. Execute: 'minikube profile list' in the cli." "${func_name}"
      fi
      # echo "${SNITZSH_PATH}/boilerplate/main.sh"
      bash "${SNITZSH_PATH}/boilerplate/main.sh" c-install-argo-cd "${cluster_type}" "${region_name}" "${cluster_name}"
      # minikube profile list
      # minikube stop --profile north-america.dev
      # minikube start --profile north-america.dev # for re-starting an existing cluster.
      # minikube delete --profile north-america.qa
      ;;
    *)
      logger "ERROR" "Cluster type '${cluster_type}' does not exist. Check the arguments you passing when calling the command function in the cli." "${func_name}"
      ;;
  esac
}
