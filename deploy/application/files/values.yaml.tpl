# https://github.com/DND-IT/app-helm-chart/blob/4.1.0/values.yaml

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
  liveness: <APP_HEALTHCHECK_ENDPOINT>
  readiness: <APP_HEALTHCHECK_ENDPOINT>

env:
%{ for key, value in env_vars ~}
  ${key}: ${value}
%{ endfor ~}

ingress:
  className: alb
  annotations:
    # TODO: auto-creation of certificate and DNS record
    # alb.ingress.kubernetes.io/certificate-arn: <CERTIFICATE_ARN>
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS13-1-2-2021-06
    alb.ingress.kubernetes.io/target-type: ip
  hosts: 
    - ${hostname}

nodeSelector:
  "provisioner-group": ${provisioner_group}
  "kubernetes.io/arch": amd64

tolerations:
  - key: karpenter.sh/default
    operator: Exists
    effect: NoSchedule
