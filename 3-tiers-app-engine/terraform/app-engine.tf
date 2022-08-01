data "google_project" "project" {
}

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.location_id
}

resource "google_app_engine_standard_app_version" "app_v1" {
  version_id = "v1"
  service    = "default"
  runtime    = "go115"

  entrypoint {
    shell = "main"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app.name}/${google_storage_bucket_object.app.name}"
    }
  }

  env_variables = {
    REDIS_ADDR = "${google_redis_instance.data.host}:${google_redis_instance.data.port}"
  }

  automatic_scaling {
    max_concurrent_requests = 10
    min_idle_instances      = 1
    max_idle_instances      = 3
    min_pending_latency     = "1s"
    max_pending_latency     = "5s"
    standard_scheduler_settings {
      target_cpu_utilization        = 0.5
      target_throughput_utilization = 0.75
      min_instances                 = var.min_instances
      max_instances                 = var.max_instances
    }
  }

  vpc_access_connector {
    name = google_vpc_access_connector.connector.self_link
  }

  delete_service_on_destroy = true
}

resource "google_storage_bucket_iam_member" "app" {
  bucket = google_storage_bucket.app.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
