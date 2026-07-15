---
marp: true
theme: gdg
paginate: true
size: 16:9
---

<script>
/* PowerPoint-style auto-shrink: iteratively reduce a slide's font size
   until its content stops overflowing. Also keeps the explicit opt-in
   <div class="fit">…</div> wrapper for finer-grained scaling. */
(() => {
  const MIN_FONT_PX = 12;
  const CODE_MIN_FONT_PX = 9;
  const STEP = 0.96;
  const MAX_ITERS = 40;
  const TOLERANCE = 1;
  let scheduled = false;

  const overflows = (el) =>
    el.scrollHeight > el.clientHeight + TOLERANCE ||
    el.scrollWidth  > el.clientWidth  + TOLERANCE;

  const shrinkElement = (el, minFontPx, shouldShrink = () => overflows(el)) => {
    if (!shouldShrink()) return;
    const base = parseFloat(getComputedStyle(el).fontSize) || 18;
    let size = base;
    for (let i = 0; i < MAX_ITERS && shouldShrink() && size > minFontPx; i++) {
      size *= STEP;
      el.style.fontSize = `${size}px`;
    }
  };

  const shrinkCodeBlocks = (section) => {
    for (const pre of section.querySelectorAll("pre")) {
      shrinkElement(pre, CODE_MIN_FONT_PX, () => overflows(pre) || overflows(section));
    }
  };

  const shrinkSection = (section) => {
    if (section.dataset.autofit === "skip") return;
    shrinkElement(section, MIN_FONT_PX, () => overflows(section));
  };

  const scaleFitBlocks = (root) => {
    for (const fit of root.querySelectorAll(".fit")) {
      if (!fit.scrollHeight) continue;
      const ratio = Math.min(1, fit.clientHeight / fit.scrollHeight);
      fit.style.transformOrigin = "top left";
      fit.style.transform = `scale(${ratio})`;
    }
  };

  const processSection = (section) => {
    if (!section.clientWidth || !section.clientHeight) return;
    scaleFitBlocks(section);
    shrinkCodeBlocks(section);
    shrinkSection(section);
  };

  const processVisibleSections = () => {
    scheduled = false;
    for (const section of document.querySelectorAll("section")) processSection(section);
  };

  const schedule = () => {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => requestAnimationFrame(processVisibleSections));
  };

  window.addEventListener("load", schedule);
  window.addEventListener("resize", schedule);
  new MutationObserver(schedule).observe(document.documentElement, {
    subtree: true,
    attributes: true,
    attributeFilter: ["class"],
  });
  schedule();
})();
</script>

<style>
/* Set once per deck — drives the colored university name on every title slide. */
:root { --gdg-university: 'University of Osaka'; }
</style>

<!-- _class: title -->
<!-- _paginate: false -->

# 自作シェルで学ぶ **OS の裏側**

コマンドを打つと、その裏で何が起きているのか

---

<!-- _class: section -->

# 00. まず全体像をつかもう

---

## コンピュータは「5 つの層」でできている

