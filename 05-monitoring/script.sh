RG=oardevol-ftalive-arc
NAME=oardevol-ftalive-logs

az monitor log-analytics workspace create -g $RG -n $NAME

#configure azure monitor using portal