summary: OSの裏側を理解して、自作シェルの cd コマンドを実装するハンズオン
id: linux-shell-hands-on
categories: Linux
environments: Web
status: Draft
feedback link: https://github.com/gdsc-osaka/education/issues
author: GDG on Campus University of Osaka

# 自作シェルで学ぶ OS の裏側

## はじめに
Duration: 0:05:00

普段何気なく打っている `ls` や `cd` というコマンド。その裏では、あなたのプログラムとハードウェアの間で、実はたくさんのやり取りが起きています。

このコードラボでは、その **OS の裏側** をのぞきながら、最終的に **自分だけのシェル(cd コマンド)** を C 言語で作ります。

### このコードラボで作るもの
* コマンドを受け取って動く、小さな自作シェル
* **課題:** その中に `cd` コマンドを自分の手で実装します
* 「なぜ `cd` だけは特別な作りにしないといけないのか」を、手を動かして体験します
* **発展課題:** `ls` や `cat` などの外部コマンドを実行できるようにします

### このコードラボで学ぶこと
* カーネルとは何か、なぜユーザーのプログラムはハードウェアを直接触れないのか
* システムコールを使って、カーネルに仕事を「お願い」する仕組み
* シェルが、ユーザーとカーネルの間を取り持つ「代行者」であること
* プロセスとは何か、`fork` / `exec` / `wait` でコマンドが実行される流れ
* `cd` を組み込みコマンドとして実装する方法

### 必要なもの
* インターネットに接続された PC(Windows または Mac)
* C 言語を少し書いたことがある(`printf` や `for` 文が読めればOK。ポインタが少し不安でも大丈夫です)
* ターミナル操作の経験は不要です

### 前提知識
* OS については「カーネル」という言葉を聞いたことがある、くらいで十分です

### このコードラボで扱わないこと
このコードラボは「ユーザーの入力がハードウェアを動かすまで」の流れを理解することに集中します。そのため、次のトピックには踏み込みません。
* 仮想メモリ / ページング
* ファイルシステムの内部構造
* パイプ・リダイレクト・ジョブ制御などのシェルの発展機能

> **Note:** これらに興味が出たら、勉強会の最後に紹介する発展リソースを参照してください。

## 環境構築(事前準備)
Duration: 0:15:00

ハンズオンでは C 言語でシェルを書きます。インストールに時間がかかることがあるので、**勉強会の当日までに、この Step の環境構築を必ず済ませてきてください。** 当日は「動作確認」から始めます。

> **Warning:** 当日その場でのインストールは間に合わない可能性が高いです。特に Windows の方は、再起動やダウンロードで時間がかかります。必ず事前に済ませてきてください。

お使いの OS に合わせて、下のどちらかを進めてください。

### 🍎 Mac の人 — ターミナルのままでOK

Mac は Unix 系なので、**標準のターミナルでそのまま参加できます。** WSL などの仮想環境は不要です。C コンパイラだけ入れましょう。

1. `⌘ + Space` で Spotlight を開き、「ターミナル」と入力して起動します。
2. 次のコマンドを実行します。

```bash
xcode-select --install
```

3. ポップアップが表示されたら「インストール」をクリックします(数分〜十数分かかります)。
4. 完了したら、このページ下部の「動作確認」へ進みます。

> **Tip:** すでに `gcc --version` が動く人は、この手順はスキップして大丈夫です。

### 🪟 Windows の人 — WSL2 + Ubuntu を入れる

Windows はそのままでは Linux のコマンドや C の環境が使えないので、**WSL2** という仕組みで Ubuntu(Linux)を入れます。

**前提:** Windows 10(バージョン 2004 以降)または Windows 11 / 管理者権限が使える PC

1. スタートメニューで「PowerShell」を検索し、**右クリック →「管理者として実行」** を選びます。
2. 次のコマンドを実行します。WSL2 と Ubuntu が自動でインストールされます。

```powershell
wsl --install
```

3. **PC を再起動します。**(ここが重要。再起動しないと完了しません)
4. 再起動後、Ubuntu のウィンドウが自動で立ち上がります。出てこない場合は、スタートメニューから「Ubuntu」を起動してください。
5. 初回だけ **ユーザー名とパスワード** を聞かれるので設定します。

> **Note:** パスワードは入力しても画面に何も表示されませんが、ちゃんと打てています。忘れないものを設定してください。

6. Ubuntu のターミナルで、次のコマンドを順に実行し、C コンパイラなどを入れます。

```bash
sudo apt update
sudo apt install build-essential -y
```

（`sudo` のパスワードは、手順 5 で設定したものです）

> **Note:** これ以降、勉強会では **この Ubuntu のターミナル** を使います。Windows の黒い画面(コマンドプロンプト)ではないので注意してください。

### 動作確認(Mac / Windows 共通)

