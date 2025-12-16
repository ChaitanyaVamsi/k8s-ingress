<!-- https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/

aws eks update-kubeconfig --region us-east-1 --name sampleapp -->

eksctl utils associate-iam-oidc-provider \
 --region us-east-1 \
 --cluster sampleapp \
 --approve

curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.1/docs/install/iam_policy.json

aws iam create-policy \
 --policy-name AWSLoadBalancerControllerIAMPolicy \
 --policy-document file://iam-policy.json

eksctl create iamserviceaccount \
--cluster=<cluster-name> \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--region <region-code> \
--approve

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh

helm repo add eks https://aws.github.io/eks-charts

kubectl get pods -n kube-system
