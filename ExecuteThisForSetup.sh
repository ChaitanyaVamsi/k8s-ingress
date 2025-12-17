#!/bin/bash

# Step 1: Associate IAM OIDC provider with the EKS cluster
eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster sampleapp \
    --approve

# Step 2: Download the IAM policy JSON for AWS Load Balancer Controller
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.16.0/docs/install/iam_policy.json

# Step 3: Create the IAM policy
aws iam create-policy \
 --policy-name AWSLoadBalancerControllerIAMPolicy \
 --policy-document file://iam-policy.json

# Step 4: Create the IAM service account for AWS Load Balancer Controller
eksctl create iamserviceaccount \
--cluster=sampleapp \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::471112667143:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--region us-east-1 \
--approve

# Step 5: Download Helm installation script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4

# Step 6: Make the Helm installation script executable
chmod 700 get_helm.sh

# Step 7: Run the Helm installation script
./get_helm.sh

# Step 8: Add the EKS Helm chart repository
helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=sampleapp --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

# Step 9: Get pods in the kube-system namespace to verify everything is working
kubectl get pods -n kube-system
