-- 道具の一覧。kind: weapon(万年筆) / armor(スーツ) / acc(ネクタイ) / food(弁当=やる気) / drink(コーヒー=HP) / card(名刺=巻物) / calc(電卓=杖) / yen
-- floors = {出始める階, 出なくなる階}, weight = 出やすさ, price = 売店の値段
local Items = {}

Items.LIST = {
	-- ===== 万年筆（武器）=====
	{ id = "pen_cheap", kind = "weapon", name = "100円ボールペン", nameEn = "Cheap Pen", atk = 2, floors = { 1, 8 }, weight = 10, price = 300, desc = "書ければいい。攻撃 +2" },
	{ id = "pen_steel", kind = "weapon", name = "鉄の万年筆", nameEn = "Steel Pen", atk = 4, floors = { 3, 18 }, weight = 7, price = 900, desc = "しっかりした一本。攻撃 +4" },
	{ id = "pen_gold", kind = "weapon", name = "金の万年筆", nameEn = "Gold Pen", atk = 7, floors = { 10, 99 }, weight = 3, price = 3000, desc = "契約書に映える。攻撃 +7" },
	{ id = "pen_legend", kind = "weapon", name = "伝説の万年筆", nameEn = "Legend Pen", atk = 11, floors = { 20, 99 }, weight = 1, price = 12000, desc = "歴代トップバンカーの一本。攻撃 +11" },
	-- ===== スーツ（防具）=====
	{ id = "suit_cheap", kind = "armor", name = "吊るしのスーツ", nameEn = "Off-the-rack Suit", def = 2, floors = { 1, 8 }, weight = 10, price = 300, desc = "安いけど一応スーツ。防御 +2" },
	{ id = "suit_navy", kind = "armor", name = "ネイビースーツ", nameEn = "Navy Suit", def = 4, floors = { 3, 18 }, weight = 7, price = 900, desc = "基本にして最強の色。防御 +4" },
	{ id = "suit_tailor", kind = "armor", name = "オーダースーツ", nameEn = "Tailored Suit", def = 7, floors = { 10, 99 }, weight = 3, price = 3000, desc = "体にぴったり。防御 +7" },
	{ id = "suit_legend", kind = "armor", name = "伝説のスーツ", nameEn = "Legend Suit", def = 11, floors = { 20, 99 }, weight = 1, price = 12000, desc = "着るだけで部屋の空気が変わる。防御 +11" },
	-- ===== ネクタイ（アクセサリ: 1 つだけ効果）=====
	{ id = "tie_red", kind = "acc", name = "赤いネクタイ", nameEn = "Red Tie", effect = "noTrap", floors = { 4, 99 }, weight = 3, price = 1500, desc = "気合いの赤。罠にかからない" },
	{ id = "tie_blue", kind = "acc", name = "青いネクタイ", nameEn = "Blue Tie", effect = "noHunger", floors = { 6, 99 }, weight = 3, price = 1500, desc = "冷静の青。やる気が減らない" },
	{ id = "tie_gold", kind = "acc", name = "金のネクタイ", nameEn = "Gold Tie", effect = "moreYen", floors = { 8, 99 }, weight = 2, price = 2500, desc = "拾う円が 2 倍" },
	{ id = "tie_green", kind = "acc", name = "緑のネクタイ", nameEn = "Green Tie", effect = "regen", floors = { 8, 99 }, weight = 2, price = 2500, desc = "HP の回復が速い" },
	-- ===== 弁当（やる気）=====
	{ id = "onigiri", kind = "food", name = "コンビニおにぎり", nameEn = "Rice Ball", hunger = 50, floors = { 1, 99 }, weight = 14, price = 120, desc = "やる気 +50" },
	{ id = "bento", kind = "food", name = "のり弁", nameEn = "Bento Box", hunger = 100, floors = { 1, 99 }, weight = 6, price = 300, desc = "やる気 全回復" },
	{ id = "bento_big", kind = "food", name = "特上弁当", nameEn = "Deluxe Bento", hunger = 100, hungerMax = 10, floors = { 8, 99 }, weight = 2, price = 900, desc = "やる気 全回復＋最大値 +10" },
	-- ===== コーヒー（HP）=====
	{ id = "coffee", kind = "drink", name = "缶コーヒー", nameEn = "Canned Coffee", hp = 25, floors = { 1, 99 }, weight = 14, price = 150, desc = "HP +25。敵に投げると敵が回復してしまう" },
	{ id = "coffee_big", kind = "drink", name = "特濃コーヒー", nameEn = "Strong Coffee", hp = 100, floors = { 5, 99 }, weight = 5, price = 500, desc = "HP +100" },
	{ id = "energy", kind = "drink", name = "エナジードリンク", nameEn = "Energy Drink", hp = 10, status = "bold", floors = { 3, 99 }, weight = 5, price = 400, desc = "HP +10、しばらく攻撃 2 倍" },
	{ id = "tea", kind = "drink", name = "お茶", nameEn = "Green Tea", hp = 5, cure = true, floors = { 1, 99 }, weight = 6, price = 150, desc = "HP +5、状態異常をなおす" },
	-- ===== 名刺（巻物: 読むと 1 回だけ。拾った時は「？」）=====
	{ id = "card_return", kind = "card", name = "帰還の名刺", nameEn = "Return Card", floors = { 1, 99 }, weight = 7, price = 800, desc = "持ち物と円を持ってオフィスへ帰る" },
	{ id = "card_identify", kind = "card", name = "鑑定の名刺", nameEn = "Appraisal Card", floors = { 1, 99 }, weight = 6, price = 400, desc = "持ち物の「？」がすべて分かる" },
	{ id = "card_map", kind = "card", name = "フロア図の名刺", nameEn = "Floor Map Card", floors = { 1, 99 }, weight = 6, price = 400, desc = "この階の間取りがすべて見える" },
	{ id = "card_merge", kind = "card", name = "合成の名刺", nameEn = "Merge Card", floors = { 5, 99 }, weight = 3, price = 2000, desc = "装備の強化値を同じ種類の装備にまとめる" },
	{ id = "card_sleep", kind = "card", name = "お昼寝の名刺", nameEn = "Nap Card", floors = { 2, 99 }, weight = 5, price = 500, desc = "部屋の敵がみんな居眠りする" },
	{ id = "card_escape", kind = "card", name = "非常口の名刺", nameEn = "Exit Card", floors = { 2, 99 }, weight = 5, price = 500, desc = "すぐ次の階へ" },
	{ id = "card_upgrade", kind = "card", name = "昇給の名刺", nameEn = "Raise Card", floors = { 4, 99 }, weight = 4, price = 1500, desc = "装備している万年筆かスーツが +1" },
	{ id = "card_audit", kind = "card", name = "監査の名刺", nameEn = "Audit Card", floors = { 3, 99 }, weight = 3, price = 100, desc = "（はずれ）この階の敵が全部こっちに来る" },
	{ id = "card_bonus", kind = "card", name = "ボーナスの名刺", nameEn = "Bonus Card", floors = { 3, 99 }, weight = 3, price = 1200, desc = "円がふってくる" },
	-- ===== 電卓（杖: 振ると直線に飛ぶ。回数あり）=====
	{ id = "calc_zap", kind = "calc", name = "電撃の電卓", nameEn = "Zap Calc", charges = 5, floors = { 2, 99 }, weight = 6, price = 1200, desc = "直線上の敵に 20 ダメージ" },
	{ id = "calc_sleep", kind = "calc", name = "居眠りの電卓", nameEn = "Sleep Calc", charges = 4, floors = { 2, 99 }, weight = 5, price = 1000, desc = "当たった敵が居眠り" },
	{ id = "calc_swap", kind = "calc", name = "席替えの電卓", nameEn = "Swap Calc", charges = 4, floors = { 3, 99 }, weight = 4, price = 1000, desc = "当たった敵と場所を入れ替わる" },
	{ id = "calc_shrink", kind = "calc", name = "減給の電卓", nameEn = "Shrink Calc", charges = 3, floors = { 5, 99 }, weight = 3, price = 1600, desc = "当たった敵のレベルを下げる" },
	{ id = "calc_blow", kind = "calc", name = "異動の電卓", nameEn = "Transfer Calc", charges = 4, floors = { 3, 99 }, weight = 4, price = 900, desc = "当たった敵をどこかへ飛ばす" },
	-- ===== 円（拾うと増える。持ち物には入らない）=====
	{ id = "yen", kind = "yen", name = "円", nameEn = "Yen", floors = { 1, 99 }, weight = 16, price = 0, desc = "" },
}

