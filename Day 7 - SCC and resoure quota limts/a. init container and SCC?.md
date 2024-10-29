
# Side car Containers

Sidecar containers are the secondary containers that run along with the main application container within the same Pod. These containers are used to enhance or to extend the functionality of the primary app container by providing additional services, or functionality such as logging, monitoring, security, or data synchronization, without directly altering the primary application code.

# Differences from application containers

Sidecar containers run alongside app containers in the same pod. However, they do not execute the primary application logic; instead, they provide supporting functionality to the main application.

Sidecar containers have their own independent lifecycles. They can be started, stopped, and restarted independently of app containers. This means you can update, scale, or maintain sidecar containers without affecting the primary application.

Sidecar containers share the same network and storage namespaces with the primary container. This co-location allows them to interact closely and share resources.

# What is the difference between an init container and a sidecar?

Both sidecar containers and init containers in Kubernetes are used within a Pod to extend or enhance the primary containers’ functionality. However, they serve different purposes and have different characteristics.

A sidecar container provides supplementary services, functionalities, or features to support the primary containers or the application as a whole. An init container, on the other hand, runs and completes its execution before the primary containers start running. It performs initialization or setup tasks required by the primary containers or the Pod, such as downloading or preparing data, configuring resources, or waiting for specific conditions.


### Types of Containers in Kubernetes

1. **Init Containers**
   - *Purpose*: Run one-time setup tasks before the main application container starts, such as initializing configuration files, setting up dependencies, or waiting for certain conditions to be met.
   - *Behavior*: Init containers run sequentially, each starting only after the previous one has completed successfully.
   - **Note**: Init containers are not a type of sidecar; they serve a distinct role in preparing the environment for the main container.

2. **Sidecar Containers**
   - *Purpose*: Run alongside the main container in a pod, providing additional functionality to support the primary application.
   - *Types*:
      - **Adapter**: Often used to transform or enhance the main application’s data. For example, logging or monitoring sidecars that collect and process logs from the main application.
      - **Ambassador**: Acts as a proxy, managing external communications on behalf of the main container. This can include handling service discovery or network traffic routing.



### Init and Sidecar Containers in a Pod

In a Kubernetes Pod, multiple containers can work together to support the main application container. We typically have **one main container** and can add **multiple Sidecar Containers (SCC)** to handle specific supporting tasks. These sidecar containers act as helpers for the main container, performing various background functions.

#### Example Scenario

Let’s say we have a main application container in a Pod that depends on a database and a specific service (`myService`) to operate correctly. In this setup:

- **Sidecar Container 1** checks whether the database endpoints are accessible and healthy.  
- **Sidecar Container 2** ensures that `myService` is deployed and reachable.  

If either the database or `myService` is not available, the sidecars can prevent the main container from running by, for example, holding off on readiness checks or handling necessary retries.

This design allows us to add multiple sidecars, each handling distinct tasks to support the main application. We can scale the number of sidecar containers as needed, each addressing a different requirement.

#### Note

This approach assumes sidecar containers are running in parallel with the main container. For tasks that must be completed **before** the main container starts, we use **Init Containers** instead of sidecars. 

- Imp - Init containers run one after another and complete all their tasks before the main container begins execution.
- Adapter containers run parallely with the main container

