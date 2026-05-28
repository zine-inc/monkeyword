# monkeyword Windows

Windows native desktop client built with Tauri v2, SvelteKit, TypeScript, and Rust.

Phase 1 is **Mock Mode only**. The app reads bundled fixtures from
`apps/shared-fixtures/` and does not call a live API.

## Requirements

- Node.js 20+
- npm 10+
- Rust stable
- Windows build: run on `windows-latest` or a Windows machine with the Tauri prerequisites

## Development

```bash
cd apps/windows
npm install
npm run dev
```

For the native shell:

```bash
cd apps/windows
npm run tauri dev
```

## Verification

```bash
cd apps/windows
npm run check
npm run build
cd src-tauri
cargo check
```

Phase 1 CI verifies the SvelteKit frontend (`npm run check` / `npm run build`)
on Linux. The Rust `cargo check` and Windows installers (`.exe` / `.msi`) are
planned for Phase 2 CI on `windows-latest`.

## Mock data

The Tauri bundle includes:

- `../../shared-fixtures/data/*.json`
- `../../shared-fixtures/schema/job_kinds.json`

The frontend also uses the same fixtures as a browser-preview fallback when it
is not running inside Tauri.

## 日本語

Windows native クライアントです。Tauri v2、SvelteKit、TypeScript、Rust で構成しています。

Phase 1 は **Mock Mode 固定** です。アプリは `apps/shared-fixtures/` の同梱 fixture を読み込み、実 API には接続しません。

### 開発

```bash
cd apps/windows
npm install
npm run dev
```

ネイティブシェルで起動する場合:

```bash
cd apps/windows
npm run tauri dev
```

### 検証

```bash
cd apps/windows
npm run check
npm run build
cd src-tauri
cargo check
```

Phase 1 の CI は Linux 上で SvelteKit frontend (`npm run check` / `npm run build`) を検証します。Rust の `cargo check` と Windows installer (`.exe` / `.msi`) は Phase 2 で `windows-latest` CI 化予定です。
