#!/usr/bin/env bash
set -uo pipefail
# Podziękowania dla https://stackoverflow.com/a/246128
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASEDIR="$DIR/.."
echo "Deploy Jaeger"
echo "Na podstawie https://github.com/jaegertracing/jaeger-operator"

kubectl create namespace observability
kubectl create -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/crds/jaegertracing.io_jaegers_crd.yaml
kubectl create -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/service_account.yaml
kubectl create -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role.yaml
kubectl create -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role_binding.yaml
kubectl create -n observability -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/operator.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/cluster_role.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/cluster_role_binding.yaml

echo "Edytuj wdrożenie i usuń wartość ze zmiennej WATCH_NAMESPACE"
echo -n "(naciśnij Enter, aby edytować plik) "
#shellcheck disable=SC2034
read -r scratch
kubectl -n observability edit deployment/jaeger-operator
kubectl create -n observability -f "$BASEDIR/jaeger.yaml"

