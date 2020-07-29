# Playing with pod assignment

The examples described below where took from the [official k8s docs about this topic](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)

## Environment setup
This repo relies on [kind](https://kind.sigs.k8s.io/) to spin up a local k8s cluster. To download it
just run `make setup`


To start the cluster run `make start`. This will spin up a cluster with 1 master node and 9 worker
nodes which has the same labels than an EC2 instance acting as a worker node would have.
This will help us to play around with different affinity constraints without incurring into any
costs.


If you're using a unix-like PC you may want to use tmux to have a more interactive view of how the
pods are being scheduled


## Pod assignment
We'll go through different assignment methods

### Node name
`nodeName` is the simplest way to assign a pod to a specific node and takes precedence over all
other methods.
When this setting is present in the `PodSpec` section the scheduler will ignore this pod and let
the kubelet run it into the specified node.
If the node doesn't have enough resources to accommodate the pod the you'll be notified of such
situation in the pod description.

For further details about this field please run `kubectl explain pod.spec.nodeName`.


Run `kubectl apply -f node-name.yaml` and verify the pod is successfully scheduled.

NOTE: This method is not recommended for production workloads.

### Node selector
`nodeSelector` is the simplest and recommended way to assign a pod to a set nodes.
The scheduler will allocate the pod based on a map of labels that the node **must** have.
Please note that this is an **AND** operation, so if none of the available node has the required
labels the pod will remain in a `Pending` state.
Running a `kubectl describe` for the pod will provide deeper details about the issue.

For further details about this field please run `kubectl explain pod.spec.nodeSelector`

Run `kubectl apply -f node-selector.yaml` and verify the pod is successfully scheduled.

In order to get the nodes labels run `kubectl get nodes --show-labels`. You'll see an ouput like
this:
```bash
NAME                 STATUS   ROLES    AGE    VERSION   LABELS
kind-control-plane   Ready    master   103s   v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-control-plane,kubernetes.io/os=linux,node-role.kubernetes.io/master=
kind-worker          Ready    <none>   68s    v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t3.medium,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2a,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker,kubernetes.io/os=linux
kind-worker2         Ready    <none>   68s    v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=c5.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2a,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker2,kubernetes.io/os=linux
kind-worker3         Ready    <none>   68s    v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=r5.2xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2a,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker3,kubernetes.io/os=linux
kind-worker4         Ready    <none>   68s    v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=r5.2xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2a,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker4,kubernetes.io/os=linux
kind-worker5         Ready    <none>   69s    v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t3.medium,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2b,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker5,kubernetes.io/os=linux
kind-worker6         Ready    <none>   69s    v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=c5.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2b,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker6,kubernetes.io/os=linux
kind-worker7         Ready    <none>   68s    v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t3.medium,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2c,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker7,kubernetes.io/os=linux
kind-worker8         Ready    <none>   69s    v1.18.2   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=c5.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2c,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker8,kubernetes.io/os=linux
```
To get a more user-friendly view of a particular label run `kubectl get nodes -L <key>`. You'll get
an output like this:
```bash
ubuntu@ubuntu:~$ kubectl get nodes -L beta.kubernetes.io/instance-type
NAME                 STATUS   ROLES    AGE     VERSION   INSTANCE-TYPE
kind-control-plane   Ready    master   2m46s   v1.18.2
kind-worker          Ready    <none>   2m11s   v1.18.2   t3.medium
kind-worker2         Ready    <none>   2m11s   v1.18.2   c5.xlarge
kind-worker3         Ready    <none>   2m11s   v1.18.2   r5.2xlarge
kind-worker4         Ready    <none>   2m11s   v1.18.2   r5.2xlarge
kind-worker5         Ready    <none>   2m12s   v1.18.2   t3.medium
kind-worker6         Ready    <none>   2m12s   v1.18.2   c5.xlarge
kind-worker7         Ready    <none>   2m11s   v1.18.2   t3.medium
kind-worker8         Ready    <none>   2m12s   v1.18.2   c5.xlarge
```

### Affinity/AntiAffinity

#### Node Affinity

#### Pod Affinity

### Taints/Tolerations
