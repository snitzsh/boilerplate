#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - findout if adding repo with project can be access by other projects.
#     else make sure the repos are global and only let the AppProject handle
#     which project has access to what repos.
#
# NOTE:
#   - when accessing argo web, you must click [refresh] so the repos connect.
#     there is a issue when applying the values, it shows in the
#     web that repos are not connect.
#   - Useful commands:
#       - helm -n argo-cd template . -s templates/app-project.yaml
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
clusterInstallArgoCD () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  local -r region_name="${args[0]}"
  local -r cluster_name="${args[1]}"
  local -r dependency_name="${args[2]}"
  local -r chart_name="${args[3]}"

  # helm dependency build
  # y70ec-lp-LSZhcv0

  local -a args_2=( \
    "get-{region_name}-{cluster_name}-dependencies-name" \
    "${region_name}" \
    "${cluster_name}" \
  )

  local -a repository_names=()

  while IFS= read -r dependency_name_2; do
    local -a args_3=( \
      "get-{region_name}-{cluster_name}-{dependencies_name}-charts-name" \
      "${region_name}" \
      "${cluster_name}" \
      "${dependency_name_2}" \
    )
    while IFS= read -r chart_name_2; do
      repository_names+=("${dependency_name_2}-${chart_name_2}")
    done < <( \
      utilQueryClustersYaml "${args_3[@]}" \
    )
  done < <( \
    utilQueryClustersYaml "${args_2[@]}" \
  )

  # echo "${repository_names[@]}"
  local argo_cd_repositories=""
  local cert=""
  cert=$(
    cat ~/.ssh/snitzsh/"${region_name}"/"${cluster_name}"/"${dependency_name}"/"${chart_name}"
  )
  # TODO:
  #   - Find out which '.type' are supported in argo
  #   - Find out if `.project` can be pass in the object
  #   - Create a project based on the name of the 'cluster name'
  #   - instead of using the same cred for each repo, do this: https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repository-credentials
  #   - depricate how it adds creds to all repos, instead
  #     create '.ssh-cred' if doesn't exist.
  #     pass dynamically the '.ssh-cred.url' value.
  # NOTE:
  #   - No need to add .type in `argo-cd.config.repositories`
  # "type": "helm",
  # "project": "default"
                  # "sshPrivateKey": $cert
  argo_cd_repositories=$(\
    jq \
      -nr \
      --arg repository_names "${repository_names[*]}" \
      --arg cert "${cert}" \
      '
        [
          (
            ($repository_names | split (" ")) as $repository_names_arr
            | $repository_names_arr
            | .[]
            | ("helm-chart-" + .) as $repository_posfix
            | {
                  "url": ("git@github.com:snitzsh/" + $repository_posfix  + ".git"),
                  "name": $repository_posfix
              }
          )
        ]
      ' \
      | yq \
          -P \
          '
            .
          ' \
  )
  # TODO:
  #   - for non-helm repos, instead to using type: helm, use type: git.
  # shellcheck disable=SC2016
  _chart_name="${chart_name}" \
  _argo_cd_repositories="${argo_cd_repositories}" \
  yq \
    -ri \
    '
      . as $init
      | env(_chart_name) as $_chart_name
      | env(_argo_cd_repositories) as $_argo_cd_repositories
      | with(.[$_chart_name].configs.repositories;
          .[$_argo_cd_repositories[].name] = {}
        )
      | .[$_chart_name].configs.repositories as $repositories_obj
      | $_argo_cd_repositories[]
      | $repositories_obj[.name] = .
      | $init[$_chart_name].configs.repositories = $repositories_obj
      | $init
    ' 'values.yaml'

  # TODO:
  #   - find a way to pass the .namespace from the object because it ensure
  #     we apply the argo-cd in the proper namespace, even if its in the
  #     default. Currenlty is using the $chart_name
  local argo_cd_installed
  argo_cd_installed=$( \
    # shellcheck disable=SC2016
    helm \
      -n "${chart_name}" \
        list \
          -o yaml \
          | \
            _chart_name="${chart_name}" \
            yq \
              '
                env(_chart_name) as $_chart_name
                | (select(.[].name == $_chart_name)) as $arr
                | $arr != null
              ' \
  )

  if [ "${argo_cd_installed}" == "false" ]; then
    # Installs the chart of helm-repo, using the repository values
    # helm \
    #   install \
    #   argo-cd argo/argo-cd \
    #   -f ./values.yaml \
    #   --namespace "${chart_name}" \
    #   --create-namespace \
    #   --version "5.51.6"

    helm dependency build
    # Install the chart of the repository, using the repository values.
    helm \
      install \
      argo-cd \
      . \
      --namespace "${chart_name}" \
      --create-namespace
  else
    helm \
      --namespace "${chart_name}" \
      upgrade \
      argo-cd \
      -f values.yaml \
      .
  fi
  # TODO:
  #   - this one fails because it doesn't initial installation is not
  #     synchronous so when this executes the password is not yet created.
  #
  local argo_cd_password
  argo_cd_password=$(\
    kubectl \
      -n "${chart_name}" \
        get secret argocd-initial-admin-secret \
          -o jsonpath="{.data.password}" \
          | base64 -d
  )
  echo "ArgoCd: Password: ${argo_cd_password}"
}
