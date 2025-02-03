
resource "kubernetes_role" "pod_reader" {
  metadata {
    name      = "pod-reader"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}