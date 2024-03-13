# <APPLICATION-NAME>

## Folder structure

- Application source code is stored in the [`app/`](./app/) folder
- Code to perform deployments is stored in the [`deploy/`](./deploy/) folder. [deploy/infra/](./deploy/infra/) for ECR and IAM role. [deploy/app/](./deploy/app/) for the actual Terraform resources to deploy (if needed)

## Deployment

This project uses [GitHub Actions](https://docs.github.com/en/actions) to deploy the application and infrastructure. The workflow is defined in `.github/workflows/main.yaml` which uses a reusable workflow that is loaded from `https://github.com/tx-pts-dai/github-workflows`.
