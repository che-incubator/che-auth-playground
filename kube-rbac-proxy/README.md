# Setup demo application with kube-rbac-proxy as a sidecar

## How to run it
__minikube_dex__ setup has defined 5 static users user[1-5]@che and script `minikube_dex/13_prepareNamespaces.sh` has created 5 namespaces `user[1-5]` with users `user[1-5]@che` having admin ClusterRole in their matching namespace.

`./01_deploy.sh <namespace> <user>` will deploy demo application to given namespace (`<user>` parameter is optional. The script derives the user from namespace like `<namespace>@che`). Users having `services/proxy` permissions in the namespace will be able to access the application.

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
