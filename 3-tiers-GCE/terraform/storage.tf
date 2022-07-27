resource "google_storage_bucket" "app" {
  name          = "${var.app_name}-${random_id.app.hex}"
  location      = "US"
  force_destroy = true
  versioning {
    enabled = true
  }
}

resource "random_id" "app" {
  byte_length = 8
}
