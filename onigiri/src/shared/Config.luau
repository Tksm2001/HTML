-- ゲーム全体の数値とキャラ一覧。
local Config = {}

-- レア度
Config.RARITY = {
	N = { name = "ふつう", nameEn = "Common", weight = 60, color = Color3.fromRGB(240, 240, 240) },
	R = { name = "レア", nameEn = "Rare", weight = 28, color = Color3.fromRGB(80, 160, 255) },
	SR = { name = "スーパーレア", nameEn = "Super Rare", weight = 10, color = Color3.fromRGB(190, 90, 255) },
	UR = { name = "ウルトラ", nameEn = "Ultra", weight = 2, color = Color3.fromRGB(255, 200, 40) },
	SEC = { name = "ひみつ", nameEn = "Secret", weight = 0, color = Color3.fromRGB(255, 120, 200) },
}

-- 弾（シリーズ）
Config.SERIES = {
	{ name = "ごはんとおやつ", nameEn = "Rice & Snacks" },
	{ name = "麺とパン", nameEn = "Noodles & Bread" },
}

-- 手作りのキャラ。順番は図鑑の順
Config.CHARS = {
	-- 第 1 弾
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
	-- 第 2 弾
	{ id = "udon", name = "うどんちゃん", nameEn = "Udon", rarity = "N", series = 2 },
	{ id = "yakisoba", name = "やきそばくん", nameEn = "Yakisoba", rarity = "N", series = 2 },
	{ id = "melonpan", name = "メロンパンちゃん", nameEn = "Melon Bun", rarity = "N", series = 2 },
	{ id = "anpan", name = "あんパンくん", nameEn = "Anpan", rarity = "N", series = 2 },
	{ id = "shokupan", name = "しょくパンさん", nameEn = "Toast", rarity = "N", series = 2 },
	{ id = "koppepan", name = "コッペパンくん", nameEn = "Koppe Bun", rarity = "N", series = 2 },
	{ id = "currypan", name = "カレーパンくん", nameEn = "Curry Bun", rarity = "R", series = 2 },
	{ id = "creampan", name = "クリームパンちゃん", nameEn = "Cream Bun", rarity = "R", series = 2 },
	{ id = "zarusoba", name = "ざるそばさん", nameEn = "Zaru Soba", rarity = "R", series = 2 },
	{ id = "tsukemen", name = "つけめんさん", nameEn = "Tsukemen", rarity = "R", series = 2 },
	{ id = "napolitan", name = "ナポリタンちゃん", nameEn = "Napolitan", rarity = "SR", series = 2 },
	{ id = "goldmelonpan", name = "金のメロンパン", nameEn = "Golden Melon Bun", rarity = "UR", series = 2 },
}

-- 味ちがい: 同じ形で、部品の色だけ変える。recolor = { 部品の名前 = 色 }、accent = 頭の小さな飾りの色（省略可）
-- プログラムで図鑑に並び、ガチャでも出る。レア度は元の子と同じ
local function v(base: string, suffix: string, suffixEn: string, recolor, accent)
	return { base = base, suffix = suffix, suffixEn = suffixEn, recolor = recolor, accent = accent }
