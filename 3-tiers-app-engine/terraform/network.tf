resource "google_compute_network" "vpc" {
  name                    = "${var.app_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "data" {
  name                     = "${var.app_name}-data-subnet"
  ip_cidr_range            = var.app_ip_range
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}