ターミナル(Windows の人は Ubuntu)で、次のコマンドを 1 行ずつ実行してください。

```bash
pwd
ls
gcc --version
```

**期待される出力:**

```
/home/あなたの名前
（ファイル一覧。何もなくてもOK）
gcc (Ubuntu ...) 13.x.x
```

* `pwd` → 今いる場所が表示される
* `ls` → ファイル一覧が表示される(何もなくてもOK)
* `gcc --version` → バージョンが表示される

最後に、C が本当にコンパイルできるかを確認します。次を **1 行のまま** 貼り付けて実行してください。

```bash
echo 'int main(){return 0;}' > test.c && gcc test.c -o test && ./test && echo "OK!"
```

最後に **`OK!`** と表示されれば、準備完了です 🎉

> **Troubleshooting:** うまくいかないときは、次を確認してください。
> - `wsl --install` が「認識されません」と出る → Windows Update を最新にしてから再挑戦する
> - 再起動後に仮想化エラーが出る → BIOS で仮想化(Virtualization)を有効にする必要がある場合があります
> - 会社・学校の貸与 PC で管理者権限がない → インストールできないことがあります。事前に運営まで連絡してください
> - どうしても入らない場合は、当日少し早めに来てください。一緒に対応します

## 骨組みのシェルを動かす
Duration: 0:10:00

まずは、今日の土台になる **骨組みシェル** を用意します。入力を受け取って解析するところまでは、こちらで用意済みです。あなたはこの上に `cd` や外部コマンドの実行を足していきます。

### シェルがやること（おさらい）

シェルは、次の 3 つをひたすら繰り返すプログラムです。

1. **入力を受け付ける** — あなたが打ち込んだコマンドを 1 行読む
2. **解析する** — 空白で区切って「コマンド名」と「引数」に分ける
3. **実行する** — コマンドを実際に動かす

このうち **1 と 2 は配布コードに用意済み**です。今日あなたが書くのは、**3 の「実行する」部分**です。

### 骨組みコードを用意する

作業用のフォルダを作り、その中に `myshell.c` を作ります。

```bash
mkdir myshell
cd myshell
```

エディタ(`nano myshell.c` など、好きなもので構いません)で `myshell.c` を作り、次の内容をそのまま貼り付けて保存します。

`myshell.c`

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>     /* chdir, getcwd, fork, execvp */
#include <sys/wait.h>   /* wait */

#define BUFLEN      1024   /* 入力バッファの大きさ */
#define MAXARGNUM    256   /* 引数の最大数 */
#define PATH_MAX_LEN 1024

int  parse(char buffer[], char *args[]);
void execute_command(char *args[]);

int main(void)
{
    char command_buffer[BUFLEN];  /* 入力を読み込むバッファ */
    char *args[MAXARGNUM];        /* 解析後の引数の配列 */
    int  status;

    for (;;) {
        printf("myshell> ");

        /* 1 行読み込む。Ctrl-D（入力の終わり）で終了 */
        if (fgets(command_buffer, BUFLEN, stdin) == NULL) {
            printf("\n");
            break;
        }

        status = parse(command_buffer, args);

        if (status == 2) {   /* "exit" が入力された */
            printf("done.\n");
            break;
        }
        if (status == 3) {   /* 空行だった */
            continue;
        }

        execute_command(args);
    }
    return 0;
}

/*
 * 入力を空白で区切り、args[] に格納する。
 * 返り値: 0 = 通常コマンド / 2 = exit / 3 = 空行
 * ※ この関数は今日は変更しません。中身を読まなくても大丈夫です。
 */
int parse(char buffer[], char *args[])
{
    int arg_index = 0;

    buffer[strlen(buffer) - 1] = '\0';   /* 末尾の改行を消す */

    if (strcmp(buffer, "exit") == 0) {
        return 2;
    }

    while (*buffer != '\0') {
        while (*buffer == ' ' || *buffer == '\t') {
            *(buffer++) = '\0';
        }
        if (*buffer == '\0') {
            break;
        }
        args[arg_index++] = buffer;
        while (*buffer != '\0' && *buffer != ' ' && *buffer != '\t') {
            ++buffer;
        }
    }
    args[arg_index] = NULL;   /* 配列の終わりを示す */

    if (arg_index == 0) {
        return 3;
    }
    return 0;
}

