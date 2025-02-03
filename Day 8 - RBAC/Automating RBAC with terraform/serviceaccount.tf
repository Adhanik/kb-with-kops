

resource "kubernetes_service_account" "example" {
  metadata {
    name      = "example-sa"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
}