# monkeyword

> AI-powered SEO keyword research with a **local LLM**. Open-source desktop & mobile clients for macOS, iOS, and Windows — plus an n8n community node.

ahrefs / Surfer / GRC 相当の機能を 1 本に。AI が「次の打ち手」を提案します。検索意図の分類からコンテンツ構成案まで、すべて **ローカル LLM** で処理 — あなたのデータは外部 AI API に送られません。

**English** · [日本語](#日本語)

---

## What is monkeyword?

monkeyword is the open-source **client suite** for the monkeyword SEO platform. The apps in this repository talk to a hosted backend (a managed service) over a documented REST API.

- **Desktop & mobile apps** — macOS, iOS, Windows
- **n8n community node** — run keyword research inside your automation workflows
- **Privacy-first** — all AI runs on a local LLM; no OpenAI / Claude / Gemini API is used
- **Beginner-friendly** — enter a domain, get a week of concrete actions from the AI coach
- **Multilingual** — Japanese & English (more languages planned)

## Repository layout

| Path | What |
|---|---|
| `apps/apple/` | macOS + iOS app (SwiftUI, single multiplatform package) |
| `apps/windows/` | Windows app (Tauri: Rust + web frontend) |
| `apps/shared-fixtures/` | Shared sample data so every platform renders the same screens |
| `n8n-nodes-monkeyword/` | n8n community node (TypeScript) |
| `tools/` | Developer tooling |
| `docs/` | Public documentation |

## Status

**Phase 1 — mock mode.** The apps ship with sample data (`apps/shared-fixtures/`) and run fully offline so you can explore the UI. The hosted backend connects in Phase 2.

A persistent **"Mock Mode"** banner is shown while sample data is in use.

## Quick start

- **macOS / iOS:** see [`apps/apple/README.md`](apps/apple/README.md)
- **Windows:** see [`apps/windows/README.md`](apps/windows/README.md)
- **n8n node:** see [`n8n-nodes-monkeyword/README.md`](n8n-nodes-monkeyword/README.md)

## License

[MIT](LICENSE) © 2026 ZINE Inc.

The hosted backend (keyword data, ranking engine, local-LLM orchestration) is a separate managed service and is **not** part of this repository. See [`docs/oss-strategy.md`](docs/oss-strategy.md).

---

## 日本語

monkeyword は、monkeyword SEO プラットフォームの **オープンソース・クライアント群** です。このリポジトリのアプリは、ドキュメント化された REST API 経由でホスト型バックエンド（マネージドサービス）と通信します。

- **デスクトップ & モバイルアプリ** — macOS / iOS / Windows
- **n8n コミュニティノード** — 自動化ワークフローの中でキーワード調査
- **プライバシー第一** — AI はすべてローカル LLM で処理。OpenAI / Claude / Gemini API は使いません
- **素人にやさしい** — ドメインを入れるだけで、AI コーチが 1 週間分の具体的アクションを提案
- **多言語** — 日本語・英語（今後拡大）

### 状態

**Phase 1 — モックモード。** アプリはサンプルデータ（`apps/shared-fixtures/`）を同梱し、完全オフラインで UI を確認できます。ホスト型バックエンドとの接続は Phase 2 です。サンプルデータ利用中は「Mock Mode」バナーが常時表示されます。

### ライセンス

[MIT](LICENSE) © 2026 ZINE Inc.

ホスト型バックエンド（キーワードデータ・順位計測エンジン・ローカル LLM オーケストレーション）は別のマネージドサービスで、本リポジトリには含まれません。詳細は [`docs/oss-strategy.md`](docs/oss-strategy.md)。
