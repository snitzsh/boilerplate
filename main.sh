#!/bin/bash
#
# TODO:
# - Save in secrets.
#   - Repo/project
#
export PLATFORM="snitzsh"
#
# TODO:
# - Save in secrets.
#   - Repo/project
# - findout which permission would allow clone-only, currrenlty all optiosn are
#   selected when creating a token
#
export GITHUB_API_TOKEN="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"
#
# TODO:
# - Save in secrets.
#   - Repo/project
#
export MINIKUBE_NORTH_AMERICA_DEV_SLACK_BOT_OAUTH_TOKEN="xoxb-6406684014950-6398852771255-RSPwrGnOlD1JYZ8r0HLRmzF3"
#
# TODO:
# - Save in secrets.
#
export GITHUB_API_THROTTLE_INTEVAL=0 # in seconds
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
#   - ArgoCD only allows this repo.
#
export SSH_REPOSITORY_ENDPOINT="git@github.com:snitzsh"
#
# TODO:
#   - Save in secrets.
#
# NOTE:
#   - Gets the parent directory: ../../../snitzh, not ../../../snitzh/boilerplate
#
export PLATFORM_PATH=${PWD%/*}
#
# TODO:
#   - Save in secrets.
#
# NOTE:
#   - identifiers for how the repo name should be name. helm--chart...configs
#     is special case. We may change it later to helm-chart-configs...
#
export REPOSITORY_NAME_IDS="api,helm-chart,script,mobile,ui,process"
#
# TODO:
#   - Save in secrets.
#
# NOTE:
#   - list of app the platform supports. Mainly use to clone the repo and place
#     it in the right directory.
#   - Name repo rules:
#       converntion <[identifier]>-<[app_name]>-<[unique_name]>-<[programming_language]>
#       for each section "<[]>", if string has multiple words,
#         then string must be snake_cased!

#   - for repo names (that are not 3rd-party helm-chart-...-configs) must follow
#     this convention:
#     conv: <[identifier]>-<[app_name]>-<[unique_name]>-<[programming_language]>
#     Ex: `<[api|ui|script|process|mobile|db|rds|etc.]>-<[global|snitzsh|lottery|etc.]>-<[main|for_multiple_word_use_snake_case]>-<[vue|rust|nodejs|etc.]>`
#   - for proprietary helm-chart...configs should follow this convention
#     conv: helm-chart-<[app_name]>-<[identifier]>-<[unique_name]-configs
#     Ex: helm-chart-<[global|snitzsh|lottery|etc.]>-[api|ui|script|process|mobile|db|rds|etc.]-<[main|for_multiple_word_use_snake_case]>-configs
#   - for proprietary helm-chart-... follow this convention
#     conv:  helm-chart-<[app_name]>-<[identifier_in_plural. ex: uis, apis]
#
export APPS="global,snitzsh"

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
  yq '.' "$PLATFORM_PATH/boilerplate/users.yaml" \
)
export PLATFORM_USERS
#
# NOTE
#   - set as global to prevent getting the same file data in each funcs/utils
#
PLATFORM_CLUSTERS_YAML=$( \
  yq '.' "$PLATFORM_PATH/boilerplate/clusters.yaml" \
)
export PLATFORM_CLUSTERS_YAML
#
# NOTE
#   - set as global to prevent getting the same file data in each funcs/utils
#
PLATFORM_HELM_CHART_DEPENDENCIES_YAML=$( \
  yq '.' "$PLATFORM_PATH/boilerplate/hc-c-dependencies.yaml" \
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

function main () {
  local -r func_name="${FUNCNAME[0]}"
  local -r args=("$@")
  local -r command_name="${args[0]}"
  local starts_with=""
  local proceed="true"
  local dir_name=""
  local post_fix=""
  for dir in ./*/; do
    dir_name=$(basename "$dir")
    if [[ "${dir_name}" == cmds-* ]]; then
      post_fix=$(echo "${dir_name}" | sed -E 's/cmds-(.*)/\1/')
      if [[ "${command_name}" =~ ^$post_fix.*$ ]]; then
        #
        # TODO:
        #   - There must be a regex that is supported by bash to do this.
        #
        # NOTE:
        #   - handles 'hc' 'hc-c', because there is not good way to match
        #     if both starts with the same letters ('hc').
        #
        if [[ "${command_name}" =~ ^hc-c- ]]; then
          starts_with=$( \
            jq \
              -n \
              -r \
              --arg post_fix "${post_fix}" \
              --arg command_name "${command_name}" \
              '
                $post_fix
                | $command_name | split($post_fix + "-")
                | .[1]
                | .
              ' \
          )
          if [[ "${starts_with}" =~ ^c- ]]; then
            starts_with="hc-c"
          fi
        else
          starts_with="${post_fix}"
        fi
      fi
    fi
  done

  case "${starts_with}" in
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
      #       - './$PLATFORM/helm-charts-configs/<repository>/<[helm-chart]>/<[region_name]>/<[cluster_name]>'
      #         exits.
      #       - chart is updated.
      #       - chart is linted.
      #       - etc.
      #
      ;;
    "g")
      #
      # Global funcions
      #
      # - Functions interacts will local machine and local filesystem.
      #   For example create folder, pull repos, etc.
      #
      ;;
    "hc")
      #
      # Repository helm-chart functions
      #
      # - Functions that intereact with
      #   './$PLATFORM/helm-charts/<repository>/<[helm-chart]>/<[region_name]>/<[cluster_name]>'
      #   files.
      #
      # NOTE:
      #   some 'g' and 'r' commands must be execute fist before executing any of these
      #   commands.
      #
      ;;
    "hc-c")
      #
      # Repository helm-chart functions
      #
      # - Functions that intereact with
      #   './$PLATFORM/helm-charts-configs/<repository>/<[helm-chart]>/<[region_name]>/<[cluster_name]>'
      #   files.
      #
      # NOTE:
      #   some 'g' and 'r' commands must be execute fist before executing any of these
      #   commands.
      #
      ;;
    "r")
      #
      # Repository functions
      #
      # - Functions that interacts with './$PLATFORM/<[REPOSITORY_NAME_IDS]>/<repository>'
      #   files.
      #
      # NOTE:
      #   - some 'g' commands must be execute fist before executing any of these
      #     commands.
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
