
# Quest

```

ubuntu@ip-172-31-27-89:~$ kubectl get ns
NAME              STATUS   AGE
default           Active   31m
development       Active   3s
kube-node-lease   Active   31m
kube-public       Active   31m

```
i have these ns, if i do kubectl config set-context --current --namespace=dev - it should give error right, because i dont have dev ns, i have development. but still in output it shows like this 

```

kubectl config set-context --current --namespace=dev
Context "cloudadhanik.xyz" modified.
ubuntu@ip-172-31-27-89:~$ kubectl get pods
No resources found in dev namespace.
```

## Sol

Yes, you’re correct! Since there is no `dev` namespace, the command should technically produce an error. However, Kubernetes does not validate if the namespace exists when you set it as the default for the current context using `kubectl config set-context`. It will accept any namespace name, even if it doesn't exist, which can cause confusion.

Here’s what happens in detail:

1. **Setting a Non-Existent Namespace**:
   - When you run `kubectl config set-context --current --namespace=dev`, Kubernetes updates the context configuration with `dev` as the namespace, without verifying its existence.
   - This change only updates your configuration file (`~/.kube/config`), but it doesn’t check if `dev` is actually a valid namespace in the cluster.

2. **Effect on Commands**:
   - Now, if you run `kubectl get pods` (or any command without specifying `-n <namespace>`), it will attempt to operate in the `dev` namespace. Since `dev` doesn’t exist, you’ll get a message saying “No resources found in dev namespace” or similar, depending on the command.
   - If you were to try creating resources without specifying `-n development`, they would fail since the `dev` namespace doesn’t exist.

3. **Correcting the Namespace**:
   - To avoid this issue, make sure you specify the exact namespace name, `development`, like this:

     ```bash
     kubectl config set-context --current --namespace=development
     ```

4. **Verifying the Change**:
   - You can confirm that the default namespace is now `development` by checking your current context:

     ```bash
     kubectl config view --minify | grep namespace
     ```

So, Kubernetes doesn’t validate namespace existence in this command, which is why it's important to double-check that the specified namespace exists.