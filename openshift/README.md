# Setup minikube instance with authentication and authorization for multiple applications in different namespaces

## How to run
  1. Have openshift cluster with oc/kubectl configured
  2. set cluster hostname  to `CLUSTER_HOSTNAME` env variable (`export CLUSTER_HOSTNAME=apps.openshift.cluster`)
  2. Deploy the gateway with `./01_gateway.sh`
  3. Deploy the user's application (workspace)
    1. Go to `workspace` folder -> `$ cd workspace`
    1. Run `./01_deploy.sh user1` (or other valid user `user[1-5]`).
    1. Deploy for at least one more user

## How it works

### Diagram
(gateway is blackbox here. See next image.)
![Diagram](diagram.png)

### Gateway
![Gateway](gateway.png)

Gateway covers couple of responsibilities here:
  - Authentication
    - _openshift/oauth_proxy_ ensures all incoming requests are authenticated. If user has no auth cookie, it redirects user to authentication page.
    - oauth_proxy can pass user's openshift token to upstream application only in `X-Forwarded-Access-Token` header. However, we need it in `Authorization` header. For that we have here __header-rewrite-rpxy__, that takes the `X-Forwarded-Access-Token` header value, and puts it into `Authorization: Bearear <token>` header.
  - Authorization
    - _Traefik_ uses forwardAuth middleware (https://doc.traefik.io/traefik/middlewares/forwardauth/) with target of kube-rbac-proxy to allow/deny the request. _Kube-rbac-proxy_ uses non-resource RBAC cluster rules (see [/kube-rbac-proxy/route-config.yaml](../kube-rbac-proxy/route-config.yaml#L54)). "Dummy webserver" is there only as a blackhole upstream for kube-rbac-proxy.
  - Routing
    - Classic routing with treafik as we know it from single-host Che, except for Authorization middleware described above ^^


## How to test
The user's applications are exposed on `https://che.<cluster-host>/user[1-n]`. Only matching user should have access to the endpoints, other should see something like `Forbidden (user=user3, verb=get, resource=, subresource=)`.

The demo application is doing some requests to k8s with bearer token. Logged user should have access only to his/her namespace. If you try to request different namespace, you shold see in the output something like `configmaps is forbidden: User "user1" cannot list resource "configmaps" in API group "" in the namespace "user2"`.
