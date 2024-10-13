
Lets delete the deployment that we have created.
```
kubectl get deployments
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
testpod1   6/6     6            6           76m

```
`kubectl delete deployments testpod1`
`kubectl delete depolyments.apps testpod1`

If we run - `kubectl explain deployment.spec.strategy`, we see a field for Rolling update. we will use this in our deployment.yaml

FIELDS:
  rollingUpdate	<RollingUpdateDeployment>
    Rolling update config params. Present only if DeploymentStrategyType =
    RollingUpdate.
