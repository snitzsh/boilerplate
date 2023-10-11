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
