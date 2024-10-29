
# Check if cluster is running fine or not

- kubectl cluster-info
- kubectl get nodes -o wide
- kops validate cluster --wait 10m


# Delete cluster

- kops delete -f cluster.yml  --yes


# Deployment

- kubectl create deployment testpod1 --image kiran2361993/kubegame:v2 --replicas 6 --dry-run -o yaml
- kubectl delete deployment.apps <deployment-name>


# Service

- kubectl expose deployemnt init-container-deployment --name myservice --port 80
- kubectl delete service <service-name>