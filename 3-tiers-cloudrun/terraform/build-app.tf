locals {
  app_image = "gcr.io/${var.project_id}/3t-app:latest"
}

resource "null_resource" "build_and_push" {
  provisioner "local-exec" {
    command = "sh build-and-push.sh ${local.app_image}"
  }
}
