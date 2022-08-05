output "set_trigger_url" {
  value = google_cloudfunctions_function.set_counter.https_trigger_url
}

output "get_trigger_url" {
  value = google_cloudfunctions_function.get_counters.https_trigger_url
}
