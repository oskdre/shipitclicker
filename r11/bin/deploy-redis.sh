#!/usr/bin/env bash
set -uo pipefail
echo "Deploy Redis"
echo "Na podstawie https://bitnami.com/stack/redis/helm"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm ls | grep ^redis \
    || helm install bitnami/redis
