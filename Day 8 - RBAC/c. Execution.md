

### 1. Copy Keys for Cluster Creation

Copy the keys and certificates to the appropriate directories (`.ssh/` and `private key`).

We have our private key id_ed25519 inside .ssh folder already which we did using `ssh-keygen`

```

ubuntu@ip-172-31-25-177:~/.ssh$ ls -ltr
total 12
-rw------- 1 ubuntu ubuntu 391 Nov  2 11:05 authorized_keys
-rw-r--r-- 1 ubuntu ubuntu 105 Nov  2 11:11 id_ed25519.pub
-rw------- 1 ubuntu ubuntu 419 Nov  2 11:11 id_ed25519
ubuntu@ip-172-31-25-177:~/.ssh$ 
```

### 2. Create Namespaces

Create two namespaces: `development` and `production`.

```
ubuntu@ip-172-31-25-177:~$ kubectl create ns development
namespace/development created
ubuntu@ip-172-31-25-177:~$ kubectl create ns production
namespace/production created
ubuntu@ip-172-31-25-177:~$ kubectl get ns
NAME              STATUS   AGE
default           Active   35m
development       Active   27s
kube-node-lease   Active   35m
kube-public       Active   35m
kube-system       Active   35m
production        Active   21s
ubuntu@ip-172-31-25-177:~$ 

```

### 3. Copy CA Certificates

Copy the following files from the master to the management server:
- `ca.crt`
- `ca.key`

So for getting the crt keys from our master node, we will login to our master node, and go to this path 

```
ubuntu@i-06cd00b80475fb4f5:~$ cd /etc/kubernetes/kops-controller/
ubuntu@i-06cd00b80475fb4f5:/etc/kubernetes/kops-controller$ ls -al
total 28
drwxr-xr-x 2 root            root 4096 Nov  2 11:18 .
drwxr-xr-x 6 root            root 4096 Nov  2 11:18 ..
-rw------- 1 kops-controller root  410 Nov  2 11:18 keypair-ids.yaml
-rw-r--r-- 1 kops-controller root 1200 Nov  2 11:18 kops-controller.crt
-rw------- 1 kops-controller root 1679 Nov  2 11:18 kops-controller.key
-rw------- 1 kops-controller root 1090 Nov  2 11:18 kubernetes-ca.crt
-rw------- 1 kops-controller root 1675 Nov  2 11:18 kubernetes-ca.key
ubuntu@i-06cd00b80475fb4f5:/etc/kubernetes/kops-controller$ 
```
We will do sudo cat kubernetes-ca.crt and cat kubernetes-ca.key , go to management server, and create a new dir /tmp, and paste the content of our key inside ca.crt. Similarly we can do for ca.key

So now we have both our ca.crt and ca.key present in same dir

```
-rw-rw-r--  1 ubuntu ubuntu 1090 Nov  2 12:18 ca.crt
-rw-rw-r--  1 ubuntu ubuntu 1675 Nov  2 12:17 ca.key
```

### 4. Create Users

#### User 1: `user1`

Generate the key and certificate:

```bash
openssl genrsa -out user1.key 2048
openssl req -new -key user1.key -out user1.csr -subj "/CN=user1/O=development"
openssl x509 -req -in user1.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out user1.crt -days 365
```

The first command creates a - user1.key
We are creating the above user for development ns in second command - user1.csr
In third command, we are creating user using ca.crt and ca.key which we pasted in our mgmt server and user will have 365 days permission. This will generate user1.crt

```
Certificate request self-signature ok
subject=CN = user1, O = development
```

#### User 2: `user2`

Similarly we will generate for user2 in production ns

```bash
openssl genrsa -out user2.key 2048
openssl req -new -key user2.key -out user2.csr -subj "/CN=user2/O=production"
openssl x509 -req -in user2.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out user2.crt -days 365
```

Certificate request self-signature ok
subject=CN = user2, O = production

#### Output

```
-rw-rw-r-- 1 ubuntu ubuntu 1675 Nov  2 12:17 ca.key
-rw-rw-r-- 1 ubuntu ubuntu 1090 Nov  2 12:18 ca.crt
-rw------- 1 ubuntu ubuntu 1704 Nov  2 12:24 user1.key
-rw-rw-r-- 1 ubuntu ubuntu  915 Nov  2 12:25 user1.csr
-rw-rw-r-- 1 ubuntu ubuntu 1021 Nov  2 12:25 user1.crt
-rw------- 1 ubuntu ubuntu 1704 Nov  2 12:39 user2.key
-rw-rw-r-- 1 ubuntu ubuntu  915 Nov  2 12:39 user2.csr
-rw-rw-r-- 1 ubuntu ubuntu   41 Nov  2 12:40 ca.srl
-rw-rw-r-- 1 ubuntu ubuntu 1021 Nov  2 12:40 user2.crt
```

### 5. Copy Certificates and Keys

We will create these keys in root dir in master node
Copy all `.crt` and `.key` files to the master root location safely.

For user1 we have 3 keys, crt, csr(ignore), and key . We will copy these keys to master location.

These are copied because this will be used in kube config file in client-certificate and client-key arguments.

`vi user1.cert`
`vi user1.key`

`vi user2.crt`
`vi user2.key`

### 6. Create Config Files for Users

We need to create config file for both the users. We can copy the kube config file from our mgmt server

```
 cd .kube
ubuntu@ip-172-31-25-177:~/.kube$ ls -al
total 20
drwxr-xr-x 3 ubuntu ubuntu 4096 Nov  2 11:38 .
drwxr-x--- 5 ubuntu ubuntu 4096 Nov  2 12:18 ..
drwxr-x--- 4 ubuntu ubuntu 4096 Nov  2 11:38 cache
-rw------- 1 ubuntu ubuntu 5688 Nov  2 11:17 config
ubuntu@ip-172-31-25-177:~/.kube$ cat config 

```

- We can see that we have client-certificate-data and client-key-data fields in kube config file. We will give location of our crt and key files here which are stored on master, and change name to client-certificate and client-key

- We have updated name and context to user1 and path to keys along with . For user1, ns will be development, for user2 ns will be production

- We will paste both config file vi USER1-CONFIG, and run `export KUBECONFIG=/root/USER1-CONFIG`

- Now if you do kubectl get pods, you will get a forbidden error. This is because user1 does not have access to resource of cluster. for this we need to crate role and role bindings so user1 is able to access the resources.

- Do same for user 2, vi USER2-CONFIG, and run `export KUBECONFIG=/root/USER2-CONFIG`

- We get same error for user2 as well.

