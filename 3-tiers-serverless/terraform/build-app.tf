data "archive_file" "app_zip" {
  type        = "zip"
  source_dir  = "../../function"
  output_path = "app.zip"
}

resource "google_storage_bucket" "functions_src" {
  name     = "${var.app_name}-src"
  location = var.region

  versioning {
    enabled = false
  }
  force_destroy = true
}

resource "google_storage_bucket_object" "app" {
  name   = format("%s-%s.zip", var.app_name, data.archive_file.app_zip.output_md5)
  bucket = google_storage_bucket.functions_src.name
  source = data.archive_file.app_zip.output_path
}

resource "google_service_account" "app_sa" {
  account_id = var.app_name
}

resource "google_cloudfunctions_function" "get_counters" {
  name                  = format("%s-%s", var.app_name, "get-counters")
  runtime               = "go116"

  source_archive_bucket = google_storage_bucket.functions_src.name
  source_archive_object = google_storage_bucket_object.app.name
  trigger_http          = true
  entry_point           = "GetCounters"
  vpc_connector         = google_vpc_access_connector.connector.name
  environment_variables = {
    REDIS_ADDR = "${google_redis_instance.data.host}:${google_redis_instance.data.port}"
  }
  service_account_email = google_service_account.app_sa.email
}

resource "google_cloudfunctions_function" "set_counter" {
  name                  = format("%s-%s", var.app_name, "set-counter")
  runtime               = "go116"

  source_archive_bucket = google_storage_bucket.functions_src.name
  source_archive_object = google_storage_bucket_object.app.name
  trigger_http          = true
  entry_point           = "SetCounter"
  vpc_connector         = google_vpc_access_connector.connector.name
  environment_variables = {
    REDIS_ADDR = "${google_redis_instance.data.host}:${google_redis_instance.data.port}"
  }
  service_account_email = google_service_account.app_sa.email
}

resource "google_cloudfunctions_function_iam_member" "set_counter_allow_public" {
  cloud_function = google_cloudfunctions_function.set_counter.name
  member         = "allUsers"
  role           = "roles/cloudfunctions.invoker"
}

resource "google_cloudfunctions_function_iam_member" "get_counters_allow_public" {
  cloud_function = google_cloudfunctions_function.get_counters.name
  member         = "allUsers"
  role           = "roles/cloudfunctions.invoker"
}
