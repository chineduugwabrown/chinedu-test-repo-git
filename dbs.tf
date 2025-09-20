locals {
db_server_names = ["postgresql"]
    # --- UPDATED LOCALS FOR DATABASE CREATION ---

  # # 1. Flatten structure to get {tenant_key, db_name, charset, collation} list
  # databases_to_create_flat = flatten([
  #   for tenant_key, tenant_config in local.selected_tenants : [
  #     # Access the list WITHIN the 'db' block
  #     for db_name in tenant_config.db.logical_databases : {
  #       tenant_key = tenant_key
  #       db_name    = db_name
  #       # Look up specific config within tenant_config.db or use defaults
  #       charset = try(tenant_config.db.database_configs[db_name].charset, local.default_db_charset)
  #       collation = try(tenant_config.db.database_configs[db_name].collation, local.default_db_collation)
  #     } if try(length(tenant_config.db.logical_databases), 0) > 0 # Check list inside 'db'
  #   ]
  # ])
  # # 1. Flatten structure to get {tenant_key, db_name, charset, collation} list
  # databases_to_create_flat = flatten([
  #   for tenant_key, tenant_config in local.selected_tenants : [
  #     # Access the list WITHIN the 'db' block
  #     for db_name in tenant_config.db.logical_databases : {
  #       tenant_key = tenant_key
  #       db_name    = db_name
  #       # Look up specific config within tenant_config.db or use defaults
  #       charset = try(tenant_config.db.database_configs[db_name].charset, local.default_db_charset)
  #       collation = try(tenant_config.db.database_configs[db_name].collation, local.default_db_collation)
  #     } if try(length(tenant_config.db.logical_databases), 0) > 0 # Check list inside 'db'
  #   ]
  # ])

  # # 2. Create map for google_sql_database resource for_each
  # sql_databases_map = {
  #   for db_info in local.databases_to_create_flat :
  #   "${db_info.tenant_key}-${db_info.db_name}" => db_info
  # }
  # # 2. Create map for google_sql_database resource for_each
  # sql_databases_map = {
  #   for db_info in local.databases_to_create_flat :
  #   "${db_info.tenant_key}-${db_info.db_name}" => db_info
  # }


  # --- DNS Locals (No change needed here as they rely on module output) ---
  tenant_db_ips = {
    for tenant_key, instance_module in module.db : tenant_key =>
    try(instance_module.ips[0].address, null) # Adjust based on module output
  }
  # --- DNS Locals (No change needed here as they rely on module output) ---

  db_instance_dns_records = {
    for tenant_key, ip_address in local.tenant_db_ips :
    "${tenant_key}_db" => {
       tenant        = tenant_key
       ip_address    = ip_address
       hostname_part = "db"
    }
    if ip_address != null
  }
}

# -------------- END DATABASE LOCALS --------------
# -------------- END DATABASE LOCALS --------------

# -------------- DATABASE LOCALS --------------
# -------------- END DATABASE LOCALS --------------


# -------------------------------------------- DATABASE INSTANCE --------------------------------------------
module "db" {
  depends_on = [google_service_networking_connection.private_vpc_connection]
  # depends_on = [resource.null_resource.wait_for_kms] # Keep if KMS keys need to exist first

  # *** Iterate over the selected DB configurations from tenantdb.tf ***
  for_each         = local.selected_dbs
  source          = "/home/cugwabrown/repos/gcp-the-armory-test/modules/cloudsql-instance"
  #source           = "github.com/stackArmor/gcp-the-armory//modules/cloudsql-instance?depth=1&ref=cloudsql-instance-v0.0.2"
  # *** Iterate over the selected DB configurations from tenantdb.tf ***

  project_id       = local.project_id # Define local.project_id
  # *** Name based on the DB instance key (e.g., staging-cbp-db) ***
  name             = "${local.tenant_shortname}-${each.key}" # Define local.tenant_shortname
  region           = local.region                            # Define local.region                       # Define local.region
  # Convert string level (e.g., "STRONG") to full policy object expected by module
  password_validation_policy = lookup({
    "MEDIUM" = {
      enable_password_policy      = true
      min_length                  = 12
      complexity                  = "COMPLEXITY_DEFAULT"
      disallow_username_substring = true
      reuse_interval              = 12
      password_change_interval    = "2160h"                  # 90 days
    }
    "STRONG" = {
      enable_password_policy      = true
      min_length                  = 16
      complexity                  = "COMPLEXITY_DEFAULT"
      disallow_username_substring = true
      reuse_interval              = 24
      password_change_interval    = "2160h"                  # 90 days
    }
  }, local.db_password_policy, null)

  # --- Access values from the iterated DB config (each.value from local.selected_dbs) ---
  database_version = each.value.db.version
  disk_size        = each.value.db.disk_size
  tier             = each.value.db.tier
  flags            = merge(local.db_flags, try(each.value.db.custom_flags, {}))
  users = try(
    { for user in each.value.db.users : user => { password = null } },
    {}
  )
  labels = merge(
     try(each.value.labels, {}), # Use labels defined in tenantdb.tf for this DB instance
     { # Extract base tenant key for labeling if desired
       base_tenant = join("-", slice(split("-", each.key), 0, length(split("-", each.key))-1)),
       #####
       # Appendix M Labels
       function = "clarity-database",
       end_of_life = "2026-11-12",
       system_administrator = "security-technical-administrator",
       diagram_label = "clarity-database",
       #####
       # CM-12 Labels
       information_impact_level = "direct-impact-data"
     }
   )
  disk_autoresize_limit = try(each.value.db.disk_autoresize_limit, null)
  # --- Access values from the iterated DB config (each.value from local.selected_dbs) ---

