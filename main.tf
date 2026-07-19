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

data "google_compute_zones" "available" {
  region = var.region
  status = "UP"
}

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
  name         = "regional-ip"
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "default-01" {
  name         = "default-01"
  machine_type = "e2-micro"
  zone         = data.google_compute_zones.available.names[0]

  tags = ["http-server", "https-server", "dns-server"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-129-19506-299-20"
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

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}


#
# Storage
#

resource "google_storage_bucket" "yumenomatayume" {
  name          = "yumenomatayume"
  location      = "US-CENTRAL1"
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

