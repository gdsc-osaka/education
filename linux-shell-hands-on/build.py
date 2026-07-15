#!/usr/bin/env python3
"""
build.py — linux-shell-hands-on コードラボのクロスプラットフォームビルドスクリプト
Make / Git Bash が使えない Windows 環境でも動きます。

使い方:
    python linux-shell-hands-on/build.py [--claat PATH] [--libs PATH]

引数:
    --claat PATH   claat コマンドまたは実行ファイルのパス (デフォルト: claat)
    --libs  PATH   コピー元の libs ディレクトリパス
                   (デフォルト: <repo-root>/portfolio-2025/libs)

このスクリプトが行うこと (Makefile の `make claat linux-shell-hands-on` と同等):
    1. claat export を一時ディレクトリに実行する
    2. 生成物を linux-shell-hands-on/ にコピー (slide.md, img/ などは上書きしない)
    3. libs/ を差し替えてアセット参照を Google CDN からローカルに書き換える
    4. .claat/fix-claat-codespans.py を実行して後処理を行う
    5. scripts/gen-index.py を実行してルートの index.html を更新する
"""

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

# ──────────────────────────────────────────────
# パス解決
# ──────────────────────────────────────────────

# このスクリプトは linux-shell-hands-on/ 直下に置かれているので、
# 2 階層上がるとリポジトリルートになる。
SCRIPT_DIR = Path(__file__).resolve().parent       # linux-shell-hands-on/
REPO_ROOT  = SCRIPT_DIR.parent                     # <repo-root>/

CONTENT_DIR = SCRIPT_DIR                           # 出力先 = このスクリプトと同じディレクトリ
CLAAT_MD    = CONTENT_DIR / "claat.md"
POSTFIX     = REPO_ROOT / ".claat" / "fix-claat-codespans.py"
GEN_INDEX   = REPO_ROOT / "scripts" / "gen-index.py"
DEFAULT_LIBS_SRC = REPO_ROOT / "portfolio-2025" / "libs"

CDN_PREFIX   = "https://storage.googleapis.com/claat-public/"
LOCAL_PREFIX = "libs/"


def find_claat() -> str:
    """
    ローカルに claat.exe / claat があれば優先し、なければ PATH を検索する。
    見つからない場合は終了する。
    """
    # リポジトリルートのローカルバイナリを最初に確認
    for name in ("claat.exe", "claat", "claat-windows-amd64.exe"):
        local = REPO_ROOT / name
        if local.exists():
            return str(local)

    # PATH 上を検索
    found = shutil.which("claat")
    if found:
        return found

    print(
        "[ERROR] claat コマンドが見つかりません。\n"
        "  以下のいずれかで claat を用意してください:\n"
        "  A) https://github.com/googlecodelabs/tools/releases から\n"
        "     claat-windows-amd64.exe をダウンロードし、\n"
        f"    {REPO_ROOT} に claat.exe として配置する\n"
        "  B) Go がインストール済みであれば:\n"
        "     go install github.com/googlecodelabs/tools/claat@latest",
        file=sys.stderr,
    )
    sys.exit(1)


def run(cmd: list, **kwargs):
    """subprocess.run のラッパー。失敗時はエラーを出力して終了する。"""
    print(f"  $ {' '.join(str(c) for c in cmd)}")
    result = subprocess.run(cmd, **kwargs)
    if result.returncode != 0:
        print(f"[ERROR] コマンドが失敗しました (exit code {result.returncode})", file=sys.stderr)
        sys.exit(result.returncode)
    return result


