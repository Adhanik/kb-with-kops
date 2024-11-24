
After creating daemon set, we can see the pods up and running

```
ubuntu@ip-172-31-17-89:~$ kubectl get daemonset.apps/troubleshooting-daemonset
NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
troubleshooting-daemonset   2         2         1       2            1           <none>          29s
ubuntu@ip-172-31-17-89:~$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
troubleshooting-daemonset-j954d   1/1     Running   0          48s
troubleshooting-daemonset-zrsvr   1/1     Running   0          48s
```

We will install below commands 
# apt-get update -y && apt-get install -f containerd
# ctr image pull docker.io/library/hello-world:latest
# ctr container ls

```
root@troubleshooting-daemonset-j954d:/# ctr container ls
CONTAINER    IMAGE    RUNTIME    
root@troubleshooting-daemonset-j954d:/# 

```

Now we can grab any information from host.
 
# Questions

## We saw that we are not able to acces docker ps insdie contianer.  can i not directly install docker inside the container only? why do the above? do we not install docker on KB cluster?

### sol

Good question! Let's break this down and address why we typically don't install Docker inside the container and why Kubernetes clusters often don’t use Docker directly:

---

### 1. **Why Not Install Docker Inside a Container?**

While technically possible, installing Docker inside a container is **not recommended** due to several reasons:

#### **a. Nested Virtualization Overhead**
- Docker inside a container introduces a nested virtualization setup: a container running another container runtime.
- This creates significant complexity and performance overhead, especially for tasks like managing networking and resource isolation.

#### **b. Best Practice: Containers Should Only Run Applications**
- Containers are meant to run lightweight applications or services, not full-fledged systems like Docker itself.
- Installing Docker inside a container goes against the principle of minimal, application-specific containerization.

#### **c. Complexity and Maintenance**
- Maintaining Docker inside a container adds unnecessary complexity to your setup.
- Any issue with Docker inside the container might cascade into larger problems, especially in production.

#### **d. Security Risks**
- Running Docker inside a container increases the attack surface.
- If a malicious actor gains access to the container, they could potentially control Docker and the host.

---

### 2. **Why Use HostPath for Docker/Containerd Socket?**

#### Kubernetes Node Architecture
- Kubernetes uses a **container runtime** (e.g., Containerd, CRI-O, or Docker) on each node to manage container lifecycles.
- When you deploy a Pod, Kubernetes talks to the container runtime via the **Container Runtime Interface (CRI)** to create containers.

#### Docker as a Container Runtime (Legacy)
- Kubernetes previously supported Docker as the default runtime (via a shim called `dockershim`).
- However, as of Kubernetes 1.20+, **dockershim is deprecated**, and Kubernetes uses Containerd (or other CRI-compatible runtimes) by default.

#### Why Not Install Docker Separately?
- Kubernetes already runs containers using the container runtime on each node.
- Instead of installing Docker, you can simply mount the host’s runtime socket (e.g., `/var/run/docker.sock` or `/run/containerd/containerd.sock`) into a container to interact with the existing runtime.

---

### 3. **Do Kubernetes Clusters Use Docker?**

#### **Docker and Kubernetes History**
- Kubernetes historically supported Docker as a container runtime via the `dockershim`.
- Docker includes a container runtime but is primarily a developer toolchain for building and managing images.

#### **Transition to Containerd**
- Modern Kubernetes clusters use **Containerd** or other CRI-compatible runtimes for container management.
- Containerd is a lightweight runtime that is part of Docker, and Kubernetes directly interacts with Containerd instead of Docker.

#### **When Docker Might Still Be Present**
- Docker may still be installed on some Kubernetes nodes for building images or running standalone Docker containers, but it’s not essential for Kubernetes operations.

---

### 4. **When to Install Docker Separately?**

#### Scenarios for Installing Docker:
- **Development Environments**: For developers working on Docker-specific tools or images.
- **Standalone Use Cases**: If you need Docker CLI commands (e.g., `docker build`, `docker run`).
- **Specific Workflows**: If you’re integrating tools like Docker Compose into your CI/CD pipelines.

#### Alternatives to Installing Docker:
- Use tools like `ctr` or `crictl` to interact with Containerd directly.
- Mount the host's Docker/Containerd socket to avoid installing Docker altogether.

---

### Example: Why Use HostPath Instead of Installing Docker?

#### Without HostPath (Installing Docker):
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: docker-inside-container
spec:
  containers:
  - name: docker
    image: docker:latest
    command: ["sh", "-c", "docker ps"]
