terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.3.0"
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