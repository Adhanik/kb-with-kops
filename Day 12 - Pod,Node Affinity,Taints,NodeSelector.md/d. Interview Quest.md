

## **Topic 1: Node Selector & Node Affinity**  

### **Question 1:**  
You have a Kubernetes cluster with 10 nodes. Some nodes are GPU-enabled, labeled as:  

```
gpu: true
```  
Others are non-GPU nodes, labeled as:  
```
gpu: false
```  
A **machine-learning pod** needs to run exclusively on GPU nodes, but occasionally it can tolerate being scheduled on non-GPU nodes if all GPU nodes are full.  

**How would you design this deployment using node affinity?**  

---

### Answer:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: critical-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: gpu
            operator: In
            values:
            - true
  containers:
  - name: nginx
    image: nginx

---
apiVersion: v1
kind: Pod
metadata:
  name: non-critical-pod
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: gpu
            operator: In
            values:
            - false
  containers:
  - name: nginx
    image: nginx

```


---

### **Feedback on Answer:**  
1. **Strengths:**  
   - Highlighted the use of **requiredDuringSchedulingIgnoredDuringExecution** for GPU preference.  
   - Addressed **fall-back to non-GPU nodes** using **preferredDuringSchedulingIgnoredDuringExecution**.  

2. **Suggestions for Improvement:**  
   - Ensure your YAML example distinguishes between **strict (required)** and **soft (preferred)** constraints.  
   - Think about **resource limits** like GPU memory in your design.  
   - Consider **taints** on non-GPU nodes to make this scenario more robust (combined approaches).  

---

## **Topic 2: Taints & Tolerations**  

### **Question 2:**  
You have a **critical payment service pod** that must run **only on node X**, which has additional **security constraints**.  

However, this node is also used for **other sensitive applications**, and we cannot allow any **non-critical workloads** to be scheduled there—even by accident.  

**How would you enforce this using taints and tolerations?**  

---

### *Your Answer:*

We will taint the node X and add toleration to deployment of **critical payment service pod** so that it only on node X

`kubectl taint nodes nodeX security=high:NoSchedule`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: critical-payment
spec:
  tolerations:
  - key: "security"
    operator: "Equal"
    value: "high"
    effect: "NoSchedule"
  containers:
  - name: app
    image: nginx
---

I have not thought of implementing PreferNoSchedule and NoExecute as there is no mention to remove existing pods

### **Feedback on Answer:**  
1. **Strengths:**  
   - Mentioned adding a taint like:  
     ```shell
     kubectl taint nodes nodeX security=high:NoSchedule
     ```  
   - Included tolerations in the deployment YAML for critical pods.  

2. **Suggestions for Improvement:**  
   - Go beyond just **NoSchedule**—consider the impact of **NoExecute** in case the node needs to be **evicted** during maintenance.  
   - Address edge cases like **temporary failures**—how will the system behave if the node becomes **unschedulable**?  
   - Think about **monitoring these taints**—what happens if someone **removes the taint accidentally**?  

---

## **Topic 3: Pod Affinity & Anti-Affinity**  

### **Question 3:**  
Imagine you have a **logging system** with 3 pods collecting logs from multiple applications. Each pod can handle logs from specific regions (e.g., **east**, **west**, and **central**).  

You need to ensure:  
1. Pods from the **same region** (e.g., east) are **co-located** for faster data processing.  
2. Pods from **different regions** are **spread apart** for **high availability**.  

**How would you design this deployment using Pod Affinity and Anti-Affinity rules?**  

---

### **Your Answer:** *(Type your answer here)*  

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: east-deployment
spec:
  replicas: 3
  template:
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: east
                  operator: In
                  values:
                  - same-region
              topologyKey: "kubernetes.io/hostname"
      containers:
      - name: logging
        image: grafana
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: others-deployment
spec:
  replicas: 3
  template:
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: others
                  operator: In
                  values:
                  - diff-region
              topologyKey: "kubernetes.io/hostname"
      containers:
      - name: logging
        image: grafana
---



### **Feedback on Answer:**  
1. **Strengths:**  
   - Addressed **co-location** using **Pod Affinity** with `requiredDuringSchedulingIgnoredDuringExecution`.  
   - Spread pods using **Anti-Pod Affinity** to avoid failures affecting multiple regions.  

2. **Suggestions for Improvement:**  
   - Think about **zones or availability zones** instead of just **nodes** for greater resilience in cloud environments.  
   - Use **weights** for preference rules rather than strict requirements to make scaling more **flexible**.  
   - Consider combining **Node Affinity** for region-based labels (e.g., `region=east`) to further optimize placement.  

---

## **General Critical Thinking Improvements:**  

1. **Weigh Trade-offs**:  
   - Are strict rules always the best? What happens when pods **cannot be scheduled** due to constraints?  
   - How do you handle **scalability** issues as clusters grow?  

2. **Combine Strategies**:  
   - Think about scenarios where you can **combine node affinity, pod affinity, and taints/tolerations**.  
   - Example: **Reserve nodes for GPU workloads (taints)** and **prefer proximity for communication-intensive tasks (pod affinity)**.  

3. **Dynamic Environments**:  
   - How would you **update affinities or tolerations dynamically** if traffic patterns or failures shift?  
   - Consider using **Custom Controllers** to **reconcile labels** based on real-time metrics.  

4. **Monitoring and Governance**:  
   - Think about **observability**—how will you detect and troubleshoot scheduling failures?  
   - Use **Prometheus** or **Kubernetes Events** to log scheduling decisions and failures.  

---

Would you like me to create more **challenge scenarios** or focus on **advanced use cases**?