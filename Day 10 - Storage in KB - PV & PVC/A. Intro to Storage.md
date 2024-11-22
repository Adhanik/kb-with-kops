
# Storage

Ways to provide both long-term and temporary storage to PODS in your cluster.

- Volumes
- Persistent Volumes
- Projected Volumes
- Ephemeral Volumes
- Storage Classes
- Dynamic Volume Provisioning
- and many more

## Volumes

### Challenges faced

1. files on a container are ephemeral, so when a container crashes or is stopped, container state is not saved so all of the files that were created or modified during the lifetime of container are lost. 

kubelet restartes the container with a clean state.

2. Another problem occurs when multiple containers are running in a POD and need to share files. It can be challenging to setup and access a shared filesystem across all of the containers

Kubernetes Volume abstraction solves both of these problems.

KB supports many types of volumes. A pod can use any number of volume types simultaneously -

- Ephemeral volume types have lifetime of a pod. When a pod ceases to exist, KB destroys ephemeral volumes
- Persistent volumes exist beyond the lifetime of a pod, KB does not destroy PV

### Types of Volume

KB supports several types of volumes

1. emptyDir - For a pod that defines an emptyDir volume, the volume is created when the POD is assigned to a node. The emptydir volume is initially empty. All containers in the POD can read and write the same files in the emptyDir volume, though that volume can be mounted at the same or diff paths in each container.

When pod is removed from a node for any reason, the data in emptyDir is deleted permanently. So this is a **Temporary Volume**

Note - A container crashing does not remove a pod from a node. The data in emptydir volume is safe if container crashes.

#### E.G.

We have a node, inside which we have our Pod, which consist of contianer/multi-contianers. By default, when we deploy a deployment with replicas set 1, a pod is created along with which a default vol is also created, called as empty dir. we can mount this vol at /etc for container1 and /cache for container2 

Anything that you share at /cache will be repliclated on /etc as well as both are part of same volume.

```
spec:
  containers:
  - image:
    name:
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir:
      sizeLimit: 500Mi
```

2. hostPath - A hostPath volume mounts a file or dir from host node's filesystem into your pod. Using this volume type has many security risk, hence not recommended to use.

Also hostPath volume usage is not treated as ephemeral storage usage. You need to monitor the disk usage by yourself bcoz excessive hostPath disk usage will lead to disk pressure on the node.

```
spec:
  containers:
  - image:
    name:
    volumeMounts:
    - mountPath: /foo
      name: example-volume
  volumes:
  - name: example-volume
    hostPath:
      path: /data/foo
      type: Directory
```

3. EBS (Elastic Block Storage)

Suppose we have a pod, inside which we have our contianer which is running a mongodb application. When container is running, customer uploads a image/file to mongodb, so all data is stored on this mongodb. for some reasons, when containers goes down, and when container comes up, whatever data was saved is lost now, because containers are ephemeral in nature.

So, to avoid losing data, we will use EBS as volume. For this we need to create a EBS Volume ( where we have to give storage, Tags, cluster name etc, ), and once volume is created, we get a volume id. This volume id is passed in YAML manifest.

You have to also mention the id of node to which you want to mount this volume to. Give the worker node AMI id 
```
spec:
  containers:
  - name:
    image:

  volumes:
  - name: mongodb-data
    awsElasticBlockStore:
      volumeID: # EBS Vol id which we created
      fsType: 
  nodeSelector:
    kubernetes.io/hostname: i-00293239292as22
```

This involves a lot of manual step, hence not very much preferred.

4. PV and PVC

A PV is piece of storage in cluster that has been provisioned by and admin or dynamically provisioned using `Storage Classes.` PVs are resources in the cluster. 

- PVs are volume plugins like Volumes, but have a lifecycle INDEPENDENT of any individual POD that uses the PV.

A PVC is a request for storage by a user. It is similar to POD. 

- Pods consume node resources and PVCs consume PV resources. 
- Pods can request specific levels of resources(CPU & memory). CLAIMS can request specific size and access modes (e.g they can be mounted ReadWriteOnce, ReadOnlyMany, ReadWriteMany, or ReadWriteOncePod)

Cluster Admins need to be able to offer a variety of PVs that differ in more ways than size and access modes, without exposing users to the details of how those volumes are implemented. For these needs, there is the `StorageClass` resource.

#### Provisioning

There are 2 ways PVs may be provisioned: statically or dynamically

##### Static

- A cluster administrator creates a number of PVs. They carry the details of the real storage, which is available for use by cluster users. They exist in the Kubernetes API and are available for consumption.

Suppose we have created 5 PV

A(2 G.B), B(4 G.B), C(6 G.B), D(8 G.B), E(10 G.B)

