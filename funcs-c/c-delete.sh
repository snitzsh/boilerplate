#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - fetch `region` and `profile` values from clusters.yaml
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
function clusterDelete () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  # Region Name is not the region of aws!
  local -r cluster_type="${args[0]}"
  local -r region_name="${args[1]}"
  local -r cluster_name="${args[2]}"
  local -r region="us-east-1"
  local -r profile="snitzsh-super-administrator"

  case "${cluster_type}" in
    "aws")
      # TODO:
      #   - Check if cluster exist, else skipt deletion
      eksctl \
        delete \
          cluster \
            --region "${region}" \
            --profile "${profile}" \
            --name "${region_name}-${cluster_name}"
      ;;
    "minikube")
      # TODO:
        #   - Check if cluster exist, else skipt deletion
      minikube \
        delete \
          --profile "${cluster_type}-${region_name}-${cluster_name}"
      ;;
    *)
      logger "ERROR" "Cluster type '${cluster_type}' does not exist. Check the arguments you passing when calling the command function in the cli." "${func_name}"
      ;;
  esac
  # logger "INFO" "Cluster ${cluster_name} in"
}
