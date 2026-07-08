# n8n-nodes-monkeyword

An [n8n](https://n8n.io) community node for **monkeyword** — AI-powered SEO keyword
research backed by a local LLM.

`n8n-nodes-monkeyword` lets you expand a seed keyword into related search queries
(with an estimated search volume, intent cluster, and keyword-difficulty score)
directly inside an n8n workflow.

## What it does

- **One service, one package.** This package integrates with a single service:
  the monkeyword API.
- **No third-party AI API calls.** Live requests are served by monkeyword's own
  backend, which runs inference on a local LLM — never OpenAI, Claude, or Gemini.
- **Works without an account.** `Mock Mode` is on by default, so you can build and
  test workflows with deterministic sample data before you have an API key.

## Install

From your n8n instance:

1. Open **Settings**.
2. Open **Community Nodes**.
3. Select **Install**.
4. Enter `n8n-nodes-monkeyword`.
5. Confirm the installation and restart n8n if your environment requires it.

Or, for a self-hosted instance:

```
npm install n8n-nodes-monkeyword
```

Requires n8n running on **Node.js 20 or later**.

## Credentials

Create a **Monkeyword API** credential with:

| Field | Description | Default |
|---|---|---|
| `Base URL` | Base URL of the monkeyword API. | `https://api.monkeyword.1stop.direct` |
| `API Key` | Your monkeyword API key. Required only when Mock Mode is off. | (empty) |
| `Mock Mode` | Return deterministic sample JSON without calling the API. | `true` |

Don't have an API key yet? Start the free LLMO diagnostic to get one:
**https://monkeyword.1stop.direct/llmo-shindan.html?utm_source=n8n&utm_medium=readme**

An API key is also issued with the weekly SEO coach plan. Running the node with
Mock Mode off and no API key returns a clear error pointing back to this link —
it never fails silently.

## Operations

- **Suggest Keywords** — expands a seed keyword into related search queries.
  Parameters: `Keyword` (required), `Language (hl)`, `Country (gl)`, `Limit`.

## Mock Mode

Mock Mode is **on by default**. While it is on, the node never makes an outbound
HTTP request — it returns deterministic, seeded mock JSON so you can wire and test
workflows offline. Turn it off once you have an API key to call the live API.

## Development

```
npm install
npm run build   # tsc + copy icon assets into dist/
npm run lint    # eslint (includes eslint-plugin-n8n-nodes-base rules)
npm test        # jest
```

## Contributing

Issues and pull requests are welcome at
[zine-inc/monkeyword](https://github.com/zine-inc/monkeyword).

## License

[MIT](./LICENSE)
