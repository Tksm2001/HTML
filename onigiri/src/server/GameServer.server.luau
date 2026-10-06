-- 進行役。商店街を組み、人が入ったらへやを割り当て、ガチャ・クレーン・飾る・おかえしをつなぐ。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Designs = require(ReplicatedStorage.Shared.Chars.Designs)
local Street = require(script.Parent.Street)
local Inventory = require(script.Parent.Inventory)

local event = Instance.new("RemoteEvent")
event.Name = "GameEvent"
event.Parent = ReplicatedStorage
local request = Instance.new("RemoteEvent")
request.Name = "GameRequest"
request.Parent = ReplicatedStorage
local getInventory = Instance.new("RemoteFunction")
getInventory.Name = "GetInventory"
getInventory.Parent = ReplicatedStorage

local function tell(player: Player, kind: string, data: any?)
	event:FireClient(player, kind, data)
end
local function tellAll(kind: string, data: any?)
	event:FireAllClients(kind, data)
end

local street = Street.build()

local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
if spawnLocation then
	spawnLocation.Transparency = 1
	spawnLocation.CFrame = street.SpawnCFrame * CFrame.new(0, -3, 0)
end

local byId = {}
local byRarity = { N = {}, R = {}, SR = {}, UR = {} }
for _, c in Config.CHARS do
	byId[c.id] = c
	table.insert(byRarity[c.rarity], c)
end

-- ===== へや =====
local roomOf: { [Player]: any } = {}

local function setPlate(room, text: string)
	local gui = room.NamePlate:FindFirstChildOfClass("SurfaceGui")
	local l = gui and gui:FindFirstChildOfClass("TextLabel")
	if l then
		l.Text = text
	end
end

local function clearSlot(room, n: number)
	local s = room.Slots[n]
	if s.Model then
		s.Model:Destroy()
	end
	s.Model = nil
	s.Id = nil
	s.Part:SetAttribute("Id", nil)
end

local function fillSlot(room, n: number, id: string)
	clearSlot(room, n)
	local s = room.Slots[n]
	local m = Designs.build(id, CFrame.new(), room.Folder)
	local scale = 0.55
	m:ScaleTo(scale)
	m:PivotTo(s.CFrame * CFrame.new(0, 1.9 * scale, 0) * CFrame.Angles(0, math.pi, 0)) -- 道（+Z）の方を向く
	s.Model = m
	s.Id = id
	s.Part:SetAttribute("Id", id)
end

local function refreshSlotPrompt(room, n: number)
	local s = room.Slots[n]
	local prompt = s.Part:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.MaxActivationDistance = 7
		prompt.RequiresLineOfSight = false
		prompt.Parent = s.Part
		prompt.Triggered:Connect(function(player)
			if room.Owner ~= player then
				return
			end
			if s.Id then
				-- しまう
				local d = Inventory.get(player)
				d.placed[tostring(n)] = nil
				clearSlot(room, n)
				refreshSlotPrompt(room, n)
				tell(player, "msg", "しまった  Put away")
			else
				-- 画面で選ぶ
				tell(player, "pick", n)
			end
		end)
	end
	prompt.ObjectText = s.Id and byId[s.Id].name or "たな / Shelf"
	prompt.ActionText = s.Id and "しまう / Put away" or "かざる / Display"
	prompt.HoldDuration = 0.3
end

local function assignRoom(player: Player)
	for _, room in street.Rooms do
		if room.Owner == nil then
			room.Owner = player
			roomOf[player] = room
			setPlate(room, player.DisplayName)
			player:SetAttribute("Room", room.Index)
			for n = 1, Config.ROOM_SLOTS do
				refreshSlotPrompt(room, n)
			end
			return room
		end
	end
	return nil
end

local function releaseRoom(player: Player)
	local room = roomOf[player]
	if not room then
		return
	end
	for n = 1, Config.ROOM_SLOTS do
		clearSlot(room, n)
		refreshSlotPrompt(room, n)
	end
	room.Owner = nil
	setPlate(room, "")
	roomOf[player] = nil
end

