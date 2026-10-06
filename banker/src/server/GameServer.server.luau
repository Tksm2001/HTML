-- サーバーの司令塔。オフィスを建てて、プレイヤーの周（ラン）を管理し、画面に snapshot を送る。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local Config = require(ReplicatedStorage.Shared.Config)
local Items = require(ReplicatedStorage.Shared.Items)
local Story = require(ReplicatedStorage.Shared.Story)
local Profile = require(script.Parent.Profile)
local Office = require(script.Parent.Office)
local Run = require(script.Parent.Run)

-- ===== 通信 =====
local event = Instance.new("RemoteEvent")
event.Name = "GameEvent"
event.Parent = ReplicatedStorage
local request = Instance.new("RemoteEvent")
request.Name = "GameRequest"
request.Parent = ReplicatedStorage
local getProfile = Instance.new("RemoteFunction")
getProfile.Name = "GetProfile"
getProfile.Parent = ReplicatedStorage

local office = Office.build()
workspace.SpawnLocation.CFrame = office.SpawnCFrame

-- 塔にいる間、アバターをしまっておく箱（遠く）
local limbo = Instance.new("Part")
limbo.Name = "Limbo"
limbo.Size = Vector3.new(30, 1, 30)
limbo.CFrame = CFrame.new(0, 400, -800)
limbo.Anchored = true
limbo.Transparency = 1
limbo.Parent = workspace

local runs: { [Player]: any } = {}

