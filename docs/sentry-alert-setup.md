# Applying the Sentry-to-Slack alert rule

`sentry-alert-rule.json` (in the repo root) describes the issue alert from
Pattern 5: fire on a new/first-seen issue, route it to Slack with the issue
title and a deep link to the stack trace.

There are two ways to apply it.

## Option A — The Sentry UI (recommended for first-timers)

1. Connect Slack: **Settings > Integrations > Slack > Add Installation**, then
   authorize the workspace and channel.
2. Go to **Alerts > Create Alert Rule** and choose **Issues** (not Metrics).
3. Set the trigger **WHEN** to **A new issue is created**.
4. Add a filter **IF** the issue level is **equal to or greater than error**.
5. Set the action **THEN** to **Send a Slack notification** to your channel
   (e.g. `#prod-alerts`). Add the tags `environment` and `release` so the
   message shows where it happened.
6. In the notes field, paste:

   ```
   New issue: {{ issue.title }} — open the stack trace: {{ issue.url }}.
   Backfill the missing E2E test from this trace before closing.
   ```

7. Set the action interval to **30 minutes** so a noisy issue does not spam the
   channel, and save.

## Option B — The Sentry API

Replace the placeholders in `sentry-alert-rule.json`
(`YOUR_SLACK_WORKSPACE_ID`, `YOUR_SLACK_CHANNEL_ID`, and the `#prod-alerts`
channel) with your real values, then POST it. You need a Sentry auth token with
the `alerts:write` scope.

```bash
export SENTRY_AUTH_TOKEN="your-token"
ORG_SLUG="your-org"
PROJECT_SLUG="your-project"

curl -sS \
  -X POST \
  -H "Authorization: Bearer ${SENTRY_AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  "https://sentry.io/api/0/projects/${ORG_SLUG}/${PROJECT_SLUG}/rules/" \
  --data @sentry-alert-rule.json
```

A `201 Created` response means the rule is live.

## The point of the pattern

The alert is not the finish line. When it fires, the workflow is:

1. Open the stack trace from the Slack link.
2. Identify the user-facing flow that produced the error.
3. Write (or generate) the E2E test that reproduces it.
4. Land the test so the same class of bug fails in CI next time, not in prod.

This is how an alert that found a bug turns into a regression test that prevents
it. Autonoma automates step 3: point it at the stack trace and it generates the
end-to-end test that covers the broken flow.
