output "app_lb_address" {
  value = google_compute_address.app_static_ip.address
}
