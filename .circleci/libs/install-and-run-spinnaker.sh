#!/bin/bash -xe
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
USERNAME=`whoami`
sudo bash InstallHalyard.sh --user $USERNAME -y
hal -v
kind create cluster
kubectl config use-context kind-kind
kubectl cluster-info
hal config provider kubernetes enable
CONTEXT=$(kubectl config current-context)
hal config provider kubernetes account add my-k8s-v2-account --provider-version v2 --context $CONTEXT
hal config features edit --artifacts true
hal config deploy edit --type distributed --account-name my-k8s-v2-account
kubectl create namespace spinnaker
kubectl create -f https://raw.githubusercontent.com/minio/minio-operator/master/minio-operator.yaml
kubectl create -n spinnaker -f https://raw.githubusercontent.com/minio/minio-operator/master/examples/minioinstance.yaml
mkdir -p ~/.hal/default/profiles
echo "spinnaker.s3.versioning: false" >> ~/.hal/default/profiles/front50-local.yml
export MINIO_ACCESS_KEY=minio
export MINIO_SECRET_KEY=minio123
echo $MINIO_SECRET_KEY | hal config storage s3 edit --endpoint "http://minio-hl-svc:9000" --access-key-id $MINIO_ACCESS_KEY --secret-access-key
hal config storage edit --type s3
hal version list
hal config version edit --version 1.19.4
hal deploy apply
while [ `kubectl -n spinnaker get pods --no-headers | grep -c -v Running` -ne 0 ]
do
  kubectl -n spinnaker get pods
  sleep 30
done