void execute_command(char *args[])
{
    /* === 課題: ここに cd の処理を書く === */

    /* === 発展課題: ここで外部コマンドを実行する === */

    printf("まだ実装されていません: %s\n", args[0]);
}
```

`main` は「読む → 解析する → 実行する」を繰り返すだけの短いループです。`parse` は入力を引数の配列に分ける係で、今日は触りません。あなたが育てていくのは、いちばん下の `execute_command` です。

### コンパイルして実行する

```bash
gcc myshell.c -o myshell
./myshell
```

`myshell>` というプロンプトが出たら成功です。試しに何か打ってみましょう。

**期待される出力:**

```
myshell> ls
まだ実装されていません: ls
myshell> exit
done.
```

まだ何も実行できませんが、これが出発点です。`exit` または `Ctrl-D` で終了できます。

> **Tip:** コードを書き換えたら、そのたびに `gcc myshell.c -o myshell` でコンパイルし直してから `./myshell` を実行します。この 2 つはこれから何度も繰り返します。

## 【課題】cd コマンドを実装する
Duration: 0:20:00

いよいよ本題です。`cd` を自分の手で実装します。その前に、**なぜ `cd` だけ特別な作りが必要なのか**を確認しておきましょう。ここが今日いちばん大事なポイントです。

### なぜ cd は「組み込みコマンド」なのか

スライドで見たとおり、シェルは `ls` のような外部コマンドを **子プロセスを作って(fork)** その中で実行します。ここで効いてくるのが、**プロセスはそれぞれ独立した「作業ディレクトリ」を持つ**という性質です。

もし `cd` を外部コマンドと同じように、子プロセスの中で実行したらどうなるでしょう?

* 子プロセスの中で作業ディレクトリを変える
* → 変わるのは **子プロセスの**ディレクトリだけ
* → 子プロセスはコマンドが終わると消えてしまう
* → **親であるシェルのディレクトリは、まったく変わらない**

つまり `cd` を外部コマンドと同じ作りにすると、**まったく効きません。** だから `cd` は fork せず、**シェル自身のプロセスの中で直接ディレクトリを変える**必要があります。このように、シェル本体が自分で処理するコマンドを **組み込み(built-in)コマンド** と呼びます。

> **Note:** `pwd` や `ls` は外部コマンド(別プログラム)ですが、`cd` はどんなシェルでも組み込みコマンドです。理由はいま説明したとおりです。

### cd 関数を書く

ディレクトリの変更には、`chdir()` というシステムコールのラッパー関数を使います。`execute_command` の **すぐ上**に、次の `cd` 関数を追加します。

`myshell.c`（`execute_command` の上に追加）

```c
int cd(char *args[])
{
    int result;

    if (args[1] == NULL) {
        /* 引数なし（"cd" だけ）ならホームディレクトリへ */
        result = chdir(getenv("HOME"));
    } else {
        /* "cd <パス>" なら、そのパスへ移動 */
        result = chdir(args[1]);
    }

    if (result != 0) {
        perror("cd failed");        /* 移動できなかった理由を表示 */
    } else {
        char cwd[PATH_MAX_LEN];
        getcwd(cwd, sizeof(cwd));    /* 今いる場所を取得して */
        printf("Current directory: %s\n", cwd);  /* 表示する */
    }
    return result;
}
```

`chdir()` がディレクトリを変える本体です。成功したら `getcwd()` で今いる場所を取り出して表示し、失敗したら `perror()` で理由を出します。

### execute_command から cd を呼ぶ

次に、コマンド名が `cd` だったときに、いま作った関数を呼ぶようにします。`execute_command` を次のように書き換えます。

`myshell.c`

```c
void execute_command(char *args[])
{
    if (strcmp(args[0], "cd") == 0) {
        cd(args);   /* fork せず、シェル自身のプロセスで実行する */
        return;
    }

    /* === 発展課題: ここで外部コマンドを実行する === */

    printf("まだ実装されていません: %s\n", args[0]);
}
```

ポイントは、`cd` のときは **fork せずにそのまま `cd(args)` を呼んで `return` している**ことです。これが「組み込みコマンド」の作りです。

### コンパイルして動かす

```bash
gcc myshell.c -o myshell
./myshell
```

いくつか試してみましょう。

**期待される出力:**

```
myshell> cd /tmp
Current directory: /tmp
myshell> cd
Current directory: /home/あなたの名前
myshell> cd /does/not/exist
cd failed: No such file or directory
```

* `cd /tmp` → 指定した場所に移動できる
* `cd`(引数なし)→ ホームディレクトリに戻る
* 存在しないパス → `cd failed` とエラー理由が出る

ここまでできれば、**課題は達成です！** おめでとうございます 🎉

> **Tip:** 現状ではまだ `pwd` や `ls` は動きません(「まだ実装されていません」と出ます)。それらを動かすのが、次の発展課題です。

### （任意）`~` をホームディレクトリに展開する

`cd ~/Downloads` のような `~` 付きのパスにも対応させたい人は、`cd` 関数の分岐を増やしてみましょう。`args[1][0]` が `'~'` のときだけ、`getenv("HOME")` と残りの文字列をつなげて `chdir()` すればOKです。

## 【発展課題】外部コマンドを実行できるようにする
Duration: 0:20:00

`cd` は動くようになりましたが、`ls` や `cat` はまだ「まだ実装されていません」と出るだけです。ここでは、それらの **外部コマンド** を実行できるようにして、本物のシェルに近づけます。

### 外部コマンドとは

`ls` や `cat` は、シェルの一部ではなく **それぞれ独立したプログラム**(`/usr/bin/ls` などの実行ファイル)です。シェルはこれらを、スライドで見た **fork → exec → wait** の 3 ステップで実行します。

1. **fork** — 自分の分身(子プロセス)を作る
2. **exec** — 分身の中身を、目的のプログラム(`ls` など)に置き換える
3. **wait** — 分身が終わるのを待つ

### fork・execvp・wait で実行する

`execute_command` の最後にある「まだ実装されていません」の行を、次のコードに置き換えます。

`myshell.c`

```c
void execute_command(char *args[])
{
    if (strcmp(args[0], "cd") == 0) {
        cd(args);
        return;
    }

    int pid = fork();               /* ① 子プロセスを作る */
    if (pid == -1) {
        perror("fork failed");
        return;
    }

    if (pid == 0) {
        /* ② ここは子プロセス。中身を別のプログラムに置き換える */
        execvp(args[0], args);
        /* execvp が成功すると、この先は実行されない。
           ここに来たということは失敗したということ */
        perror("execvp failed");
        exit(1);
    }

    /* ③ ここは親プロセス（シェル）。子の終了を待つ */
    int status;
    wait(&status);
}
```

`fork()` の返り値で「自分が親か子か」を見分けているのがポイントです。返り値が `0` なら子プロセス、そうでなければ親プロセスです。子は `execvp()` で `ls` などに変身し、親は `wait()` でその終了を待ちます。

### コンパイルして動かす

```bash
gcc myshell.c -o myshell
./myshell
```

今度は外部コマンドが動きます。`cd` と組み合わせても試してみましょう。

**期待される出力:**

```
myshell> ls
myshell.c  myshell
myshell> cd /tmp
Current directory: /tmp
myshell> ls
（/tmp の中のファイル一覧）
```

`cd` で移動した先で `ls` の結果が変わっていれば、**あなたの `cd`(組み込み)と `ls`(外部コマンド)が、きちんと連携して動いている**証拠です。

### 確かめてみよう: もし cd も fork していたら?

「なぜ `cd` は組み込みなのか」を、実際に壊して確かめてみましょう。`execute_command` の先頭にある `cd` の分岐を、**一時的にコメントアウト**します。

```c
    /* if (strcmp(args[0], "cd") == 0) {
        cd(args);
        return;
    } */
