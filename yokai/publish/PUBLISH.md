# 公開の手順と、貼り付ける文章（ようかい神社）

かためだるま（`../../daruma/publish/PUBLISH.md`）と同じ手順。違いはファイル名と文章だけ。

| ファイル | 使い道 |
|---|---|
| `icon_512.png` | アイコン（たぬきの顔） |
| `thumb1_village.jpg` | サムネイル 1 枚目（夜の村） |
| `thumb2_shrine.jpg` | サムネイル 2 枚目（神社に並んだ妖怪） |
| `thumb3_mikoshi.jpg` | サムネイル 3 枚目（おみこしで担ぐ） |

## タイトル（そのまま貼る）

```
ようかい神社｜妖怪をあつめて盗め Steal a Yokai
```

## 説明文（そのまま貼る）

```
かわいい妖怪をあつめて、自分の神社に住まわせよう。
置いた妖怪が お賽銭を貯めてくれる。
よその神社の妖怪を おみこしに乗せて担いで逃げろ！
自分の鳥居をくぐれば 自分の物。
守る側は お札を投げろ。当たった泥棒は 3 秒かかしになる。

・かっぱ、たぬき、からかさ、ちょうちんおばけ、きつね、ぬりかべ、ろくろ首、天狗
・伝説の妖怪は重くて 2 人がかり。友だちと担ごう
・夜はレアな妖怪が行列に出やすい
・留守のあいだも お賽銭が貯まる

Collect cute yokai and keep them at your shrine – they earn coins for you.
Carry yokai away from other shrines on a tiny mikoshi and run home through your torii!
Defend with ofuda: a hit turns the thief into a scarecrow for 3 seconds.

- 8 yokai: Kappa, Tanuki, Karakasa, Chochin, Kitsune, Nurikabe, Rokurokubi, Tengu
- Legendary yokai need two carriers – bring a friend
- Rare yokai parade at night
- Coins keep flowing while you're away
```

## 公開のしかた

1. Studio で `C:\Rublox\Yokai.rbxl` を開く
2. **Alt + P**（Roblox に公開）。「新しいバーチャル空間」で上の名前と説明を貼り、**作成**（この PC では窓のボタンが描画されない。「キャンセル」の右に見えないまま存在する）
3. https://create.roblox.com/dashboard/creations で新しいゲームを開き、
   - プレース → アイコン: `icon_512.png`
   - プレース → サムネイル → 「バーチャル空間の詳細ページ」タブ: `thumb1〜3`（自動アップロードが効かなかったので手で）
   - オーディエンス → 対象範囲 → 質問フォーム: 17 問すべて「なし／いいえ」（かためだるまと同じ。暴力・流血・課金なし）
   - 環境設定 → オーディエンス「公開」→ 変更を保存
4. Studio の Home → Game Settings → Security → **Enable Studio Access to API Services** をオン（保存のテストに必要）

## 公開前にできれば

- Test → Clients and Servers（2 人）で、仲間と担ぐ／お札が当たる／結界 を確認
- 保存（DataStore）が効くか: API アクセスをオンにして Studio で ▶ → 妖怪を置いて ■ → もう一度 ▶ で残っているか
