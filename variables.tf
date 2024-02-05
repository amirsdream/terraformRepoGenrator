variable "gitlab_token" {
  description = "GitLab personal access token"
}

variable "gitlab_common_variables" {
  description = "Common variables applicable to all repositories"
  type        = map(string)
}

variable "gitlab_common_configuration" {
  description = "Common configuration applicable to all repositories"
  type = object({
    default_branch     = string
    protected_branches = list(string)
    protected_tags     = list(string)
  })
}

variable "gitlab_repositories" {
  description = "List of GitLab repositories"
  type = list(object({
    name        = string
    path        = string
    description = string
    group_name  = string
    group_id    = string
    variables   = map(string)
  }))
}

