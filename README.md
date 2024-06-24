# Template Generic Application for Tamedia

This repo contains a Jinja template that can be used for a single service or for a mono-repo (multi-service) setup.

This is highly recommended to be used through [Tam CLI](https://github.com/DND-IT/tam-cli) command `tam repo create`.

## Features

- CI/CD workflows for build and deployment to K8s cluster
- Infrastructure definition through Terraform
- TLS certificate deployment and validation
- Automatic DNS record creation (supports Route53 and CloudFlare)
- Folder for application source code

## How to use

It expects the following Jinja variables:

- `dns_provider` (accepts values "aws" or "cloudflare")
- `app_name`
- `matrix_envs` (list of objects for CI workflows)
- `github_repo`
- `tf_state_bucket`
- `infra_tf_state_key`
- `app_healthcheck_endpoint`
- `aws_region`

After you run it through Jinja rendering engine (or Tam CLI), then...

1. (Platform team) Update the `infra-terraform` repository to include this repo as allowed to use OIDC
1. Do a first CI run to create the infrastructure
1. Do a second CI run to deploy the application

## Folder structure

- Application source code is stored in the [`application/`](./application/) folder
- Code to perform deployments is stored in the [`deploy/`](./deploy/) folder. [deploy/infrastructure/](./deploy/infrastructure/) for ECR and IAM role. [deploy/application/](./deploy/application/) for the actual Terraform resources to deploy.

## Deployment

This project uses [GitHub Actions](https://docs.github.com/en/actions) to deploy the application and infrastructure. The workflow is defined in `.github/workflows/application.yaml` which uses a reusable workflow that is loaded from `https://github.com/tx-pts-dai/github-workflows`.

## Future works for the Platform engineers

1. Custom Python/NodeJS/Java templates. (Involve developers to provide good/standard ones? Include generation of GitIgnore too)
1. Implement scripts for [Localstack](https://www.localstack.cloud/), [Kind](https://kind.sigs.k8s.io/) and [Act](https://github.com/nektos/act) to complete local dev experience
