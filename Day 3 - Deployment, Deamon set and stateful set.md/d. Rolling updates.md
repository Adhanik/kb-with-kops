
Lets delete the deployment that we have created.
```
kubectl get deployments
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
testpod1   6/6     6            6           76m

```
`kubectl delete deployments testpod1`
`kubectl delete depolyments.apps testpod1`

If we run - `kubectl explain deployment.spec.strategy`, we see a field for Rolling update. we will use this in our deployment.yam

FIELDS:
  rollingUpdate	<RollingUpdateDeployment>
    Rolling update config params. Present only if DeploymentStrategyType =
    RollingUpdate.

'kubectl explain deployment.spec.strategy.rollingUpdate`

We have  maxSurge and maxUnavailable

maxSurge	<IntOrString>

The maximum number of pods that can be scheduled above the desired number of
    pods. Value can be an absolute number (ex: 5) or a percentage of desired
    pods (ex: 10%). This can not be 0 if MaxUnavailable is 0. Absolute number is
    calculated from percentage by rounding up. Defaults to 25%. Example: when
    this is set to 30%, the new ReplicaSet can be scaled up immediately when the
    rolling update starts, such that the total number of old and new pods do not
    exceed 130% of desired pods. Once old pods have been killed, new ReplicaSet
    can be scaled up further, ensuring that total number of pods running at any
    time during the update is at most 130% of desired pods.

maxUnavailable	<IntOrString>
    The maximum number of pods that can be unavailable during the update. Value
    can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%).
    Absolute number is calculated from percentage by rounding down. This can not
    be 0 if MaxSurge is 0. Defaults to 25%. Example: when this is set to 30%,
    the old ReplicaSet can be scaled down to 70% of desired pods immediately
    when the rolling update starts. Once new pods are ready, old ReplicaSet can
    be scaled down further, followed by scaling up the new ReplicaSet, ensuring
    that the total number of pods available at all times during the update is at
    least 70% of desired pods.

We will run with maxsurge 100%, which means since we have 6 pods running across 2 worker nodes, it will create 6 extra pods, and will max take 3 down after creating new ones.

`kubectl edit deployment testpod1`

O/P
```
kubectl get pods
NAME                        READY   STATUS        RESTARTS   AGE
testpod1-6c458f74c7-5p459   2/2     Terminating   0          4m7s
testpod1-6c458f74c7-k6lnp   2/2     Terminating   0          4m7s
testpod1-6c458f74c7-kpx55   2/2     Terminating   0          4m7s
testpod1-6c458f74c7-mg7z4   2/2     Terminating   0          4m7s
testpod1-6c458f74c7-mrzpc   2/2     Terminating   0          4m7s
testpod1-6c458f74c7-s69v6   2/2     Terminating   0          4m7s
testpod1-7f579df4d4-6lzm9   2/2     Running       0          7s
testpod1-7f579df4d4-6qpkd   2/2     Running       0          7s
testpod1-7f579df4d4-7g5dd   2/2     Running       0          7s
testpod1-7f579df4d4-9bpfl   2/2     Running       0          7s
testpod1-7f579df4d4-tfn79   2/2     Running       0          7s
testpod1-7f579df4d4-tw8h2   2/2     Running       0          7s

```

### What happened in backend?

The behavior you're experiencing is likely due to how Kubernetes interprets the `maxSurge` and `maxUnavailable` values in the rolling update strategy.

You mentioned that you set `maxSurge: 100%`, but you **did not specify a value** for `maxUnavailable`. In this case, Kubernetes is applying the **default value** for `maxUnavailable`, which is `25%` of the replicas. This could explain the behavior where pods are being terminated and replaced more aggressively than expected.

Here’s a breakdown of what might have happened:

### What You Expected:
- You expected Kubernetes to create **6 extra pods** (because `maxSurge: 100%`), and then gradually take down old pods by a maximum of 3 at a time (as per `maxUnavailable` defaults).

### What Happened:
1. **maxSurge: 100%**: This indeed means that Kubernetes can create **up to 100% more pods** than the current replica count. With 6 existing pods, Kubernetes is allowed to create **6 additional pods** (bringing the total to 12 temporarily).

2. **maxUnavailable Defaults**: Since you didn’t specify `maxUnavailable`, Kubernetes likely applied the default value, which is `25%` of the total replicas. For 6 replicas, `25%` translates to **1.5 pods**, which gets rounded up to 2 pods. This means Kubernetes is allowed to take **down up to 2 pods** during the update at a time.

3. **Rolling Update Execution**:
   - Kubernetes starts by creating new `v2` pods (which it did).
   - After creating a few `v2` pods, it began **terminating the old `v1` pods** based on the `maxUnavailable` limit (which is 2 pods).
   - This process continued, resulting in the termination of all `v1` pods as the `v2` pods were spun up.

### Why It Seemed Like All Pods Were Terminated:
Even though the update was gradual, because the new `v2` pods were created quickly and the default `maxUnavailable` allowed Kubernetes to terminate up to 2 old `v1` pods at a time, it **appeared** as though all pods were being deleted and replaced at once.

This can happen quickly depending on your cluster capacity, node resources, and the speed at which new pods are scheduled.

### How to Achieve the Behavior You Expected:
To ensure the update behaves as you expected, you need to explicitly set `maxUnavailable` to a higher value. For example, setting it to `3` (50%) would mean that Kubernetes is allowed to take down up to 3 old pods at a time:

```yaml
spec:
  strategy:
    rollingUpdate: 
      maxSurge: 100%         # Create up to 6 extra pods (100% more than 6 replicas)
      maxUnavailable: 3      # Take down a maximum of 3 pods at a time
```

### Conclusion:
The reason for the rapid pod termination is the interplay between `maxSurge` (which allowed 100% additional pods) and the default value of `maxUnavailable` (which allowed terminating up to 2 pods at a time). Specifying a higher `maxUnavailable` will help achieve the desired behavior where more pods are kept running during the update process.