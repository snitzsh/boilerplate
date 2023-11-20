#!/bin/bash

#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Creates versios folder with sub-folders that will be use to keep track of
#     versions
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
utilCreateHelmChartVersionsFolder () {
  local -a folders=( \
    "tgzs" \
    "manifests" \
    "values" \
    "diff-current-to-latest-version-values" \
    "diff-current-to-per-newer-version-values" \
  )
  for folder in "${folders[@]}"; do
    mkdir -p "versions/${folder}"
    (
      cd "versions/${folder}" &&
      # Creating a dummy file to force git to track the folders,
      # otherwise git will not push empty folder.
      if [ "${folder}" == "tgzs" ]; then
        touch _test.tgz
      else
        touch _test.yaml
      fi
    )
  done
}
