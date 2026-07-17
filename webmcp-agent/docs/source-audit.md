# 情報源監査

調査日: 2026-07-17

## 優先順位

1. WebMCP Draft Community Group Report
2. WebMCP repository の Explainer / declarative explainer
3. Chrome for Developers の現行実装文書
4. MCP 公式文書
5. ユーザーブログ、検証記事

仕様の normative な形は 1、背景・動機・未決事項は 2、Chrome で実際に試す手順は 3 を使う。1 と 3 が異なる場合は「仕様」と「Chrome の試験実装」を分けて記述する。

## 指定された情報源

### WebMCP Draft Community Group Report

- URL: https://webmachinelearning.github.io/webmcp/
- 公開日表示: 2026-07-10
- 種別: Community Group の仕様ドラフト
- 採用: API shape、security model、status、用語の基準
- 注意: W3C Standard / Standards Track ではない。Declarative WebMCP 節は TODO。

### webmachinelearning/webmcp

- URL: https://github.com/webmachinelearning/webmcp
- 種別: 公式 Explainer と仕様 source
- 採用: 背景、goals / non-goals、use cases、alternatives、open questions
- 重要な補助文書: https://github.com/webmachinelearning/webmcp/blob/main/declarative-api-explainer.md
- 注意: Explainer の提案・open question を確定仕様として書かない。

### Chrome for Developers: WebMCP

- URL: https://developer.chrome.com/docs/ai/webmcp?hl=ja
- 公開日表示: 2026-05-18、最終更新 2026-06-09
- 種別: Chrome 実装・導入文書
- 採用: progressive enhancement、testing flag、origin trial、命令型 / 宣言型 API の入口、制限
- 注意: 日本語ページは機械翻訳の可能性がある。仕様より Chrome 実装が先行している箇所がある。

### Chrome for Developers: WebMCP と MCP の使い分け

- URL: https://developer.chrome.com/docs/ai/webmcp/compare-mcp?hl=ja
- 公開日表示: 2026-03-11、最終更新 2026-05-19
- 種別: 公式比較記事
- 採用: persistent vs ephemeral、backend vs live UI、両者を併用する設計
- 注意: 「MCP Apps」の UI と一般 MCP server の区別は初学者向け説明で単純化されているため、MCP 全体の定義には MCP 公式文書を使う。

### DevelopersIO 検証記事

- URL: https://dev.classmethod.jp/articles/exploring-webmcp-and-testing-it/
- 公開日表示: 2026-03-18
- 種別: 日本語ユーザーブログ / preview 実装検証
- 採用: testing flag、extension、tool list、call / result の screenshot、実装者がつまずく点
- 注意: `navigator.modelContext`、`unregisterTool()`、`provideContext()` は現在の仕様基準では古い。code の出典には使わない。

### MCP Introduction

- URL: https://modelcontextprotocol.io/docs/getting-started/intro
- 種別: MCP 公式入門
- 採用: MCP の定義、external system の例、標準化の意義
- 補助: https://modelcontextprotocol.io/docs/learn/architecture
- 注意: USB-C analogy は導入には便利だが、protocol の participant / layer 説明は architecture 文書を使う。

## 追加で参照した公式文書

| 文書 | URL | 用途 |
| --- | --- | --- |
| Imperative API | https://developer.chrome.com/docs/ai/webmcp/imperative-api?hl=ja | `document.modelContext`、AbortSignal、Chrome の discovery / execution API |
| Declarative API | https://developer.chrome.com/docs/ai/webmcp/declarative-api?hl=ja | form attribute、schema synthesis の Chrome 挙動 |
| User journeys | https://developer.chrome.com/docs/ai/webmcp/use-cases | shopping、form、support flow の例 |
| Best practices | https://developer.chrome.com/docs/ai/webmcp/best-practices | tool strategy、命名、schema、reliability、eval |
| Tool security | https://developer.chrome.com/docs/ai/webmcp/secure-tools | annotation、origin、character budget |
| Agent security | https://developer.chrome.com/docs/agents/security?hl=en | prompt injection と agent 側の defense-in-depth |

## 鮮度チェックで判明した変更

| 項目 | 旧 preview 情報 | 2026-07-17 時点の基準 |
| --- | --- | --- |
| global entry point | `navigator.modelContext` | `document.modelContext` |
| tool 解除 | `unregisterTool(name)` | registration に `AbortSignal` を渡して abort |
| tool 一括置換 | `provideContext()` | 現仕様の `ModelContext` interface にない |
| annotations | 主に `readOnlyHint` | `readOnlyHint` と `untrustedContentHint` |
| cross-origin | 実装依存の説明が多い | `tools` Permissions Policy と `exposedTo` |
| declarative | 属性例が具体的 | 属性は試験実装あり。ただし仕様本文は TODO のまま |

## 引用時のルール案

- 仕様状態を述べる文には Draft Community Group Report を付ける。
- 動機や use case は Explainer を付ける。
- Chrome flag や origin trial は Chrome 文書を付ける。
- screenshot を使う場合は `.png.meta` の URL を caption か直後の「出典」に記載する。
- ブログの API code は引用せず、preview 実装を試した記録として紹介する。

