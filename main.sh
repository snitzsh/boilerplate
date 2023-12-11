#!/bin/bash
#
# TODO:
# - Save in secrets.
#   - Repo/project
#
export GITHUB_API_TOKEN=""
#
# TODO:
# - Save in secrets.
#
export GITHUB_API_THROTTLE_INTEVAL=30000 # in seconds
#
# TODO:
# - Save in secrets.
#
export GITHUB_DOMAIN="https://api.github.com"
#
# TODO:
#   - Save in secrets.
#
# NOTE:
#   - Gets the parent directory: ../../../snitzh, not ../../../snitzh/boilerplate
#
export SNITZSH_PATH=${PWD%/*}
#
# TODO:
#   - null
#
# NOTE:
#   - For more reex info: https://semver.org
#   - SemVer version that is use to validate
#   - Checks for v0.0.0 or 0.0.0
#     -> it cannot have leading 0s like: 01.01.01
#   - if not match check version manually
#   - other useful regex
#     v0.0.0 or 0.0.0
#     ^(v[0-9]|v[1-9]\d*|0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$
#
# semver. Ex: https://regex101.com/r/vkijKf/1/
#   Ex: 0.0.0 | 0.0.0-beta-1
export PLATFORM_REGEX_SEMVER="^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"
# v0.0.0
export PLATFORM_REGEX_V_X_X_X="^(v[0-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$"
# 0.0.0
export PLATFORM_REGEX_X_X_X="^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$"
#
export PLATFORM_REGEX_EXTRACT_X_X_X="([0-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)"
# 0
export PLATFORM_REGEX_ONLY_NUMBERS="^[0-9]*$"
#
# NOTE
#   - set as global to prevent getting the same file data in each funcs/utils
#
PLATFORM_USERS=$( \
  yq '.' "$SNITZSH_PATH/boilerplate/users.yaml" \
)
export PLATFORM_USERS
#
# NOTE
#   - set as global to prevent getting the same file data in each funcs/utils
#
PLATFORM_CLUSTERS_YAML=$( \
  yq '.' "$SNITZSH_PATH/boilerplate/clusters.yaml" \
)
export PLATFORM_CLUSTERS_YAML
#
# NOTE
#   - set as global to prevent getting the same file data in each funcs/utils
#
PLATFORM_HELM_CHART_DEPENDENCIES_YAML=$( \
  yq '.' "$SNITZSH_PATH/boilerplate/helm-chart-dependencies.yaml" \
)
export PLATFORM_HELM_CHART_DEPENDENCIES_YAML

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Executes a script file inside `./funcs` folder.
#
# ARGS:
#   - $1 : name of the file located in `./funcs` folder. : <[file name]>
#
# RETURN:
#   - null
#
main () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r command_name="${args[0]}"
  local starts_with=""
  local proceed="true"

  # Gets the first character.
  starts_with=$(\
    jq \
      -n \
      -r \
      --arg command_name "${command_name}" \
      '
        $command_name | split("-")
        | .[0]
      '
  )

  case "${starts_with}" in
    "g")
      #
      # Global funcions
      #
      # - Functions interacts will local machine and local filesystem.
      #   For example create folder, pull repos, etc.
      #
      ;;
    "r")
      #
      # Repository functions
      #
      # - Functions that interacts with './snitzsh/helm-charts/<repository>'
      #   files.
      #
      # NOTE:
      #   - some 'g' commands must be execute fist before executing any of these
      #     commands.
      #
      ;;
    "hc")
      #
      # Repository helm-chart functions
      #
      # - Functions that intereact with
      #   './snitzsh/helm-charts/<repository>/<[helm-chart]>/<[region_name]>/<[cluster_name]>'
      #   files.
      #
      # NOTE:
      #   some 'g' and 'r' commands must be execute fist before executing any of these
      #   commands.
      #
      ;;
    "t")
      #
      # Terraform functions
      #
      # - Functions that interact with terraform -> aws account.
      #
      #   >>> In the works... <<<
      ;;
    "c")
      #
      # Cluster functions
      #
      # - Functions that executes commands to interact with the cluster using
      #   directly. Some commands are: kubectl eksctl, argo, argocd, etc.
      #
      # NOTE:
      #   - Some 'g' 'r' `hc` commands must be executed first,
      #     for example:
      #       - ensure that cluster exist in cluster.yaml.
      #       - './snitzsh/helm-charts/<repository>/<[helm-chart]>/<[region_name]>/<[cluster_name]>'
      #         exits.
      #       - chart is updated.
      #       - chart is linted.
      #       - etc.
      #
      ;;
    *)
      proceed="false"
      logger "ERROR" "cmds-${starts_with} folder does not exits" "${func_name}"
      ;;
  esac

  if [ "${proceed}" == "false" ]; then
    exit 1
  fi

  bash "cmds-${starts_with}/${1}.sh" "${args[@]}"
}

main "$@"
