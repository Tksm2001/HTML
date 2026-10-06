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

return Config
