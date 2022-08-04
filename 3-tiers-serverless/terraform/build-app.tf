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

resource "google_cloudfunctions_function" "app" {
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

resource "google_cloudfunctions_function" "app" {
  name                  = format("%s-%s", var.app_name, "set-counter")
  runtime               = "go116"

  source_archive_bucket = google_storage_bucket.functions_src.name
  source_archive_object = google_storage_bucket_object.app.name
  trigger_http          = true
  entry_point           = "SetCounters"
  vpc_connector         = google_vpc_access_connector.connector.name
  environment_variables = {
    REDIS_ADDR = "${google_redis_instance.data.host}:${google_redis_instance.data.port}"
  }
  service_account_email = google_service_account.app_sa.email
}

resource "google_cloudfunctions_function_iam_member" "app_allow_api_gateway" {
  cloud_function = google_cloudfunctions_function.app.name
  member         = "serviceAccount:${google_service_account.app_sa.email}"
  role           = "roles/cloudfunctions.invoker"
}
