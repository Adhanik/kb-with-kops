
## Prod to QA on a specific port

In this section, we will be configuring Network Policies in such a way that pods in prod  ns will be able to access pods in qa ns on a specific port - 8888.

- Since we will be sending traffic from prod, it will be a egress traffic, we have to write network policy with prod ns.

- Also the QA should allow Egress traffic from prod, and internally it should accept Ingress traffic, so we will write a Network policy which would allow Ingress traffic from prod to QA.

- Refer g.1 prod to qa.yaml