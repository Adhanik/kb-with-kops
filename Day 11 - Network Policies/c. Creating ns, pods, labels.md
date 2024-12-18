
# Create 3 ns

We will be creating 3 ns - dev, qa and prod.

- `kubectlbectl create ns dev`
- `kubectlbectl create ns prod`
- `kubectlbectl create ns qa`

## Add labels to ns


Next we will be adding lables to our 3 ns

- `kubectlbectl label ns prod nsp=prod`
- `kubectlbectl label ns dev nsp=dev`
- `kubectlbectl label ns qa nsp=qa`

 What is this nsp argument ??

Next, if you run `kubectlbectl get ns --show-labels`

```
 kubectlbectl get ns --show-labels
NAME              STATUS   AGE   LABELS

dev               Active   57s   kubectlbernetes.io/metadata.name=dev,nsp=dev
prod              Active   53s   kubectlbernetes.io/metadata.name=prod,nsp=prod
qa                Active   49s   kubectlbernetes.io/metadata.name=qa,nsp=qa

```
## Deploying 2 pods on each ns

### prod

kubectlbectl run prod1 --image=kiran2361993/troubleshootingtools:v1 -n prod -l ns=prod
kubectlbectl run prod2 --image=kiran2361993/troubleshootingtools:v1 -n prod -l ns=prod

 Does -l stand for label here?


### dev

kubectlbectl run dev1 --image=kiran2361993/troubleshootingtools:v1 -n dev -l ns=dev
kubectlbectl run dev2 --image=kiran2361993/troubleshootingtools:v1 -n dev -l ns=dev

### QA

kubectlbectl run qa1 --image=kiran2361993/troubleshootingtools:v1 -n qa -l ns=qa
kubectlbectl run qa2 --image=kiran2361993/troubleshootingtools:v1 -n qa -l ns=qa

## Check all pods 

```
kubectlbectl get pods -o wide -n prod && kubectlbectl get pods -o wide -n dev && kubectlbectl get pods -o wide -n qa
NAME    READY   STATUS    RESTARTS   AGE     IP                NODE                  NOMINATED NODE   READINESS GATES
prod1   1/1     Running   0          2m28s   100.115.162.194   i-0f3b21bd0da060378   <none>           <none>
prod2   1/1     Running   0          2m28s   100.115.162.195   i-0f3b21bd0da060378   <none>           <none>
NAME   READY   STATUS    RESTARTS   AGE     IP               NODE                  NOMINATED NODE   READINESS GATES
dev1   1/1     Running   0          2m13s   100.110.204.67   i-0c45f29f172d12bec   <none>           <none>
dev2   1/1     Running   0          2m12s   100.97.182.4     i-06f3226cc8ea7faff   <none>           <none>
NAME   READY   STATUS    RESTARTS   AGE    IP                NODE                  NOMINATED NODE   READINESS GATES
qa1    1/1     Running   0          104s   100.115.162.196   i-0f3b21bd0da060378   <none>           <none>
qa2    1/1     Running   0          104s   100.110.204.68    i-0c45f29f172d12bec   <none>           <none>
ubuntu@ip-172-31-20-104:~$ 

```

Without header

kubectlbectl get pods -o wide -n prod --no-headers && kubectlbectl get pods -o wide -n dev --no-headers && kubectlbectl get pods -o wide -n qa --no-headers

```
kubectlbectl get pods -o wide -n prod --no-headers && kubectlbectl get pods -o wide -n dev --no-headers && kubectlbectl get pods -o wide -n qa --no-headers
prod1   1/1   Running   0     8m31s   100.115.162.194   i-0f3b21bd0da060378   <none>   <none>
prod2   1/1   Running   0     8m31s   100.115.162.195   i-0f3b21bd0da060378   <none>   <none>
dev1   1/1   Running   0     8m16s   100.110.204.67   i-0c45f29f172d12bec   <none>   <none>
dev2   1/1   Running   0     8m15s   100.97.182.4     i-06f3226cc8ea7faff   <none>   <none>
qa1   1/1   Running   0     7m48s   100.115.162.196   i-0f3b21bd0da060378   <none>   <none>
qa2   1/1   Running   0     7m48s   100.110.204.68    i-0c45f29f172d12bec   <none>   <none>

```
### Creat alias for big command

alias allpods='kubectlbectl get pods -o wide -n prod --no-headers && kubectlbectl get pods -o wide -n dev --no-headers && kubectlbectl get pods -o wide -n qa --no-headers'

`source .bashrc`
env

```
allpods
prod1   1/1   Running   0     15m   100.115.162.194   i-0f3b21bd0da060378   <none>   <none>
prod2   1/1   Running   0     15m   100.115.162.195   i-0f3b21bd0da060378   <none>   <none>
dev1   1/1   Running   0     15m   100.110.204.67   i-0c45f29f172d12bec   <none>   <none>
dev2   1/1   Running   0     15m   100.97.182.4     i-06f3226cc8ea7faff   <none>   <none>
qa1   1/1   Running   0     15m   100.115.162.196   i-0f3b21bd0da060378   <none>   <none>
qa2   1/1   Running   0     15m   100.110.204.68    i-0c45f29f172d12bec   <none>   <none>

```

## Checking communication btw each and every pod

We will be sending 3 packets from prod1, dev1, qa1 pods to all both pods of diff ns. For eg, from prod ns, we will login to prod1 pod, and try to check communication to both pod in dev ns, and both pod in qa ns.


pod prod1 in prod ns, is tryig to ping 2 pods in dev ns and 2 pods in QA ns
```
kubectl exec -it  prod1 -n prod -- ping -c 3  100.110.204.67 \
&& kubectl exec -it  prod2 -n prod -- ping -c 3  100.97.182.4 \
&& kubectl exec -it  prod1 -n prod -- ping -c 3   100.115.162.196     \
&& kubectl exec -it  prod2 -n prod -- ping -c 3   100.110.204.68
```

```
kubectl exec -it  dev1 -n dev -- ping -c 3    100.115.162.194 \
&& kubectl exec -it  dev2 -n dev -- ping -c 3  100.115.162.195 \
&& kubectl exec -it  dev1 -n dev -- ping -c 3   100.115.162.196    \
&& kubectl exec -it  dev2 -n dev -- ping -c 3 100.110.204.68
```

```
kubectl exec -it  qa1 -n qa -- ping -c 3     100.115.162.194  \
&& kubectl exec -it  qa2 -n qa -- ping -c 3   100.115.162.195  \
&& kubectl exec -it  qa1 -n qa -- ping -c 3  100.110.204.67 \
&& kubectl exec -it  qa2 -n qa -- ping -c 3   100.97.182.4
```

#### o/p

We can see that by default, inter communication btw pods in each ns, and communication btw pods in diff ns is happening.


