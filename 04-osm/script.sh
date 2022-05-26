k create namespace bookstore
k create namespace bookbuyer
k create namespace bookthief
k create namespace bookwarehouse

osm namespace add bookstore bookbuyer bookthief bookwarehouse

kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.1/manifests/apps/bookbuyer.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.1/manifests/apps/bookthief.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.1/manifests/apps/bookstore.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.1/manifests/apps/bookwarehouse.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.1/manifests/apps/mysql.yaml

#on a different session
git clone https://github.com/openservicemesh/osm
cp .env.example .env
sed -i 's/K8S_NAMESPACE=osm-system/K8S_NAMESPACE=arc-osm-system/' .env
sed -i 's/port-forward-bookstore-ui-v2.sh/port-forward-bookstore-ui.sh/' ./scripts/port-forward-all.sh
./scripts/port-forward-all.sh

#using Arc portal show how can we change configuration
#"spec":{"traffic":{"enablePermissiveTrafficPolicyMode":false}}
#check services can't communicate

#allow traffic again
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm-docs/release-v1.1/manifests/access/traffic-access-v1.yaml
