
## Persistent Volume

A PV is a piece of storage in cluster that has been provisioned by an admin or dynamically provisioned using Storage Classes.

We will create 4 PV, attached with EBS volumes, and then use them for PVC requests.

Since we are creating a number of PVs, this is static method of provisioning.

## Installing AWS CLI

```

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws --version

```

## Create EBS Volume using aws cli

We have created ebs volume like aws-pv1,2,3,4,5 with diff volume size (2,4,6,8,10) and type are same (gp2)

Update the volume id created from below command in Persistentvol.yaml 

```

aws ec2 create-volume \
    --volume-type gp2 \
    --size 2 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=volume,Tags=[{Key=KubernetesCluster,Value=cloudadhanik.xyz},{Key=Name,Value=aws-pv1}]' && \

aws ec2 create-volume \
    --volume-type gp2 \
    --size 4 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=volume,Tags=[{Key=KubernetesCluster,Value=cloudadhanik.xyz},{Key=Name,Value=aws-pv2}]' && \

aws ec2 create-volume \
    --volume-type gp2 \
    --size 6 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=volume,Tags=[{Key=KubernetesCluster,Value=cloudadhanik.xyz},{Key=Name,Value=aws-pv3}]' && \

aws ec2 create-volume \
    --volume-type gp2 \
    --size 8 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=volume,Tags=[{Key=KubernetesCluster,Value=cloudadhanik.xyz},{Key=Name,Value=aws-pv4}]' && \

aws ec2 create-volume \
    --volume-type gp2 \
    --size 10 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=volume,Tags=[{Key=KubernetesCluster,Value=cloudadhanik.xyz},{Key=Name,Value=aws-pv5}]'
```


Copy the Persistentvol.yaml , and run kubectl apply on it (or use echo command)

```
 kubectl apply -f PV.yaml 
persistentvolume/aws-pv1 created
persistentvolume/aws-pv2 created
persistentvolume/aws-pv3 created
persistentvolume/aws-pv4 created
persistentvolume/aws-pv5 created

```

We get the PV

```
kubectl get pv
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
aws-pv1   2Gi        RWO            Delete           Available           gp2                     80s
aws-pv2   4Gi        RWO            Delete           Available           gp2                     80s
aws-pv3   6Gi        RWO            Delete           Available           gp2                     80s
aws-pv4   8Gi        RWO            Delete           Available           gp2                     80s
aws-pv5   10Gi       RWO            Delete           Available           gp2                     80s
ubuntu@ip-172-31-25-119:~$ 

```

To claim these PV, we need to claim it. Refer PVC
