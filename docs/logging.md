---
title: Logging
---

> HP Business Platform leverage the functions provided from open source tool "EFK" to provie the ability for logging and help developer for debugging and troubleshooting. "EFK” is an acronym for three major open source projects: Elasticsearch, Fluentd and Kibana.

- Elasticsearch is a search and analytics engine.
- Fluentd to receive, clean and parse the log data.
- Kibana lets users visualize data with charts and graphs in Elasticsearch.

EFK makes it way easier and faster to search and analyze large data sets.

**Technologies used in solution:**
1. [Amazon OpenDistro Elasticsearch](https://opendistro.github.io/for-elasticsearch/ "Amazon OpenDistro Elasticsearch") - **Data store and search engine**. Elasticsearch image with some opensource plugins installed. Main plugin used is "security" plugin which allows us to create multi-tenant environment with data segragation up to document  level based on user role, group, login.
2. ***Kibana*** is the default visualization tool for data in Elasticsearch. It also serves as a user interface for the Open Distro for Elasticsearch Security and Alerting plugins
3. [Keycloak](https://www.keycloak.org/) - is an open source Identity and Access Management solution aimed at modern applications and services.  Keycloak is able to provide internal user database or be a proxy to other Id Providers like Github, Google, LDAP and several others. Keycloak is configured to allow use of HP ID service to authenticate HP Inc users. 
4. [Banzai Logging Operator](https://github.com/banzaicloud/logging-operator) - Logging operator for Kubernetes based on Fluentd and Fluentbit. Operator allows to use Kubernetes style configuration of fluentd and fluent-bit through different CRD

**Short description with configuration examples:**
- [Elasticsearch, Kibana, Keycloak security](./kibana.md)
- [Banzai Logging Operator](./logging_operator.md)

#### INSTALLATION INSTRUCTION
***Pre-requisites***
1. Kubernetes >= 1.14
2. Helm v3

Files may be found in [EFK-Logging](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/tree/master/open-distro/k8s) repository
1. Create namespace for stack ([ns-logging.yml](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/blob/master/open-distro/k8s/ns-logging.yml)). File includes some kube2iam annotations for access to S3 and ECR
2. Create StorageClass for stack's PVC [es-gp2-storage](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/blob/master/open-distro/k8s/es-storageclass.yml)
3. Create PersistantVolume and PersistentVolumeClaim for postgres database, used as backend for Keycloak application ([pv-postgres.yml](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/blob/master/open-distro/k8s/pv-postgres.yml))
4. Start postgres database using [postgres.yml](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/blob/master/open-distro/k8s/postgres.yml). You may restore database backup stored on S3 in order to implement keycloak configuration running on DEV Kubernetes stack
5. Apply [keycloak_ssl.yml](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/blob/master/open-distro/k8s/keycloak_ssl.yml) to start keycloak pod. 
6. Create Keycloak service ([keycloak-svc.yml](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/blob/master/open-distro/k8s/keycloak-svc.yml)) It will create LoadBalancer to access Keycloak from outside world. Add Kubernetes workers external ip to LB security group in order to allow communication between Kibana and Keycloak using FQDN. Add (wildcard) certificate to LB. Add CNAME of LB to Route53
7. Apply [elasticsearch_ssl.yml](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/blob/master/open-distro/k8s/elasticsearch_ssl.yml) to create statefulset for Elasticsearch nodes. It has three replicas to form Elasticsearch cluster with 300GB volume storage for data. File has initial configuration for Elasticsearch and OpenDistro Security plugin with some pre-configured internal users, roles, etc. 
8. Create Kibana instance using [kibana_ssl.yml](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/blob/master/open-distro/k8s/kibana_ssl.yml). Add kibana service from [kibana-svc.yml](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/blob/master/open-distro/k8s/kibana-svc.yml). It will create LoadBalancer to allow access from Internet. Apply the same additional steps as for Keycloak service installation from #6.
9. Install Banzai Logging operator using helm:
```
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
helm repo update
helm install --namespace logging logging banzaicloud-stable/logging-operator --set createCustomResource=false
```
 10. Apply configuration to fluentd and fluent-bit using [controlNamespace.yml](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/blob/master/open-distro/k8s/logging%20operator/controlNamespace.yml)
 11. [logs](https://github.azc.ext.hp.com/hpbp-devops/efk-logging/tree/master/open-distro/k8s/logging%20operator) directory contain examples of logging flow configuration. Since tenants will have more than one namespace for their application it is make sense to configure "clusterOutput" for each tenant and one "Flow" for each namespace to gather logs