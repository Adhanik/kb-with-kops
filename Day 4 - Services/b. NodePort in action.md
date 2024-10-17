
We will create a deployment

`kubectl create deployment app1 --image kiran2361993/kubegame:v2 --replicas 3 --dry-run -o yaml`

```
kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
app1-6cc4dcbd94-92rmt   1/1     Running   0          15s
app1-6cc4dcbd94-b7m2h   1/1     Running   0          15s
app1-6cc4dcbd94-qpxsg   1/1     Running   0          15s
troubleshooting         1/1     Running   0          14m
```

## Exposing deployment using NodePort

Now we will expose our deployment using NODEPORT

`kubectl expose deployment app1 --port 80 --target-port 80 --type NodePort`

service/app1 exposed

```
kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
app1         NodePort    100.64.174.1   <none>        80:30694/TCP   7s
kubernetes   ClusterIP   100.64.0.1     <none>        443/TCP        54m
ubuntu@ip-172-31-85-130:~$ 
```

So our deployment app1 has been exposed on port 30694. We will add this in the inbound rules our worker nodes. allow traffic from anywhere. copy publicip:30694 , and our app is accessible.

We do a proper dns name for prod use cases. We will delete node port svc, and create loadbalancer one next.