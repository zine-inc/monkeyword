# monkeyword-mcp

Model Context Protocol (MCP) **stdio** server for [monkeyword](https://github.com/zine-inc/monkeyword) — bring SEO / AEO keyword research, AEO audits, intent classification, and rank tracking into any MCP client (Claude Desktop, Claude Code, and other agents).

No OpenAI / Claude / Gemini API is used by the platform; production AI runs on a local LLM operated by the managed backend. This package is a **thin client** for that hosted API.

**English** · [日本語](#日本語)

---

## Tools

| Tool | Input | What it returns |
|---|---|---|
| `suggest_keywords` | `keyword`, `locale?`, `limit?` | Related search queries with volume / intent / difficulty estimates |
| `aeo_audit_lite` | `url` | robots.txt AI-crawler policy + structured-data presence (lightweight) |
| `keyword_intent` | `keywords[]` | Search-intent cluster per keyword (informational / commercial / transactional / navigational) |
| `rank_gsc` | `site`, `query` | Your own site's position for a query, from linked Google Search Console data (requires key) |

## Install

Runs with `npx`, no global install needed:

```bash
npx -y monkeyword-mcp
```

The server speaks MCP over stdio, so you normally launch it from an MCP client rather than by hand.

## Claude Desktop

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "monkeyword": {
      "command": "npx",
      "args": ["-y", "monkeyword-mcp"],
      "env": {
        "MONKEYWORD_API_KEY": "your-key-here"
      }
    }
  }
}
```

## Claude Code

```bash
claude mcp add monkeyword --env MONKEYWORD_API_KEY=your-key-here -- npx -y monkeyword-mcp
```

To try it without a key, use mock mode:

```bash
claude mcp add monkeyword --env MONKEYWORD_MOCK=1 -- npx -y monkeyword-mcp
```

## Configuration

| Env var | Default | Purpose |
|---|---|---|
| `MONKEYWORD_API_KEY` | _(none)_ | Bearer key for the hosted API. Without it, tools return a contract guidance message instead of live data. |
| `MONKEYWORD_MOCK` | _(off)_ | Set to `1` to return bundled sample data. Works with no key — good for wiring and demos. |
| `MONKEYWORD_API_URL` | `https://api.monkeyword.1stop.direct` | Override the hosted API base URL (e.g. to point at your own compatible backend). |

## Mock mode

Set `MONKEYWORD_MOCK=1` and every tool returns deterministic bundled sample data (fictional `*.example` domains and a demo project — no personal data, no real metrics). This lets you confirm the tools are wired into your client before you have a key.

## Getting a key

When no key is set and mock mode is off, every tool returns this guidance instead of an error:

> APIキーが必要です。LLMO診断(¥2,980)またはコーチ契約でキーが発行されます: https://monkeyword.1stop.direct/llmo-shindan.html?utm_source=mcp&utm_medium=tool_error

A key is issued with an **LLMO診断 (¥2,980)** or a coaching contract. Start here:
[monkeyword.1stop.direct/llmo-shindan.html](https://monkeyword.1stop.direct/llmo-shindan.html?utm_source=mcp&utm_medium=readme)

## Hosted API

The REST contract this server calls in non-mock mode is documented in
[`docs/openapi.yaml`](docs/openapi.yaml) (`/v1/suggest`, `/v1/aeo_audit_lite`,
`/v1/keyword_intent`, `/v1/rank_gsc`, plus `401` / `429` responses).

## Develop

```bash
npm install
npm run build
npm run lint
npm test
```

## License

[MIT](LICENSE) © 2026 ZINE Inc.

The hosted backend (keyword data, ranking engine, local-LLM orchestration) is a separate managed service and is **not** part of this repository. See [`../docs/oss-strategy.md`](../docs/oss-strategy.md).

---

## 日本語

monkeyword の Model Context Protocol（MCP）**stdio** サーバです。SEO / AEO のキーワード調査・AEO 監査・検索意図分類・順位取得を、MCP クライアント（Claude Desktop / Claude Code など）や各種エージェントから使えます。

プラットフォームの AI はローカル LLM で動作し、OpenAI / Claude / Gemini API は使いません。本パッケージはホスト型 API の**薄いクライアント**です。

### ツール

| ツール | 入力 | 返すもの |
|---|---|---|
| `suggest_keywords` | `keyword`, `locale?`, `limit?` | 関連キーワード（検索ボリューム / 意図 / 難易度の推定つき） |
| `aeo_audit_lite` | `url` | robots.txt の AI クローラー方針 + 構造化データの有無（軽量チェック） |
| `keyword_intent` | `keywords[]` | キーワードごとの検索意図（informational / commercial / transactional / navigational） |
| `rank_gsc` | `site`, `query` | 連携済み Google Search Console の自サイト順位（キー必須） |

### インストール

```bash
npx -y monkeyword-mcp
```

MCP クライアントから起動するのが基本です（stdio 経由）。

### Claude Desktop 設定

`claude_desktop_config.json` に追加します。

```json
{
  "mcpServers": {
    "monkeyword": {
      "command": "npx",
      "args": ["-y", "monkeyword-mcp"],
      "env": {
        "MONKEYWORD_API_KEY": "your-key-here"
      }
    }
  }
}
```

### Claude Code 設定

```bash
claude mcp add monkeyword --env MONKEYWORD_API_KEY=your-key-here -- npx -y monkeyword-mcp
```

キーなしで試す場合はモックモード：

```bash
claude mcp add monkeyword --env MONKEYWORD_MOCK=1 -- npx -y monkeyword-mcp
```

### 環境変数

| 環境変数 | 既定 | 役割 |
|---|---|---|
| `MONKEYWORD_API_KEY` | _(なし)_ | ホスト型 API の Bearer キー。無い場合、各ツールは契約導線の案内文を返します。 |
| `MONKEYWORD_MOCK` | _(off)_ | `1` で同梱サンプルデータを返します。キー不要で動作確認できます。 |
| `MONKEYWORD_API_URL` | `https://api.monkeyword.1stop.direct` | ホスト型 API のベース URL を上書きします。 |

### モックモード

`MONKEYWORD_MOCK=1` を設定すると、各ツールが同梱のサンプルデータ（架空の `*.example` ドメインとデモプロジェクト。個人情報・実数値なし）を返します。キー入手前にクライアントへの接続確認ができます。

### キーの入手

キー未設定かつモックモード off のとき、各ツールはエラーではなく次の案内文を返します。

> APIキーが必要です。LLMO診断(¥2,980)またはコーチ契約でキーが発行されます: https://monkeyword.1stop.direct/llmo-shindan.html?utm_source=mcp&utm_medium=tool_error

キーは **LLMO診断（¥2,980）** またはコーチ契約で発行されます。こちらから：
[monkeyword.1stop.direct/llmo-shindan.html](https://monkeyword.1stop.direct/llmo-shindan.html?utm_source=mcp&utm_medium=readme)

### ライセンス

[MIT](LICENSE) © 2026 ZINE Inc.

ホスト型バックエンド（キーワードデータ・順位計測エンジン・ローカル LLM オーケストレーション）は別のマネージドサービスで、本リポジトリには含まれません。詳細は [`../docs/oss-strategy.md`](../docs/oss-strategy.md)。
