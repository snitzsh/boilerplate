#!/bin/bash
# shellcheck source=/dev/null

#
# Dashboard Installation:
# - https://istio.io/latest/docs/setup/platform-setup/kind/
#
# Docke Memory issues:
# Instance types:
# - https://stackoverflow.com/questions/58277794/diagnosing-high-cpu-usage-on-docker-for-mac
#
# Instance Price:
# - https://aws.amazon.com/ec2/pricing/on-demand/
#
# https://aws.amazon.com/ec2/instance-types/
# URL:
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
#

source "${PLATFORM_PATH}/boilerplate/funcs-g/source-funcs.sh"
source "${PLATFORM_PATH}/boilerplate/utils/source-utils.sh"

#
# TODO:
#   - cmd still in the works
#
# NOTE:
#   - null
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
function main () {
  funcKindClusterCreate
}

main
