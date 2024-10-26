

# Readiness Probe

A Readiness Probe determines if a container is ready to handle requests. If the probe fails, the container is temporarily removed from service.

- Example:

apiVersion: v1
kind: Pod
metadata:
  name: readiness-example
spec:
  containers:
  - name: myapp
    image: myapp:latest
    readinessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10


In this example:

- httpGet: The probe sends an HTTP GET request to /healthz on port 8080.
- initialDelaySeconds: The probe waits 5 seconds before starting checks.
- periodSeconds: The probe checks the endpoint every 10 seconds.