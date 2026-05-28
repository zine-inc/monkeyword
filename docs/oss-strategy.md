# Open-source strategy

monkeyword is split across two repositories with a clear boundary.

## This repository — open source (MIT)

`zine-inc/monkeyword` contains the **client applications and developer integrations**:

- Native apps for macOS, iOS, and Windows
- The n8n community node
- Shared sample data used in mock mode
- Public documentation

Anyone may build, run, modify, and redistribute everything here under the [MIT license](../LICENSE).

## The hosted backend — managed service

The keyword data pipeline, ranking engine, and local-LLM orchestration run as a **managed service**. That backend is operated separately and is not part of this repository.

## Why split it this way?

- **Privacy.** The apps never send your data to third-party AI APIs. AI inference runs on a local LLM operated by the managed service — not OpenAI, Claude, or Gemini.
- **Transparency.** The code that runs on your machine — the apps — is fully open and auditable.
- **Sustainability.** The managed backend funds ongoing development, while the clients stay free and open source.

## Connecting to a backend

In **Phase 1** the apps run in **mock mode** with the bundled sample data in [`apps/shared-fixtures/`](../apps/shared-fixtures/) — no account or API key required.

In **Phase 2** the apps connect to the hosted backend over a documented REST API. The data-access layer is written so that only the repository implementation swaps (mock → live); the UI and view models stay the same. You can also point the apps at your own compatible backend through **Settings**.

## Job kinds contract

The set of job kinds the apps understand is published as
[`apps/shared-fixtures/schema/job_kinds.json`](../apps/shared-fixtures/schema/job_kinds.json).
This is the single contract shared by every client. See
[`tools/gen_job_kinds.py`](../tools/gen_job_kinds.py) for how it is validated.
