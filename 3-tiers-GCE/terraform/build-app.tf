resource "google_storage_bucket_object" "app" {
  name   = "3t-app"
  source = "../../app/3t-app"
  bucket = google_storage_bucket.app.name
  depends_on = [
    null_resource.build_and_push
  ]
}

resource "null_resource" "build_and_push" {
  provisioner "local-exec" {
    command = "cd ../../app && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o 3t-app ."
  }
  
  depends_on = [
    google_storage_bucket.app
  ]
}
