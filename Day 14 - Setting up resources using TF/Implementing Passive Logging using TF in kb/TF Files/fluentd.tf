

## Deploy Fluentd as a DaemonSet
## You can use the Fluentd Helm chart to deploy Fluentd as a DaemonSet.

resource "helm_release" "fluentd" {
  name       = "fluentd"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluentd"
  namespace  = "logging"  # Create a dedicated namespace for logging

  set {
    name  = "image.tag"
    value = "v1.14.6"  # Use the desired Fluentd version
  }
## updated the Fluentd configuration to forward logs to Loki:
set {
  name  = "config.output"
  value = <<EOF
<match **>
  @type loki
  url http://loki:3100
  flush_interval 10s
  buffer_chunk_limit 1m
</match>
EOF
}
}