#!/bin/bash

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
function utilQueryContext () {
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
