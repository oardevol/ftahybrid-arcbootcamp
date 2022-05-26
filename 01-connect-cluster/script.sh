#connect cluster
az connectedk8s connect --name oardevol-ftalive-arc-kind --resource-group oardevol-ftalive-arc

#view cluster
#notice certificate for system managed identity (managedIdentityCertificateExpirationTime) has a default expiration time of 90 days
az connectedk8s show -n oardevol-ftalive-arc-kind -g oardevol-ftalive-arc