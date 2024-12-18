
Now suppose we have a scenario where you want to establish communication btw dev and production. The developer from dev ns wants to access production, so it should be success


Here we can see that traffic going from dev pod will be EGRESS to prod, and for prod pod, it will be ingress. We want to allow traffic from dev ns to communicate with prod ns.

We will allow egress from dev to have access to prod, and ingress to prod should be allowed from dev.

## Current behaviour

We can see that currently traffic from dev pod is not working

```
ubuntu@ip-172-31-20-104:~$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
dev1   1/1     Running   0          4h20m
dev2   1/1     Running   0          4h20m

```
```
ubuntu@ip-172-31-20-104:~$ kubectl exec -it dev1 -- bash
root@dev1:/# ping 100.115.162.194
PING 100.115.162.194 (100.115.162.194) 56(84) bytes of data.
^C
--- 100.115.162.194 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2047ms


```

## Expected Scenario

We will now apply f.1 yaml, and  after that we can see that pods in dev ns are able to communicate with pods in prod ns

```
kubectl exec -it dev1 -- bash
root@dev1:/# ping 100.115.162.194
PING 100.115.162.194 (100.115.162.194) 56(84) bytes of data.
64 bytes from 100.115.162.194: icmp_seq=1 ttl=62 time=0.549 ms
64 bytes from 100.115.162.194: icmp_seq=2 ttl=62 time=0.272 ms
64 bytes from 100.115.162.194: icmp_seq=3 ttl=62 time=0.256 ms
^C
--- 100.115.162.194 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2076ms
rtt min/avg/max/mdev = 0.256/0.359/0.549/0.134 ms
root@dev1:/# 

```

dev2 pod accesses prod2

```

 kubectl exec -it dev2 -- bash
root@dev2:/# ping 100.115.162.195
PING 100.115.162.195 (100.115.162.195) 56(84) bytes of data.
64 bytes from 100.115.162.195: icmp_seq=1 ttl=62 time=0.410 ms
64 bytes from 100.115.162.195: icmp_seq=2 ttl=62 time=0.335 ms
64 bytes from 100.115.162.195: icmp_seq=3 ttl=62 time=0.320 ms
64 bytes from 100.115.162.195: icmp_seq=4 ttl=62 time=0.312 ms
64 bytes from 100.115.162.195: icmp_seq=5 ttl=62 time=0.283 ms
^C
--- 100.115.162.195 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4136ms
rtt min/avg/max/mdev = 0.283/0.332/0.410/0.042 ms
root@dev2:/# 
```