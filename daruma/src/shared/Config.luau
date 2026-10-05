-- ゲーム全体の数値。遊びの手触りはほぼここで決まる。
local Config = {}

-- フィールド
Config.FIELD_WIDTH = 60          -- 横幅（スタッド）
Config.FIELD_LENGTH = 200        -- 奥行き
Config.DARUMA_Z = -90            -- だるまの位置（奥）
Config.SPAWN_Z = 90              -- スタート地点（手前）
Config.DARUMA_RADIUS = 12        -- だるまの大きさの基準（横幅の半分）

-- ラウンド（モード共通）
Config.RESCUE_HOLD = 3           -- 救出に必要な長押し秒数
Config.PAINT_HOLD = 1.5          -- 目入れに必要な長押し秒数
Config.END_WAIT = 6              -- ラウンド終了後、次に進むまでの秒数

-- 参道の障害物。左右を交互にふさいで、ときどき危ない側へ渡らないと進めないようにする
--   rack: 絵馬掛け（片側の半分と中央線をふさぐ柵）。side = "L"（x がマイナス側）/ "R"
--   box: 賽銭箱、basin: 手水鉢（回り込む小さな障害物）
Config.OBSTACLES = {
	normal = {
		{ kind = "rack", side = "L", z = 50 },
		{ kind = "rack", side = "R", z = 20 },
		{ kind = "rack", side = "L", z = -10 },
		{ kind = "rack", side = "R", z = -40 },
		{ kind = "box", x = 8, z = 35 },
		{ kind = "box", x = -10, z = 5 },
		{ kind = "basin", x = -12, z = -20 },
		{ kind = "basin", x = 10, z = -55 },
	},
	-- むずかしいモードで追加される分
	hard = {
		{ kind = "rack", side = "R", z = 64 },
		{ kind = "rack", side = "L", z = 35 },
		{ kind = "rack", side = "R", z = 5 },
		{ kind = "rack", side = "L", z = -28 },
		{ kind = "rack", side = "L", z = -58 },
	},
}

-- モードごとの数値
--   SAFE_*: 背を向けている秒数 / LOOK_*: こちらを見ている秒数
--   GRACE: 振り向いた直後、動いていても見逃す猶予
--   MOVE_THRESHOLD: これ以上の速さで動くと「動いた」扱い
--   EYE_SWAP_CHANCE: 振り向くときに目を入れ替える確率
--   FAKE_WINK_CHANCE: チカチカしたのに入れ替えない（嘘）確率
--   QUICK_TURN_CHANCE: 背を向けてすぐ振り向く確率
--   WINK_TIME: 入れ替えの予告（チカチカ）の長さ
--   ROUND_TIME: これを過ぎるとだるまの勝ち
Config.MODES = {
	normal = {
		SAFE_MIN = 3,
		SAFE_MAX = 6,
		LOOK_MIN = 2,
		LOOK_MAX = 4,
		GRACE = 0.35,
		MOVE_THRESHOLD = 3,
		EYE_SWAP_CHANCE = 0.35,
		FAKE_WINK_CHANCE = 0,
		QUICK_TURN_CHANCE = 0,
		WINK_TIME = 0.8,
		ROUND_TIME = 120,
	},
	hard = {
		SAFE_MIN = 1.8,
		SAFE_MAX = 4,
		LOOK_MIN = 2,
		LOOK_MAX = 3.5,
		GRACE = 0.2,
		MOVE_THRESHOLD = 2,
		EYE_SWAP_CHANCE = 0.45,
		FAKE_WINK_CHANCE = 0.25,
		QUICK_TURN_CHANCE = 0.25,
		WINK_TIME = 0.5,
		ROUND_TIME = 90,
	},
}

return Config
