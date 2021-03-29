# Setup demo application with kube-rbac-proxy as a sidecar

## How to run it
__minikube_dex__ setup has defined 5 static users `user[1-5]@che`.

`./01_deploy.sh <user>` will create a `<user>` namespace with admin permissions for the user and deploy there demo application protected by kube-rbac-proxy. Users having `services/proxy` permissions in the namespace will be able to access the application. It also created a traefik routing configuration in `che` namespace.

There are actually 2 instances of the demo application in the pod, both protected with their own instance of kube-rbac-proxy.

### Test
You need to obtain a token for the user (see `minikube_dex/README.md`). Then run `./03_test.sh <namespace> <token>`.

You can then run `01_deploy.sh` for different user and try to use one token for various namespaces.

If you open endpoint in the browser, you should get `Unauthorized`, because you're not passing the token header.

### Notes

#### permissions
kube-rbac-proxy needs following rules on cluster level (ClusterRoleBinding)
```
rules:
- apiGroups: ["authentication.k8s.io"]
  resources:
  - tokenreviews
  verbs: ["create"]
- apiGroups: ["authorization.k8s.io"]
  resources:
  - subjectaccessreviews
  verbs: ["create"]
```

#### Authorization header with bearer token
kube-rbac-proxy does not pass bearer token header to upstream application. 

It removes the header in authentication phase. It allows to pass the user and groups in `x-remote-user` and `x-remote-groups` headers (configurable with `auth-header-fields-enabled`, `auth-header-groups-field-name`, `auth-header-groups-field-separator`, `auth-header-user-field-name`).

I've created an issue (https://github.com/brancz/kube-rbac-proxy/issues/114) and proposed the PR (https://github.com/brancz/kube-rbac-proxy/pull/115) to allow passing the token to upstream application.
