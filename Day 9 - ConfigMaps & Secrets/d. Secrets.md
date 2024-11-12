
# Secrets

A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in a container image. Using a Secret means that you don't need to include confidential data in your application code.

Because Secrets can be created independently of the Pods that use them, there is less risk of the Secret (and its data) being exposed during the workflow of creating, viewing, and editing Pods. Kubernetes, and applications that run in your cluster, can also take additional precautions with Secrets, such as avoiding writing sensitive data to nonvolatile storage.

Secrets are similar to ConfigMaps but are specifically intended to hold confidential data.

# Types

- TLS Secrets
- Registry Secrets
- Generic secrets - We can pass secrets as env variables or Volume mounts. The secrets are mounted to a paritcular file called .aws/credentials in root location


Create a Secret by providing Docker credentials on the command line


kubectl create secret docker-registry docker-pwd \
--docker-server=docker.io --docker-username=NAME \
--docker-password=token \
--docker-email=workwithnik@gmail.com

In real time not even a single image will be in public repo. Everything is kept in a private repo. We create secret using above command, and then in yaml make use of  `imagePullSecrets`


## TLS secrets have already been covered during Ingress
