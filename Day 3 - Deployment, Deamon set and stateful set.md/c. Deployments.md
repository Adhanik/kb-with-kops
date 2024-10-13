

# Deployments

- High Availability & Scalability - One of the main reasons why Deployments are bing used is due to SCALABILITY. The replica set ensure that the specified no of pods are always up and running, ensuring H.A.

- Automation - Deployments help with automatically managing the updates, scaling, rollbacks etc.

- Self Healing - If any pod goes down or fails, it is automatically replaced/ restart failed containers.

- Load Balancing - Ensure network traffic is distributed evenly across multiple pods.


## Practical
 
### Prechecks

`alias ku = kubectl`
`ku get nodes -o wide`
`ku cluster-info`

### Deployment manifest

`kubectl create deployment testpod1 --image kiran2361993/kubegame:v2 --replicas 6 --dry-run -o yaml`

Paste it in testpod.yaml and run the file using kubectl apply -f deployment.yaml or echo command

```
kubectl apply -f deployment.yaml 
deployment.apps/testpod1 created
ubuntu@ip-172-31-94-171:~$ kubectl get pods 
NAME                       READY   STATUS    RESTARTS   AGE
testpod1-f65c8cd6d-6bfdv   2/2     Running   0          41s
testpod1-f65c8cd6d-c7db9   2/2     Running   0          41s
testpod1-f65c8cd6d-js249   2/2     Running   0          41s
testpod1-f65c8cd6d-nvlf2   2/2     Running   0          41s
testpod1-f65c8cd6d-thk86   2/2     Running   0          41s
testpod1-f65c8cd6d-w9p7b   2/2     Running   0          41s

```

### Adding Annotations

Anotations are very helpful, escepically where we have load balancers or ingress. For load balancers, we have NLB, and other is ALB. With help of annotation, we can select which L.B we want.

### Adding env variables

We will add env varialbes for our db, like name, url and port on which it is exposed

To check env varialbes, we can login to contianer, and run below
`k exec -it testpod1-f65c8cd6d-6bfdv -- bash`

Defaulted container "kubegame" out of: kubegame, mysqldb
root@testpod1-f65c8cd6d-6bfdv:/# env


# Expose the Application using svc

svc1 is our svc name which will be created. 
`kubectl expose deployment testpod1 --name svc1 --port 8000 --target-port 80 --type NodePort`

To expose DB running on 5000

`kubectl expose deployment testpod1 --name svc2 --port 5000 --target-port 5000 --type NodePort`

`kubectl get svc -o wide`
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE   SELECTOR
kubernetes   ClusterIP   100.64.0.1      <none>        443/TCP          68m   <none>
svc1         NodePort    100.70.92.3     <none>        8000:30877/TCP   86s   app=testpod1
svc2         NodePort    100.64.10.100   <none>        5000:31998/TCP   25s   app=testpod1


We will add these ports in our inbound traffic S.G for the worker nodes EC2, and then we can access our application.
