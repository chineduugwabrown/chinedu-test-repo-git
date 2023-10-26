
#resource "google_compute_network" "vpc_network1" {
#  project                 = "practice-project-338002"
#  name                    = "chinedu-vpc-network"
#  auto_create_subnetworks = false
#  mtu                     = 1460
#}
#
#resource "google_compute_subnetwork" "my-subnetwork1" {
#  name          = "chinedusubnet-subnetwork"
#  ip_cidr_range = "10.128.0.0/20"
#  region        = "us-central1"
#  network       = google_compute_network.vpc_network1.name
#}
#
#resource "google_compute_firewall" "default1" {
#  name    = "chinedu-firewall"
#  network = google_compute_network.vpc_network1.name
#
#  allow {
#    protocol = "icmp"
#  }
#
#  allow {
#    protocol = "tcp"
#    ports    = ["22", "3389"]
#  }
#
#  source_tags = ["network"]
#}
#
#
#resource "google_compute_instance" "vm-instance1" {
#  name         = "chinedu-us-vm"
#  machine_type = "e2-medium"
#  zone         = "us-central1-a"
#
#  boot_disk {
#    initialize_params {
#      image = "debian-cloud/debian-9"
#    }
#  }
#
#  network_interface {
#    network = "default"
#
#    access_config {
#    }
#  }
#}
#
#resource "google_compute_network" "vpc_network2" {
#  project                 = "practice-project-338002"
#  name                    = "brown-vpc-network"
#  auto_create_subnetworks = false
#  mtu                     = 1460
#}
#
#resource "google_compute_subnetwork" "my-subnetwork2" {
#  name          = "brownsubnet-subnetwork"
#  ip_cidr_range = "172.16.0.0/24"
#  region        = "us-central1"
#  network       = google_compute_network.vpc_network2.name
#}
#
#resource "google_compute_firewall" "default2" {
#  name    = "brown-firewall"
#  network = google_compute_network.vpc_network2.name
#
#  allow {
#    protocol = "icmp"
#  }
#
#  allow {
#    protocol = "tcp"
#    ports    = ["22", "3389"]
#  }
#
#  source_tags = ["network"]
#}
#
#resource "google_compute_instance" "vm-instance2" {
#  name         = "brown-us-vm"
#  machine_type = "e2-medium"
#  zone         = "us-central1-a"
#
#  boot_disk {
#    initialize_params {
#      image = "debian-cloud/debian-9"
#    }
#  }
#
#  network_interface {
#    network = "default"
#
#    access_config {
#    }
#  }
#}

#resource "google_pubsub_topic" "example" {
#  name = "example-topic"
#
#  labels = {
#    foo = "bar"
#  }
#
#  message_retention_duration = "86600s"
#}
#
#resource "google_storage_bucket" "auto-expire" {
#  name          = "auto-expiring-bucket"
#  location      = "US"
#  force_destroy = true
#}

resource "google_dataflow_job" "big_data_job" {
  name              = "dataflow-job"
  template_gcs_path = "gs://my-bucket/templates/template_file"
  temp_gcs_location = "gs://my-bucket/tmp_dir"
  parameters = {
    foo = "bar"
    baz = "qux"
  }
}