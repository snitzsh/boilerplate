#!/bin/bash

# Args
# - $1 - repos - array
cloneRepos() {
  repos=$1
  for repo in "${repos[@]}"; do
    if [ ! -d "../${repo}" ]; then
      git clone git@github.com:snitzsh/"${repo}".git ../$repo
      (cd ../$repo && echo "git fetching at $(pwd)..." && git fetch --all)
      git_fetch
    else
      $git_fetch
      echo "${repo} is already cloned..."
      (cd ../$repo && echo "git fetching at $(pwd)..." && git fetch --all )
      echo ""
    fi
  done
}

main() {
  # boilerplate repo should not be included here.
  repos=(
    "website-vue"
    "infrastructure-terraform"
    "composer-docker"
    "composer-docker"
    "apis-fastify"
    "mobile-nativescript"
  )
  cloneRepos $repos
}

main
