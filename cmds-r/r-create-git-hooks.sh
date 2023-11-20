#!/bin/bash
# shellcheck source=/dev/null

source "${SNITZSH_PATH}/boilerplate/funcs-r/source-funcs.sh"
source "${SNITZSH_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - maybe we much create a function to sync our helm-charts/ and respositories in git.
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - Exectues the function(s)
#
# ARGS:
#   - null
#
# RETURN:
#   - null
#
main () {
  # utilLooperHelmChartRepositories "update-helm-repositories"
  utilLooperHelmChartRepositories "r-create-git-hooks"
}

main
