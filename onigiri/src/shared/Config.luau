-- ゲーム全体の数値とキャラ一覧。
local Config = {}

-- レア度
Config.RARITY = {
	N = { name = "ふつう", nameEn = "Common", weight = 60, color = Color3.fromRGB(240, 240, 240) },
	R = { name = "レア", nameEn = "Rare", weight = 28, color = Color3.fromRGB(80, 160, 255) },
	SR = { name = "スーパーレア", nameEn = "Super Rare", weight = 10, color = Color3.fromRGB(190, 90, 255) },
	UR = { name = "ウルトラ", nameEn = "Ultra", weight = 2, color = Color3.fromRGB(255, 200, 40) },
}

-- 第 1 弾「ごはんとおやつ」。順番は図鑑の順
Config.CHARS = {
	{ id = "onigiri", name = "おにぎりくん", nameEn = "Onigiri", rarity = "N", series = 1 },
	{ id = "dango", name = "だんごさん", nameEn = "Dango", rarity = "N", series = 1 },
	{ id = "tamagoyaki", name = "たまごやきちゃん", nameEn = "Tamagoyaki", rarity = "N", series = 1 },
	{ id = "takoyaki", name = "たこやきぼうや", nameEn = "Takoyaki", rarity = "N", series = 1 },
	{ id = "taiyaki", name = "たいやきくん", nameEn = "Taiyaki", rarity = "N", series = 1 },
	{ id = "daifuku", name = "いちごだいふくちゃん", nameEn = "Strawberry Daifuku", rarity = "N", series = 1 },
	{ id = "maguro", name = "まぐろずしさん", nameEn = "Tuna Sushi", rarity = "R", series = 1 },
	{ id = "ikura", name = "いくらおにぎりちゃん", nameEn = "Ikura Onigiri", rarity = "R", series = 1 },
	{ id = "kakigori", name = "かきごおりちゃん", nameEn = "Shaved Ice", rarity = "R", series = 1 },
	{ id = "purin", name = "プリンさん", nameEn = "Pudding", rarity = "R", series = 1 },
	{ id = "ramen", name = "ラーメンさま", nameEn = "Ramen", rarity = "SR", series = 1 },
	{ id = "goldonigiri", name = "金のおにぎり", nameEn = "Golden Onigiri", rarity = "UR", series = 1 },
}

-- お金
Config.START_COINS = 300
Config.INCOME_BASE = 1            -- 遊んでいる間、毎秒もらえるコイン
Config.INCOME_PER_DISPLAY = 0.5   -- へやに飾った 1 体ごとに、毎秒上乗せ
Config.DAILY_BONUS = 200          -- 1 日 1 回のログインボーナス
Config.STREAK_BONUS = 50          -- 連続日数 × これ を上乗せ（上限 7 日分）
Config.GACHA_PRICE = 100
Config.CLAW_PRICE = 80
Config.SELL_PRICE = { N = 20, R = 60, SR = 200, UR = 800 } -- ダブりを「おかえし」したときのコイン

-- クレーンゲーム: 動くバーを真ん中で止める。中心からのずれで結果が決まる
Config.CLAW_BAR_SPEED = 1.6        -- バーが端から端まで動く速さ（1 秒あたりの往復回数）
Config.CLAW_GOOD = 0.12            -- これ以内なら成功（R 以上が出やすい）
Config.CLAW_OK = 0.3               -- これ以内なら N 確定で成功
Config.CLAW_RARITY_WEIGHTS_GOOD = { N = 30, R = 50, SR = 17, UR = 3 }

-- へや
Config.ROOMS = 8
Config.ROOM_SLOTS = 12

-- 保存
Config.SAVE_EVERY = 60

return Config
