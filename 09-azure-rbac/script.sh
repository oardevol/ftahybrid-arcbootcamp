clusterName=""
tenantId="28fb5b77-7c3b-4f34-9250-7492ccfd85fe"

#create azure ad app (server)
SERVER_APP_ID=$(az ad app create --display-name "${clusterName}Server" --identifier-uris "api://${tenantId}/${clusterName}Server" --query appId -o tsv)
az ad app update --id "${SERVER_APP_ID}" --set groupMembershipClaims=All
#MISSING: create app role!
#create service principal for app
az ad sp create --id "${SERVER_APP_ID}"
SERVER_APP_SECRET=$(az ad sp credential reset --id "${SERVER_APP_ID}" --query password -o tsv)
az ad app permission add --id "${SERVER_APP_ID}" --api 00000003-0000-0000-c000-000000000000 --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
az ad app permission grant --id "${SERVER_APP_ID}" --api 00000003-0000-0000-c000-000000000000 --scope

#create client app
APP_ROLE_ID=$(az ad app show --id "${SERVER_APP_ID}" --query "appRoles[0].id" -o tsv)
CLIENT_APP_ID=$(az ad app create --display-name "${clusterName}Client" --is-fallback-public-client true --web-redirect-uris "api://${tenantId}/${clusterName}Client" --query appId -o tsv)
#create service principal for app
az ad sp create --id "${CLIENT_APP_ID}"
az ad app permission add --id "${CLIENT_APP_ID}" --api "${SERVER_APP_ID}" --api-permissions ${APP_ROLE_ID}=Role
az ad app permission grant --id "${CLIENT_APP_ID}" --api "${SERVER_APP_ID}" --scope ${APP_ROLE_ID}=Role

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
cat <<EOF > accessCheck.json
{
  "Name": "Read authorization",
  "IsCustom": true,
  "Description": "Read authorization",
  "Actions": ["Microsoft.Authorization/*/read"],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/${SUBSCRIPTION_ID}"
  ]
} 
EOF
ROLE_ID=$(az role definition create --role-definition ./accessCheck.json --query id -o tsv)
az role assignment create --role "${ROLE_ID}" --assignee "${SERVER_APP_ID}" --scope /subscriptions/${SUBSCRIPTION_ID}

az connectedk8s enable-features -n $clusterName -g $groupName --features azure-rbac --app-id "${SERVER_APP_ID}" --app-secret "${SERVER_APP_SECRET}"