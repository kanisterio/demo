#!/usr/bin/env bash

# based on https://github.com/kanisterio/kanister/tree/master/examples/mysql

# Create the mysql database
kubectl create namespace mysql-test
kubectl config set-context --current --namespace=mysql-test
helm install mysql-release bitnami/mysql --namespace mysql-test \
  --set auth.rootPassword='mymysqlrootpassword'
# create some data see create-data.sh

# create the profile and the blueprint 
kanctl create profile s3compliant --access-key $AWS_S3_ACCESS_KEY_ID \
	--secret-key $AWS_S3_SECRET_ACCESS_KEY \
	--bucket $MY_DEMO_BUCKET --region $MY_REGION \
	--namespace mysql-test
kubectl create -f \
    -n kasten-io \
    https://raw.githubusercontent.com/kanisterio/kanister/master/examples/mysql/mysql-blueprint.yaml 

# We are ready to launch a backup 
PROFILE=$(kubectl get profiles.cr.kanister.io \
   -ojsonpath='{.items[0].metadata.name}')
kanctl create actionset --action backup \
   --namespace kasten-io \
   --blueprint mysql-blueprint \
   --statefulset mysql-test/mysql-release \
   --profile mysql-test/$PROFILE

# Check if it's successful 
ACTION_SET=$(kubectl get actionset \
    --sort-by=.metadata.creationTimestamp \
    -n kasten-io \
    | awk '{print $1}' \
    | tail -1)
kubectl get actionset $ACTION_SET -n kasten-io 

# create a disaster you accidentally remove your installation
helm uninstall mysql-release
kubectl delete pvc data-mysql-release-0

# let's reinstall
helm install mysql-release bitnami/mysql --namespace mysql-test \
  --set auth.rootPassword='mymysqlrootpassword'

# lauche a restore
kanctl create actionset \
   --namespace kasten-io \
   --action restore \
   --from $ACTION_SET
   
# Check if it's successful 
ACTION_SET=$(kubectl get actionset \
    --sort-by=.metadata.creationTimestamp \
    -n kasten-io \
    | awk '{print $1}' \
    | tail -1)
kubectl get actionset $ACTION_SET -n kasten-io 
