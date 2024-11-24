
## Interview Question:

Scenario: You are running a Kubernetes application where a pod requires temporary storage to process intermediate data. The storage should persist if a container crashes but should be cleared when the pod is deleted.

1. Which Kubernetes volume type would you choose to meet this requirement?

2. What happens to the data stored in this volume if:

- The container inside the pod crashes and restarts?

- The pod is deleted?

3. How does this behavior differ from a hostPath volume?


Follow-up: Why might hostPath not be a suitable choice in this scenario?


# Sol


1. Since its temp storage, we can make use of empty dir. its lifecycle is that of pod, and once pod gets deleted, storage will also be deleted

2. A. If container crashes and restarts, for emptydir, data persists as lifecycle is connected to pod, so container crashing doesnt have any effect on data.

Once pod is deleted, data is lost then

3. Host path vol is persistent storage, and stores data even after pod is deleted. Its posses a security risk though, as it connects to host machine


# EXPLAINATION



The behavior of hostPath and emptyDir volumes in Kubernetes depends on the lifecycle of the pod and the volume type. Here’s how they work and why data may or may not persist:



1. emptyDir Behavior



Lifecycle Dependency:

- The emptyDir volume’s lifecycle is tied to the pod’s lifecycle, not the container’s lifecycle.

- When the pod is deleted, Kubernetes deletes the emptyDir volume and all the data stored in it, even if the node remains intact. This is because emptyDir is meant to provide temporary storage for the pod’s lifetime.

Container Crash:

- If a container within the pod crashes but the pod itself remains running, the data in the emptyDir volume is not lost. The container can restart and still access the data stored in the volume.

- If the pod restarts (e.g., due to a crash of all containers in the pod), the emptyDir volume is cleared.



2. hostPath Behavior



Lifecycle Independence:

- The hostPath volume directly maps a directory or file on the host node into the container. The data is stored on the node itself and is independent of the pod or container lifecycle.

- When the pod is deleted, the data in the hostPath volume is not deleted because it resides on the host filesystem.

- However, the data will only persist if the directory or file on the host node isn’t explicitly cleaned up by your application or scripts.

Container Crash:

- If a container crashes or the pod restarts, the data in the hostPath volume remains intact, as it is stored on the host node.


## Why emptyDir Data Is Deleted with the Pod



- The emptyDir volume is designed for ephemeral storage, meant to exist only while the pod is running. When the pod is deleted, Kubernetes ensures a clean slate by removing the associated data.

- This behavior ensures that temporary data does not accumulate on the host node, which could otherwise lead to storage bloat.



What Happens on Container Crash?



1. emptyDir:

- Data persists as long as the pod is not deleted. A crashing container can restart and still access the emptyDir volume.

- If the pod restarts, the emptyDir is wiped clean.

2. hostPath:

- Data persists because it is stored on the host filesystem, independent of the pod or container lifecycle.



## Best Practices



- Use emptyDir for temporary storage where data isn’t required to persist beyond the pod’s lifecycle.

- Use hostPath cautiously, as it tightly couples your pod to the specific host node, reducing portability and introducing potential storage management challenges.

- For persistent storage, use Persistent Volumes (PVs) backed by durable storage systems like NFS, EBS, or Ceph, which are independent of pod and node lifecycles.


