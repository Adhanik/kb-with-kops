
# Overview

Suppose we have 3 Ns - Prod, QA and Dev. By default, all the 3 ns will be having communication with other ns.

In real time, there will be no communication within these 3 ns. So we will be blocking all access of each ns to other ns, and any pod running in Prod ns, will not be able to communicate with Dev or QA ns.

The same will be done for pods in QA and Dev ns. We will give them access only on port level.


The networking policies can be applied on 

- Pod level
- Labels
- Namespaces

## Features:

- Namespace Isolation: Policies to isolate network traffic within specific namespaces, preventing unintended access between different parts of the cluster.

- Granular Traffic Control: Define rules that allow or block traffic between namespaces, ensuring that only authorized communication paths are permitted.

- Environment Segmentation: Securely manage traffic flow between development, QA, and production environments, helping to maintain a strict separation of concerns.

- Ingress and Egress Management: Control incoming and outgoing traffic at a fine-grained level, which is crucial for both security and performance optimization.

- Port-Specific Rules: Implement policies that allow or restrict traffic on specific TCP/UDP ports, such as allowing QA to communicate with production over a specific port.

- Ingress refers to incoming traffic, while egress refers to outgoing traffic.

# Create cluster using Calico

```
kops create cluster --name=cloudadhanik.xyz \
--state=s3://cloudadhanik.xyz --zones=us-east-1a \
--node-count=3 --node-size=t3.medium --control-plane-size=t3.medium \
--control-plane-volume-size 10 --node-volume-size 10 \
--topology private --networking calico \
--ssh-public-key ~/.ssh/id_ed25519.pub \
--dns-zone=cloudadhanik.xyz --yes
```

`kops validate cluster --wait 10m`

Delete it later - `kops delete -f cluster.yml  --yes`

- Once you create cluster using the above command, control plane and worker nodes will not have any public IP assigned to them.

- A Network load balancer will also be created, along with a NAT gateway.