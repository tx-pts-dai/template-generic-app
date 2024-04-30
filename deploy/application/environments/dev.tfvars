environment = "dev"
hostname    = "<DEV_HOSTNAME>"
deployment_annotations = {
  # downscale by default in `dev` environment over night and during the weekend
  "downscaler/downscale-period" = "Mon-Fri 22:00-22:01 Europe/Zurich"
  "downscaler/upscale-period"   = "Mon-Fri 05:00-05:01 Europe/Zurich"
}
