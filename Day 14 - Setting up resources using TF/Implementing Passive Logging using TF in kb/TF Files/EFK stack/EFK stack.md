
### **What is the EFK Stack?**  
The **EFK stack** consists of:  
- **Elasticsearch (E)** – Stores and indexes logs.  
- **Fluentd (F)** – Collects, processes, and forwards logs.  
- **Kibana (K)** – Provides a UI to visualize and search logs.  

It is a popular alternative to the **ELK stack** (Elasticsearch, Logstash, Kibana), where **Fluentd replaces Logstash** as the log collector.

---

### **Fluentd + Elasticsearch Logging Setup in Kubernetes via Terraform**
Yes! You can deploy **EFK in Kubernetes using Terraform**. The setup involves:  
1. **Deploying Elasticsearch & Kibana** as StatefulSets.  
2. **Deploying Fluentd** as a DaemonSet to collect logs.  
3. **Configuring Fluentd to forward logs to Elasticsearch.**

Here’s a **Terraform setup** for deploying EFK in Kubernetes:

---

### **1️⃣ Create a Terraform File for EFK (`efk.tf`)**
```hcl
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# --- Deploy Elasticsearch ---
resource "kubernetes_stateful_set" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = "logging"
  }

  spec {
    service_name = "elasticsearch"
    replicas     = 1

    selector {
      match_labels = {
        app = "elasticsearch"
      }
    }

    template {
      metadata {
        labels = {
          app = "elasticsearch"
        }
      }

      spec {
        container {
          name  = "elasticsearch"
          image = "docker.elastic.co/elasticsearch/elasticsearch:7.10.0"

          port {
            container_port = 9200
          }

          env {
            name  = "discovery.type"
            value = "single-node"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "2Gi"
            }
            requests = {
              cpu    = "250m"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }
}

# --- Deploy Kibana ---
resource "kubernetes_deployment" "kibana" {
  metadata {
    name      = "kibana"
    namespace = "logging"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kibana"
      }
    }

    template {
      metadata {
        labels = {
          app = "kibana"
        }
      }

      spec {
        container {
          name  = "kibana"
          image = "docker.elastic.co/kibana/kibana:7.10.0"

          port {
            container_port = 5601
          }

          env {
            name  = "ELASTICSEARCH_HOSTS"
            value = "http://elasticsearch:9200"
          }
        }
      }
    }
  }
}

# --- Deploy Fluentd as DaemonSet ---
resource "kubernetes_daemonset" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = "logging"
  }

  spec {
    selector {
      match_labels = {
        app = "fluentd"
      }
    }

    template {
      metadata {
        labels = {
          app = "fluentd"
        }
      }

      spec {
        container {
          name  = "fluentd"
          image = "fluent/fluentd-kubernetes-daemonset:v1.14-debian-elasticsearch7"

          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }

          env {
            name  = "FLUENT_ELASTICSEARCH_HOST"
            value = "elasticsearch"
          }

          env {
            name  = "FLUENT_ELASTICSEARCH_PORT"
            value = "9200"
          }
        }

        volume {
          name = "varlog"

          host_path {
            path = "/var/log"
          }
        }
      }
    }
  }
}

# --- Create a Namespace for Logging ---
resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}
```

---

### **2️⃣ Apply Terraform to Deploy EFK**
```sh
terraform init
terraform apply -auto-approve
```

---

### **3️⃣ Verify the Setup**
```sh
kubectl get pods -n logging
kubectl logs <fluentd-pod-name> -n logging
kubectl port-forward svc/kibana 5601:5601 -n logging
```
Now, open **http://localhost:5601** in your browser to access Kibana. 🎉

---

### **Key Takeaways**
✅ Terraform can be used to **provision Kubernetes logging** infrastructure.  
✅ **Fluentd collects logs** from `/var/log/containers/` and **forwards them to Elasticsearch**.  
✅ Kibana provides a **GUI for log visualization**.  
✅ This setup **avoids active logging** and **ensures log persistence**.

Let me know if you want **Helm-based Terraform deployment** for EFK instead! 🚀