resource "google_service_account" "app" {
  account_id   = "${var.app_name}-sa"
  display_name = "3t App Service Account"
}

resource "google_storage_bucket_iam_member" "app" {
  bucket = google_storage_bucket.app.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.app.email}"
}

data "google_compute_image" "os" {
  family  = var.image_family
  project = var.image_project
}

resource "google_compute_instance_template" "instance_template" {
  name_prefix  = "${var.app_name}-tmpl"
  machine_type = var.app_machine_type
  region       = var.region
  tags         = ["web-app"]

  service_account {
    email  = google_service_account.app.email
    scopes = ["cloud-platform"]
  }

  disk {
    source_image = data.google_compute_image.os.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = var.app_disk_size_gb
  }

  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.app.self_link
    
    # uncoment this block for set external IPs to instances
    # access_config {
    #   network_tier = "STANDARD"
    # }
  }

  metadata_startup_script = <<-USERDATA
    #!/bin/bash
    sudo apt-get install apt-transport-https ca-certificates gnupg -y
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install google-cloud-cli -y
    gsutil cp gs://${google_storage_bucket.app.name}/3t-app 3t-app
    chmod +x 3t-app
    export REDIS_ADDR="${google_redis_instance.data.host}:${google_redis_instance.data.port}"
    ./3t-app
  USERDATA

  depends_on = [
    google_storage_bucket.app, google_redis_instance.data
  ]
}

resource "google_compute_region_instance_group_manager" "app" {
  name               = "${var.app_name}-mig"
  base_instance_name = "${var.app_name}-srv"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.instance_template.id
  }

  depends_on = [
    google_storage_bucket.app, google_compute_instance_template.instance_template
  ]

  auto_healing_policies {
    health_check      = google_compute_health_check.app.id
    initial_delay_sec = 300
  }

  named_port {
    name = "http"
    port = 8080
  }
}

resource "google_compute_health_check" "app" {
  name                = "${var.app_name}-helth-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    request_path = "/health"
    port         = "8080"
  }
}

resource "google_compute_region_autoscaler" "app" {
  name   = "${var.app_name}-auto-scaler"
  region = var.region
  target = google_compute_region_instance_group_manager.app.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60
    cpu_utilization {
      target = 0.5
    }
  }
}

module "app_lb" {
  source = "GoogleCloudPlatform/lb-http/google"
  name   = "${var.app_name}-lb"

  firewall_networks = [google_compute_network.vpc.name]
  project           = var.project_id
  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port                            = 8080
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/health"
        port                = 8080
        host                = null
        logging             = null
      }

      groups = [
        {
          group                        = google_compute_region_instance_group_manager.app.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        }
      ]

      log_config = {
        enable      = false
        sample_rate = null
      }

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}
