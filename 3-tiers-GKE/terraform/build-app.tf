locals {
  artifact_registry_image_full_path = "us-central1-docker.pkg.dev/${var.project_id}/${var.app_name}/gke"
  deployment_trigger = sha1(join("", [for f in fileset("${path.cwd}/../../app/", "*"): filesha1("${path.cwd}/../../app/${f}")]))
}

resource "google_artifact_registry_repository_iam_member" "app_default_sa_member" {
  provider = google-beta

  project = var.project_id
  location = google_artifact_registry_repository.app.location
  repository = google_artifact_registry_repository.app.name
  role = "roles/editor"
  member = "serviceAccount:${google_service_account.app.email}"
}

resource "google_artifact_registry_repository" "app" {
  provider = google-beta

  location        = "us-central1"
  repository_id   = var.app_name
  description     = "3 tier Docker Registry Repository"
  format          = "DOCKER"
}

resource "null_resource" "build_and_push" {
  triggers = {
    dir_sha1 = local.deployment_trigger
  }

  provisioner "local-exec" {
    command = "./build_and_push.sh ${local.artifact_registry_image_full_path} ../../app"
  }

  depends_on = [
    google_artifact_registry_repository.app
  ]
}

resource "kubernetes_secret" "app" {
  metadata {
    name = "app-secrets"
    labels = {
      app = "app"
    }
  }
  data = {
    "REDIS_ADDR" = "${google_redis_instance.data.host}:${google_redis_instance.data.port}"
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = "app"
    labels = {
      app = "app"
    }
  }

  spec {
    port {
      name = "web"
      port = 80
      protocol = "TCP"
      target_port = 8080
    }
    selector = {
      "app" = "app"
    }
  }
}

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name = "app-ingress"
    labels = {
      app = "app"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.app.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "app" {
  depends_on = [
    null_resource.build_and_push
  ]

  metadata {
    name = "app"
    labels = {
      app = "app"
      dir_sha1 = local.deployment_trigger
    }
  }
  spec {
    selector {
      match_labels = {
        app = "app"
      }
    }
    replicas = 1
    template {
      metadata {
        labels = {
          app = "app"
        }
      }
      spec {
        container {
          name = "app"
          image = "${local.artifact_registry_image_full_path}:latest"
          resources {
            requests = {
              cpu = "100m"
              memory = "100Mi"
            }
            limits = {
              cpu = "100m"
              memory = "100Mi"
            }
          }
          liveness_probe {
            tcp_socket {
              port = 8080
            }
            initial_delay_seconds = 5
            timeout_seconds = 3
            success_threshold = 1
            failure_threshold = 3
            period_seconds = 10
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 5
            timeout_seconds = 3
            success_threshold = 1
            failure_threshold = 3
            period_seconds = 10
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.app.metadata.0.name
            }
          }
          port {
            container_port = 8080
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
