#!/usr/bin/env bash
#
# Pattern 5 — Apply the Sentry-to-Slack alert rule via the Sentry API.
#
# This is the one-shot version of docs/sentry-alert-setup.md (Option B). It
# POSTs sentry-alert-rule.json to your project's rules endpoint. Edit the
# placeholders in sentry-alert-rule.json (Slack workspace/channel ids) first.
#
# Usage:
#   export SENTRY_AUTH_TOKEN="your-token-with-alerts:write"
#   ./examples/apply-sentry-alert.sh your-org your-project
#
set -euo pipefail

ORG_SLUG="${1:?Usage: apply-sentry-alert.sh <org-slug> <project-slug>}"
PROJECT_SLUG="${2:?Usage: apply-sentry-alert.sh <org-slug> <project-slug>}"
: "${SENTRY_AUTH_TOKEN:?Set SENTRY_AUTH_TOKEN to a token with the alerts:write scope}"

# Resolve the rule file relative to this script so it runs from any CWD.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULE_FILE="${SCRIPT_DIR}/../sentry-alert-rule.json"

if [ ! -f "${RULE_FILE}" ]; then
  echo "Cannot find ${RULE_FILE}" >&2
  exit 1
fi

echo "Applying alert rule to ${ORG_SLUG}/${PROJECT_SLUG}..."

http_status=$(
  curl -sS -o /tmp/sentry-rule-response.json -w "%{http_code}" \
    -X POST \
    -H "Authorization: Bearer ${SENTRY_AUTH_TOKEN}" \
    -H "Content-Type: application/json" \
    "https://sentry.io/api/0/projects/${ORG_SLUG}/${PROJECT_SLUG}/rules/" \
    --data @"${RULE_FILE}"
)

if [ "${http_status}" = "201" ]; then
  echo "Alert rule created (HTTP 201)."
  cat /tmp/sentry-rule-response.json
else
  echo "Failed to create alert rule (HTTP ${http_status})." >&2
  cat /tmp/sentry-rule-response.json >&2
  exit 1
fi
