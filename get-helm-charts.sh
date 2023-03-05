#!/bin/bash

# ARGS
# - $1 = charts
addCharts() {
  charts=$1
  for chart in "${charts[@]}"; do
    echo $chart
    # obj="${chart[@]}"
    # echo $obj
  done
}

main() {
  charts=("kyverno https://kyverno.github.io/kyverno/")
  addCharts $charts
}

main