<div style="display: flex; flex-direction: column; align-items: center; gap: 0; margin-top: 12px;">
  <div style="width: 80%; padding: 16px 24px; background: var(--gdg-blue); color: #fff; border-radius: 12px 12px 0 0; text-align: center; font-weight: 600; font-size: 1.05em;">
    ユーザーアプリ<br>
    <span style="font-size: 0.72em; font-weight: 400;">Web ブラウザ、エディタなど — あなたが普段使うソフト</span>
  </div>
  <div style="font-size: 20px; color: #5F6368; line-height: 1.1;">▼</div>
  <div style="width: 80%; padding: 16px 24px; background: var(--gdg-yellow); color: var(--gdg-ink); text-align: center; font-weight: 600; font-size: 1.05em; border: 2px solid #E8AD00;">
    シェル ← 今日の主役!<br>
    <span style="font-size: 0.72em; font-weight: 400;">あなたとカーネルの仲介役 — コマンドを受け取る</span>
  </div>
  <div style="font-size: 20px; color: #5F6368; line-height: 1.1;">▼</div>
  <div style="width: 80%; padding: 16px 24px; background: var(--gdg-green); color: #fff; text-align: center; font-weight: 600; font-size: 1.05em;">
    標準ライブラリ<br>
    <span style="font-size: 0.72em; font-weight: 400;">printf, chdir など — 呼び出しを簡単にするラッパー</span>
  </div>
  <div style="font-size: 20px; color: var(--gdg-red); line-height: 1.1; font-weight: 600;">▼ システムコール</div>
  <div style="width: 80%; padding: 16px 24px; background: var(--gdg-red); color: #fff; text-align: center; font-weight: 600; font-size: 1.05em;">
    OS カーネル<br>
    <span style="font-size: 0.72em; font-weight: 400;">Linux カーネル — 全体の司令塔（特権モード）</span>
  </div>
  <div style="font-size: 20px; color: #5F6368; line-height: 1.1;">▼</div>
  <div style="width: 80%; padding: 16px 24px; background: #5F6368; color: #fff; border-radius: 0 0 12px 12px; text-align: center; font-weight: 600; font-size: 1.05em;">
    デバイス<br>
    <span style="font-size: 0.72em; font-weight: 400;">CPU、メモリ、SSD、キーボード — 物理的な電子部品</span>
  </div>
</div>

---

## OS = この全体を動かしている仕組み

- **カーネル + 標準ライブラリ** が「OS」と呼ばれる部分
- **シェル**はユーザーアプリとカーネルの間に立つ、特別なプログラム
- あなたが打ったコマンドは、シェル → ライブラリ → カーネル → デバイスと流れていく

> 今日はこの 5 層のつながりを、**自作シェル**で体験しよう!

---

## 今日の流れ

1. プロセス — 仕事の単位
2. なぜプログラムはハードウェアを触れないのか
3. システムコール — カーネルへの「お願い」
4. シェル — あなたとカーネルの仲介役
5. ハンズオン: 自作シェルに `cd` を実装する

---

<!-- _class: section -->

# 01. プロセスとは

---

## CPU がメモリの命令を実行する（復習）

- CPU はコンピュータの「脳」。実際に処理をしているのは CPU
- CPU は **メモリから命令とデータを取り出し**、命令レジスタ・デコーダを通して 1 つずつ実行する
- ここまでは、共通テストでやった内容の復習

<div style="display: flex; align-items: center; justify-content: center; gap: 20px; margin-top: 28px;">
  <div style="padding: 14px 18px; border: 2px solid #5F6368; border-radius: 12px; text-align:center;">
    <div style="font-weight:600; margin-bottom:8px;">メモリ</div>
    <div style="display:flex; flex-direction:column; gap:4px; font-size:0.72em;">
      <div style="padding:4px 12px; background:#F1F3F4; border-radius:4px;">命令 1</div>
      <div style="padding:4px 12px; background:#F1F3F4; border-radius:4px;">命令 2</div>
      <div style="padding:4px 12px; background:#F1F3F4; border-radius:4px;">命令 3</div>
      <div style="padding:4px 12px; background:#FEF7E0; border-radius:4px;">データ</div>
    </div>
  </div>
  <div style="text-align:center; color: var(--gdg-blue); font-weight:600;">
    <div style="font-size:0.72em;">命令・データを<br>取り出す (fetch)</div>
    <div style="font-size: 30px;">→</div>
  </div>
  <div style="padding: 14px 20px; border: 2px solid var(--gdg-blue); border-radius: 12px; text-align:center;">
    <div style="font-weight:600; margin-bottom:8px;">CPU <span style="font-size:0.7em; font-weight:400;">(脳)</span></div>
    <div style="display:flex; gap:6px; font-size:0.72em;">
      <div style="padding:6px 8px; border:1px solid var(--gdg-blue); border-radius:6px;">命令<br>レジスタ</div>
      <div style="padding:6px 8px; border:1px solid var(--gdg-blue); border-radius:6px;">デコーダ</div>
      <div style="padding:6px 8px; border:1px solid var(--gdg-blue); border-radius:6px;">実行</div>
    </div>
  </div>
