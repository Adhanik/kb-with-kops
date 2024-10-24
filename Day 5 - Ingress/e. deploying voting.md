

1. We will create voting.yaml in our managemnt cluster, and paste content of voting.yaml in this file
Then run `kubectl apply -f voting.yaml`

`kubectl apply -f voting.yaml`

```

service/redis created
deployment.apps/redis created
service/db created
deployment.apps/db created
persistentvolumeclaim/postgres-pv-claim created
service/result created
deployment.apps/result created
service/vote created
deployment.apps/vote created
service/worker created
deployment.apps/worker created

```

2. If we run `kubectl get pods`, we see error image pull

```
 kubectl get pods
NAME                      READY   STATUS         RESTARTS   AGE
db-679cdf9f79-6qp7x       1/1     Running        0          34s
redis-65fbbd8f94-wj5jt    1/1     Running        0          34s
result-7dd6d684c7-h6lsq   0/1     ErrImagePull   0          34s
vote-7c6fcf656d-cdtkk     0/1     ErrImagePull   0          34s
vote-7c6fcf656d-gcnk8     0/1     ErrImagePull   0          34s
worker-7b6cf87597-5pfrp   0/1     ErrImagePull   0          34s

```

3. We do describe and see below error 

 Error: ErrImagePull
  Warning  FailedToRetrieveImagePullSecret  7s (x6 over 64s)   kubelet            Unable to retrieve some image pull secrets (docker-pwd); attempting to pull the image may not succeed.

only DB image is working fine. This happens because ours is a private repo, and deployment dont have secrets to access the our private docker hub repo. so we need to pass 'docker-secrets' in our deployment.yaml as well.

Go to account - generate new token - give read, write and delete permission. Copy and paste the token below in docker-password= <token>

# Create a Secret by providing Docker credentials on the command line


kubectl create secret docker-registry docker-pwd \
--docker-server=docker.io --docker-username=NAME \
--docker-password=token \
--docker-email=workwithnik@gmail.com

so now we have two secrets, one for tls, and one for docker hub with name demo. We need to pass this in our voting.yaml

```
kubectl get secrets
NAME                TYPE                             DATA   AGE
docker-pwd          kubernetes.io/dockerconfigjson   1      4s
nginx-tls-default   kubernetes.io/tls                2      10m


```

Now we can see all our PODS are up and running

```
 kubectl get  pods
NAME                      READY   STATUS    RESTARTS   AGE
db-679cdf9f79-slsrc       1/1     Running   0          98s
redis-65fbbd8f94-fqvgd    1/1     Running   0          98s
result-7dd6d684c7-br7l6   1/1     Running   0          98s
vote-7c6fcf656d-dvtm4     1/1     Running   0          98s
vote-7c6fcf656d-hjgw5     1/1     Running   0          98s
worker-7b6cf87597-z9l6m   1/1     Running   0          98s

```

```
kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
db           ClusterIP   None             <none>        5432/TCP   6m10s
kubernetes   ClusterIP   100.64.0.1       <none>        443/TCP    35m
redis        ClusterIP   None             <none>        6379/TCP   6m10s
result       ClusterIP   100.66.43.69     <none>        80/TCP     6m10s
vote         ClusterIP   100.71.177.190   <none>        80/TCP     6m10s
worker       ClusterIP   None             <none>        <none>     6m10s
```