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
    --configuration-settings "buildService.storageClassName=default" \
    --configuration-settings "buildService.storageAccessMode=ReadWriteOnce" \
    --configuration-settings "customConfigMap=${namespace}/kube-environment-config" \
    --configuration-settings "envoy.annotations.service.beta.kubernetes.io/azure-load-balancer-resource-group=${aksClusterGroupName}" \
    --configuration-settings "logProcessor.appLogs.destination=log-analytics" \
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.customerId=${logAnalyticsWorkspaceIdEnc}" \
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.sharedKey=${logAnalyticsKeyEnc}"


    extensionId=$(az k8s-extension show \
    --cluster-type connectedClusters \
    --cluster-name $clusterName \
    --resource-group $groupName \
    --name $extensionName \
    --query id \
    --output tsv)

    