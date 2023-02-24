groupName=oardevol-ftalive-arc
clusterName=""

az k8s-extension create --cluster-name $clusterName --resource-group $groupName --cluster-type connectedClusters --extension-type Microsoft.AzureKeyVaultSecretsProvider --name akvsecretsprovider