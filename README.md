# EFK Multitenant with Authentication and Authorization

### **OAuth2**
- [Github/Github Enterprize](https://github.com/settings/developers) - OAuth App Configuration. Create new App, set Application name (any useful string), Homepage URL ( public URL to your application), Authorization callback URL (for OAuth2-proxy - http://[public url]/oauth2/callback ). You will get Client ID and Client Secret after all.
- [OAuth2-proxy](https://github.com/bitly/oauth2_proxy) - OAuth2 proxy, supports Google, Azure, Facebook, Keycloak, Gitlab, OpenID Connect and some other providers. For Github provider, need to configure OAuth Apps and set client-id, organization, team and client-secret in docker-compose.yaml file
- Kibana X-Pack is free security plugin available. Free and Basic subscription allows to use basic authentication. It is possible to restrict user access to particular indexes, documents, actions
- [Nginx](https://nginx.com) - HTTP(S) proxy server, used to map OAuth2 user to Kibana local user database

Go to folder with docker-compose.yaml file (./oauth2-proxy/), modify it with your parameters and run:
```sh
docker-compose run --build
```
Application will be available at http://localhost:4180
After login to your github account browser will be redirected to Kibana home page
Account used for Kibana has all admin rights

### **OpenDistro for Elasticsearch and Kibana**
- [OpenDistro For Elasticsearch](https://github.com/opendistro-for-elasticsearch) - repositories with Elasticsearch and Kibana maintained by Amazon. It includes some opensourced plugins (Alerts, Security, Anomaly Detection...) preinstalled in the image
- [Security Plugin](https://opendistro.github.io/for-elasticsearch-docs/docs/security-configuration/) (Free version) allow to use several Authentication providers (OpenIDC, LDAP, SAML, Proxy-based and Internal Database)
- Docker-compose files are located in open-distro directory, efk.yaml, with configuration files - in corresponded folders.
- Kubernetes files - are in k8s folder. OD-ELASTICSEARCH.YML will install one node cluster of Elasticsearch, OD-KIBANA.YML - For OpenDistro Kibana, OD-KIBANA-SVC.YML - for Kibana LoadBalancer service to access Kibana GUI on port 5601. Communication between Elasticsearch and Kibana is encrypted using TLS. Kibana Authentication is using OpenID connector for [Auth0](https://auth0.com) service
- Access to Elasticsearch data and different features of Kibana may be configured using Kibana GUI or Kibana API or through configuration files during bootstrap.
- Security Plugin: "Permissions and Roles" consists of "Role Mapping", "Roles", "Action Groups" and "Tenants"
  * **Tenants**: workspace in Kibana sharing Dashboards, Filters, Queries, Indices and so on. There are two pre-defined tenants: 
    * *Global* - Everything configured in this workspace will be available for any authenticated user
    * *Private* - Logged in user scope, nobody except logged user will see what was created here

    Any other created tenants will share Dashboards, Views, etc between users who has access to this tenant
  * **Action Groups** - Named groups of permissions, **Action Groups** may include individual permissions or other Action Groups. There are several predefined **Action Groups**
  * **Roles** - Roles combine Cluster wide permissions (if any) with access rights to indexes, Document Level permissions, list of fields available for user and permissions to the tenants
  * **Role Mapping** - Map users to *Roles*

 ### **Multitenancy**
 **Multitenancy** may be achieved by using separate index per customer, shared index for all customers or combination of both. For second case we can use *Filtered Query* or *Index Aliases* to separate customer data. We also can use Document level permissions to filter data availabale for user. According to several articles ([this](https://www.bigeng.io/elasticsearch-scaling-multitenant/), [this](https://developer.epages.com/blog/tech-stories/multitenancy-and-elasticsearch/), [this](https://www.elastic.co/blog/found-multi-tenancy)) the most scalable way is to use multiple shared indexes with ability to move biggest customers to their own separate indexes.
 
 [BanzaiCloud Logging Operator](https://banzaicloud.com/products/logging-operator) is used to configure per tenant logs flow to Elasticsearch cluster. It consists of several pods:
  * **Logging Operator** - Monitoring multiple namespaces for CRD changes, when changes occured it initiates config check job and applies changes to *fluent-bit* and *fluentd* 
  * **fluent-bit** - lightweigth fluentd version with smaller resource usage footprint, faster but with less number of plugins. It runs on each node and send ALL kubernetes logs to *fluend*. *Fluent-bit* use API servers to collect additional information about pods - pod name, container name, namespace, and send it to *fluentd* too
  * **Fluentd** - main power horse, accept logs from *fluent-bit*, make changes to log, drop logs from pods excluded and send logs to configured Outputs. As target for f*fluentd* we can use Kafka, AWS S3, Elasticsearch and [others](https://github.com/banzaicloud/logging-operator/tree/master/docs/plugins/outputs)

![Operator Flow diagram]
(https://github.com/banzaicloud/logging-operator/blob/master/docs/img/logging_operator_flow.png)

