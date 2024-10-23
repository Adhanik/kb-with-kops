

# Agenda

- Ingress
- We will be generating TLS Keys (.cert and .key)
- Keeping docker images in a private registry, then pass docker creds as secret so kubelet is able to pull the docker images from private docker hub repo.


# Ingress

For external env, we have NodePort and Load balancer, and L.B is manily used for external routing to app. Then why is ingress used?

Ingress is used because it manages external access to multiple services in a Kubernetes cluster, offering more advanced routing, SSL termination, and path-based rules compared to NodePort or LoadBalancer.

# Overview of SSL Termination and Ingress

Suppose you have a 3 tier web application with USER, ORDER and PAYMENT ms, and a user wants to access it from web. Below are the problems faced without ingress 

- We want to confirm that user is a genuine and not a hacker, for that we enable SSL termination on all three ms, which needs to be done manually. 
- For each USER, ORDER and PAYMENT ms to talk to each other, we need to configure a Load balancer for each ms. As your business grows, you create more ms, enable SSL termination on each, create Load balancer for proper communicaton, and this causes a lot of management overhead.

To avoid all problems, we make use of INGRESS.

    When we create a Ingerss, it creates a NLB. This NLB is associated with a DNS name, which we will be integrating NLB to our DNS name (clouddhanikxyz.com)

    Once request is sent to NLB, it then goes towards ingress controller. 

    The request is then forwarded to ingress resource. Based on request, Ingress resource routes it to appropriate service

This flow one can read in detail in - INGRESS TRAFFIC EXPLAINED

