# Playing with pod assignment

The examples described below where took from the [official k8s docs about this topic](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)

## Environment setup
This repo relies on [kind](https://kind.sigs.k8s.io/) to spin up a local k8s cluster. To download it just run `make setup`

To start the cluster run `make start`. This will spin up a cluster with 1 master node and 9 worker nodes which has the same labels than an EC2 instance acting as a worker node would have.
This will help us to play around with different affinity constraints without incurring into any costs.

## Pod assingment
We'll go through different assingment methods

### Node name
`nodeName` is the simplest way to assign a pod to a specific node. Just add the node name under the `PodSpec` section
This will force the scheduller to schedule the pod onto a specific node assuming it fits the resources requirements.
For further details about this field please run `kubectl explain pod.spec.nodeName`

Run `kubectl apply -f node-name.yaml` and verify the pod is successfully scheduled.


## Node selector
`nodeSelector` is the simplest way to assign a pod to a node. Just add the node name in the `PodSpec` section.
If the
For further details about this field please run `kubectl explain pod.spec.nodeSelector`
