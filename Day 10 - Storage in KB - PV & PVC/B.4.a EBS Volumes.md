

## Why are we using EBS?

Containers are stateless, if there is no volume attached, once the pod is deleted, the data is also deleted as containers are ephemeral in nature.

We need to make sure that there is no data loss. For this, we will make use of EBS volume

## Creating a EBS Volume

1. Go to EBS Volumes - Select volume as GP2.
2. Give size - 10 G.B
3. Give tag as Kubernetes, and value cloudadhanik.xyz
4. Create Volume

- Copy the volume id - vol-0890ac4f2a40000f5

- We will create a Deployment which has image as mongodb 

`kubectl create deployment mongo-deployment --image=mongodb --replicas=1 --dry-run=client -o yaml`

- We will add the above EBS volume created in our deployment. This way of doing is called as static provisioning.

###  VolumeMounts and Data Replication to EBS

#### Static Provisioning

The configuration which we will use below uses static provisioning, where the EBS volume (vol-0890ac4f2a40000f5) is pre-created in AWS and explicitly referenced in the Deployment. For dynamic provisioning, you would define a StorageClass in Kubernetes, and Kubernetes would automatically create and manage EBS volumes as needed based on PersistentVolumeClaim (PVC) specifications. This removes the need for manual volume creation and node binding.

- Read B.4.b deployment.yaml . The features used in that yaml are discussed below

- You specify volumeMounts in the Pod to map a directory inside the container (e.g., /data/db) to a volume provided by Kubernetes. In this case, the volume is backed by an AWS EBS volume.
- Any data written to /data/db inside the container is persisted on the EBS volume. For example:

    Writing a file to /data/db/myfile.txt inside the container will store it in the EBS volume.
    If the Pod is deleted and recreated on the same node, the data in the EBS volume will still be accessible.

- The volume mount ensures that data is persisted outside the container's ephemeral storage, which would otherwise be lost when the container restarts.

- If multiple Pods are created for the same Deployment, EBS volumes cannot be shared across multiple nodes simultaneously. AWS EBS volumes are block storage and can only be attached to a single node at a time. This is why the nodeSelector is critical 

- The fsType specifies the filesystem type to use on the EBS volume. In this example, you are using ext4, which is a common choice for Linux systems.
You can use other filesystem types like xfs or ext3 if required, depending on your application's needs.
Why it Matters:

- The choice of filesystem type can affect performance, compatibility, and data integrity based on the workload. For most use cases, ext4 is suitable and widely supported.

- kubernetes.io/hostname: i-03431a589cb5ac5d3 - The nodeSelector ensures that the Pod is scheduled on a specific node (i-03431a589cb5ac5d3) in the cluster.
Since AWS EBS volumes are zone-specific and can only be attached to one node at a time, you must ensure the Pod runs on the node where the volume is attached.
Key Points:

- If Kubernetes tries to schedule the Pod on a different node, it won't work because the volume cannot be accessed from that node. This makes the nodeSelector critical for ensuring the Pod is scheduled correctly.
Alternatively, you can use StorageClasses with dynamic provisioning to avoid manually managing nodeSelector and volume attachment (see below).
