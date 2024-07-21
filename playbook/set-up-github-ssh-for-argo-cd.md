# Set up SSH for argo-cd

Argo cd requires to have access to version control such as github, bitbucket.
After setting up access argo-cd will be able to pull the repositories
values.yaml to deploy as part of ci/cd.

## Commands dependent on key

- `ssh` get call mainly when executing `c-install-argo-cd` command:

```bash
# NOTE:
#   - `minikube` is treated as if it was `dev`
bash main.sh c-install-argo-cd \
  --cluster-type="minikube" \
  --region-name="north-america" \
  --cluster-name="dev"
```

## If `ssh` key exist

### Step 1

Check if key exist in the machine
```bash
# NOTE
#   - clusterInstallArgoCD function pull a ssh dynamically
platform_name="$PLATFORM"
cluster_name="--cluster-name"
region_name="--region-name"
cat ~/.ssh/${platform_name}/${region_name}/${cluster_name}/argo/argo-cd
```

### Step 2

Check if key exit in [gitbub](https://github.com/settings/keys)

```bash
# Look for the key clusterInstallArgoCD is looking for
platform_name="$PLATFORM"
cluster_name="--cluster-name"
region_name="--region-name"
dependency_name="--dependency-name"
chart_name="--chart-name"

key_name="hc-c.${region_name}.${cluster_name}.${dependency_name}.${chart_name}"
```

## If `ssh` file does not exist

### Step 1 - create ssh key

```bash
platform_name="$PLATFORM"
cluster_name="--cluster-name"
region_name="--region-name"
dependency_name="--dependency-name"
chart_name="--chart-name"
# email is the owner/admin of the github account
email="narc.informant.snitch@gmail.com"
ssh-keygen -t ed25519 -f "~/.ssh/${PLATFORM}/${region_name}/${cluster_name}/${dependency_name}/${chart_name}"  -C "${email}"
```

### Step 2 - create ssh key pair

- In [github](https://github.com/settings/keys) click [New SSH key]
- Fill Form
  - Name:
    - ```bash
      # NOTE:
      #   - should follow this convention
      name="hc-c.${region_name}.${cluster_name}.${dependency_name}.${chart_name}"
      echo "$name"
      ```
  - Key type:
    - Select `Authentication Key`
  - Key
    - ```bash
      # NOTE:
      #  - Execute this command on your terminal
      pbcopy < `~/.ssh/${PLATFORM}/${region_name}/${cluster_name}/${dependency_name}/${chart_name}`
      ```

## References

- [check-for-exisiting-ssh-keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys)
- [generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [adding-a-new-ssh-key-to-your-github-account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)


## TODO

- Create a cmd that generates the key and adds it in aws secrets