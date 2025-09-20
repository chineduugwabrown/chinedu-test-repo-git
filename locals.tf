#locals.tf
# Variables such as project_id which are dependent on the environment (prod|staging) are normalized here to simplify referencing
# This way, references can be expressed as 
# local.project_id 
# instead of 
# var.tenant_resman_project_ids[var.environment], etc

locals {
  #Project Stuff ----------------------------------------------------------------------
  environment             = var.environment
  tenant_shortname        = var.tenant_shortname
  domain                  = var.core.organization.domain
  public_zone_domain      = "${var.public_subdomain["${local.environment}"]}.${local.domain}" # e.g. clarity.thearmory.cloud
  shared_zone_domain      = "${local.tenant_shortname}.${local.domain}."
  project_id              = var.tenant_resman_project_ids[var.environment]
  project_number          = var.tenant_resman_project_numbers[var.environment]
  automation_project_id   = var.core.automation.project_id # Project ID for Automation
  region                  = var.core.regions.primary
  zone                    = "b" #var.core.zones.primary need a zones variable
  sa-aggregator-group     = "gcp-org-sa-aggregator"
  group_name              = "${local.sa-aggregator-group}@${local.domain}"

  artifact_bucket         = "armory-gss-prod-artifact-bucket"  # armory-gss-prod-artifact-bucket for Tenant Integration, this bucket has requisite resources.
  
  # KMS Stuff --------------------------------------------------------------------------
  crypto_key_rotation_period_seconds = var.core.crypto_key_rotation_period_seconds

  # Database Stuff ---------------------------------------------------------------------
  db_version              = "POSTGRES_14" # per-instance declarations implemented in tenantdb.tf)
  # db_tier                = "db-f1-micro" <-- don't use this: use this db-custom-4-15360 
  # Machine type names use the following format: db-custom-#-# Replace the first # placeholder with the number of CPUs in the machine, and the second # placeholder with the amount of memory in the machine.
  db_edition              = "ENTERPRISE" # or ENTERPRISE_PLUS
  # db_disk_size            = 10 This is commented because it will vary per tenant
  db_disk_type            = "PD_SSD" # PERSISTENT DISK SSD
  db_instance_zone        = local.zone # Replace this with local.zone
  db_instance_network     = var.tenant_resman_project_vpc_self_links[var.environment]
  db_prod_edition         = "Enterprise Plus"
  db_staging_edition      = "Enterprise"
  db_prod_tier            = "db-custom-16-64512"
  db_prod_small_tier      = "db-custom-8-16384" # 4vCPU & 16GB RAM. The maximum memory for 2 vCPUs is 2 * 6.5 GiB = 13 GiB = 13312 MiB. Valid tier: db-custom-2-13312 or db-custom-4-16128
  db_staging_tier         = "db-custom-2-8192"
  db_nonprod_tier         = "db-custom-8-16384"
  db_nonprod_small_tier   = "db-custom-4-16384" # 8vCPU & 16GB RAM. The maximum memory for 2 vCPUs is 2 * 6.5 GiB = 13 GiB = 13312 MiB. Valid tier: db-custom-2-13312 or db-custom-4-16128
  db_nonprod_plus_tier    = "db-custom-6-16384" # 4vCPU & 15GB RAM. The maximum memory for 2 vCPUs is 2 * 6.5 GiB = 13 GiB = 13312 MiB. Valid tier: db-custom-2-13312 or db-custom-4-16128
  ssl_mode                = "ENCRYPTED_ONLY"
  password_validation_policy      = var.environment == "prod" ? "STRONG" : "MEDIUM" # Options: "DISABLED", "LOW", "MEDIUM", "STRONG"
  
    # Common database flags for Cloud SQL PostgreSQL instances
# Updated Cloud SQL PostgreSQL flags combining settings from locals.tf and postgresql.conf.prod.SA
db_flags = {
  # Values from locals.tf - maintaining your existing configurations
  "cloudsql.enable_pgaudit"      = "on"              # Enable the pgaudit extension
  "pg_stat_statements.track"     = "all"             # Track all statements for pg_stat_statements
  "log_connections"              = "on"              # Log client connections
  "log_disconnections"           = "on"              # Log client disconnections
  "log_min_duration_statement"   = "1"               # From locals.tf (1ms) - different from postgresql.conf (60000ms)
  "log_statement"                = "all"             # From locals.tf - different from postgresql.conf ("ddl")
  "password_encryption"          = "scram-sha-256"   # Use SCRAM-SHA-256 for password encryption
  "ssl_min_protocol_version"     = "TLSv1.2"         # Set minimum TLS version for SSL connections
  "pgaudit.log"                  = "role"            # From locals.tf - different from postgresql.conf ("ddl,write")
  "pgaudit.role"                 = "csql_pgaudit"    # Specify the role pgaudit uses for logging control
  "cloudsql.iam_authentication"  = "on"              # Enable IAM database authentication
  "timezone"                     = "America/Los_Angeles" # Set the timezone
  "temp_file_limit"              = "16350032"
  "cloudsql.enable_pg_cron"      = "on"
  "cron.database_name"            = "niku"           # Enable pg_cron for scheduled jobs

  # Set temporary file limit
  # Additional values from postgresql.conf.prod.SA not in locals.tf
  "work_mem"                     = "32788"           # 32MB in KB
  "maintenance_work_mem"         = "1048576"         # 1 GB in KB
  "effective_io_concurrency"     = "4"
  "max_parallel_workers_per_gather" = "16"
  "wal_compression"              = "on"
  "min_wal_size"                 = "2048"            # 2GB in MB
  "max_wal_size"                 = "4096"            # 4GB in MB
  "checkpoint_completion_target" = "0.9"
  "random_page_cost"             = "3"
  "seq_page_cost"                = "1.0"
  "default_statistics_target"    = "100"
  "from_collapse_limit"          = "20"
  "join_collapse_limit"          = "20"

  # Logging configurations
  "log_replication_commands"     = "on" 
  "log_checkpoints"              = "on"
  "log_lock_waits"               = "on"
  "log_temp_files"               = "0"
  "track_io_timing"              = "on"
  "log_line_prefix"              = "%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h " # Standard log line prefix

  # Autovacuum settings
  "log_autovacuum_min_duration"  = "0"
  "autovacuum_max_workers"       = "12"
  "autovacuum_vacuum_cost_delay" = "2"               # 2ms
  #"autovacuum_vacuum_scale_factor" = "0.05"
  #"autovacuum_analyze_scale_factor" = "0.02"
  
  # Transaction behavior
  "idle_in_transaction_session_timeout" = "3600000"  # 1 hour in ms
  
  # Resource limits
  "max_locks_per_transaction"    = "1024"
  "checkpoint_timeout"            = "600"             # 10 minutes in seconds

  # Enable additional settings useful for performance monitoring
  "geqo_threshold"               = "12"              # From postgresql.conf.prod.SA
}
    
    component  = "cloudsql-postgres"

  #VM Stuff --------------------------------------------------------------------------
  # shared_image_kms_key_name = "shared-image-key"
  stig_image_name              = var.armory_images.stig_rhel8_golden_image_name #STIGGED RHEL 8 Golden Image
  # stig_image_self_link       = var.armory_images.stig_rhel8_image_selflink # Image Self Link to STIGGED RHEL 8 Golden Image
  stig_snapshot_self_link      = var.armory_images.stig_rhel8_snapshot_selflink # Snapshot Self Link to STIGGED RHEL 8 Golden Image
  staging_vm_type         = "n2-standard-4" # 2vCPU & 8GB RAM n2d-standard-2 = 2 vCPU with 8GB RaAM,
  prod_vm_type            = "n2-standard-8"  # 2vCPU & 8GB RAM n2d-highmem-2 = 2 vCPU with 16GB RaAM,
  db_specs_type           = "n2-highmem-32" # 32vCPU & 128GB RAM n2-highmem-32 = 32 vCPU with 128GB RaAM,

  stig_disk_settings = {
      prod = {
        size = 80
        type = "pd-ssd"
        source_snapshot = local.stig_snapshot_self_link
      }
      staging = {
        size = 80
        type = "pd-ssd"
        source_snapshot = local.stig_snapshot_self_link
      }
    }
  boot_disk_settings = {
    prod = {
      size = 100
      type = "pd-ssd"
    # source_disk = local.stig_image_self_link
    }
    staging = {
      size = 100
      type = "pd-ssd"
    # source_disk = local.stig_image_self_link
    }
  }

  vm_options = {
    prod = {
      allow_stopping_for_update = true
      deletion_protection       = true
    }
    staging = {
      allow_stopping_for_update = true
      deletion_protection       = false
    }
  }

   # --- VM Role Specific Named Ports (Reflecting LB ports from image) ---
  vm_named_ports = {
    app    = 8082
    bg-xog = 8082
    jasper = 8089
    admin  = 8090
    ofast  = 8043
  }
}

