-- ゲーム全体の数値。遊びの手触りはほぼここで決まる。
local Config = {}

-- フィールド
Config.FIELD_WIDTH = 60          -- 横幅（スタッド）
Config.FIELD_LENGTH = 200        -- 奥行き
Config.DARUMA_Z = -90            -- だるまの位置（奥）
Config.SPAWN_Z = 90              -- スタート地点（手前）
Config.DARUMA_RADIUS = 12

-- だるまのリズム
Config.SAFE_MIN = 3              -- 背を向けている秒数（最短）
Config.SAFE_MAX = 6              -- 同（最長）
Config.LOOK_MIN = 2              -- こちらを見ている秒数（最短）
Config.LOOK_MAX = 4              -- 同（最長）
Config.GRACE = 0.35              -- 振り向いた直後、動いていても見逃す猶予
Config.MOVE_THRESHOLD = 3        -- これ以上の速さで動くと「動いた」扱い
Config.EYE_SWAP_CHANCE = 0.35    -- 振り向くときに目を入れ替える確率
Config.WINK_TIME = 0.6           -- 目を入れ替える前の予告時間

-- ラウンド
Config.ROUND_TIME = 120          -- これを過ぎるとだるまの勝ち
Config.RESCUE_HOLD = 3           -- 救出に必要な長押し秒数
Config.PAINT_HOLD = 1.5          -- 目入れに必要な長押し秒数
Config.END_WAIT = 6              -- ラウンド終了後、次に進むまでの秒数

return Config
