



### **Explanation of the Configuration**

1. **Elasticsearch**:
   - Deployed as a stateful application using the Elasticsearch Helm chart.
   - Stores logs forwarded by Fluentd.
   - You can scale the `replicas` and configure `minimumMasterNodes` based on your cluster size.

2. **Kibana**:
   - Deployed to visualize logs stored in Elasticsearch.
   - Connects to the Elasticsearch service (`http://elasticsearch:9200`).

3. **Fluentd**:
   - Deployed as a DaemonSet to collect logs from all nodes.
   - Forwards logs to Elasticsearch using the `elasticsearch` output plugin.
   - The `logstash_format true` option ensures logs are stored in a structured format (e.g., `kubernetes-YYYY.MM.DD` indices).

---

### **How It Works**
1. **Log Collection**:
   - Fluentd collects logs from `/var/log/containers` on each node.
   - Logs are processed and forwarded to Elasticsearch.

2. **Log Storage**:
   - Elasticsearch stores the logs in indices (e.g., `kubernetes-2023.10.01`).

3. **Log Visualization**:
   - Kibana connects to Elasticsearch and allows you to query and visualize logs.

---

### **Accessing Kibana**
Once deployed, you can access Kibana by port-forwarding the Kibana service:

```bash
kubectl port-forward svc/kibana 5601:5601 -n logging
```

Then, open your browser and go to `http://localhost:5601`.

---

### **Optional: Persistent Storage for Elasticsearch**
To ensure logs are not lost if the Elasticsearch Pod is restarted, you can configure persistent storage for Elasticsearch. Update the Helm release for Elasticsearch:

```hcl
set {
  name  = "persistence.enabled"
  value = "true"
}

set {
  name  = "persistence.size"
  value = "10Gi"  # Adjust based on your storage requirements
}
```

---

### **Final Notes**
- This setup uses **Fluentd** for log collection and **Elasticsearch** for log storage.
- **Kibana** is optional but highly recommended for log visualization.
- You can customize the Fluentd configuration (e.g., add filters, parsers) based on your logging requirements.
- Ensure your Elasticsearch cluster is properly sized and configured for production use.