locals {
  # Define default disk configurations matching the original settings
  sftp_default_boot_disk = {
    initialize_params = {
      image = data.google_compute_image.golden_rhel8.self_link
      size  = "250"
      type  = "pd-ssd"
    }
    use_independent_disk = false
    auto_delete          = true
  }

  sftp_default_attached_disks = [{
    name        = "stig-volume"
    size        = "80"
    source_type = "snapshot"
    source      = var.armory_images.stig_rhel8_snapshot_selflink
    options = {
      auto_delete = true
      type        = "pd-ssd"
    }
  }]

  # Define VM configurations per environment as maps, keyed by name_suffix
  sftp_vm_configs = {
    staging = {
      "sftp-0" = { # Key is the name_suffix
        instance_type = "custom-4-8192"
        boot_disk = {
          initialize_params = {
            image = data.google_compute_image.golden_rhel8.self_link
            size  = "250" # Staging VM 0 size
            type  = "pd-standard" # Staging VM 0 type
          }
          use_independent_disk = false
          auto_delete          = true
        }
        attached_disks = [{
          name              = "stig-volume"
          size              = "80" # Staging VM 0 size
          source_type       = "snapshot"
          source            = var.armory_images.stig_rhel8_snapshot_selflink
          options           = {
             auto_delete = true
             type        = "pd-balanced"
          }
        }]
      },
      "sftp-1" = { # Key is the name_suffix
        instance_type = "custom-4-8192"
        # Omitting boot_disk and attached_disks here will use the defaults defined above
        attached_disks = [{ # Prod VM 0 settings (using original defaults)
          name              = "stig-volume"
          size              = "80"
          source_type       = "snapshot"
          source            = var.armory_images.stig_rhel8_snapshot_selflink
          options           = {
            auto_delete = true
            type        = "pd-balanced"
          }
        }]

      }
    },
    prod = {
      "sftp-0" = { # Key is the name_suffix
        instance_type = "custom-8-16384"
        boot_disk = { # Prod VM 0 settings (using original defaults)
          initialize_params = {
            image = data.google_compute_image.golden_rhel8.self_link
            size  = "250"
            type  = "pd-ssd"
          }
          use_independent_disk = false
          auto_delete          = true
        }
        attached_disks = [{ # Prod VM 0 settings (using original defaults)
          name              = "stig-volume"
          size              = "80"
          source_type       = "snapshot"
          source            = var.armory_images.stig_rhel8_snapshot_selflink
          options           = {
            auto_delete = true
            type        = "pd-ssd"
          }
        }]
      },
      "sftp-1" = { # Key is the name_suffix
        instance_type = "custom-8-16384"
        boot_disk = { # Example: Prod VM 1 with slightly different boot disk
          initialize_params = {
            image = data.google_compute_image.golden_rhel8.self_link
            size  = "250" # Larger boot disk
            type  = "pd-ssd"
          }
          use_independent_disk = false
          auto_delete          = true
        }
        # attached_disks will use the default for this VM
      }
      # Add more VM definitions here if needed for the prod environment
    }
  }

  # Select the map of VM configurations for the current environment
  # Use 'try' to safely access the map key, providing an empty map if the environment is not defined
  current_sftp_vm_map = try(local.sftp_vm_configs[var.environment], {})

}

