helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install loki grafana/loki --namespace logging --create-namespace --version 6.29.0 -f values-loki.yaml 


Loki has been configured with a gateway (nginx) to support reads and writes from a single component.

You can send logs from inside the cluster using the cluster DNS:

http://loki-gateway.logging.svc.cluster.local/loki/api/v1/push

You can test to send data from outside the cluster by port-forwarding the gateway to your local machine:

  kubectl port-forward --namespace logging svc/loki-gateway 3100:80 &

And then using http://127.0.0.1:3100/loki/api/v1/push URL as shown below:

```
curl -H "Content-Type: application/json" -XPOST -s "http://127.0.0.1:3100/loki/api/v1/push"  \
--data-raw "{\"streams\": [{\"stream\": {\"job\": \"test\"}, \"values\": [[\"$(date +%s)000000000\", \"fizzbuzz\"]]}]}"
```

Then verify that Loki did receive the data using the following command:

```
curl "http://127.0.0.1:3100/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' | jq .data.result
```

promtail :
helm install promtail grafana/promtail --namespace logging -f values-promtail.yaml

