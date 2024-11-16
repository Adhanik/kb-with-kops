
# Secrets

A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in a container image. Using a Secret means that you don't need to include confidential data in your application code.

Because Secrets can be created independently of the Pods that use them, there is less risk of the Secret (and its data) being exposed during the workflow of creating, viewing, and editing Pods. Kubernetes, and applications that run in your cluster, can also take additional precautions with Secrets, such as avoiding writing sensitive data to nonvolatile storage.

Secrets are similar to ConfigMaps but are specifically intended to hold confidential data.

### Types

- TLS Secrets
- Registry Secrets
- Generic secrets - We can pass secrets as env variables or Volume mounts. The secrets are mounted to a paritcular file called .aws/credentials in root location


## 1.  TLS Secrets

These have been discussed in Ingress part already. Refer to the ingress section.

## 2. Registry Secrets

Create a Secret by providing Docker credentials on the command line


kubectl create secret docker-registry docker-pwd \
--docker-server=docker.io --docker-username=NAME \
--docker-password=token \
--docker-email=workwithnik@gmail.com

In real time not even a single image will be in public repo. Everything is kept in a private repo. We create secret using above command, and then in deployment yaml make use of  `imagePullSecrets` for KB to interact and download docker image from private repo.


## 3. Generic Secrets - Pass as env variables

Here we are passing secrets as it is. In the method discussed below this, we will first encrypt our secrets, and then pass them as env variables

--from-literal helps create secrets as it is
kubectl create secret generic backend-user --from-literal=backend-username='backend-admin'
kubectl create secret generic backend-user-pwd --from-literal=backend-password='backend-password'


We will use the above created secrets in our pod
```

apiVersion: v1
kind: Pod
metadata:
  name: env-single-secret
spec:
  containers:
  - name: envars-test-container
    image: nginx
    env:
    - name: SECRET_USERNAME
      valueFrom:
        secretKeyRef:
          name: backend-user
          key: backend-username
    - name: SECRET_PASSWORD
      valueFrom:
        secretKeyRef:
          name: backend-user-pwd
          key: backend-password

```


### Explanation:

- **env**: This section defines environment variables for the container.
- **valueFrom**: This is used to specify that the value for the environment variable should come from a secret.
- **secretKeyRef**: This points to a specific secret (`backend-user and backend-user-pwd`) and key (`backend-username` or `backend-password`).

- **`SECRET_USERNAME`**: This environment variable is populated from the `backend-user` secret, using the `backend-username` key.
- **`SECRET_PASSWORD`**: This environment variable is populated from the `backend-user-pwd` secret, using the `backend-password` key.


This way, your Pod will have both the `backend-username` and `backend-password` environment variables available in the container, which you can then use in your application.


1. **Secrets Created**:

   First, you will have two secrets:
   - `backend-user` (for the `backend-username`).
   - `backend-user-pwd` (for the `backend-password`).

   You can verify that they were created successfully using:

   ```bash
   kubectl get secrets backend-user backend-user-pwd -o yaml
   ```

O/P

```
 kubectl get secrets backend-user backend-user-pwd -o yaml
apiVersion: v1
items:
- apiVersion: v1
  data:
    backend-username: YmFja2VuZC1hZG1pbg==
  kind: Secret
  metadata:
    creationTimestamp: "2024-11-16T10:45:43Z"
    name: backend-user
    namespace: default
    resourceVersion: "3323"
    uid: 5b362475-eeb5-4edf-ba94-0941015c0e84
  type: Opaque
- apiVersion: v1
  data:
    backend-password: YmFja2VuZC1wYXNzd29yZA==
  kind: Secret
  metadata:
    creationTimestamp: "2024-11-16T10:45:50Z"
    name: backend-user-pwd
    namespace: default
    resourceVersion: "3348"
    uid: e408141d-c0a5-46e1-9bde-44a8f94c5a6f
  type: Opaque
kind: List
metadata:
  resourceVersion: ""

```




### Verification Steps:

1. **Ensure both secrets are available**:

   Run the following to make sure both secrets were created correctly:

   ```bash
   kubectl get secrets backend-user backend-user-pwd
   ```

   You should see something like this:

   ```
   kubectl get secrets
    NAME               TYPE     DATA   AGE
    backend-user       Opaque   1      4m57s
    backend-user-pwd   Opaque   1      4m50s

   ```


## 4. Generic Secrets - Pass secrets in encrypted form as env variable

echo -n AKAKSKSKKSSASK | base64
echo -n QOEKS99A8CMAM  | base 64

After encryption, we get the below values which we can pass as env variables.

QUtBS1NLU0tLU1NBU0s=
UU9FS1M5OUE4Q01BTQ==




## 5. Volume mounts

Another way to pass secrets is using volume mounts. Here secrets will be mounted to .aws/credentials which is in root location. Inside the container, you will not be able to access them.