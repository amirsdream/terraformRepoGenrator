# Configure the GitLab Provider
provider "gitlab" {
  token = var.gitlab_token
}

resource "gitlab_project" "repositories" {
  for_each = { for repo in local.gitlab_repositories : repo.name => repo }

  name           = each.value.name
  path           = each.value.path
  description    = each.value.description
  namespace_id   = each.value.group_id
  default_branch = each.value.default_branch
  # default_branch = "main"
}


# Add a variable to the project
resource "gitlab_project_variable" "project_variables" {
  depends_on = [gitlab_project.repositories]
  for_each   = { for idx, repo in local.repositories_variables : idx => repo }
  project    = each.value.id
  value      = each.value.value
  key        = each.value.key
}

resource "gitlab_branch" "branch" {
  depends_on = [gitlab_project.repositories]
  for_each   = { for repo in local.repositories_id : repo.name => repo }
  project    = each.value.id
  name       = var.gitlab_common_configuration.default_branch
  ref        = "main"
}

resource "gitlab_branch_protection" "master" {
  depends_on         = [gitlab_branch.branch]
  for_each           = { for idx, repo in local.repositories_protected_branches : idx => repo }
  project            = each.value.id
  branch             = each.value.branch
  push_access_level  = "no one"
  merge_access_level = "maintainer"
}

resource "gitlab_tag_protection" "TagProtect" {
    depends_on         = [gitlab_branch.branch]
  for_each           = { for idx, repo in local.repositories_protected_tags : idx => repo }
  project             = each.value.id
  tag                 = each.value.tag
  create_access_level = "maintainer"
}

resource "null_resource" "remove_default_branch_protection" {

  depends_on = [gitlab_project.repositories]
  for_each   = { for repo in local.repositories_id : repo.name => repo }
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = (
      each.value.default_branch == var.gitlab_common_configuration.default_branch ? <<-EOT
      curl --request DELETE --header "PRIVATE-TOKEN: ${var.gitlab_token}" \
      "https://gitlab.com/api/v4/projects/${each.value.id}/protected_branches/main"
    EOT
      :
      "/bin/true"
    )
  }
}

resource "null_resource" "remove_main" {

  depends_on = [gitlab_branch.branch]
  for_each   = { for repo in local.repositories_id : repo.name => repo }
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {

    command = (
      each.value.default_branch == var.gitlab_common_configuration.default_branch ? <<-EOT
      curl --request DELETE --header "PRIVATE-TOKEN: ${var.gitlab_token}" \
      "https://gitlab.com/api/v4/projects/${each.value.id}/repository/branches/main"
    EOT 
      :
      "/bin/true"
    )
  }
}

