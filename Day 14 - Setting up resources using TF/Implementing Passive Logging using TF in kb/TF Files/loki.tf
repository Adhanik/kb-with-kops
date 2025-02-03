

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = "logging"

  set {
    name  = "promtail.enabled"
    value = "false"  # Disable Promtail since we're using Fluentd
  }
}