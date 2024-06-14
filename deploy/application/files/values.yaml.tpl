# https://github.com/DND-IT/helm-charts/blob/main/charts/app/values.yaml

aws_iam_role_arn: ${aws_iam_role_arn}
image_repo: ${image_repo}
image_tag: ${image_tag}

service:
  name: ${service_name}

port: 8080

metadata:
  deploymentAnnotations: 
    %{ for key, value in deployment_annotations ~}
      ${key}: ${value}
    %{ endfor ~}

probe:
  liveness:@{{ app_healthcheck_endpoint }}
  readiness:@{{ app_healthcheck_endpoint }}

env:
%{ for key, value in env_vars ~}
  ${key}: ${value}
%{ endfor ~}

ingress:
  className: alb
  annotations:
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS13-1-2-2021-06
    alb.ingress.kubernetes.io/target-type: ip
    external-dns.alpha.kubernetes.io/hostname: ${hostname}
  hosts: 
    - ${hostname}
  paths:
    - ${path}

nodeSelector:
  "karpenter.sh/nodepool": ${nodepool}
  "kubernetes.io/arch": ${node_selector_architecture}
