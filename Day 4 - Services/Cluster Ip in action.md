
```
`kubectl cluster-info`
Kubernetes control plane is running at https://api.cloudadhanik.xyz
CoreDNS is running at https://api.cloudadhanik.xyz/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

```

## Creating a Deployment

kubectl create deployment app1 --image kiran2361993/loadbalancerimage:v1 --replicas 3 --dry-run -o yaml

echo 'yaml ' | kubectl apply -f -

```
 kubectl get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE   IP             NODE                  NOMINATED NODE   READINESS GATES
app1-5dbf9f747-dg2gw   1/1     Running   0          45s   100.96.2.101   i-0b0e8d0357636fd71   <none>           <none>
app1-5dbf9f747-mk4wb   1/1     Running   0          45s   100.96.2.111   i-0b0e8d0357636fd71   <none>           <none>
app1-5dbf9f747-zqwch   1/1     Running   0          45s   100.96.1.17    i-0628f261c8b8848d8   <none>           <none>

```

## Expose the above app to clusterIP

kubectl expose deployment app1 --port 80 --target-port 80 --type ClusterIP

```
kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
app1         ClusterIP   100.67.105.216   <none>        80/TCP    7s
kubernetes   ClusterIP   100.64.0.1       <none>        443/TCP   32m
```

Now if we try to access the app from here, it will not work
```
curl https://app1
curl: (6) Could not resolve host: app1
```

This is becasue we are working from management server, which is outside the cluster, and clusterIP works only inside the cluster.

## Installing a troubleshooting image

Since our containers dont have any packages, we will run a troubleshooting image.

kubectl run troubleshooting --image kiran2361993/troubleshootingtools:v1  

This tools container tools curl, wget, nslookup etc.

We will login to this container, try to access the pods

```
kubectl get pod
NAME                   READY   STATUS    RESTARTS   AGE
app1-5dbf9f747-dg2gw   1/1     Running   0          10m
app1-5dbf9f747-mk4wb   1/1     Running   0          10m
app1-5dbf9f747-zqwch   1/1     Running   0          10m
troubleshooting        1/1     Running   0          56s
```

kubectl exec -it troubleshooting -- bash
root@troubleshooting:/# nslookup app1
Server:		100.64.0.10
Address:	100.64.0.10#53

Name:	app1.default.svc.cluster.local
Address: 100.67.105.216


### How cluster ip achieves load balancer internally

while true
> do
> curl -sL http://app1 | grep -i 'IP Address' 
> sleep 1
> done

        <h1> Server IP Address is: 100.96.1.17 </h1>
        <h1> Server IP Address is: 100.96.2.101 </h1>
        <h1> Server IP Address is: 100.96.1.17 </h1>
        <h1> Server IP Address is: 100.96.2.111 </h1>
        <h1> Server IP Address is: 100.96.2.101 </h1>
        <h1> Server IP Address is: 100.96.1.17 </h1>


```
kubectl get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE   IP             NODE                  NOMINATED NODE   READINESS GATES
app1-5dbf9f747-dg2gw   1/1     Running   0          14m   100.96.2.101   i-0b0e8d0357636fd71   <none>           <none>
app1-5dbf9f747-mk4wb   1/1     Running   0          14m   100.96.2.111   i-0b0e8d0357636fd71   <none>           <none>
app1-5dbf9f747-zqwch   1/1     Running   0          14m   100.96.1.17    i-0628f261c8b8848d8   <none>           <none>
troubleshooting        1/1     Running   0          5m    100.96.2.8     i-0b0e8d0357636fd71   <none>           <none>
ubuntu@ip-172-31-85-130:~$ 

```

We can see that Cluster IP is load balancing the traffic across all 3 pod's IP. We can see this in describe svc also in endpoints.

```
kubectl describe svc app1
Name:                     app1
Namespace:                default
Labels:                   app=app1
Annotations:              <none>
Selector:                 app=app1
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       100.67.105.216
IPs:                      100.67.105.216
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:                100.96.2.101:80,100.96.1.17:80,100.96.2.111:80
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>

```

Later we delete the svc, and will see NodePort in action

`kubectl delete svc app1`
service "app1" deleted

`kubectl delete deployment app1`