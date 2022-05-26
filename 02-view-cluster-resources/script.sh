#view cluster resources from Azure Arc Azure Portal

#create a service account
kubens default
k create serviceaccount admin-user
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: admin-user-secret
  annotations:
    kubernetes.io/service-account.name: admin-user
type: kubernetes.io/service-account-token
EOF
k create clusterrolebinding admin-user-binding --clusterrole cluster-admin --serviceaccount default:admin-user
TOKEN=$(kubectl get secret admin-user-secret -o jsonpath='{$.data.token}' | base64 -d | sed $'s/$/\\\n/g')