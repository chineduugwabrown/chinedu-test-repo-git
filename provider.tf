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