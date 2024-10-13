
We will create a ns first

    `kubectl create ns alpha`

# Create yaml manifest

`kubectl run alpha1 -n alpha --image nginx:latest --dry-run -o yaml`

We have saved above as pod.yaml

To run, we do echo'<content fof yaml>' | kubectl apply -f -

```
ku get pods -n alpha
NAME     READY   STATUS    RESTARTS   AGE
alpha1   1/1     Running   0          42s

```

# How to deploy the pod manifest

Either you can vi, and paste your yaml config, or you can do 

```
echo'<content fof yaml>' | kubectl apply -f -
kubectl get pods -n alpha
```
Once our pod is up and running, we can see on which worker node it is assigned.
```

ku get pods -o wide -n alpha
NAME     READY   STATUS    RESTARTS   AGE     IP             NODE                  NOMINATED NODE   READINESS GATES
alpha1   1/1     Running   0          5m52s   100.96.2.194   i-0c86e68dd92f450ce   <none>           <none>


ku get nodes -o wide
NAME                  STATUS   ROLES           AGE   VERSION    INTERNAL-IP     EXTERNAL-IP     OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
i-0401ab05e63feb772   Ready    node            15m   v1.28.11   172.20.50.122   3.231.222.190   Ubuntu 22.04.4 LTS   6.5.0-1020-aws   containerd://1.7.16
i-07d85eb02719ceecd   Ready    control-plane   18m   v1.28.11   172.20.58.246   44.195.78.157   Ubuntu 22.04.4 LTS   6.5.0-1020-aws   containerd://1.7.16
i-0c86e68dd92f450ce   Ready    node            15m   v1.28.11   172.20.176.28   52.91.188.78    Ubuntu 22.04.4 LTS   6.5.0-1020-aws   containerd://1.7.16
ubuntu@ip-172-31-94-171:~$ 

```

You may ask why pod is running on specific i-0c86e68dd92f450ce  node when we have two nodes, this is explained in Why pod run on this node?


## How to separate two pod yaml files inside one yaml file only

Use --- to separate two yaml manifiest inside one yaml configuration file.

For eg

apiVersion: v1
<POD manifest>


Using this 3 dash ---

apiVersion: v1
<POD manifest>

---

apiVersion: v1
<POD manifest>


# How to connect to a app running inside a pod apart from services?

We can connect to pod without using services, This can be done via kube forwarding. In docker it was port forwarding. 


# Exposing POD via service

`ku expose pod alpha1 --port=8000 --target-port=80 --type=NodePort -n alpha`

```
ku get svc -n alpha
NAME     TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
alpha1   NodePort   100.67.152.172   <none>        8000:31547/TCP   35s

```


This will expose your application on a specific port. Now you can copy any of worker node DNS, and try to access it on <ec2-dns:port>

Note - Before accessing, you should add that port in your inbound rules in S.G and allow traffic on it.


## How endpoints is updated in SVC?


A **Service (svc)** is responsible for providing a stable network endpoint to access one or more Pods. 

When we run:
   ```bash 
   kubectl expose pod alpha1 --port=8000 --target-port=80 --type=NodePort -n <ns>
   ```
   Kubernetes creates a **Service** that exposes the `alpha1` Pod at `NodePort`. Behind the scenes, the Service will look for Pods that match a **label selector** (if you haven’t explicitly provided a label selector, it defaults to the Pod's labels).

This is our POD IP. You can see labels in svc.yaml, which will be similar to labels in pod.yaml. Kubernetes uses **labels** and **selectors** to associate a Service with the right Pods.
```
ku get pods -o wide -n alpha
NAME     READY   STATUS    RESTARTS   AGE     IP             NODE                  NOMINATED NODE   READINESS GATES
alpha1   1/1     Running   0          5m52s   100.96.2.194   i-0c86e68dd92f450ce   <none>           <none>

```
If we do describe our svc - `ku describe svc -n alpha`, we can see the endpoint pointing to same. 

Endpoints:                100.96.2.194:80

If you delete a pod, the svc is not deleted. But if you create a pod with same label as svc, that pod IP is automatically assigned the service as endpoint, enabling communication to  that pod.

## Checking resources

If you run kubectl api-resources, it will show you all the resources where you can deploy in your kB cluster. We have two type of ns, one is inside your KB cluster, other is outside your KB cluster (marked as true and false)

`kubectl api-resources --namespaced=true`

will show us all the resources that we can deploy in our KB cluster. From above command, you can see we have pod with APIVersion v1, hence to create pods, we make use of parameter `apiVersion:v1` . 

Similarly for deployments, daemonset, we have apps/v1.

# How to write a pod manifest

`kubectl explain pod` gives you all the default parameters that are inside a pod.yaml. If you want to understand a specific parameter, you can give

`kubectl explain pod.metadata`