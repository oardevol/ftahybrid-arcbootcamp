groupName=oardevol-ftalive-arc
workspaceName=oardevol-ftalive-arc-logs

az monitor log-analytics workspace create -g $groupName -n $workspaceName

#configure azure monitor using portal