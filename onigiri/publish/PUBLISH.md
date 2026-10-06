# 公開の手順と、貼り付ける文章（おにぎりーず）

かためだるま（`../../daruma/publish/PUBLISH.md`）と同じ手順。

| ファイル | 使い道 |
|---|---|
| `icon_512.png` | アイコン（おにぎりくん） |
| `thumb1_room.jpg` | サムネイル 1 枚目（へやに飾ったところ） |
| `thumb2_street.jpg` | サムネイル 2 枚目（商店街） |
| `thumb3_gacha.jpg` | サムネイル 3 枚目（ガチャの結果） |

## タイトル（そのまま貼る）

```
おにぎりーず｜ガチャで集めてへやに飾ろう Onigiri Friends
```

## 説明文（そのまま貼る）

```
もぐもぐ商店街の だがしやで ガチャガチャをまわそう！
おにぎりくん、だんごさん、たこやきぼうや、ラーメンさま…
かわいい食べものの子たちを あつめて、自分のへやの たなに飾ろう。
飾った子が いると コインが増える。
ゲームコーナーのクレーンゲームは まん中で止めると レアが出やすい！

・第1弾「ごはんとおやつ」12体 ＋ 第2弾「麺とパン」12体
・味ちがい 42体（うめ、しゃけ、みたらし、チョコ…）
・ひみつの子も…？
・毎日来ると ログインボーナス。ダブりは「おかえし」でコインに
・ガチャはゲーム内コインだけ。課金では回しません

Turn the gacha at the candy shop on Mogumogu Street!
Collect cute food friends – Onigiri, Dango, Takoyaki, Ramen and more –
and display them on the shelves of your own tatami room.
Displayed friends earn you coins. Try the claw machine in the game corner too!

- Series 1 "Rice & Snacks" (12) + Series 2 "Noodles & Bread" (12)
- 42 flavor variants and secret friends
- Daily login bonus. Return duplicates for coins
- Gacha uses in-game coins only – never Robux
```

## 公開のしかた

1. Studio で `C:\Rublox\Onigiri.rbxl` を開く
2. **Alt + P**（Roblox に公開）。「新しいバーチャル空間」で上の名前と説明を貼り、**作成**（この PC では窓のボタンが描画されない。「キャンセル」の右に見えないまま存在する）
3. https://create.roblox.com/dashboard/creations で新しいゲームを開き、
   - プレース → アイコン: `icon_512.png`
   - プレース → サムネイル → 「バーチャル空間の詳細ページ」タブ: `thumb1〜3`（自動アップロードが効かなかったので手で）
   - オーディエンス → 対象範囲 → 質問フォーム: 17 問すべて「なし／いいえ」。**「有料ランダムアイテム」も「いいえ」**（ガチャはゲーム内コインだけなので）
   - 環境設定 → オーディエンス「公開」→ 変更を保存
4. Studio の Home → Game Settings → Security → **Enable Studio Access to API Services** をオン（保存のテストに必要）

## 公開前にできれば

- 保存（DataStore）が効くか: API アクセスをオンにして Studio で ▶ → ガチャを回して飾って ■ → もう一度 ▶ で残っているか
- 友達のへやに入れるか: Test → Clients and Servers（2 人）