  # --- Reference shared resources using BASE tenant key ---
  # Extract base tenant key (e.g., "staging-cbp") from the for_each key (e.g., "staging-cbp-db")
  
  encryption_key_name = module.kms_tenant[each.value.tenant_base_name].keys["${each.value.tenant_base_name}-key"].id

  #encryption_key_name = module.kms_tenant[join("-", slice(split("-", each.key), 0, length(split("-", each.key))-1))].keys["${join("-", slice(split("-", each.key), 0, length(split("-", each.key))-1))}-key"].id
  # --- Reference shared resources using BASE tenant key ---
  # Extract base tenant key (e.g., "staging-cbp") from the for_each key (e.g., "staging-cbp-db")
  # Common Configurations (assuming standard)
  maintenance_config = {
    maintenance_window = { day = 6, hour = 4, update_track = "stable" }
  }
  insights_config = {
    query_insights_enabled = true, query_plans_per_minute = 5, query_string_length = 1024, record_application_tags = true
  }
  backup_configuration = {
    enabled = true, location = "us", point_in_time_recovery_enabled = true
  }
  ssl = {
    ssl_mode = local.ssl_mode # Define local.ssl_mode
  }
  # Common Configurations (assuming standard)

  # Network Config - Use BASE tenant key for subnet lookup
# Network Config - Use PSA instead of PSC
    network_config = {
    connectivity = {
        psa_config = {
        private_network = local.project_vpc_self_link # The VPC network where the CloudSQL instance will connect
        }
        ipv4_enabled = false # Keep this to ensure no public IP is assigned
    }
    }
#   network_config = {`
    
#     # connectivity = {
#     #   psc_allowed_consumer_projects = compact([ local.project_id, try(var.core.projects.gss-prod.project_id, null) ])
#     #   psc_config = {
#     #     consumer_vpc = local.project_vpc_self_link # Define local.project_vpc_self_link
#     #     # Extract base tenant key for subnet lookup
#     #     subnet       = module.vpc-network-tenant-subnets[join("-", slice(split("-", each.key), 0, length(split("-", each.key))-1))].subnet_self_links["${local.region}/${join("-", slice(split("-", each.key), 0, length(split("-", each.key))-1))}-db-subnet"]
#     #   }
#     #   ipv4_enabled = false
#     # }
#   }
}

resource "google_compute_global_address" "private_ip_address" {
  project = local.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = local.project_vpc_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {

  network                 = local.project_vpc_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name, google_compute_global_address.filestore_ip_range.name]
}

resource "google_sql_user" "iam_group_user" {
  project    = local.project_id
  for_each = module.db
  name     = "gcp-armory-clarity-owners@thearmory.cloud"
  instance = "clarity-${each.key}"
  type     = "CLOUD_IAM_GROUP"
}

resource "google_sql_user" "editors" {
  project    = local.project_id
  for_each = module.db
  name     = "gcp-armory-clarity-${var.environment}-editors@thearmory.cloud"
  instance = "clarity-${each.key}"
  type     = "CLOUD_IAM_GROUP"
}
data "google_sql_database_instance" "db" {
  for_each = module.db
  project  = local.project_id
  name     = "clarity-${each.key}"
}

resource "google_kms_key_handle" "db-keyhandle" {
  provider               = google-beta
  project                = local.project_id
  name                   = "db-export-handle"
  location               = "us"
  resource_type_selector = "storage.googleapis.com/Bucket"
}

resource "google_storage_bucket" "sql_exports" {
  # Ensure KMS key exists and permissions are applied
  depends_on = [module.kms_shared]

  name          = "${local.tenant_shortname}-${local.environment}-sql-exports" # Added environment for clarity ${local.environment}
  project       = local.project_id
  location      = "us" # Parameterize this.

  # --- Security Enhancements ---
  force_destroy = false
  uniform_bucket_level_access = true
  public_access_prevention = "enforced"

  versioning {
    enabled = true
  }

  encryption {
    # --- UPDATED: Use the existing shared image key ---
    default_kms_key_name = google_kms_key_handle.db-keyhandle.kms_key
  }

  # --- Lifecycle rule to delete objects after 7 days ---
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 7
      matches_prefix = ["full-db/"] # Adjust prefix to match your backup structure
    }
  }

  # --- REMOVED ---
  # website { ... }
  # cors { ... }

  # --- Standard Labels ---
  labels = {
    managed-by  = "terraform"
    environment = local.environment
    component   = "shared-storage"
    # Appendix M Labels
    function             = "clarity-sql-exports"
    system-administrator = "security-technical-administrator"
    diagram-label        = "clarity-cloud-storage-bucket"
    # CM-12 Labels
    information-impact-level = "direct-impact-data"
  }
}

resource google_storage_bucket_iam_member "sql_exports_writer" {
 for_each = module.db
  bucket = google_storage_bucket.sql_exports.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${data.google_sql_database_instance.db[each.key].service_account_email_address}"
}

resource "google_storage_bucket_iam_member" "sql_exports_reader" {
  for_each = local.vm_instances_to_create
  bucket = google_storage_bucket.sql_exports.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${module.tenant_vm_role_service_accounts["${each.value.base_tenant_key}-${each.value.vm_role}"].email}"
  }
