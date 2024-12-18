


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

## Conclusion

As we have seen in our last d1.yaml, pods in same ns were also not able to communicate with each other. We will change this and implement policy that will allow traffic between PODs in prod NS.

Switch to prod ns 
`kubectl config set-context --current --namespace=prod`


Refer e1.yaml. Once you have applied yaml, you can see that communication btw pods in prod ns is success

```
networkpolicy.networking.k8s.io/allow-trrafic-in-pods-in-same-ns created

ubuntu@ip-172-31-20-104:~$ kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE     IP                NODE                  NOMINATED NODE   READINESS GATES
prod1   1/1     Running   0          3h27m   100.115.162.194   i-0f3b21bd0da060378   <none>           <none>
prod2   1/1     Running   0          3h27m   100.115.162.195   i-0f3b21bd0da060378   <none>           <none>

```

```
ubuntu@ip-172-31-20-104:~$ kubectl exec -it prod1 -- bash
root@prod1:/# ping 100.115.162.195
PING 100.115.162.195 (100.115.162.195) 56(84) bytes of data.
64 bytes from 100.115.162.195: icmp_seq=1 ttl=63 time=0.512 ms
64 bytes from 100.115.162.195: icmp_seq=2 ttl=63 time=0.072 ms
64 bytes from 100.115.162.195: icmp_seq=3 ttl=63 time=0.074 ms
64 bytes from 100.115.162.195: icmp_seq=4 ttl=63 time=0.127 ms
64 bytes from 100.115.162.195: icmp_seq=5 ttl=63 time=0.064 ms
^C
--- 100.115.162.195 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4054ms
rtt min/avg/max/mdev = 0.064/0.169/0.512/0.173 ms

```