locals {

  gitlab_repositories = flatten([
    for repo in var.gitlab_repositories :
    merge(
      repo,
      var.gitlab_common_configuration
    )
  ])

  repositories_id = flatten([
    for repo in local.gitlab_repositories :
    [
      for data_repo in gitlab_project.repositories : {
        id                 = data_repo.id
        name               = data_repo.name
        variables          = merge(repo.variables, var.gitlab_common_variables)
        default_branch     = data_repo.default_branch
        protected_tags     = repo.protected_tags
        protected_branches = repo.protected_branches

      }
      if repo.name == data_repo.name
    ]
  ])

  repositories_variables = flatten([
    for repo in local.repositories_id :
    [
      for key, value in repo.variables :
      merge(
        {
          id = repo.id
        },
        {
          key   = key
          value = value
        }
      )
    ]
  ])

  repositories_protected_branches = flatten([
    for repo in local.repositories_id :
    [
      for branch in repo.protected_branches :
      merge(
        {
          id = repo.id
        },
        {
          branch = branch
        }
      )
    ]
  ])

  repositories_protected_tags = flatten([
    for repo in local.repositories_id :
    [
      for tag in repo.protected_tags :
      merge(
        {
          id = repo.id
        },
        {
          tag = tag
        }
      )
    ]
  ])
}