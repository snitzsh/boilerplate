#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - if ${1} is not specified it return "false"
#
# DESCRIPTION:
#   - Queries the file clusters.yaml file.
#
# ARGS:
#   - ${1} : STRING :  "query_name"           : name of the query specified in `case` statement
#   - ${2} : ANY    :  ("a", "b") | "a" | 1   : incase the query needs an argument. Example: a query
#                                             : may need an argument to get data for specific region.
#
# RETURN:
#   - Array | Boolean : ("name1" "name2") | "false"
#
utilQueryClustersYaml () {
  local -r query_name="${1}"
  case "${query_name}" in
    # Get regions name
    # NOTE:
    #   - return names ONLY if a region has data and clusters data.
    #     Example: it will not return data if a property is `europe: {}`
    "get-regions-name")
      local -a arr=()
      while IFS= read -r value; do
        arr+=("${value}")
      done < <( \
        echo "${PLATFORM_CLUSTERS_YAML}" \
        | yq -r '
            .regions
            | del(.. | select(tag == "!!map" and length == 0))
            | .
            | keys
            | .[]
          ' \
      )
      echo "${arr[@]}"
      ;;
    "get-dependency")
      echo "true"
      ;;
    # Get clusters name.
    # NOTE:
    #   - return names ONLY if a region has data and clusters data.
    #     Example: it will not return data if a property is `europe: {}` AND
    #     `{..., europe: {clusters: {}, ...}`
    "get-{region_name}-clusters-name")
      local -a region_name="${2}"
      local -a arr=()
      # shellcheck disable=SC2016
      while IFS= read -r value; do
        arr+=("${value}")
      done < <( echo "${PLATFORM_CLUSTERS_YAML}" \
        | region="${region_name}" \
          yq '
            env(region) as $region
            | .regions[$region].clusters
            | del(.. | select(tag == "!!map" and length == 0))
            | .
            | keys
            | .[]
          ' \
      )
      echo "${arr[@]}"
      ;;
    *)
      echo "false"
      ;;
  esac
}
