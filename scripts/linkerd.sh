#!/bin/bash

kubectl create namespace cert-manager

kubectl apply --validate=false --wait -f https://github.com/jetstack/cert-manager/releases/download/v0.13.1/cert-manager.yaml 

kubectl create namespace linkerd

step certificate create identity.linkerd.cluster.local ca.crt ca.key \
  --profile root-ca --no-password --insecure &&
  kubectl create secret tls \
   linkerd-trust-anchor \
   --cert=ca.crt \
   --key=ca.key \
   --namespace=linkerd

sleep 60s

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: linkerd-trust-anchor
  namespace: linkerd
spec:
  ca:
    secretName: linkerd-trust-anchor
EOF

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: linkerd-identity-issuer
  namespace: linkerd
spec:
  secretName: linkerd-identity-issuer
  duration: 24h
  renewBefore: 1h
  issuerRef:
    name: linkerd-trust-anchor
    kind: Issuer
  commonName: identity.linkerd.cluster.local
  isCA: true
  keyAlgorithm: ecdsa
  usages:
  - cert sign
  - crl sign
  - server auth
  - client auth
EOF

kubectl get secret linkerd-identity-issuer -o yaml -n linkerd

kubectl get events --field-selector reason=IssuerUpdated -n linkerd

ca=$( cat ca.crt ) 

helm install \
  linkerd2   linkerd/linkerd2 \
  --namespace linkerd \
  --set-file global.identityTrustAnchorsPEM=./ca.crt \
  --set identity.issuer.scheme=kubernetes.io/tls \
  --set installNamespace=false

linkerd check