#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - if ${1} is not specified it return "false"
#
# DESCRIPTION:
#   - Queries the file ~/.kube/config file.
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilQueryKubeConfig () {
  local -r _path=~/.kube/config
  local -r args=("$@")
  local -r query_name="${args[0]}"

  case "${query_name}" in
    "get-context")
      local -r cluster_type="${args[1]}"
      local -r region_name="${args[2]}"
      local -r cluster_name="${args[3]}"
      local -r region="${args[4]}"
      # shellcheck disable=SC2016
      _cluster_type="${cluster_type}" \
      _region_name="${region_name}" \
      _cluster_name="${cluster_name}" \
      _region="${region}" \
      yq \
        '
          env(_cluster_type) as $_cluster_type
          | env(_region_name) as $_region_name
          | env(_cluster_name) as $_cluster_name
          | env(_region) as $_region
          | {
              "found": false,
              "rename": false,
              "name": ""
            } as $obj
          | .contexts[]
          | select(.context.cluster == $_region_name + "-" + $_cluster_name + "." + $_region + ".*")
          | $obj.found = ((.context | type) == "!!map")
          | $obj.rename = (.name != ($_cluster_type + "-" + $_region_name + "-" + $_cluster_name))
          | $obj.name = .name
          | $obj
        ' "${_path}"
      ;;
    *)
      echo ""
      ;;
  esac
}


#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Queries the file ~/.kube/config .contexts[].context
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilQueryContext () {
  local context="${1}"
  local key="${2}"

  # shellcheck disable=SC2016
  _context="${context}" \
  _key="${key}" \
  yq \
    -rn \
    '
      env(_context) as $_context
      | env(_key) as $_key
      | $_context
      | .[$_key]
    '
}
