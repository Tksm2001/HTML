-- 1 周（ラン）の中身。マス目・ターン・戦闘・道具・罠・敵の動き。サーバーだけが真実を持つ。
-- 画面側には snapshot を送るだけ。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Items = require(ReplicatedStorage.Shared.Items)
local Monsters = require(ReplicatedStorage.Shared.Monsters)
local MapGen = require(script.Parent.MapGen)

local Run = {}
Run.__index = Run

local DIRS = { { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } }

local function key(x, y)
	return x .. "," .. y
end

-- ===== 作成 =====
-- opts: seed, floorCap, startFloor, bag(持ち込み), yen(持ち込み), locker, rank, acc effects
function Run.new(player: Player, opts)
	local self = setmetatable({}, Run)
	self.player = player
	self.seed = opts.seed or Random.new():NextInteger(1, 1e9)
	self.rng = Random.new(self.seed * 7 + 13)
	self.floorCap = opts.floorCap or 5
	self.daily = opts.daily == true
	self.floor = 0
	self.turn = 0
	self.lv = 1
	self.exp = 0
	self.hpMax = Config.BASE_HP
	self.hp = self.hpMax
	self.hungerMax = Config.HUNGER_MAX
	self.hunger = self.hungerMax
	self.yen = opts.yen or 0
	self.inv = opts.bag or {}
	self.equip = { weapon = nil, armor = nil, acc = nil }
	for _, it in self.inv do
		if it.equipped then
			self.equip[Items.BY_ID[it.id].kind] = it
		end
	end
	self.status = { sleep = 0, confuse = 0, stress = 0, bold = 0 }
	self.known = {}
	self.aliases = {}
	self.log = {}
	self.events = {}
	self.kills = 0
	self.facing = 3 -- 下向き
	self.ended = nil -- "dead" / "returned" / "cleared" / "cap"
	self.monsters = {}
	self.uidNext = 1
	self.intern = nil
	-- 「？」の名前をこの周だけランダムに割り当てる
	local cards, calcs = {}, {}
	for _, it in Items.LIST do
		if it.kind == "card" then
			table.insert(cards, it)
		elseif it.kind == "calc" then
			table.insert(calcs, it)
		end
	end
	local cn = table.clone(Items.UNKNOWN_CARD_NAMES)
	local ln = table.clone(Items.UNKNOWN_CALC_NAMES)
	for _, it in cards do
		self.aliases[it.id] = table.remove(cn, self.rng:NextInteger(1, #cn)) or "名刺"
	end
	for _, it in calcs do
		self.aliases[it.id] = table.remove(ln, self.rng:NextInteger(1, #ln)) or "電卓"
	end
	-- 売店で買った物と持ち込みは識別済み
	for _, it in self.inv do
		self.known[it.id] = true
	end
	self.known.card_return = true -- 帰還の名刺だけは誰でも知っている
	self:enterFloor(opts.startFloor or 1)
	return self
end

-- ===== ログ・イベント =====
function Run:say(text: string)
	table.insert(self.log, text)
	if #self.log > 60 then
		table.remove(self.log, 1)
	end
	table.insert(self.events, { t = "log", text = text })
end

function Run:ev(e)
	table.insert(self.events, e)
end

-- ===== 階に入る =====
function Run:enterFloor(n: number)
	self.floor = n
	self.f = MapGen.generate(self.seed, n)
	self.px, self.py = self.f.start.X, self.f.start.Y
	self.explored = {}
	self.monsters = {}
	self.items = self.f.items
	self.traps = self.f.traps
	self.spawnTimer = 0
	for _, mdef in self.f.monsters do
		self:spawnMonster(mdef.def, mdef.x, mdef.y, mdef.asleep, mdef.levelBonus)
	end
	-- 臨時売店の品ぞろえ
	self.shop = nil
	if self.f.shop then
		self.shop = { x = self.f.shop.X, y = self.f.shop.Y, stock = {} }
		for _ = 1, 6 do
			local def = Items.roll(self.rng, n + 2)
			if def.kind ~= "yen" then
				table.insert(self.shop.stock, { def = def, inst = Items.make(self.rng, def, n), price = def.price })
			end
		end
	end
	if self.intern then
		self.intern.x, self.intern.y = self:freeNear(self.px, self.py)
	end
	self:updateSight()
	self:ev({ t = "floor", floor = n })
	if self.f.special == "exam" then
		self:say("昇進試験: 気むずかしいクライアントにプレゼンで勝て！")
	elseif self.f.special == "board" then
		self:say("最上階 — 取締役会。3 人の取締役と、その奥に…")
	elseif self.f.special == "audit" then
		self:say("なにか いやな気配がする…")
	else
		self:say(n .. "F に着いた。")
	end
end

function Run:spawnMonster(def, x, y, asleep, levelBonus)
	local mul = Monsters.floorMul(self.floor) + (levelBonus or 0) * 0.3
	local m = {
		uid = self.uidNext,
		id = def.id,
		def = def,
		x = x,
		y = y,
		hpMax = math.floor(def.hp * mul),
		atk = math.floor(def.atk * mul),
		dfn = def.def,
		exp = math.floor(def.exp * mul),
		lv = 1,
		asleep = asleep == true or (def.boss == nil and self.rng:NextNumber() < 0.3),
		alert = false,
		stolen = 0,
		grow = 0,
		shiftTimer = 0,
		fleeing = false,
		sleepTurns = 0,
	}
	m.hp = m.hpMax
	self.uidNext += 1
	table.insert(self.monsters, m)
	return m
end

-- ===== マス目のヘルパー =====
function Run:walkable(x, y): boolean
	if x < 1 or y < 1 or x > Config.MAP_W or y > Config.MAP_H then
		return false
	end
	return self.f.grid[y][x] ~= 0
end

function Run:monsterAt(x, y)
	for _, m in self.monsters do
		if m.x == x and m.y == y then
			return m
		end
	end
	return nil
end

function Run:occupied(x, y): boolean
	if self.px == x and self.py == y then
		return true
	end
	if self.intern and self.intern.x == x and self.intern.y == y then
		return true
	end
	return self:monsterAt(x, y) ~= nil
end

function Run:itemAt(x, y)
	for i, it in self.items do
		if it.x == x and it.y == y then
			return it, i
		end
	end
	return nil
end

function Run:freeNear(x, y): (number, number)
	for r = 0, 6 do
		for dy = -r, r do
			for dx = -r, r do
				local nx, ny = x + dx, y + dy
				if self:walkable(nx, ny) and not self:occupied(nx, ny) then
					return nx, ny
				end
			end
		end
	end
	return x, y
end

function Run:randomFreeCell(): (number, number)
	for _ = 1, 300 do
		local x = self.rng:NextInteger(1, Config.MAP_W)
		local y = self.rng:NextInteger(1, Config.MAP_H)
		if self.f.grid[y][x] == 1 and not self:occupied(x, y) then
			return x, y
		end
	end
	return self.px, self.py
end

-- 見える範囲を更新（部屋にいれば部屋全体＋入口、通路なら周り 1 マス）
function Run:updateSight()
	self.visible = {}
	local room = MapGen.roomAt(self.f, self.px, self.py)
	local function see(x, y)
		if x >= 1 and y >= 1 and x <= Config.MAP_W and y <= Config.MAP_H then
			self.visible[key(x, y)] = true
			self.explored[key(x, y)] = true
		end
	end
	if room then
		for y = room.y - 1, room.y + room.h do
			for x = room.x - 1, room.x + room.w do
				see(x, y)
			end
		end
	else
		for dy = -1, 1 do
			for dx = -1, 1 do
				see(self.px + dx, self.py + dy)
			end
		end
	end
	if self.mapRevealed then
		for y = 1, Config.MAP_H do
			for x = 1, Config.MAP_W do
				if self.f.grid[y][x] ~= 0 then
					self.explored[key(x, y)] = true
				end
			end
		end
	end
end

function Run:canSeeMonster(m): boolean
	if not self.visible[key(m.x, m.y)] then
		return false
	end
	if m.def.special == "invisible" and not m.revealed then
		return math.abs(m.x - self.px) <= 1 and math.abs(m.y - self.py) <= 1
	end
	return true
end

-- ===== 強さ =====
function Run:atk(): number
	local a = Config.BASE_ATK + (self.lv - 1) * Config.ATK_PER_LEVEL
	local w = self.equip.weapon
	if w then
		a += Items.BY_ID[w.id].atk + (w.plus or 0)
	end
	if self.status.bold > 0 then
		a *= 2
	end
	return a
end

function Run:dfn(): number
	local d = 0
	local ar = self.equip.armor
	if ar then
		d += Items.BY_ID[ar.id].def + (ar.plus or 0)
	end
	return d
end

function Run:hasAcc(effect: string): boolean
	local a = self.equip.acc
	return a ~= nil and Items.BY_ID[a.id].effect == effect
end

function Run:gainExp(n: number)
	self.exp += n
	while self.lv < Config.MAX_LEVEL and self.exp >= Config.EXP_TABLE[self.lv + 1] do
		self.lv += 1
		self.hpMax += Config.HP_PER_LEVEL
		self.hp = math.min(self.hpMax, self.hp + Config.HP_PER_LEVEL)
		self:say("レベル " .. self.lv .. " になった！ HP が上がった")
		self:ev({ t = "levelup", lv = self.lv })
	end
end

function Run:damagePlayer(n: number, source: string)
	n = math.max(0, n)
	self.hp -= n
	self:ev({ t = "hit", target = "player", dmg = n })
	if self.hp <= 0 then
		self.hp = 0
		self:say(source .. " にやられて 倒れた…")
		self.ended = "dead"
		self:ev({ t = "end", result = "dead" })
	end
end

-- ===== プレイヤーの行動 =====
-- 1 歩動く／その先に敵がいれば攻撃。戻り値: ターンを使ったか
function Run:step(dir: number): boolean
	if self.ended then
		return false
	end
	if self.status.sleep > 0 then
		self:say("居眠り中… zzz")
		self:endTurn()
		return true
	end
	if self.status.confuse > 0 and self.rng:NextNumber() < 0.5 then
		dir = self.rng:NextInteger(1, 4)
	end
	self.facing = dir
	local d = DIRS[dir]
	local nx, ny = self.px + d[1], self.py + d[2]
	local m = self:monsterAt(nx, ny)
	if m then
		self:attackMonster(m)
		self:endTurn()
		return true
	end
	if not self:walkable(nx, ny) then
		return false
	end
	if self.intern and self.intern.x == nx and self.intern.y == ny then
		-- 部下と入れ替わる
		self.intern.x, self.intern.y = self.px, self.py
	end
	self.px, self.py = nx, ny
	self:ev({ t = "move", who = "player", x = nx, y = ny })
	self:updateSight()
	-- 拾う
	local it, idx = self:itemAt(nx, ny)
	if it then
		self:pickup(it, idx)
	end
	-- 罠
	for _, tr in self.traps do
		if tr.x == nx and tr.y == ny then
			self:triggerTrap(tr)
			break
		end
	end
	if self.ended then
		return true
	end
	if self.f.stairs.X == nx and self.f.stairs.Y == ny then
		self:say("上への階段だ。「のぼる」で次の階へ")
	end
	if self.shop and math.abs(self.shop.x - nx) <= 1 and math.abs(self.shop.y - ny) <= 1 then
		self:say("先輩ミサキ「いらっしゃい。塔の中で店番してるの」")
	end
	self:endTurn()
	return true
end

function Run:pickup(it, idx)
	local def = Items.BY_ID[it.inst.id]
	if def.kind == "yen" then
		local n = it.inst.amount * (self:hasAcc("moreYen") and 2 or 1)
		self.yen += n
		table.remove(self.items, idx)
		self:say(n .. " 円を拾った")
		self:ev({ t = "pickup", x = it.x, y = it.y, yen = n })
		return
	end
	if #self.inv >= Config.INVENTORY_MAX then
		self:say("持ち物がいっぱいだ（" .. Items.displayName(it.inst, self.known, self.aliases) .. " の上に乗った）")
		return
	end
	table.remove(self.items, idx)
	table.insert(self.inv, it.inst)
	self:say(Items.displayName(it.inst, self.known, self.aliases) .. " を拾った")
	self:ev({ t = "pickup", x = it.x, y = it.y })
end

function Run:triggerTrap(tr)
	tr.found = true
	if self:hasAcc("noTrap") then
		self:say(MapGen.TRAP_NAMES[tr.kind] .. "！ …赤いネクタイのおかげで平気だった")
		return
	end
	self:ev({ t = "trap", x = tr.x, y = tr.y, kind = tr.kind })
	if tr.kind == "overtime" then
		self.hunger = math.max(0, self.hunger - 30)
		self:say("残業トラップ！ やる気が 30 減った")
	elseif tr.kind == "meeting" then
		self.px, self.py = self:randomFreeCell()
		self:updateSight()
		self:say("会議ワープ！ 別の部屋に飛ばされた")
		self:ev({ t = "move", who = "player", x = self.px, y = self.py, warp = true })
	elseif tr.kind == "trip" then
		if #self.inv > 0 then
			local i = self.rng:NextInteger(1, #self.inv)
			local inst = self.inv[i]
			if not inst.equipped then
				table.remove(self.inv, i)
				local x, y = self:freeNear(self.px, self.py)
				table.insert(self.items, { x = x, y = y, inst = inst })
				self:say("転倒！ " .. Items.displayName(inst, self.known, self.aliases) .. " を落とした")
			else
				self:say("転倒！ でも何も落とさなかった")
			end
		else
			self:say("転倒！ 痛い…")
			self:damagePlayer(2, "転倒")
		end
	elseif tr.kind == "glitch" then
		local n = 0
		for _, inst in self.inv do
			if Items.BY_ID[inst.id].kind == "calc" and inst.charges > 0 then
				inst.charges = 0
				n += 1
			end
		end
		self:say("システム障害！ 電卓 " .. n .. " 個の電池が切れた")
	elseif tr.kind == "stairs" then
		self:say("非常階段！ 強制的に上の階へ")
		self:climb(true)
	elseif tr.kind == "audit" then
		for _, m in self.monsters do
			m.alert = true
			m.asleep = false
		end
		self:say("監査の呼び出し！ この階の敵がみんな こっちに来る")
	end
end

function Run:attackMonster(m)
	self.facing = self:dirTo(m.x, m.y) or self.facing
	local dmg = math.max(1, self:atk() - m.dfn + self.rng:NextInteger(-1, 1))
	if self.rng:NextNumber() < 0.08 then
		dmg *= 2
		self:say("会心のプレゼン！")
	end
	if m.def.special == "invisible" then
		m.revealed = true
	end
	m.asleep = false
	m.alert = true
	m.hp -= dmg
	self:ev({ t = "hit", target = m.uid, dmg = dmg, from = "player" })
	if m.hp <= 0 then
		self:killMonster(m, "player")
	else
		self:say(m.def.name .. " に " .. dmg .. " ダメージ")
	end
end

function Run:killMonster(m, by: string)
	for i, o in self.monsters do
		if o == m then
			table.remove(self.monsters, i)
			break
		end
	end
	self.kills += 1
	self:say(m.def.name .. " を倒した！")
	self:ev({ t = "die", uid = m.uid, x = m.x, y = m.y })
	if by == "player" or by == "intern" then
		self:gainExp(m.exp)
	end
	if m.stolen > 0 then
		table.insert(self.items, { x = m.x, y = m.y, inst = { id = "yen", kind = "yen", amount = m.stolen } })
		self:say("盗まれた " .. m.stolen .. " 円が落ちた")
	end
	if m.def.special == "rich" then
		table.insert(self.items, { x = m.x, y = m.y, inst = { id = "yen", kind = "yen", amount = 500 * self.floor } })
	elseif self.rng:NextNumber() < 0.12 then
		local def = Items.roll(self.rng, self.floor)
		table.insert(self.items, { x = m.x, y = m.y, inst = Items.make(self.rng, def, self.floor) })
	end
	-- ボス
	if m.def.boss == "exam" then
		self:say("プレゼン成功！ クライアント「…いいだろう。上に行け」")
		self:ev({ t = "exam_clear", floor = self.floor })
	elseif m.def.boss == "final" then
		self:say("ダークマネーが消えていく… 塔の頂上に光が差した")
		self.ended = "cleared"
		self:ev({ t = "end", result = "cleared" })
	end
end

function Run:dirTo(x, y): number?
	local dx, dy = x - self.px, y - self.py
	for i, d in DIRS do
		if d[1] == dx and d[2] == dy then
			return i
		end
	end
	return nil
end

-- 階段をのぼる
function Run:climb(force: boolean?): boolean
	if self.ended then
		return false
	end
	if not force and not (self.f.stairs.X == self.px and self.f.stairs.Y == self.py) then
		self:say("ここに階段はない")
		return false
	end
	-- 取締役会の階はボスを倒すまで上がれない
	if self.f.special == "board" and not force then
		for _, m in self.monsters do
			if m.def.boss then
				self:say("取締役会が終わるまで 上には行けない")
				return false
			end
		end
	end
	if self.f.special == "exam" and not force then
		for _, m in self.monsters do
			if m.def.boss == "exam" then
				self:say("クライアントが道をふさいでいる。プレゼン（戦闘）で勝て")
				return false
			end
		end
	end
	local nextFloor = self.floor + 1
	if nextFloor > self.floorCap then
		self:say("今のランクで行けるのは " .. self.floorCap .. "F まで。ここで帰還だ（持ち物は持って帰れる）")
		self.ended = "cap"
		self:ev({ t = "end", result = "cap" })
		return true
	end
	if self.daily and nextFloor > Config.DAILY_FLOORS then
		self:say("本日の案件、完了！")
		self.ended = "cleared"
		self:ev({ t = "end", result = "cleared" })
		return true
	end
	self.mapRevealed = false
	self:enterFloor(nextFloor)
	return true
end

function Run:wait()
	if self.ended then
		return
	end
	self:endTurn()
end

-- ===== 道具 =====
function Run:findInv(idx: number)
	return self.inv[idx]
end

function Run:removeInv(inst)
	for i, o in self.inv do
		if o == inst then
			table.remove(self.inv, i)
			return
		end
	end
end

function Run:identify(inst)
	if not self.known[inst.id] then
		self.known[inst.id] = true
		self:say("それは " .. Items.BY_ID[inst.id].name .. " だった！")
	end
end

function Run:use(idx: number): boolean
	if self.ended then
		return false
	end
	local inst = self:findInv(idx)
	if not inst then
		return false
	end
	local def = Items.BY_ID[inst.id]
	if def.kind == "weapon" or def.kind == "armor" or def.kind == "acc" then
		if inst.equipped then
			inst.equipped = nil
			self.equip[def.kind] = nil
			self:say(def.name .. " をはずした")
		else
			local cur = self.equip[def.kind]
			if cur then
				cur.equipped = nil
			end
			inst.equipped = true
			self.equip[def.kind] = inst
			self:say(Items.displayName(inst, self.known, self.aliases) .. " を装備した")
		end
		self:endTurn()
		return true
	elseif def.kind == "food" then
		self.hungerMax += def.hungerMax or 0
		self.hunger = math.min(self.hungerMax, self.hunger + def.hunger)
		self:say(def.name .. " を食べた。やる気 " .. math.floor(self.hunger))
		self:removeInv(inst)
	elseif def.kind == "drink" then
		self.hp = math.min(self.hpMax, self.hp + def.hp)
		if def.status == "bold" then
			self.status.bold = 15
			self:say(def.name .. " を飲んだ。強気になった！（攻撃 2 倍）")
		elseif def.cure then
			self.status.sleep, self.status.confuse, self.status.stress = 0, 0, 0
			self:say(def.name .. " を飲んだ。落ち着いた")
		else
			self:say(def.name .. " を飲んだ。HP " .. self.hp)
		end
		self:removeInv(inst)
	elseif def.kind == "card" then
		self:removeInv(inst)
		self:identify(inst)
		self:readCard(def)
	elseif def.kind == "calc" then
		if inst.charges <= 0 then
			self:say("電池切れだ")
			return false
		end
		inst.charges -= 1
		self:identify(inst)
		self:swingCalc(def)
	end
	if self.ended then
		return true
	end
	self:endTurn()
	return true
end

function Run:readCard(def)
	self:ev({ t = "card", id = def.id })
	if def.id == "card_return" then
		self:say("帰還の名刺を読んだ。オフィスへ帰る！")
		self.ended = "returned"
		self:ev({ t = "end", result = "returned" })
	elseif def.id == "card_identify" then
		for _, inst in self.inv do
			self.known[inst.id] = true
		end
		self:say("持ち物の正体が全部わかった")
	elseif def.id == "card_map" then
		self.mapRevealed = true
		self:updateSight()
		self:say("この階の間取りが頭に入った")
	elseif def.id == "card_merge" then
		local merged = 0
		for _, kind in { "weapon", "armor" } do
			local base = self.equip[kind]
			if base then
				for i = #self.inv, 1, -1 do
					local o = self.inv[i]
					if o ~= base and o.id == base.id then
						base.plus = (base.plus or 0) + (o.plus or 0) + 1
						table.remove(self.inv, i)
						merged += 1
					end
				end
			end
		end
		self:say(merged > 0 and ("装備を合成した！（" .. merged .. " 個）") or "合成できる装備がなかった（装備中と同じ種類が要る）")
	elseif def.id == "card_sleep" then
		local room = MapGen.roomAt(self.f, self.px, self.py)
		local n = 0
		for _, m in self.monsters do
			if room and MapGen.roomAt(self.f, m.x, m.y) == room then
				m.asleep = true
				m.sleepTurns = 8
				n += 1
			end
		end
		self:say("部屋の敵 " .. n .. " 体が居眠りした")
	elseif def.id == "card_escape" then
		self:say("非常口から上へ！")
		self:climb(true)
	elseif def.id == "card_upgrade" then
		local target = self.rng:NextNumber() < 0.5 and self.equip.weapon or self.equip.armor
		target = target or self.equip.weapon or self.equip.armor
		if target then
			target.plus = (target.plus or 0) + 1
			self:say(Items.displayName(target, self.known, self.aliases) .. " になった！")
		else
			self:say("何も装備していないので効かなかった")
		end
	elseif def.id == "card_audit" then
		for _, m in self.monsters do
			m.alert = true
			m.asleep = false
		end
		self:say("しまった！ 監査の名刺だ。この階の敵がみんな来る")
	elseif def.id == "card_bonus" then
		local n = 150 * self.floor
		self.yen += n
		self:say("ボーナス！ " .. n .. " 円 ゲット")
	end
end

-- 電卓: 向いている方向の直線上、最初の敵に効く
function Run:swingCalc(def)
	local d = DIRS[self.facing]
	local x, y = self.px, self.py
	local target = nil
	for _ = 1, 12 do
		x += d[1]
		y += d[2]
		if not self:walkable(x, y) then
			break
		end
		target = self:monsterAt(x, y)
		if target then
			break
		end
	end
	self:ev({ t = "beam", from = { self.px, self.py }, to = { x, y }, id = def.id })
	if not target then
		self:say(def.name .. " を振った。何にも当たらなかった")
		return
	end
	target.asleep = false
	if def.id == "calc_zap" then
		target.hp -= 20
		self:ev({ t = "hit", target = target.uid, dmg = 20 })
		if target.hp <= 0 then
			self:killMonster(target, "player")
		else
			self:say(target.def.name .. " に電撃！ 20 ダメージ")
		end
	elseif def.id == "calc_sleep" then
		target.asleep = true
		target.sleepTurns = 6
		self:say(target.def.name .. " が居眠りした")
	elseif def.id == "calc_swap" then
		local tx, ty = target.x, target.y
		target.x, target.y = self.px, self.py
		self.px, self.py = tx, ty
		self:updateSight()
		self:ev({ t = "move", who = "player", x = self.px, y = self.py, warp = true })
		self:say(target.def.name .. " と席を替わった")
	elseif def.id == "calc_shrink" then
		target.atk = math.max(1, math.floor(target.atk * 0.5))
		target.hpMax = math.max(1, math.floor(target.hpMax * 0.5))
		target.hp = math.min(target.hp, target.hpMax)
		target.grow = 0
		self:say(target.def.name .. " が減給された（弱くなった）")
	elseif def.id == "calc_blow" then
		target.x, target.y = self:randomFreeCell()
		target.alert = false
		self:say(target.def.name .. " を異動させた（どこかへ飛んだ）")
	end
end

-- 投げる: 向いている方向へ最大 10 マス
function Run:throw(idx: number): boolean
	if self.ended then
		return false
	end
	local inst = self:findInv(idx)
	if not inst then
		return false
	end
	local def = Items.BY_ID[inst.id]
	if inst.equipped then
		inst.equipped = nil
		self.equip[def.kind] = nil
	end
	self:removeInv(inst)
	local d = DIRS[self.facing]
	local x, y = self.px, self.py
	local lx, ly = x, y
	local target = nil
	for _ = 1, 10 do
		local nx, ny = x + d[1], y + d[2]
		if not self:walkable(nx, ny) then
			break
		end
		x, y = nx, ny
		target = self:monsterAt(x, y)
		if target then
			break
		end
		lx, ly = x, y
	end
	self:ev({ t = "throw", from = { self.px, self.py }, to = { x, y }, id = inst.id })
	if target then
		target.asleep = false
		target.alert = true
		if def.kind == "drink" then
			target.hp = math.min(target.hpMax, target.hp + def.hp)
			self:say("しまった！ " .. target.def.name .. " が " .. def.name .. " で回復した")
		elseif def.kind == "food" then
			target.asleep = true
			target.sleepTurns = 3
			self:say(target.def.name .. " は " .. def.name .. " を食べて満足して眠った")
		else
			local dmg = def.kind == "weapon" and (def.atk + (inst.plus or 0) + 3) or 6
			target.hp -= dmg
			self:ev({ t = "hit", target = target.uid, dmg = dmg })
			if target.hp <= 0 then
				self:killMonster(target, "player")
			else
				self:say(Items.displayName(inst, self.known, self.aliases) .. " を投げた。" .. dmg .. " ダメージ")
			end
			if def.kind == "card" or def.kind == "calc" then
				-- 投げた名刺・電卓は落ちる
				local fx, fy = self:freeNear(lx, ly)
				table.insert(self.items, { x = fx, y = fy, inst = inst })
			end
		end
	else
		local fx, fy = self:freeNear(lx, ly)
		table.insert(self.items, { x = fx, y = fy, inst = inst })
		self:say(Items.displayName(inst, self.known, self.aliases) .. " を投げた")
	end
	self:endTurn()
	return true
end

function Run:drop(idx: number): boolean
	if self.ended then
		return false
	end
	local inst = self:findInv(idx)
	if not inst then
		return false
	end
	if self:itemAt(self.px, self.py) then
		self:say("ここには もう何か落ちている")
		return false
	end
	local def = Items.BY_ID[inst.id]
	if inst.equipped then
		inst.equipped = nil
		self.equip[def.kind] = nil
	end
	self:removeInv(inst)
	table.insert(self.items, { x = self.px, y = self.py, inst = inst })
	self:say(Items.displayName(inst, self.known, self.aliases) .. " を置いた")
	self:endTurn()
	return true
end

-- ===== 臨時売店 =====
function Run:nearShop(): boolean
	return self.shop ~= nil and math.abs(self.shop.x - self.px) <= 1 and math.abs(self.shop.y - self.py) <= 1
end

function Run:buy(i: number): boolean
	if not self:nearShop() then
		return false
	end
	local s = self.shop.stock[i]
	if not s or self.yen < s.price or #self.inv >= Config.INVENTORY_MAX then
		self:say("買えない（円か持ち物の空きが足りない）")
		return false
	end
	self.yen -= s.price
	table.remove(self.shop.stock, i)
	table.insert(self.inv, s.inst)
	self.known[s.inst.id] = true
	self:say(s.def.name .. " を買った")
	return true
end

function Run:sell(idx: number): boolean
	if not self:nearShop() then
		return false
	end
	local inst = self:findInv(idx)
	if not inst then
		return false
	end
	local def = Items.BY_ID[inst.id]
	local price = math.floor(def.price * 0.4) + (inst.plus or 0) * 100
	if inst.equipped then
		inst.equipped = nil
		self.equip[def.kind] = nil
	end
	self:removeInv(inst)
	self.yen += price
	self.known[inst.id] = true
	self:say(def.name .. " を " .. price .. " 円で売った")
	return true
end

-- ===== ターンの終わり（敵が動く）=====
function Run:endTurn()
	self.turn += 1
	-- やる気
	if not self:hasAcc("noHunger") then
		self.hunger = math.max(0, self.hunger - Config.HUNGER_PER_TURN)
	end
	if self.hunger <= 0 then
		if self.turn % 3 == 0 then
			self.hp -= 1
			if self.turn % 15 == 0 then
				self:say("やる気がゼロだ… おなかがすいて HP が減っていく")
			end
			if self.hp <= 0 then
				self.hp = 0
				self:say("やる気を失って 倒れた…")
				self.ended = "dead"
				self:ev({ t = "end", result = "dead" })
				return
			end
		end
	elseif self.status.stress > 0 then
		self.hp -= 1
		if self.hp <= 0 then
			self.hp = 0
			self:say("ストレスで 倒れた…")
			self.ended = "dead"
			self:ev({ t = "end", result = "dead" })
			return
		end
	else
		local every = self:hasAcc("regen") and Config.HP_REGEN_TURNS // 2 or Config.HP_REGEN_TURNS
		if self.turn % every == 0 then
			self.hp = math.min(self.hpMax, self.hp + 1)
		end
	end
	for k, v in self.status do
		if v > 0 then
			self.status[k] = v - 1
		end
	end
	-- 部下
	if self.intern then
		self:internAct()
	end
	-- 敵
	for _, m in table.clone(self.monsters) do
		if self.ended then
			return
		end
		if m.hp > 0 then
			self:monsterAct(m)
		end
	end
	-- 湧き
	self.spawnTimer += 1
	if self.spawnTimer >= Config.SPAWN_EVERY and #self.monsters < 12 and not self.f.special then
		self.spawnTimer = 0
		local x, y = self:randomFreeCell()
		if not self.visible[key(x, y)] then
			self:spawnMonster(Monsters.roll(self.rng, self.floor), x, y, false)
		end
	end
	self:updateSight()
end

local function dist(ax, ay, bx, by)
	return math.abs(ax - bx) + math.abs(ay - by)
end

-- 敵の 1 ターン
function Run:monsterAct(m)
	local sp = m.def.special
	-- 居眠り
	if m.asleep then
		if m.sleepTurns > 0 then
			m.sleepTurns -= 1
			return
		end
		local near = dist(m.x, m.y, self.px, self.py) <= 2
		if (near and self.rng:NextNumber() < 0.5) or (self:canSeeMonster(m) and self.rng:NextNumber() < 0.08) then
			m.asleep = false
		else
			return
		end
	end
	-- 個性: 成長・分裂・色変え
	if sp == "grow" and m.grow < 6 and self.turn % 5 == 0 then
		m.grow += 1
		m.atk += 1
	elseif sp == "split" and self.turn % 14 == 0 and #self.monsters < 14 then
		local x, y = self:freeNear(m.x, m.y)
		if not (x == m.x and y == m.y) and not self:occupied(x, y) then
			local c = self:spawnMonster(m.def, x, y, false)
			c.alert = m.alert
			if self:canSeeMonster(m) then
				self:say("インフレねずみが増えた！")
			end
		end
	elseif sp == "shift" then
		m.shiftTimer += 1
		if m.shiftTimer >= 6 then
			m.shiftTimer = 0
			m.atk, m.dfn = m.dfn + 3, math.max(0, m.atk - 3)
			m.shade = (m.shade or 0) + 1
		end
	end
	-- 逃げる（コウモリが円を持っている時）
	if m.fleeing then
		local best, bd = nil, dist(m.x, m.y, self.px, self.py)
		for _, d in DIRS do
			local nx, ny = m.x + d[1], m.y + d[2]
			if self:walkable(nx, ny) and not self:occupied(nx, ny) and dist(nx, ny, self.px, self.py) > bd then
				best, bd = { nx, ny }, dist(nx, ny, self.px, self.py)
			end
		end
		if best then
			m.x, m.y = best[1], best[2]
			self:ev({ t = "move", who = m.uid, x = m.x, y = m.y })
		end
		return
	end
	-- 隣なら攻撃（部下が隣ならそちらを狙うことも）
	local adjacent = dist(m.x, m.y, self.px, self.py) == 1
	if adjacent then
		self:monsterAttack(m)
		return
	end
	if self.intern and dist(m.x, m.y, self.intern.x, self.intern.y) == 1 and self.rng:NextNumber() < 0.5 then
		local dmg = math.max(0, m.atk - 2 + self.rng:NextInteger(-1, 1))
		self.intern.hp -= dmg
		self:ev({ t = "hit", target = "intern", dmg = dmg })
		if self.intern.hp <= 0 then
			self:say("インターンが倒れて 先に帰った…")
			self.intern = nil
		end
		return
	end
	-- 見つけているか
	local room = MapGen.roomAt(self.f, self.px, self.py)
	local sees = m.alert or (room ~= nil and MapGen.roomAt(self.f, m.x, m.y) == room) or dist(m.x, m.y, self.px, self.py) <= 3
	if sees then
		m.alert = true
		-- 近づく（主軸→もう一方）
		local dx, dy = self.px - m.x, self.py - m.y
		local tries = {}
		if math.abs(dx) >= math.abs(dy) then
			table.insert(tries, { dx > 0 and 1 or -1, 0 })
			table.insert(tries, { 0, dy > 0 and 1 or (dy < 0 and -1 or 0) })
		else
			table.insert(tries, { 0, dy > 0 and 1 or -1 })
			table.insert(tries, { dx > 0 and 1 or (dx < 0 and -1 or 0), 0 })
		end
		for _, d in tries do
			local nx, ny = m.x + d[1], m.y + d[2]
			if (d[1] ~= 0 or d[2] ~= 0) and self:walkable(nx, ny) and not self:occupied(nx, ny) then
				m.x, m.y = nx, ny
				self:ev({ t = "move", who = m.uid, x = nx, y = ny })
				return
			end
		end
	else
		-- うろうろ
		if self.rng:NextNumber() < 0.6 then
			local d = DIRS[self.rng:NextInteger(1, 4)]
			local nx, ny = m.x + d[1], m.y + d[2]
			if self:walkable(nx, ny) and not self:occupied(nx, ny) then
				m.x, m.y = nx, ny
				self:ev({ t = "move", who = m.uid, x = nx, y = ny })
			end
		end
	end
end

function Run:monsterAttack(m)
	local sp = m.def.special
	local dmg = math.max(0, m.atk - self:dfn() + self.rng:NextInteger(-1, 1))
	if self.rng:NextNumber() < 0.1 then
		self:say(m.def.name .. " の攻撃を かわした")
		self:ev({ t = "miss", from = m.uid })
		return
	end
	self:ev({ t = "attack", from = m.uid })
	if sp == "steal" and self.yen > 0 and self.rng:NextNumber() < 0.5 then
		local n = math.min(self.yen, math.max(50, math.floor(self.yen * 0.3)))
		self.yen -= n
		m.stolen += n
		m.fleeing = true
		self:say(m.def.name .. " に " .. n .. " 円 盗まれた！ 倒せば返ってくる")
		return
	end
	self:damagePlayer(dmg, m.def.name)
	if self.ended then
		return
	end
	local msg = m.def.name .. " の攻撃！ " .. dmg .. " ダメージ"
	if sp == "rust" and self.equip.armor and self.rng:NextNumber() < 0.4 then
		self.equip.armor.plus = (self.equip.armor.plus or 0) - 1
		msg ..= "（スーツがかじられて −1）"
	elseif sp == "stress" and self.rng:NextNumber() < 0.5 then
		self.status.stress = 10
		msg ..= "（ストレス！ しばらく毎ターン HP −1）"
	elseif sp == "sleep" and self.rng:NextNumber() < 0.4 and self.status.sleep == 0 then
		self.status.sleep = 3
		msg ..= "（ねむい… 居眠りしてしまった）"
	elseif sp == "drain" then
		self.hunger = math.max(0, self.hunger - 15)
		msg ..= "（やる気を吸われた）"
	elseif sp == "grow" and self.rng:NextNumber() < 0.3 then
		m.atk = math.max(m.def.atk, m.atk - m.grow)
		m.grow = 0
		msg ..= "（バブルがはじけた）"
	end
	self:say(msg)
end

-- 部下（インターン）: 隣の敵を攻撃、いなければついてくる
function Run:internAct()
	local it = self.intern
	for _, m in self.monsters do
		if dist(m.x, m.y, it.x, it.y) == 1 then
			local dmg = math.max(1, it.atk - m.dfn)
			m.hp -= dmg
			m.asleep = false
			self:ev({ t = "hit", target = m.uid, dmg = dmg, from = "intern" })
			if m.hp <= 0 then
				self:killMonster(m, "intern")
			end
			return
		end
	end
	if dist(it.x, it.y, self.px, self.py) > 1 then
		local dx, dy = self.px - it.x, self.py - it.y
		local tries = math.abs(dx) >= math.abs(dy) and { { dx > 0 and 1 or -1, 0 }, { 0, dy > 0 and 1 or -1 } } or { { 0, dy > 0 and 1 or -1 }, { dx > 0 and 1 or -1, 0 } }
		for _, d in tries do
			local nx, ny = it.x + d[1], it.y + d[2]
			if self:walkable(nx, ny) and not self:occupied(nx, ny) then
				it.x, it.y = nx, ny
				self:ev({ t = "move", who = "intern", x = nx, y = ny })
				return
			end
		end
	end
end

function Run:addIntern()
	local x, y = self:freeNear(self.px, self.py)
	self.intern = { x = x, y = y, hp = 20, atk = 4 + self.floor // 3 }
	self:say("迷子のインターンを助けた。「ついていきます！」")
end

-- ===== 画面に送る形 =====
function Run:snapshot(full: boolean?)
	local rows = {}
	for y = 1, Config.MAP_H do
		local chars = table.create(Config.MAP_W)
		for x = 1, Config.MAP_W do
			local k = key(x, y)
			if self.visible[k] then
				chars[x] = tostring(self.f.grid[y][x] + 3) -- 3,4,5 = 見えている
			elseif self.explored[k] then
				chars[x] = tostring(self.f.grid[y][x]) -- 0,1,2 = 覚えている
			else
				chars[x] = "9"
			end
		end
		rows[y] = table.concat(chars)
	end
	local mons = {}
	for _, m in self.monsters do
		if self:canSeeMonster(m) then
			table.insert(mons, { uid = m.uid, id = m.id, x = m.x, y = m.y, hp = m.hp, hpMax = m.hpMax, asleep = m.asleep, grow = m.grow, shade = m.shade, name = m.def.name })
		end
	end
	local its = {}
	for _, it in self.items do
		if self.explored[key(it.x, it.y)] then
			table.insert(its, { x = it.x, y = it.y, kind = it.inst.kind, name = Items.displayName(it.inst, self.known, self.aliases) })
		end
	end
	local traps = {}
	for _, tr in self.traps do
		if tr.found then
			table.insert(traps, { x = tr.x, y = tr.y, kind = tr.kind, name = MapGen.TRAP_NAMES[tr.kind] })
		end
	end
	local inv = {}
	for i, inst in self.inv do
		local def = Items.BY_ID[inst.id]
		inv[i] = { id = inst.id, kind = def.kind, name = Items.displayName(inst, self.known, self.aliases), equipped = inst.equipped == true, desc = self.known[inst.id] and def.desc or "使ってみるまで分からない", known = self.known[inst.id] == true }
	end
	local shop = nil
	if self.shop then
		shop = { x = self.shop.x, y = self.shop.y, near = self:nearShop(), stock = {} }
		for i, s in self.shop.stock do
			shop.stock[i] = { name = s.def.name, price = s.price, desc = s.def.desc }
		end
	end
	local snap = {
		floor = self.floor,
		special = self.f.special,
		rows = rows,
		px = self.px,
		py = self.py,
		facing = self.facing,
		stairs = self.explored[key(self.f.stairs.X, self.f.stairs.Y)] and { self.f.stairs.X, self.f.stairs.Y } or nil,
		hp = self.hp,
		hpMax = self.hpMax,
		lv = self.lv,
		exp = self.exp,
		expNext = Config.EXP_TABLE[math.min(self.lv + 1, Config.MAX_LEVEL)],
		hunger = math.floor(self.hunger),
		hungerMax = self.hungerMax,
		yen = self.yen,
		atk = self:atk(),
		def = self:dfn(),
		status = self.status,
		monsters = mons,
		items = its,
		traps = traps,
		inv = inv,
		shop = shop,
		intern = self.intern and { x = self.intern.x, y = self.intern.y, hp = self.intern.hp } or nil,
		events = self.events,
		turn = self.turn,
		ended = self.ended,
		kills = self.kills,
		floorCap = self.floorCap,
		onStairs = (self.f.stairs.X == self.px and self.f.stairs.Y == self.py),
	}
	self.events = {}
	return snap
end

return Run
