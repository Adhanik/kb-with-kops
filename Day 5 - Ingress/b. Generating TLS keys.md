

# Generating SSL Keys

We will create a t2.micro instance. This is separate from our management cluster from where we are creating our KB cluster.

1. Install cert bot - sudo snap install --classic certbot
2. sudo certbot certonly --manual --preferred-challenges=dns --key-type rsa --email workwithnik@gmail.com \
--server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d *.cloudadhanik.xyz

This will give us two certificates, when it prompts you to press Enter, dont press Enter, 

1. copy _acme-challenge -> GOTO Route 53 - Hosted Zone - Create record, with record name - _acme-challenge 
2. Then in value, provide the value given 
3. Set ttl to 1 with simple routing.
4. Wait for its status to change to INSYNC from pending - After that press enter

``` Eg 
Please deploy a DNS TXT record under the name:

_acme-challenge.cloudadhanik.xyz.

with the following value:

Ztuj3n5lDjL2XBd9_Hs68U-xaMkDwzMeKHBhdBLoHCo
```

5. After we press enter, in backend it checks whether _acme-challenge exists in our Route 53 for which we created record.
It will show confirmation

```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/cloudadhanik.xyz/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/cloudadhanik.xyz/privkey.pem
This certificate expires on 2025-01-16.
These files will be updated when the certificate renews.

```

6. We see certificate and key saved at respective path. cat them and copy to tls.cert, and tls.ey

    sudo cat /etc/letsencrypt/live/cloudadhanik.xyz/fullchain.pem
    sudo cat /etc/letsencrypt/live/cloudadhanik.xyz/privkey.pem


7. Once our cluster is up and ready, we will run these keys as secret.

```
kubectl cluster-info
Kubernetes control plane is running at https://api.cloudadhanik.xyz
CoreDNS is running at https://api.cloudadhanik.xyz/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.


kubectl get nodes -o wide
NAME                  STATUS   ROLES           AGE   VERSION    INTERNAL-IP      EXTERNAL-IP      OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
i-0d193b094cbfc5af5   Ready    node            47m   v1.28.11   172.20.208.216   18.233.225.254   Ubuntu 22.04.4 LTS   6.5.0-1020-aws   containerd://1.7.16
i-0f335b072a4efa623   Ready    control-plane   50m   v1.28.11   172.20.126.80    34.239.112.166   Ubuntu 22.04.4 LTS   6.5.0-1020-aws   containerd://1.7.16
i-0fd5e183ddd487d05   Ready    node            47m   v1.28.11   172.20.100.67    44.213.109.118   Ubuntu 22.04.4 LTS   6.5.0-1020-aws   containerd://1.7.16
```

Next we will deploy a ingress controller.
