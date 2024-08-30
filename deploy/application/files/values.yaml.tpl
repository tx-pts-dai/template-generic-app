# https://github.com/DND-IT/helm-charts/blob/app-0.1.2/charts/app/values.yaml

aws_iam_role_arn: ${aws_iam_role_arn}
image_repo: ${image_repo}
image_tag: ${image_tag}

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

{%- if app_url_type == "path" %}
targetGroupBinding:
  enabled: ${enable_target_group_binding}
  targetGroupARN: ${target_group_arn}
{%- endif %}

{%- if app_url_type == "subdomain" %}
ingress:
  className: alb
  annotations:
  alb.ingress.kubernetes.io/scheme: internet-facing
  alb.ingress.kubernetes.io/target-type: ip
  alb.ingress.kubernetes.io/group.name: ${service_name}
  alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80,"HTTPS":443}]'
  alb.ingress.kubernetes.io/ssl-redirect: '443'
  alb.ingress.kubernetes.io/healthcheck-path: @{{ app_healthcheck_endpoint }}
  hosts: 
    - ${hostname}
  paths:
    - /
{%- endif %}

nodeSelector:
  "karpenter.sh/nodepool": default
  "kubernetes.io/arch": amd64
