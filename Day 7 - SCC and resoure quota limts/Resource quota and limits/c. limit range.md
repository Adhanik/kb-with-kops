

We will run kubectl apply on b2.resource-quota.yaml, and see that our ns development and resource quota both are created

```
namespace/development unchanged
resourcequota/object-counts created

```

- Switch to development ns - kubectl config set-context --current --namespace=development

- If we do describe on our ns, we can see the resource quotas associated with our ns

```
kubectl describe ns development
Name:         development
Labels:       kubernetes.io/metadata.name=development
              name=development
Annotations:  <none>
Status:       Active

Resource Quotas
  Name:                   object-counts
  Resource                Used  Hard
  --------                ---   ---
  limits.cpu              0     2
  limits.memory           0     2Gi
  pods                    0     10
  replicationcontrollers  0     20
  requests.cpu            0     1
  requests.memory         0     1Gi
  resourcequotas          1     10
  services                0     5

No LimitRange resource.

```

- If i try to create a pod in ns, then i get below error

```
kubectl run pod --image nginx:latest

Error from server (Forbidden): pods "pod" is forbidden: failed quota: object-counts: must specify limits.cpu for: pod; limits.memory for: pod; requests.cpu for: pod; requests.memory for: pod
ubuntu@ip-172-31-27-89:~$ 

```

## Why are we getting this error?

The error message indicates that when creating the pod, Kubernetes requires you to set specific CPU and memory **requests** and **limits** for it to meet the defined `ResourceQuota` requirements in the `development` namespace. This is happening because the `ResourceQuota` applied on the namespace has specific limits and requests for `cpu` and `memory`, and any pod created in this namespace must define these parameters.

### Understanding the Error
The error:
```
Error from server (Forbidden): pods "pod" is forbidden: failed quota: object-counts: must specify limits.cpu for: pod; limits.memory for: pod; requests.cpu for: pod; requests.memory for: pod
```

- This means that to create any pod in the `development` namespace, it must have these four fields specified:
  - **`requests.cpu`**
  - **`requests.memory`**
  - **`limits.cpu`**
  - **`limits.memory`**

This requirement is set by the `ResourceQuota` you deployed, where both `requests` and `limits` for `cpu` and `memory` were specified:
```yaml
request.cpu: "1000m"
limits.cpu: "2000m"
requests.memory: 1Gi
limits.memory: 2Gi
```

### How to Resolve the Error

We could define limit Range, The LimitRange resource in your YAML specifies the minimum and maximum CPU and memory usage for any container within the development namespace. 

### Explanation of YAML

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-memory-min-max-demo-lr
  namespace: development
spec:
  limits:
    - max:
        cpu: "200m"
        memory: "128Mi"
      min:
        cpu: "100m"
        memory: "100Mi"
      type: Container
```

- **`LimitRange` Resource**: `LimitRange` allows you to set minimum and maximum resource limits for containers or pods within a namespace. This applies a boundary to prevent containers from using too little (which may cause poor performance) or too much (which could affect other workloads).
  
- **`max` and `min`**: Here, you've specified that containers in the `development` namespace must request between `100m` (0.1 CPU) and `200m` (0.2 CPU) for CPU, and between `100Mi` and `128Mi` for memory:
  - `cpu: "200m"`: This means the maximum CPU a container can request is `200m`, or 0.2 of a CPU core.
  - `cpu: "100m"`: This is the minimum CPU that a container can request, set to `100m` (0.1 CPU).
  - `memory: "128Mi"`: Sets the upper limit of memory a container can use to `128Mi`.
  - `memory: "100Mi"`: Sets the minimum memory usage a container must request to `100Mi`.

- **`type: Container`**: This applies the limits and minimum requirements at the container level. Any container created in this namespace must follow these restrictions.

### Key Points

1. **Automatic Enforcing of Limits and Requests**: Once this `LimitRange` is applied, Kubernetes will enforce these resource boundaries. If you try to deploy a container that requests less than `100m` CPU or more than `200m` CPU, Kubernetes will deny the deployment. Similarly, memory usage must be between `100Mi` and `128Mi`.

2. **Usage with ResourceQuotas**: This `LimitRange` doesn’t replace the `ResourceQuota`; it complements it. The `LimitRange` sets per-container boundaries, while the `ResourceQuota` restricts the total resources available in the namespace. This ensures both individual containers stay within their limits and that the namespace as a whole doesn’t exceed its allocated quota.

3. **Defaulting Behavior**: If a container does not specify its own `requests` or `limits`, Kubernetes will automatically assign the minimum values specified in `LimitRange` (i.e., `100m` CPU and `100Mi` memory), provided these values fall within any specified `ResourceQuota`.

4. **Alternatives and Best Practices**:
   - While `LimitRange` is good for restricting individual containers, **Persistent Volumes** can be useful if you need a storage solution that retains data beyond a pod’s lifecycle.
   - **Cluster-level ResourceQuotas** or **NetworkPolicies** can help manage resources and network traffic across namespaces or clusters.

- After applying above yaml

```
kubectl apply -f limitrange.yaml 
limitrange/cpu-memory-min-max-demo-lr created
```

- If we now run a pod, it will be success

```
kubectl run pod1 --image nginx:latest
pod/pod1 created
ubuntu@ip-172-31-27-89:~$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
pod1   1/1     Running   0          7s

