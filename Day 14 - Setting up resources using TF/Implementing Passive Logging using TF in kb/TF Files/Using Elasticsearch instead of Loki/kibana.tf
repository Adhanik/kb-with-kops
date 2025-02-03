

## Deploy Kibana (Optional)
## Kibana is used to visualize logs stored in Elasticsearch. You can deploy it using the Kibana Helm chart.

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  namespace  = "logging"

  set {
    name  = "elasticsearchHosts"
    value = "http://elasticsearch:9200"  # Points to the Elasticsearch service
  }
}