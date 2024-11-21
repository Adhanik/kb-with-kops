

## Practical

We will be exposing nginx on port 9999, and use the config map to store the port. It would be 9999

Eg, if this is how port to host communication looks like, 8080:80, here 80 is our container port, and 8080 is the host port

Default port for nginx is 80

With the help of configMaps, we will set our port to 9999 or anything of our own.


### Create a default conf file for nginx

Refer default.conf

### Create Config map

`kubectl create configmap default.conf --from-file=default.conf`

```
kubectl create configmap default.conf --from-file=default.conf
configmap/default.conf created
ubuntu@ip-172-31-25-219:~/configmaps$ kubectl get configmaps
NAME               DATA   AGE
default.conf       1      103s
kube-root-ca.crt   1      108m

```

If you do describe config map, you will see the port on which nginx is exposed.

```
kubectl describe cm default.conf 
Name:         default.conf
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
default.conf:
----
server {
    listen 9999;
    server_name localhost;
}
BinaryData
====

Events:  <none>

```
### Deployment

Next we will create a deployment with nginx:latest as contaienr image and 3 replicas. The app name would be newnginx

`kubectl create deployment newnginx --image=nginx:latest --replicas=3 --dry-run=client -o yaml`


In deployment.yaml, you can see that we are passing contianer port 9999, which we have kept in default.conf and by default the port for nginx is 80

### Exposing the service
The correct syntax for exposing the deployment as a NodePort service is as follows:

`kubectl expose deployment newnginx --port=80 --target-port=9999 --type=NodePort`

```

 kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
newnginx-fdfd6f9b5-2vwjw   1/1     Running   0          52m
newnginx-fdfd6f9b5-4t68l   1/1     Running   0          52m
newnginx-fdfd6f9b5-ff5k6   1/1     Running   0          52m

```

##### Explanation:

--port=80: This specifies the port that the service will expose.
--target-port=9999: This specifies the port on the container that the service will forward traffic to. If your NGINX container is listening on port 9999, this is the correct setting.
--type=NodePort: This specifies that the service type should be NodePort, which exposes the service on a port on each node in the cluster.

##### Example:

If you want the NGINX deployment to listen on port 9999 inside the container but expose it externally via port 80, this command will create a service with type NodePort.

Once executed, you can access the NGINX service via the external IP of any node in the cluster and the assigned node port.

Additional Notes:
You can check the assigned NodePort by running:
kubectl get service newnginx
The PORT(S) column will show you the NodePort assigned to your service, something like 80:31000/TCP, where 31000 is the NodePort.

```
kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   100.64.0.1     <none>        443/TCP        63m
newnginx     NodePort    100.68.50.36   <none>        80:31722/TCP   4s

```

We will open this port in our S.G Inbound rules for control plane (master node), and then we can see that nginx webpage is accessible.

