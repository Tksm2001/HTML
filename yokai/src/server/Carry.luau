-- 担ぐ。妖怪を小さなおみこしに乗せて肩にかつぐ。落とす、戻る。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Parts = require(script.Parent.Parts)

local Carry = {}

-- [Player] = { yokai, mikoshi, owner(Player?), fromPlot, fromSlot }
local carrying: { [Player]: any } = {}
-- 落ちている妖怪: { yokai, model, owner, plot, slot, until }
local dropped = {}

local folder = Instance.new("Folder")
folder.Name = "Dropped"
folder.Parent = workspace

function Carry.get(player: Player)
	return carrying[player]
end

-- おみこし（担ぎ棒と屋根つきの小さな台）を作る
local function buildMikoshi(parent: Instance): Model
	local m = Instance.new("Model")
	m.Name = "Mikoshi"
	local base = Parts.part({ Name = "Base", Size = Vector3.new(3.2, 0.5, 3.2), Color = Color3.fromRGB(190, 40, 40), Material = Enum.Material.SmoothPlastic, Anchored = false, CanCollide = false, Massless = true, Parent = m })
	m.PrimaryPart = base
	for _, s in { -1, 1 } do
		local pole = Parts.part({ Name = "Pole", Shape = Enum.PartType.Cylinder, Size = Vector3.new(7, 0.35, 0.35), Color = Color3.fromRGB(230, 60, 60), Anchored = false, CanCollide = false, Massless = true, Parent = m })
		pole.CFrame = base.CFrame * CFrame.new(s * 1.3, -0.1, 0) * CFrame.Angles(0, math.pi / 2, 0)
	end
	for _, s in { -1, 1 } do
		for _, t in { -1, 1 } do
			local post = Parts.part({ Name = "Post", Size = Vector3.new(0.25, 3.2, 0.25), Color = Parts.GOLD, Material = Enum.Material.Metal, Anchored = false, CanCollide = false, Massless = true, Parent = m })
			post.CFrame = base.CFrame * CFrame.new(s * 1.35, 1.85, t * 1.35)
		end
	end
	for i, w in { 4.0, 3.2, 2.2 } do
		local roof = Parts.part({ Name = "Roof", Size = Vector3.new(w, 0.3, w), Color = Parts.GOLD, Material = Enum.Material.Metal, Anchored = false, CanCollide = false, Massless = true, Parent = m })
		roof.CFrame = base.CFrame * CFrame.new(0, 3.5 + (i - 1) * 0.35, 0)
	end
	local bird = Parts.part({ Name = "Phoenix", Shape = Enum.PartType.Ball, Size = Vector3.new(0.7, 0.7, 0.7), Color = Parts.GOLD, Material = Enum.Material.Metal, Anchored = false, CanCollide = false, Massless = true, Parent = m })
	bird.CFrame = base.CFrame * CFrame.new(0, 4.8, 0)
	-- 全部を台に溶接
	for _, p in m:GetChildren() do
		if p ~= base and p:IsA("BasePart") then
			local w = Instance.new("WeldConstraint")
			w.Part0 = base
			w.Part1 = p
			w.Parent = p
		end
	end
	m.Parent = parent
	return m
end

local function setYokaiPhysics(model: Model, anchored: boolean, massless: boolean)
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = anchored
			p.Massless = massless
		end
	end
end

-- 妖怪の部品をすべて芯（Root）に溶接する
local function weldYokai(model: Model)
	local root = model.PrimaryPart :: BasePart
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p ~= root and not p:FindFirstChildOfClass("WeldConstraint") then
			local w = Instance.new("WeldConstraint")
			w.Part0 = root
			w.Part1 = p
			w.Parent = p
		end
	end
end

