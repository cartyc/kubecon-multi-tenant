#!/bin/bash

kind create cluster --name master
kubectl apply -k $(pwd)/install/
kubectl delete -n flux-system secret flux-git-deploy
kubectl create secret generic flux-git-deploy --from-file=identity=/Users/work/.ssh/fluxcd -n flux-system
echo "/n"


# # QA
# echo "Installing QA Cluster"
# kind create cluster --name qa
# echo "Setting QA Flux Agent"
# kubectl apply -k ../install/ --dry-run -o yaml | sed 's/master/qa/' | kubectl apply -f -
# kubectl delete -n flux-system secret flux-git-deploy
# kubectl create secret generic flux-git-deploy --from-file=identity=/Users/work/.ssh/fluxcd -n flux-system
# echo "/n"

# Dev
echo "Installing Dev Cluster"
kind create cluster --name dev
echo "Setting Dev Flux Agent"
kubectl apply -k $(pwd)/install/ --dry-run -o yaml | sed 's/master/dev/'  | kubectl apply -f -
kubectl delete -n flux-system secret flux-git-deploy
kubectl create secret generic flux-git-deploy --from-file=identity=/Users/work/.ssh/fluxcd -n flux-system

kubectx


## Useful Commands

# GateKeeper 
# {
#     kubectl delete -n gatekeeper secret flux-git-deploy
#     kubectl create secret generic flux-git-deploy --from-file=identity=/Users/work/.ssh/gatekeeper -n gatekeeper
# }
