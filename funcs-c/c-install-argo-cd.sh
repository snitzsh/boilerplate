#!/bin/bash
# shellcheck source=/dev/null

#
# TODO:
#   - null
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
  # TODO: Find out which type are supported in argo
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
                  "type": "helm",
                  "name": $repository_posfix,
                  "sshPrivateKey": $cert
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
  # shellcheck disable=SC2016
  # _chart_name="${chart_name}" \
  # _argo_cd_repositories="${argo_cd_repositories}" \
  # yq \
  #   -ri \
  #   '
  #     . as $init
  #     | env(_chart_name) as $_chart_name
  #     | env(_argo_cd_repositories) as $_argo_cd_repositories
  #     | with(.[$_chart_name].configs.repositories;
  #         .[$_argo_cd_repositories[].name] = {}
  #       )
  #     | .[$_chart_name].configs.repositories as $repositories_obj
  #     | $_argo_cd_repositories[]
  #     | $repositories_obj[.name] = .
  #     | $init[$_chart_name].configs.repositories = $repositories_obj
  #     | $init
  #   ' 'values.yaml'
      # | .[].name
      # | $r_type

  # helm \
  #   install \
  #   argo-cd argo/argo-cd \
  #   --namespace "${chart_name}" \
  #   --create-namespace \
  #   --version "5.46.6"
  # helm template .

  # helm \
  #   install \
  #   argo-cd \
  #   . \
  #   --namespace "${chart_name}" \
  #   --create-namespace

  helm \
    --namespace "${chart_name}" \
    upgrade \
    argo-cd \
    . \
  # kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
}

# # Default values for argo-cd.
# # This is a YAML-formatted file.
# # Declare variables to be passed into your templates.

# replicaCount: 1
# image:
#   repository: nginx
#   pullPolicy: IfNotPresent
#   # Overrides the image tag whose default is the chart appVersion.
#   tag: ""
# imagePullSecrets: []
# nameOverride: ""
# fullnameOverride: ""
# serviceAccount:
#   # Specifies whether a service account should be created
#   create: true
#   # Automatically mount a ServiceAccount's API credentials?
#   automount: true
#   # Annotations to add to the service account
#   annotations: {}
#   # The name of the service account to use.
#   # If not set and create is true, a name is generated using the fullname template
#   name: ""
# podAnnotations: {}
# podLabels: {}
# podSecurityContext: {}
# # fsGroup: 2000

# securityContext: {}
# # capabilities:
# #   drop:
# #   - ALL
# # readOnlyRootFilesystem: true
# # runAsNonRoot: true
# # runAsUser: 1000

# service:
#   type: ClusterIP
#   port: 80
# ingress:
#   enabled: false
#   className: ""
#   annotations: {}
#   # kubernetes.io/ingress.class: nginx
#   # kubernetes.io/tls-acme: "true"
#   hosts:
#     - host: chart-example.local
#       paths:
#         - path: /
#           pathType: ImplementationSpecific
#   tls: []
#   #  - secretName: chart-example-tls
#   #    hosts:
#   #      - chart-example.local
# resources: {}
# # We usually recommend not to specify default resources and to leave this as a conscious
# # choice for the user. This also increases chances charts run on environments with little
# # resources, such as Minikube. If you do want to specify resources, uncomment the following
# # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
# # limits:
# #   cpu: 100m
# #   memory: 128Mi
# # requests:
# #   cpu: 100m
# #   memory: 128Mi

# autoscaling:
#   enabled: false
#   minReplicas: 1
#   maxReplicas: 100
#   targetCPUUtilizationPercentage: 80
#   # targetMemoryUtilizationPercentage: 80
# # Additional volumes on the output Deployment definition.
# volumes: []
# # - name: foo
# #   secret:
# #     secretName: mysecret
# #     optional: false

# # Additional volumeMounts on the output Deployment definition.
# volumeMounts: []
# # - name: foo
# #   mountPath: "/etc/foo"
# #   readOnly: true

# nodeSelector: {}
# tolerations: []
# affinity: {}