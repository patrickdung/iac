terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "patrickdung"

    workspaces {
      # https://www.terraform.io/docs/language/settings/backends/remote.html#prefix
      # name = "cloudnative-quest"
      prefix = "cloudnative-quest-aws-"
    }
  }
}
