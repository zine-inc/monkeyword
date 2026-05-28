# Contributing to monkeyword

Thanks for your interest! This repository holds the open-source clients for the monkeyword SEO platform.

## Project layout

- `apps/apple/` — macOS + iOS (SwiftUI multiplatform package)
- `apps/windows/` — Windows (Tauri: Rust + web)
- `apps/shared-fixtures/` — shared sample data (mock mode)
- `n8n-nodes-monkeyword/` — n8n community node (TypeScript)

## Getting started

Each app has its own README with build instructions:

- macOS / iOS: [`apps/apple/README.md`](apps/apple/README.md)
- Windows: [`apps/windows/README.md`](apps/windows/README.md)
- n8n node: [`n8n-nodes-monkeyword/README.md`](n8n-nodes-monkeyword/README.md)

All apps run in **mock mode** out of the box — no backend or API key needed to build and explore.

## Pull requests

1. Fork and create a feature branch (`feat/...`, `fix/...`)
2. Keep changes focused; one logical change per PR
3. Make sure the relevant build / lint / test passes locally
4. Describe **what** changed and **why** in the PR body

## Code style

- **Swift**: follow the existing SwiftUI + `@Observable` patterns
- **TypeScript**: ESLint config in `n8n-nodes-monkeyword/`
- **Rust**: `cargo fmt` for the Tauri side
- Do not introduce dependencies on external AI APIs (OpenAI / Claude / Gemini). The platform's AI runs on a local LLM.

## Sample data

`apps/shared-fixtures/` contains **mock data only** (fictional `*.example` domains, no real metrics, no personal data). Please keep it that way — never add real keyword rankings, customer data, or credentials.

## Reporting security issues

See [SECURITY.md](SECURITY.md). Do not open public issues for vulnerabilities.
