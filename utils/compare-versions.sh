#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - A version like `v0.0.0` aren't semantic, but is common to used 'v'
#     for versioning. Ex: `git` uses `v0.0.0` versioning.
#   - The first if-statemnt checks for v0.0.0
#        then 0.0.0
#        then 0.0.0-beta-1
#     The reason for this if- statement order is because semver regex and v_v_v
#     regex will return true for 0.0.0, so it's better for semver regex to
#     be the last check.
#
#   - note that scan in jq throw a silent error which causes jq not to output
#     anything (not even the default object). The work around is
#     adding [EXP?] is return null.
# DESCRIPTION:
#   - Validates a version, it can be use for helm chart or other software.
#     by using 3 regexes.
#
# ARGS:
#   - $1 : version : 0.0.0 | v0.0.0 | 3.1.0-beta.2 (rare) | chart version
#
# RETURN:
#   - OBJECT : {}
#
utilGetVersionAsObj () {
  local -r version="${1}"
  jq \
    -nr \
    --arg regex_x_x_x "${PLATFORM_REGEX_X_X_X}" \
    --arg regex_v_x_x_x "${PLATFORM_REGEX_V_X_X_X}" \
    --arg regex_semver "${PLATFORM_REGEX_SEMVER}" \
    --arg regex_extract_x_x_x "${PLATFORM_REGEX_EXTRACT_X_X_X}" \
    --arg version "${version}" \
    '
      $version | test($regex_x_x_x) as $is_valid_x_x_x
      | $version | test($regex_v_x_x_x) as $is_valid_v_x_x_x
      | $version | test($regex_semver) as $is_valid_semver
      | [$version | scan($regex_extract_x_x_x; "n")?] as $x_x_x
      | {
          "is_valid": false,
          "type": null,
          "x_x_x_str": null
        } as $obj
      | $obj
      | .
      | if ($is_valid_x_x_x) then
          .is_valid |= $is_valid_x_x_x
          | .type |= "x_x_x"
          | .x_x_x_str |= ($x_x_x | .[])
        else
          if ($is_valid_v_x_x_x) then
            .is_valid |= $is_valid_v_x_x_x
            | .type |= "v_x_x_x"
            | .x_x_x_str |= ($x_x_x | .[])
          else
            if ($is_valid_semver) then
              .is_valid |= $is_valid_semver
              | .type |= "semver"
              | .x_x_x_str |= ($x_x_x | .[])
            end
          end
        end
      | if (.x_x_x_str==null) then .x_x_x_str |= [] end
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
  local -r current_version_obj="${3}"
  local -r latest_version_obj="${4}"
  echo "$chart_name"
  # shellcheck disable=SC2016
  _dependency_name="${dependency_name}" \
  _chart_name="${chart_name}" \
  _current_version_obj="${current_version_obj}" \
  _latest_version_obj="${latest_version_obj}" \
  yq -n '
    env(_dependency_name) as $_dependency_name
    | env(_chart_name) as $_chart_name
    | env(_current_version_obj) as $_current_version_obj
    | env(_latest_version_obj) as $_latest_version_obj
    | {
        "current_version": $_current_version_obj,
        "latest_version": $_latest_version_obj
      } as $obj
    | $obj
  '
}
