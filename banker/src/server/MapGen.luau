-- 1 階ぶんの間取りを作る。部屋をランダムに置いて L 字の通路でつなぐ。
-- 戻り値の grid[y][x]: 0 = 壁, 1 = 部屋の床, 2 = 通路
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Items = require(ReplicatedStorage.Shared.Items)
local Monsters = require(ReplicatedStorage.Shared.Monsters)

local MapGen = {}

export type Room = { x: number, y: number, w: number, h: number, kind: string? }
export type Floor = {
	grid: { { number } },
	rooms: { Room },
	stairs: Vector2,
	start: Vector2,
	items: { any }, -- { x, y, inst }
	traps: { any }, -- { x, y, kind, found }
	monsters: { any }, -- 生成直後の配置 { x, y, def }
	special: string?, -- "exam" / "board" / "final" / "vault" / "audit" / nil
	shop: Vector2?,
}

local TRAP_KINDS = { "overtime", "meeting", "trip", "glitch", "stairs", "audit" }
MapGen.TRAP_NAMES = {
	overtime = "残業トラップ",
	meeting = "会議ワープ",
	trip = "転倒トラップ",
	glitch = "システム障害",
	stairs = "非常階段",
	audit = "監査の呼び出し",
}

local function emptyGrid(): { { number } }
	local g = {}
	for y = 1, Config.MAP_H do
		g[y] = table.create(Config.MAP_W, 0)
	end
	return g
end

local function carveRoom(grid, r: Room)
	for y = r.y, r.y + r.h - 1 do
		for x = r.x, r.x + r.w - 1 do
			grid[y][x] = 1
		end
	end
end

local function carveLine(grid, x1, y1, x2, y2)
	local x, y = x1, y1
	while x ~= x2 do
		if grid[y][x] == 0 then
			grid[y][x] = 2
		end
		x += (x2 > x) and 1 or -1
	end
	while y ~= y2 do
		if grid[y][x] == 0 then
			grid[y][x] = 2
		end
		y += (y2 > y) and 1 or -1
	end
	if grid[y][x] == 0 then
		grid[y][x] = 2
	end
end

local function center(r: Room): (number, number)
	return r.x + math.floor(r.w / 2), r.y + math.floor(r.h / 2)
end

local function overlaps(a: Room, b: Room): boolean
	return not (a.x + a.w + 1 < b.x or b.x + b.w + 1 < a.x or a.y + a.h + 1 < b.y or b.y + b.h + 1 < a.y)
end

local function randomFloorCell(rng: Random, grid, room: Room?, taken: { [string]: boolean }): (number, number)
	for _ = 1, 200 do
		local x, y
		if room then
			x = rng:NextInteger(room.x, room.x + room.w - 1)
			y = rng:NextInteger(room.y, room.y + room.h - 1)
		else
			x = rng:NextInteger(2, Config.MAP_W - 1)
			y = rng:NextInteger(2, Config.MAP_H - 1)
		end
		if grid[y][x] == 1 and not taken[x .. "," .. y] then
			taken[x .. "," .. y] = true
			return x, y
		end
	end
	return center(room or { x = 2, y = 2, w = 1, h = 1 })
end

