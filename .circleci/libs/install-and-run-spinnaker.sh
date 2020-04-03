#!/bin/bash -x
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
echo "Exit code $?"
USERNAME=`whoami`
echo "Exit code $?"
sudo bash InstallHalyard.sh --user $USERNAME -y
echo "Exit code $?"
hal -v
echo "Exit code $?"
kind create cluster
echo "Exit code $?"
kubectl config use-context kind-kind
echo "Exit code $?"
kubectl cluster-info
echo "Exit code $?"
hal config provider kubernetes enable
echo "Exit code $?"
CONTEXT=$(kubectl config current-context)
echo "Exit code $?"
hal config provider kubernetes account add my-k8s-v2-account -provider-version v2 --context $CONTEXT
echo "Exit code $?"
hal config features edit --artifacts true
echo "Exit code $?"
hal config deploy edit --type distributed --account-name my-k8s-v2-account
echo "Exit code $?"
kubectl create namespace spinnaker
echo "Exit code $?"
kubectl create -f https://raw.githubusercontent.com/minio/minio-operator/master/minio-operator.yaml
echo "Exit code $?"
kubectl create -n spinnaker -f https://raw.githubusercontent.com/minio/minio-operator/master/examples/minioinstance.yaml
echo "Exit code $?"
mkdir -p ~/.hal/default/profiles
echo "Exit code $?"
echo "spinnaker.s3.versioning: false" >> ~/.hal/default/profiles/front50-local.yml
echo "Exit code $?"
export MINIO_ACCESS_KEY=minio
echo "Exit code $?"
export MINIO_SECRET_KEY=minio123
echo "Exit code $?"
echo $MINIO_SECRET_KEY | hal config storage s3 edit --endpoint "http://minio-hl-svc:9000" --access-key-id $MINIO_ACCESS_KEY --secret-access-key
echo "Exit code $?"
hal config storage edit --type s3
echo "Exit code $?"
hal version list
echo "Exit code $?"
hal config version edit --version 1.19.4
echo "Exit code $?"
hal deploy apply
echo "Exit code $?"
while [ `kubectl -n spinnaker get pods --no-headers | grep -c -v Running` -ne 0 ]
do
  kubectl -n spinnaker get pods
  sleep 30
done
