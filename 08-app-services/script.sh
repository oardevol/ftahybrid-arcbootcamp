groupName=oardevol-ftalive-arc
workspaceName=$(az resource list --resource-type Microsoft.OperationalInsights/workspaces --query [].name --output tsv | grep ftalive)

#get log analytics
logAnalyticsWorkspaceId=$(az monitor log-analytics workspace show \
    --resource-group $groupName  \
    --workspace-name $workspaceName \
    --query customerId \
    --output tsv)
logAnalyticsWorkspaceIdEnc=$(printf %s $logAnalyticsWorkspaceId | base64 -w0) 
logAnalyticsKey=$(az monitor log-analytics workspace get-shared-keys \
    --resource-group $groupName  \
    --workspace-name $workspaceName \
    --query primarySharedKey \
    --output tsv)
logAnalyticsKeyEnc=$(printf %s $logAnalyticsKey | base64 -w0) 

#app service extension
extensionName="appservice-ext" 
namespace="appservice-ns" 
kubeEnvironmentName="oardevol-ftalive-arc-kube" 
clusterName=oardevol-ftalive-arc-kind

az k8s-extension create \
    --resource-group $groupName \
    --name $extensionName \
    --cluster-type connectedClusters \
    --cluster-name $clusterName \
    --extension-type 'Microsoft.Web.Appservice' \
    --release-train stable \
    --auto-upgrade-minor-version true \
    --scope cluster \
    --release-namespace $namespace \
    --configuration-settings "Microsoft.CustomLocation.ServiceAccount=default" \
    --configuration-settings "appsNamespace=${namespace}" \
    --configuration-settings "clusterName=${kubeEnvironmentName}" \
    --configuration-settings "keda.enabled=true" \
    --configuration-settings "buildService.storageClassName=standard" \
    --configuration-settings "buildService.storageAccessMode=ReadWriteOnce" \
    --configuration-settings "customConfigMap=${namespace}/kube-environment-config" \
    --configuration-settings "envoy.annotations.service.beta.kubernetes.io/azure-load-balancer-resource-group=${groupName}" \
    --configuration-settings "logProcessor.appLogs.destination=log-analytics" \
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.customerId=${logAnalyticsWorkspaceIdEnc}" \
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.sharedKey=${logAnalyticsKeyEnc}"

#delete (if issues!)
az k8s-extension show \
    --resource-group $groupName \
    --name $extensionName \
    --cluster-type connectedClusters \
    --cluster-name $clusterName

extensionId=$(az k8s-extension show \
    --cluster-type connectedClusters \
    --cluster-name $clusterName \
    --resource-group $groupName \
    --name $extensionName \
    --query id \
    --output tsv)

customLocationName="oardevol-ftalive-arc-location"
connectedClusterId=$(az connectedk8s show --resource-group $groupName --name $clusterName --query id --output tsv)

az customlocation create \
    --resource-group $groupName \
    --name $customLocationName \
    --host-resource-id $connectedClusterId \
    --namespace $namespace \
    --cluster-extension-ids $extensionId \
    --location westeurope

customLocationId=$(az customlocation show \
    --resource-group $groupName \
    --name $customLocationName \
    --query id \
    --output tsv)

az appservice kube create \
    --resource-group $groupName \
    --name $kubeEnvironmentName \
    --custom-location $customLocationId

az webapp create \
    --resource-group $groupName \
    --name oardevol-ftalive-arc-app \
    --custom-location $customLocationId \
    --runtime 'NODE|12-lts'