region = "@@aws_region@@"
environment = "@@environment@@"

tags = {
  Environment = "@@environment@@"
  GithubRepo  = "@@github_repo@@"
  GithubOrg   = "@@github_org@@"
}

platform_remote_state = {
  bucket = "@@state_bucket@@"
  key    = "@@platform_state_key@@"
  region = "@@aws_region@@"
}

infra_remote_state = {
  bucket = "@@state_bucket@@"
  key    = "@@github_repo@@/infra/@@environment@@.tfstate"
  region = "@@aws_region@@"
}
