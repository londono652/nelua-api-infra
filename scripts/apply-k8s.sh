#!/usr/bin/env bash
# Aplica en el clúster los manifiestos que pertenecen a la plataforma (no a la app):
# namespaces, pool de nodos y el enlace entre los Services y el ALB.
#   uso: bash scripts/apply-k8s.sh
set -euo pipefail

PROJECT="${PROJECT:-nelua-api}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

param() {
  aws ssm get-parameter --name "/$PROJECT/$1" --query Parameter.Value --output text
}

aws eks update-kubeconfig --name "$(param eks/cluster-name)" >/dev/null

kubectl apply -f "$ROOT/k8s/namespaces.yaml"
kubectl apply -f "$ROOT/k8s/nodepool.yaml"

for ENVIRONMENT in staging prod; do
  TARGET_GROUP_ARN=$(param "alb/target-group-arn-$ENVIRONMENT")
  export ENVIRONMENT TARGET_GROUP_ARN
  envsubst '${ENVIRONMENT} ${TARGET_GROUP_ARN}' < "$ROOT/k8s/targetgroupbinding.yaml" | kubectl apply -f -
done

kubectl get nodepools
kubectl get targetgroupbindings -A
