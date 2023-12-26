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
#   - Docs:
#     - https://eksctl.io/
#     - https://www.geeksforgeeks.org/what-is-dev-null-in-linux/
#     - https://www.cyberciti.biz/faq/how-to-redirect-output-and-errors-to-devnull/
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
  local region="us-east-1"
  local profile=""
  case "${cluster_type}" in
    #
    # TODO:
    #   - fetch the region from the cluster.yaml
    #
    # NOTE
    #   - kubeconfig is pull automatically by eksctl ONLY if you are the one
    #     that created it.
    #
    "aws")
      profile="snitzsh-super-administrator"
      # shellcheck disable=SC2016
      cluster_exist=$(\
        eksctl \
          get \
            cluster \
              --profile "${profile}" \
              --region "${region}" \
              --name "${region_name}-${cluster_name}" \
              --output yaml 2> /dev/null  \
          | \
            _region_name="${region_name}" \
            _cluster_name="${cluster_name}" \
            yq -r \
              '
                env(_region_name) as $_region_name
                | env(_cluster_name) as $_cluster_name
                | .[]
                | select(.Name == ($_region_name + "-" + $_cluster_name))
                | .Name != null
              ' \
      )

      if [ "${cluster_exist}" != "true" ]; then
        eksctl \
          create \
            cluster \
              --profile "${profile}" \
              --region "${region}" \
              --name "${region_name}-${cluster_name}" \
              --nodegroup-name standard-workers \
              --node-type t4g.large \
              --nodes 1 \
              --managed
      else
        logger "WARN" "Cluster '${region_name}-${cluster_name}' already exist in aws. Execute: 'minikube profile list' in the cli." "${func_name}"
      fi
      # Context
      local context=""
      local -a args_1=( \
        "get-context" \
        "${cluster_type}" \
        "${region_name}" \
        "${cluster_name}" \
        "${region}" \
      )
      context=$( \
        utilQueryKubeConfig "${args_1[@]}" \
      )

      local context_found=""
      context_found=$( \
        utilQueryContext "${context}" "found"
      )

      # Fetch cluster's kubeconfig
      if [ "${context_found}" == "false" ]; then
        eksctl utils write-kubeconfig \
          --cluster "${region_name}-${cluster_name}" \
          --profile "${profile}" \
          --region "${region}"
      fi

      local context_rename=""
      context_rename=$( \
        utilQueryContext "${context}" "rename"
      )
      # Renames context to stay consistent
      if [ "${context_rename}" == "true" ]; then
        local context_name=""
        context_name=$( \
          utilQueryContext "${context}" "name"
        )
        kubectl config rename-context "${context_name}" "${cluster_type}-${region_name}-${cluster_name}"
      fi
      ;;
    "minikube")
      profile="${cluster_type}-${region_name}-${cluster_name}"
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
        # TODO:
        #   - execute command even if the cluster is created
        kubectl \
          config \
            rename-context "${region_name}-${cluster_name}" "${cluster_type}-${region_name}-${cluster_name}"
      else
        logger "WARN" "Cluster '${profile}' already exist. Execute: 'minikube profile list' in the cli." "${func_name}"
      fi
      # echo "${PLATFORM_PATH}/boilerplate/main.sh"
      # bash "${PLATFORM_PATH}/boilerplate/main.sh" c-install-argo-cd "${cluster_type}" "${region_name}" "${cluster_name}"
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
