resource "google_cloud_run_service" "app" {
  provider = google-beta
  name     = var.app_name
  location = var.region
  template {
    spec {
      containers {
        image = local.app_image
        env {
          name  = "REDIS_ADDR"
          value = "${google_redis_instance.data.host}:${google_redis_instance.data.port}"
        }
        ports {
          name           = "http1"
          container_port = "8080"
        }
      }
    }
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
        "autoscaling.knative.dev/minScale"        = var.min_scale
        "autoscaling.knative.dev/maxScale"        = var.max_scale
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.name
      }
    }
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "all"
    }
  }

  autogenerate_revision_name = true
  traffic {
    percent         = 100
    latest_revision = true
  }
  lifecycle {
    ignore_changes = [
      metadata.0.annotations,
    ]
  }
  depends_on = [
    google_redis_instance.data
  ]
}

resource "google_cloud_run_service_iam_member" "allUsers" {
  service  = google_cloud_run_service.app.name
  location = google_cloud_run_service.app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