```

こうすると `cd` も外部コマンドと同じ道(fork → execvp)を通ります。保存して再コンパイルし、`cd /tmp` を実行してみてください。

**期待される出力:**

```
myshell> cd /tmp
execvp failed: No such file or directory
```

`cd` という名前の実行ファイルは存在しないので `execvp` が失敗します。仮に存在して成功したとしても、ディレクトリが変わるのは子プロセスの中だけで、**親シェルには反映されません。** これが「`cd` は組み込みでなければならない」理由です。

確認できたら、**コメントアウトを元に戻して**再コンパイルしておきましょう。

> **Warning:** 戻し忘れると `cd` が動かない状態のままになります。`/* */` を消して、必ず元に戻してください。

### さらに挑戦したい人へ

余力があれば、本物のシェルに近づける機能を足してみましょう。

* `cd ~/Downloads` のように `~` をホームディレクトリに展開する
* `pushd` / `popd` / `dirs` でディレクトリの移動履歴を扱う
* コマンド末尾の `&` で、`wait` せずに戻る(バックグラウンド実行)
* プロンプト(`myshell> `)に、現在のディレクトリを表示する

## おめでとうございます！
Duration: 0:05:00

自作シェルに `cd` を実装し(発展課題では外部コマンドの実行まで)、コマンドが動く裏側を手を動かして体験しました。

### 学んだこと

* プロセスはそれぞれ独立した状態(作業ディレクトリ)を持つこと
* 外部コマンドは **fork → execvp → wait** で実行されること
* `cd` が **組み込みコマンド** でなければならない理由
* `chdir()` を使った `cd` の実装

### 次のステップ

* 「さらに挑戦したい人へ」の機能を追加して、シェルを育てる
* `strace ./myshell` で、自作シェルが呼ぶシステムコールを覗いてみる
* 関連するシステムコールのマニュアルを読む:
  * https://man7.org/linux/man-pages/man2/fork.2.html
  * https://man7.org/linux/man-pages/man3/execvp.3.html
  * https://man7.org/linux/man-pages/man2/chdir.2.html

普段何気なく打っている `cd` や `ls` の裏側が、少し見えるようになっていれば大成功です。お疲れさまでした!