```

- To see how much we have used, we can describe ns

`kubectl describe ns development`

```
kubectl describe ns development
Name:         development
Labels:       kubernetes.io/metadata.name=development
              name=development
Annotations:  <none>
Status:       Active

Resource Quotas
  Name:                   object-counts
  Resource                Used   Hard
  --------                ---    ---
  limits.cpu              200m   2
  limits.memory           128Mi  2Gi
  pods                    1      10
  replicationcontrollers  0      20
  requests.cpu            200m   1
  requests.memory         128Mi  1Gi
  resourcequotas          1      10
  services                0      5

Resource Limits
 Type       Resource  Min    Max    Default Request  Default Limit  Max Limit/Request Ratio
 ----       --------  ---    ---    ---------------  -------------  -----------------------
 Container  memory    100Mi  128Mi  128Mi            128Mi          -
 Container  cpu       100m   200m   200m             200m           -

```

you can see limits on ns and contianer level.



# Summary

## Ques

So if i have defined resourcequota on a ns (are resourcequota applied only for ns?) then i do have to define limitRange, otherwise i cannot create any pod in that ns. Is it correct understanding? because when i had not defined liimit range, it gave me this error - Error from server (Forbidden): pods "pod" is forbidden: failed quota: object-counts: must specify limits.cpu for: pod; limits.memory for: pod; requests.cpu for: pod; requests.memory for: pod
ubuntu@ip-172-31-27-89:~$ 

## Sol
Yes, you’ve understood it well. Here’s a breakdown:

1. **ResourceQuota** applies limits at the namespace level, setting boundaries on the total CPU, memory, number of pods, services, etc., that all containers in that namespace can collectively consume. **ResourceQuota only works at the namespace level**, so each namespace can have its own independent limits.

2. When **ResourceQuota is applied on CPU or memory**, it requires that each container within that namespace defines specific CPU and memory requests and limits for every pod created. Without these values set, Kubernetes will deny the creation of new pods in that namespace.

3. A **LimitRange** provides default `requests` and `limits` on individual containers within a namespace if they aren’t defined in the pod specification. With a `LimitRange`, you don’t have to manually set CPU and memory `requests` and `limits` each time you define a pod, since the `LimitRange` values will be applied automatically.

### Example Flow of the Requirement

- If you set a **ResourceQuota** specifying limits like `requests.cpu`, `limits.cpu`, `requests.memory`, and `limits.memory` for a namespace:
  - **Pods must specify these resource limits** (for `requests` and `limits`).
  - Alternatively, you can set a **LimitRange** to automatically provide default values.

So, in summary:
- When a `ResourceQuota` for resources is defined on a namespace, either you need to **manually specify resource limits** on each container, or you need to define a **LimitRange** so Kubernetes automatically applies these limits to new pods. This ensures that pods meet the requirements imposed by the `ResourceQuota`.