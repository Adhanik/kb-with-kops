
## Prod to QA on a specific port

In this section, we will be configuring Network Policies in such a way that pods in prod  ns will be able to access pods in qa ns on a specific port - 8888.

- Since we will be sending traffic from prod, it will be a egress traffic, we have to write network policy with prod ns.

- Also the QA should allow Egress traffic from prod, and internally it should accept Ingress traffic, so we will write a Network policy which would allow Ingress traffic from prod to QA.

- Refer g.1 prod to qa.yaml


## Output

We see the pods of all IP

```

ubuntu@ip-172-31-22-195:~$ allpod
prod1   1/1   Running   0     9m10s   100.101.105.194   i-01f6de6d4d00ac3aa   <none>   <none>
prod2   1/1   Running   0     9m10s   100.101.105.195   i-01f6de6d4d00ac3aa   <none>   <none>
dev1   1/1   Running   0     8m44s   100.122.207.3     i-056853162e43c10f1   <none>   <none>
dev2   1/1   Running   0     8m44s   100.124.167.196   i-0135a070173a99167   <none>   <none>
qa1   1/1   Running   0     8m33s   100.101.105.196   i-01f6de6d4d00ac3aa   <none>   <none>
qa2   1/1   Running   0     8m33s   100.122.207.4     i-056853162e43c10f1   <none>   <none>

```

If we try to ping 
```

ubuntu@ip-172-31-22-195:~$ kubectl exec -it prod1 -- bash
Error from server (NotFound): pods "prod1" not found

```

But we can see if we curl on QAPOD -IP:PORT, it is accessible

```
ubuntu@ip-172-31-22-195:~$ kubectl exec -it prod1 -n prod -- bash
root@prod1:/# ping 100.101.105.196
PING 100.101.105.196 (100.101.105.196) 56(84) bytes of data.
^C
--- 100.101.105.196 ping statistics ---
12 packets transmitted, 0 received, 100% packet loss, time 11268ms

root@prod1:/# curl http://100.101.105.196:8888
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
```

Similary for other QA pod as well, if we curl on its IP its accessible

```
root@prod1:/# curl http://100.122.207.4:8888
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
```