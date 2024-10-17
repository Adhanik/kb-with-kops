

We will make use of the old deployment created in node port only.

`kubectl expose deployment app1 --port 80 --target-port 80 --type LoadBalancer`

```
kubectl get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
app1         LoadBalancer   100.69.27.160   <pending>     80:30689/TCP   4s

```

Note - See we get the EXTERNAL-IP here. AWS provisions a load balancer for us. We get a DNS name, which we have to attach in route 53..

Open your hosted zone, create record, simple touring - Define simple record- choose subdomain as www - select Application load balancer in Value/Route traffic to - choose region - define simple record - wait for to get sync.

Now the application can be accessed on DNS.

## Annotations in KB

We have diff annotations which can be used in Deployment yaml manifest, which one can read here -

https://gist.github.com/mgoodness/1a2926f3b02d8e8149c224d25cc57dc1

A few egs are -

```
service.beta.kubernetes.io/aws-load-balancer-access-log-emit-interval (in minutes)
service.beta.kubernetes.io/aws-load-balancer-access-log-enabled (true|false)
service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-name
service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-prefix
service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags (comma-separated list of key=value)
service.beta.kubernetes.io/aws-load-balancer-backend-protocol (http|https|ssl|tcp)
```

