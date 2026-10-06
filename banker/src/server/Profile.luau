-- キャリア（ランク・挑戦回数・最高階・貯金・ロッカー）の保存。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Config = require(ReplicatedStorage.Shared.Config)

local Profile = {}

local store: DataStore? = nil
pcall(function()
	store = DataStoreService:GetDataStore("BankerTower_v1")
end)

local data: { [Player]: any } = {}

local function key(player: Player)
	return "u_" .. player.UserId
end

local function today(): number
	return os.time() // 86400
end

function Profile.get(player: Player)
	return data[player]
end

function Profile.rank(player: Player): number
	return Config.rankFor(data[player].points)
end

local function push(player: Player)
	local d = data[player]
	local r = Config.rankFor(d.points)
	d.stats.rank.Value = Config.RANKS[r].title
	d.stats.floor.Value = d.bestFloor
	player:SetAttribute("Rank", r)
	player:SetAttribute("Points", d.points)
	player:SetAttribute("Yen", d.yen)
	player:SetAttribute("Runs", d.runs)
	player:SetAttribute("BestFloor", d.bestFloor)
	player:SetAttribute("Intro", d.intro)
end

function Profile.load(player: Player)
	local d = {
		points = 0,
		runs = 0,
		bestFloor = 0,
		yen = Config.START_YEN,
		locker = {},
		intro = false,
		seenRank = 1,
		cleared = false,
		dailyDay = 0,
		dailyBest = 0,
		kills = 0,
		loaded = false,
		history = {}, -- 直近の周 { floor, result, kills, yen }
	}
	if store then
		local ok, saved = pcall(function()
			return (store :: DataStore):GetAsync(key(player))
		end)
		if ok then
			d.loaded = true
			if type(saved) == "table" then
				for k, v in saved do
					d[k] = v
				end
			end
		end
	end
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local rank = Instance.new("StringValue")
	rank.Name = "ランク"
	rank.Parent = stats
	local floor = Instance.new("IntValue")
	floor.Name = "最高階"
	floor.Parent = stats
	stats.Parent = player
	d.stats = { rank = rank, floor = floor }
	data[player] = d
	push(player)
	return d
end

-- 1 周の結果を記録。戻り値: 新しいランク番号（上がった時だけ）か nil
function Profile.finishRun(player: Player, result)
	local d = data[player]
	if not d then
		return nil
	end
	local before = Config.rankFor(d.points)
	d.runs += 1
	d.kills += result.kills or 0
	local pts = result.floor
	if result.result ~= "dead" then
		pts = math.floor(pts * 1.5)
	end
	d.points += pts
	d.bestFloor = math.max(d.bestFloor, result.floor)
	if result.result ~= "dead" then
		d.yen += result.yen or 0
	end
	if result.result == "cleared" and not result.daily then
		d.cleared = true
	end
	if result.daily then
		d.dailyDay = today()
		d.dailyBest = math.max(d.dailyBest, result.floor)
	end
	table.insert(d.history, 1, { floor = result.floor, result = result.result, kills = result.kills, yen = result.yen, pts = pts })
	while #d.history > 10 do
		table.remove(d.history)
	end
	push(player)
	local after = Config.rankFor(d.points)
	if after > before then
		return after
	end
	return nil
end

function Profile.dailyDone(player: Player): boolean
	return data[player].dailyDay == today()
end

function Profile.spendYen(player: Player, n: number): boolean
	local d = data[player]
	if d.yen < n then
		return false
	end
	d.yen -= n
	push(player)
	return true
end

function Profile.addYen(player: Player, n: number)
	local d = data[player]
	d.yen += n
	push(player)
end

function Profile.snapshot(player: Player)
	local d = data[player]
	local r = Config.rankFor(d.points)
	local nextPts = Config.RANKS[math.min(r + 1, #Config.RANKS)].points
	return {
		rank = r,
		title = Config.RANKS[r].title,
		titleEn = Config.RANKS[r].titleEn,
		points = d.points,
		nextPoints = nextPts,
		floorCap = Config.RANKS[r].floorCap,
		runs = d.runs,
		bestFloor = d.bestFloor,
		yen = d.yen,
		bag = d.bag or {},
		locker = d.locker,
		lockerSlots = Config.LOCKER_SLOTS_BY_RANK[r],
		history = d.history,
		dailyDone = Profile.dailyDone(player),
		dailyBest = d.dailyBest,
		cleared = d.cleared,
		kills = d.kills,
	}
end

function Profile.save(player: Player)
	local d = data[player]
	if not d or not store or not d.loaded then
		return
	end
	local payload = {}
	for k, v in d do
		if k ~= "stats" and k ~= "loaded" then
			payload[k] = v
		end
	end
	pcall(function()
		(store :: DataStore):SetAsync(key(player), payload)
	end)
end

function Profile.forget(player: Player)
	data[player] = nil
end

return Profile
