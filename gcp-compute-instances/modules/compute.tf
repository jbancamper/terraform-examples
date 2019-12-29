variable "project_name" {}
variable "instance_name" {}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "region" {
  default = "us-east4"
}

variable "zone" {
  default = "us-east4-a"
}

variable "subnet_cidr_range" {
  default = "10.128.0.0/24"
}

variable "instance_boot_disk_mode" {
  default = "READ_WRITE"
}

variable "gce_service_account_id" {
  default = "compute"
}

data "google_service_account" "compute_engine_service_account" {
  account_id = var.gce_service_account_id
}

resource "google_compute_network" "project_vpc" {
  name = "${var.project_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_subnet" {
  name = "${var.project_name}-private-subnet"
  network = google_compute_network.project_vpc.self_link
  ip_cidr_range = var.subnet_cidr_range
}

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  network = google_compute_network.project_vpc.self_link
  source_ranges = ["0.0.0.0/0"]
  direction = "INGRESS"
  target_service_accounts = [data.google_service_account.compute_engine_service_account.email]

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}

resource "google_compute_instance" "vm_instance" {
  name = var.instance_name
  machine_type = var.machine_type
  zone = var.zone
  hostname = "${var.instance_name}.${var.zone}.${var.project_name}.com"
  allow_stopping_for_update = true
  
  boot_disk {
    device_name = var.instance_name
    mode = var.instance_boot_disk_mode
    auto_delete = true

    initialize_params {
      image = "ubuntu-1804-bionic-v20191211"
      size = "15"
    }
  }

  network_interface {
    network = google_compute_network.project_vpc.self_link
    subnetwork = google_compute_subnetwork.private_subnet.self_link

    access_config {
      // auto-generates public IP with empty block
    }
  }

  service_account {
    email = data.google_service_account.compute_engine_service_account.email
    scopes = ["default"]
  }
}