-- ===== 抽選 =====
local function roll(weights): any
	local total = 0
	for _, w in weights do
		total += w
	end
	local r = math.random() * total
	local acc = 0
	for rarity, w in weights do
		acc += w
		if r <= acc then
			local pool = byRarity[rarity]
			return pool[math.random(#pool)]
		end
	end
	return byRarity.N[1]
end

local function rarityWeights()
	local w = {}
	for r, info in Config.RARITY do
		w[r] = info.weight
	end
	return w
end

local function award(player: Player, c, how: string)
	local isNew = Inventory.give(player, c.id)
	tell(player, "got", { id = c.id, isNew = isNew, how = how })
	if c.rarity == "UR" then
		tellAll("ur", player.DisplayName .. " が " .. c.name .. " を当てた！  " .. player.DisplayName .. " got " .. c.nameEn .. "!")
	end
end

-- ===== ガチャ・クレーンの長押し =====
for _, g in street.Gachas do
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "ガチャガチャ / Gacha"
	prompt.ActionText = "まわす ¥" .. Config.GACHA_PRICE .. " / Turn"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = g.Knob
	prompt.Triggered:Connect(function(player)
		if not Inventory.spend(player, Config.GACHA_PRICE) then
			tell(player, "msg", "コインが足りない（¥" .. Config.GACHA_PRICE .. "）  Not enough coins")
			return
		end
		local c = roll(rarityWeights())
		-- ハンドルを回す（見た目）
		task.spawn(function()
			for i = 1, 12 do
				g.Knob.CFrame = g.Knob.CFrame * CFrame.Angles(math.pi / 6, 0, 0)
				task.wait(0.05)
			end
		end)
		award(player, c, "gacha")
	end)
end

do
	local panel = street.Claw:FindFirstChild("Panel")
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "クレーンゲーム / Claw"
	prompt.ActionText = "あそぶ ¥" .. Config.CLAW_PRICE .. " / Play"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = panel
	prompt.Triggered:Connect(function(player)
		if Inventory.get(player).coins < Config.CLAW_PRICE then
			tell(player, "msg", "コインが足りない（¥" .. Config.CLAW_PRICE .. "）  Not enough coins")
			return
		end
		tell(player, "claw_start", nil) -- 画面でバーを止めてもらう
	end)
end

-- ===== 画面からの頼み =====
request.OnServerEvent:Connect(function(player, kind: string, a: any, b: any)
	local d = Inventory.get(player)
	if not d then
		return
	end
	if kind == "claw_stop" then
		-- a = 中心からのずれ（0〜1）
		local off = math.clamp(tonumber(a) or 1, 0, 1)
		if not Inventory.spend(player, Config.CLAW_PRICE) then
			return
		end
		if off <= Config.CLAW_GOOD then
			award(player, roll(Config.CLAW_RARITY_WEIGHTS_GOOD), "claw")
		elseif off <= Config.CLAW_OK then
			award(player, byRarity.N[math.random(#byRarity.N)], "claw")
		else
			tell(player, "claw_miss", nil)
		end
	elseif kind == "place" then
		-- a = たなの番号, b = キャラ id
		local room = roomOf[player]
		local n = tonumber(a)
		if not room or not n or not room.Slots[n] or not byId[b] then
			return
		end
		if room.Slots[n].Id then
			return
		end
		if Inventory.free(player, b) < 1 then
			tell(player, "msg", "その子はもう全部飾ってある  All of those are already displayed")
			return
		end
		d.placed[tostring(n)] = b
		fillSlot(room, n, b)
		refreshSlotPrompt(room, n)
		tell(player, "placed", byId[b].name)
	elseif kind == "sell" then
		local c = byId[a]
		if c and Inventory.sell(player, a, Config.SELL_PRICE[c.rarity]) then
			tell(player, "msg", c.name .. " をおかえしして ¥" .. Config.SELL_PRICE[c.rarity] .. "  Returned for coins")
			tell(player, "inventory", Inventory.snapshot(player))
		else
			tell(player, "msg", "さいごの 1 体は おかえしできない  Keep at least one")
		end
	elseif kind == "tutorialDone" then
		player:SetAttribute("TutorialSeen", true)
	end
end)

getInventory.OnServerInvoke = function(player)
	local d = Inventory.get(player)
	return d and Inventory.snapshot(player) or nil
end

-- ===== コインの時間収入 =====
local acc: { [Player]: number } = {}
RunService.Heartbeat:Connect(function(dt)
	for _, player in Players:GetPlayers() do
		local d = Inventory.get(player)
		if d then
			local placedN = 0
			for _ in d.placed do
				placedN += 1
			end
			local rate = Config.INCOME_BASE + Config.INCOME_PER_DISPLAY * placedN
			player:SetAttribute("Income", rate)
			acc[player] = (acc[player] or 0) + rate * dt
			if acc[player] >= 1 then
				local whole = math.floor(acc[player])
				acc[player] -= whole
				Inventory.addCoins(player, whole)
			end
		end
	end
end)

-- ===== 入退室 =====
local function onJoin(player: Player)
	local d, bonus = Inventory.load(player)
	local room = assignRoom(player)
	if room then
		for slotStr, id in d.placed do
			local n = tonumber(slotStr)
			if n and room.Slots[n] and byId[id] then
				fillSlot(room, n, id)
				refreshSlotPrompt(room, n)
			end
		end
	end
	if bonus > 0 then
		tell(player, "daily", { bonus = bonus, streak = d.streak })
	end
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			root.CFrame = street.SpawnCFrame
		end
	end)
end

Players.PlayerAdded:Connect(onJoin)
for _, p in Players:GetPlayers() do
	task.spawn(onJoin, p)
end
Players.PlayerRemoving:Connect(function(player)
	Inventory.save(player)
	releaseRoom(player)
	Inventory.forget(player)
end)
task.spawn(function()
	while true do
		task.wait(Config.SAVE_EVERY)
		for _, p in Players:GetPlayers() do
			Inventory.save(p)
		end
	end
end)
game:BindToClose(function()
	for _, p in Players:GetPlayers() do
		Inventory.save(p)
	end
end)

-- Studio でのテスト用。公開版では作られない
if RunService:IsStudio() then
	local cheat = Instance.new("BindableEvent")
	cheat.Name = "Cheat"
	cheat.Parent = game:GetService("ServerStorage")
	cheat.Event:Connect(function(player: Player, kind: string, arg: any)
		if kind == "coins" then
			Inventory.addCoins(player, tonumber(arg) or 1000)
		elseif kind == "give" then
			award(player, byId[arg] or byRarity.N[1], "cheat")
		end
	end)
end