end
local C = Color3.fromRGB
Config.VARIANTS = {
	v("onigiri", "うめ", "Ume", {}, C(220, 50, 70)),
	v("onigiri", "しゃけ", "Salmon", {}, C(255, 140, 90)),
	v("onigiri", "ツナマヨ", "Tuna Mayo", {}, C(250, 235, 190)),
	v("onigiri", "こんぶ", "Kombu", {}, C(60, 70, 50)),
	v("onigiri", "おかか", "Okaka", {}, C(170, 110, 70)),
	v("dango", "みたらし", "Mitarashi", { Dango = C(205, 150, 70) }),
	v("dango", "あんこ", "Anko", { Dango = C(110, 55, 60) }),
	v("dango", "よもぎ", "Yomogi", { Dango = C(110, 150, 90) }),
	v("tamagoyaki", "だしまき", "Dashimaki", { Body = C(255, 235, 150), Edge = C(255, 235, 150) }),
	v("tamagoyaki", "めんたい", "Mentai", { Body = C(255, 190, 170), Edge = C(255, 190, 170) }),
	v("takoyaki", "ねぎ", "Negi", { Sauce = C(90, 160, 80) }),
	v("takoyaki", "チーズ", "Cheese", { Sauce = C(255, 215, 110) }),
	v("takoyaki", "めんたいマヨ", "Mentai Mayo", { Sauce = C(255, 150, 150) }),
	v("taiyaki", "クリーム", "Custard", { Anko = C(255, 230, 150) }),
	v("taiyaki", "チョコ", "Choco", { Body = C(120, 80, 60), Tail = C(120, 80, 60), Fin = C(90, 60, 45), Anko = C(80, 50, 40) }),
	v("taiyaki", "まっちゃ", "Matcha", { Body = C(150, 180, 110), Tail = C(150, 180, 110), Fin = C(110, 140, 80) }),
	v("daifuku", "みかん", "Mikan", { Strawberry = C(255, 160, 50) }),
	v("daifuku", "ぶどう", "Grape", { Strawberry = C(140, 80, 170) }),
	v("daifuku", "よもぎ", "Yomogi", { Body = C(170, 190, 130) }),
	v("maguro", "サーモン", "Salmon", { Tuna = C(255, 150, 100), Sinew = C(255, 235, 220) }),
	v("maguro", "たまご", "Egg", { Tuna = C(255, 215, 90), Sinew = C(255, 240, 180) }),
	v("maguro", "えび", "Shrimp", { Tuna = C(255, 170, 160), Sinew = C(255, 80, 80) }),
	v("ikura", "うに", "Uni", { Ikura = C(240, 180, 60) }),
	v("ikura", "とびこ", "Tobiko", { Ikura = C(255, 100, 60) }),
	v("kakigori", "いちご", "Strawberry", { Syrup = C(255, 80, 100), Drip = C(255, 80, 100) }),
	v("kakigori", "メロン", "Melon", { Syrup = C(120, 220, 110), Drip = C(120, 220, 110) }),
	v("kakigori", "レモン", "Lemon", { Syrup = C(255, 230, 90), Drip = C(255, 230, 90) }),
	v("purin", "チョコ", "Choco", { Body = C(130, 85, 60) }),
	v("purin", "いちご", "Strawberry", { Body = C(255, 180, 200), Caramel = C(220, 60, 90), Drip = C(220, 60, 90) }),
	v("purin", "まっちゃ", "Matcha", { Body = C(150, 185, 110) }),
	v("ramen", "みそ", "Miso", { Soup = C(190, 140, 80) }),
	v("ramen", "とんこつ", "Tonkotsu", { Soup = C(245, 235, 215) }),
	v("ramen", "しお", "Shio", { Soup = C(250, 240, 200) }),
	v("udon", "きつね", "Kitsune", { Topping = C(230, 170, 90) }),
	v("udon", "カレー", "Curry", { Soup = C(200, 140, 60) }),
	v("yakisoba", "しお", "Shio", { Noodle = C(255, 235, 170) }),
	v("melonpan", "チョコチップ", "Choco Chip", { Grid = C(90, 60, 45) }),
	v("melonpan", "いちご", "Strawberry", { Top = C(255, 170, 190), Grid = C(220, 90, 120) }),
	v("anpan", "しろあん", "White Bean", { Body = C(240, 220, 190) }),
	v("currypan", "チーズ", "Cheese", { Body = C(215, 170, 110) }),
	v("creampan", "チョコ", "Choco", { Body = C(130, 85, 60) }),
	v("shokupan", "トースト", "Toasted", { Crumb = C(230, 190, 120) }),
}

-- ひみつの子: 図鑑に「？」で出る。ガチャでは出ない（イベントで手に入る）
Config.SECRETS = {
	{ id = "obakeonigiri", name = "おばけおにぎり", nameEn = "Ghost Onigiri", rarity = "SEC", series = 1, base = "onigiri", recolor = { Body = C(235, 235, 250), Nori = C(80, 60, 110) }, accent = C(150, 110, 200), secret = true },
	{ id = "yukimelonpan", name = "ゆきメロンパン", nameEn = "Snow Melon Bun", rarity = "SEC", series = 2, base = "melonpan", recolor = { Top = C(250, 250, 255), Grid = C(200, 220, 255) }, accent = C(120, 180, 255), secret = true },
}

-- 全部の子（手作り + 味ちがい + ひみつ）。図鑑の順
Config.ALL = {}
Config.BY_ID = {}
local baseById = {}
for _, c in Config.CHARS do
	baseById[c.id] = c
	table.insert(Config.ALL, c)
	Config.BY_ID[c.id] = c
end
for _, vd in Config.VARIANTS do
	local base = baseById[vd.base]
	local c = {
		id = vd.base .. "_" .. vd.suffixEn:lower():gsub("%s", ""),
		name = base.name .. "（" .. vd.suffix .. "）",
		nameEn = base.nameEn .. " (" .. vd.suffixEn .. ")",
		rarity = base.rarity,
		series = base.series,
		base = vd.base,
		recolor = vd.recolor,
		accent = vd.accent,
	}
	table.insert(Config.ALL, c)
	Config.BY_ID[c.id] = c
end
for _, c in Config.SECRETS do
	table.insert(Config.ALL, c)
	Config.BY_ID[c.id] = c
end

-- お金
Config.START_COINS = 300
Config.INCOME_BASE = 1            -- 遊んでいる間、毎秒もらえるコイン
Config.INCOME_PER_DISPLAY = 0.5   -- へやに飾った 1 体ごとに、毎秒上乗せ
Config.DAILY_BONUS = 200          -- 1 日 1 回のログインボーナス
Config.STREAK_BONUS = 50          -- 連続日数 × これ を上乗せ（上限 7 日分）
Config.GACHA_PRICE = 100
Config.CLAW_PRICE = 80
Config.SELL_PRICE = { N = 20, R = 60, SR = 200, UR = 800, SEC = 0 } -- ダブりを「おかえし」したときのコイン

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
