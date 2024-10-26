
We will create a deployment - 

`kubectl create deployment app1 --image kiran2361993/kubegame:v2 --replicas 3 --dry-run -o yaml`

We will copy the content of this file, and in visual studio code, first add readiness probe, then add a liveness probe, and then implement both together.

We will first define readiness probe which will check if container is ready to accept traffic or not. httpget is the method via which we configure this probe.

After creating deployment using deployment.yaml

```
kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
app1-db59b695b-gdzv6   1/1     Running   0          13s
app1-db59b695b-gmmbf   1/1     Running   0          13s
app1-db59b695b-zd28t   1/1     Running   0          13s

```
Open another tab to see functioning of how readiness probe works

We will watch our kubectl pods

```
watch kubectl get pods

Every 2.0s: kubectl get pods                                                          ip-172-31-19-48: Sat Oct 26 12:10:02 2024

NAME                   READY   STATUS    RESTARTS   AGE
app1-db59b695b-gdzv6   1/1     Running   0          3m52s
app1-db59b695b-gmmbf   1/1     Running   0          3m52s
app1-db59b695b-zd28t   1/1     Running   0          3m52s

```

### Changes

We will login to one of the containers, and delete index.html, which will result in Readniess probe health check failing, and hence continaer would be marked as not ready to serve traffic

`kubectl exec -it app1-db59b695b-gdzv6 -- bash`

We will remove index.html and see what happens to pods
```
root@app1-db59b695b-gdzv6:/# cd /var/www/html
root@app1-db59b695b-gdzv6:/var/www/html# ls
index.html  index.nginx-debian.html
root@app1-db59b695b-gdzv6:/var/www/html# rm -rf index*
```

#### O/P

We see pod goes down, and no restart happens. It remains in 0/1 status

```
watch kubectl get pods

Every 2.0s: kubectl get pods                                                          ip-172-31-19-48: Sat Oct 26 12:13:38 2024

NAME                   READY   STATUS    RESTARTS   AGE
app1-db59b695b-gdzv6   0/1     Running   0          7m28s
app1-db59b695b-gmmbf   1/1     Running   0          7m28s
app1-db59b695b-zd28t   1/1     Running   0          7m28s

```

So for readiness probe, we see it does not serve traffic to that pod and marks it as down. in describe pod, evnet section , we see error 

Warning  Unhealthy  28s (x22 over 3m28s)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 404



