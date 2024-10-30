
# Resource quotas and limits

### 1. **Resource Quotas**

In Kubernetes, **Resource Quotas** are a way to control the total resource usage (like CPU and memory) within a specific **namespace** (ns). This is helpful when multiple teams or applications share a single Kubernetes cluster and ensures that resources are fairly distributed.

#### Scenario Overview

Imagine you have a Kubernetes cluster with a total of **20 CPUs and 20 GB of memory**. You have four teams, each working on different projects:
- **T1**: Python application
- **T2**: .NET application
- **T3**: Java application
- **T4**: Node.js application

Initially, without any limits, **T1** (Python team) was consuming all 20 CPUs and 20 GB of memory, leaving no resources for the other teams. To avoid this, you:
- **Create separate namespaces** for each team, isolating their applications.
- **Apply resource quotas at the namespace level** to allocate a fair share of resources to each team.

#### How Resource Quotas Work
When you set resource quotas on a namespace, you limit the **total amount of CPU and memory** that all the containers within that namespace can consume.

Here’s how you could set quotas:
- Allocate **5 CPUs and 5 GB of memory** to each namespace, ensuring fair resource distribution:
  ```yaml
  apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: team-quota
    namespace: team-namespace
  spec:
    hard:
      requests.cpu: "5"
      requests.memory: "5Gi"
      limits.cpu: "5"
      limits.memory: "5Gi"
  ```
- This setup ensures each namespace (`T1`, `T2`, `T3`, `T4`) has access to only 5 CPUs and 5 GB of memory, preventing one team from monopolizing resources.
- Since quotas are set **at the namespace level**, any containers within that namespace collectively cannot exceed the specified limits. This way, the resources are effectively isolated.

#### Key Points About Resource Quotas
- Quotas ensure **resource fairness** among teams by dividing cluster resources at the namespace level.
- They are not applied to individual containers but rather the namespace as a whole.
- This isolation prevents any team from over-utilizing cluster resources and ensures stable resource availability for all teams.

### 2. **Resource Limits**

While resource quotas control resources at the namespace level, **Resource Limits** control resources at the **individual container level** within a Pod. This ensures that no single container can consume all resources allocated to a namespace, thus preventing "noisy neighbors" within the same namespace.

#### Example Scenario

Let’s say **T1** has been allocated a quota of **5 CPUs and 5 GB of memory** for its namespace, and this namespace contains multiple containers. If one container within T1’s namespace consumes all 5 CPUs and 5 GB of memory, it would lead to problems for other containers in the same namespace, even though other namespaces aren’t affected.

To prevent this, you can set **resource limits** on each container:
- **Requests**: This is the minimum guaranteed amount of resources the container will receive.
- **Limits**: This is the maximum amount the container is allowed to consume.

For example, you can set limits like this in the Pod definition:
```yaml
spec:
  containers:
  - name: python-app
    image: python-app-image
    resources:
      requests:
        cpu: "1"
        memory: "1Gi"
      limits:
        cpu: "2"
        memory: "2Gi"
```

#### Key Points About Resource Limits
- Resource limits ensure **fair resource allocation within a namespace** so no single container consumes all resources.
- Limits are defined in the container spec and help maintain container-level control.
- Limits make resource usage more predictable and prevent a single container from affecting the performance of other containers within the namespace.

### 3. **Network Policies**: Control Inter-Namespace Communication

Since each team is isolated in a separate namespace, you might want to manage which namespaces can communicate with each other. This is done using **Network Policies** in Kubernetes.

#### What Are Network Policies?
Network Policies are Kubernetes resources used to control traffic flow between Pods, either within the same namespace or across different namespaces. They define which Pods are allowed to communicate with each other and can be applied to achieve both intra-namespace and inter-namespace network isolation.

For example:
- If you want the **Python team (T1)** to communicate with the **Java team (T3)** but restrict access to the .NET team (T2), you can create a Network Policy to allow only specific Pods or namespaces to connect.

Here’s an example Network Policy:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-python-to-java
  namespace: java-namespace
spec:
  podSelector:
    matchLabels:
      app: java-app
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          team: python
```

This policy:
- Allows traffic from the `python` namespace to reach Pods labeled `java-app` in the `java-namespace`.
- Restricts other traffic from reaching `java-namespace` unless explicitly allowed.

#### Implementation and Scope of Network Policies
- **Ingress and Egress Rules**: Network policies specify both incoming (ingress) and outgoing (egress) rules.
- **Namespace-Level Isolation**: Policies can be applied to all Pods in a namespace or selectively to certain Pods.
- **Enforced by CNI Plugin**: Not all Kubernetes clusters enforce network policies by default; they rely on the network plugin (CNI) to implement the policy.

### Summary and Best Practices

1. **Resource Quotas**: Used at the namespace level to ensure fair distribution of CPU and memory across teams.
2. **Resource Limits**: Applied at the container level to prevent any single container from consuming all namespace resources, which improves reliability and stability.
3. **Network Policies**: Used to control traffic between namespaces or Pods, ensuring security and controlled communication within the cluster.

Using **Persistent Volumes** and **Persistent Volume Claims** would further support data persistence and isolation between namespaces, especially in stateful applications like databases, where data must persist beyond the Pod lifecycle.