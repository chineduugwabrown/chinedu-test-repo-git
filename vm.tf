resource "google_compute_instance" "vm-instance" {
  name         = "github-check-vm"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  /*
  depends_on = [
    google_service_account_iam_binding.admin-account-iam
  ]
  */

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  /*
  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"
  

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.email
    scopes = ["cloud-platform"]
  }
  */
  
}