-- 担がせる。owner = この妖怪の正式な持ち主（買った直後は player 自身）。helper = 一緒に担ぐ仲間（伝説以上）
function Carry.give(player: Player, yokai, owner: Player?, fromPlot, fromSlot, helper: Player?)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or carrying[player] then
		return false
	end
	local mikoshi = buildMikoshi(char)
	local base = mikoshi.PrimaryPart :: BasePart
	-- 肩の上、少し後ろ
	base.CFrame = root.CFrame * CFrame.new(0, 2.9, 0.3)
	local w = Instance.new("WeldConstraint")
	w.Part0 = root
	w.Part1 = base
	w.Parent = base

	local model = yokai.model
	model.Parent = char
	weldYokai(model)
	setYokaiPhysics(model, false, true)
	-- 妖怪をおみこしの台に乗せる（担ぐ人の方を向く = 前を向く）
	model:PivotTo(base.CFrame * CFrame.new(0, 0.25 + 1.8, 0) * CFrame.Angles(0, 0, 0))
	local yw = Instance.new("WeldConstraint")
	yw.Part0 = base
	yw.Part1 = model.PrimaryPart
	yw.Parent = model.PrimaryPart
	for _, p in model:GetDescendants() do
		if p:IsA("ProximityPrompt") or p:IsA("BillboardGui") then
			p:Destroy()
		end
	end

	hum.WalkSpeed = Config.CARRY_SPEED
	carrying[player] = { yokai = yokai, mikoshi = mikoshi, owner = owner or player, fromPlot = fromPlot, fromSlot = fromSlot, helper = helper }
	player:SetAttribute("Carrying", yokai.def.name)
	if helper then
		-- 仲間は後ろの担ぎ棒を持つ役。同じ速さにして、印を付ける
		local hc = helper.Character
		local hh = hc and hc:FindFirstChildOfClass("Humanoid")
		if hh then
			hh.WalkSpeed = Config.CARRY_SPEED
		end
		helper:SetAttribute("Helping", yokai.def.name)
		-- 2 人分の担ぎ棒（後ろに長く）
		for _, s in { -1, 1 } do
			local pole = Parts.part({ Name = "LongPole", Shape = Enum.PartType.Cylinder, Size = Vector3.new(5, 0.3, 0.3), Color = Color3.fromRGB(230, 60, 60), Anchored = false, CanCollide = false, Massless = true, Parent = mikoshi })
			pole.CFrame = base.CFrame * CFrame.new(s * 1.3, -0.1, 4) * CFrame.Angles(0, math.pi / 2, 0)
			local w = Instance.new("WeldConstraint")
			w.Part0 = base
			w.Part1 = pole
			w.Parent = pole
		end
	end
	return true
end

-- 仲間の役を外す
local function releaseHelper(c)
	local helper = c.helper
	if not helper then
		return
	end
	c.helper = nil
	helper:SetAttribute("Helping", nil)
	local hc = helper.Character
	local hh = hc and hc:FindFirstChildOfClass("Humanoid")
	if hh then
		hh.WalkSpeed = 16
	end
end

-- 担いでいる物を外す（置く・落とすの共通）。妖怪を返す
function Carry.release(player: Player)
	local c = carrying[player]
	if not c then
		return nil
	end
	carrying[player] = nil
	player:SetAttribute("Carrying", nil)
	releaseHelper(c)
	c.mikoshi:Destroy()
	local model = c.yokai.model
	for _, p in model:GetDescendants() do
		if p:IsA("WeldConstraint") then
			p:Destroy()
		end
	end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 16
	end
	return c
end

-- 落とす。10 秒たったら持ち主の神社に戻る
function Carry.drop(player: Player, onReturn)
	local c = Carry.release(player)
	if not c then
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local pos = root and root.Position or Vector3.new(0, 3, 0)
	local model = c.yokai.model
	model.Parent = folder
	setYokaiPhysics(model, true, false)
	model:PivotTo(CFrame.new(pos + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, math.random() * 6.28, 0))
	local entry = { yokai = c.yokai, owner = c.owner, plot = c.fromPlot, slot = c.fromSlot, untilTime = os.clock() + Config.DROP_RETURN_SECONDS }
	table.insert(dropped, entry)
	-- 落ちている間は誰でも拾える
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "ひろう / Pick up"
	prompt.ObjectText = c.yokai.def.name
	prompt.HoldDuration = Config.PICKUP_HOLD
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = model.PrimaryPart
	prompt.Triggered:Connect(function(byPlayer)
		local i = table.find(dropped, entry)
		if not i then
			return
		end
		if Carry.give(byPlayer, c.yokai, c.owner, c.fromPlot, c.fromSlot) then
			table.remove(dropped, i)
			prompt:Destroy()
		end
	end)
	task.delay(Config.DROP_RETURN_SECONDS, function()
		local i = table.find(dropped, entry)
		if i then
			table.remove(dropped, i)
			prompt:Destroy()
			onReturn(entry)
		end
	end)
end

-- 退出時など、担いでいる物を持ち主の神社に戻す
function Carry.forceReturn(player: Player, onReturn)
	local c = Carry.release(player)
	if c then
		onReturn({ yokai = c.yokai, owner = c.owner, plot = c.fromPlot, slot = c.fromSlot })
	end
end

return Carry
