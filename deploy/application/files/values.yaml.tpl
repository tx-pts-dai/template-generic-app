# https://github.com/DND-IT/app-helm-chart/blob/4.1.0/values.yaml

aws_iam_role_arn: ${aws_iam_role_arn}
image_repo: ${image_repo}
image_tag: ${image_tag}
probe:
  liveness: /api/health
  readiness: /api/health

env:
%{ for key, value in env_vars ~}
  ${key}: ${value}
%{ endfor ~}

ingress:
  hosts: 
    - ${hostname}

nodeSelector:
  "provisioner-group": ${provisioner_group}
  "kubernetes.io/arch": amd64

tolerations:
  - key: karpenter.sh/default
    operator: Exists
    effect: NoSchedule
