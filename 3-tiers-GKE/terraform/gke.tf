resource "google_service_account" "app" {
  account_id   = "${var.app_name}-sa"
  display_name = "3t App Service Account"
}

resource "google_container_cluster" "k8s_cluster" {
  name     = "${var.app_name}-k8s-cluster"
  location = "us-central1"

  network = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.app.id

  ip_allocation_policy {
    cluster_secondary_range_name = "services-range"
    services_secondary_range_name = google_compute_subnetwork.app.secondary_ip_range.1.range_name
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "k8s_cluster_preemptible_nodes" {
  name       = "${var.app_name}-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.k8s_cluster.name
  node_count = 1

  node_config {
    
    preemptible  = true
    machine_type = var.app_machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.app.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
