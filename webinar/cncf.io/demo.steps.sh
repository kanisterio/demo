#!/usr/bin/env bash

kanctl create actionset --action backup \
   --namespace kasten-io --blueprint mysql-blueprint \
   --statefulset mysql-test/mysql-release \
   --profile mysql-test/s3-profile-s2zpc \
   --secrets mysql=mysql-test/mysql-release

kubectl get actionset
kubectl get actionset backup-t4sqb -oyaml |grep -i artifacts -A3 -B2

kanctl --namespace kanister create actionset --action restore --from "backup-t4sqb"
actionset restore-backup-t4sqb-dsvr9 created

k get actionset
k get action set restore-backup-t4sqb-dsvr9 -o yaml
