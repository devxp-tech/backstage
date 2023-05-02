# Backstage

[![main](https://github.com/devxp-tech/backstage/actions/workflows/main.yaml/badge.svg)](https://github.com/devxp-tech/backstage/actions/workflows/main.yaml)
[![Quality Gate Status](https://sonar.diegoluisi.eti.br/api/project_badges/measure?project=backstage&metric=alert_status&token=6b826098cc984faf7c32b5f980fc84ac0e3b2880)](https://sonar.diegoluisi.eti.br/dashboard?id=backstage)
[![App Status](https://argocd.diegoluisi.eti.br/api/badge?name=backstage-prd&revision=true)](https://argocd.diegoluisi.eti.br/applications/backstage-prd)

## Backstage - IDP

## Environments you need before start

| Name                      | Where to get?                                                                                                   |
| :------------------------ | :-------------------------------------------------------------------------------------------------------------- |
| GITHUB_ACCESS_TOKEN       | Generate a new personal access token in [GIthub Secure page](https://github.com/settings/tokens)                |
| AUTH_GITHUB_CLIENT_ID     | Get in [Github app ID](https://github.com/organizations/devxp-tech/settings/applications/1927877)             |
| AUTH_GITHUB_CLIENT_SECRET | Open a tiket to Devxp to share this value                                                                       |
| SONARQUBE_TOKEN           | Create a `Sonarqube` token using this [documentation](https://docs.sonarqube.org/latest/user-guide/user-token/) |

All environments above `MUST` be exported in your bash context like below:

```sh
# .bashrc or .zshrc
export GITHUB_ACCESS_TOKEN='YOUR-TOKEN-HERE'
export AUTH_GITHUB_CLIENT_ID='YOUR-TOKEN-HERE'
export AUTH_GITHUB_CLIENT_SECRET='YOUR-TOKEN-HERE'
export SONARQUBE_TOKEN='YOUR-TOKEN-HERE'
```

## Setup your hosts

You'll need to create an entry to your `/etc/hosts` to specify `backstage.local` like below:

```sh
# /etc/hosts

# ...
127.0.0.1 backstage.local
#...

```

## 🚀 Start project

You'll need `Docker` and `docker-compose` installed before you continue!

Once all you need is in your bash context, just run the commands below:

```sh
docker-compose run --rm app yarn # to install node_modules
docker-compose up -d app # to up the backstage application
```

Backstage in develop mode will be available in <http://backstage.local:3000> and it's using `GitHub SSO integration`

## 🆙 Backstage Update

```sh
docker-compose run --rm app bash
yarn backstage-cli versions:bump
```

## 🚦 Work Flux

```mermaid
graph TD;
    Dev-->Backstage;
    Backstage--create-->devxp-app;
    devxp-app-->golang;
    devxp-app-->python;
    devxp-app-->node;
    golang--new-app-->backstage-catalog;
    backstage-catalog--fetch-->github/devxp-tech/template-golang;
    backstage-catalog--fetch-->kubernetes-skelleton;
    backstage-catalog--push-->github/devxp-tech/new-app;
    kubernetes-skelleton--PullRequest-->ArgoCD;
    github/devxp-tech/new-app--workflow-->devxp-tech/.github/workflows;
    ArgoCD--pull-->helm-charts/devxp-app;
    ArgoCD--deploy-->Kubernetes;
    devxp-tech/.github/workflows--push/docker-image-->ghcr.github.com/devxp-tech;
    Kubernetes--pull/docker-image-->ghcr.github.com/devxp-tech;
    Kubernetes-->new-app;
```

## 🧩 References 

- [ArgoCD](https://github.com/devxp-tech/gitops)
- [helm-charts](https://github.com/devxp-tech/helm-charts)
- [Backstage](https://github.com/devxp-tech/backstage)
- [backstage-catalog:](https://github.com/devxp-tech/backstage-catalog)
- [template-golang](https://github.com/devxp-tech/template-golang)
- [github-workflows](https://github.com/devxp-tech/.github)


## ✨ Contributions

We ❤️ contributions big or small. [See our guide](contributing.md) on how to get started.

### Thanks to all our contributors!

<a href="https://github.com/devxp-tech/backstage/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=devxp-tech/backstage" />
</a>

Made with 💜 by DevXP-Tech.
