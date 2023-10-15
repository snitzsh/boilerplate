#!/bin/bash

#
# TODO:
#   - regex should check white-spaces between dots.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Compare version for helm-charts
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilVersionHasLetter () {
  local -r version="${1}"
  # shellcheck disable=SC2016
  _version="${version}" \
  yq -n '
    env(_version) as $_version
    | ($_version | match("[^(\d+(\.\d+)+)]", "g"))
    | (.string | length > 0)
    | .
  '
}

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Compare version for helm-charts
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilCompareVersions () {
  local -r dependency_name="${1}"
  local -r chart_name="${2}"
  local -r current_version="${3}"
  local -r latest_version="${4}"
  echo "--- $current_version"
  # shellcheck disable=SC2016
  _dependency_name="${dependency_name}" \
  _chart_name="${chart_name}" \
  _current_version="${current_version}" \
  _latest_version="${latest_version}" \
  yq -n '
    env(_dependency_name) as $_dependency_name
    | env(_chart_name) as $_chart_name
    | env(_current_version) as $_current_version
    | env(_latest_version) as $_latest_version
    | {
        "current_version": $_current_version,
        "latest_version": $_latest_version
      } as $obj
    | $obj.trim_current_version |= ( $obj.current_version | match("\d+(\.\d+)+"; "g").string)
    | $obj.trim_latest_version |= ( $obj.latest_version | match("\d+(\.\d+)+"; "g").string)
    | $obj.trim_latest_version_number |= ( $obj.trim_latest_version | sub("[^0-9]+"; ""))
    | $obj
  '
}
