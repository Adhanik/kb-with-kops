

1. Login to your management-cluster, and configure ingress controller 

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/aws/deploy.yaml


Check if ingress pod is up and running
```
kubectl get pods -n ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-85pww        0/1     Completed   0          26m
ingress-nginx-admission-patch-d9nrp         0/1     Completed   1          26m
ingress-nginx-controller-77667b9d9b-vh22j   1/1     Running     0          26m

```

The output shows that the NGINX Ingress Controller pod (ingress-nginx-controller-77667b9d9b-vh22j) is running, which is a good sign. The other two pods (ingress-nginx-admission-create and ingress-nginx-admission-patch) are job-related pods for admission webhooks, and it's normal for them to have Completed status.


2.  Next, run the following command to check if the Ingress Controller service has been assigned an external LoadBalancer:

```

kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   100.67.88.198   <pending>     80:32713/TCP,443:31322/TCP   28m
ingress-nginx-controller-admission   ClusterIP      100.70.29.4     <none>        443/TCP                      28m
ubuntu@ip-172-31-80-64:~$ 

```

Here, we see that the EXTERNAL-IP shows <pending>, this means the AWS Load Balancer is not yet created.

## Issue-Debugging

1. Check the Ingress Controller Logs: - kubectl logs ingress-nginx-controller-77667b9d9b-vh22j -n ingress-nginx
We did not find any error here, we will check events

2. Check if there are any events related to the service or ingress that might indicate why the Load Balancer isn't being created:

kubectl describe ingress <your-ingress-name> -n <your-namespace>

`kubectl describe svc ingress-nginx-controller -n ingress-nginx` - This gave us the below error 

```
Error syncing load balancer: failed to ensure load balancer: error creating load balancer: "AccessDenied: User: arn:aws:sts::975050301329:assumed-role/masters.cloudadhanik.xyz/i-00b8791e32d52548d is not authorized to perform: ec2:DescribeInternetGateways\n\tstatus code: 403, request id: e2000372-0a93-402b-a3f1-705ad2fd4668"

```

## Solution

We need to update the IAM role that your Kubernetes control plane (master) nodes are using to grant the necessary permissions for creating and managing load balancers.

Go to iam role - permissions - Add permission - Attach the AmazonEC2FullAccess and ElasticLoadBalancingFullAccess AWS managed policies to the role.

Now if we run describe svc command again for ingress, we see

```
 service-controller  (combined from similar events): Error syncing load balancer: failed to ensure load balancer: error creating load balancer: "AccessDenied: User: arn:aws:sts::975050301329:assumed-role/masters.cloudadhanik.xyz/i-00b8791e32d52548d is not authorized to perform: ec2:DescribeInternetGateways\n\tstatus code: 403, request id: 37ebd4bb-d121-4a6f-abe9-cad194f98a1c"
  Normal   EnsuringLoadBalancer    39s (x14 over 41m)   service-controller  Ensuring load balancer
  Normal   EnsuredLoadBalancer     35s                  service-controller  Ensured load balancer

```
Our load balancer is now created.

If we describe the nginx controller - `kubectl describe svc ingress-nginx-controller -n ingress-nginx` , we can see `LoadBalancer Ingress:     adb65a2089d91489a96ce54036c829c4-a3b57334a1d0d57d.elb.us-east-1.amazonaws.com` assinged.



# Copying the cert keys from TLS key EC2 to mangement server EC2

2. We will create keys in /tmp folder

`cd /tmp`
`vi tls.crt` -> paste cert keys
`vi tls.key`

3. Once we have pasted keys in above location, we will create secrets

`kubectl create secret tls nginx-tls-default --key "tls.key" --cert="tls.crt"`

secret/nginx-tls-default created

4. Verify secrets are correct, they should not be empty. if no is 0 in bytes, then keys are wrong. we see its 3578 bytes
```


kubectl get secrets 
NAME                TYPE                DATA   AGE
nginx-tls-default   kubernetes.io/tls   2      46s

ubuntu@ip-172-31-85-128:/tmp$ kubectl describe secrets nginx-tls-default
Name:         nginx-tls-default
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  3578 bytes
tls.key:  1704 bytes

```