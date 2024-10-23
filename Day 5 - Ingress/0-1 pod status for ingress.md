
why we have 0/1?

kubectl get all -n ingress-nginx
NAME                                            READY   STATUS      RESTARTS   AGE
pod/ingress-nginx-admission-create-85pww        0/1     Completed   0          25m
pod/ingress-nginx-admission-patch-d9nrp         0/1     Completed   1          25m
pod/ingress-nginx-controller-77667b9d9b-vh22j   1/1     Running     0          25m


## sol

In the output of `kubectl get all -n ingress-nginx`, the `0/1` status for the `ingress-nginx-admission-create` and `ingress-nginx-admission-patch` pods indicates that these pods have completed their tasks and are no longer running.

Here’s a breakdown of what's happening:

### 1. **`ingress-nginx-admission-create` Pod (0/1 Completed)**

- **`0/1`**: This indicates that the pod had **1 container**, but the container has finished executing, so it's no longer "ready." The `0` indicates no container is currently running.
- **`Completed`**: The pod has completed its task successfully and doesn't need to stay running. It’s typical for jobs that run once and finish, like setup or patching tasks, to show as `Completed` once done.

### 2. **`ingress-nginx-admission-patch` Pod (0/1 Completed)**

- **`0/1`**: Same as above; the pod had **1 container**, and the container is no longer running because it finished its task.
- **`RESTARTS 1`**: The pod or container restarted once during its operation. This could be due to various reasons like temporary failures, network issues, or resource contention. However, since its current status is `Completed`, the restart issue is likely non-critical.

### 3. **`ingress-nginx-controller` Pod (1/1 Running)**

- **`1/1`**: This indicates that the pod has **1 container**, and that container is running and ready. This is the main `nginx` controller pod responsible for handling ingress traffic, and it stays running continuously to manage ingress resources.

### Why do we have `0/1` for the first two pods?

These pods (`admission-create` and `admission-patch`) are used to set up the admission webhook for the `ingress-nginx` controller. The webhook is necessary for Kubernetes to properly validate and handle ingress resources, including admission control of the ingress objects. Once these setup tasks are completed, the pods exit, and their status remains as `Completed`.

Since they are **job-like** pods, their purpose is just to run once and finish. The `0/1` means they are not running anymore, but they successfully completed their job. This behavior is normal for one-off job tasks in Kubernetes.