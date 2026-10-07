-- 敵（損失のモンスター）の一覧。floors = 出る階、special = 個性
local Monsters = {}

Monsters.LIST = {
	{ id = "akaji", name = "あかじくん", nameEn = "Deficit", hp = 6, atk = 2, def = 0, exp = 3, floors = { 1, 6 }, weight = 10, desc = "いちばん弱い。でも数が多い" },
	{ id = "bubble", name = "バブルん", nameEn = "Bubbly", hp = 10, atk = 3, def = 0, exp = 6, floors = { 2, 10 }, weight = 8, special = "grow", desc = "ターンごとに大きくなり、攻撃も上がる。割れると小さくなる" },
	{ id = "fee", name = "手数料コウモリ", nameEn = "Fee Bat", hp = 8, atk = 2, def = 1, exp = 6, floors = { 2, 12 }, weight = 7, special = "steal", desc = "円を盗んで逃げる。倒すと返してくれる" },
	{ id = "inflation", name = "インフレねずみ", nameEn = "Inflation Mouse", hp = 7, atk = 3, def = 0, exp = 4, floors = { 3, 14 }, weight = 6, special = "split", desc = "ほうっておくと増える" },
	{ id = "risk", name = "リスクのカゲ", nameEn = "Risk Shade", hp = 12, atk = 5, def = 1, exp = 10, floors = { 4, 16 }, weight = 6, special = "invisible", desc = "近づくまで見えない" },
	{ id = "gator", name = "不良債権ワニ", nameEn = "Bad Debt Gator", hp = 22, atk = 7, def = 3, exp = 18, floors = { 6, 20 }, weight = 5, special = "rust", desc = "かみつくとスーツの強化値が下がる" },
	{ id = "fx", name = "為替カメレオン", nameEn = "FX Chameleon", hp = 16, atk = 5, def = 2, exp = 14, floors = { 7, 22 }, weight = 5, special = "shift", desc = "色が変わるたびに攻撃と防御が入れ替わる" },
	{ id = "interest", name = "利息ヘビ", nameEn = "Interest Snake", hp = 20, atk = 6, def = 2, exp = 16, floors = { 9, 26 }, weight = 5, special = "stress", desc = "かまれるとストレス（毎ターン HP −1）" },
	{ id = "sleepy", name = "会議のねむけ", nameEn = "Meeting Drowse", hp = 14, atk = 3, def = 2, exp = 12, floors = { 5, 20 }, weight = 5, special = "sleep", desc = "さわると居眠りしてしまう" },
	{ id = "bankrupt", name = "破産おばけ", nameEn = "Bankrupt Ghost", hp = 30, atk = 9, def = 4, exp = 40, floors = { 10, 99 }, weight = 2, special = "rich", desc = "レア。倒すと大金" },
	{ id = "auditor", name = "監査ロボ", nameEn = "Audit Bot", hp = 28, atk = 8, def = 5, exp = 30, floors = { 12, 99 }, weight = 4, special = "armor", desc = "かたい。電卓がよく効く" },
	{ id = "darkcoin", name = "ダークコイン", nameEn = "Dark Coin", hp = 36, atk = 11, def = 5, exp = 50, floors = { 18, 99 }, weight = 4, special = "drain", desc = "さわると やる気を吸う" },
	-- ===== 昇進試験（5 の倍数の階）の「クライアント」=====
	{ id = "client", name = "気むずかしいクライアント", nameEn = "Tough Client", hp = 40, atk = 7, def = 3, exp = 40, floors = { 0, 0 }, weight = 0, boss = "exam", desc = "プレゼンで勝て（戦闘ルールは同じ）" },
	-- ===== 30F 取締役会 =====
	{ id = "director", name = "取締役", nameEn = "Board Director", hp = 60, atk = 12, def = 6, exp = 120, floors = { 0, 0 }, weight = 0, boss = "board", desc = "3 人同時に出てくる" },
	{ id = "darkmoney", name = "ダークマネー", nameEn = "Dark Money", hp = 180, atk = 15, def = 8, exp = 500, floors = { 0, 0 }, weight = 0, boss = "final", special = "drain", desc = "塔の主。昔のバンカーの欲が形になったもの" },
}

Monsters.BY_ID = {}
for _, m in Monsters.LIST do
	Monsters.BY_ID[m.id] = m
end

-- 章ごとに出やすい敵（重みの倍率）
Monsters.CHAPTER_BIAS = {
	{ from = 1, ids = { akaji = 3, bubble = 1.5 } },
	{ from = 5, ids = { fee = 3, inflation = 3, bubble = 1.5 } },
	{ from = 10, ids = { sleepy = 3, risk = 3, fee = 1.5 } },
	{ from = 15, ids = { auditor = 3, gator = 3, inflation = 1.5 } },
	{ from = 20, ids = { fx = 3, interest = 3, darkcoin = 2 } },
	{ from = 25, ids = { bankrupt = 3, darkcoin = 3, risk = 2 } },
}
local function bias(floor: number)
	local b = Monsters.CHAPTER_BIAS[1]
	for _, c in Monsters.CHAPTER_BIAS do
		if floor >= c.from then
			b = c
		end
	end
	return b.ids
end

-- 階に応じて 1 体抽選。階が深いほど強くなる（floorMul）。章の敵は出やすい
function Monsters.roll(rng: Random, floor: number)
	local total = 0
	local pool = {}
	local b = bias(floor)
	for _, m in Monsters.LIST do
		if m.weight > 0 and floor >= m.floors[1] and floor <= m.floors[2] then
			local w = m.weight * (b[m.id] or 1)
			table.insert(pool, { m = m, w = w })
			total += w
		end
	end
	local r = rng:NextNumber() * total
	for _, e in pool do
		r -= e.w
		if r <= 0 then
			return e.m
		end
	end
	return pool[#pool] and pool[#pool].m or Monsters.BY_ID.akaji
end

-- 階による強さの倍率
function Monsters.floorMul(floor: number): number
	return 1 + math.max(0, floor - 1) * 0.06
end

return Monsters
