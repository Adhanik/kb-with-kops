

A Liveness Probe ensures that your container is running properly. If the probe fails, Kubernetes will restart the container.

- Example:

apiVersion: v1
kind: Pod
metadata:
  name: liveness-example
spec:
  containers:
  - name: myapp
    image: myapp:latest
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 3
      periodSeconds: 5

In this example:

httpGet: Similar to the Readiness Probe, but used to determine if the container should be restarted.
initialDelaySeconds: The probe starts checking 3 seconds after the container starts.
periodSeconds: The probe checks the endpoint every 5 seconds.