#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - using ./hc-dependencies.yaml because it tells us what the cluster is
#     using. Technically there shouldn't be an image if its not running going to
#     be using in a cluser.
#
# DESCRIPTION:
#   - queries `../hc-dependencies.yaml` file.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function utilQueryHelmChartDependenciesFile () {
  local -r func_name="${FUNCNAME[0]}"
  local -r _path="${PLATFORM_PATH}/boilerplate/hc-dependencies.yaml"
  local -r args=("$@")
  local -r query_name="${args[0]}"

  case "${query_name}" in
    "read-hc-as-paths")
      # shellcheck disable=SC2016
      yq \
        -r \
        '
          .dependencies[]
          | .name as $depndency_name
          | .charts[]
          | $depndency_name + "/" + .name
        ' "${_path}"
      ;;
    *)
      ;;
  esac
}
