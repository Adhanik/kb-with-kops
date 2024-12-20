
# Create 3 ns

We will be creating 3 ns - dev, qa and prod.

- `kubectl create ns dev`
- `kubectl create ns prod`
- `kubectl create ns qa`

## Add labels to ns


Next we will be adding lables to our 3 ns

- `kubectl label ns prod nsp=prod`
- `kubectl label ns dev nsp=dev`
- `kubectl label ns qa nsp=qa`

 What is this nsp argument ??

### **1. What is the `nsp` argument?**
The command:

```bash
kubectl label ns qa nsp=qa
```

**Explanation**:
- This command adds a **label** `nsp=qa` to the namespace `qa`.
- **`nsp`** is the key of the label, and `qa` is the value. It's a user-defined label; Kubernetes doesn't impose any specific meaning or restrictions on it.
  - You can think of it as a custom metadata tag for the namespace `qa`.
- Labels are key-value pairs that are used to organize, select, and manage Kubernetes resources.

---

#### **Use Case for Labeling Namespaces**
- You can apply network policies, resource quotas, or role-based access control (RBAC) rules that target namespaces with specific labels.
  - For example, a network policy might allow traffic only to namespaces labeled `nsp=prod`.

---

Next, if you run `kubectl get ns --show-labels`

```
 kubectl get ns --show-labels
NAME              STATUS   AGE   LABELS

dev               Active   57s   kubectlbernetes.io/metadata.name=dev,nsp=dev
prod              Active   53s   kubectlbernetes.io/metadata.name=prod,nsp=prod
qa                Active   49s   kubectlbernetes.io/metadata.name=qa,nsp=qa

```
## Deploying 2 pods on each ns

### prod

kubectl run prod1 --image=kiran2361993/troubleshootingtools:v1 -n prod -l ns=prod
kubectl run prod2 --image=kiran2361993/troubleshootingtools:v1 -n prod -l ns=prod

 Does -l stand for label here?


### **2. Does `-l` stand for label in this command?**
The command:

```bash
kubectl run prod2 --image=kiran2361993/troubleshootingtools:v1 -n prod -l ns=prod
```

**Explanation**:
- Yes, the `-l` flag here stands for **label**. It applies a label to the resource being created.
  - **`-l ns=prod`** adds a label `ns=prod` to the pod being created (`prod2`).
- After running this command:
  - A pod named `prod2` is created in the `prod` namespace.
  - The pod is labeled with `ns=prod`.

---

### **Key Differences Between the Two Commands**
1. **First Command: Labeling a Namespace**
   - `kubectl label ns qa nsp=qa` adds the label to the **namespace** `qa`.

2. **Second Command: Adding Labels to a Pod**
   - `kubectl run prod2 -l ns=prod` assigns the label to the **pod** `prod2`.

---

### **How Labels Are Useful**

- Labels are used by:
  - **Selectors**: To filter resources. For example:
    ```bash
    kubectl get pods -l ns=prod
    ```
  - **Network Policies**: For traffic control. For example:
    - Allow traffic to all pods in namespaces with `nsp=prod`.
  - **Monitoring Tools**: To group resources logically.
  - **Deployment Tools**: To target specific pods for updates or scaling.

---

### **Summary**
- In `kubectl label`, `nsp` is a key of a label (custom metadata) you can assign to Kubernetes resources.
- In `kubectl run`, `-l` is a shorthand for adding labels to the resource you’re creating (in this case, the pod).


### dev

kubectl run dev1 --image=kiran2361993/troubleshootingtools:v1 -n dev -l ns=dev
kubectl run dev2 --image=kiran2361993/troubleshootingtools:v1 -n dev -l ns=dev

### QA

kubectl run qa1 --image=kiran2361993/troubleshootingtools:v1 -n qa -l ns=qa
kubectl run qa2 --image=kiran2361993/troubleshootingtools:v1 -n qa -l ns=qa

## Check all pods 

