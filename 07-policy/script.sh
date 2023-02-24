groupName=oardevol-ftalive-arc
clusterName=""

az provider register --namespace 'Microsoft.PolicyInsights'

az k8s-extension create --cluster-type connectedClusters --cluster-name $clusterName --resource-group $groupName --extension-type Microsoft.PolicyInsights --name azurepolicy