
READ - https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html

# Automating EBS-backed Persistent Volume Provisioning in Kubernetes with Terraform

## Overview of Terraform Automation

Terraform will automate the following tasks:
1. Create an EKS cluster (or integrate with an existing cluster).
2. Define an IAM Role & Policy for EBS CSI Driver.
3. Deploy the Amazon EBS CSI Driver in Kubernetes.
4. Create a StorageClass (gp2-storage) for dynamic provisioning.
5. Define a PVC (`pvc.yaml`) so that developers can request storage.

---

## 1️⃣ Terraform Code for AWS EKS with EBS CSI Driver

#### 🔹 Step 1: Create an EKS Cluster

**eks-cluster.tf**
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_eks_cluster" "my_cluster" {
  name     = "my-k8s-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }
}

resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}
```

#### 🔹 Step 2: IAM Role for EBS CSI Driver

**iam-ebs-csi.tf**
```hcl
resource "aws_iam_role" "ebs_csi_role" {
  name = "EBSCSIDriverRole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole

"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "ebs_csi_policy" {
  name        = "AmazonEBSCSIPolicy"
  description = "Allows EBS CSI driver to manage volumes"

  policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:CreateVolume",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeVolumes",
        "ec2:DescribeInstances",
        "ec2:ModifyVolume"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = aws_iam_policy.ebs_csi_policy.arn
}
```

#### 🔹 Step 3: Deploy Amazon EBS CSI Driver in Kubernetes

**ebs-csi-driver.tf**
```hcl
resource "kubernetes_service_account" "ebs_csi" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "ebs_csi_role" {
  metadata {
    name = "ebs-csi-role"
  }
  rules {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["create", "delete", "get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "ebs_csi_binding" {
  metadata {
    name = "ebs-csi-binding"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.ebs_csi_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
  subjects {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ebs_csi.metadata[0].name
    namespace = "kube-system"
  }
}
```

#### 🔹 Step 4: Create a Dynamic StorageClass in Kubernetes

**storageclass.yaml**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp2
  fsType: ext4
  zones: us-east-1a
reclaimPolicy: Delete
allowVolumeExpansion: true
```

#### 🔹 Step 5: Define a PVC to Request Storage

**pvc.yaml**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: gp2-storage
```

---

## 3️⃣ Apply Terraform to Deploy Everything

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Plan Deployment**
   ```bash
   terraform plan
   ```

3. **Apply Deployment**
   ```bash
   terraform apply -auto-approve
   ```

4. **Verify StorageClass**
   ```bash
   kubectl get storageclass
   ```
   Expected output:
   ```bash
   NAME           PROVISIONER      RECLAIM POLICY
   gp2-storage   ebs.csi.aws.com   Delete
   ```

5. **Verify PVC & PV**
   ```bash
   kubectl get pvc
   ```
   Expected output:
   ```bash
   NAME           STATUS   VOLUME                                     CAPACITY  ACCESS MODES   STORAGECLASS
   dynamic-pvc    Bound    pvc-1234abcd-5678-efgh-9101-ijklmnopqr     100Gi     RWO            gp2-storage
   ```

---

## 4️⃣ Final Setup Recap

✅ Terraform automates Kubernetes + AWS EBS integration.

✅ Developers can request any storage size dynamically.

✅ No manual PV creation is needed anymore.

✅ Kubernetes automatically provisions EBS volumes via CSI.

---

Would you like a Helm Chart to package this setup? 🚀
```

This Markdown structure allows you to share the guide in a well-organized and readable format, suitable for documentation purposes.