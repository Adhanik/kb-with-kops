
To expose a application created using Deployment, we make use of services.

## Cluster IP -

Cluster IP is generally used for internal communication, and this communication is responsible for the ms talking to each other. Cluster ip routes traffic and request to diff pods based on Round robin sense.

- Drawback - Cluster IP cannot expose your application to the outside world.

## Node Port - 

What happens when we create a Node port service?

1. **ClusterIP is Created by Default**:
   - **By default**, every service in Kubernetes is assigned a `ClusterIP`. This is an internal IP address that is only accessible within the cluster. It allows communication between services and pods inside the cluster but cannot be accessed externally.
   - When you create a **NodePort** service, a **ClusterIP** is still created and used for internal routing. The NodePort is essentially an extension of the ClusterIP, allowing external access.

2. **NodePort Service for External Access**:
   - A **NodePort** service exposes your application to the outside world by opening a specific port (typically in the range 30000–32767) on each node of your Kubernetes cluster.
   - This port (NodePort) is accessible from outside the cluster. So, when you access `<public-ip-of-node>:<NodePort>`, Kubernetes forwards the request to the service's **ClusterIP**.

3. **How Traffic is Routed**:
   - When a request hits the **NodePort** (e.g., `30000`), Kubernetes routes this request to the internal **ClusterIP** of the service.
   - The **ClusterIP** then load balances and forwards the request to one of the pods (e.g., `POD1`, `POD2`, `POD3`) based on the service's selector.

### Request Flow:
1. **External request** arrives at the **NodePort** (`<node-public-ip>:<nodeport>`, e.g., `EC2_IP:30000`).
2. The **NodePort** forwards the request to the **ClusterIP** of the service (which routes traffic internally within the cluster).
3. The **ClusterIP** load-balances the request to one of the **pods** (`POD1`, `POD2`, `POD3`) by using iptables.

### Final Traffic Flow:
```
Request from Internet --> NodePort (e.g., 30000) --> ClusterIP --> Pod (POD1, POD2, POD3)
```

This allows your service to be accessible both within the cluster (via the ClusterIP) and from outside the cluster (via the NodePort).

### Example:
Let's say your NodePort is `30000`, and your node's public IP is `54.234.XXX.XXX` (EC2 instance). Users can access your application at `54.234.XXX.XXX:30000`. When this request hits `NodePort`, it forwards the request to the service's ClusterIP, which then routes it to one of your pods (which are running your application).

### Summary:
- Yes, the **ClusterIP** is created by default with every service.
- The **NodePort** allows external access to the service, while **ClusterIP** handles internal routing.
- Traffic goes from **NodePort** → **ClusterIP** → **Pods**.


# Load balancer

Node port is not a use case for prod, it is generally used for dev env. Load balancer is used for prod env, because we cannot give <node-public-ip>:<nodeport> to users for accessing the app. We need to provide proper DNS, which is possible with L.B. We will be making use of route 53 to attach DNS.

# External Name

Consider you want to integrate a external database with your KB application, the db consist of product, customer feedback, reviews etc.

An **ExternalName** service in Kubernetes is a special type of service that allows you to route traffic to an **external resource** (such as an external database or API) that is **outside** of your Kubernetes cluster. It maps a service name to a **CNAME DNS record**, which means Kubernetes does not manage pods for this service—it only provides DNS resolution.

### How It Works:
1. You create an **ExternalName** service in Kubernetes.
2. This service will not point to any pods within the cluster. Instead, it will map to an external DNS hostname (e.g., a database, API, or other service hosted outside of Kubernetes).
3. Kubernetes will act as a DNS resolver, translating requests to the external service’s hostname.

### Use Case (Example):
Imagine you have an external database hosted outside of your Kubernetes cluster, say on a remote server, with the URL `db.external.com`. You can use an **ExternalName** service to make this external database accessible via a service inside your cluster, like `dbservice.mynamespace.svc.cluster.local`.

Now, all of your internal applications can access `dbservice` inside the cluster without needing to know the actual external hostname (`db.external.com`). If the external database changes its URL, you only need to update the **ExternalName** service in Kubernetes to reflect the new URL, and all 20 applications that rely on the service will still work without any changes.

### Example of ExternalName Service:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: db.external.com
```

In this example:
- The service is called `external-db`.
- It is an **ExternalName** service type.
- Any request to `external-db` will be resolved to the external DNS name `db.external.com`.

### Benefits:
- **Centralized Management**: If the external resource (like a database) changes its hostname, you only need to update the `externalName` field in your Kubernetes service. You don’t have to update all the individual applications that use it.
- **Consistency**: Your applications continue using the same internal service name (e.g., `external-db`), regardless of where the external resource is hosted.

### Example Use Case Scenario:
You have 20 different applications in your Kubernetes cluster that need to access a shared external database. Instead of configuring each application to directly use the external database’s URL (`db.external.com`), you create an **ExternalName** service (like `dbservice`). If the external database is moved to a new server or the URL changes, you only need to update the `externalName` service, and all the applications continue functioning without code changes.

### Traffic Flow:
```
Application in Cluster → ExternalName Service (dbservice) → DNS Lookup → db.external.com (external DB server)
```

### Summary:
- An **ExternalName** service lets Kubernetes manage external DNS names.
- It's useful when you want to decouple the external resource's hostname from your applications.
- Any hostname or URL changes for the external resource only need to be reflected in the **ExternalName** service, not in individual apps.
