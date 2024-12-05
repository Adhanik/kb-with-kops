
Storage class helps us to create diff vol types. When we delete the default storage class, then we can create new storage class so that they can craete gp2 and IOPS pvc dynamically.

After running kubectl apply -f Storageclass.yaml

```
kubectl get storageclasses.storage.k8s.io    
NAME                      PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2 (default)             kubernetes.io/aws-ebs   Delete          Immediate              false                  49s
io1                       kubernetes.io/aws-ebs   Delete          Immediate              false                  49s
kops-csi-1-21 (default)   ebs.csi.aws.com         Delete          WaitForFirstConsumer   true                   4h12m
kops-ssd-1-17             kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   true                   4h12m

```

So now if we claim for 30 gb

```

apiVersion: v1
kind: PersistentVolumeClaim 
metadata:
  name: task-pv-claim8
spec: 
  storageClassName: gp2 
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 30Gi
```

We can see it will be bounded and not in pending state anymore, as before where we have deleted the default gp2 storage class, and the claim was not being assigned.

Now since we have defined storage class, we can create request for any volume storage, and KOPS automatically assigns that volume using dynamic allocation.


```
kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
task-pv-claim1   Bound    aws-pv1                                    2Gi        RWO            gp2            123m
task-pv-claim2   Bound    aws-pv2                                    4Gi        RWO            gp2            112m
task-pv-claim3   Bound    aws-pv3                                    6Gi        RWO            gp2            112m
task-pv-claim4   Bound    aws-pv4                                    8Gi        RWO            gp2            112m
task-pv-claim5   Bound    aws-pv5                                    10Gi       RWO            gp2            112m
task-pv-claim6   Bound    pvc-e7ddb70c-6cd9-4c79-98a2-1427f59726c3   20Gi       RWO            gp2            79m
task-pv-claim8   Bound    pvc-761526be-d0f9-49c4-8e21-7a27343a8f86   30Gi       RWO            gp2            4s

```

In EBS volume, you can see the volume created dynamically - 
`cloudadhanik.xyz-dynamic-pvc-e7ddb70c-6cd9-4c79-98a2-1427f59726c3`


### Summary

The behavior you observe is expected and is due to how Kubernetes handles Persistent Volume Claims (PVCs) and Persistent Volumes (PVs) when using a **StorageClass** that supports dynamic provisioning.

---

### **Detailed Explanation**

1. **Dynamic Provisioning with StorageClass (`gp2`)**:
   - When you create a PVC and specify a `StorageClassName` (e.g., `gp2`), Kubernetes checks if there are any existing PVs that satisfy the PVC request (capacity, access mode, etc.).
   - If no existing PVs match the PVC request, and the specified StorageClass supports **dynamic provisioning**, Kubernetes dynamically provisions a new EBS volume for the PVC.

2. **Your Scenario**:
   - You created 5 EBS volumes manually and created PVs that are **statically provisioned** (manually bound to those volumes).
   - When you created the sixth PVC (`task-pv-claim6`) with a request for 20Gi, Kubernetes could not find a pre-existing PV that matched the request.
   - Because the PVC's `StorageClassName` (`gp2`) supports dynamic provisioning, Kubernetes automatically created a new EBS volume with a capacity of 20Gi and bound it to the PVC.

3. **Dynamic EBS Volume Creation**:
   - The dynamically provisioned volume has a generated name, such as `pvc-e7ddb70c-6cd9-4c79-98a2-1427f59726c3`, which corresponds to the dynamically created PV for the PVC.
   - You can verify this by inspecting the details of the new PV:
     ```bash
     kubectl describe pv pvc-e7ddb70c-6cd9-4c79-98a2-1427f59726c3
     ```
     This should show the `VolumeHandle`, which is the AWS EBS volume ID for the dynamically created volume.

4. **What If Dynamic Provisioning Is Not Supported?**:
   - If the `gp2` StorageClass did not support dynamic provisioning, the PVC would remain in a `Pending` state, as no matching PV would be available.

---

### **How to Control This Behavior**

1. **Avoid Dynamic Provisioning**:
   - Set `StorageClassName: ""` in your PVC. This disables dynamic provisioning and ensures only manually created PVs can be used:
     ```yaml
     storageClassName: ""
     ```

2. **Verify Existing PVs First**:
   - Ensure all required volumes are created as PVs before creating PVCs.

3. **Disable Dynamic Provisioning for a StorageClass**:
   - Edit the StorageClass and set `allowVolumeExpansion: false` and disable dynamic provisioning if needed:
     ```bash
     kubectl edit storageclass gp2
     ```

---

### **Dynamic Provisioning Logs**
To see how Kubernetes created the EBS volume, check the logs of the `cloud-controller-manager` pod in your Kubernetes cluster:
```bash
kubectl logs -n kube-system <cloud-controller-manager-pod>
```

This will show the AWS API call made to provision the new EBS volume.