</div>

> では、その命令は **誰がメモリに用意する**のか?

---

## その命令をメモリに用意するのが OS

- プログラムはただのファイル(命令の集まり)。放っておいても動かない
- **OS** がプログラムをメモリに読み込み、CPU が実行できる状態に整える
- こうして **メモリに割り当てられ、命令が実行されているもの** —— それが **プロセス**

<div style="display: flex; align-items: center; justify-content: center; gap: 14px; margin-top: 32px;">
  <div style="padding: 16px 20px; border: 2px solid var(--gdg-blue); border-radius: 12px; text-align: center; font-weight: 600;">プログラム<br><span style="font-size:0.7em;font-weight:400;">ファイル(命令の集まり)</span></div>
  <div style="text-align:center; color: var(--gdg-red); font-weight:600;"><div style="font-size:0.72em;">OS がメモリに<br>読み込む</div><div style="font-size: 34px;">→</div></div>
  <div style="padding: 16px 20px; border: 2px solid #5F6368; border-radius: 12px; text-align: center;">メモリ上の命令<br><span style="font-size:0.7em;">CPU が実行できる状態</span></div>
  <div style="text-align:center; color: #5F6368; font-weight:600;"><div style="font-size:0.72em;">CPU が実行</div><div style="font-size: 34px;">→</div></div>
  <div style="padding: 16px 20px; border: 2px solid var(--gdg-green); border-radius: 12px; text-align: center; font-weight: 600;">プロセス<br><span style="font-size:0.7em;font-weight:400;">動いているプログラム</span></div>
</div>

---

## プロセスは「デバイス」を使って仕事をする

どんな処理も、最後はハードウェア(デバイス)に行き着く

- 画面に文字を出す → ディスプレイ
- ファイルを読む・書く → ストレージ
- 計算する・記憶する → CPU / メモリ

つまりプロセスは、仕事をするためにデバイスを触りにいく

---

<!-- _class: section red -->

# 02. なぜプログラムは
# ハードウェアを触れないのか

---

## もし、どのプロセスも自由にデバイスを触れたら?

- 悪意あるプログラムが、メモリやディスクを壊し放題になる
- バグで暴走したプロセスが、他の仕事まで巻き込む
- たった 1 つのミスで、システム全体がダウンする

だからこそ「誰でも自由には触らせない」仕組みが必要

---

## CPU には 2 つのモードがある

| モード | 説明 |
| --- | --- |
| **ユーザーモード** | 普段プロセスが動く場所。デバイスを直接触る命令は**禁止** |
| **カーネルモード** | デバイスを直接触れる**特権モード** |

あなたが書くプログラムは、いつもユーザーモードで動いている

---

## カーネル = カーネルモードで動く OS の核

- デバイスを直接触れるのは、**カーネルだけ**
- CPU やメモリの割り当て、デバイスの管理を一手に引き受ける
- カーネルは **OS の一部**。OS の中心にある「核」の部分

<div style="display: flex; align-items: center; justify-content: center; gap: 16px; margin-top: 32px;">
  <div style="padding: 18px 24px; border: 2px dashed var(--gdg-blue); border-radius: 12px; text-align: center;">ユーザーモード<br><span style="font-size:0.7em;">あなたのプロセス</span></div>
  <div style="font-size: 34px; color: var(--gdg-red);">✕ 直接は触れない</div>
  <div style="padding: 18px 24px; border: 2px solid var(--gdg-green); border-radius: 12px; text-align: center; font-weight:600;">カーネル<br><span style="font-size:0.7em;font-weight:400;">デバイスを管理</span></div>
  <div style="font-size: 34px; color: var(--gdg-green);">〇 デバイスに触れる</div>
</div>

---

<!-- _class: section yellow -->

# 03. システムコール

---

