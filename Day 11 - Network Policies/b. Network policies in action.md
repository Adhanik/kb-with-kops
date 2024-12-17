

## Create pods
We will deploy 2 pods, triumph1 and triumph2 with a troubleshooting image which consist of all debuggin tools.

`kubectl run triumph1 --image=kiran2361993/troubleshootingtools:v1 -n default`
`kubectl run triumph2 --image=kiran2361993/troubleshootingtools:v1 -n default`

```
kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
triumph1   1/1     Running   0          2m7s
triumph2   1/1     Running   0          108s

```
```
kubectl get pods -o wide
NAME       READY   STATUS    RESTARTS   AGE     IP               NODE                  NOMINATED NODE   READINESS GATES
triumph1   1/1     Running   0          4m6s    100.120.31.66    i-08c431c8b5cfbfc00   <none>           <none>
triumph2   1/1     Running   0          3m47s   100.111.25.130   i-0cc4b3b8593320307   <none>           <none>
```

## Try to access second pod from first pod

We will login to triumph1 and try to ping the ip of triumph2 from first pod

```
 kubectl exec -it triumph1 -- bash
root@triumph1:/# ping 100.111.25.130
PING 100.111.25.130 (100.111.25.130) 56(84) bytes of data.
64 bytes from 100.111.25.130: icmp_seq=1 ttl=62 time=0.816 ms
64 bytes from 100.111.25.130: icmp_seq=2 ttl=62 time=0.371 ms
```

We can see that by default both pods are able to communicate with each other when they are in same ns

```
kubectl exec -it triumph2 -- bash
root@triumph2:/# ping 100.120.31.66
PING 100.120.31.66 (100.120.31.66) 56(84) bytes of data.
64 bytes from 100.120.31.66: icmp_seq=1 ttl=62 time=0.469 ms
64 bytes from 100.120.31.66: icmp_seq=2 ttl=62 time=0.254 ms
64 bytes from 100.120.31.66: icmp_seq=3 ttl=62 time=0.280 ms
^C
--- 100.120.31.66 ping statistics ---

```


## Restricting communication btw triumph1 and triumph2

- We want to restrict any communication btw both the pods. For this we will need to define Network policy for both the pods, and then disable ingress and egress communinction for both the pods.

- It is imp to mention the ns in which your pods are running. if we are only mentioning the ns, then it will apply to all pods inside that ns. If you want to restrict a specific pod, then we can pass the pod name in matchLabels. 

- To block ingress traffic, we will mention the same in `policyTypes`. We will not block egress traffic for now, which means that triumph1 will still be able to ping triumph2, but triumph2 will not be able to ping triumph1.

NOTE - If the order is diff for these, it gives error `error: error validating "STDIN": error validating data: kind not set; if you choose to ignore these errors, turn validation off with --validate=false`

kind: NetworkPolicy
apiVersion: networking.k8s.io/v1

## RESULT

Once the network policies have been created, we can see that egress traffic from triumph1 is still working, but ingress traffic to triumph1 does not work

```
networkpolicy.networking.k8s.io/deny-ingress created
ubuntu@ip-172-31-31-18:~$ kubectl get pods -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP               NODE                  NOMINATED NODE   READINESS GATES
triumph1   1/1     Running   0          32m   100.120.31.66    i-08c431c8b5cfbfc00   <none>           <none>
triumph2   1/1     Running   0          31m   100.111.25.130   i-0cc4b3b8593320307   <none>           <none>
ubuntu@ip-172-31-31-18:~$ kubectl exec -it triumph1 -- bash
root@triumph1:/# ping 100.111.25.130
PING 100.111.25.130 (100.111.25.130) 56(84) bytes of data.
64 bytes from 100.111.25.130: icmp_seq=1 ttl=62 time=0.616 ms
```
We try to ping triumph 1 from triumph2, but it does not work

```
ubuntu@ip-172-31-31-18:~$ kubectl exec -it triumph2 -- bash
root@triumph2:/# ping 100.120.31.66
PING 100.120.31.66 (100.120.31.66) 56(84) bytes of data.
^C
--- 100.120.31.66 ping statistics ---
38 packets transmitted, 0 received, 100% packet loss, time 37882ms

```

## Blocking Egress

Similarly we can block egress traffic from triumph1 pod as well, Refer yaml

We can see that now from triumph1 pod, egress traffic is also not working to any other pod in same ns.
```

networkpolicy.networking.k8s.io/deny-egress created
ubuntu@ip-172-31-31-18:~$ kubectl exec -it triumph1 -- bash
root@triumph1:/# ping 100.111.25.130 
PING 100.111.25.130 (100.111.25.130) 56(84) bytes of data.
^C
--- 100.111.25.130 ping statistics ---
9 packets transmitted, 0 received, 100% packet loss, time 8217ms

root@triumph1:/# 

```

Delete all pods

`kubectl delete pods --all`
pod "triumph1" deleted
pod "triumph2" deleted


