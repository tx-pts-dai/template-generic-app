# https://github.com/DND-IT/helm-charts/blob/main/charts/webapp/values.yaml

aws_iam_role_arn: ${aws_iam_role_arn}
image_repo: ${image_repo}
image_tag: ${image_tag}

service:
  targetPort: 8080 # Port on which the application is exposed on the pod

scale:
  enabled: ${scaling_enabled}
  minReplicas: 3 # Minimum number of replicas, applied only if scaling is enabled
  maxReplicas: 20
  minAvailable: 60%
  cpuThresholdPercentage: 80

metadata:
  deploymentAnnotations:
    %{ for key, value in deployment_annotations ~}
      ${key}: ${value}
    %{ endfor ~}

probe:
  liveness: @{{ app_healthcheck_endpoint }}
  readiness: @{{ app_healthcheck_endpoint }}

env:
%{ for key, value in env_vars ~}
  ${key}: ${value}
%{ endfor ~}

externalSecrets:
  secretNames:
    %{ for secret in external_secrets ~}
     - ${secret}
    %{ endfor ~}

{% if app_url_type == "path" %}
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
    alb.ingress.kubernetes.io/group.name: ${alb_group_name}
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80,"HTTPS":443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/healthcheck-path: @{{ app_healthcheck_endpoint }}
    alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS13-1-2-2021-06
  hosts:
    - ${hostname}
  paths:
    - /
{%- endif %}

nodeSelector:
  kubernetes.io/arch: amd64
