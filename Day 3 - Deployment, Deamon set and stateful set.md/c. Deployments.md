

# Deployments

- High Availability & Scalability - One of the main reasons why Deployments are bing used is due to SCALABILITY. The replica set ensure that the specified no of pods are always up and running, ensuring H.A.

- Automation - Deployments help with automatically managing the updates, scaling, rollbacks etc.

- Self Healing - If any pod goes down or fails, it is automatically replaced/ restart failed containers.

- Load Balancing - Ensure network traffic is distributed evenly across multiple pods.


## Practical
 
### Prechecks

`alias ku = kubectl`
`ku get nodes -o wide`
`ku cluster-info`

### Deployment manifest

`kubectl create deployment testpod1 --image kiran2361993/kubegame:v2 --replicas 3 --dry-run -o yaml`

Paste it in testpod.yaml
