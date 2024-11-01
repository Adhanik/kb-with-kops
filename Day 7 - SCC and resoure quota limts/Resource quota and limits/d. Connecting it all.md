
# Creating ns

We will be creating a ns, with resource quotas defined in that ns, along with init and SCC - adapter containers. We would expose it on a port using service, and see all of that in action.


- Firstly we will create a ns. Thats what the first section of our yaml will consist of.

# Creating Resource quota for ns

- Next we will create Resource Quota for our ns. How much mem and cpu will our ns consume. 

# Creating limit range for containers

- Next we will create Limit Range for continaer. If quota is enabled in a namespace for compute resources like cpu and memory, users must specify requests or limits for those values; otherwise, the quota system may reject pod creation. Hint: Use the LimitRanger admission controller to force defaults for pods that make no compute resource requirements.

# Creating deployment.yaml

- Next we will create Deployment yaml. In Deployment.yaml, we have our init contianers defined

- The init containers are executed first before a pod is made ready to serve traffic. We have defined three tasks inside out init contianers, where it clones a github, looks for myservice, and writes a success text msg to status.txt.

- The status.txt is mounted on volume shared-vol

- Next we have defined containers. First we have defined a adapter container, which is accessible on port 80. We have applied resources limits on this container, as to to the max cpu and max memory it can consume.

- next we have defined a main container, exposed it on port 80, mounted it on common vol we have defined, and defined resource constraint for this container as well.

- at last we have defined our volume  at container level and used an empty dir for same

# Creating service

We have created 2 service, one for our adapter container, and the other for myservice for init containers


We got one error -

Error from server (BadRequest): error when creating "deployment.yaml": Deployment in version "v1" cannot be handled as a Deployment: json: cannot unmarshal object into Go struct field Container.spec.template.spec.containers.ports of type []v1.ContainerPort

This was due to missed - at line 85

          ports: 
          -  containerPort: 80 (hyphen needed)



# AFTER RESULT

```
kubectl get pods 
NAME                                          READY   STATUS    RESTARTS   AGE
adapter-container-deployment-b99b964f-jjgjl   2/2     Running   0          62s
```

```
ubuntu@ip-172-31-20-67:~$ kubectl describe ns development
Name:         development
Labels:       kubernetes.io/metadata.name=development
              name=development
Annotations:  <none>
Status:       Active

Resource Quotas
  Name:                   object-counts
  Resource                Used  Hard
  --------                ---   ---
  limits.cpu              0     2
  limits.memory           0     2Gi
  pods                    0     10
  replicationcontrollers  0     20
  requests.cpu            0     1
  requests.memory         0     1Gi
  resourcequotas          1     10
  services                0     5

Resource Limits
 Type       Resource  Min    Max    Default Request  Default Limit  Max Limit/Request Ratio
 ----       --------  ---    ---    ---------------  -------------  -----------------------
 Container  memory    100Mi  128Mi  128Mi            128Mi          -
 Container  cpu       100m   200m   200m             200m           -
ubuntu@ip-172-31-20-67:~$ 

```
```
 kubectl get deployments
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
adapter-container-deployment   1/1     1            1           3m40s
```
- We will increase the replicas 

` kubectl scale deployment adapter-container-deployment --replicas 6 `

- We can see that first init containers are being executed, tll then pod is not ready.

```
kubectl get pods
NAME                                          READY   STATUS            RESTARTS   AGE
adapter-container-deployment-b99b964f-5d2r2   0/2     Init:1/3          0          4s
adapter-container-deployment-b99b964f-jjgjl   2/2     Running           0          4m28s
adapter-container-deployment-b99b964f-ln8l4   0/2     Init:1/3          0          4s
adapter-container-deployment-b99b964f-mmqpz   0/2     Init:1/3          0          5s
adapter-container-deployment-b99b964f-sfgx2   0/2     PodInitializing   0          4s
adapter-container-deployment-b99b964f-tk6d4   0/2     PodInitializing   0          5s
```

It passes all after sometime

```
ubuntu@ip-172-31-20-67:~$ kubectl get pods
NAME                                          READY   STATUS    RESTARTS   AGE
adapter-container-deployment-b99b964f-5d2r2   2/2     Running   0          48s
adapter-container-deployment-b99b964f-jjgjl   2/2     Running   0          5m12s
adapter-container-deployment-b99b964f-ln8l4   2/2     Running   0          48s
adapter-container-deployment-b99b964f-mmqpz   2/2     Running   0          49s
adapter-container-deployment-b99b964f-sfgx2   2/2     Running   0          48s
adapter-container-deployment-b99b964f-tk6d4   2/2     Running   0          49s
```

- We will login to one of the pods

`kubectl exec -it adapter-container-deployment-b99b964f-5d2r2 -- sh`

We can see the resutls

```


/ # cd /html
/html # ls
index.html  status.txt
/html # cat index.html 
<h1>Fri Nov 1 10:21:56 UTC 2024</h1>

/html # cat status.txt 
Init-container tasks completed
/html # 


- Next we will check the svc on which our app is exposed via node port, add it to security group, and try to acces it from publicIP of EC2

```
 kubectl get svc
NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
adapter-container-service   NodePort    100.66.152.140   <none>        80:32124/TCP   11m
kubernetes                  ClusterIP   100.64.0.1       <none>        443/TCP        113m
myservice                   NodePort    100.70.240.86    <none>        80:32635/TCP   11m
```

We can see that it is writing timestamp on the public iP - http://44.193.220.240:32124/

