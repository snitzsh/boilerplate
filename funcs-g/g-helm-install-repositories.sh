#!/bin/bash

#
# TODO:
#   - add args, notes.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Install dependency repository locally.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
funcGlobalHelmInstallRepositories () {
  local -r func_name="${FUNCNAME[0]}"
  local -a args=("$@")
  local -r dependency_name="${args[0]}"
  local -r dependency_obj="${args[2]}"
  local repository_name=""
  repository_name=$( \
    echo "${dependency_obj}" \
    | yq \
      '
        .repository
      ' \
  )
  echo "${repository_name}"
  if ! helm repo add "${dependency_name}" "${repository_name}" &> /dev/null ; then
    logger "ERROR" "Helm repo '${dependency_name}' cannot be install. Check if repository 'name' and 'url' is valid." "${func_name}"
  else
    logger "INFO" "Helm repo '${dependency_name}' is installed." "${func_name}"
  fi
}
