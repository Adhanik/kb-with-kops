
# Dynamic Provisioning of EBS Volumes in Kubernetes

## Overview

In this guide, we'll explore how to transition from static provisioning of EBS volumes in Kubernetes to dynamic provisioning, leveraging `StorageClass` and the `EBS CSI driver`.

### 1️⃣ Static Provisioning (Your Previous Method)

#### How It Worked

1. **Manually Create EBS Volumes**

   Example AWS CLI command:
   ```bash
   aws ec2 create-volume --volume-type gp2 --size 5 \
   --availability-zone us-east-1a \
   --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=static-pv-5gb}]'
   ```

   Repeat for 10GB, 15GB, 20GB volumes.

2. **Define PersistentVolumes (PV) with AWS EBS**

   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: pv-5gb
   spec:
     capacity:
       storage: 5Gi
     volumeMode: Filesystem
     accessModes:
       - ReadWriteOnce
     persistentVolumeReclaimPolicy: Retain
     awsElasticBlockStore:
       volumeID: vol-0abcd1234efgh5678  # Manually created EBS ID
       fsType: ext4
   ```

3. **Developers Request PVCs**

   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: my-claim
   spec:
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 5Gi  # Must match one of the manually created PV sizes
   ```

4. **Limitations of Static Provisioning**
   - Developers can’t request arbitrary storage sizes.
   - Manual intervention required for new volumes.
   - Limited automation and scalability.

---

### 2️⃣ Moving to Dynamic Provisioning

#### Goal

- ✅ Developers can request any storage size without defining PVs.
- ✅ Kubernetes automatically provisions EBS volumes.
- ✅ No need to manually create PVs and attach EBS volumes.

---

### 3️⃣ Step-by-Step Deep Dive into Dynamic Provisioning

#### 🔹 Step 1: Delete the Default StorageClass (if needed)

KOPS (Kubernetes Operations) by default comes with a StorageClass that might not allow dynamic provisioning for arbitrary sizes.

1. List existing StorageClasses:
   ```bash
   kubectl get storageclass
   ```

2. If there’s a default StorageClass preventing dynamic provisioning, delete it:
   ```bash
   kubectl delete storageclass default
   ```

#### 🔹 Step 2: Create a New StorageClass for AWS EBS

To enable dynamic provisioning, define a StorageClass that automatically provisions EBS volumes.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"  # Set as default
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2  # General-purpose SSD
  fsType: ext4
  zones: us-east-1a  # Modify based on your region
  iopsPerGB: "10"  # Only applicable for io1 type
reclaimPolicy: Delete  # Automatically delete volume when PVC is deleted
allowVolumeExpansion: true  # Enables resizing
```

- `provisioner: kubernetes.io/aws-ebs`: Automatically creates EBS volumes.
- `parameters`: Specifies volume type, filesystem, and availability zone.
- `allowVolumeExpansion: true`: Developers can resize volumes if needed.

Apply the new StorageClass:
```bash
kubectl apply -f storageclass.yaml
```

#### 🔹 Step 3: Developers Can Now Request Storage with PVC

Since we enabled dynamic provisioning, developers can now request any storage size using a PVC.

Example PVC Requesting 100GB (Previously Not Possible):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-dynamic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi  # Any size is allowed now
  storageClassName: gp2-storage
```

When this PVC is applied:
```bash
kubectl apply -f pvc.yaml
```

Kubernetes will:
1. Automatically create an EBS volume of 100GB.
2. Automatically create a PersistentVolume (PV).
3. Bind the PVC to the newly created PV.

✅ **No need to manually create EBS volumes!**

#### 🔹 Step 4: Verify Provisioning

- **Check if PVC is Bound:**
   ```bash
   kubectl get pvc my-dynamic-pvc
   ```
   Output:
   ```bash
   NAME             STATUS    VOLUME                                     CAPACITY  ACCESS MODES   STORAGECLASS
   my-dynamic-pvc   Bound     pvc-1234abcd-5678-efgh-9101-ijklmnopqr     100Gi     RWO            gp2-storage
   ```

- **Check Automatically Created PV:**
   ```bash
   kubectl get pv
   ```
   Output:
   ```bash
   NAME                                     CAPACITY  ACCESS MODES   RECLAIM POLICY   STATUS   STORAGECLASS
   pvc-1234abcd-5678-efgh-9101-ijklmnopqr   100Gi     RWO            Delete           Bound    gp2-storage
   ```

- **Verify on AWS (Check EBS Volume):**
   ```bash
   aws ec2 describe-volumes --filters Name=tag:Name,Values=kubernetes.io/cluster/my-cluster
   ```
   Output:
   ```json
   {
       "Volumes": [
           {
               "VolumeId": "vol-0xyz1234abcd5678",
               "Size": 100,
               "AvailabilityZone": "us-east-1a",
               "VolumeType": "gp2"
           }
       ]
   }
   ```

✅ **New 100GB EBS volume automatically created!**

---

### 4️⃣ Recap: What Changed?

| **Before (Static Provisioning)**                           | **After (Dynamic Provisioning)**                             |
| ---------------------------------------------------------- | ------------------------------------------------------------ |
| Manually create EBS volumes using AWS CLI.                 | Kubernetes automatically creates EBS volumes.                |
| Define PersistentVolume (PV) with specific EBS volume IDs. | No need to define PVs; PVCs dynamically request storage.    |
| Developers can only request pre-created sizes (e.g., 5GB, 10GB). | Developers can request any size (e.g., 100GB, 200GB).        |
| Manual intervention required for new storage.              | Fully automated and scalable.                               |
| Storage is fixed at creation.                              | Supports volume expansion (`allowVolumeExpansion: true`).    |

---

### 5️⃣ Bonus: How to Enable Auto-Resizing of PVC?

If a developer wants to expand an existing PVC from 100GB to 150GB, they can modify the PVC:

```bash
kubectl edit pvc my-dynamic-pvc
```

Change:
```yaml
resources:
  requests:
    storage: 150Gi  # Resize from 100Gi to 150Gi
```

Check if the resize happened:
```bash
kubectl get pvc my-dynamic-pvc
```

✅ **Kubernetes resizes the EBS volume automatically** (if `allowVolumeExpansion: true` is set).

---

## Final Thoughts

- You deleted the default StorageClass in KOPS.
- You created a new StorageClass (`gp2-storage`) that allows dynamic provisioning.
- Developers can request any storage size via PVCs, and Kubernetes automatically provisions EBS volumes.
- The entire process is now automated and scalable.

