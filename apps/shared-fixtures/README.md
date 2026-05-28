# monkeyword mock fixtures

このディレクトリは、monkeyword の Native アプリ 3 OS（macOS SwiftUI / iOS / Windows Tauri）が同じ画面を描画するための共有 mock fixtures です。

## Schema 契約

- すべての JSON は UTF-8、末尾 newline、camelCase キーです。
- JSON のトップレベルは配列、または `job_kinds.json` のみ `{ "kinds": [], "generatedFrom": "...", "version": 1 }` です。
- 日時は ISO8601 文字列です。ランク履歴の `date` のみ `YYYY-MM-DD` です。
- 未完了ジョブの `completedAt` は `null` です。
- `position` と `prevPosition` は、順位が取れない場合のみ `null` です。
- `serpFeatures` は `paa`, `image_pack`, `local_pack`, `video` のみを使います。
- `status` 系 enum は、各 JSON の用途ごとに指定値だけを使います。
- 競合・参照元ドメインは RFC 2606 に従い、すべて架空の `*.example` です。

## Seed 規約

- Seed 名: `monkeyword-marketing-demo-v1`
- 基準日: `2026-05-28`
- 生成範囲: ランク履歴は `2026-05-22` から `2026-05-28` までの 7 日間です。
- 主役プロジェクトは `proj_demo` で、`monkeyword.1stop.direct` を対象にしています。
- 画面確認で同じ見た目になるよう、ID、日時、順位推移、スコアは固定値です。
- 公開 OSS に同梱できるよう、個人情報、実在競合名、機密値、内部ホスト名は含めません。
