# <APPLICATION_NAME>

This template can be used for a single service or for a mono-repo (multi-service) setup. To convert it to a mono-repo:

1. duplicate `application/` folder
1. duplicate `.github/workflows/application.yaml` file for enabling the CI

## Initialization

To make this template functioning you have to first fill the blanks by replacing all the occurrences of:

- `<APPLICATION_NAME>` with the app name
- `<DEV_ACCOUNT_ID>` and `<PROD_ACCOUNT_ID>` with the respective AWS Account IDs
- `<GITHUB_REPO>`

in the following files:

- `.github/workflows/*`
- `deploy/application/providers.tf`
- `deploy/infrastructure/providers.tf`

Then double check the following inputs:

- `var.terraform_remote_state_key` to point to the right file for your infra.

## Folder structure

- Application source code is stored in the [`application/`](./application/) folder
- Code to perform deployments is stored in the [`deploy/`](./deploy/) folder. [deploy/infrastructure/](./deploy/infrastructure/) for ECR and IAM role. [deploy/application/](./deploy/application/) for the actual Terraform resources to deploy.

A feature we offer is to allow to deploy the application with `helm install` only instead of using Terraform to do that for you.

## Deployment

This project uses [GitHub Actions](https://docs.github.com/en/actions) to deploy the application and infrastructure. The workflow is defined in `.github/workflows/application.yaml` which uses a reusable workflow that is loaded from `https://github.com/tx-pts-dai/github-workflows`.
