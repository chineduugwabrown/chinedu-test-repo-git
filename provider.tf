/*
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.37.0"
    }
  }

  backend "gcs" {
      bucket = "practice-project-338002-tfstate"
      prefix = "chinedu-state/chinedu-repo-2"
    
  }
}

provider "google" {
  project     = "practice-project-338002"
  region      = "us-central1"
}

*/
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.37.0"
    }
  }

  backend "gcs" {
      bucket = "lekcub-project-1-tfstate"
      prefix = ""
    
  }
}

provider "google" {
  project     = "lekcub-project-1"
  region      = "us-central1"
}

# Ensure required APIs are enabled
resource "google_project_service" "cloud_sql_admin" {
  project = "lekcub-project-1"
  service = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  project = "lekcub-project-1"
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

# IAM role bindings for Terraform service account (if provided)
resource "google_project_iam_member" "tf_cloudsql_admin" {
  count   = var.terraform_sa_email == "" ? 0 : 1
  project = "lekcub-project-1"
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${var.terraform_sa_email}"
}

resource "google_project_iam_member" "tf_compute_network_admin" {
  count   = var.terraform_sa_email == "" ? 0 : 1
  project = "lekcub-project-1"
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${var.terraform_sa_email}"
}

resource "google_project_iam_member" "tf_service_usage_admin" {
  count   = var.terraform_sa_email == "" ? 0 : 1
  project = "lekcub-project-1"
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${var.terraform_sa_email}"
}

resource "google_project_iam_member" "tf_service_account_user" {
  count   = var.terraform_sa_email == "" ? 0 : 1
  project = "lekcub-project-1"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${var.terraform_sa_email}"
}