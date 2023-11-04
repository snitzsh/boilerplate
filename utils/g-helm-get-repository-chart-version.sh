#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - get chart version using helm command
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilGlobalHelmGetRepositoryChartVersion () {
  local version=""
  local repository_name="${1}"
  local chart_name="${2}"

  if ! helm show chart "${repository_name}/${chart_name}" &> /dev/null ; then
    version="false"
  else
    version=$(helm show chart "${repository_name}/${chart_name}" \
      | yq '.version' \
    )
  fi
  echo "${version}"
}
