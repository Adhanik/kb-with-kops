
# Question

How a svc in KB is assigned a endpoint? suppose i have created a svc using kubectl expose alpha1 --port 8000 --target-port-80 --type Nodeport, and we have alpha1 a pod which is running.

If i delete the above pod alpha1, the svc is not deleted, and if i do kubectl describe svc, then endpoint shows as <none>. and if i create alpha1 again using below 

apiVersion: v1
kind: Pod
metadata:
    labels:
      run: alpha1
      app: nginx
    name: alpha1
    namespace: alpha
spec:
    containers:
    -  image: nginx:latest
        name: alpha1

Then endpoint is again assigned after pod is deployed successfully. how does this svc know to connect to this pod only. if i do kubectl get pods -o wide , i see the pod ip, in endpoint, i see the same ip:port 

# Sol

In Kubernetes, a **Service (svc)** is responsible for providing a stable network endpoint to access one or more Pods. The scenario you described illustrates how Kubernetes automatically manages **Service Endpoints** for Pods based on labels and selectors.

### Breakdown of the Process:

1. **Creating a Service (`kubectl expose`)**:
   When you run:
   ```bash 
   kubectl expose pod alpha1 --port=8000 --target-port=80 --type=NodePort -n <ns>
   ```
   Kubernetes creates a **Service** that exposes the `alpha1` Pod at `NodePort`. Behind the scenes, the Service will look for Pods that match a **label selector** (if you haven’t explicitly provided a label selector, it defaults to the Pod's labels).

2. **How Services Track Pods (Selectors and Labels)**:
   Kubernetes uses **labels** and **selectors** to associate a Service with the right Pods. For example, if your `alpha1` Pod has the following labels:

   ```yaml
   metadata:
     labels:
       run: alpha1
       app: nginx
   ```
   The Service will automatically select any Pod with the label `run: alpha1` to route traffic to.

3. **Endpoints**:
   The **Endpoint** is the actual IP and port of the Pod(s) backing the Service. When a Service is created, Kubernetes creates a corresponding **Endpoints** object that lists the IPs of the Pods matching the label selector. For example:

   - The Service checks which Pods have the labels `run: alpha1`.
   - If a Pod has the matching labels, the Service adds that Pod’s IP and port to its **Endpoints**.

4. **What Happens When the Pod is Deleted**:
   - If the `alpha1` Pod is deleted, the Service’s **Endpoints** object is updated to reflect that there are no available Pods, and you see:
     ```
     Endpoints: <none>
     ```
   - The Service itself still exists, but it has no associated Pods to route traffic to.

5. **Recreating the Pod (`alpha1`)**:
   When you recreate the Pod with the same labels (`run: alpha1`), the Service automatically detects the new Pod because it matches the Service's label selector.

   - The Service updates its **Endpoints** object, associating the new Pod’s IP and port (e.g., `10.244.1.3:80`).
   - The **Endpoints** now reflect the IP address of the newly created Pod.

### How the Service "Knows" to Connect to the Pod:
- **Label Matching**: The Service "knows" which Pod(s) to connect to by using the label selector. In your case, the label `run: alpha1` is used to select the Pod.
- When the Pod is recreated with the same label (`run: alpha1`), the Service automatically includes it in its list of Endpoints.

### Visualization:
Here's a high-level workflow:
1. **Service Creation**: The Service is created with a label selector (`run: alpha1`).
2. **Pod Deletion**: When the Pod `alpha1` is deleted, the Service detects that no Pods match its label selector, so the Endpoints are set to `<none>`.
3. **Pod Re-creation**: When a new Pod with the label `run: alpha1` is created, the Service updates its Endpoints with the Pod's IP and target port.

### Verify this by Checking Endpoints:
After recreating the Pod, you can verify that the Service has updated its Endpoints by running:
```bash
kubectl describe svc <service-name>
```
Or:
```bash
kubectl get endpoints <service-name>
```
You should see the new Pod’s IP and port listed as the Endpoint.

### Example:

- Before Pod deletion:
  ```bash
  Endpoints: 10.244.1.3:80
  ```
- After Pod deletion:
  ```bash
  Endpoints: <none>
  ```
- After Pod recreation:
  ```bash
  Endpoints: 10.244.1.5:80
  ```

This dynamic binding of Pods to Services ensures that Services provide a consistent way to access Pods, even as Pods are deleted and recreated in the cluster.

### Summary:
- **Services use label selectors** to find matching Pods.
- **Endpoints are dynamically updated** based on the presence of Pods that match the Service’s label selector.
- When a Pod is deleted, the Endpoints are cleared. When a new Pod with matching labels is created, the Endpoints are updated automatically.

Let me know if you need more clarity!