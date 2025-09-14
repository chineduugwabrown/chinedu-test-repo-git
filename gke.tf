/*
resource "google_gke_backup_backup_plan" "cmek" {
  name = "gke-cmek-restore-plan"
  location = local.region
  project = local.project_id
  backup_plan = google_gke_backup_backup_plan.basic.id
  cluster = google_container_cluster.primary.id

   retention_policy {
    backup_delete_lock_days = 7
    backup_retain_days = 30
  }

  backup_config {
    include_volume_data = true
    include_secrets = true
    all_namespaces = true
    
    encryption_key {
      gcp_kms_encryption_key = google_kms_crypto_key.crypto_key.id
    }
  }
}

resource "google_gke_backup_restore_plan" "cmek_restore" {
  name = "gke-cmek-restore-plan"
  location = local.region
  project = local.project_id
  backup_plan = google_gke_backup_backup_plan.basic.id
  cluster = google_container_cluster.primary.id

# defines the configuration of the Restores created via this RestorePlan.
  restore_config {
    selected_namespaces {
      namespaces = ["rally"]  #selected namespaces to restore
    }

    namespaced_resource_restore_mode = "MERGE_REPLACE_VOLUME_ON_CONFLICT"
    volume_data_restore_policy = "REUSE_VOLUME_HANDLE_FROM_BACKUPP"

    cluster_resource_restore_scope {
      no_group_kinds = true   #restores only namespaces + PV
    }
    cluster_resource_conflict_policy = "USE_EXISTING_VERSION"
    volume_data_restore_policy_bindings {
       policy = "REUSE_VOLUME_HANDLE_FROM_BACKUP"
       volume_type = "GCE_PERSISTENT_DISK"
    }
  }
}
*/

