resource "google_compute_network" "vpc" {
  name                    = "app"
  description             = "App VPC"
  auto_create_subnetworks = false

  project                 = var.project_id
}

resource "google_compute_subnetwork" "app" {
  name          = "app-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.3.0.0/22"

  }

  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "10.3.8.0/22"
  }
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "vpc_peering" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}
