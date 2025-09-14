

# Random suffix for instance name (optional, helps avoid name conflicts)
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Cloud SQL PostgreSQL instance
resource "google_sql_database_instance" "postgres_instance" {
  name             = "postgres-instance-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_15"
  region           = "us-central1"

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

    ip_configuration {
      ipv4_enabled    = true
      require_ssl     = false
      authorized_networks {
        name  = "office"
        value = "173.69.155.130/32" # Inserted current public IPv4
      }
    }
  }

  deletion_protection = false
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
