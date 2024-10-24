
# Load balancer

The load balancer that we have created has been assigned a DNS name, but this we cannot use for routing
```

DNS Name
adb65a2089d91489a96ce54036c829c4-a3b57334a1d0d57d.elb.us-east-1.amazonaws.com

```

- So we will go back to our Route 53 -> Hosted zones(cloudadhanik.xyz) -> create records-> record name(put www) -> Value/route traffic  - Alias to NLB - give region IN Whichever your LB is - points to your LB

- If someone want to access votes,  we will create another simple record as with subdomain as vote - Value/route traffic  - Alias to NLB - give region IN Whichever your LB is - points to your LB

- for result similarly we will create another simple record with result as subdomain. we will click on create records at last, and wait for them to get in sync.


So we have foll records - 
    vote.cloudadhanik.xyz
    www.cloudadhanik.xyz
    result.cloudadhanik.xyz

Verify Load Balancer Creation

Once the Ingress resources are recognized, the NGINX Ingress controller should create the AWS load balancer. You can check the status with:

`kubectl get svc -n ingress-nginx`

The external load balancer IP or hostname should now be visible under the EXTERNAL-IP field.

This is issue which we will solve by including a field in our ingress.yaml  
`spec:ingressClassName: nginx`

```
kubectl get ingress
NAME             CLASS    HOSTS                                        ADDRESS   PORTS     AGE
result-ingress   <none>   result.cloudadhanik.xyz                                80, 443   6s
vote-ingress     <none>   vote.cloudadhanik.xyz,www.cloudadhanik.xyz             80, 443   6s
```

If we do describe on our ingress svc, we can see load balancer address there.

```
kubectl describe svc ingress-nginx-controller -n ingress-nginx
Name:                     ingress-nginx-controller
Namespace:                ingress-nginx
Labels:                   app.kubernetes.io/component=controller
                          app.kubernetes.io/instance=ingress-nginx
                          app.kubernetes.io/name=ingress-nginx
                          app.kubernetes.io/part-of=ingress-nginx
                          app.kubernetes.io/version=1.11.1
Annotations:              service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
                          service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: true
                          service.beta.kubernetes.io/aws-load-balancer-type: nlb
Selector:                 app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       100.67.88.198
IPs:                      100.67.88.198
LoadBalancer Ingress:     adb65a2089d91489a96ce54036c829c4-a3b57334a1d0d57d.elb.us-east-1.amazonaws.com
Port:                     http  80/TCP
TargetPort:               http/TCP
NodePort:                 http  32713/TCP
Endpoints:                100.96.2.137:80
Port:                     https  443/TCP
TargetPort:               https/TCP
NodePort:                 https  31322/TCP
Endpoints:                100.96.2.137:443
Session Affinity:         None
External Traffic Policy:  Local
Internal Traffic Policy:  Cluster
HealthCheck NodePort:     30961
Events:

```