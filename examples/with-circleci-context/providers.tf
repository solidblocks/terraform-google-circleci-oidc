terraform {
  required_providers {
    circleci = {
      source  = "mrolla/circleci"
      version = "0.6.1"
    }
  }
}

provider "circleci" {
  organization = local.circleci_organization_name
}

provider "google" {
  project = local.gcp_project_id
}
