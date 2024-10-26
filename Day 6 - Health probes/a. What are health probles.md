
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

• Always (default for most Pods): Kubelet will automatically restart the container if it fails. 
• OnFailure: The kubelet will restart the container only if it exits with a non-zero exit code. 
• Never: The kubelet won’t restart the container regardless of its exit status. 

In summary, without defined probes, the kubelet depends on the process’s exit status and restartPolicy. However, this setup doesn’t allow the kubelet to detect “soft” failures (like a process running but unresponsive), which liveness probes would catch.

We will define both health probes in our common manifest file.