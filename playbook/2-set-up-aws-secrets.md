# Set up AWS secrets

This secrets is maily use for argo-cd, running in the cluster, to be able to
pull repositories.

## Local Machine

- This is needed to create aws-secrets from local.

## Ec2

- a AWS (othe cloud) role is needed to be assign to the ec2.

## RULES

- secret name should follow this convention: `${region_name}/${cluster_name}/argo/argo-cd` in both aws secret manager and folder ssh-keygen command will generate the pub and private keys.

## FLOW

- if local shh key doesn't exist, it check cloud secret
  - if cloud secret doesn't exist
    - it creates a local ssh key, then creates a cloud secret
  - if cloud secret exit
    - it pulls it from cloud and creates the ssh key files
- if both local and cloud ssh key exist, it will upload it to github.

## Limitation

- It every key belongs to a cluster. That means for now argo-cd can only host a cluster, instead of hosting multiple clusters in the same dev (or other account). Technically all argo will have access to the same repos. But we may need to support ssh key that can be shared throughout multiple clusters. There maybe a case where the cluster may need only access to specific repos.
