#!/usr/bin/env bash
set -uo pipefail
echo "Wdrożenie kontrolera wejściowego NGINX"
namespace=${1:-default}
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm ls -n "$namespace" | grep "^nginx-ingress"  \
    || helm install -n "$namespace" nginx-ingress stable/nginx-ingress 
