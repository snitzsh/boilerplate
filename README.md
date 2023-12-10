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


### Steps to add a new helm-chart
- 1) Create a repository in `snitzsh` account
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
- create folder base on the cluster.yaml: ~/.ssh/snitzsh/north-america/dev/argo/argo-cd
- Create an ssh-key in github.
- paste it in the file (script with fetch it.)
