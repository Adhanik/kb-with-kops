
# Check if cluster is running fine or not

- kubectl cluster-info
- kubectl get nodes -o wide
- kops validate cluster --wait 10m


# Delete cluster

- kops delete -f cluster.yml  --yes


# Pod

- Create a pod - kubectl run pod --image nginx:latest
- kubectl run prod1 --image=kiran2361993/troubleshootingtools:v1 -n prod -l ns=prod
- kubectl exec -it prod -- bash
- kubectl delete pods --all - Delete all pods

# Deployment

- kubectl create deployment testpod1 --image kiran2361993/kubegame:v2 --replicas 6 --dry-run -o yaml
- kubectl create deployment newnginx --image=nginx:latest --replicas=3 --dry-run=client -o yaml

- kubectl delete deployment.apps <deployment-name>


# Service

- kubectl expose deployemnt init-container-deployment --name myservice --port 80
- kubectl expose deployment newnginx --port=80 --target-port=9999 --type=NodePort
- kubectl delete service <service-name>

# Change ns

- Switch to diff ns - kubectl config set-context --current --namespace=development


# Create ns and label

- kubectl create ns prod
- kubectl label ns qa nsp=qa
- kubectl get ns --show-labels

# alias

alias allpods='kubectl get pods -o wide -n prod --no-headers && kubectl get pods -o wide -n dev --no-headers && kubectl get pods -o wide -n qa --no-headers'