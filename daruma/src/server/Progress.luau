-- プレイヤーの記録（勝った回数、連続で遊んだ日数、説明を見たか）を保存する。
-- 画面右上のプレイヤー一覧に Wins / Streak として表示される（leaderstats）。
-- 保存先は Roblox の DataStore。公開前の Studio では保存できないことがあるが、そのときも遊べる。
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local Progress = {}

local store: DataStore? = nil
pcall(function()
	store = DataStoreService:GetDataStore("DarumaProgress_v1")
end)

-- [Player] = { wins, streak, lastDay, tutorial }
local data: { [Player]: any } = {}

local function today(): number
	return os.time() // 86400
end

local function key(player: Player): string
	return "u_" .. player.UserId
end

local function save(player: Player)
	local d = data[player]
	if not d or not store or not d.loaded then
		return
	end
	pcall(function()
		(store :: DataStore):SetAsync(key(player), { wins = d.wins, streak = d.streak, lastDay = d.lastDay, tutorial = d.tutorial })
	end)
end

local function onJoin(player: Player)
	local d = { wins = 0, streak = 1, lastDay = today(), tutorial = false, loaded = false }
	if store then
		local ok, saved = pcall(function()
			return (store :: DataStore):GetAsync(key(player))
		end)
		if ok then
			d.loaded = true
			if type(saved) == "table" then
				d.wins = saved.wins or 0
				d.tutorial = saved.tutorial == true
				-- 昨日も遊んでいたら連続日数 +1、2 日以上あいたら 1 に戻る
				local last = saved.lastDay or today()
				if last == today() then
					d.streak = saved.streak or 1
				elseif last == today() - 1 then
					d.streak = (saved.streak or 0) + 1
				else
					d.streak = 1
				end
			end
		end
	end
	d.lastDay = today()
	data[player] = d

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = d.wins
	wins.Parent = stats
	local streak = Instance.new("IntValue")
	streak.Name = "Streak"
	streak.Value = d.streak
	streak.Parent = stats
	stats.Parent = player

	-- 説明を見たかどうか（画面側が読む）
	player:SetAttribute("TutorialSeen", d.tutorial)
	save(player)
end

function Progress.addWin(player: Player)
	local d = data[player]
	if not d then
		return
	end
	d.wins += 1
	local stats = player:FindFirstChild("leaderstats")
	local wins = stats and stats:FindFirstChild("Wins") :: IntValue?
	if wins then
		wins.Value = d.wins
	end
	task.spawn(save, player)
end

function Progress.markTutorialSeen(player: Player)
	local d = data[player]
	if not d or d.tutorial then
		return
	end
	d.tutorial = true
	player:SetAttribute("TutorialSeen", true)
	task.spawn(save, player)
end

function Progress.start()
	Players.PlayerAdded:Connect(onJoin)
	for _, p in Players:GetPlayers() do
		task.spawn(onJoin, p)
	end
	Players.PlayerRemoving:Connect(function(player)
		save(player)
		data[player] = nil
	end)
	-- サーバーが閉じるときも保存する
	game:BindToClose(function()
		for player in data do
			save(player)
		end
	end)
end

return Progress
