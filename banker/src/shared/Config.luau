-- ゲーム全体の決まりごと（数字はここだけ直せば効く）
local Config = {}

-- ===== 塔（ダンジョン）のマス目 =====
Config.CELL = 4 -- 1 マス = 4 スタッド
Config.MAP_W = 44 -- 横のマス数
Config.MAP_H = 30 -- 縦のマス数
Config.WALL_H = 4.5 -- 壁の高さ
Config.ZONE_GAP = 600 -- プレイヤーごとの区画の間隔（スタッド）
Config.ZONE_ORIGIN = Vector3.new(0, 0, 1500) -- 区画はここから +X 方向に並ぶ（オフィスから離す）

-- ===== ランク（キャリア）=====
-- points = 周ごとに「到達した階」ぶん貯まる。生きて帰ると 1.5 倍
Config.RANKS = {
	{ title = "インターン", titleEn = "Intern", points = 0, floorCap = 5 },
	{ title = "アナリスト", titleEn = "Analyst", points = 8, floorCap = 10 },
	{ title = "アソシエイト", titleEn = "Associate", points = 25, floorCap = 15 },
	{ title = "VP", titleEn = "Vice President", points = 60, floorCap = 20 },
	{ title = "ディレクター", titleEn = "Director", points = 120, floorCap = 25 },
	{ title = "MD", titleEn = "Managing Director", points = 220, floorCap = 30 },
	{ title = "伝説のバンカー", titleEn = "Legendary Banker", points = 400, floorCap = 99 },
}
Config.BOSS_FLOOR = 30 -- 取締役会（ダークマネー）

-- 塔の「章」（見た目と敵の出方が変わる）
Config.CHAPTERS = {
	{ from = 1, name = "新人フロア", nameEn = "Rookie Floors", desc = "まずは 1 歩ずつ。赤字くんが多い" },
	{ from = 5, name = "営業フロア", nameEn = "Sales Floors", desc = "コウモリが円を狙う。ねずみは放っておくと増える" },
	{ from = 10, name = "会議室フロア", nameEn = "Meeting Floors", desc = "ねむけとカゲに注意。ガラスの向こうは見えない" },
	{ from = 15, name = "金庫フロア", nameEn = "Vault Floors", desc = "監査ロボとワニの巣。金貨の山はあるが罠も多い" },
	{ from = 20, name = "役員フロア", nameEn = "Executive Floors", desc = "為替カメレオンと利息ヘビ。ダークコインが現れる" },
	{ from = 25, name = "闇フロア", nameEn = "Dark Floors", desc = "破産おばけとダークコイン。取締役会はすぐそこ" },
	{ from = 30, name = "取締役会", nameEn = "The Board", desc = "ダークマネーとの対決" },
}
function Config.chapterFor(floor: number)
	local c = Config.CHAPTERS[1]
	for _, ch in Config.CHAPTERS do
		if floor >= ch.from then
			c = ch
		end
	end
	return c
end
Config.EXAM_EVERY = 5 -- 5 の倍数の階は「昇進試験」（固定の間取り＋クライアント戦）

-- ===== 主人公の基本 =====
Config.BASE_HP = 15
Config.HP_PER_LEVEL = 5
Config.BASE_ATK = 3
Config.ATK_PER_LEVEL = 1
Config.MAX_LEVEL = 30
-- レベルに必要な累計経験値
Config.EXP_TABLE = {}
do
	local total = 0
	for lv = 1, Config.MAX_LEVEL do
		Config.EXP_TABLE[lv] = total
		total += math.floor(6 * lv ^ 1.6)
	end
end
Config.HUNGER_MAX = 100 -- やる気
Config.HUNGER_PER_TURN = 0.12 -- 1 歩で減る量（約 800 歩で 0）
Config.HP_REGEN_TURNS = 8 -- 何ターンに 1 回 HP が 1 回復するか（やる気がある時）
Config.INVENTORY_MAX = 16
Config.SIGHT = 6 -- 通路で見える距離（マス）

-- ===== 円 =====
Config.START_YEN = 500
Config.LOCKER_SLOTS_BY_RANK = { 0, 0, 1, 2, 3, 4, 6 }

-- ===== 1 階の生成 =====
Config.ROOMS_MIN = 4
Config.ROOMS_MAX = 7
Config.ROOM_MIN = 4
Config.ROOM_MAX = 9
Config.ITEMS_PER_FLOOR = { 4, 7 }
Config.TRAPS_PER_FLOOR = { 2, 5 }
Config.MONSTERS_PER_FLOOR = { 4, 7 }
Config.SPAWN_EVERY = 40 -- 何ターンごとに敵が湧くか
Config.TURN_DELAY = 0.12 -- 1 ターンの演出時間（秒）

-- ===== 毎日の案件 =====
Config.DAILY_FLOORS = 10

-- ===== 保存 =====
Config.SAVE_EVERY = 60

-- ランク番号（1 始まり）を points から求める
function Config.rankFor(points: number): number
	local r = 1
	for i, rk in Config.RANKS do
		if points >= rk.points then
			r = i
		end
	end
	return r
end

return Config
