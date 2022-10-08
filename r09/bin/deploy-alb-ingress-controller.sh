#!/usr/bin/env bash
set -euo pipefail
echo "Wdróż kontroler ALB Ingress"
echo "Na podstawie https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html"

CLUSTER=${1:?You must specify the name of the EKS cluster.}
REGION=${2:-us-east-2}
VERSION=${3:-v1.1.4}

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
IAM_ROLE_NAME="eks-alb-ingress-controller"
IAM_POLICY_NAME="ALBIngressControllerIAMPolicy"
EKS_CONTEXT="arn:aws:eks:$REGION:$AWS_ACCOUNT_ID:cluster/$CLUSTER"
SLEEP_DURATION=10

echo "Przełączenie kontekstu do $EKS_CONTEXT"
kubectl config use-context "$EKS_CONTEXT"
echo "Powiązanie dostawcy IAM OIDC"
set +e
eksctl utils associate-iam-oidc-provider \
    --region "$REGION" \
    --cluster "$CLUSTER" \
    --approve
set -e
echo -n "Wyszukiwanie dostawcy OIDC: "
OIDC_PROVIDER=$(aws eks describe-cluster \
    --region "$REGION" \
    --name "$CLUSTER" \
    --query "cluster.identity.oidc.issuer" \
    --output text \
    | sed -e "s/^https:\/\///")
echo $OIDC_PROVIDER
echo "Uzyskiwanie roli IAM"
AWS_IAM_ROLE=$(aws iam get-role \
    --role-name "$IAM_ROLE_NAME" \
    --query Role.Arn \
    --output text)
if [[ -z "$AWS_IAM_ROLE" ]]; then
    echo "Tworzenie roli IAM"

    TMPFILE=$(mktemp)
    cat > "$TMPFILE" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:kube-system:alb-ingress-controller"
        }
      }
    }
  ]
}
EOF
    aws iam create-role \
        --role-name "$IAM_ROLE_NAME" \
        --assume-role-policy-document "file://$TMPFILE" \
        --description "Kontroler EKS ALB Ingress"
fi
#shellcheck disable=SC2016
IAM_POLICY_ARN=$(aws iam list-policies \
    --query 'Policies[?PolicyName==`ALBIngressControllerIAMPolicy`].Arn' \
    --output text)
if [[ -z "$IAM_POLICY_ARN" ]]; then
    echo "Tworzenie polisy IAM $IAM_POLICY_NAME"
    IAM_POLICY_ARN=$(aws iam create-policy \
        --policy-name "$IAM_POLICY_NAME" \
        --policy-document "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/$VERSION/docs/examples/iam-policy.json" \
        --query 'Policy.Arn' \
        --output text)
fi
echo "Przypisywanie polisy IAM"
aws iam attach-role-policy \
    --role-name "$IAM_ROLE_NAME" \
    --policy-arn="$IAM_POLICY_ARN"
echo "Stosowanie konfiguracjij roli RBAC"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/$VERSION/docs/examples/rbac-role.yaml"
echo "Stosowanie konfiguracji kontrolera wejściowego"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/$VERSION/docs/examples/alb-ingress-controller.yaml"
echo "Dodawanie adnotacji do konta usługi alb-ingress-controller z rolą IAM"
kubectl annotate serviceaccount \
    --overwrite \
    -n kube-system \
    alb-ingress-controller \
    "eks.amazonaws.com/role-arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/$IAM_ROLE_NAME"
echo "Getting VPC ID"
AWS_VPC_ID=$(aws eks describe-cluster \
    --name "$CLUSTER" \
    --region "$REGION" \
    --query 'cluster.resourcesVpcConfig.vpcId' \
    --output text)
cat <<EOF
Dokumentacja AWS dotycząca konfigurowania kontrolera ALB Ingress podaje:
    
    Dodaj wiersz dla nazwy klastra po wierszu --ingress-class = alb.
    Jeśli używasz kontrolera ALB Ingress w Fargate, musisz także dodać 
    wiersze dla identyfikatora VPC i nazwy regionu AWS swojego klastra.
    Po dodaniu odpowiednich wierszy zapisz i zamknij plik.    

Przykład:
 spec:
      containers:
      - args:
        - --ingress-class=alb
        - --cluster-name=$CLUSTER
        - --aws-vpc-id=$AWS_VPC_ID
        - --aws-region=$REGION

Naciśnij klawisz Enter, aby uruchomić to polecenie i edytować plik:

    kubectl edit deployment.apps/alb-ingress-controller -n kube-system

EOF
#shellcheck disable=SC2034
read -r x
kubectl edit deployment.apps/alb-ingress-controller -n kube-system
echo "Oczekiwanie $SLEEP_DURATION na aktywację kontrolera wejściowego"
sleep $SLEEP_DURATION
echo "Uruchomienie polecenia: kubectl get pods -n kube-system"
kubectl get pods -n kube-system
