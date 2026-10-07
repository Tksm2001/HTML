# 公開の手順と、貼り付ける文章（バンカーの大冒険）

かためだるま（`../../daruma/publish/PUBLISH.md`）と同じ手順。

| ファイル | 使い道 |
|---|---|
| `icon_512.png` | アイコン（タクト） |
| `thumb1_tower.jpg` | サムネイル 1 枚目（塔の中、敵と対峙） |
| `thumb2_office.jpg` | サムネイル 2 枚目（オフィス） |
| `thumb3_boss.jpg` | サムネイル 3 枚目（取締役会・ダークマネー） |

## タイトル（そのまま貼る）

```
バンカーの大冒険｜マネータワーを駆け上がれ Banker's Tower
```

## 説明文（そのまま貼る）

```
新人バンカーのタクトになって、入るたびに形が変わる「マネータワー」を駆け上がろう！
1 歩動くと敵も 1 歩動く、じっくり考えるターン制のダンジョン。
倒れると持ち物は失う。でもキャリア（ランク）と物語は残る。
インターン → アナリスト → VP → MD → 伝説のバンカーへ、何度も挑んで出世しろ！

・拾った名刺と電卓は、使ってみるまで何か分からない
・罠、監査室、金庫室、塔の中の臨時売店
・万年筆とスーツを強化・合成。ネクタイで特殊能力
・5 の倍数の階は「昇進試験」。30F の取締役会でダークマネーと対決
・毎日「本日の案件」で全員同じ塔に挑戦、到達階ランキング
・課金なし。すべてゲーム内の円だけ

Become rookie banker Takuto and climb the ever-changing Money Tower!
A turn-based roguelike: every step you take, monsters take one too.
Lose your items when you fall – but your career rank and story remain.
Rise from Intern to Legendary Banker through repeated runs.

- Unidentified cards & calculators, traps, vault rooms, in-tower shop
- Upgrade and merge your pen (weapon) and suit (armor)
- Promotion exams every 5 floors, final boss on floor 30
- Daily challenge tower with a floor-reached leaderboard
- No purchases – everything uses in-game yen

音楽: MiniMax-Music3 で制作 / Music generated with MiniMax-Music3
```

## 公開のしかた

1. Studio で `C:\Rublox\Banker.rbxl` を開く
2. **Alt + P**（Roblox に公開）。「新しいバーチャル空間」で上の名前と説明を貼り、**作成**
3. https://create.roblox.com/dashboard/creations で新しいゲームを開き、
   - プレース → アイコン: `icon_512.png`
   - プレース → サムネイル: `thumb1〜3`（自動アップロードが効かなかったので手で）
   - オーディエンス → 対象範囲 → 質問フォーム: 17 問すべて「なし／いいえ」（ギャンブル表現なし、有料ランダムアイテムなし）
   - 環境設定 → オーディエンス「公開」→ 変更を保存
4. Studio の Home → Game Settings → Security → **Enable Studio Access to API Services** をオン（保存のテストに必要）

## 公開前にできれば

- 保存（DataStore）が効くか: API アクセスをオンにして Studio で ▶ → 1 周して帰還 → ■ → もう一度 ▶ でランクと持ち物が残っているか
