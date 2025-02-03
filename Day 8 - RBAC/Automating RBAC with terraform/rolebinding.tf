

resource "kubernetes_role_binding" "example" {
  metadata {
    name      = "pod-reader-binding"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.pod_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.example.metadata[0].name
    namespace = kubernetes_namespace.example.metadata[0].name
  }
}