#!/usr/bin/env bash
# Generate a slow query + a failed login, then check Elasticsearch.
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a

echo "==> Running a slow query (3s, long_query_time=2)"
docker compose exec -T mariadb mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" \
  -e "SELECT SLEEP(3), COUNT(*) FROM appdb.orders;" >/dev/null

echo "==> Triggering an access-denied entry in the error log"
docker compose exec -T mariadb mariadb -uroot -pwrong-password -e "SELECT 1" 2>/dev/null || true

echo "==> Waiting 15s for Filebeat to ship..."
sleep 15

echo "==> Events in Elasticsearch"
for q in 'event.dataset:mysql.slowlog' 'event.dataset:mysql.error' 'service_name:backend-api'; do
  c=$(curl -s "http://localhost:9200/filebeat-*/_count?q=${q}" | grep -o '"count":[0-9]*' || true)
  printf '  %-30s %s\n' "$q" "$c"
done
echo "Open Kibana: http://localhost:5601  (Discover -> filebeat-*)"
