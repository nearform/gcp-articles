resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
}

resource "google_compute_address" "app_static_ip" {
  name = "app-static-ip"
}

resource "helm_release" "nginx" {
  depends_on = [
    google_container_cluster.k8s_cluster
  ]

  name       = "ingress-nginx"
  namespace = kubernetes_namespace.nginx.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.1.4"

  set {
    name = "controller.service.loadBalancerIP"
    value = google_compute_address.app_static_ip.address
  }
}
