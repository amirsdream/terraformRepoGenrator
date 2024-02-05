terraform {
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/54544031/terraform/state/REPOSITORIES_STATE1"
    lock_address   = "https://gitlab.com/api/v4/projects/54544031/terraform/state/REPOSITORIES_STATE1/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/54544031/terraform/state/REPOSITORIES_STATE1/lock"
    username       = "terraform"
    password       = ""
    lock_method    = "POST"
    unlock_method  = "DELETE"
  }
}