
# Why probes are used?


Probes help in maintaining the reliability and availability of your applications.

- Readiness Probe: Ensures that your service doesn't receive traffic until it's fully ready.
- Liveness Probe: Detects when your container is in a bad state and needs a restart to recover.

Health probes are a one time activity. Once you set them up, they dont require any significant changes.


Suppose we have a node, on which multiple PODS(p1,p2,p3) are running, and p1 pod has mulitple containers(c1,c2,c3) running inside it. A user from the internet tries to access the application.

Suppose c3 goes down, and c1 and c2 are running properly. When c1 goes down, kubelet takes care of restarting the container, and kube proxy takes care of the networking part.

# How does the kubelet comes to know when the contianer goes down?

for this the kubelet monitors  continaers health and restarts failed containers by relying on liveness proble and readiness probes that it defines on each contianer. When a particular container does not serve traffic, helth probes come in action.


- Readiness probe - It indicates if the `container` (not pod) is ready to accept traffic. If a readiness probe fails, the kubelete marks the pod as "not ready" but it DOES NOT RESTART the container.


- Liveness probe - It determines if a container is still running or has crashed. if the liveness probe fails(eg due to network issue, timeout or unhealthy state), the kubelete considers the contianer unhealthy. The kubelet checks the `restartPlicy` defined on pod spec. It could be set to Always, OnFailure, Never. If its set to always, kubelet always restarts the container.

Liveness probe will restart the container.

## Default behaviour - If we dont explicitly define health probes, what kubelete does in this case?

Yes, if you don’t explicitly define liveness or readiness probes, the kubelet still has a default way of handling container failures, but it becomes less sophisticated: 

1. Default Health Check: 
• In the absence of custom probes, the kubelet doesn’t perform any active health checks on the container. It relies on the container’s process status to determine if it’s running or has exited unexpectedly. 

2. Container Exit Monitoring: 

• If a container’s main process exits (for any reason), the kubelet detects this based on the container runtime’s status. When the main process in the container terminates, the kubelet considers the container to have failed and will react based on the pod’s restartPolicy. 

3. RestartPolicy: 

• The kubelet respects the pod’s restartPolicy: 

- Always (default for most Pods): Kubelet will automatically restart the container if it fails. 
- OnFailure: The kubelet will restart the container only if it exits with a non-zero exit code. 
- Never: The kubelet won’t restart the container regardless of its exit status. 

In summary, without defined probes, the kubelet depends on the process’s exit status and restartPolicy. However, this setup doesn’t allow the kubelet to detect “soft” failures (like a process running but unresponsive), which liveness probes would catch.

We will define both health probes in our common manifest file.

## Process’s exit status

In Linux-based systems, process exit statuses are integers returned by a process to indicate its completion state. These statuses are essential for tools like the **kubelet** to determine what actions to take (e.g., restarting a Pod based on `restartPolicy`).

### **Common Process Exit Status Codes**

| **Exit Code** | **Meaning**                                                                                                                                  | **Details**                                                                                  |
|---------------|----------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| **0**         | **Success**                                                                                                                                 | Indicates that the process executed successfully without errors.                            |
| **1**         | **General Error**                                                                                                                           | A general error occurred, but it is not specific to a particular issue.                     |
| **2**         | **Misuse of Command**                                                                                                                       | The command was used incorrectly (e.g., invalid options).                                   |
| **126**       | **Command Cannot Execute**                                                                                                                  | Indicates that the command is found but cannot execute (e.g., insufficient permissions).    |
| **127**       | **Command Not Found**                                                                                                                       | The command is not available on the system.                                                 |
| **128**       | **Invalid Exit Argument**                                                                                                                   | An invalid argument was passed to the exit command.                                         |
| **128 + N**   | **Fatal Error Signal (N)**                                                                                                                  | Indicates a process was terminated by signal `N` (e.g., 130 for Ctrl+C, 137 for SIGKILL).   |
| **130**       | **Script Terminated by Ctrl+C**                                                                                                             | A signal interrupt (`SIGINT`) from the terminal.                                            |
| **137**       | **Killed by SIGKILL**                                                                                                                       | Indicates the process was forcibly killed (e.g., out-of-memory killer).                     |
| **139**       | **Segmentation Fault**                                                                                                                      | The process accessed invalid memory, leading to a crash (`SIGSEGV`).                       |
| **143**       | **Killed by SIGTERM**                                                                                                                       | Indicates graceful termination by `SIGTERM` (commonly sent to terminate Kubernetes Pods).   |

---

### **How Exit Codes Relate to Kubernetes Kubelet**

1. **Exit Code Monitoring by Kubelet**:
   - Kubernetes uses exit codes to understand why a container process exited. 
   - Based on the container's `exit status` and the Pod's `restartPolicy` (`Always`, `OnFailure`, or `Never`), the kubelet decides whether to restart the container.

2. **Liveness Probes for Unresponsive Processes**:
   - While exit statuses handle cases where the process stops, they don't detect "soft failures," where the process is running but not functioning properly (e.g., stuck in an infinite loop).
   - **Liveness probes** (HTTP, TCP, or command-based checks) are designed to catch such scenarios and restart the container proactively.

---

### **Practical Example in Kubernetes**

#### Pod Spec Using `restartPolicy` and Liveness Probe:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  containers:
  - name: example-app
    image: myapp:latest
    args: ["--run"]
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 3
      periodSeconds: 5
  restartPolicy: OnFailure
```

- **Process Exit Code Behavior**: If the container exits with a non-zero status, the kubelet will restart it based on the `OnFailure` policy.
- **Liveness Probe**: Ensures the process is healthy, even if it is still running (e.g., a stuck or unresponsive process will trigger a restart).

---

### **Debugging and Logs**

To debug common exit statuses in a Kubernetes environment:
```bash
kubectl logs <pod-name> --previous
kubectl describe pod <pod-name>
```

These commands help identify the exit code, error logs, and probe failures. Let me know if you'd like to explore specific scenarios!