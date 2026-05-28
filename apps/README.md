# monkeyword apps

Native client applications for the monkeyword SEO platform. All apps share the
same screens and the same sample data, so they look and behave consistently
across platforms.

## Platforms

| Path | Platform | Stack | Status |
|---|---|---|---|
| [`apple/`](apple/) | macOS + iOS | SwiftUI (multiplatform package) | Phase 1 (mock mode) |
| [`windows/`](windows/) | Windows | Tauri (Rust + web frontend) | Phase 1 (mock mode) |

## Shared sample data

[`shared-fixtures/`](shared-fixtures/) holds the mock JSON that every app reads.
Because all platforms load the same fixtures, screenshots line up 1:1 across
macOS, iOS, and Windows.

The fixtures contain **mock data only**: a demo project on
`monkeyword.1stop.direct`, fictional competitor domains (`*.example`), and no
personal data or real credentials.

## Mock mode

In Phase 1 the apps run entirely offline against the bundled fixtures. A
persistent **"Mock Mode"** banner is shown so it is always clear the data is
sample data. The hosted backend connects in Phase 2; the data-access layer is
written so only the repository implementation needs to swap (mock → live).

## Screens

Onboarding · Dashboard · Keyword Research · Rank Tracking · Backlink Analysis ·
Site Audit · Competitor Analysis · Content Brief · AI Coach · Settings

## License

[MIT](../LICENSE) © 2026 ZINE Inc.
