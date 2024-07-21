# Commands Playbook (to open preview cmd + shift + v)

## Create new hc-c-`<[dependency_name]>-<[chart_name]>`-configs repo

- TODO

## Update a hc-c-`<[dependency_name]>-<[chart_name]>`-configs to new version

1. Fetch new versions of all dependencies' charts

```bash
bash main.sh g-clusters-file-update-to-latest-version
```

1. Update `../<[region_name]>/<[cluster_name]>/versions/` folder of each

```bash
bash main.sh hc-c-update-versions-folder
   ```

1. Do a diff. There are three ways to make sure to safely upgrade version:
   - Compare values.yaml vs values.yaml:
   `../<[region_name]>/<[cluster_name]>/values.yaml`'s `.<[chart_name]>` properties against `../<[region_name]>/<[cluster_name]>/values/<[chart_name]>-<[new_version]>.yaml`.
   - Compare the diff current version vs latest version to see what has changed: `../<[region_name]>/<[cluster_name]>/versions/diff-current-to-latest-version-values/<[chart_name]>-values.yaml`. If a property is not used in `../<[region_name]>/<[cluster_name]>/values.yaml`, then ignore the diff.
   - Compare the diff current version vs specific version to see what has changed: `../<[region_name]>/<[cluster_name]>/versions/diff-current-to-per-newer-version-values/<[chart_name]>-<version>-values.yaml`. If a property is not used in `../<[region_name]>/<[cluster_name]>/values.yaml`, then ignore the diff.
   - Update `boilerplate./clusters.yaml`'s `.regions.<[region_name]>.clusters.<[cluster_name]>.helm_charts.dependencies[<[index]>].charts[<[index]>].version` property with one of the version listed in `.regions.<[region_name]>.clusters.<[cluster_name]>.helm_charts.dependencies[<[index]>].charts[<[index]>].releases[]`
   - To update `../<[region_name]>/<[cluster_name]>/Chart.yaml`'s `.dependecies[<[index]>].version` property:

2. Update version

```bash
bash main.sh hc-c-update-version
```

5. Fetch new versions of all dependencies' charts

```bash
bash main.sh g-clusters-file-update-to-latest-version
```

6. Update `../<[region_name]>/<[cluster_name]>/versions/` folder of each

```bash
 bash main.sh hc-update-versions-folder
```

## Create Cluster

- ArgoCd is the only chart that needs to be update as follows:
  - For local cluster:

    ```bash
    bash main.sh c-create-cluster minikube north-america dev
    ```

  - For a real cluster to be discussed...


## Install Chartmuseum CLI

- install doc: https://medium.com/stakater/using-chartmuseum-as-a-chart-repository-for-helm-b4d12205f4c9
- download binary mac amd64 https://github.com/helm/chartmuseum/releases
- untar the tgz file, cd untar-ed folder
- $ chmod 700 chartmuseum
- for mac it will throw an error about the security
  - [issue](https://www.lifewire.com/fix-developer-cannot-be-verified-error-5183898)
- mv executable file using
  - $ sudo mv chartmuseum /bin/local/bin