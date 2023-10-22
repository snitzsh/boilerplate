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
  echo "Func name: ${1}"
  bash "funcs/${1}.sh"
}

main "${1}"
