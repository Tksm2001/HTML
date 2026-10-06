-- ゲーム全体の数値。遊びの手触りはほぼここで決まる。
local Config = {}

-- 妖怪。順番は図鑑の順。
--   rarity: "common" / "rare" / "legend" / "god"
--   income: 置いたとき毎秒入るお賽銭 / price: 行列での値段
--   carriers: 担ぐのに必要な人数（伝説以上は 2 人）
Config.YOKAI = {
	{ id = "kappa", name = "かっぱ", nameEn = "Kappa", rarity = "common", income = 1, price = 50, carriers = 1 },
	{ id = "tanuki", name = "たぬき", nameEn = "Tanuki", rarity = "common", income = 2, price = 120, carriers = 1 },
	{ id = "karakasa", name = "からかさ", nameEn = "Karakasa", rarity = "common", income = 2, price = 150, carriers = 1 },
	{ id = "chochin", name = "ちょうちんおばけ", nameEn = "Chochin", rarity = "common", income = 3, price = 200, carriers = 1 },
	{ id = "kitsune", name = "きつね", nameEn = "Kitsune", rarity = "rare", income = 8, price = 1000, carriers = 1 },
	{ id = "nurikabe", name = "ぬりかべ", nameEn = "Nurikabe", rarity = "rare", income = 10, price = 1500, carriers = 1 },
	{ id = "rokurokubi", name = "ろくろ首", nameEn = "Rokurokubi", rarity = "rare", income = 15, price = 3000, carriers = 1 },
	{ id = "tengu", name = "天狗", nameEn = "Tengu", rarity = "legend", income = 40, price = 15000, carriers = 2 },
}

Config.RARITY = {
	common = { name = "ふつう", nameEn = "Common", color = Color3.fromRGB(240, 240, 240) },
	rare = { name = "レア", nameEn = "Rare", color = Color3.fromRGB(80, 160, 255) },
	legend = { name = "伝説", nameEn = "Legend", color = Color3.fromRGB(190, 90, 255) },
	god = { name = "神", nameEn = "God", color = Color3.fromRGB(255, 200, 40) },
}

Config.GOLD_CHANCE = 0.05        -- 金ぴか（収入 3 倍）になる確率
Config.GOLD_MULTIPLIER = 3

return Config
