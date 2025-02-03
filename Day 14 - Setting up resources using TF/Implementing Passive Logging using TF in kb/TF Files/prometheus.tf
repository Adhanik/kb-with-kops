

## Deploy Prometheus and Grafana
## Use the Prometheus Operator Helm chart to deploy Prometheus and Grafana.

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"  # Create a dedicated namespace for monitoring

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "grafana.enabled"
    value = "true"
  }
}