provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

module "terraform_cloud" {
  source  = "saidsef/terraform-cloud-oidc/gcp"
  version = "~> 1.2.0"

  project_id          = var.project_id
  pool_id             = "terraform-cloud"
  organisation        = "yumenomatayume"
  projects            = [{ "project" : "gcp", "workspace" : "gcp" }]
  attribute_condition = "assertion.sub.startsWith('organization:yumenomatayume')"
}
