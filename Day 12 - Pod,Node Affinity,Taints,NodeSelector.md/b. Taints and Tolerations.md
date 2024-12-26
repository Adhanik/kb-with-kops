

## Taint and Toleration

Taint works on node level, while pod works on tolerance 

Now suppose we have a critical app, which we need to deploy on node2 out of the three nodes that we have. We will taint the nodes.

So in our deployment yaml, we are going to mention the tolerance values, and taint our node before the deployment. Now when we deploy our deployment with R.S-3 , everything will dpeloy on node 2 and Non critical applications can be deployed on node 1 and 3

We will taint the nodes before running deployment like acc to high cpu, med cpu and low cpu - 


`kubectl taint node nodeid high-cpu=yes:NoExecute`
`kubectl taint node nodeid med-cpu=yes:NoExecute`
`kubectl taint node nodeid low-cpu=yes:NoExecute`

After this, in your deployment.yaml, you will mention the tolerations

---

## **Taints and Tolerations** – Final Explanation  

### **Key Concepts**  

1. **Taints (Node Level):**  
   - **Definition:** Applied to **nodes** to **repel pods** unless the pods explicitly **tolerate** the taint.  
   - **Purpose:** Prevent pods from being scheduled on certain nodes unless they explicitly declare compatibility using **tolerations**.  
   - **Command to Add Taint:**  
     ```bash
     kubectl taint nodes <node-name> <key>=<value>:<effect>
     ```  
     Example:  
     ```bash
     kubectl taint nodes node2 high-cpu=yes:NoExecute
     ```  
     This adds a taint to `node2`, repelling all pods **unless** they have a matching **toleration**.  

2. **Tolerations (Pod Level):**  
   - **Definition:** Applied to **pods** to **match the taint** on nodes, allowing the pod to be **scheduled** despite the taint.  
   - **Purpose:** Explicitly **allow specific pods** to be scheduled on tainted nodes.  
   - **Example in Deployment YAML:**  
     ```yaml
     tolerations:
     - key: "high-cpu"
       operator: "Equal"
       value: "yes"
       effect: "NoExecute"
     ```

---

### **Taint Effects** (Important)  

| **Effect**       | **Behavior**                                                                 |
|------------------|------------------------------------------------------------------------------|
| **NoSchedule**   | Pods **without tolerations** are **not scheduled** on the tainted node.       |
| **PreferNoSchedule** | Pods **without tolerations** are **avoided**, but can still be scheduled. |
| **NoExecute**    | Existing pods are **evicted immediately** unless they tolerate the taint.    |

---

### **Example Use Case**

You have:
- **Node 1** (low CPU)  
- **Node 2** (high CPU)  
- **Node 3** (medium CPU)  

#### **Scenario: Critical App on High CPU Node (Node 2)**  

**Step 1: Taint the node**  
```bash
kubectl taint nodes node2 high-cpu=yes:NoSchedule
```

**Step 2: Deploy the pod with toleration**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: critical-app
spec:
  tolerations:
  - key: "high-cpu"
    operator: "Equal"
    value: "yes"
    effect: "NoSchedule"
  containers:
  - name: app
    image: nginx
```

- **Result:** The **pod will be scheduled** only on `node2`.  

---

## **Node Affinity vs Taints and Tolerations** – Key Differences  

| Feature                            | Node Affinity                                            | Taints and Tolerations                                    |
|-------------------------------------|----------------------------------------------------------|-----------------------------------------------------------|
| **Purpose**                         | **Attracts pods** to specific nodes.                     | **Repels pods** from specific nodes unless tolerated.     |
| **Behavior**                        | Pods are **preferred** or **required** to be placed.      | Nodes **block pods** unless pods explicitly allow it.     |
| **Use Case**                        | Pods **should** or **must** be scheduled on specific nodes.| Pods **must not** be scheduled on nodes unless tolerated. |
| **Configuration Scope**             | Defined using **affinity rules** in pod specs.            | Defined using **taints** on nodes and **tolerations** in pods.|
| **Flexibility**                     | Supports **preferred and required rules** with operators. | Only supports **strict rules** (NoSchedule, NoExecute).   |

---

### **When to Use Node Affinity?**
- When you want **pods to prefer specific nodes** but are **not restricted** if the node is unavailable.  
- Example: Deploy a **frontend app** on nodes labeled `type=gpu` if available but fallback if needed.  

### **When to Use Taints and Tolerations?**
- When you want to **reserve nodes for specific workloads** and **block all other pods**.  
- Example: Reserve a **high-memory node** exclusively for **database workloads**, avoiding all non-critical apps.  

---

### **Common Use Cases for Taints and Tolerations**

1. **Dedicated Nodes for Critical Workloads**  
   - Use taints to **isolate high-priority applications** from general-purpose workloads.  
   - E.g., Database or Logging services that need **dedicated resources**.

2. **Node Isolation for Special Hardware**  
   - Use taints for **GPU nodes** to restrict pods that are not GPU-enabled.  
   - E.g., AI/ML workloads can run on **GPU nodes**, while other workloads are kept away.

3. **Temporary Maintenance or Decommissioning Nodes**  
   - Taint nodes to **prevent new pods** from being scheduled during maintenance.  
   - Use `NoExecute` to **evict existing pods** safely.  

4. **Mixed Workloads in Multi-Tenant Clusters**  
   - Taint nodes to **segregate workloads** based on tenant requirements.  
   - E.g., Production workloads on `prod` nodes and Dev workloads on `dev` nodes.  

---

### **Final Example Combining Node Affinity and Tolerations**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-deployment
spec:
  replicas: 2
  template:
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: environment
                operator: In
                values:
                - prod
      tolerations:
      - key: "high-cpu"
        operator: "Equal"
        value: "yes"
        effect: "NoSchedule"
      containers:
      - name: app
        image: nginx
```

- **Affinity Rule**: Schedule on nodes labeled `environment=prod`.  
- **Toleration Rule**: Pods can **only be scheduled** on tainted nodes with `high-cpu=yes`.  

---

### **Final Answer: Why Do We Need Taints and Tolerations?**  

While **Node Affinity** is **selective**, it **doesn’t block other pods** from being scheduled on the node. Taints, however, **enforce rules strictly**, ensuring that **only tolerant pods** are scheduled.  

Use **Node Affinity** for **preferences or constraints**, and **Taints/Tolerations** for **strict isolation or node reservations**.  

