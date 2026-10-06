-- 進行役。村を組み、人が入ったら神社を割り当て、買う・担ぐ・置く・盗む・お札・結界をつなぐ。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Village = require(script.Parent.Village)
local Parade = require(script.Parent.Parade)
local Shrines = require(script.Parent.Shrines)
local Carry = require(script.Parent.Carry)
local Economy = require(script.Parent.Economy)
local Ofuda = require(script.Parent.Ofuda)
local Designs = require(script.Parent.Yokai.Designs)

-- 画面への合図と、画面からの頼み
local event = Instance.new("RemoteEvent")
event.Name = "GameEvent"
event.Parent = ReplicatedStorage
local request = Instance.new("RemoteEvent")
request.Name = "GameRequest"
request.Parent = ReplicatedStorage

local function tell(player: Player, kind: string, data: any?)
	event:FireClient(player, kind, data)
end
local function tellAll(kind: string, data: any?)
	event:FireAllClients(kind, data)
end

local village = Village.build()
Shrines.init(village)
Parade.start()

local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
if spawnLocation then
	spawnLocation.Transparency = 1
	spawnLocation.Position = Vector3.new(0, 0.5, Config.PARADE_RADIUS + 10)
end

local attachPedestalPrompt -- 下で定義

-- ===== 妖怪を持ち主の神社に戻す =====
local function returnHome(entry)
	local owner = entry.owner
	local plot = owner and Shrines.plotOf(owner)
	if not plot then
		entry.yokai.model:Destroy()
		return
	end
	local ped, slot
	if entry.slot and plot.Pedestals[entry.slot] and plot.Pedestals[entry.slot].Yokai == nil then
		ped, slot = plot.Pedestals[entry.slot], entry.slot
	else
		ped, slot = Shrines.freePedestal(plot)
	end
	if not ped then
		entry.yokai.model:Destroy()
		return
	end
	Shrines.place(plot, slot, entry.yokai)
	attachPedestalPrompt(plot, slot)
	tell(owner, "returned", entry.yokai.def.name)
end

-- ===== 台座の長押し（担ぐ / 置く / 盗む） =====
attachPedestalPrompt = function(plot, slot: number)
	local ped = plot.Pedestals[slot]
	local old = ped.Part:FindFirstChildOfClass("ProximityPrompt")
	if old then
		old:Destroy()
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = ped.Part
	local function refresh()
		if ped.Yokai then
			prompt.ObjectText = ped.Yokai.def.name
			prompt.ActionText = "担ぐ / Carry"
			prompt.HoldDuration = Config.PICKUP_HOLD
		else
			prompt.ObjectText = "台座 / Pedestal"
			prompt.ActionText = "置く / Place"
			prompt.HoldDuration = 0.3
		end
	end
	refresh()
	ped.Refresh = refresh
	prompt.Triggered:Connect(function(player)
		local mine = plot.Owner == player
		if ped.Yokai then
			-- 担ぐ（よその神社なら盗む）
			if Carry.get(player) or Ofuda.isKakashi(player) then
				return
			end
			if not mine then
				if Shrines.isLocked(plot) then
					tell(player, "msg", "結界がはられている  The barrier is up")
					return
				end
				if Shrines.isProtected(plot) then
					tell(player, "msg", "この神社はまだ守られている  This shrine is still protected")
					return
				end
			end
			local y = Shrines.take(plot, slot)
			if Carry.give(player, y, plot.Owner, plot, slot) then
				refresh()
				if not mine then
					tell(player, "msg", "ぬすんだ！ 自分の鳥居まで走れ  Stolen! Run to your torii")
					if plot.Owner then
						tell(plot.Owner, "stolen", player.DisplayName .. " が " .. y.def.name .. " を担いで逃げた！  " .. player.DisplayName .. " grabbed your " .. y.def.nameEn .. "!")
					end
				end
			else
				Shrines.place(plot, slot, y)
			end
		else
			-- 置く（自分の神社だけ）
			local c = Carry.get(player)
			if not c then
				return
			end
			if not mine then
				tell(player, "msg", "自分の神社の台座に置こう  Place it on your own pedestal")
				return
			end
			if c.owner ~= player then
				tell(player, "msg", "まだ自分の物じゃない。鳥居をくぐろう  Not yours yet. Pass your torii")
				return
			end
			Carry.release(player)
			Shrines.place(plot, slot, c.yokai)
			refresh()
			tell(player, "placed", c.yokai.def.name)
		end
	end)
end

for _, plot in village.Plots do
	for s = 1, plot.PedestalCount do
		attachPedestalPrompt(plot, s)
	end
	-- 台座を増やす・結界の長押し（社の札）
	local up = Instance.new("ProximityPrompt")
	up.ObjectText = "社 / Shrine"
	up.ActionText = "台座を増やす / More pedestals"
	up.HoldDuration = 0.5
	up.MaxActivationDistance = 9
	up.RequiresLineOfSight = false
	up.Parent = plot.NamePlate
	up.Triggered:Connect(function(player)
		if plot.Owner ~= player then
			return
		end
		local u = Shrines.nextUpgrade(plot)
		if not u then
			tell(player, "msg", "台座はもう最大  Pedestals are maxed")
			return
		end
		if not Economy.spend(player, u.price) then
			tell(player, "msg", "お賽銭が足りない（¥" .. u.price .. "）  Not enough coins")
			return
		end
		Shrines.upgrade(plot)
		for s = 1, plot.PedestalCount do
			if not plot.Pedestals[s].Part:FindFirstChildOfClass("ProximityPrompt") then
				attachPedestalPrompt(plot, s)
			end
		end
		tell(player, "msg", "台座が " .. plot.PedestalCount .. " 個になった  Now " .. plot.PedestalCount .. " pedestals")
	end)
