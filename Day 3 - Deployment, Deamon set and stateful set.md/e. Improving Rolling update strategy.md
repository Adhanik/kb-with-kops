
# Previously what happened ?

Last time we saw that we had maxSurge: 100% which allowed Kubernetes to create up to 6 additional v2 pods (since 100% of the current replica count of 6 means 6 new pods can be created). At this point, 12 pods (6 v1 and 6 v2) are running simultaneously:

6 v1 pods (old version)
6 v2 pods (new version)

As soon as some v2 pods become ready (in this case, likely all 6 new pods), Kubernetes begins terminating v1 pods, but it is limited by the maxUnavailable setting.

The default maxUnavailable of 25% means that up to 2 v1 pods can be taken down at a time.
Therefore, 2 of the v1 pods are terminated after some of the new v2 pods are up and running.

After the first 2 v1 pods are terminated, Kubernetes continues replacing the rest of the v1 pods:

Kubernetes terminates the remaining 4 v1 pods in batches of 2 (due to maxUnavailable: 2), with v2 pods already available to take over.
This process continues until all 6 v1 pods are replaced by v2 pods, maintaining at least 4 pods (since maxUnavailable allows only 2 to be unavailable at any time).

Final State:
Once the rolling update is complete, you will have 6 v2 pods running, and all v1 pods will have been terminated. Here's the final pod state:

6 v2 pods (new version)
0 v1 pods (old version)

# Improving 

We dont want a downtime in real time for even a second. We will slowly update, that is once first pod is updated to v2, v1 should be deleted then after 10 sec. 

For each and every 10 sec, KB will create a new pod and delete the older one.

`minreadySeconds: 10`
maxSurge: 1 - for every 10 sec, 1 is created, 
maxUnavailable: 0  - every time 6 should be up acc to replica.


Now we can see, it slowly creates a new container each 10 sec, and terminates as well.
```
kubectl get pods -w
NAME                        READY   STATUS        RESTARTS   AGE
testpod1-6c458f74c7-6b82d   2/2     Terminating   0          76s
testpod1-6c458f74c7-89kgn   2/2     Running       0          76s
testpod1-6c458f74c7-9mgzn   2/2     Running       0          76s
testpod1-6c458f74c7-kz6vr   2/2     Running       0          76s
testpod1-6c458f74c7-p8sdh   2/2     Running       0          76s
testpod1-6c458f74c7-twsfw   2/2     Running       0          76s
testpod1-7f579df4d4-4h6zk   2/2     Running       0          8s
testpod1-7f579df4d4-p4rsr   2/2     Running       0          19s
testpod1-6c458f74c7-p8sdh   2/2     Terminating   0          80s
testpod1-7f579df4d4-sznfn   0/2     Pending       0          0s
testpod1-7f579df4d4-sznfn   0/2     Pending       0          0s
testpod1-7f579df4d4-sznfn   0/2     ContainerCreating   0          0s
testpod1-7f579df4d4-sznfn   2/2     Running             0          1s

```