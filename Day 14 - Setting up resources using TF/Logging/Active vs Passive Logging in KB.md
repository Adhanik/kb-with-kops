
There are two logging strategies:  Passive and active

###  Passive Logging


- The application logs to stdout and stderr
- Apps that use passive logging are unaware of the logging infra and log  messages to standard outputs
- Kubernetes captures these logs and makes them available through kubectl logs <pod-name>.
- A sidecar or DaemonSet-based logging agent (like Fluentd, Filebeat, or Promtail) collects and forwards logs to a central system.

### Active logging

In active logging the app makes network connections to intermediate aggregators, sends data to third party logging services, or writes directly to a database or index.

- Active logging is considered an antipattern, and it should be avoided.
- The application itself sends logs directly to an external system (e.g., Elasticsearch, Splunk, or a database).
- Requires additional networking overhead and can fail if the external system is down.
- Harder to scale and debug.

## Explaination


### **Logging Strategies in Kubernetes**

#### 1. **Passive Logging (Recommended)**
- **How it works**: Applications write logs to **standard output (`stdout`)** and **standard error (`stderr`)**.
- **Kubernetes handling**: Kubernetes captures these logs and stores them in files on the nodes where the Pods are running.
- **Log collection**: A log collection tool (e.g., Fluentd, Fluent Bit, Logstash) can be deployed as a DaemonSet on each node to collect logs from these files and forward them to a centralized logging system (e.g., Elasticsearch, Loki, Splunk).
- **Advantages**:
  - Simple to implement: Applications don’t need to be aware of the logging infrastructure.
  - Decouples application logic from logging infrastructure.
  - Kubernetes natively supports this approach.
- **Disadvantages**:
  - Logs are stored temporarily on the node, so if the node crashes or the logs are rotated out, logs can be lost unless collected promptly.

#### 2. **Active Logging (Generally Discouraged)**
- **How it works**: Applications directly send logs to an external logging service, database, or message queue (e.g., Elasticsearch, Kafka, AWS CloudWatch).
- **Kubernetes handling**: Kubernetes is not involved in log collection; the application handles it.
- **Advantages**:
  - Fine-grained control over log formatting and destination.
  - Can be useful for specialized use cases where logs need to be sent to a specific system.
- **Disadvantages**:
  - Tight coupling between the application and the logging infrastructure.
  - Increases application complexity.
  - If the logging service is unavailable, the application may fail or lose logs.
  - Harder to manage in a distributed environment like Kubernetes.

---

### **Why Active Logging is Considered an Anti-Pattern**
- **Tight coupling**: The application becomes dependent on the logging infrastructure, making it harder to maintain and scale.
- **Failure handling**: If the logging service is unavailable, the application may need to handle retries, buffering, or failures, which adds complexity.
- **Violates separation of concerns**: Applications should focus on business logic, not infrastructure concerns like logging.

---

### **Best Practices for Log Collection in Kubernetes**
1. **Use Passive Logging**:
   - Applications should write logs to `stdout` and `stderr`.
   - Kubernetes will handle log storage on the node.

2. **Deploy a Logging Agent**:
   - Use a logging agent (e.g., Fluentd, Fluent Bit) as a DaemonSet to collect logs from all nodes and forward them to a centralized logging system.
   - This ensures logs are collected even if Pods or nodes are terminated.

3. **Centralized Logging**:
   - Use a centralized logging system (e.g., Elasticsearch, Loki, Splunk) to store and query logs.
   - This provides a single source of truth for logs across the cluster.

4. **Log Rotation and Retention**:
   - Configure log rotation on nodes to prevent disk space issues.
   - Set retention policies in your centralized logging system to manage storage costs.

5. **Structured Logging**:
   - Use structured logging (e.g., JSON format) to make logs easier to parse and query.

6. **Handle Log Loss**:
   - To minimize log loss, ensure your logging agent is reliable and can handle network issues or backpressure.
   - Use buffering (e.g., in Fluentd or Fluent Bit) to temporarily store logs if the logging backend is unavailable.

---

### **Risk of Losing Logs**
- **Node-level logs**: Logs stored on nodes are at risk of being lost if the node crashes or the logs are rotated out before being collected.
- **Mitigation**:
  - Deploy a reliable logging agent (e.g., Fluentd) to collect logs as soon as they are written.
  - Use persistent storage for logs if necessary.
  - Ensure your centralized logging system is highly available and can handle failures.

---

### **Summary**
- **Passive logging** is the recommended approach in Kubernetes. It decouples the application from the logging infrastructure and leverages Kubernetes' native logging capabilities.
- **Active logging** is generally discouraged due to tight coupling and increased complexity.
- To avoid losing logs, deploy a logging agent as a DaemonSet and ensure logs are promptly collected and stored in a centralized system.
- Always design your logging infrastructure with reliability and scalability in mind.


## Note


## Avoid sidecars for logging(if you can)

With a sidecar container, you can normalize the log entries before they are shipped elsewhere. For eg, you may want to transform apache logs into Logstash JSON format before shipping them to the logging infrastructure. However, if you have control over the application, it is better to output the right format from the begining. This approach can save you from running an extra container for each Pod in your cluster.

