#!/bin/bash

# Args
# - $1 - repos - array
cloneRepos() {
  repos=$1
  for repo in "${repos[@]}"; do
    if [ ! -d "../${repo}" ]; then
      git clone git@github.com:snitzsh/"${repo}".git ../$repo
      (cd ../$repo && echo "git fetching at $(pwd)..." && git fetch --all)
    else
      echo "${repo} is already cloned..."
      (cd ../$repo && echo "git fetching at $(pwd)..." && git fetch --all )
      echo ""
    fi
  done
}

main() {
  # boilerplate repo should not be included here.
  repos=(
    "apis-fastify"
    "composer-docker"
    "infrastructure-terraform"
    "infrastructure-helm"
    "machine-set-up"
    "mobile-nativescript"
    "website-vue"
  )
  cloneRepos $repos
}

main
