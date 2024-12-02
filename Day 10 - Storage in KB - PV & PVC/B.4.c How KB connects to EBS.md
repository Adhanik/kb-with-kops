In Kubernetes, the attachment of an Amazon EBS volume to a node is managed by the **EBS CSI (Container Storage Interface) driver**. This driver facilitates the dynamic or static provisioning, attachment, detachment, and management of EBS volumes for your pods and nodes.

Here’s how Kubernetes is able to attach your EBS volume to the specified node:

---

### 1. **Static Volume Binding with `PersistentVolume` (PV) and `PersistentVolumeClaim` (PVC)**
- **Step 1**: In your `deployment.yaml`, you specify the `volumeClaimTemplates` or use an existing `PersistentVolumeClaim` (PVC). The PVC requests storage.
- **Step 2**: The PVC binds to a specific `PersistentVolume` (PV) which is backed by the EBS volume you've manually created.
  - This is done using the `volumeId` field in the PV definition, such as:
    ```yaml
    kind: PersistentVolume
    apiVersion: v1
    metadata:
      name: my-ebs-volume
    spec:
      capacity:
        storage: 10Gi
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      csi:
        driver: ebs.csi.aws.com
        volumeHandle: vol-0890ac4f2a40000f5
    ```
- **Step 3**: The CSI driver detects the PVC-to-PV binding and starts handling the attachment process.

---

### 2. **How the Volume is Attached to the Node**
- **CSI Controller**: The **EBS CSI driver** in Kubernetes uses its controller to interact with AWS APIs to attach the specified EBS volume to the node where your pod is scheduled.
  1. The **CSI Controller** receives a `ControllerPublishVolume` request when the pod is scheduled.
  2. The driver issues an **AWS EC2 AttachVolume API call** to attach the EBS volume to the selected node (instance).
  
- **Node Plugin**: Once attached, the **node plugin** (also part of the EBS CSI driver) ensures that the volume is made available to the container by mounting it at the specified path in the pod.

---

### 3. **Role of IAM Permissions**
For this process to work:
- The **IAM Role** associated with the node (or CSI Controller) must have the following permissions:
  - `ec2:AttachVolume`
  - `ec2:DetachVolume`
  - `ec2:CreateVolume`
  - `ec2:DeleteVolume`
  - `ec2:DescribeVolumes`

If these permissions are missing or insufficient, Kubernetes cannot perform the attach or detach operations, resulting in errors like the one you encountered (`UnauthorizedOperation`).

---

### 4. **Dynamic Provisioning**
If you had used **dynamic provisioning** with a `StorageClass`, Kubernetes would create the EBS volume automatically via the CSI driver based on the `PVC` request. The attachment process would then proceed in the same manner.

Example `StorageClass`:
```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
parameters:
  type: gp2
```

Example PVC:
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: my-pvc
spec:
  storageClassName: ebs-sc
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

---

### Summary
The EBS CSI driver connects the volume to the node as follows:
1. Kubernetes API -> PVC -> PV (or directly specifies a volume in the pod spec).
2. EBS CSI driver issues AWS API calls to attach the EBS volume to the correct node.
3. Node plugin mounts the volume inside the pod container.

The process is transparent to the user, but it relies on proper IAM permissions and CSI configuration. If any component fails (e.g., IAM role, CSI driver), the attachment fails.