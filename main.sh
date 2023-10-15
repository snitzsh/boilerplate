#!/bin/bash
#
# TODO:
# - Save in secrets.
#
export GITHUB_API_TOKEN="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"
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
  echo "Func name: ${1}"
  bash "funcs/${1}.sh"
}

main "${1}"
