/*
data "google_client_config" "current" {}

output "active_project" {
  value = data.google_client_config.current.project
}

output "active_region" {
  value = data.google_client_config.current.region
}

# Cloud SQL PostgreSQL instance
resource "google_sql_database_instance" "postgres_instance" {
  name             = "lekcub-postgre-instance"
  database_version = "POSTGRES_15"
  region           = "us-central1"

  depends_on = [
    google_project_service.cloud_sql_admin,
    google_project_service.compute,
    google_project_iam_member.tf_cloudsql_admin,
    google_project_iam_member.tf_compute_network_admin,
    google_project_iam_member.tf_service_usage_admin,
    google_project_iam_member.tf_service_account_user,
    google_project_iam_member.tf_project_viewer
  ]

  settings {
    tier              = "db-f1-micro" # 1 vCPU, 3.75GB RAM
    availability_type = "ZONAL"            # or REGIONAL for HA
    disk_size         = 20                 # GB
    disk_type         = "PD_SSD"           # SSD disk
    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
    }

    dynamic "password_validation_policy" {
      for_each = var.password_validation_policy != null ? [""] : []
      content {
        complexity = (
          var.password_validation_policy.default_complexity == true
          ? "COMPLEXITY_DEFAULT"
          : null # "COMPLEXITY_UNSPECIFIED" generates a permadiff
        )
        disallow_username_substring = (
          var.password_validation_policy.disallow_username_substring
        )
        enable_password_policy   = var.password_validation_policy.enabled
        min_length               = var.password_validation_policy.min_length
        password_change_interval = (
          var.password_validation_policy.change_interval == null
          ? null
          : "${var.password_validation_policy.change_interval}s"
        )
        reuse_interval = var.password_validation_policy.reuse_interval
      }
    }

    ip_configuration {
      ipv4_enabled = true
      # require_ssl is not a valid argument in ip_configuration for postgres instances.
      # To enforce SSL, configure database flags or use client connection options (e.g., sslmode=require),
      # or prefer private IP + Cloud SQL Auth Proxy for secure connectivity.
      authorized_networks {
        name  = "office"
        value = "173.69.155.130/32" # Inserted current public IPv4
      }
    }
  }

  deletion_protection = var.terraform_deletion_protection
}

# Create a database inside the instance
resource "google_sql_database" "default_db" {
  name     = "lekcub-mydatabase"
  instance = google_sql_database_instance.postgres_instance.name
}

# Create a user
resource "google_sql_user" "default_user" {
  name     = "lekcub-user"
  instance = google_sql_database_instance.postgres_instance.name
  password = "mypassword123!"  # Use Secret Manager in real setups
}
*/