Items.BY_ID = {}
for _, it in Items.LIST do
	Items.BY_ID[it.id] = it
end

-- 「？」で表示する名前の候補（名刺・電卓は周ごとにランダムに割り当てる）
Items.UNKNOWN_CARD_NAMES = { "白い名刺", "黒い名刺", "金ぶちの名刺", "折れた名刺", "透かしの名刺", "二つ折りの名刺", "縦書きの名刺", "赤い名刺", "青い名刺", "破れた名刺" }
Items.UNKNOWN_CALC_NAMES = { "黒い電卓", "白い電卓", "ピンクの電卓", "太陽電池の電卓", "大きい電卓", "小さい電卓", "古い電卓" }

-- 指定の階で出る道具を 1 つ抽選
function Items.roll(rng: Random, floor: number, kindFilter: string?)
	local total = 0
	local pool = {}
	for _, it in Items.LIST do
		if floor >= it.floors[1] and floor <= it.floors[2] and (not kindFilter or it.kind == kindFilter) then
			table.insert(pool, it)
			total += it.weight
		end
	end
	local r = rng:NextNumber() * total
	for _, it in pool do
		r -= it.weight
		if r <= 0 then
			return it
		end
	end
	return pool[#pool]
end

-- 持ち物 1 つの実体（インスタンス）を作る
function Items.make(rng: Random, def, floor: number)
	local inst = { id = def.id, kind = def.kind }
	if def.kind == "weapon" or def.kind == "armor" then
		inst.plus = 0
		local r = rng:NextNumber()
		if r < 0.25 then
			inst.plus = rng:NextInteger(1, 3)
		elseif r < 0.32 then
			inst.plus = -1
		end
	elseif def.kind == "calc" then
		inst.charges = math.max(1, def.charges - rng:NextInteger(0, 2))
	elseif def.kind == "yen" then
		inst.amount = rng:NextInteger(20, 40) * floor + rng:NextInteger(0, 80)
	end
	return inst
end

-- 表示名（識別していなければ「？」の名前）
function Items.displayName(inst, known: { [string]: boolean }?, aliases: { [string]: string }?): string
	local def = Items.BY_ID[inst.id]
	if not def then
		return "？"
	end
	if def.kind == "yen" then
		return tostring(inst.amount) .. " 円"
	end
	local name = def.name
	if (def.kind == "card" or def.kind == "calc") and known and not known[def.id] then
		name = "？" .. ((aliases and aliases[def.id]) or (def.kind == "card" and "名刺" or "電卓"))
	end
	if def.kind == "weapon" or def.kind == "armor" then
		if inst.plus and inst.plus ~= 0 then
			name ..= (inst.plus > 0 and "+" or "") .. inst.plus
		end
	elseif def.kind == "calc" then
		name ..= " [" .. tostring(inst.charges) .. "]"
	end
	return name
end

return Items
