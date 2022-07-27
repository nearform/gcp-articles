resource "google_compute_network" "vpc" {
  name                    = "${var.app_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "app" {
  name          = "${var.app_name}-subnet"
  ip_cidr_range = var.app_ip_range
  region        = var.region
  network       = google_compute_network.vpc.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "app" {
  name    = "${var.app_name}-firewall"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = [
      "8080",
      # "22" uncomment this line for ssh access to instances
    ]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["web-app"]
}