provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

module "terraform_cloud" {
  source  = "saidsef/terraform-cloud-oidc/gcp"
  version = "~> 1.2.0"

  project_id          = var.project_id
  pool_id             = "terraform-cloud"
  organisation        = "yumenomatayume"
  projects            = [{ "project" : "gcp", "workspace" : "gcp" }]
  attribute_condition = "assertion.sub.startsWith('organization:yumenomatayume')"
}


#
# Compute
#

resource "google_compute_firewall" "allow-http" {
  name    = "default-allow-http"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow-https" {
  name    = "default-allow-https"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

resource "google_compute_firewall" "allow-dns" {
  name    = "default-allow-dns"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["53"]
  }
  allow {
    protocol = "udp"
    ports    = ["53"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["dns-server"]
}

resource "google_compute_address" "default" {
  name = "global-ip"
}

resource "google_compute_instance" "default" {
  name         = "centos01"
  machine_type = "e2-micro"
  zone         = "us-west1-b"

  tags = ["http-server", "https-server", "dns-server"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      size  = "30"
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.default.address
    }
  }

  metadata = {
    managed-by = "terraform"
  }

  metadata_startup_script = <<EOT
    sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    sudo sed -i '$ a /swapfile                                 swap                    swap    defaults        0 0' /etc/fstab
    EOT


  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}


#
# Storage
#

resource "google_storage_bucket" "yumenomatayume_default_bucket" {
  name          = "yumenomatayume_default_bucket"
  location      = "US-WEST1"
  force_destroy = false
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }
}

