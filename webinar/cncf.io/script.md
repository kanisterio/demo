# Overview
- Title: Kubernetes Data Protection Requires Orchestration: Kanister.io Delivers (Slide 1)
- What will be covered: How the open source project Kanister.io solves the need to extend past infrastructure backups to application orchestration and recovery of databases and persistent workloads on Kubernetes.
- Why the reader should attend: To address the challenge of Kubernetes disaster recovery and adopt the value of Kanister blueprints for automated data protection.
- What reader will learn: How to automate data protection with Kanister blueprints.
- Actionable takeaways:
  - Understand the goals of disaster recovery and why Kubernetes is the ideal infrastructure
  - Understand Kubernetes persistent workloads and their challenges: the different types of backups
  - Understand how Kanister.io automation solves those challenges
  - See a Kanister.io blueprint in action: application consistent backup and recovery of an open source database
- Title: How the Kanister.io Project Orchestrates Kubernetes Data Protection
  - Abstract:
The open source Kanister.io project extends infrastructure backups to application orchestration and recovery of databases and persistent workloads on Kubernetes. Operators, logical, and system backup methods are not a panacea for application consistent backup and recovery with efficient resource management of time, security, and storage. Kanister.io blueprint automation addresses the gaps of each while also coordinating external systems as needed. We'll demonstrate a simple application consistent backup and recovery of an open source database hosted on Kubernetes with Kanister and conclude with how to adopt and join the project.
  - Benefits to the Ecosystem:
As databases and persistent workloads hosted on Kubernetes grows, cloud native data protection is needed to address the gaps of traditional backup and recovery solutions. While there are many open source and commercial offerings in the market, many automate backups with scripting and cron, addressing only the first step of data protection. What if there was a cloud-native controller, installed by Helm chart, that could drive data protection operations with a community of blueprints ready to be consumed and adopted by the entire industry, regardless of vendor or provider? Kanister replaces bespoke efforts with an extensible framework to manage data protection operations.

