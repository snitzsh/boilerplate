#!/bin/bash

#
# TODO:
#   - findout if adding repo with project can be access by other projects.
#     else make sure the repos are global and only let the AppProject handle
#     which project has access to what repos.
#   - Figure out why istio-base, istio-istid and istio-gateway, must
#     be refresh when it gets deployed for the first time.
#   - figure out why argo-cd continue send notification when
#     annotations in application.yaml is removed. Findout which turns
#     the notificiations values.yaml or annotations.
#   - make sure to map the ssh-key based on the .config_repository
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
function clusterInstallArgoCD () {
  local -r func_name="${FUNCNAME[0]}"
  local -ar args=("$@")
  local -r cluster_type="${args[0]}"
  local -r region_name="${args[1]}"
  local -r cluster_name="${args[2]}"
  local -r dependency_name="${args[3]}"
  local -r chart_name="${args[4]}"
  # local -r cluster_configs="${args[5]}"
  local chart_version_number=""

  # Gets Secret
  local -r secret_file_name="local"
  local -r secret_name="${region_name}/${cluster_name}/argo/argo-cd"
  local -r secret_name_path="${CLUSTER_SSH_KEY_PATH}/${secret_name}"
  local cert=""
  cert=$(
    cat "${secret_name_path}/${secret_file_name}" 2> /dev/null
  )
  if [ -z "${cert}" ]; then
    # bash main.sh c-create-argo-cd-ssh-key --cluster-type="minikube" --region-name="north-america" --cluster-name="dev"
    logger "ERROR" "Secret don't exist. Either cmd \'c-create-argo-cd-ssh-key \' silently failed or something that creates the secrets failed" "${func_name}"
    exit 1
  fi

  local -r args_xx=( \
    "read-{region_name}-{cluster_name}-helm-charts-{dependency_name}-{chart_name}" \
    "${region_name}" \
    "${cluster_name}" \
    "argo" \
    "argo-cd" \
  )
  local -r argo_cd_namespace=$( \
    utilQueryClustersYaml "${args_xx[@]}" \
      | yq '.namespace_name' \
  )

  chart_version_number=$(
    # shellcheck disable=SC2016
    _chart_name="${chart_name}" \
    yq \
      '
        env(_chart_name) as $_chart_name
        | .dependencies[]
        | select(.name == $_chart_name)
        | .version
      ' Chart.yaml
  )

  local -a args_2=( \
    "get-{region_name}-{cluster_name}-dependencies-name" \
    "${region_name}" \
    "${cluster_name}" \
  )

  local -a ignore_repositories=( \
    "cert-manager.cert-manager" \
    "certic.adminer" \
    "external-dns.external-dns" \
    "fluent.fluent-bit" \
    "grafana.grafana" \
    "jaegertracing.jaeger" \
    "kiali.kiali-operator" \
    "kyverno.kyverno" \
    "linkerd.linkerd-crds" \
    "linkerd.linkerd-control-plane" \
    "linkerd.linkerd2-cni" \
    "metrics-server.metrics-server" \
    "prometheus-community.prometheus" \
    "stakater.reloader" \
    "vmware-tanzu.velero" \
    "knative.knative-operator" \
    "knative.knative-serving" \
    "knative.knative-eventing" \
    "snitzsh.api-main" \
    "snitzsh.ui-main" \
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
      if [[ " ${ignore_repositories[*]} " =~ [[:space:]]${chart_name_2}[[:space:]] ]]; then
        continue
      fi
      repository_names+=("${dependency_name_2}-${chart_name_2}")
    done < <( \
      utilQueryClustersYaml "${args_3[@]}" \
    )
  done < <( \
    utilQueryClustersYaml "${args_2[@]}" \
  )

  local -a args_4=( \
    "get-{region_name}-{cluster_name}-helm-charts-dependencies" \
    "${region_name}" \
    "${cluster_name}" \
  )

  local dependencies
  dependencies=$( \
    utilQueryClustersYaml "${args_4[@]}" \
  )

  # shellcheck disable=SC2016
  dependencies=$( \
    _ignore_repositories="${ignore_repositories[*]}" \
    _dependencies="${dependencies}" \
    yq \
      -n \
      '
        env(_ignore_repositories) as $_ignore_repositories
        | ($_ignore_repositories | split(" ")) as $_ignore_repositories
        | env(_dependencies) as $_dependencies
        | del($_dependencies[]
            | .name as $dependency_name
            | .charts[]
            | select($dependency_name + "." + .name as $item | ($_ignore_repositories[] as $filter | $item | contains($filter)))
          )
        | $_dependencies
        | [.[] | select(.charts | length > 0)]
      ' \
  )
  echo "${repository_names[@]}"
  local argo_cd_repositories=""
  #
  # TODO:
  #   - Create a cli questions to decide which repos should included/excluded.
  #   - Find out which '.type' are supported in argo
  #   - Find out if `.project` can be pass in the object
  #   - instead of using the same cred for each repo, do this: https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repository-credentials
  #
  # NOTE:
  #   - No need to add .type in `argo-cd.config.repositories`
  #
  #   - these key/values were commented, but read the todos to see if
  #     it should be used as part of the obeject this `jq` returns:
  #               "type": "helm",
  #               "project": "default"
  #
  # TODO:
  #  make sure you check logic for api-main instead of apis in other cmds.
  #

  # shellcheck disable=SC2016
  argo_cd_repositories=$( \
    _ssh_repository_endpoint="${SSH_REPOSITORY_ENDPOINT}" \
    _dependencies="${dependencies}" \
    yq \
      -n \
      '
        env(_ssh_repository_endpoint) as $_ssh_repository_endpoint
        | env(_dependencies) as $_dependencies
        | $_dependencies[]
        | .name as $dependency_name
        | .charts[]
        | .name as $chart_name
        | ("helm-chart-" + $dependency_name + "-" + $chart_name + "-configs") as $repository_name
        | {
            "url": ($_ssh_repository_endpoint + "/" + $repository_name + ".git"),
            "name": $repository_name
          } as $obj
        | [$obj]
      ' \
  )

  # echo "${argo_cd_repositories}"
  # exit 1
  local managed_by="argo-cd"
  local use_helm_hooks="false" # yq will treat it as boolean.
  #
  # TODO:
  #   - for non-helm repos, instead to using type: helm, use type: git.
  #     findout if we even need it.
  #   - in function funcHelmChartConfigsUpdateValuesAddDependencyNameAsProperty
  #     make sure it doens't interfer with this function.
  #   - add helm-charts property with all the chart list from /$PLATFORM/boilerplate/clusters.yaml
  #   - Find out why `yq` do not update some existing commnent. File a bug
  #     report in git if you have time.
  #   - make sure when update hc-c-...-configs to newer version the argo-cd.main.dependecies
  #     are also updated.
  #
  # NOTE:
  #   - Creates repository template in
  #     `[chart_name].configs.credentialsTemplate`.
  #   - `str_env()` loads the cert. using `env()` will make it fail.
  #   - when deleting a key, it removes the comment on top, so this make
  #     sures it generates new comment when re-arranging the keys.
  #   - be caucious about adding comments. Open at the file is updating to
  #     make sure the comments are not DUPLICATED.
  #
  # DESCRIPTION:
  #   - it adds/updates `.[$_chart_name].configs.repositories` key/value.
  #   - it adds/updates `.[$_chart_name].configs.credentialTemplates` key/value.
  #   - it adds/updates `.cluster_name` key/value.
  #   - it adds/updates `.ssh_repository_endpoint` key/value.
  #   - it adds `.dependencies` key/value.
  #   - ... (add keys before it moves .[$_chart_name])
  #   - it moves `.[$_chart_name]` key/value to the bottom of the file for
  #     better readability.
  #
  # shellcheck disable=SC2016
  _func_name="${func_name}" \
  _platform="${PLATFORM}" \
  _ssh_repository_endpoint="${SSH_REPOSITORY_ENDPOINT}" \
  _cluster_type="${cluster_type}" \
  _region_name="${region_name}" \
  _cluster_name="${cluster_name}" \
  _chart_name="${chart_name}" \
  _managed_by="${managed_by}" \
  _use_helm_hooks="${use_helm_hooks}" \
  _dependencies="${dependencies}" \
  _cert="${cert}" \
  _argo_cd_repositories="${argo_cd_repositories}" \
  yq \
    -ri \
    '
      env(_func_name) as $_func_name
      | env(_platform) as $_platform
      | env(_ssh_repository_endpoint) as $_ssh_repository_endpoint
      | env(_cluster_type) as $_cluster_type
      | env(_region_name) as $_region_name
      | env(_cluster_name) as $_cluster_name
      | env(_chart_name) as $_chart_name
      | env(_managed_by) as $_managed_by
      | env(_use_helm_hooks) as $_use_helm_hooks
      | env(_dependencies) as $_dependencies
      | strenv(_cert) as $_cert
      | env(_argo_cd_repositories) as $_argo_cd_repositories
      | "ssh-" + $_platform + "-credential" as $new_key
      | ("DO NOT manually update this value. This property was initially auto generated by {_func_name} in boilerplate repository." | sub("{_func_name}", $_func_name)) as $key_comment
      | "DO NOT manually update this value. This property was initially auto generated by funcHelmChartConfigsUpdateValuesAddDependencyNameAsProperty in boilerplate repository." as $chart_comment
      | . as $init
      | with(.[$_chart_name].configs.repositories;
          .[$_argo_cd_repositories[].name] = {}
        )
      | .[$_chart_name].configs.repositories as $repositories_obj
      | $_argo_cd_repositories[]
      | $repositories_obj[.name] = .
      | $init[$_chart_name].configs.repositories = $repositories_obj
      | ($init[$_chart_name].configs.repositories[.name] | key) linecomment=$key_comment
      | $init
      | .
      | with(.[$_chart_name].configs.credentialTemplates;
          .[$new_key] = {
            "url": $_ssh_repository_endpoint,
            "sshPrivateKey": $_cert
          }
          | (.[$new_key] | key) linecomment=$key_comment
        )
      | with(.main;
          .nameOverride = ""
          | .fullnameOverride = ""
          | .cluster_type = $_cluster_type
          | .region_name = $_region_name
          | .cluster_name = $_cluster_name
          | .ssh_repository_endpoint = $_ssh_repository_endpoint
          | .managed_by = $_managed_by
          | .use_helm_hooks = $_use_helm_hooks
          | .dependencies = $_dependencies
        )
      | {$_chart_name: .[$_chart_name]} as $chart_values
      | del(.[$_chart_name])
      | . as $root
      | with($root;
          . |= . *+ $chart_values
        )
      | $root
      | (.["main"].cluster_type | key) linecomment=$key_comment
      | (.["main"].region_name | key) linecomment=$key_comment
      | (.["main"].cluster_name | key) linecomment=$key_comment
      | (.["main"].ssh_repository_endpoint | key) linecomment=$key_comment
      | (.["main"].managed_by | key) linecomment=$key_comment
      | (.["main"].use_helm_hooks | key) linecomment=$key_comment
      | (.[$_chart_name] | key) headComment=$chart_comment
      | .
    ' "values.yaml"

  sleep 1

  local argo_cd_installed
  argo_cd_installed=$( \
    # shellcheck disable=SC2016
    helm \
      -n "${argo_cd_namespace}" \
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
  #
  # TODO:
  #   - Find out if we can make argo-cd point to itself for minikube.
  #     else it will failed to deploy itself with no error, it just the
  #     applications will not show. Check if we need to re-start localhost.
  #     find a way if we can pass a new property, to check if we need to
  #     push changes if `managed-by: argo-cd` or `manage-by: helm`
  #
  # NOTE:
  #   - Pulls chart for ./charts. This is useful for initial local deployment.

  # Pulls dependencies for local execution.
  if ! [ -f "./charts/argo-cd-${chart_version_number}.tgz" ]; then
    helm dependency build
  fi

  if [ "${argo_cd_installed}" == "false" ]; then
    #
    # NOTE:
    #   - Installs the chart from `helm` repository list, using the our
    #     repository values.
    #
    # helm \
    #   install \
    #   argo-cd argo/argo-cd \
    #   -f ./values.yaml \
    #   --namespace "${chart_name}" \
    #   --create-namespace \
    #   --version "5.51.6"
    # helm dependency build
    #
    # NOTE:
    #  - Install the chart of the repository, using the repository values.
    #
    helm \
      install \
      --set  managed_by=Helm \
      --set use_helm_hooks="true" \
      argo-cd \
      . \
      --namespace "${chart_name}" \
      --create-namespace
  else
    echo ""
    helm \
      --namespace "${chart_name}" \
      upgrade \
      argo-cd \
      -f values.yaml \
      .
  fi
  #
  # TODO:
  #   - this one fails because it doesn't initial installation is not
  #     synchronous so when this executes the password is not yet created.
  #   - create aws secrets and pull it with external-secrets or sealedsecret.
  #   - Add this command as part of notes in chart, create a command to handle
  #     this.
  #
  #   - Only output password for minikube (local) development
  #
  local argo_cd_password
  argo_cd_password=$(\
    kubectl \
      -n "${chart_name}" \
        get secret argocd-initial-admin-secret \
          -o jsonpath="{.data.password}" \
          | base64 -d
  )
  echo "ArgoCD: Password: ${argo_cd_password}"
}
