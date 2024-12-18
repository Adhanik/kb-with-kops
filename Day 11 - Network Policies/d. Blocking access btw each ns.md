

## Blocking access btw each ns 

We will implement network policies in such a way that pods in prod ns will not be able to communicate to pods in Dev and QA ns.

Refer d1.yaml. We will block both Ingress and Egress traffic prod, qa, and dev ns. This way pods from other ns will not be able to communicate with diff ns.

Once you have applied the yaml, you will see network policies have been created.

```
networkpolicy.networking.k8s.io/deny-all-traffic-to-and-from-prod created
networkpolicy.networking.k8s.io/deny-all-traffic-to-and-from-dev created
networkpolicy.networking.k8s.io/deny-all-traffic-to-and-from-qa created
```

## Can pods in same ns communicate with each other?

As we can see pod in same ns, prod1 is also not able to communicate with prod2 in same ns
```
kubectl get pods -o wide -n prod
NAME    READY   STATUS    RESTARTS   AGE    IP                NODE                  NOMINATED NODE   READINESS GATES
prod1   1/1     Running   0          153m   100.115.162.194   i-0f3b21bd0da060378   <none>           <none>
prod2   1/1     Running   0          153m   100.115.162.195   i-0f3b21bd0da060378   <none>           <none>
```

ping fails

```

ubuntu@ip-172-31-20-104:~$ kubectl exec -it prod1 -n prod -- bash
root@prod1:/# ping 100.115.162.195
PING 100.115.162.195 (100.115.162.195) 56(84) bytes of data.
^C
--- 100.115.162.195 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 4075ms

```

## Testing traffic from pod in one ns to pod in diff ns

```

kubectl exec -it  prod1 -n prod -- ping -c 3  100.110.204.67 \
&& kubectl exec -it  prod2 -n prod -- ping -c 3  100.97.182.4 \
&& kubectl exec -it  prod1 -n prod -- ping -c 3   100.115.162.196     \
&& kubectl exec -it  prod2 -n prod -- ping -c 3   100.110.204.68

kubectl exec -it  dev1 -n dev -- ping -c 3    100.115.162.194 \
&& kubectl exec -it  dev2 -n dev -- ping -c 3  100.115.162.195 \
&& kubectl exec -it  dev1 -n dev -- ping -c 3   100.115.162.196    \
&& kubectl exec -it  dev2 -n dev -- ping -c 3 100.110.204.68

kubectl exec -it  qa1 -n qa -- ping -c 3     100.115.162.194  \
&& kubectl exec -it  qa2 -n qa -- ping -c 3   100.115.162.195  \
&& kubectl exec -it  qa1 -n qa -- ping -c 3  100.110.204.67 \
&& kubectl exec -it  qa2 -n qa -- ping -c 3   100.97.182.4

```

### O/P

--- 100.110.204.67 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2026ms