If a devloper requires to mount 4 gb of vol to its dir, developer will raise a PVC. Similarly they can raise for each. Once the PV is acquired or has been assigned, it gets bonded to a PVC. The status will change from  `Available` to`Bonded`.

Now suppose all the PV get bounded by PVC, and now a dev want 30 GB of gp2 vol, this is not possible now as all PV are bounded.

For this to make happen, we make use of Dynamic Provisioning client. 

##### Dynamic 

- When none of the static PVs the administrator created match a user's PersistentVolumeClaim, the cluster may try to dynamically provision a volume specially for the PVC. This provisioning is based on StorageClasses: the PVC must request a storage class and the administrator must have created and configured that class for dynamic provisioning to occur. Claims that request the class "" effectively disable dynamic provisioning for themselves.

- To enable dynamic storage provisioning based on storage class, the cluster administrator needs to enable the DefaultStorageClass admission controller on the API server. This can be done, for example, by ensuring that DefaultStorageClass is among the comma-delimited, ordered list of values for the --enable-admission-plugins flag of the API server component. For more information on API server command-line flags, check kube-apiserver documentation.

## Summary

1. **PV and PVC Binding**:
   - Persistent Volumes (PVs) are pre-provisioned by the administrator, each with a defined size and access mode.
   - Persistent Volume Claims (PVCs) are requests made by developers for storage. 
   - When a PVC matches the requirements of an available PV (size, access mode, etc.), the PV gets **bound** to the PVC. Its status changes from `Available` to `Bound`.

2. **Scenario When All PVs are Bound**:
   - If all pre-provisioned PVs are bound, and a new PVC request (e.g., 30 GB) is made, the request cannot be fulfilled because no matching PV is available.

3. **Dynamic Provisioning**:
   - This is where **Dynamic Provisioning** comes in. Instead of requiring pre-created PVs, the Kubernetes cluster can automatically provision storage on-demand.
   - This happens through **StorageClasses**, which define the parameters for creating new storage (e.g., size, performance tier, disk type like gp2 for AWS EBS).

4. **StorageClass**:
   - When a PVC specifies a `StorageClass`, Kubernetes uses the parameters defined in the `StorageClass` to dynamically provision the required storage from the underlying cloud provider or storage backend.

---

### **Clarifications and Refinements:**

1. **Role of `StorageClass` in Kops**:
   - When you deploy a cluster using **Kops**, it sets up a default `StorageClass`. This is used for dynamic provisioning if the PVC specifies the class or doesn't specify one (default class is used).
   - The storage backend (e.g., AWS EBS for Kops) is abstracted, and the storage is provisioned as needed.

2. **Dynamic Provisioning and Persistent Volumes**:
   - In dynamic provisioning, the PV is **not pre-created by the administrator**. Instead, it is **created dynamically** when a PVC request is made. The PV is directly associated with the PVC that triggered its creation.

3. **Static vs. Dynamic Provisioning**:
   - In **static provisioning**, the admin manually creates PVs beforehand, and developers must request storage that matches one of these PVs.
   - In **dynamic provisioning**, the storage system automatically provisions the requested storage, simplifying workflows and ensuring availability.

---

### **Examples of Static vs. Dynamic Provisioning**

#### **Static Provisioning Example**:
1. **Admin Creates PVs**:
   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: pv-a
   spec:
     capacity:
       storage: 5Gi
     accessModes:
     - ReadWriteOnce
     persistentVolumeReclaimPolicy: Retain
     hostPath:
       path: "/mnt/data-a"
   ```

2. **Developer Requests PVC**:
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: pvc-a
   spec:
     accessModes:
     - ReadWriteOnce
     resources:
       requests:
         storage: 5Gi
   ```

3. The PVC `pvc-a` gets bound to `pv-a` if it matches the requirements.

---

#### **Dynamic Provisioning Example**:
1. **Admin Configures a StorageClass**:
   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: standard
   provisioner: kubernetes.io/aws-ebs
   parameters:
     type: gp2
   ```

2. **Developer Creates a PVC**:
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: pvc-dynamic
   spec:
     accessModes:
     - ReadWriteOnce
     resources:
       requests:
         storage: 20Gi
     storageClassName: standard
   ```

3. **What Happens**:
   - Kubernetes dynamically provisions a new PV using the `standard` `StorageClass`.
   - The new PV is created and immediately bound to `pvc-dynamic`.

---

### **Conclusion**:
Your understanding is correct with slight refinements:  
- Dynamic provisioning eliminates the need for pre-created PVs by automating the creation process using `StorageClasses`.  
- Static provisioning requires manual effort to create PVs beforehand, and only matching requests can be fulfilled.  
Dynamic provisioning is especially useful in cloud environments where storage is elastic and can be provisioned on demand.
