
We will now mount all the PV. The volume Mounts will refer to the path inside pod where anything that is kept will be copied to the EBS volume.

Refer mountclaims.yaml

Once we have created the deployment, our pod will be ready

```
 kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
mongo-deployment-cfd44967c-dtzvg   1/1     Running   0          25s

```

## Exec inside the pod

We have given the below mountPath
volumeMounts:
          - name: mongodb-data1
            mountPath: /data/db1
          - name: mongodb-data2
            mountPath: /tmp/db2

`kubectl exec -it mongo-deployment-cfd44967c-dtzvg -- bash`
We can see that the path are empty

```
root@mongo-deployment-cfd44967c-dtzvg:/# cd data/db1
root@mongo-deployment-cfd44967c-dtzvg:/data/db1# ls -ltr
total 16
drwx------ 2 root root 16384 Dec  4 12:20 lost+found
root@mongo-deployment-cfd44967c-dtzvg:/data/db1# cd /tmp/db2
root@mongo-deployment-cfd44967c-dtzvg:/tmp/db2# ls
lost+found
root@mongo-deployment-cfd44967c-dtzvg:/tmp/db2# 

```

This is static PVC. In reality, dev will give request for random no, where this method will not work. Suppose if we now request for 20 GB vol, we will see that it is automatically assigned and bounded

```
echo 'apiVersion: v1
kind: PersistentVolumeClaim 
metadata:
  name: task-pv-claim6
spec: 
  storageClassName: gp2 
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi' | kubectl apply -f -
persistentvolumeclaim/task-pv-claim6 created

```

```
ubuntu@ip-172-31-25-119:~$ kubectl get pv
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE
aws-pv1   2Gi        RWO            Delete           Bound    default/task-pv-claim1   gp2                     61m
aws-pv2   4Gi        RWO            Delete           Bound    default/task-pv-claim2   gp2                     61m
aws-pv3   6Gi        RWO            Delete           Bound    default/task-pv-claim3   gp2                     61m
aws-pv4   8Gi        RWO            Delete           Bound    default/task-pv-claim4   gp2                     61m
aws-pv5   10Gi       RWO            Delete           Bound    default/task-pv-claim5   gp2                     61m
```

kops helps us in dynamically provisioning even if we dont have PV
```
ubuntu@ip-172-31-25-119:~$ kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
task-pv-claim1   Bound    aws-pv1                                    2Gi        RWO            gp2            43m
task-pv-claim2   Bound    aws-pv2                                    4Gi        RWO            gp2            32m
task-pv-claim3   Bound    aws-pv3                                    6Gi        RWO            gp2            32m
task-pv-claim4   Bound    aws-pv4                                    8Gi        RWO            gp2            32m
task-pv-claim5   Bound    aws-pv5                                    10Gi       RWO            gp2            32m
task-pv-claim6   Bound    pvc-e7ddb70c-6cd9-4c79-98a2-1427f59726c3   20Gi       RWO            gp2            7s
ubuntu@ip-172-31-25-119:~$ 

```

```
kubectl get storageclasses.storage.k8s.io
NAME                      PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
default                   kubernetes.io/aws-ebs   Delete          Immediate              false                  177m
gp2                       kubernetes.io/aws-ebs   Delete          Immediate              false                  177m
kops-csi-1-21 (default)   ebs.csi.aws.com         Delete          WaitForFirstConsumer   true                   177m
kops-ssd-1-17             kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   true                   177m
```

Now if we delete this gp2, anyone else would not be able to create any PVC

```
kubectl delete storageclasses.storage.k8s.io gp2
storageclass.storage.k8s.io "default" deleted

```
```
kubectl get storageclasses.storage.k8s.io
NAME                      PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
kops-csi-1-21 (default)   ebs.csi.aws.com         Delete          WaitForFirstConsumer   true                   4h8m
kops-ssd-1-17             kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   true                   4h8m
ubuntu@ip-172-31-25-119:~$ 

```

Now if you request for 25Gb of vol, it will reamin in pending state


Next we will be implementing storage class. These are necessary when we dont want developers to use any volume type, as it would increase cost. Instead we would create 2 storage classes, which will have volume type as io1 and gp2, and then developer can dynamically use these two only