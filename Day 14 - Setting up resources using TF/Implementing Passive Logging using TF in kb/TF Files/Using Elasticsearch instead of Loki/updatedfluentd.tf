
## Deploy Fluentd to Forward Logs to Elasticsearch
## Update the Fluentd configuration to forward logs to Elasticsearch.

resource "helm_release" "fluentd" {
  name       = "fluentd"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluentd"
  namespace  = "logging"

  set {
    name  = "image.tag"
    value = "v1.14.6"  # Use the desired Fluentd version
  }

  set {
    name  = "config.output"
    value = <<EOF
<match **>
  @type elasticsearch
  host elasticsearch  # Points to the Elasticsearch service
  port 9200
  logstash_format true
  logstash_prefix kubernetes  # Prefix for indices in Elasticsearch
  buffer_chunk_limit 1m
  buffer_queue_limit 32
  flush_interval 10s
  retry_wait 1s
  retry_limit 3
  reload_on_failure true
</match>
EOF
  }
}