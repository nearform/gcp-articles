resource "google_compute_global_address" "service_range" {
  name          = "${var.app_name}-global-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.service_range.name]
}

resource "google_redis_instance" "data" {
  name               = "${var.app_name}-redis"
  region             = var.region
  tier               = "BASIC"
  memory_size_gb     = var.regis_memory_size_gb
  authorized_network = google_compute_network.vpc.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
}
