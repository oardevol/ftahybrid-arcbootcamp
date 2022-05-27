clusterName=oardevol-ftalive-arc-kind
groupName=oardevol-ftalive-arc

#connect cluster
az connectedk8s connect --name $clusterName --resource-group $groupName --location westeurope

#view cluster
#notice certificate for system managed identity (managedIdentityCertificateExpirationTime) has a default expiration time of 90 days
az connectedk8s show -n $clusterName -g $groupName