#!/bin/sh
# Sample app: appends one JSON log line every 2 seconds.
# Replace with your real application; just write to /var/log/myapp/*.log
LOG=/var/log/myapp/app.log
mkdir -p /var/log/myapp

while true; do
  n=$((RANDOM % 10))
  if   [ "$n" -ge 9 ]; then level="ERROR"; msg="Database timeout while processing order"
  elif [ "$n" -ge 7 ]; then level="WARN";  msg="Slow response from payment gateway"
  else                      level="INFO";  msg="Request handled successfully"
  fi
  printf '{"@timestamp":"%s","level":"%s","message":"%s","request_id":"%s"}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$level" "$msg" "$RANDOM$RANDOM" >> "$LOG"
  sleep 2
done
