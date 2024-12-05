
We need to create a PVC to claim a volume for our pods. Suppose we need 2 gb of PV for our pod. We will create a PVC for same.

```

ubuntu@ip-172-31-25-119:~$ echo 'apiVersion: v1 
kind: PersistentVolumeClaim 
metadata:
  name: task-pv-claim1 
spec: 
  storageClassName: gp2 
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi' | kubectl apply -f -
persistentvolumeclaim/task-pv-claim1 created

```
Once the PVC is created we can see that the PV is now Bound to our pVC.
```
ubuntu@ip-172-31-25-119:~$ kubectl get pvc
NAME             STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
task-pv-claim1   Bound    aws-pv1   2Gi        RWO            gp2            5s
ubuntu@ip-172-31-25-119:~$ kubectl get pv
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                    STORAGECLASS   REASON   AGE
aws-pv1   2Gi        RWO            Delete           Bound       default/task-pv-claim1   gp2                     17m
aws-pv2   4Gi        RWO            Delete           Available                            gp2                     17m
aws-pv3   6Gi        RWO            Delete           Available                            gp2                     17m
aws-pv4   8Gi        RWO            Delete           Available                            gp2                     17m
aws-pv5   10Gi       RWO            Delete           Available                            gp2                     17m
ubuntu@ip-172-31-25-119:~$ 

```
We will do the bound each of the PV we have created.

```
persistentvolumeclaim/task-pv-claim2 created
persistentvolumeclaim/task-pv-claim3 created
persistentvolumeclaim/task-pv-claim4 created
persistentvolumeclaim/task-pv-claim5 created
```

Now all PV are bounded to respective PVC 

```
kubectl get pv
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE
aws-pv1   2Gi        RWO            Delete           Bound    default/task-pv-claim1   gp2                     28m
aws-pv2   4Gi        RWO            Delete           Bound    default/task-pv-claim2   gp2                     28m
aws-pv3   6Gi        RWO            Delete           Bound    default/task-pv-claim3   gp2                     28m
aws-pv4   8Gi        RWO            Delete           Bound    default/task-pv-claim4   gp2                     28m
aws-pv5   10Gi       RWO            Delete           Bound    default/task-pv-claim5   gp2                     28m
```