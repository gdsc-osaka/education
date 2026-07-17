# WebMCP 講義パート調査資料

調査日: 2026-07-17

`webmcp-agent/claat.md` の「MCP / WebMCP 概論」と、各実装ステップの概念説明を改善するための調査資料です。

## ファイル構成

- [research-notes.md](research-notes.md): 仕様、背景、動機、API、ユースケース、セキュリティの統合メモ
- [lecture-recommendations.md](lecture-recommendations.md): 現在の `claat.md` に対する修正・追記候補
- [source-audit.md](source-audit.md): 情報源ごとの位置づけ、鮮度、採用時の注意点
- `img/`: 引用候補画像。各 PNG と同名の `.png.meta` に出典 URL を保存

## 読み方

講義本文を直すときは、まず `lecture-recommendations.md` の構成案を確認し、根拠や補足が必要な箇所だけ `research-notes.md` を参照してください。API の正誤は、ブログよりも 2026-07-10 公開の WebMCP Draft Community Group Report を優先しています。

## 重要な結論

1. WebMCP は MCP のブラウザ版 transport ではなく、MCP を置き換えるものでもない。ブラウザ、DOM、オリジン、タブのライフサイクルに合わせた Web API である。
2. 中心的な価値は、画面を推測して操作する brittle な actuation を、意味・入力・実行処理が明示された tool で補うことにある。
3. WebMCP tool は開いている `Document` に結びつく。ログイン状態、現在の UI、既存のクライアントロジックを共有できる一方、タブを閉じれば利用できない。
4. 命令型 API の現在の入口は `document.modelContext.registerTool()`。`navigator.modelContext` は Chrome 150 で非推奨と案内されている。
5. 宣言型 API は Chrome で試せるが、仕様本文の節とフォームから JSON Schema を合成するアルゴリズムはまだ TODO/TBD である。
6. `readOnlyHint` と `untrustedContentHint` は安全性の保証ではなく、agent の判断を助ける hint である。認証・認可、入力検証、ユーザー確認はアプリ側にも必要である。

