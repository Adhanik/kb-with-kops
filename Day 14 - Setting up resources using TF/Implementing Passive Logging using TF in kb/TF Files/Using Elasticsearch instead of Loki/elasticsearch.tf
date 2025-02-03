
## Deploy Elasticsearch
## You can deploy Elasticsearch using the Elasticsearch Helm chart.

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"  # Official Elastic Helm charts
  chart      = "elasticsearch"
  namespace  = "logging"  # Create a dedicated namespace for logging

  set {
    name  = "clusterName"
    value = "elasticsearch"
  }

  set {
    name  = "replicas"
    value = "1"  # Adjust based on your cluster size
  }

  set {
    name  = "minimumMasterNodes"
    value = "1"  # Adjust based on your cluster size
  }
}