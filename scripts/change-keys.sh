#!/bin/bash

# GateKeeper 
{
    export NAMESPACE=gatekeeper-system
    kubectl delete secret flux-git-deploy -n $NAMESPACE
    kubectl create secret generic flux-git-deploy --from-file=identity=$HOME/.ssh/gatekeeper -n $NAMESPACE
    kubectl rollout restart deploy flux -n $NAMESPACE
}

# Falco 
{
    export NAMESPACE=falco-system
    kubectl delete secret flux-git-deploy -n $NAMESPACE
    kubectl create secret generic flux-git-deploy --from-file=identity=$HOME/.ssh/falco -n $NAMESPACE
}

# Demo App 
{
    export NAMESPACE=demo-app
    kubectl delete secret flux-git-deploy -n $NAMESPACE
    kubectl create secret generic flux-git-deploy --from-file=identity=$HOME/.ssh/demo-app -n $NAMESPACE
}

# Linkerd
{
    export NAMESPACE=linkerd
    kubectl delete secret flux-git-deploy -n $NAMESPACE
    kubectl create secret generic flux-git-deploy --from-file=identity=$HOME/.ssh/linkerd -n $NAMESPACE

    kubectl create secret tls \
    linkerd-trust-anchor \
    --cert=./scripts/ca.crt \
    --key=./scripts/ca.key \
    --namespace=linkerd
}