
We will be creating a multi image container, and we be mounting both the containers inside the pod on an emptyDir volume.

The first image we will be mounting on path /etc/myemptydir, while the second image will be  mounted at /temp/myemptydir 

We have exposed nignx at port 80

For generating deployment.yaml, we will use the below command -

`kubectl create deployment nginx-deployment --image=kiran2361993/troubleshootingtools:v1 --replicas=1 --dry-run=client -o yaml`

Refer emptydirdeployment.yaml

To go inside container and check the mount dir

`kubectl exec -it nginx-deployment-75694764b8-h2k8x -c troubleshootingtools -- bash`
```
root@nginx-deployment-75694764b8-h2k8x:/etc/myemptydir# pwd
/etc/myemptydir
root@nginx-deployment-75694764b8-h2k8x:/etc/myemptydir# ls
root@nginx-deployment-75694764b8-h2k8x:/etc/myemptydir# ls -al
total 8
drwxrwxrwx 2 root root 4096 Nov 22 13:53 .
drwxr-xr-x 1 root root 4096 Nov 22 13:53 ..

```
We can see that its empty, so we will create some dummy files here

```
root@nginx-deployment-75694764b8-h2k8x:/etc/myemptydir# for I in (1..10)
bash: syntax error near unexpected token `('
root@nginx-deployment-75694764b8-h2k8x:/etc/myemptydir# for I in {1..10}
> do
> echo $(date) > FILE-$I
> done
root@nginx-deployment-75694764b8-h2k8x:/etc/myemptydir# ls -al
total 48
drwxrwxrwx 2 root root 4096 Nov 22 14:02 .
drwxr-xr-x 1 root root 4096 Nov 22 13:53 ..
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-1
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-10
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-2
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-3
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-4
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-5
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-6
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-7
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-8
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-9
root@nginx-deployment-75694764b8-h2k8x:/etc/myemptydir# 

```
Now we will login to nginx pod, and see what there in our mount path

`kubectl exec -it nginx-deployment-75694764b8-h2k8x -c nginx -- bash`

```
root@nginx-deployment-75694764b8-h2k8x:/# cd /tmp/myemptydir/
root@nginx-deployment-75694764b8-h2k8x:/tmp/myemptydir# ls -al
total 48
drwxrwxrwx 2 root root 4096 Nov 22 14:02 .
drwxrwxrwt 1 root root 4096 Nov 22 13:53 ..
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-1
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-10
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-2
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-3
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-4
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-5
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-6
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-7
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-8
-rw-r--r-- 1 root root   29 Nov 22 14:02 FILE-9

```

We can see that the same files are reflecting in nginx container as well now. This is because they share the common vol, created using empty dir

## Trying to access docker inside container

If we run docker ps command inside troubleshooting container, we can see it is  not able to connect to docker daemon. This is because we are trying to access something which is on host from inside the container .

Hence it unable to connect to docker.sock
```
ubuntu@ip-172-31-17-89:~$ kubectl exec -it nginx-deployment-75694764b8-h2k8x -c troubleshootingtools -- bash
root@nginx-deployment-75694764b8-h2k8x:/# docker ps
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
root@nginx-deployment-75694764b8-h2k8x:/# 

```

To retrieve the information of whats in our host, we will deploy our deployment as Daemon Set because we want our deployment be deployed on each and every node , and now in deployment.yaml, volume mounts will remain same, we will mount at /run/containerd/containerd.sock , and the volumes will be now referring to hostPath

Now it will be able connect to container socket from hostPath.

```
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
```

This will be done in next Host Path.

Refer B.2.2 Hostpathdeployment.yaml

# Summary
## What happens once we run kubectl apply -f emptydirdpeloyment.yaml

Your understanding is on the right track, but let me refine it and provide a detailed explanation of what happens when you create a Deployment with `emptyDir` volumes and apply it using `kubectl apply -f`. Here's a step-by-step breakdown of the process, focusing on how Kubernetes handles this setup:

---

### 1. **kubectl applies the configuration**
- When you run `kubectl apply -f`, your YAML configuration is sent to the **API server** via an HTTP request.
- The **API server** validates the YAML against the Kubernetes schema and ensures that the resource definitions are correct.

---

### 2. **Persistence in etcd**
- The **API server** persists the Deployment resource into **etcd**, the key-value store that acts as the cluster's source of truth.
- At this stage, your Deployment is just a desired state stored in etcd.

---

### 3. **Scheduler identifies unscheduled Pods**
- The **Deployment controller** detects that the Deployment defines `replicas: 1` and creates a **ReplicaSet**, which in turn creates a new Pod.
- The **Scheduler** detects this unscheduled Pod and assigns it to a specific **worker node** based on factors like resource availability, taints, tolerations, and affinity rules.

---

### 4. **Kubelet pulls images and starts containers**
- On the assigned worker node, the **kubelet** (node agent) picks up the Pod specification from the API server.
- The kubelet:
  1. Pulls the specified container images (`nginx:latest` and `kiran2361993/troubleshootingtools:v1`) if they are not already present on the node.
  2. Prepares to create the containers defined in the Pod.
  3. Initializes any required **volumes**, including your `emptyDir`.

---

### 5. **Handling of the `emptyDir` volume**
- **What is `emptyDir`?**  
  `emptyDir` is a temporary directory created on the worker node's filesystem. The directory's lifecycle is tied to the Pod: it is created when the Pod starts and deleted when the Pod is terminated.

- **How is it provisioned?**
  - The kubelet creates the `emptyDir` on the node's filesystem in a directory reserved for that Pod.
  - The actual location on the worker node depends on the container runtime and kubelet configuration. For example, it might be under `/var/lib/kubelet/pods/<pod-id>/volumes/kubernetes.io~empty-dir/myemptydir`.

- **How is it shared between containers?**
  - The `emptyDir` is mounted into the containers as specified in `volumeMounts`.
  - In your YAML, the `emptyDir` is mounted as `/etc/myemptydir` in the `troubleshootingtools` container and as `/tmp/myemptydir` in the `nginx` container. Both containers can read and write to the same underlying directory on the host, enabling data sharing.

---

### 6. **Pod networking and IP assignment**
- The **CNI plugin** ensures that the Pod gets an IP address and is connected to the Kubernetes network.
- The `nginx` container exposes port `80`, making it accessible from within the cluster or externally depending on how you configure services.

---

### 7. **Volume lifecycle**
- The `emptyDir` persists as long as the Pod is running.
- If the Pod is deleted or restarted, the `emptyDir` is wiped, and a new directory is created when the Pod restarts.

---

### Key Points to Note:
1. **Controller vs kubelet responsibilities:**
   - The **controller** does not create directories or manage worker node resources. Its role is to ensure the desired state (e.g., ensure a Pod exists).
   - The **kubelet** on the worker node handles creating and mounting `emptyDir` volumes.

2. **Scope of `emptyDir`:**
   - It exists only within the Pod and does not persist beyond the Pod's lifecycle. It’s not shared across Pods.

3. **Data sharing in the same Pod:**
   - `emptyDir` is perfect for sharing data between containers in the same Pod because they run on the same node and share the same storage backend.

---

### Example Workflow:

1. **Applying YAML**:  
   `kubectl apply -f deployment.yaml`
   - API server validates and persists the Deployment resource.

2. **Pod Scheduling**:  
   The Scheduler assigns the Pod to Node-1.

3. **Node-1 (Worker Node)**:  
   - Kubelet:
     - Creates `emptyDir` under `/var/lib/kubelet/pods/<pod-id>/volumes/kubernetes.io~empty-dir/myemptydir`.
     - Starts both containers (`nginx` and `troubleshootingtools`) and mounts `emptyDir` to `/tmp/myemptydir` and `/etc/myemptydir` respectively.

4. **Runtime Behavior**:  
   - Both containers can write to and read from the `emptyDir`. Any changes made by one container are immediately visible to the other.

---

### Contrast with Other Volume Types:
- Unlike `emptyDir`, persistent volumes (PVs) retain data beyond the Pod's lifecycle.
- If the Pod crashes or restarts, the `emptyDir` data is lost, but PVs allow you to maintain data continuity.

Let me know if you'd like further clarification on any part!