```
- This requires setting up Docker inside the container, leading to the nested Docker problem and performance/security issues.

#### With HostPath (Preferred Method):
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: troubleshooting-daemonset
spec:
  selector:
    matchLabels:
      app: troubleshooting
  template:
    metadata:
      labels:
        app: troubleshooting
    spec:
      containers:
      - name: troubleshooting
        image: kiran2361993/troubleshootingtools:v1
        volumeMounts:
        - name: dockersock
          mountPath: "/var/run/docker.sock"
      volumes:
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
```
- This directly interacts with the host's Docker/Containerd runtime without installing Docker inside the container.

---

### Conclusion

- Kubernetes clusters no longer need Docker directly; they use Containerd or another CRI runtime.
- Installing Docker inside a container adds unnecessary complexity and is not recommended.
- Use **hostPath volumes** to access the host's runtime (Docker/Containerd) if required for troubleshooting or management tasks.

# Why docker ps fails inside continaer?

### Why `docker ps` Fails Inside the Container

1. **Isolation by Design**:
   - Containers are designed to operate in isolation from the host. They cannot directly access host resources unless explicitly configured.
   - The `docker ps` command communicates with the **Docker daemon**, which listens on a Unix socket (`/var/run/docker.sock` or `/run/containerd/containerd.sock`).

2. **No Access to Docker Daemon**:
   - In your example, the container is isolated and does not have access to the Docker socket on the host. Hence, when you run `docker ps`, it fails with:
     ```
     Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
     ```

---

### How to Fix: Mount the Docker/Containerd Socket

To enable a container to communicate with the host's Docker/Containerd daemon:

1. **HostPath Volume**:
   - Use the `hostPath` volume type in your Deployment/DaemonSet to mount the Docker/Containerd socket from the host into the container.

2. **Volume Mounting**:
   - Mount the socket at the correct path (`/run/containerd/containerd.sock` for Containerd or `/var/run/docker.sock` for Docker).

---

### Why a DaemonSet?

A **DaemonSet** ensures that a copy of your Pod runs on **every node** in the cluster. This is particularly useful when you want to troubleshoot or monitor the node-level containers and services, such as:

- Accessing the host's Docker/Containerd daemon.
- Collecting node-specific metrics or logs.
- Running a network or security monitoring agent.

By deploying as a DaemonSet:
- The Pod runs on every node, and each Pod has access to the **host's Docker/Containerd socket**.
- This allows troubleshooting tools in the container to interact with containers running on the host.

---

### Updated YAML for DaemonSet

Here's how your DaemonSet YAML would look:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: troubleshooting-daemonset
  labels:
    app: troubleshooting
spec:
  selector:
    matchLabels:
      app: troubleshooting
  template:
    metadata:
      labels:
        app: troubleshooting
    spec:
      containers:
      - name: troubleshooting
        image: kiran2361993/troubleshootingtools:v1
        volumeMounts:
        - name: containerdsock
          mountPath: "/run/containerd/containerd.sock"
      volumes:
      - name: containerdsock
        hostPath:
          path: /run/containerd/containerd.sock
          type: File
```

---

### What Happens After Deployment?

1. **DaemonSet Pods**:
   - Each node in the cluster will have a Pod running from this DaemonSet.

2. **Socket Access**:
   - Inside the container, the `/run/containerd/containerd.sock` file is mounted, providing direct access to the host's Containerd/Docker daemon.

3. **Testing the Setup**:
   - Execute a command in one of the Pods:
     ```bash
     kubectl exec -it troubleshooting-daemonset-<pod-id> -- bash
     ```
   - Run `docker ps` (or `ctr containers list` for Containerd) to view containers on the host.

---

### Why HostPath Should Be Used Carefully

Mounting the host's socket into a container gives the container significant access to the host's Docker/Containerd daemon. This can:
- Be a **security risk** because the container can control all containers on the host.
- Lead to **unintended consequences** if the container modifies critical containers or configurations.

Always restrict such setups to trusted tools and environments.

---

### Key Points to Remember

1. **DaemonSet**:
   - Use DaemonSets for node-specific tasks requiring direct access to host resources.

2. **Volume Types**:
   - Use `hostPath` for mounting host resources like `/var/run/docker.sock` or `/run/containerd/containerd.sock`.

3. **Security Implications**:
   - Only trusted containers should have access to host sockets to prevent misuse.

Let me know if you'd like more clarification!