locals {
  # ... existing locals ...

  # Map from previous step: { top_env => { namespace => [list_of_unique_subenvironments] } }
  namespace_subenvironments_by_env = {
    # Iterate through the top-level environments ("staging", "prod")
    for top_env_key, tenants_in_env in local.tenants :
    # Key is the top-level environment name
    top_env_key => {
      # For each top-level environment, create an inner map
      # Iterate over the unique namespace names found within this top-level environment
      for ns in distinct([
          # Extract namespace names from all tenants in the current top-level env
          for tenant_attrs in values(tenants_in_env) : tenant_attrs.namespace
          # Ensure namespace attribute exists to avoid errors
          if lookup(tenant_attrs, "namespace", null) != null
        ]) :
        # Key is the namespace name
        ns => distinct([
          # Value is a distinct list of subenvironments for this namespace in this top-level env
          for tenant_attrs in values(tenants_in_env) : tenant_attrs.subenvironment
          # Filter for the current namespace and ensure subenvironment exists
          if lookup(tenant_attrs, "namespace", null) == ns && lookup(tenant_attrs, "subenvironment", null) != null
        ])
    }
  }

  # Final aggregated map: { top_env => { base_namespace => [aggregated_list_of_subenvironments] } }
  aggregated_namespace_subenvironments = {
    # Iterate through the top-level environments ("staging", "prod")
    for top_env_key, namespaces_map in local.namespace_subenvironments_by_env :
    # Key is the top-level environment name
    top_env_key => {
      # Build the inner map using base namespaces as keys
      # Iterate over the distinct base namespaces calculated directly here
      for base_ns in distinct([
          # Calculate base namespaces from the keys of the current namespaces_map
          for ns in keys(namespaces_map) : split("-", ns)[0]
        ]) :
        # Key is the base namespace (e.g., "cppmfed7002")
        base_ns => distinct(flatten([
          # Value is the distinct, flattened list of subenvironments
          # Iterate through the original namespaces and their subenv lists again
          for original_ns, subenv_list in namespaces_map :
          # If the original namespace's base part matches the current base_ns
          # then include its subenv_list in the list to be flattened.
          subenv_list if split("-", original_ns)[0] == base_ns
        ]))
    }
  }


  # ... other existing locals ...
}
