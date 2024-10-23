

# Creating ingress resource
So we hvae foll records - 
    vote.cloudadhanik.xyz
    www.cloudadhanik.xyz
    result.cloudadhanik.xyz

So now we have created 3 record name, we will create an ingress resource which is responsible for routing the traffic appropriately to each service.

- We will create 2 - result and vote.cloudadhanik.xyz
- The secret name for ssl termination is also defined inside the ingress.yaml - secretName: nginx-tls-default. so whenever you access www.cloudadhanik.xyz, it is now secure.

```
kubectl apply -f ingress.yaml 
ingress.networking.k8s.io/result-ingress created
ingress.networking.k8s.io/vote-ingress created
```

## Issue

After doing kubectl apply -f ingress.yaml , we faced issue where `CLASS and ADDRESS` was not being assinged to our ingress address.


```
kubectl get ingress
NAME             CLASS    HOSTS                                        ADDRESS   PORTS     AGE
result-ingress   <none>   result.cloudadhanik.xyz                                80, 443   6s
vote-ingress     <none>   vote.cloudadhanik.xyz,www.cloudadhanik.xyz             80, 443   6s
```

### Checking logs of result-ingress

We chcked the logs our result-ingress

`kubectl logs ingress-nginx-controller-77667b9d9b-vh22j -n ingress-nginx`


"ignoring ingress result-ingress in default based on annotation: ingress does not contain a valid IngressClass"
"ignoring ingress vote-ingress in default based on annotation: ingress does not contain a valid IngressClass"

- Key Problem

1. The NGINX Ingress controller is not recognizing the IngressClass specified in your Ingress resources. The issue lies in how the IngressClassName is defined, and it's likely that it is missing or not correctly mapped to the NGINX Ingress controller.

`kubectl get ingressclass`

```
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       142m
```
`If there's no valid nginx IngressClass, you need to create one manually.`

The output confirms that the IngressClass named nginx is correctly defined and recognized by your Kubernetes cluster. However, from the logs and configuration provided earlier, it seems the issue is that your Ingress resources are not referencing this IngressClass properly.

Update Ingress Resources
Since the IngressClass exists, you need to make sure that your Ingress resources explicitly reference this class using ingressClassName: nginx. The following steps should resolve the issue:

Modify your Ingress YAML file by updating the ingressClassName in both the result-ingress and vote-ingress resources.

2. We will udpate our yaml and Create an IngressClass for NGINX. If the IngressClass does not exist, you can create it manually. In spec section we added ingressClassName

spec:
  ingressClassName: nginx  # Correct ingressClassName here

We delete both the ingress paths and recreated with corrected yaml

```

kubectl delete ingress result-ingress
ingress.networking.k8s.io "result-ingress" deleted
ubuntu@ip-172-31-80-64:~$ kubectl delete ingress vote-ingress
ingress.networking.k8s.io "vote-ingress" deleted
ubuntu@ip-172-31-80-64:~$ kubectl get ingress
No resources found in default namespace.
ubuntu@ip-172-31-80-64:~$ rm ingress.yaml 

```
Recreated ingress.yaml

```
ubuntu@ip-172-31-80-64:~$ vi ingress.yaml
ubuntu@ip-172-31-80-64:~$ kubectl apply -f ingress.yaml 
```

 kubectl get ingress
NAME             CLASS   HOSTS                                        ADDRESS                                                                         PORTS     AGE
result-ingress   nginx   result.cloudadhanik.xyz                      adb65a2089d91489a96ce54036c829c4-a3b57334a1d0d57d.elb.us-east-1.amazonaws.com   80, 443   7m52s
vote-ingress     nginx   vote.cloudadhanik.xyz,www.cloudadhanik.xyz   adb65a2089d91489a96ce54036c829c4-a3b57334a1d0d57d.elb.us-east-1.amazonaws.com   80, 443   7m52s
ubuntu@ip-172-31-80-64:~$ 


Once the load balancer is up, you can access your application using your domain names (www.cloudadhanik.xyz, vote.cloudadhanik.xyz, result.cloudadhanik.xyz).

## Note - Applying changes from YAML for only vote-ingress

When you use kubectl edit ingress vote-ingress, the changes should apply directly to the specific vote-ingress resource. If the changes are not reflecting, it might be due to an error while saving or some other configuration issue.

Since you are asking about how to edit only the vote-ingress section within the original ingress.yaml file without recreating the resources, you can do it - `kubectl edit ingress vote-ingress`


kubectl get ingress
NAME             CLASS   HOSTS                                        ADDRESS                                                                         PORTS     AGE
result-ingress   nginx   result.cloudadhanik.xyz                      adb65a2089d91489a96ce54036c829c4-a3b57334a1d0d57d.elb.us-east-1.amazonaws.com   80, 443   7m52s
vote-ingress     nginx   vote.cloudadhanik.xyz,www.cloudadhanik.xyz   adb65a2089d91489a96ce54036c829c4-a3b57334a1d0d57d.elb.us-east-1.amazonaws.com   80, 443   7m52s


Now we can access the website on our domain www.cloudadhanik.xyz