```
kubectl get pods -o wide -n prod && kubectl get pods -o wide -n dev && kubectl get pods -o wide -n qa
NAME    READY   STATUS    RESTARTS   AGE     IP                NODE                  NOMINATED NODE   READINESS GATES
prod1   1/1     Running   0          2m28s   100.115.162.194   i-0f3b21bd0da060378   <none>           <none>
prod2   1/1     Running   0          2m28s   100.115.162.195   i-0f3b21bd0da060378   <none>           <none>
NAME   READY   STATUS    RESTARTS   AGE     IP               NODE                  NOMINATED NODE   READINESS GATES
dev1   1/1     Running   0          2m13s   100.110.204.67   i-0c45f29f172d12bec   <none>           <none>
dev2   1/1     Running   0          2m12s   100.97.182.4     i-06f3226cc8ea7faff   <none>           <none>
NAME   READY   STATUS    RESTARTS   AGE    IP                NODE                  NOMINATED NODE   READINESS GATES
qa1    1/1     Running   0          104s   100.115.162.196   i-0f3b21bd0da060378   <none>           <none>
qa2    1/1     Running   0          104s   100.110.204.68    i-0c45f29f172d12bec   <none>           <none>
ubuntu@ip-172-31-20-104:~$ 

```

Without header

kubectl get pods -o wide -n prod --no-headers && kubectl get pods -o wide -n dev --no-headers && kubectl get pods -o wide -n qa --no-headers

```
kubectl get pods -o wide -n prod --no-headers && kubectl get pods -o wide -n dev --no-headers && kubectl get pods -o wide -n qa --no-headers
prod1   1/1   Running   0     8m31s   100.115.162.194   i-0f3b21bd0da060378   <none>   <none>
prod2   1/1   Running   0     8m31s   100.115.162.195   i-0f3b21bd0da060378   <none>   <none>
dev1   1/1   Running   0     8m16s   100.110.204.67   i-0c45f29f172d12bec   <none>   <none>
dev2   1/1   Running   0     8m15s   100.97.182.4     i-06f3226cc8ea7faff   <none>   <none>
qa1   1/1   Running   0     7m48s   100.115.162.196   i-0f3b21bd0da060378   <none>   <none>
qa2   1/1   Running   0     7m48s   100.110.204.68    i-0c45f29f172d12bec   <none>   <none>

```
### Creat alias for big command

alias allpods='kubectl get pods -o wide -n prod --no-headers && kubectl get pods -o wide -n dev --no-headers && kubectl get pods -o wide -n qa --no-headers'

`source .bashrc`
env

```
allpods
prod1   1/1   Running   0     15m   100.115.162.194   i-0f3b21bd0da060378   <none>   <none>
prod2   1/1   Running   0     15m   100.115.162.195   i-0f3b21bd0da060378   <none>   <none>
dev1   1/1   Running   0     15m   100.110.204.67   i-0c45f29f172d12bec   <none>   <none>
dev2   1/1   Running   0     15m   100.97.182.4     i-06f3226cc8ea7faff   <none>   <none>
qa1   1/1   Running   0     15m   100.115.162.196   i-0f3b21bd0da060378   <none>   <none>
qa2   1/1   Running   0     15m   100.110.204.68    i-0c45f29f172d12bec   <none>   <none>

```

## Checking communication btw each and every pod

We will be sending 3 packets from prod1, dev1, qa1 pods to all both pods of diff ns. For eg, from prod ns, we will login to prod1 pod, and try to check communication to both pod in dev ns, and both pod in qa ns.


pod prod1 in prod ns, is tryig to ping 2 pods in dev ns and 2 pods in QA ns
```
kubectl exec -it  prod1 -n prod -- ping -c 3  100.110.204.67 \
&& kubectl exec -it  prod2 -n prod -- ping -c 3  100.97.182.4 \
&& kubectl exec -it  prod1 -n prod -- ping -c 3   100.115.162.196     \
&& kubectl exec -it  prod2 -n prod -- ping -c 3   100.110.204.68
```

```
kubectl exec -it  dev1 -n dev -- ping -c 3    100.115.162.194 \
&& kubectl exec -it  dev2 -n dev -- ping -c 3  100.115.162.195 \
&& kubectl exec -it  dev1 -n dev -- ping -c 3   100.115.162.196    \
&& kubectl exec -it  dev2 -n dev -- ping -c 3 100.110.204.68
```

```
kubectl exec -it  qa1 -n qa -- ping -c 3     100.115.162.194  \
&& kubectl exec -it  qa2 -n qa -- ping -c 3   100.115.162.195  \
&& kubectl exec -it  qa1 -n qa -- ping -c 3  100.110.204.67 \
&& kubectl exec -it  qa2 -n qa -- ping -c 3   100.97.182.4
```

#### o/p

We can see that by default, inter communication btw pods in each ns, and communication btw pods in diff ns is happening.


