output "app_trigger_url" {
  value = google_cloudfunctions_function.app.https_trigger_url
}