local orderedPoints, orderedDaily
pcall(function()
	orderedPoints = DataStoreService:GetOrderedDataStore("BankerPoints_v1")
end)
local function dailyStore()
	local ok, s = pcall(function()
		return DataStoreService:GetOrderedDataStore("BankerDaily_" .. (os.time() // 86400))
	end)
	return ok and s or nil
end

local function deepCopy(t)
	if type(t) ~= "table" then
		return t
	end
	local c = {}
	for k, v in t do
		c[k] = deepCopy(v)
	end
	return c
end

local function sendProfile(player: Player)
	event:FireClient(player, "profile", Profile.snapshot(player))
end

local function dialog(player: Player, lines, tag: string?)
	event:FireClient(player, "dialog", { lines = lines, tag = tag })
end

-- ===== キャラをしまう／戻す =====
local function hideCharacter(player: Player)
	local ch = player.Character
	if not ch then
		return
	end
	local root = ch:FindFirstChild("HumanoidRootPart")
	if root then
		root.Anchored = true
		ch:PivotTo(limbo.CFrame * CFrame.new(0, 4, 0))
	end
end

local function showCharacter(player: Player)
	local ch = player.Character
	if not ch then
		return
	end
	local root = ch:FindFirstChild("HumanoidRootPart")
	if root then
		ch:PivotTo(office.SpawnCFrame * CFrame.new(0, 2, 0))
		root.Anchored = false
	end
end

-- ===== 周の開始と終了 =====
local function startRun(player: Player, daily: boolean)
	if runs[player] then
		return
	end
	local d = Profile.get(player)
	if not d then
		return
	end
	if daily and Profile.dailyDone(player) then
		event:FireClient(player, "toast", "本日の案件は もう挑戦した。また明日！")
		return
	end
	local rank = Profile.rank(player)
	local seed = daily and (os.time() // 86400) or Random.new():NextInteger(1, 1e9)
	local bag = deepCopy(d.bag or {})
	local run = Run.new(player, { seed = seed, floorCap = daily and Config.DAILY_FLOORS or Config.RANKS[rank].floorCap, bag = bag, yen = 0, daily = daily })
	run.rank = rank
	runs[player] = run
	player:SetAttribute("InRun", true)
	hideCharacter(player)
	if d.runs == 0 then
		run:say("先輩ミサキ「矢印キーか画面の十字で 1 歩ずつ。敵にぶつかれば攻撃だよ」")
		run:say("先輩ミサキ「▲ の階段を見つけたら『のぼる』。危なくなったら 持ち物の 帰還の名刺！」")
	end
	event:FireClient(player, "run", run:snapshot(true))
end

local function finishRun(player: Player)
	local run = runs[player]
	if not run then
		return
	end
	runs[player] = nil
	local d = Profile.get(player)
	local result = { floor = run.floor, result = run.ended, kills = run.kills, yen = run.yen, daily = run.daily }
	local newRank = Profile.finishRun(player, result)
	-- 持ち物
	if run.ended == "dead" then
		d.bag = {}
	else
		d.bag = run.inv
	end
	-- ランキング
	pcall(function()
		if orderedPoints then
			orderedPoints:SetAsync("u_" .. player.UserId, d.points)
		end
		if run.daily then
			local s = dailyStore()
			if s then
				s:SetAsync("u_" .. player.UserId, run.floor)
			end
		end
	end)
	Profile.save(player)
	player:SetAttribute("InRun", false)
	showCharacter(player)
	-- 画面
	local story
	if run.ended == "cleared" and not run.daily then
		story = Story.ENDING
	elseif run.ended == "dead" then
		story = { { who = "kanemoto", text = Story.FAIL[Random.new():NextInteger(1, #Story.FAIL)] } }
	else
		story = { { who = "kanemoto", text = Story.RETURN[Random.new():NextInteger(1, #Story.RETURN)] } }
	end
	event:FireClient(player, "runEnd", { result = run.ended, floor = run.floor, kills = run.kills, yen = run.yen, pts = d.history[1] and d.history[1].pts or 0, daily = run.daily, story = story, newRank = newRank })
	sendProfile(player)
	if newRank then
		-- ランクアップのセリフ（伝説の万年筆のプレゼントも）
		task.delay(0.5, function()
			dialog(player, Story.RANK_UP[newRank] or {}, "rank" .. newRank)
			if newRank == 6 then
				table.insert(d.bag, { id = "pen_legend", kind = "weapon", plus = 0 })
			end
		end)
	end
end

-- ===== 周の中の操作 =====
local function afterAction(player: Player, run)
	-- 迷子のインターン（ランク 3 以上、4 の倍数の階に着いた時）
	if run.rank >= 3 and run.floor % 4 == 0 and not run.intern and run.internFloor ~= run.floor then
		run.internFloor = run.floor
		run:addIntern()
	end
	event:FireClient(player, "run", run:snapshot())
	if run.ended then
		task.delay(1.2, function()
			finishRun(player)
		end)
	end
end

request.OnServerEvent:Connect(function(player: Player, kind: string, a, b)
	local run = runs[player]
	if run then
		if run.ended then
			return
		end
		if kind == "step" and type(a) == "number" and a >= 1 and a <= 4 then
			if run:step(math.floor(a)) then
				afterAction(player, run)
			end
		elseif kind == "wait" then
			run:wait()
			afterAction(player, run)
		elseif kind == "climb" then
			if run:climb() then
				afterAction(player, run)
			end
		elseif kind == "use" and type(a) == "number" then
			if run:use(math.floor(a)) then
				afterAction(player, run)
			else
				event:FireClient(player, "run", run:snapshot())
			end
		elseif kind == "throw" and type(a) == "number" then
			if run:throw(math.floor(a)) then
				afterAction(player, run)
			end
		elseif kind == "drop" and type(a) == "number" then
			if run:drop(math.floor(a)) then
				afterAction(player, run)
			end
		elseif kind == "face" and type(a) == "number" and a >= 1 and a <= 4 then
			run.facing = math.floor(a)
			event:FireClient(player, "run", run:snapshot())
		elseif kind == "buy" and type(a) == "number" then
			run:buy(math.floor(a))
			event:FireClient(player, "run", run:snapshot())
		elseif kind == "sell" and type(a) == "number" then
			run:sell(math.floor(a))
			event:FireClient(player, "run", run:snapshot())
		elseif kind == "giveup" then
			run:say("あきらめて帰った…（持ち物は失う）")
			run.ended = "dead"
			run:ev({ t = "end", result = "dead" })
			afterAction(player, run)
		end
		return
	end
	-- ===== オフィスでの操作 =====
	local d = Profile.get(player)
	if not d then
		return
	end
	if kind == "shopBuy" and type(a) == "string" then
		local def = Items.BY_ID[a]
		if def and def.price > 0 and #(d.bag or {}) < Config.INVENTORY_MAX and Profile.spendYen(player, def.price) then
			d.bag = d.bag or {}
			local inst = { id = def.id, kind = def.kind }
			if def.kind == "weapon" or def.kind == "armor" then
				inst.plus = 0
			elseif def.kind == "calc" then
				inst.charges = def.charges
			end
			table.insert(d.bag, inst)
			event:FireClient(player, "toast", def.name .. " を買った")
		else
			event:FireClient(player, "toast", "買えない（円か、持ち物の空きが足りない）")
		end
		sendProfile(player)
	elseif kind == "shopSell" and type(a) == "number" then
		local inst = d.bag and d.bag[math.floor(a)]
		if inst then
			local def = Items.BY_ID[inst.id]
			local price = math.floor(def.price * 0.4) + (inst.plus or 0) * 100
			table.remove(d.bag, math.floor(a))
			Profile.addYen(player, price)
			event:FireClient(player, "toast", def.name .. " を " .. price .. " 円で売った")
		end
		sendProfile(player)
	elseif kind == "lockerPut" and type(a) == "number" then
		local slots = Config.LOCKER_SLOTS_BY_RANK[Profile.rank(player)]
		local inst = d.bag and d.bag[math.floor(a)]
		if inst and #d.locker < slots then
			table.remove(d.bag, math.floor(a))
			inst.equipped = nil
			table.insert(d.locker, inst)
		else
			event:FireClient(player, "toast", "ロッカーがいっぱい（ランクが上がると増える）")
		end
		sendProfile(player)
	elseif kind == "lockerTake" and type(a) == "number" then
		local inst = d.locker[math.floor(a)]
		if inst and #(d.bag or {}) < Config.INVENTORY_MAX then
			table.remove(d.locker, math.floor(a))
			d.bag = d.bag or {}
			table.insert(d.bag, inst)
		end
		sendProfile(player)
	elseif kind == "bagEquip" and type(a) == "number" then
		-- オフィスで装備を切り替える
		local inst = d.bag and d.bag[math.floor(a)]
		if inst then
			local def = Items.BY_ID[inst.id]
			if def.kind == "weapon" or def.kind == "armor" or def.kind == "acc" then
				local was = inst.equipped
				for _, o in d.bag do
					if Items.BY_ID[o.id].kind == def.kind then
						o.equipped = nil
					end
				end
				if not was then
					inst.equipped = true
				end
			end
		end
		sendProfile(player)
	elseif kind == "introDone" then
		d.intro = true
		player:SetAttribute("Intro", true)
	elseif kind == "talk" and type(a) == "string" then
		local rank = Profile.rank(player)
		if a == "kanemoto" then
			local lines = Story.RANK_UP[rank] and { Story.RANK_UP[rank][1] } or { Story.INTRO[2] }
			if not d.intro then
				lines = Story.INTRO
			end
			dialog(player, lines, "kanemoto")
		elseif a == "hayate" then
			if rank < 4 then
				dialog(player, { { who = "hayate", text = "……誰だ？ 新人か。話しかけるな、忙しい。" } }, "hayate")
			else
				local l = Story.RANK_UP[rank]
				dialog(player, { l[#l] }, "hayate")
			end
		end
	end
end)

getProfile.OnServerInvoke = function(player: Player)
	return Profile.snapshot(player)
end

-- ===== オフィスの ProximityPrompt =====
local function onPrompt(part: BasePart, fn)
	local pp = part:FindFirstChildOfClass("ProximityPrompt")
	if pp then
		pp.Triggered:Connect(fn)
	end
end
onPrompt(office.Elevator, function(player)
	startRun(player, false)
end)
onPrompt(office.Daily, function(player)
	startRun(player, true)
end)
onPrompt(office.Shop, function(player)
	event:FireClient(player, "openShop", Profile.snapshot(player))
end)
onPrompt(office.Locker, function(player)
	event:FireClient(player, "openLocker", Profile.snapshot(player))
end)
onPrompt(office.Boss, function(player)
	local d = Profile.get(player)
	if not d then
		return
	end
	if not d.intro then
		dialog(player, Story.INTRO, "intro")
	else
		local rank = Profile.rank(player)
		local lines = Story.RANK_UP[rank] and { Story.RANK_UP[rank][1] } or { Story.INTRO[2] }
		dialog(player, lines, "kanemoto")
	end
end)
onPrompt(office.Rival, function(player)
	local rank = Profile.rank(player)
	if rank < 4 then
		dialog(player, { { who = "hayate", text = "……誰だ？ 新人か。話しかけるな、忙しい。" } }, "hayate")
	else
		local l = Story.RANK_UP[rank]
		dialog(player, { l[#l] }, "hayate")
	end
end)

-- ===== ランキングの壁 =====
local function refreshRanking()
	local lines = { "社内ランキング（キャリア点）" }
	local ok = pcall(function()
		local page = orderedPoints:GetSortedAsync(false, 8):GetCurrentPage()
		for i, e in page do
			local uid = tonumber(string.sub(e.key, 3))
			local name = "?"
			pcall(function()
				name = Players:GetNameFromUserIdAsync(uid)
			end)
			table.insert(lines, string.format("%d. %s  %d 点", i, name, e.value))
		end
	end)
	if not ok or #lines == 1 then
		for i, p in Players:GetPlayers() do
			table.insert(lines, string.format("%d. %s  %d 点", i, p.DisplayName, p:GetAttribute("Points") or 0))
		end
	end
	office.RankText.Text = table.concat(lines, "\n")
	local lines2 = { "本日の案件 ランキング（到達階）" }
	local ok2 = pcall(function()
		local s = dailyStore()
		local page = s:GetSortedAsync(false, 8):GetCurrentPage()
		for i, e in page do
			local uid = tonumber(string.sub(e.key, 3))
			local name = "?"
			pcall(function()
				name = Players:GetNameFromUserIdAsync(uid)
			end)
			table.insert(lines2, string.format("%d. %s  %dF", i, name, e.value))
		end
	end)
	if not ok2 or #lines2 == 1 then
		table.insert(lines2, "まだ誰も挑戦していない")
	end
	office.RankText2.Text = table.concat(lines2, "\n")
end

-- ===== 入退室 =====
Players.PlayerAdded:Connect(function(player)
	Profile.load(player)
	player:SetAttribute("InRun", false)
	player.CharacterAdded:Connect(function(ch)
		if runs[player] then
			task.wait(0.2)
			hideCharacter(player)
		end
	end)
	task.wait(0.5)
	sendProfile(player)
	refreshRanking()
end)

Players.PlayerRemoving:Connect(function(player)
	local run = runs[player]
	if run then
		-- 途中で抜けたら「倒れた」扱い（持ち物は失う）
		run.ended = "dead"
		runs[player] = nil
		local d = Profile.get(player)
		if d then
			Profile.finishRun(player, { floor = run.floor, result = "dead", kills = run.kills, yen = 0, daily = run.daily })
			d.bag = {}
		end
	end
	Profile.save(player)
	Profile.forget(player)
end)

game:BindToClose(function()
	for _, p in Players:GetPlayers() do
		Profile.save(p)
	end
end)

task.spawn(function()
	while true do
		task.wait(Config.SAVE_EVERY)
		for _, p in Players:GetPlayers() do
			Profile.save(p)
		end
		refreshRanking()
	end
end)

-- ===== Studio だけのチート（テスト用）=====
if RunService:IsStudio() then
	local cheat = Instance.new("BindableEvent")
	cheat.Name = "Cheat"
	cheat.Parent = ServerStorage
	cheat.Event:Connect(function(player: Player, cmd: string, arg)
		local d = Profile.get(player)
		if not d then
			return
		end
		local run = runs[player]
		if cmd == "yen" then
			Profile.addYen(player, tonumber(arg) or 1000)
		elseif cmd == "points" then
			d.points += tonumber(arg) or 10
			sendProfile(player)
		elseif cmd == "item" then
			local def = Items.BY_ID[arg]
			if def then
				local inst = Items.make(Random.new(), def, 1)
				if run then
					table.insert(run.inv, inst)
					run.known[def.id] = true
				else
					d.bag = d.bag or {}
					table.insert(d.bag, inst)
				end
			end
		elseif cmd == "mon" and run then
			local Monsters = require(ReplicatedStorage.Shared.Monsters)
			local def = Monsters.BY_ID[arg] or Monsters.BY_ID.akaji
			local x, y = run.px + 1, run.py
			if not run:walkable(x, y) or run:occupied(x, y) then
				x, y = run:freeNear(run.px, run.py)
			end
			run:spawnMonster(def, x, y, false)
			run:updateSight()
			event:FireClient(player, "run", run:snapshot())
		elseif cmd == "tp" and run then
			local x, y = tostring(arg):match("(%d+),(%d+)")
			if x and run:walkable(tonumber(x), tonumber(y)) then
				run.px, run.py = tonumber(x), tonumber(y)
				run:updateSight()
				event:FireClient(player, "run", run:snapshot())
			end
		elseif cmd == "floor" and run then
			run.mapRevealed = false
			run:enterFloor(tonumber(arg) or 1)
			event:FireClient(player, "run", run:snapshot())
		elseif cmd == "start" then
			startRun(player, arg == "daily")
		elseif cmd == "hp" and run then
			run.hp = tonumber(arg) or run.hpMax
		elseif cmd == "reveal" and run then
			run.mapRevealed = true
			run:updateSight()
			event:FireClient(player, "run", run:snapshot())
		end
		sendProfile(player)
	end)
end
