

We are going to create 2 ns, dev and prod

- We will create two users - user1 and user2. We cannot directly go and create users. We will be making use of ca.crt and ca.key for both users. With help of these keys, we will create both used in dev and prod ns.

- Once we have created the users, we will create configs. We will call both keys ca.crt and ca.key under /root/file for authentication btw multiple servers. we will also make use of ns in config file

- Next we will define Roles. roles consist of rule where we can give access on api level and for resources like pod, deployments, nodes, repolica sets, while mkaing use of verbs (get, create, update delete etc) for both users

- Lastly we will create a admin user which has full access to whole cluster. so user1 from dev ns cannot see resources in prod ns, and will get forbidden user. Admin user, on other hand, is able to access both ns.

- Since we will have a lot of config files, we will merge all of them and call them using kubens and kubectx.

- Using Portainer, we will be able to see all the resources.

We have a master node, which is control plane, and rest 3 are worker nodes.. We dont log in any of these 4 nodes, we manage the cluster only from management server.


## Logging to master node

for RBAC, we will be logging for first time in our master node(control plane) to generate the crt keys.