# Agenda (Slide 2)
[Slides](https://veeamsoftwarecorp-my.sharepoint.com/:p:/g/personal/mark_lavi_veeam_com/EfR8pfcjwIRLtPktAsDL8aYBuJ6HTmoUMYWFzBKAkfpaxQ?e=9BuusL)

1. Introductions: Michael and Mark
2. Data Protection on Kubernetes: Overview
   - Stateful versus stateless: mixed workloads are reality for many
   - Why backing up etcd is not a proper strategy
   - What is an application consistent backup?
   - How Kanister performs cloud native data protection operations
3. Discussion and Demonstration of Kubernetes Data Protection with Kanister.io Blueprints
4. Conclusions: where to go for more resources
   - https://kanister.io
     - Today's materials = https://github.com/kanisterio/demo/blob/main/webinar/cncf.io/
   - Kubernetes: SIG-App+SIG-Storage: [Data Protection Working Group](https://www.kubernetes.dev/community/community-groups/#working-groups)
   - https://DoK.community

# Talk and Demonstration
Mi. Hey Ma, I know that you are in charge of Kanister, I heard Kanister is a framework for data management in Kubernetes, but I'm not sure to understand why we need a framework for that ?

Ma. Sure Kanister solve the problem of data management on Kubernetes, because data management on Kubernetes is not obvious as it seems.

Mi. Why that ? Can you give me an example

Ma. Let's say you have a mysql database deployed on Kubernetes and you want to backup this database. First you'll have to open the secret attached to this database and obtain the root password, you also have to discover the service to connect to : the port and the url. How are you going to connect to this url ? You can do a port-forward to expose the mysql port in your laptop but this is unstable and you also need to have a mysqldump client locally so you'd better take the approach of executing mysqldump on the mysql pod or on a client pod that you spin up just for this reason. Whatever the solution you take, then you'll have to manage a dump, you need to export this dump to a backup location for instance S3 or a google bucket, and you want to have freedom of choice on this matter. For security reason you decide to encrypt this dump at rest because you don't trust by default the security on the s3 bucket, now you need to encrypt with solid and proven tool and also manage an encryption key. Most likely the tools needed for this won't be available on the mysql pod so you have to spin up a pod with the required tool. Then come the management of your backup, how do you keep track of all your backups. How do you manage their deletion or their restoration, will you repeat all this operations ? Now most likely you have more than one database deployed on this clusters or deployed on several clusters. How do you capture and share all this knowledge across your teams, your clusters and your namespaces...

Mi. I didn't no see it this way but this is true that's going to be a problem if you have a strong repetition of the same deployment with few parameters that change. We may try to write a quick and dirty bash script ? What do you think I know that "quick and dirty" is not popular today but I can try :)

Ma. When it comes to data management "quick and dirty" is not a good idea if you want my opinion, let's say you decide to write a "clean" script and not rely on a framework. Even if you decide do that in a clean manner you have to solve many problems that a framework will properly encapsulate and that you'll spend tons of time to solve if you don't want to fall back in quick and dirty !

Mi. You have examples ?

Ma. Sure, for instances :
- how do you switch from S3 to Azure blob without changing the code ?
- how do you follow up the progression of an action knowing that your internet connection may be cut ?
- how do retrieve in a consistent manner credentials of your backup location ?
- how do you manage incremental backup of your PVC ?
- how do you wait for a scale down or a scale up operation, how do you wait for a status before switching to the next action ?
- how do you logs all the operations in a single place ?
- how do you discover the content of a secret, deployment, or any object without using ugly and not maintainable JSONpath expression like '.metadata.annotations.kubenetes\.io/hostname}'
....

Mi. Ok I think you convince me. So ok let's say I want to use this framework Kanister can you give an overview of how it works

Ma. It's basically the operator pattern you create an action that has parameters and a blueprint, then the operator execute the blueprint with the parameters. Whatever the result success or failure the operator update the status of the action. You'll be able to work again with this status to restore or delete the backup.

Mi. Do you have like a diagram so that I can understand in a more sequential way ?

Ma. Sure let's take the example of mysql .... <comment on the diagram>
![Kanister diagram sequence without artifact](./kanister-sequence-diagram-with-blueprint-and-mysql.drawio.png)

Now we can add the artifact and the backup location in the picture

![Kanister diagram sequence with artifact](./kanister-sequence-diagram-with-blueprint-and-mysql-and-artifact.drawio.png)

Mi. Ok can you show me an example of an actionset ?

Ma.  [ActionSet.example.yaml](ActionSet.example.yaml) all of these materials are available at https://github.com/kanisterio/demo/tree/main/webinar/cncf.io/

```yaml
apiVersion: cr.kanister.io/v1alpha1
kind: ActionSet
metadata:
  name: backup-action-2023-05-24
  namespace: kanister
spec:
  actions:
  - blueprint: mysql-blueprint
    name: backup
    object:
      apiVersion: ""
      group: ""
      kind: statefulset
      name: mysql-release
      namespace: mysql-test
      resource: ""
    preferredVersion: ""
    profile:
      apiVersion: ""
      group: ""
      kind: ""
      name: s3-profile-s2zpc
      namespace: mysql-test
      resource: ""
    secrets:
      mysql:
        apiVersion: ""
        group: ""
        kind: ""
        name: mysql-release
        namespace: mysql-test
        resource: ""
```

Mi. Whooo that looks complicated ?

Ma. Not that much actually you can break it apart

There is basically 4 important parts :

the blueprint
```
blueprint: mysql-blueprint
```
which is a sort of library of actions that you create for your operations related to mysql.
- https://github.com/kanisterio/kanister/tree/master/examples/mysql

the action
```
name: backup
```
you invoke in the blueprint

the object
```yaml
object:
      apiVersion: ""
      group: ""
      kind: statefulset
      name: mysql-release
      namespace: mysql-test
      resource: ""
```
on which you apply this action

the profile
```yaml
    profile:
      apiVersion: ""
      group: ""
      kind: ""
      name: s3-profile-s2zpc
      namespace: mysql-test
      resource: ""
```
Which is where you want to send your backup

the secrets
```yaml
   secrets:
      mysql:
        apiVersion: ""
        group: ""
        kind: ""
        name: mysql-release
        namespace: mysql-test
        resource: ""
```
That you need to work with for executing your operations, for instance connecting to the database.

The controller detect (in Kubernetes it's more "watch" than detect) the creation of the actionset and execute the blueprint actions on the object and the secrets.

Mi. Ok but that sound complex to create an actionset each time we need to take a backup ?

Ma. No ! Kanister comes with a tool called kanctl that help you create it, I created the previous object with this command
```shell
kanctl create actionset --action backup \
   --namespace kasten-io --blueprint mysql-blueprint \
   --statefulset mysql-test/mysql-release \
   --profile mysql-test/s3-profile-s2zpc \
   --secrets mysql=mysql-test/mysql-release
```

Mi. But wait I understand all the parameters but not the --profile, what is that ?

Ma. Ah the profile is where you send backup, Kanister support S3 compliant, Azure container and GCP bucket.

Mi. But if decide to change the for a s3 bucket to another one or to a GCP bucket do I need to change the code in the blueprint ?

Ma. No that's the advantage of working with a framework, you don't need to change a single line of code in your blueprint only change the parameter.

Mi. Ok, let's say that now I have created the actionset then what, how do I know if it's successful and how can I know where is my backup

Ma. All this information is in the action set
```shell
kubectl get actionset
NAME           PROGRESS   RUNNING PHASE   LAST TRANSITION TIME   STATE
backup-t4sqb   10.00                      2023-05-24T09:54:57Z   complete
```

You see the state is complete which means the execution was successful and if you need to know where is the backup check the artifacts section of the status
```shell
kubectl get actionset backup-t4sqb -oyaml |grep -i artifacts -A3 -B2
status:
  actions:
  - artifacts:
      mysqlCloudDump:
        keyValue:
          s3path: /mysql-backups/mysql-test/mysql-release/2023-05-24T09-54-45/dump.sql.gz
```
This part is what we called the output artifacts.

Mi. Ok but if I need to restore I guess that I have to recreate another actionset, but how can I pass this "s3path" to the actionset

Ma. You're right to restore you need to create another actionset with the action "restore" and with all the information contained in the actionset kanctl will create the appropriate actionset
```shell
kanctl --namespace kanister create actionset --action restore --from "backup-t4sqb"
actionset restore-backup-t4sqb-dsvr9 created
```

Mi. Did it work?

Ma. Let's see
```shell
kubectl get actionset
NAME                         PROGRESS   RUNNING PHASE   LAST TRANSITION TIME   STATE
backup-t4sqb                 10.00                      2023-05-24T09:54:57Z   complete
restore-backup-t4sqb-dsvr9   10.00                      2023-05-24T13:30:22Z   complete
```
Yes the restore has been working fine as well ! You see it creates like an history of all your actions, date and state are easy to read.

Mi. Hey, let me see the content of the restore ?

Ma.
```yaml
kubectl get action set restore-backup-t4sqb-dsvr9 -o yaml
spec:
  actions:
  - artifacts:
      mysqlCloudDump:
        keyValue:
          s3path: /mysql-backups/mysql-test/mysql-release/2023-05-24T09-54-45/dump.sql.gz
    blueprint: mysql-blueprint
    name: restore
    object:
      apiVersion: ""
      group: ""
      kind: statefulset
      name: mysql-release
      namespace: mysql-test
      resource: ""
    preferredVersion: ""
    profile:
      apiVersion: ""
      group: ""
      kind: ""
      name: s3-profile-s2zpc
      namespace: mysql-test
      resource: ""
    secrets:
      mysql:
        apiVersion: ""
        group: ""
        kind: ""
        name: mysql-release
        namespace: mysql-test
        resource: ""
```
You see an artifacts section is there now. The output artifacts of the previous actionset becomes the input artifact of the new action. This way the restore action can consume the dump on the s3 profile and execute the restoration.

Mi. I start to get the idea this is really powerful to write quickly data management operations. But I really wonder how you define a blueprint.

Ma. Ah, let's speak about that next...
