

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

  set {
    name  = "config.output"
    value = <<EOF
<match **>
  @type elasticsearch  # Change this to your desired output (e.g., Loki, S3)
  host elasticsearch  # Replace with your logging backend
  port 9200
  logstash_format true
</match>
EOF
  }
}