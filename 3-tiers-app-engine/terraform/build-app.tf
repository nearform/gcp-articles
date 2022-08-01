resource "google_storage_bucket_object" "app" {
  name   = "app.zip"
  source = "../../app.zip"
  bucket = google_storage_bucket.app.name
  depends_on = [
    null_resource.build_and_push
  ]
}

resource "null_resource" "build_and_push" {
  provisioner "local-exec" {
    command = "zip -r -j ../../app.zip ../../app/*"
  }

  depends_on = [
    google_storage_bucket.app
  ]
}
