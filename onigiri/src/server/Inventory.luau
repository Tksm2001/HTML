-- もちもの・図鑑・コイン・連続日数の保存。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Config = require(ReplicatedStorage.Shared.Config)

local Inventory = {}

local store: DataStore? = nil
pcall(function()
	store = DataStoreService:GetDataStore("OnigiriFriends_v1")
end)

-- [Player] = { coins, counts = {id = n}, collected = {id = true}, placed = {slot = id}, streak, lastDay, tutorial, loaded, stat }
local data: { [Player]: any } = {}

local function key(player: Player)
	return "u_" .. player.UserId
end

local function today(): number
	return os.time() // 86400
end

function Inventory.get(player: Player)
	return data[player]
end

local function pushCoins(player: Player)
	local d = data[player]
	d.stat.Value = d.coins
	player:SetAttribute("Coins", d.coins)
end

-- 読み込み。戻り値: d と、今日のボーナス（0 ならなし）
function Inventory.load(player: Player)
	local d = { coins = Config.START_COINS, counts = {}, collected = {}, placed = {}, streak = 1, lastDay = today(), tutorial = false, loaded = false }
	local bonus = Config.DAILY_BONUS + Config.STREAK_BONUS
	if store then
		local ok, saved = pcall(function()
			return (store :: DataStore):GetAsync(key(player))
		end)
		if ok then
			d.loaded = true
			if type(saved) == "table" then
				d.coins = saved.coins or d.coins
				d.counts = saved.counts or {}
				d.collected = saved.collected or {}
				d.placed = saved.placed or {}
				d.tutorial = saved.tutorial == true
				local last = saved.lastDay or today()
				if last == today() then
					d.streak = saved.streak or 1
					bonus = 0 -- 今日はもうもらった
				elseif last == today() - 1 then
					d.streak = (saved.streak or 0) + 1
					bonus = Config.DAILY_BONUS + Config.STREAK_BONUS * math.min(d.streak, 7)
				else
					d.streak = 1
				end
			end
		end
	end
	d.lastDay = today()
	d.coins += bonus
	-- 画面右上のプレイヤー一覧
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local c = Instance.new("IntValue")
	c.Name = "コイン"
	c.Value = d.coins
	c.Parent = stats
	local z = Instance.new("IntValue")
	z.Name = "図鑑"
	local n = 0
	for _ in d.collected do
		n += 1
	end
	z.Value = n
	z.Parent = stats
	stats.Parent = player
	d.stat = c
	d.zukan = z
	data[player] = d
	player:SetAttribute("Coins", d.coins)
	player:SetAttribute("Streak", d.streak)
	player:SetAttribute("TutorialSeen", d.tutorial)
	return d, bonus
end

function Inventory.addCoins(player: Player, n: number)
	local d = data[player]
	if not d then
		return
	end
	d.coins = math.max(0, math.floor(d.coins + n))
	pushCoins(player)
end

function Inventory.spend(player: Player, n: number): boolean
	local d = data[player]
	if not d or d.coins < n then
		return false
	end
	d.coins -= n
	pushCoins(player)
	return true
end

-- キャラを 1 体手に入れる。戻り値: 初めてか
function Inventory.give(player: Player, id: string): boolean
	local d = data[player]
	d.counts[id] = (d.counts[id] or 0) + 1
	local isNew = not d.collected[id]
	d.collected[id] = true
	if isNew then
		d.zukan.Value += 1
	end
	return isNew
end

-- 置いていない手持ちの数
function Inventory.free(player: Player, id: string): number
	local d = data[player]
	local placedN = 0
	for _, pid in d.placed do
		if pid == id then
			placedN += 1
		end
	end
	return (d.counts[id] or 0) - placedN
end

-- ダブりを 1 体「おかえし」してコインに
function Inventory.sell(player: Player, id: string, price: number): boolean
	local d = data[player]
	if Inventory.free(player, id) < 1 or (d.counts[id] or 0) < 2 then
		return false -- 最後の 1 体は残す
	end
	d.counts[id] -= 1
	Inventory.addCoins(player, price)
	return true
end

-- 画面に送る形
function Inventory.snapshot(player: Player)
	local d = data[player]
	return { coins = d.coins, counts = d.counts, collected = d.collected, placed = d.placed, streak = d.streak }
end

function Inventory.save(player: Player)
	local d = data[player]
	if not d or not store or not d.loaded then
		return
	end
	local payload = { coins = d.coins, counts = d.counts, collected = d.collected, placed = d.placed, streak = d.streak, lastDay = d.lastDay, tutorial = player:GetAttribute("TutorialSeen") == true }
	pcall(function()
		(store :: DataStore):SetAsync(key(player), payload)
	end)
end

function Inventory.forget(player: Player)
	data[player] = nil
end

return Inventory
