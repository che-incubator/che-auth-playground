#!/bin/bash

for i in {1..5}; do
  NAMESPACE="user${i}"
  USER="user${i}@che"
  echo "Preparing namespace '${NAMESPACE}' for user '${USER}'"

  kubectl create namespace ${NAMESPACE}

  echo "
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${NAMESPACE}-admin
subjects:
  - kind: User
    name: ${USER}
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io
" | kubectl apply -n ${NAMESPACE} -f -
done
