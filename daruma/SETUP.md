# かためだるま — セットアップ手順（Windows）

あなたがやるのは 3 つだけ。残りは PC の中の Claude Code がやります。

## 1. Claude Code を PC に入れる（1 回だけ）

1. https://claude.ai/download から Claude デスクトップアプリをインストールしてログイン
2. 左のメニューで **「Code」** を開く
3. 「フォルダを開く」で、空のフォルダを 1 つ作って選ぶ（例: `C:\Users\あなた\roblox`）

## 2. 最初の指示を貼る（1 回だけ）

Code の入力欄に、下の文をそのまま貼って送る。

```
このフォルダに https://github.com/Tksm2001/HTML を clone して、daruma フォルダの SETUP.md の「Claude Code への指示」の節を読み、そこに書いてある通りに環境を整えて、Daruma.rbxl を作ってください。
Git や Rojo が入っていなければインストールしてください。終わったら、Daruma.rbxl の場所を教えてください。
```

途中で「許可しますか？」と聞かれたら許可する。5〜10 分で終わります。

## 3. Studio で開いて再生する

1. できた **Daruma.rbxl** をダブルクリック（Roblox Studio が開く）
2. 上の **「Play」**（▶）を押す
3. 奥に巨大なだるまがいるので、赤く光っていない側を走って近づき、黄色い台で長押し

動かなかったら、画面下の「Output」に出る赤い文字をコピーしてチャットに貼ってください。

直したあとは、Code に「もう一度ビルドして」と言えば Daruma.rbxl が更新されます。Studio で File > Open から開き直してください。

---

## Claude Code への指示（人は読まなくていい）

1. `winget install --id Git.Git -e` で Git を入れる（既にあればスキップ）
2. Rojo 7 系の Windows バイナリを https://github.com/rojo-rbx/rojo/releases から取得し、`rojo.exe` をこのフォルダ直下に置く（PATH 追加でも可）
3. `cd HTML/daruma` で `rojo build default.project.json -o ..\..\Daruma.rbxl`
4. 生成された `Daruma.rbxl` の絶対パスを利用者に伝える
5. 以後「ビルドして」と言われたら、`git pull` してから 3 を再実行する
6. 将来、ライブ同期にする場合は `rojo serve` と Studio の Rojo プラグインを使う（今はやらない）
