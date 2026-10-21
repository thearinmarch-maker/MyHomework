#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd)
cd "$PROJECT_ROOT"
source ci/settings.env
LOG=rollback-availability.log
: > "$LOG"
echo "Monitoring for 180 seconds. Start the Jenkins rollback now."
for sample in $(seq 1 180); do
  NOW=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  if VERSION=$(curl -fsS --connect-timeout 2 --max-time 2 \
      "http://127.0.0.1:$APP_PORT/version.txt" 2>/dev/null); then
    printf '%s OK %s\n' "$NOW" "$VERSION" | tee -a "$LOG"
  else
    printf '%s FAIL unavailable\n' "$NOW" | tee -a "$LOG"
  fi
  sleep 1
done
awk '$2=="FAIL"{n++} END{print "Failures:", n+0}' "$LOG"
echo "Observed versions:"
awk '{print $3}' "$LOG" | sort -u
