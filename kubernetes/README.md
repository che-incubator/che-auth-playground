#Setup minikube instance with authentication and authorization for multiple applications in different namespaces

## How to run
  1. Start minikube instance with prepared scripts
    1. Go to `minikube_dex` folder -> `$ cd ../minikube_dex`
    2. Run scripts `01-04` and `12`. See `../minikube_dex/README.md` for details what they do
    3. Prepared static users are `che@eclipse.org:password` and `user[1-5]@che:password`
  2. Deploy the gateway
    1. run `./01_gateway.sh` from this folder
    2. the scripts prints link to main endpoint `https://che.<minikube ip>.nip.io`. This will point to application deployed in `1.2.`, and should be protected by authentication. All users should have access to that endpoint, but only `che@eclipse.org` users should have access to request kubernetes on `che` namespace.
  3. Deploy the user's application (workspace)
    1. Go to `kube-rbac-proxy` folder -> `$ cd ../kube-rbac-proxy`
    1. Run `./01_deploy.sh user1` (or other valid user `user[1-5]`).
    1. Deploy for at least one more user

### Diagram
![diagram](diagram.gif)

## How to test
The user's applications are exposed on `https://che.<minikube ip>.nip.io/user[1-5]`. Only matching user should have access to the endpoints, other should see something like `Forbidden (user=user1@che, verb=get, resource=services, subresource=proxy)`.

The demo application is doing some requests to k8s with bearer token. Logged user should have access only to his/her namespace. If you try to request different namespace, you shold see in the output something like `configmaps is forbidden: User "user1@che" cannot list resource "configmaps" in API group "" in the namespace "user2"`.
