# npm publish checklist — n8n-nodes-monkeyword

Status: **prepared, not yet published.** `npm publish` and the n8n verified-node
application are intentionally **not executed** as part of this checklist — both
require an explicit go-ahead (see the repository-level publish/deploy approval
gate) before they run. This document is the runbook for the person who executes
that approval.

## 1. Pre-publish checklist (already satisfied on `main`)

- [ ] `npm run build` succeeds (`tsc` + icon copy into `dist/`)
- [ ] `npm run lint` is clean (`eslint-plugin-n8n-nodes-base` rules included)
- [ ] `npm test` is green (Jest)
- [ ] `package.json`
  - [ ] `version` bumped (semver; this checklist assumes `0.2.0` is the first
        published version)
  - [ ] `engines.node` set (`>=20`)
  - [ ] `files` limited to `dist` + `index.js` (no `src`, `tests`, config files
        ship to npm)
  - [ ] `keywords` includes `n8n-community-node-package`
  - [ ] `repository`, `homepage`, `bugs` point at `zine-inc/monkeyword`
  - [ ] no `dependencies` beyond `peerDependencies` (`n8n-workflow`) — required
        for verified-node review (zero extra runtime deps)
- [ ] `README.md` is in **English**, documents Credentials / Operations / Mock
      Mode, and links to the API-key signup flow with `utm_source=n8n`
- [ ] Credential default `baseUrl` points at the production API
      (`https://api.monkeyword.1stop.direct`), not a placeholder/staging host
- [ ] Live-mode (`Mock Mode` off) execution without an API key throws a clear
      `NodeOperationError` that links to the signup page — verified by
      `tests/node.test.ts`
- [ ] Leak-grep self-check run against the diff (see PR description for the
      command and result) — no internal hostnames, Slack IDs, AWS account IDs,
      or secret-shaped strings in tracked files

## 2. npm account / org (confirm before first publish)

1. Check whether an npm organization named `zine-inc` already exists:
   - `npm org ls zine-inc` (if logged in), or check
     `https://www.npmjs.com/org/zine-inc` directly.
2. If it does not exist yet, decide the publishing identity:
   - **Option A (recommended):** create the `zine-inc` npm org and publish
     `n8n-nodes-monkeyword` under it (ownership on npm; the package name itself
     stays unscoped — n8n community nodes must be named `n8n-nodes-*`, not
     `@zine-inc/n8n-nodes-*`, to be installable/discoverable from the n8n
     Community Nodes UI).
   - **Option B (fallback):** publish from an individual maintainer's npm
     account first, then transfer ownership (`npm owner add`) to the org once
     it exists. Slower to redo later — prefer Option A if there is no blocker.
3. Enable **two-factor authentication** on the publishing npm account. npm
   requires 2FA (or a token with the `automation` type plus 2FA on the account)
   for publishing new packages.
4. Generate an **Automation** npm access token scoped to publish, and store it
   in 1Password (SSoT — never in repo, CI YAML literals, or chat). Follow the
   existing `secure-credentials` pattern used for other service tokens in this
   org.
5. If publishing via GitHub Actions later (see §5), load the token through the
   1Password `load-secrets-action` the same way other CI secrets are wired —
   do not add it as a raw `secrets.*` GitHub Actions secret unless it's a
   bootstrap-only exception.

## 3. Publish steps

Run from `n8n-nodes-monkeyword/`, on a clean checkout of the release commit:

```
npm ci
npm run build
npm run lint
npm test
npm publish --access public
```

- `prepack` already runs `npm run build` automatically before packing, but
  running it explicitly first lets you catch failures before `publish` starts.
- `--access public` is required the first time an unscoped-but-new package is
  published under an org-owned npm account with default private-first
  settings; harmless to keep on subsequent publishes.
- Immediately after: verify the listing at
  `https://www.npmjs.com/package/n8n-nodes-monkeyword` (version, README
  rendering, files tab shows only `dist/` + `index.js`).

## 4. Post-publish smoke test (must pass before announcing)

1. In a scratch n8n instance (local or disposable container), install via
   **Settings → Community Nodes → Install**, package name
   `n8n-nodes-monkeyword`.
2. Add a **Monkeyword API** credential with `Mock Mode` on (default) — run the
   **Suggest Keywords** node and confirm deterministic mock JSON returns with
   no outbound HTTP request.
3. Switch `Mock Mode` off with no API key set — confirm the node throws the
   expected error and the signup link in the message is reachable.
4. Switch `Mock Mode` off with a real API key against the production API —
   confirm a live suggestion response returns (this step depends on the
   backend being reachable and a key being issued; skip with a note if the
   backend isn't live yet, but do not skip step 2–3).

## 5. n8n verified-node application

Reference: n8n's community node submission guidelines (Creator Portal).

1. Confirm the package already meets n8n's verification bar:
   - [ ] Package name starts with `n8n-nodes-`
   - [ ] `n8n-community-node-package` keyword present
   - [ ] Node + credential ship with `n8nNodesApiVersion` set and the icon SVG
         is bundled in `dist/`
   - [ ] No runtime dependencies beyond `n8n-workflow` (peer dep only)
   - [ ] README in English with clear install/credentials/operations docs
   - [ ] Repository is public, has a `LICENSE` (MIT), and builds/lints/tests
         pass in CI (`.github/workflows/n8n-node-build.yml`)
   - [ ] Package integrates with exactly **one** external service (monkeyword)
2. Submit via the n8n Creator Portal (`n8n.io` → Community Nodes → submit for
   verification). You will need: npm package URL, GitHub repo URL, a short
   description, and a contact email.
3. **Provenance (npm package provenance via GitHub Actions OIDC)** is a
   nice-to-have n8n looks for but is **not required to start the verification
   review**. This repo does not currently publish via GitHub Actions (GitHub
   Actions billing is paused — see the parent plan). Revisit provenance-based
   publishing once GHA billing resumes; until then, publish manually per §3
   with an npm token from 1Password.
4. Track review status; n8n verification review is manual and can take days
   to weeks. Respond to any reviewer feedback (they may request README or
   node behavior changes) as follow-up commits + a version bump + republish.
5. Once verified, the node gets a "Verified" badge and is discoverable from
   the in-app Community Nodes installer without users needing "Community
   Nodes" risk-acknowledgement toggles (n8n Cloud installs it directly).

## 6. Rollback / troubleshooting

- **Unpublish window:** npm allows `npm unpublish n8n-nodes-monkeyword@<version>`
  only within 72 hours of publishing, and only if no other package depends on
  it. After that, use `npm deprecate` with a message pointing to the fixed
  version instead of unpublishing.
- **Bad release:** publish a patch/minor version with the fix; do not try to
  overwrite an already-published version (npm rejects re-publishing the same
  version number).
- **Wrong publishing account/org:** `npm owner add <user> n8n-nodes-monkeyword`
  / `npm owner rm <user> n8n-nodes-monkeyword` to fix ownership without a
  republish.
