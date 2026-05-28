# n8n-nodes-monkeyword

monkeyword community node for n8n — AI-powered SEO keyword research with local LLM.

No OpenAI / Claude / Gemini API used. All AI runs on local LLM (Qwen2.5).

Free tier: 10 requests/day. Server is managed SaaS at https://monkeyword.1stop.direct (Phase 2).

## English

### About

`n8n-nodes-monkeyword` adds monkeyword keyword research workflows to n8n as a community node.

Phase 1 ships the **Suggest Keywords** operation in Mock Mode: it returns deterministic mock JSON and does not call the production monkeyword API. Phase 2 will connect the node to the managed monkeyword SaaS API.

### Installation

Install from your n8n instance:

1. Open **Settings**.
2. Open **Community Nodes**.
3. Select **Install**.
4. Enter `n8n-nodes-monkeyword`.
5. Confirm the installation and restart n8n if your environment requires it.

### Credentials

Create a **Monkeyword API** credential with:

- `baseUrl`: API base URL. Default: `https://monkeyword.1stop.direct`
- `apiKey`: API key for monkeyword.
- `mockMode`: Keep enabled in Phase 1 to return mock JSON.

### Operations

Phase 1 exposes one operation:

- `Suggest Keywords`: returns keyword suggestions for SEO research.

### Mock Mode

Mock Mode is enabled by default in Phase 1. It lets n8n workflows be wired and tested before the real monkeyword API is available.

When Mock Mode is enabled, the node returns deterministic mock JSON and avoids any external API request.

### Publishing (maintainers)

Distribution artifacts in `dist/` are built automatically on `npm pack` / `npm publish` via the `prepack` script. Publishing to the npm registry is planned for Phase 2.

### License

MIT

## 日本語

### 概要

`n8n-nodes-monkeyword` は、monkeyword のキーワード調査を n8n から使うための community node です。

Phase 1 では **Suggest Keywords** operation を Mock Mode で提供します。決定的な mock JSON を返し、本番 monkeyword API には接続しません。Phase 2 で managed SaaS API に接続します。

### インストール

n8n の画面からインストールします。

1. **Settings** を開きます。
2. **Community Nodes** を開きます。
3. **Install** を選択します。
4. `n8n-nodes-monkeyword` を入力します。
5. インストールを確認し、環境に応じて n8n を再起動します。

### Credentials

**Monkeyword API** credential を作成します。

- `baseUrl`: API base URL。初期値は `https://monkeyword.1stop.direct`
- `apiKey`: monkeyword API key。
- `mockMode`: Phase 1 では有効のまま mock JSON を返します。

### Operation

Phase 1 の予定 operation は 1 つです。

- `Suggest Keywords`: SEO 調査向けのキーワード候補を返します。

### Mock Mode

Mock Mode は Phase 1 で標準有効です。実 API が利用可能になる前に、n8n workflow の接続と動作確認を進めるためのモードです。

Mock Mode が有効な場合、node 実装は外部 API リクエストを行わず、決定的な mock JSON を返します。

### License

MIT
