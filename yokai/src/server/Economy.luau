-- お賽銭（コイン）と保存。留守中の収入もここ。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Config = require(ReplicatedStorage.Shared.Config)

local Economy = {}

local store: DataStore? = nil
pcall(function()
	store = DataStoreService:GetDataStore("YokaiShrine_v1")
end)

-- [Player] = { coins, loaded, saved = { yokai, pedestals, lastSeen, income } }
local data: { [Player]: any } = {}

local function key(player: Player)
	return "u_" .. player.UserId
end

local function leaderstats(player: Player, coins: number)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local c = Instance.new("IntValue")
	c.Name = "お賽銭"
	c.Value = coins
	c.Parent = stats
	stats.Parent = player
	return c
end

-- 読み込む。戻り値: 保存されていた内容（なければ nil）
function Economy.load(player: Player)
	local d = { coins = Config.START_COINS, loaded = false, saved = nil }
	if store then
		local ok, saved = pcall(function()
			return (store :: DataStore):GetAsync(key(player))
		end)
		if ok then
			d.loaded = true
			if type(saved) == "table" then
				d.coins = saved.coins or Config.START_COINS
				d.saved = saved
				-- 留守中の収入（上限あり）
				local away = math.clamp(os.time() - (saved.lastSeen or os.time()), 0, Config.OFFLINE_CAP_SECONDS)
				local offline = math.floor(away * (saved.income or 0))
				if offline > 0 then
					d.coins += offline
					d.offline = offline
				end
			end
		end
	end
	d.stat = leaderstats(player, d.coins)
	data[player] = d
	player:SetAttribute("Coins", d.coins)
	return d
end

function Economy.coins(player: Player): number
	local d = data[player]
	return d and d.coins or 0
end

function Economy.add(player: Player, amount: number)
	local d = data[player]
	if not d then
		return
	end
	d.coins = math.max(0, math.floor(d.coins + amount))
	d.stat.Value = d.coins
	player:SetAttribute("Coins", d.coins)
end

function Economy.spend(player: Player, amount: number): boolean
	local d = data[player]
	if not d or d.coins < amount then
		return false
	end
	Economy.add(player, -amount)
	return true
end

-- 保存する。snapshot = { yokai = {...}, pedestals = n, income = n/s }
function Economy.save(player: Player, snapshot)
	local d = data[player]
	if not d or not store or not d.loaded then
		return
	end
	local payload = {
		coins = d.coins,
		yokai = snapshot.yokai,
		pedestals = snapshot.pedestals,
		income = snapshot.income,
		lastSeen = os.time(),
		tutorial = snapshot.tutorial,
	}
	pcall(function()
		(store :: DataStore):SetAsync(key(player), payload)
	end)
end

function Economy.forget(player: Player)
	data[player] = nil
end

return Economy