## プロセスはカーネルに「お願い」する

- プロセスは自分ではデバイスを触れない
- 「ファイルを開いて」「画面に出して」をカーネルに依頼する
- この依頼の窓口が **システムコール**

<div style="display: flex; align-items: center; justify-content: center; gap: 12px; margin-top: 36px;">
  <div style="padding: 18px 24px; border: 2px solid var(--gdg-blue); border-radius: 12px; font-weight:600;">プロセス</div>
  <div style="text-align:center; color: var(--gdg-red); font-weight:600;"><div style="font-size:0.8em;">システムコール</div><div style="font-size: 34px;">→</div></div>
  <div style="padding: 18px 24px; border: 2px solid var(--gdg-green); border-radius: 12px; font-weight:600;">カーネル</div>
  <div style="font-size: 34px; color: #5F6368;">→</div>
  <div style="padding: 18px 24px; border: 2px solid #5F6368; border-radius: 12px;">デバイス</div>
</div>

---

## システムコールは、そのままでは呼びにくい

- システムコールは、CPU の **特別な命令(アセンブリ)** で呼び出す必要がある
- C などの高級言語から、そのままでは書けない
- そこで OS が **ラッパー関数** を用意してくれている
  - 例: `chdir()` や `fork()` は、中でその特別な命令を呼んでいる

高級言語とアセンブリの橋渡しも、OS の役割の一つ

---

<!-- _class: invert -->

## 実際に見てみよう: `strace ls`

```bash
$ strace ls
execve("/usr/bin/ls", ...)              = 0
openat(AT_FDCWD, ".", O_RDONLY|...)     = 3
getdents64(3, ...)                      = 168
write(1, "file1  file2  memo.txt\n", 23) = 23
close(3)                                = 0
```

`ls` 一発の裏で、こんなにたくさんのシステムコールが呼ばれている!

---

<!-- _class: section green -->

# 04. シェル

---

## シェル = あなたとカーネルの「仲介役」

シェルがやっていることは、大きく 4 つ

1. **入力を受け付ける** — あなたが打ち込むコマンド
2. **解釈する** — 何をしたいのかを読み取る
3. **プロセスを作る** — コマンドを実際に実行する
4. **システムコールを呼ぶ** — カーネルに依頼する

<div style="display: flex; align-items: center; justify-content: center; gap: 12px; margin-top: 24px;">
  <div style="padding: 12px 18px; border: 2px solid var(--gdg-blue); border-radius: 10px; font-weight:600;">あなた</div>
  <div style="font-size: 28px; color: #5F6368;">→</div>
  <div style="padding: 12px 18px; border: 2px solid var(--gdg-green); border-radius: 10px; font-weight:600; text-align:center;">シェル<br><span style="font-size:0.65em;font-weight:400;">受付 → 解釈 → プロセス作成 → syscall</span></div>
  <div style="font-size: 28px; color: #5F6368;">→</div>
  <div style="padding: 12px 18px; border: 2px solid var(--gdg-red); border-radius: 10px; font-weight:600;">カーネル</div>
</div>

---

## シェルがコマンドを動かす 3 ステップ

`ls` を実行するとき、シェルは新しいプロセスを作る

<div style="display: flex; align-items: stretch; justify-content: center; gap: 16px; margin-top: 24px;">
  <div style="padding: 18px 22px; border-top: 4px solid var(--gdg-blue); background:#F8F9FA; border-radius: 8px; width: 30%;"><b>fork</b><br><span style="font-size:0.8em;">自分の分身(子プロセス)を作る。親のメモリをコピー</span></div>
  <div style="padding: 18px 22px; border-top: 4px solid var(--gdg-green); background:#F8F9FA; border-radius: 8px; width: 30%;"><b>exec</b><br><span style="font-size:0.8em;">分身の中身を別のプログラム(ls など)に置き換える。<strong>最初に話した「OS がメモリに読み込む」</strong>のがこれ</span></div>
  <div style="padding: 18px 22px; border-top: 4px solid var(--gdg-yellow); background:#F8F9FA; border-radius: 8px; width: 30%;"><b>wait</b><br><span style="font-size:0.8em;">分身が仕事を終えるのを待つ</span></div>
