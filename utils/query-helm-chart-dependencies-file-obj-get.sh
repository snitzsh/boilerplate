#!/bin/bash

#
# TODO:
#   - add desc, args, return
#   - maybe add a argument that can return comments if true.
#
# NOTE:
#   - when using output with jq, it will not work because it contains comments
#     that why comments are removed in the last line.
#
# DESCRIPTION:
#   - null
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
function utilQueryHelmChartDependenciesFileObjGET () {
  local -r obj="${1}"
  local -r prop="${2}"
  local output_type="${3}" # use incase we need to use jq with the output
  if [ "${output_type}" == "" ]; then
    output_type="yaml"
  fi

  # shellcheck disable=SC2016
  _obj="${obj}" \
  _prop="${prop}" \
  yq \
    -nr \
    -o "${output_type}" \
    '
      env(_obj) as $_obj
      | env(_prop) as $_prop
      | $_obj
      | .
      | .[$_prop]
      | ... comments=""
    '
}
