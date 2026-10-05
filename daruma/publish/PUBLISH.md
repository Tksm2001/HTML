# 公開の手順と、貼り付ける文章

このフォルダの画像:

| ファイル | 使い道 |
|---|---|
| `icon_512.png` | アイコン（ゲーム一覧に出る正方形の画像） |
| `thumb1_shrine.png` | サムネイル 1 枚目（だるま神社） |
| `thumb2_shibuya.png` | サムネイル 2 枚目（渋谷） |
| `thumb3_fuji.png` | サムネイル 3 枚目（富士山） |

## タイトル（そのまま貼る）

```
かためだるま｜だるまさんがころんだ Red Light Daruma
```

## 説明文（そのまま貼る）

```
片目しか入っていない巨大だるまから にげろ！
だるまは「黒目の側」しか見えない。白目の側なら 動いても見つからない。
ふりむいたら 赤い床では 止まれ。緑の床は 安全。
だるまが目をチカチカさせたら 要注意…見える側が入れ替わる！

見つかると 小さなだるまにされてしまう。仲間に助けてもらおう。
足元の黄色い台で長押しして もう片方の目を入れたら 勝ち！

・ステージ: だるま神社 / 渋谷 / 富士山
・むずかしいモード（夜）: だるまが嘘をつく
・友だちと助け合って遊べる 鬼ごっこ系ゲーム

Run from the giant One-Eyed Daruma!
It can only see the side with its painted eye. On the blank-eye side, you can move freely.
When it turns: FREEZE on the RED floor. GREEN is safe.
Watch out when the eye blinks – the safe side may switch!

Get caught and you become a tiny daruma. Ask a friend to rescue you.
Hold on the yellow stand at its feet to paint the second eye and win!

- Stages: Daruma Shrine / Shibuya / Mt. Fuji
- HARD mode (night): the Daruma lies
- A Red Light, Green Light tag game to play with friends
```

## 公開のしかた（あなたのアカウントで行う作業）

Claude はあなたのアカウントでボタンを押せないので、ここだけお願いします。分からなければ、画面のスクリーンショットを送ってください。

1. Studio で `C:\Rublox\Daruma.rbxl` を開く（いつもの画面）
2. 上のメニューの **File（ファイル）→ Publish to Roblox（Robloxに公開）** を押す
3. 「新しい体験（New experience）」を選び、上のタイトルと説明文を貼る。ジャンルは「Party & Casual」など近いもの
4. **Create（作成）** を押す。これで Roblox に保存される（まだ一般には公開されていない）
5. ブラウザで https://create.roblox.com/dashboard/creations を開き、今作ったゲームを選ぶ
6. 左のメニューから次を設定する
   - **Places / Thumbnails（場所 / サムネイル）**: アイコンに `icon_512.png`、サムネイルに `thumb1〜3` を入れる
   - **Questionnaire（アンケート）**: 年齢区分のアンケートに答える。暴力・流血・課金などの質問は、このゲームでは全部「なし」
   - **Audience / Access（公開範囲）**: 「Public（一般公開）」にする。対応機器は Computer / Phone / Tablet に印を付ける
7. Studio に戻り、**Home → Game Settings → Security → Enable Studio Access to API Services** をオンにする（勝った回数の保存を Studio でも試せるようになる）

## 公開前にできれば: 2 人で救出を試す

救出（仲間が 3 秒長押しで助ける）は 2 人いないと試せないため、まだ確かめていません。Studio だけで 2 人分を動かせます。

1. Studio の上のメニューで **Test（テスト）** を開く
2. 「Clients and Servers（クライアントとサーバー）」の人数を **2** にして **Start（開始）** を押す
3. 窓が 2 つ開く（どちらもあなた）。片方をわざと捕まえて、もう片方で近づいて E キーを 3 秒長押しする
4. 「たすかった！」と出れば OK。終わったら最初の窓で **Cleanup（後片付け）** を押す
