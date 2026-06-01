# Catch bugs before Sentry does: 5 pre-deploy patterns

Companion configs for the 5 pre-deploy patterns playbook: a GitHub Actions E2E preview workflow, a tsconfig strict-mode block, a Husky + lint-staged setup, a Neon database-branching workflow, and a Sentry-to-Slack alert rule.

> Companion code for the Autonoma blog post: **[How Do You Catch Bugs Before Sentry Does?](https://www.getautonoma.com/blog/catch-bugs-before-sentry-pre-deploy-patterns)**

This repo is reference material. Each file is a real, copy-pasteable config for one of the five patterns in the post. They are meant to be dropped into your own project (adjust secrets, channel names, and project ids), not run as a standalone app.

## The five patterns

<table>
<thead>
<tr><th>#</th><th>Pattern</th><th>File(s)</th><th>What it catches before Sentry</th></tr>
</thead>
<tbody>
<tr>
  <td>1</td>
  <td>E2E tests against a per-PR preview deployment</td>
  <td><code>.github/workflows/e2e-preview.yml</code></td>
  <td>Bugs that only appear against deployed infra: env vars, edge config, cold starts.</td>
</tr>
<tr>
  <td>2</td>
  <td>TypeScript strict mode as a CI gate</td>
  <td><code>tsconfig.strict.json</code>, <code>.github/workflows/typecheck.yml</code></td>
  <td>Null derefs, implicit anys, unchecked array access. <code>tsc --noEmit</code> fails the build.</td>
</tr>
<tr>
  <td>3</td>
  <td>Husky + lint-staged pre-commit hook</td>
  <td><code>package.json</code> (lint-staged block), <code>.husky/pre-commit</code></td>
  <td>Lint errors and broken related tests, blocked at commit time before they reach the branch.</td>
</tr>
<tr>
  <td>4</td>
  <td>Neon database branch per PR</td>
  <td><code>.github/workflows/neon-preview-branch.yml</code></td>
  <td>Migration and data-shape bugs, isolated to a throwaway DB branch instead of production.</td>
</tr>
<tr>
  <td>5</td>
  <td>Sentry-to-Slack triage with test backfill</td>
  <td><code>sentry-alert-rule.json</code>, <code>docs/sentry-alert-setup.md</code></td>
  <td>The escape hatch: when something does slip through, route it to Slack and backfill the missing E2E test from the stack trace.</td>
</tr>
</tbody>
</table>

## Requirements

Pattern-specific, since each config targets a different tool:

- **Patterns 1, 2, 4** — GitHub Actions; Node 20+ in CI. Pattern 1 assumes a Vercel-style preview deployment; pattern 4 assumes a Neon project with `NEON_API_KEY` and `NEON_PROJECT_ID` secrets.
- **Pattern 3** — Node 18+ locally, plus `husky` and `lint-staged` as dev dependencies.
- **Pattern 5** — A Sentry project with the Slack integration connected.

## Quickstart

Each pattern is adopted independently. The most common starting point is the local pre-commit hook:

```bash
git clone https://github.com/Autonoma-Tools/catch-bugs-before-sentry-pre-deploy-patterns.git
cd catch-bugs-before-sentry-pre-deploy-patterns

# Pattern 3 — install the pre-commit hook in your own project
npm install --save-dev husky lint-staged
npx husky init
# then copy the "lint-staged" block from package.json and the .husky/pre-commit body
```

For the GitHub Actions patterns, copy the relevant file from `.github/workflows/` into your repo and set the secrets it references. For Sentry, follow `docs/sentry-alert-setup.md`.

## Project structure

```
.
├── .github/
│   └── workflows/
│       ├── e2e-preview.yml            # Pattern 1
│       ├── typecheck.yml              # Pattern 2
│       └── neon-preview-branch.yml    # Pattern 4
├── .husky/
│   └── pre-commit                     # Pattern 3
├── docs/
│   └── sentry-alert-setup.md          # Pattern 5 — how to apply the rule
├── examples/
│   └── apply-sentry-alert.sh          # Pattern 5 — one-shot apply script
├── tsconfig.strict.json               # Pattern 2
├── package.json                       # Pattern 3 — lint-staged config
├── sentry-alert-rule.json             # Pattern 5
├── LICENSE
└── README.md
```

- `.github/workflows/` — CI workflows for patterns 1, 2, and 4.
- `.husky/` — the git pre-commit hook for pattern 3.
- `docs/` — setup notes for the Sentry alert rule.
- `examples/` — a runnable script that applies the Sentry alert via the API.

## About

This repository is maintained by [Autonoma](https://getautonoma.com) as reference material for the linked blog post. Autonoma builds autonomous AI agents that plan, execute, and maintain end-to-end tests directly from your codebase, which is exactly how you turn a Sentry stack trace (Pattern 5) into a regression test that prevents the next incident.

If something here is wrong, out of date, or unclear, please [open an issue](https://github.com/Autonoma-Tools/catch-bugs-before-sentry-pre-deploy-patterns/issues/new).

## License

Released under the [MIT License](./LICENSE) © 2026 Autonoma Labs.
