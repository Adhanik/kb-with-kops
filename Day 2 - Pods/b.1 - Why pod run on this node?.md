In Kubernetes, Pods are scheduled on worker nodes, not control-plane (master) nodes, unless the control-plane node is tainted to allow workloads to run on it (which is typically not recommended). Based on your setup, you have:

- **2 worker nodes** (`i-0401ab05e63feb772` and `i-0c86e68dd92f450ce`)
- **1 control-plane node** (`i-07d85eb02719ceecd`)

### Pod Scheduling:
- The Pod `alpha1` is running on the worker node `i-0c86e68dd92f450ce` (as seen from the `kubectl get pods -o wide` output).
- Kubernetes schedules Pods across available worker nodes based on various factors such as node resources (CPU, memory), affinity/anti-affinity rules, taints/tolerations, and others.
- **Kops doesn't control scheduling directly** but ensures the cluster nodes and control plane are set up properly. The **Kubernetes scheduler** determines where to place Pods based on the cluster's state.

### Will the Pod Run on Both Worker Nodes?
- By default, a Pod (like `alpha1`) will run on a **single node**, not on multiple nodes. If you want the same Pod to run on multiple nodes for high availability or load balancing, you should use a **Deployment** or **ReplicaSet**, which allows Kubernetes to manage multiple replicas of a Pod across nodes.

For example, if you want to ensure `alpha1` runs on both worker nodes, you can modify the YAML to create a Deployment with replicas:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alpha1
  namespace: alpha
spec:
  replicas: 2  # Number of replicas (2 in this case, one for each worker node)
  selector:
    matchLabels:
      run: alpha1
  template:
    metadata:
      labels:
        run: alpha1
    spec:
      containers:
      - image: kiran2361993/kubegame:v2
        name: alpha1
```

This way, Kubernetes will create two replicas of the Pod, and they can be scheduled on different worker nodes, depending on resource availability.

### Why is the Pod Running on a Specific Node?
The scheduler decides which worker node to place the Pod on by evaluating factors such as:
- **Resource availability**: Kubernetes will try to balance CPU and memory usage across nodes.
- **Affinity/anti-affinity rules**: You can define these rules to influence how Pods are distributed across nodes.
- **Taints and tolerations**: If a node has taints, only Pods that tolerate those taints will be scheduled on it.
- **NodeSelector/Node Affinity**: If you specify `nodeSelector` or `node affinity` in your Pod spec, it will influence which node the Pod gets scheduled on.

Since you didn’t specify any such constraints, the scheduler automatically placed the Pod on one of the available worker nodes (`i-0c86e68dd92f450ce` in this case).

### Conclusion:
- The Pod is running on a single worker node (`i-0c86e68dd92f450ce`).
- If you want to distribute it across both worker nodes, use a Deployment with multiple replicas.
- The scheduler handles Pod placement based on available resources and configuration options like taints, node affinity, etc.

