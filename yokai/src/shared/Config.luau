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

-- 村の形
Config.PLOTS = 8                 -- 神社の数 = サーバーの人数
Config.PLOT_RADIUS = 62          -- 広場の中心から各神社の中心までの距離
Config.PLOT_SIZE = 30            -- 神社の敷地の一辺
Config.PARADE_RADIUS = 24        -- 百鬼夜行が回る円の半径
Config.PARADE_SPEED = 4          -- 行列の歩く速さ（スタッド/秒）
Config.PARADE_SPAWN_EVERY = 8    -- 何秒ごとに妖怪が出てくるか
Config.PARADE_MAX = 10           -- 行列にいる妖怪の最大数
Config.PARADE_LAPS = 1.5         -- 何周したら消えるか
-- 行列に出てくる格の割合（合計 100）
Config.PARADE_RARITY_WEIGHTS = { common = 78, rare = 19, legend = 3 }

-- 台座
Config.PEDESTALS_START = 3
Config.PEDESTAL_UPGRADES = {     -- 台座を増やす値段（3→5、5→8）
	{ count = 5, price = 2500 },
	{ count = 8, price = 12000 },
}

-- 担ぐ・盗む
Config.CARRY_SPEED = 13          -- 担いでいるときの歩く速さ（通常 16）
Config.PICKUP_HOLD = 0.6         -- 担ぐのに必要な長押し秒数
Config.STEAL_HOLD = 1.5          -- よその妖怪を担ぐときの長押し秒数
Config.DROP_RETURN_SECONDS = 10  -- 落ちた妖怪が持ち主の神社に戻るまで
Config.NEWBIE_PROTECT_SECONDS = 180 -- 入ってから守られる時間

-- お札・かかし・結界
Config.OFUDA_COOLDOWN = 1.5
Config.OFUDA_SPEED = 45
Config.OFUDA_RANGE = 30
Config.KAKASHI_SECONDS = 3
Config.LOCK_SECONDS = 60
Config.LOCK_COOLDOWN = 300

-- お賽銭
Config.START_COINS = 60
Config.OFFLINE_CAP_SECONDS = 7200 -- 留守中に貯まる上限（2 時間分）
Config.SAVE_EVERY = 60

return Config
