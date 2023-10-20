#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - A version like `v0.0.0` aren't semantic, but is common to used 'v'
#     for versioning. Ex: `git` uses `v0.0.0` versioning.
#   - Read PLATFORM_REGEX_SEMVER notes in ../main.sh
#   - The second if-statement checks for v0.0.0-blah.
#
# DESCRIPTION:
#   - Validates a version, it can be use for helm chart or other software
#
# ARGS:
#   - $1 : version : 0.0.0 | v0.0.0 | 3.1.0-beta.2 (rare) | chart version
#
# RETURN:
#   - BOOLEAN : true | false
#
utilIsSemVerValid () {
  local -r version="${1}"
  jq \
    -nr \
    --arg regex_semver "${PLATFORM_REGEX_SEMVER}" \
    --arg regex_non_semver "${PLATFORM_REGEX_NON_SEMVER}" \
    --arg regex_only_numbers "${PLATFORM_REGEX_ONLY_NUMBERS}" \
    --arg version "${version}" \
    '
      $version | test($regex_semver) as $is_valid_semver
      | {"is_valid": false} as $obj
      | $obj
      | if ($is_valid_semver) then
          .is_valid |= $is_valid_semver
        else
          .is_valid |= ($version | test($regex_non_semver))
          | if .is_valid then
            .is_valid |= ($version | split(".") | .[2] | test($regex_only_numbers))
          end
        end
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
