# mariadb-filebeat-stack

MariaDB + application logs shipped by Filebeat to Elasticsearch/Kibana, all in Docker.

## Layout

```
.
├── docker-compose.yml
├── .env.example               # copy to .env
├── mariadb/
│   ├── conf.d/50-server.cnf   # commented MariaDB config (error + slow log)
│   └── initdb/01-init.sql     # sample table
├── filebeat/
│   ├── filebeat.yml           # app log input + ES/Kibana output
│   └── modules.d/mysql.yml    # MariaDB log paths
├── app/generate-logs.sh       # sample JSON logger (replace with your app)
└── scripts/test.sh            # slow query + failed login + ES check
```

## Run

```bash
cp .env.example .env                      # edit passwords
sudo sysctl -w vm.max_map_count=262144    # Elasticsearch requirement (Linux/WSL)
docker compose up -d
docker compose ps
./scripts/test.sh
```

Kibana: http://localhost:5601 → Discover → `filebeat-*`
Dashboards: search "MySQL" in Kibana → Dashboards (installed by `setup.dashboards.enabled`).

## Useful queries (Discover, KQL)

| Goal | Query |
|------|-------|
| MariaDB slow queries | `event.dataset : "mysql.slowlog"` |
| MariaDB errors | `event.dataset : "mysql.error"` |
| App errors | `service_name : "backend-api" and level : "ERROR"` |

## Using your own app

Write your app logs into the `app-logs` volume (or change the path in
`filebeat/filebeat.yml`). For plain-text/multiline logs remove the `ndjson` parser
and add a `multiline` parser.

## Notes

- Filebeat reads logs through shared volumes (read-only); it never touches the DB.
- `init-logs` fixes ownership of the log volume so MariaDB (uid 999) can write.
- MariaDB errors go to a file, so `docker logs mariadb` is mostly empty. Use:
  `docker compose exec mariadb tail -f /var/log/mysql/mariadb-error.log`
- Elasticsearch security is disabled for the lab. For production enable
  `xpack.security`, use https and set `username/password` in `filebeat.yml`.
- Troubleshoot: `docker compose exec filebeat filebeat test output` and
  `docker compose logs -f filebeat`.