def build(claat_cmd: str, libs_src: Path):
    # ── 入力チェック ──────────────────────────────
    if not CLAAT_MD.exists():
        print(f"[ERROR] {CLAAT_MD} が見つかりません", file=sys.stderr)
        sys.exit(1)

    if not libs_src.exists():
        print(f"[ERROR] libs ソースディレクトリが見つかりません: {libs_src}", file=sys.stderr)
        sys.exit(1)

    # ── Step 1: claat export → 一時ディレクトリ ──
    print("[1/5] claat export を実行中...")
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        run([claat_cmd, "export", "-o", str(tmp_path), str(CLAAT_MD)])

        # claat は id フィールドと同名のディレクトリを出力するので、その唯一のサブディレクトリを探す
        exported_dirs = [d for d in tmp_path.iterdir() if d.is_dir()]
        if not exported_dirs:
            print("[ERROR] claat export の出力ディレクトリが見つかりません", file=sys.stderr)
            sys.exit(1)
        exported = exported_dirs[0]

        # ── Step 2: 生成物を CONTENT_DIR にコピー ──
        print("[2/5] 生成物をコピー中...")
        # 既存の claat 生成ファイルのみ上書きする。
        # slide.md, img/, slide/ など無関係なファイルはそのまま残す。
        for src_item in exported.iterdir():
            dst_item = CONTENT_DIR / src_item.name
            if src_item.is_dir():
                if dst_item.exists():
                    shutil.rmtree(dst_item)
                shutil.copytree(src_item, dst_item)
            else:
                shutil.copy2(src_item, dst_item)

    # ── Step 3: libs/ の差し替え ──────────────────
    print("[3/5] libs ディレクトリを差し替え中...")
    dst_libs = CONTENT_DIR / "libs"
    if dst_libs.exists():
        shutil.rmtree(dst_libs)
    shutil.copytree(libs_src, dst_libs)

    # ── Step 4: Google CDN URL をローカルに書き換え ──
    print("[4/5] アセット参照を書き換え中...")
    index_html = CONTENT_DIR / "index.html"
    if not index_html.exists():
        print(f"[ERROR] {index_html} が見つかりません。claat export に失敗した可能性があります", file=sys.stderr)
        sys.exit(1)

    content = index_html.read_text(encoding="utf-8")
    updated = content.replace(CDN_PREFIX, LOCAL_PREFIX)
    if updated != content:
        index_html.write_text(updated, encoding="utf-8")
        count = len(re.findall(re.escape(LOCAL_PREFIX), updated)) - len(re.findall(re.escape(LOCAL_PREFIX), content))
        print(f"    CDN URL を {content.count(CDN_PREFIX)} 箇所書き換えました")
    else:
        print("    (書き換え対象なし)")

    # ── Step 5: 後処理スクリプトの実行 ────────────
    print("[5/5] 後処理スクリプトを実行中...")
    if POSTFIX.exists():
        run([sys.executable, str(POSTFIX), "--source-md", str(CLAAT_MD), str(index_html)])
    else:
        print(f"    [WARN] {POSTFIX} が見つかりません。スキップします")

    # ── オプション: ルート index.html の更新 ───────
    if GEN_INDEX.exists():
        print("[+] ルート index.html を更新中...")
        run([sys.executable, str(GEN_INDEX)])
    else:
        print(f"    [WARN] {GEN_INDEX} が見つかりません。スキップします")

    print(f"\nBuild OK: {CONTENT_DIR / 'index.html'}")


def main():
    parser = argparse.ArgumentParser(
        description="linux-shell-hands-on コードラボのクロスプラットフォームビルドスクリプト"
    )
    parser.add_argument(
        "--claat",
        default=None,
        help="claat コマンドまたは実行ファイルのパス (省略時は自動検索)",
    )
    parser.add_argument(
        "--libs",
        default=None,
        help=f"コピー元の libs ディレクトリ (デフォルト: {DEFAULT_LIBS_SRC})",
    )
    args = parser.parse_args()

    claat_cmd = args.claat if args.claat else find_claat()
    libs_src  = Path(args.libs) if args.libs else DEFAULT_LIBS_SRC

    print(f"claat  : {claat_cmd}")
    print(f"libs   : {libs_src}")
    print(f"output : {CONTENT_DIR}")
    print()

    build(claat_cmd, libs_src)


if __name__ == "__main__":
    main()