</div>

---

## 実行の流れを時間で見る

シェル自身も 1 つのプロセス。`ls` を実行するとき、シェルは **もう 1 つ別のプロセス**を作る

<div style="margin-top: 18px; font-size: 0.82em;">
<div style="display:grid; grid-template-columns: 92px repeat(4, 1fr); gap:8px;">
<div></div>
<div style="text-align:center; font-weight:600; color:#5F6368;">① fork</div>
<div style="text-align:center; font-weight:600; color:#5F6368;">② exec</div>
<div style="text-align:center; font-weight:600; color:#5F6368;">③ 実行中</div>
<div style="text-align:center; font-weight:600; color:#5F6368;">④ 終了・復帰</div>
<div style="font-weight:600; color:var(--gdg-green); display:flex; align-items:center;">親: シェル</div>
<div style="background:#E6F4EA; border-radius:6px; padding:8px; text-align:center;">分身を作る</div>
<div style="background:#F1F3F4; border-radius:6px; padding:8px; text-align:center; color:#5F6368;">—</div>
<div style="background:#FEF7E0; border-radius:6px; padding:8px; text-align:center;">終了を待つ<br>(wait)</div>
<div style="background:#E6F4EA; border-radius:6px; padding:8px; text-align:center;">受付に戻る</div>
<div style="font-weight:600; color:var(--gdg-blue); display:flex; align-items:center;">子: ls</div>
<div style="background:#E8F0FE; border-radius:6px; padding:8px; text-align:center;">分身が誕生<br>(シェルのコピー)</div>
<div style="background:#E8F0FE; border-radius:6px; padding:8px; text-align:center;">中身を ls に<br>置き換える</div>
<div style="background:#E8F0FE; border-radius:6px; padding:8px; text-align:center;">ls の命令を<br>実行</div>
<div style="background:#FCE8E6; border-radius:6px; padding:8px; text-align:center;">終了 (exit)</div>
</div>
</div>

> `ls` が終わると、制御は **シェルのプロセスに戻ってくる**

---

## プロセスは、それぞれ独立している

- 各プロセスは、自分専用の状態を持っている(作業ディレクトリも含む)
- あるプロセスが何をしても、他のプロセスには影響しない
- だから、**子プロセスの中で変更しても、親プロセスには伝わらない**

> この性質が、後半の `cd` でカギになる!

---

## 今日のまとめ

<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-top: 24px;">
  <div style="padding: 18px; border-top: 4px solid var(--gdg-blue); background:#F8F9FA; border-radius: 8px;"><h3 style="margin:0 0 6px;">プロセス</h3>仕事の単位。単独ではデバイスを触れない</div>
  <div style="padding: 18px; border-top: 4px solid var(--gdg-green); background:#F8F9FA; border-radius: 8px;"><h3 style="margin:0 0 6px;">カーネル</h3>OS の核。デバイスを触れる唯一の存在</div>
  <div style="padding: 18px; border-top: 4px solid var(--gdg-yellow); background:#F8F9FA; border-radius: 8px;"><h3 style="margin:0 0 6px;">システムコール</h3>カーネルへ「お願い」する窓口</div>
  <div style="padding: 18px; border-top: 4px solid var(--gdg-red); background:#F8F9FA; border-radius: 8px;"><h3 style="margin:0 0 6px;">シェル</h3>受付 → 解釈 → プロセス作成 → syscall の仲介役</div>
</div>

---

## 後半: 自作シェルに `cd` を実装しよう

- `fork` / `exec` / `wait` で動くシェルは、こちらで配布する
- あなたが実装するのは `cd` コマンド
- 「`cd` はなぜ特別な作りにしないといけないのか?」を、手を動かして確かめよう!

---

<!-- _class: lead -->

# それでは、
# 手を動かそう!