-- ふつうの階
local function normalFloor(rng: Random, floorNo: number): Floor
	local grid = emptyGrid()
	local rooms: { Room } = {}
	local n = rng:NextInteger(Config.ROOMS_MIN, Config.ROOMS_MAX)
	local tries = 0
	while #rooms < n and tries < 300 do
		tries += 1
		local w = rng:NextInteger(Config.ROOM_MIN, Config.ROOM_MAX)
		local h = rng:NextInteger(Config.ROOM_MIN, Config.ROOM_MAX - 2)
		local r: Room = { x = rng:NextInteger(2, Config.MAP_W - w - 1), y = rng:NextInteger(2, Config.MAP_H - h - 1), w = w, h = h }
		local ok = true
		for _, o in rooms do
			if overlaps(r, o) then
				ok = false
				break
			end
		end
		if ok then
			table.insert(rooms, r)
		end
	end
	for _, r in rooms do
		carveRoom(grid, r)
	end
	-- 近い順につなぐ（最小全域木のかんたん版）＋ たまに余分な通路
	local connected = { rooms[1] }
	local rest = { table.unpack(rooms, 2) }
	while #rest > 0 do
		local bi, bj, bd = 1, 1, math.huge
		for i, a in connected do
			for j, b in rest do
				local ax, ay = center(a)
				local bx, by = center(b)
				local d = math.abs(ax - bx) + math.abs(ay - by)
				if d < bd then
					bi, bj, bd = i, j, d
				end
			end
		end
		local a, b = connected[bi], rest[bj]
		local ax, ay = center(a)
		local bx, by = center(b)
		if rng:NextNumber() < 0.5 then
			carveLine(grid, ax, ay, bx, ay)
			carveLine(grid, bx, ay, bx, by)
		else
			carveLine(grid, ax, ay, ax, by)
			carveLine(grid, ax, by, bx, by)
		end
		table.insert(connected, b)
		table.remove(rest, bj)
	end
	if #rooms >= 4 and rng:NextNumber() < 0.6 then
		local a, b = rooms[rng:NextInteger(1, #rooms)], rooms[rng:NextInteger(1, #rooms)]
		if a ~= b then
			local ax, ay = center(a)
			local bx, by = center(b)
			carveLine(grid, ax, ay, bx, ay)
			carveLine(grid, bx, ay, bx, by)
		end
	end

	local taken = {}
	local startRoom = rooms[rng:NextInteger(1, #rooms)]
	local stairsRoom = startRoom
	if #rooms > 1 then
		repeat
			stairsRoom = rooms[rng:NextInteger(1, #rooms)]
		until stairsRoom ~= startRoom
	end
	local sx, sy = randomFloorCell(rng, grid, startRoom, taken)
	local tx, ty = randomFloorCell(rng, grid, stairsRoom, taken)

	local f: Floor = { grid = grid, rooms = rooms, start = Vector2.new(sx, sy), stairs = Vector2.new(tx, ty), items = {}, traps = {}, monsters = {}, special = nil }

	-- 特別な部屋
	local roll = rng:NextNumber()
	if floorNo >= 4 and roll < 0.12 and #rooms >= 4 then
		-- 監査室（モンスターハウス）
		local r = rooms[rng:NextInteger(1, #rooms)]
		if r ~= startRoom then
			r.kind = "audit"
			f.special = "audit"
			for _ = 1, rng:NextInteger(6, 9) do
				local x, y = randomFloorCell(rng, grid, r, taken)
				table.insert(f.monsters, { x = x, y = y, def = Monsters.roll(rng, floorNo), asleep = true })
			end
			for _ = 1, 4 do
				local x, y = randomFloorCell(rng, grid, r, taken)
				local def = Items.roll(rng, floorNo)
				table.insert(f.items, { x = x, y = y, inst = Items.make(rng, def, floorNo) })
			end
		end
	elseif floorNo >= 3 and roll < 0.22 and #rooms >= 4 then
		-- 金庫室（宝が多いが罠も多い）
		local r = rooms[rng:NextInteger(1, #rooms)]
		if r ~= startRoom then
			r.kind = "vault"
			f.special = "vault"
			for _ = 1, 5 do
				local x, y = randomFloorCell(rng, grid, r, taken)
				local def = (rng:NextNumber() < 0.5) and Items.BY_ID.yen or Items.roll(rng, floorNo + 4)
				table.insert(f.items, { x = x, y = y, inst = Items.make(rng, def, floorNo + 4) })
			end
			for _ = 1, 4 do
				local x, y = randomFloorCell(rng, grid, r, taken)
				table.insert(f.traps, { x = x, y = y, kind = TRAP_KINDS[rng:NextInteger(1, #TRAP_KINDS)], found = false })
			end
		end
	elseif floorNo >= 2 and roll < 0.34 and #rooms >= 3 then
		-- 臨時売店（先輩ミサキ）
		local r = rooms[rng:NextInteger(1, #rooms)]
		if r ~= startRoom and r ~= stairsRoom then
			r.kind = "shop"
			local cx, cy = center(r)
			taken[cx .. "," .. cy] = true
			f.shop = Vector2.new(cx, cy)
		end
	end

	-- 道具
	for _ = 1, rng:NextInteger(Config.ITEMS_PER_FLOOR[1], Config.ITEMS_PER_FLOOR[2]) do
		local x, y = randomFloorCell(rng, grid, nil, taken)
		local def = Items.roll(rng, floorNo)
		table.insert(f.items, { x = x, y = y, inst = Items.make(rng, def, floorNo) })
	end
	-- 罠
	for _ = 1, rng:NextInteger(Config.TRAPS_PER_FLOOR[1], Config.TRAPS_PER_FLOOR[2]) do
		local x, y = randomFloorCell(rng, grid, nil, taken)
		table.insert(f.traps, { x = x, y = y, kind = TRAP_KINDS[rng:NextInteger(1, #TRAP_KINDS)], found = false })
	end
	-- 敵（最初の部屋には置かない）
	for _ = 1, rng:NextInteger(Config.MONSTERS_PER_FLOOR[1], Config.MONSTERS_PER_FLOOR[2]) do
		local r = rooms[rng:NextInteger(1, #rooms)]
		if r ~= startRoom and r.kind ~= "audit" then
			local x, y = randomFloorCell(rng, grid, r, taken)
			table.insert(f.monsters, { x = x, y = y, def = Monsters.roll(rng, floorNo) })
		end
	end
	return f
end

-- 昇進試験の階（固定の間取り: 大きな部屋 1 つ。クライアントが真ん中）
local function examFloor(rng: Random, floorNo: number): Floor
	local grid = emptyGrid()
	local r: Room = { x = 14, y = 9, w = 16, h = 12, kind = "exam" }
	carveRoom(grid, r)
	local f: Floor = { grid = grid, rooms = { r }, start = Vector2.new(16, 15), stairs = Vector2.new(28, 15), items = {}, traps = {}, monsters = {}, special = "exam" }
	local cx, cy = center(r)
	table.insert(f.monsters, { x = cx, y = cy, def = Monsters.BY_ID.client, levelBonus = floorNo // 5 })
	-- 試験のお供（少し）
	for i = 1, math.min(3, floorNo // 5) do
		table.insert(f.monsters, { x = cx + (i - 2) * 3, y = cy - 3, def = Monsters.roll(rng, floorNo) })
	end
	return f
end

-- 30F 取締役会
local function boardFloor(rng: Random, floorNo: number): Floor
	local grid = emptyGrid()
	local r: Room = { x = 12, y = 7, w = 20, h = 16, kind = "board" }
	carveRoom(grid, r)
	local f: Floor = { grid = grid, rooms = { r }, start = Vector2.new(14, 15), stairs = Vector2.new(30, 15), items = {}, traps = {}, monsters = {}, special = "board" }
	for i = -1, 1 do
		table.insert(f.monsters, { x = 24, y = 15 + i * 4, def = Monsters.BY_ID.director })
	end
	table.insert(f.monsters, { x = 28, y = 15, def = Monsters.BY_ID.darkmoney })
	for _ = 1, 3 do
		local taken = {}
		local x, y = randomFloorCell(rng, grid, r, taken)
		table.insert(f.items, { x = x, y = y, inst = Items.make(rng, Items.BY_ID.coffee_big, floorNo) })
	end
	return f
end

function MapGen.generate(seed: number, floorNo: number): Floor
	local rng = Random.new(seed * 1000 + floorNo)
	if floorNo == Config.BOSS_FLOOR then
		return boardFloor(rng, floorNo)
	elseif floorNo % Config.EXAM_EVERY == 0 and floorNo < Config.BOSS_FLOOR then
		return examFloor(rng, floorNo)
	end
	return normalFloor(rng, floorNo)
end

-- その座標が入っている部屋
function MapGen.roomAt(f: Floor, x: number, y: number): Room?
	for _, r in f.rooms do
		if x >= r.x and x < r.x + r.w and y >= r.y and y < r.y + r.h then
			return r
		end
	end
	return nil
end

return MapGen
