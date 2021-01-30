# Playing with pod scheduling

The examples described below are based on the [official k8s docs](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
about this topic

This repo aims to help us to play around with different pod scheduling approaches without incurring
into any costs.

If you think this repo can be enhanced in any way, please fill free to
[create an issue](https://github.com/lucas-giaco/k8s-pod-scheduling/issues/new/choose) or
[submit a PR](https://github.com/lucas-giaco/k8s-pod-scheduling/compare)

## Environment setup

This repo relies on [kind](https://kind.sigs.k8s.io/) to spin up a local k8s cluster.

To start the cluster run `kind create cluster --config config.yaml`. This will spin up a cluster
with 1 master node and 9 worker nodes which has the same labels than an EC2 instance used as a
worker node.

## Pod assignment

Let's go through the different scheduling methods

### Node name

`nodeName` is the simplest way to assign a pod to a specific node and takes precedence over all
other methods.
When this setting is present in the `PodSpec` section the scheduler will ignore this pod and let
the kubelet run it into the specified node.
If the node doesn't have enough resources to accommodate the pod then you'll be notified of such
situation in the pod description.

Run `kubectl apply -f node-name.yaml` to create a `Deployment` that has a `nodeName` constraint. The
pod will be placed in the node `kind-worker`. If you try to scale the deployment by running the
`kubectl scale deployment node-name --replicas=<any-number>` you'll see that all the pods are being
scheduled in the same node.

NOTE: This method is **not** recommended for production workloads.

### Node selector

`nodeSelector` is the simplest recommended way to assign a pod to a set of nodes.
The scheduler will allocate the pod based on a map of labels that the node **must** have.
Please note that this is an **AND** operation, so if none of the available node has all the required
labels the pod will remain in a `Pending` state.
Running a `kubectl describe` for the pod will provide deeper details about the issue.

Run `kubectl apply -f node-selector.yaml` to create a `Deployment` that has a `nodeSelector`
constraint. Here, we're telling the scheduler to place the pods in nodes that have the label
`beta.kubernetes.io/instance-type` with the value `r5.2xlarge`. The only nodes that meet this
condition are the nodes `kind-worker3` and `kind-worker4`.

If we run `kubectl scale deployment node-selector --replicas=<any-number>` to create
more pods, we'll see that all of them are being scheduled in the nodes `kind-worker3` and
`kind-worker4`.

In order to get the nodes labels run `kubectl get nodes --show-labels`. You'll see an output like
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

To get a more user-friendly view of a particular node label we'll have to run
`kubectl get nodes -L <label-key>`. This will print the label as a new column and we'll get an
output like this:

```bash
❯ kubectl get nodes -L beta.kubernetes.io/instance-type
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

When using `nodeSelector` is not enough for our requirements, the affinity/anti-affinity feature
comes to help expanding the constraints we can express. These are the key enhancements that offers:

* More expressive language: Allows matching rules besides exact match
* Soft rules (a.k.a preferred): Allows declaring rules that are applied in a best-effort basis,
preventing unscheduled (pending) pods.
* Constraints against other pods: Allows rules about which pods can or cannot be co-located in a
node

This feature consist on two types of affinity, node-affinity and pod-affinity. Let's take a look
to both of them.

#### Node Affinity

Conceptually node affinity is similar to `nodeSelector` in the way that declares which pods can be
located on each node based on node labels but allowing a more expressive syntax using operators
like `In`, `NotIn`, `Exists`, `DoesNotExist`. `Gt`, and `Lt`.

We have to types of affinity:

* `requiredDuringSchedulingIgnoredDuringExecution`: scheduler will **ensure** conditions listed
under this spec are meet for the pod to be scheduled
* `preferredDuringSchedulingIgnoredDuringExecution`: scheduler will **try** to meet the conditions
listed under this spec but if it's not possible will allow to run the pod elsewhere.

Run `kubectl apply -f node-affinity.yaml` to create a `Deployment` which has both types of node
affinity. Looking at the pod spec we'll see that we have forced the scheduler to place the pod in
one of the regions `us-west-2b` **or** `us-west-2c`, and if it's possible to place it a `t3.large`
instance. As this last condition can't be met the scheduler will place the pod in any other
available instance.

#### Pod Affinity
WIP

#### Pod Anti Affinity
WIP

### Taints/Tolerations
WIP
