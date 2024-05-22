region = "@@aws_region@@"
environment = "@@environment@@"

tags = {
  Environment = "@@environment@@"
  GithubRepo  = "@@github_repo@@"
  GithubOrg   = "@@github_org@@"
}

platform_remote_state = {
  bucket = "@@platform_remote_state_bucket@@"
  key    = "@@platform_remote_state_key@@"
  region = "@@aws_region@@"
}
