RG=oardevol-ftalive-arc
CLUSTER=oardevol-ftalive-arc-kind

LOGID=$(az resource list --resource-type Microsoft.OperationalInsights/workspaces --query [].id --output tsv | grep ftalive)

az k8s-extension create --name microsoft.azuredefender.kubernetes --cluster-type connectedClusters --cluster-name $CLUSTER --resource-group $RG --extension-type microsoft.azuredefender.kubernetes --configuration-settings logAnalyticsWorkspaceResourceID=$LOGID

#show it can also be done from portal

kubectl get pods --namespace=asc-alerttest-662jfi039n

 