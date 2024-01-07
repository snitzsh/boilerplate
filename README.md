# boilerplate

Installs Repos, helm-charts, docker-compose

## Steps to set up

### 1 Step Execute

```bash
# Gets all the repos.
bash main.sh get-repository
```

### 2 Step Execute

```bash
# Creates a helm chart for each repo.
bash main.sh create-helm-chart-in-exisiting-dependencies.sh
```

### 3 Step Excute

```bash
# Patches the Chart.yaml for each repo.
bash main.sh patch-helm-chart-repos-chart-yaml-file.sh
```

### Set up Github API key (Beta)
```bash
# On ${PLATFORM} github account do the following:
# - Visit Link: "https://github.com/settings/tokens?type=beta"
# - Click [Create New Token] button
# - Fill the form with the following values:
#   - Name: "boilerplate-repository"
#   - Expire: "30 Days"
#   - Description: "This key only gives read-only permission to all repositories: public and private.""
#   - Repository access: "All repositories"
#   - Permissions: "Contents" -> Read-Only
#   - Click [Create]
#   - Copy the token and pasted it as the value for "GITHUB_API_TOKEN" variable located in ""./main.sh".
```

### Steps to add a new helm-chart
- 1) Create a repository in `${PLATFORM}` account
- 2) Share the repo to a user.
- 3) crete a X-AUTH in git
  * In https://github.com/settings/tokens
    -> Generate new token
    -> `Note` should be 'CloneOnly For Boilerplate Repo'
    -> `Expire` in 30 days.
    -> `Do not` select any boxes.
  4) Copy the token and pasted in main.sh -> GITHUB_API_TOKEN variable
- 5) In in boilerplate repository.
    * Add the helm-chart information in `clusters.yaml` and `helm-chart-dependencies.yaml`.
      (Add it in A-Z ascending order)
    * execute command: `bash main.sh g-clone-repositories`
    * execute command: `bash main.sh hc-create-chart`
    * execute command: `bash main.sh hc-update-helmignore-file`
    * execute command: `bash main.sh r-update-gitignore-file`


### ARGO CD get set up ssh key (only for local deployment)
- create folder base on the cluster.yaml: ~/.ssh/${PLATFORM}/north-america/dev/argo/argo-cd
- Create an ssh-key in github.
- paste it in the file (script with fetch it.)

# RUN MINIKUBE with istio
```bash
# https://istio.io/latest/docs/setup/getting-started/#determining-the-ingress-ip-and-ports
minikube tunnel
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "$GATEWAY_URL"
```

## Slack Setup

```bash
# 1) Download Slack, Create a workspace. I created (snitzsh)
# 2) Create a channel for each region_name per cluster_name
#    - ex: minikube-north-america-dev
# 3) https://api.slack.com/apps ,
#    - Click [Create an App]
#    - Give it a name and select the workspace (snitzsh)
# 4) Follow this example to create OAUTH https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/slack/
# 5) Cleate a channel and add the app (created above)
# 6) add annotations to each applications/edit `values.yaml`
```

# Fetch new version for clusters.yaml and hc-helm-charts
```bash
# 1) run `bash main.sh g-clusters-file-put-to-latest-version`
#    - check .releases[]
# 2) run `bash main.sh hc-update-versions-folder`
# 3) Check the versons/diff** folder to check if any of the prop you
#    currently using has change/depricated
# 4) if nothing has changes do, update cluster.yaml .version to the
#     the version you want to be.
# 5) after .version has been updated, do `bash main.sh hc-update-version`
# 6) then run again `bash main.sh g-clusters-file-put-to-latest-version` to clean up releases
# 7 run bash main.sh hc-update-versions-folder to clean up /versions a   gain
#
```
