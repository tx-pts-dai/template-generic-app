# {{ application_name }}

This Jinja2 template can be used for a single service or for a mono-repo (multi-service) setup.

It expects the following Jinja2 variables:

- `dns_provider` (accepts values "aws" or "cloudflare")

To convert it to a mono-repo:

1. duplicate `application/` folder
1. duplicate `.github/workflows/application.yaml` file for enabling the CI

## Initialization

To make this template functioning you have to first fill the blanks by replacing all the occurrences of:

- `{{ application_name }}` with the app name
- `{{ dev_account_id }}` and `{{ prod_account_id }}` with the respective AWS Account IDs
- `{{ dev_hostname }}` and `{{ prod_hostname }}` with the respective DNS values
- `{{ github_repo }}`
- `{{ aws_region }}`

Then double check the following inputs:

- `var.terraform_remote_state_key` to point to the right file for your infra.
- `var.provisioner_group` to use the right provisioner group based on the ones available.

Then...

1. (Platform team) Update the `infra-terraform` repository to include this repo as allowed to use OIDC
1. Do a first run to create the infrastructure
1. Do a second run to deploy the application
1. Profit (?)

## Folder structure

- Application source code is stored in the [`application/`](./application/) folder
- Code to perform deployments is stored in the [`deploy/`](./deploy/) folder. [deploy/infrastructure/](./deploy/infrastructure/) for ECR and IAM role. [deploy/application/](./deploy/application/) for the actual Terraform resources to deploy.

A feature we offer is to allow to deploy the application with `helm install` only instead of using Terraform to do that for you.

## Deployment

This project uses [GitHub Actions](https://docs.github.com/en/actions) to deploy the application and infrastructure. The workflow is defined in `.github/workflows/application.yaml` which uses a reusable workflow that is loaded from `https://github.com/tx-pts-dai/github-workflows`.

## Future works for the Platform engineers

1. Auto-configure (`AWS_REGION`, `AWS_ACCOUNT_ID`, precommit, clone the repo, ...) through cli tool (wip)
1. Create ACM certificate automatically + DNS validation (module?) through CloudFlare or Route53 + injection into the service annotations
1. Custom Python/NodeJS/Java templates. (Ask developers to provide good/standard ones? Include generation of GitIgnore too)
1. Implement scripts for [Localstack](https://www.localstack.cloud/), [Kind](https://kind.sigs.k8s.io/) and [Act](https://github.com/nektos/act) to complete local dev experience

## Requirements

Foundational infrastructure must have:

- external-dns
- AWS Load Balancer controller
- ... (growing list) ...
