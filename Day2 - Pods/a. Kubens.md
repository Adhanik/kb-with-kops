
### Kubens

We will be installing kubens in our management-server node. Kubens is a tool that helps to switch between Kubernetes namespaces (and configure them for kubectl) easily.

# For linux distribution

We will go with package - kubens_v0.9.5_linux_x86_64.tar.gz
```
cd /usr/local/bin
wget https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubens_v0.9.5_linux_x86_64.tar.gz

ls -al
tar zxvf kubens_v0.9.5_linux_x86_64.tar.gz (extract package)
rm -rf kubens_v0.9.5_linux_x86_64.tar.gz (delete the package)
ls -al
kubens (gives u default ns)
kubens <ns> (takes u to specific ns)
```

## Create alias in KB

```
alias ku=kubectl
alias kg="k get"
alias kgpo="kg po" or alias kgpo="kg pods"
alias kgno="kg no" or alias kgno="kg nodes"
alias kd="k describe"
```