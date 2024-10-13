
When we deploy a deployment with help of daemon set, daemon set makes sure that it deploys each and every pod on each and every single node.

This is manily used for monitoring and logging purpose.


# Creating DaemonSet

- They are similar to deployments. Look at daemonset.yaml

- There will be no replicas mentioned in yaml

`kubectl apply -f daemonset.yaml`
```

kubectl get daemonset
NAME       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
testpod1   2         2         2       2            2           <none>          3m48s

```

```
kubectl get pods
NAME             READY   STATUS    RESTARTS   AGE
testpod1-ltlx9   2/2     Running   0          5s
testpod1-wtkqj   2/2     Running   0          5s
ubuntu@ip-172-31-94-171:~$ kubectl get pods -o wide
NAME             READY   STATUS    RESTARTS   AGE   IP             NODE                  NOMINATED NODE   READINESS GATES
testpod1-ltlx9   2/2     Running   0          13s   100.96.1.9     i-0401ab05e63feb772   <none>           <none>
testpod1-wtkqj   2/2     Running   0          13s   100.96.2.236   i-0c86e68dd92f450ce   <none>           <none>
ubuntu@ip-172-31-94-171:~$ 

```

As we can see, we have not mentioned any replicas, still we see that each pod is runnig on each worker nodes

# Diff in Deployment and Daemon set

When we deploy a deployment, we can see our pods running on both worker nodes
```
kubectl get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP             NODE                  NOMINATED NODE   READINESS GATES
testpod1-7f579df4d4-4h6zk   2/2     Running   0          70m   100.96.1.127   i-0401ab05e63feb772   <none>           <none>
testpod1-7f579df4d4-gkjvw   2/2     Running   0          70m   100.96.1.201   i-0401ab05e63feb772   <none>           <none>
testpod1-7f579df4d4-p4rsr   2/2     Running   0          71m   100.96.2.195   i-0c86e68dd92f450ce   <none>           <none>
testpod1-7f579df4d4-rq9hs   2/2     Running   0          70m   100.96.2.36    i-0c86e68dd92f450ce   <none>           <none>
testpod1-7f579df4d4-sznfn   2/2     Running   0          70m   100.96.2.100   i-0c86e68dd92f450ce   <none>           <none>
testpod1-7f579df4d4-w967t   2/2     Running   0          70m   100.96.1.207   i-0401ab05e63feb772   <none>           <none>
ubuntu@ip-172-31-94-171:~$ kubectl get nodes -o wide
NAME                  STATUS   ROLES           AGE    VERSION    INTERNAL-IP     EXTERNAL-IP     OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
i-0401ab05e63feb772   Ready    node            4h5m   v1.28.11   172.20.50.122   3.231.222.190   Ubuntu 22.04.4 LTS   6.5.0-1020-aws   containerd://1.7.16
i-07d85eb02719ceecd   Ready    control-plane   4h8m   v1.28.11   172.20.58.246   44.195.78.157   Ubuntu 22.04.4 LTS   6.5.0-1020-aws   containerd://1.7.16
i-0c86e68dd92f450ce   Ready    node            4h4m   v1.28.11   172.20.176.28   52.91.188.78    Ubuntu 22.04.4 LTS   6.5.0-1020-aws   containerd://1.7.16
ubuntu@ip-172-31-94-171:~$ kubectl get deployments
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
testpod1   6/6     6            6           72m

```

For deployment, we have more than 1 instances are running on each worker node. while for daemon set, without specifying any replicas, we will have exactly 1 pod on each worker node.