end

-- ===== 行列で買う =====
Parade.onBuy(function(player, w)
	if Carry.get(player) or Ofuda.isKakashi(player) then
		tell(player, "msg", "両手がふさがっている  Your hands are full")
		return false
	end
	if not Economy.spend(player, w.def.price) then
		tell(player, "msg", "お賽銭が足りない  Not enough coins")
		return false
	end
	local yokai = { def = w.def, gold = w.gold, model = w.model }
	if Carry.give(player, yokai, player, nil, nil) then
		tell(player, "bought", w.def.name)
		return true
	end
	Economy.add(player, w.def.price)
	return false
end)

-- ===== お札 =====
Ofuda.onHit(function(thrower, victim)
	Carry.drop(victim, returnHome)
	tell(victim, "kakashi", nil)
	tell(thrower, "msg", "当たった！  Hit!")
end)

-- ===== 画面からの頼み =====
request.OnServerEvent:Connect(function(player, kind: string, data: any)
	if kind == "throw" and typeof(data) == "Vector3" then
		Ofuda.throw(player, data)
	elseif kind == "lock" then
		local plot = Shrines.plotOf(player)
		if plot and Shrines.lock(plot) then
			tell(player, "locked", Config.LOCK_SECONDS)
		elseif plot then
			tell(player, "msg", "結界はまだ使えない（あと " .. math.ceil(plot.LockReadyAt - os.clock()) .. " 秒）  Barrier not ready")
		end
	elseif kind == "tutorialDone" then
		player:SetAttribute("TutorialSeen", true)
	end
end)

-- ===== 毎フレーム: 盗んだ物を自分の鳥居まで持ち帰ったら自分の物に。収入。 =====
local incomeAcc: { [Player]: number } = {}
RunService.Heartbeat:Connect(function(dt)
	for _, player in Players:GetPlayers() do
		local c = Carry.get(player)
		if c and c.owner ~= player then
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
			local myPlot = Shrines.plotOf(player)
			if root and myPlot and Village.isInside(myPlot, root.Position) then
				local from = c.owner
				c.owner = player
				c.fromPlot = nil
				c.fromSlot = nil
				tell(player, "msg", c.yokai.def.name .. " は自分の物になった！ 台座に置こう  It's yours now! Place it")
				if from then
					tell(from, "lost", c.yokai.def.name)
				end
			end
		end
		local plot = Shrines.plotOf(player)
		if plot then
			local inc = Shrines.income(plot)
			incomeAcc[player] = (incomeAcc[player] or 0) + inc * dt
			if incomeAcc[player] >= 1 then
				local whole = math.floor(incomeAcc[player])
				incomeAcc[player] -= whole
				Economy.add(player, whole)
			end
			player:SetAttribute("Income", inc)
		end
	end
end)

-- ===== 入退室と保存 =====
local function snapshot(player: Player)
	local plot = Shrines.plotOf(player)
	return {
		yokai = plot and Shrines.serialize(plot) or {},
		pedestals = plot and plot.PedestalCount or Config.PEDESTALS_START,
		income = plot and Shrines.income(plot) or 0,
		tutorial = player:GetAttribute("TutorialSeen") == true,
	}
end

local function onJoin(player: Player)
	local d = Economy.load(player)
	local plot = Shrines.assign(player)
	if plot and d.saved then
		-- 台座の数を戻し、妖怪を置き直す
		while plot.PedestalCount < (d.saved.pedestals or Config.PEDESTALS_START) do
			local before = plot.PedestalCount
			Shrines.upgrade(plot)
			if plot.PedestalCount == before then
				break
			end
		end
		for s = 1, plot.PedestalCount do
			attachPedestalPrompt(plot, s)
		end
		Shrines.restore(plot, d.saved.yokai or {}, Parade.byId)
		for s = 1, plot.PedestalCount do
			if plot.Pedestals[s].Refresh then
				plot.Pedestals[s].Refresh()
			end
		end
		player:SetAttribute("TutorialSeen", d.saved.tutorial == true)
	else
		player:SetAttribute("TutorialSeen", false)
	end
	if d.offline and d.offline > 0 then
		tell(player, "offline", d.offline)
	end
	player.CharacterAdded:Connect(function(char)
		-- 生まれ変わったら担いでいた物は持ち主に戻る
		Carry.forceReturn(player, returnHome)
		task.wait(0.5)
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			root.CFrame = CFrame.new(0, 4, Config.PARADE_RADIUS + 10)
		end
	end)
end

Players.PlayerAdded:Connect(onJoin)
for _, p in Players:GetPlayers() do
	task.spawn(onJoin, p)
end

Players.PlayerRemoving:Connect(function(player)
	Carry.forceReturn(player, returnHome)
	Economy.save(player, snapshot(player))
	Shrines.release(player)
	Economy.forget(player)
	Ofuda.forget(player)
end)

task.spawn(function()
	while true do
		task.wait(Config.SAVE_EVERY)
		for _, p in Players:GetPlayers() do
			Economy.save(p, snapshot(p))
		end
	end
end)

-- Studio でのテスト用: ServerStorage の Cheat を鳴らすとお賽銭が増える。公開版では動かない
if RunService:IsStudio() then
	local cheat = Instance.new("BindableEvent")
	cheat.Name = "Cheat"
	cheat.Parent = game:GetService("ServerStorage")
	cheat.Event:Connect(function(player: Player, amount: number)
		Economy.add(player, amount)
	end)
end

game:BindToClose(function()
	for _, p in Players:GetPlayers() do
		Economy.save(p, snapshot(p))
	end
end)
