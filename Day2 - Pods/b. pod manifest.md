
We will create a ns first

    `kubectl create ns alpha`

# Create yaml manifest

`kubectl run alpha1 -n alpha --image nginx:latest --dry-run -o yaml`

If you run kubectl api-resources, it will show you all the resources where you can deploy in your kB cluster. We have two type of ns, one is inside your KB cluster, other is outside your KB cluster (marked as true and false)

`kubectl api-resources --namespaced=true`

will show us all the resources that we can deploy in our KB cluster. From above command, you can see we have pod with APIVersion v1, hence to create pods, we make use of parameter `apiVersion:v1` . 

Similarly for deployments, daemonset, we have apps/v1.

# How to write a pod manifest

`kubectl explain pod` gives you all the default parameters that are inside a pod.yaml. If you want to understand a specific parameter, you can give

`kubectl explain pod.metadata`

# How to deploy the pod manifest

Either you can vi, and paste your yaml config, or you can do 

```
echo'<content fof yaml>' | kubectl apply -f -
kubectl get pods -n alpha
```

to switch btw ns easily, we can make use of kubens

## How to separate two pod yaml files inside one yaml file only

Use --- to separate two yaml manifiest inside one yaml configuration file.

For eg

apiVersion: v1
<POD manifest>


---

apiVersion: v1
<POD manifest>

---

apiVersion: v1
<POD manifest>


# How to connect to a app running inside a pod apart from services?

We can connect to pod without using services, This can be done via kube forwarding. In docker it was port forwarding. 


# Exposing POD via service

ku expose pod alpha1 --port 8000 --target-port-80 --type NodePort
ku get svc

This will expose your application on a specific port. Now you can copy any of worker node DNS, and try to access it on <dns:port>

Note - Before accessing, you should add that port in your inbound rules in S.G and allow traffic on it.


## How endpoints is updated in SVC?

if you delete a pod, the svc is not deleted. But if you create a pod with same label as svc, that pod IP is automatically assigned the service as endpoint, enabling communication to  that pod.

