-- ラウンド進行、捕まえる、だるま化、救出、目入れ、モード切り替え。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage.Shared.Config)
local StageBuilder = require(script.Parent.StageBuilder)
local Daruma = require(script.Parent.Daruma)

local remote = Instance.new("RemoteEvent")
remote.Name = "GameEvent"
remote.Parent = ReplicatedStorage

local stage = StageBuilder.build()
local daruma = Daruma.new(stage)

local phase: "safe" | "look" | "ended" = "safe"
local lookStart = 0
local roundStart = os.clock()

-- 今のモード。数値は Config.MODES から引く
local modeName = "normal"
local M = Config.MODES.normal

-- 捕まっている人: [Player] = { mini = Part, base = CFrame, parts = {[BasePart]=number} }
local caught: { [Player]: any } = {}

local function broadcast(kind: string, data: any?)
	remote:FireAllClients(kind, data)
end

-- 振り向いている間: 見られている側を赤、安全な側を緑に光らせる
local function setHalfColors()
	for side, h in stage.Halves do
		if phase == "look" then
			if side == daruma.eyeSide then
				h.Transparency = 0.45
				h.Color = Color3.fromRGB(255, 50, 50)
			else
				h.Transparency = 0.7
				h.Color = Color3.fromRGB(60, 220, 90)
			end
		else
			h.Transparency = 1
		end
	end
end

-- 空と明かり。ふつう = 夕方、むずかしい = 夜
local atmosphere = Instance.new("Atmosphere")
atmosphere.Parent = Lighting
local function applyLighting()
	if modeName == "hard" then
		Lighting.ClockTime = 20.5
		Lighting.Brightness = 1
		Lighting.Ambient = Color3.fromRGB(40, 35, 60)
		Lighting.OutdoorAmbient = Color3.fromRGB(60, 55, 90)
		atmosphere.Density = 0.4
		atmosphere.Color = Color3.fromRGB(90, 80, 130)
		atmosphere.Decay = Color3.fromRGB(40, 30, 70)
	else
		Lighting.ClockTime = 16.4
		Lighting.Brightness = 2.2
		Lighting.Ambient = Color3.fromRGB(70, 60, 55)
		Lighting.OutdoorAmbient = Color3.fromRGB(140, 125, 115)
		atmosphere.Density = 0.3
		atmosphere.Color = Color3.fromRGB(255, 220, 190)
		atmosphere.Decay = Color3.fromRGB(200, 140, 110)
	end
	for _, l in stage.Lights do
		l.Brightness = modeName == "hard" and 3 or 1
	end
end

local function getRoot(player: Player): BasePart?
	local char = player.Character
	if not char then
		return nil
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return nil
	end
	return char:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function rescue(player: Player)
	local info = caught[player]
	if not info then
		return
	end
	caught[player] = nil
	if info.mini then
		info.mini:Destroy()
	end
	local char = player.Character
	if char then
		for p, t in info.parts do
			if p.Parent then
				p.Transparency = t
			end
		end
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			root.Anchored = false
		end
	end
	broadcast("rescued", player.Name)
end

-- 小さなだるまの部品（楕円体）を root に溶接する
local function miniPart(name: string, size: Vector3, color: Color3, parent: Instance, root: BasePart, offset: CFrame): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.CanCollide = false
	p.Massless = true
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	p.CFrame = root.CFrame * offset
	local w = Instance.new("WeldConstraint")
	w.Part0 = root
	w.Part1 = p
	w.Parent = p
	p.Parent = parent
	return p
end

local function catch(player: Player)
	if caught[player] then
		return
	end
	local char = player.Character
	local root = getRoot(player)
	if not char or not root then
		return
	end

	-- 体を消して、その場に固定
	local parts = {}
	for _, d in char:GetDescendants() do
		if d:IsA("BasePart") then
			parts[d] = d.Transparency
			d.Transparency = 1
		elseif d:IsA("Decal") then
			parts[d] = d.Transparency
			d.Transparency = 1
		end
	end
	root.Anchored = true
	-- 位置だけ残して、助けに来る仲間（スタート側）へ顔を向ける
	local base = CFrame.new(root.Position) * CFrame.Angles(0, math.pi, 0)
	root.CFrame = base

	-- 小さなだるまを被せる（目は両方白 = まだ目が入っていない）
	local mini = miniPart("MiniDaruma", Vector3.new(4.4, 5, 4.2), Color3.fromRGB(200, 25, 25), char, root, CFrame.new(0, -0.4, 0))
	miniPart("MiniFace", Vector3.new(2.8, 2.4, 1.2), Color3.fromRGB(250, 245, 235), mini, root, CFrame.new(0, 0.3, -1.65))
	for _, x in { -0.6, 0.6 } do
		miniPart("MiniBrow", Vector3.new(0.9, 0.22, 0.25), Color3.fromRGB(20, 20, 20), mini, root, CFrame.new(x, 1.15, -2.05) * CFrame.Angles(0, 0, x > 0 and 0.3 or -0.3))
	end

	-- 救出用の長押し
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "たすける / Rescue"
	prompt.ObjectText = player.DisplayName
	prompt.HoldDuration = Config.RESCUE_HOLD
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = mini
	prompt.Triggered:Connect(function(byPlayer)
		if byPlayer ~= player and not caught[byPlayer] then
			rescue(player)
		end
	end)

	caught[player] = { mini = mini, base = base, parts = parts, t0 = os.clock() }
	broadcast("caught", player.Name)
end

local function teleportAll()
	for _, player in Players:GetPlayers() do
		local root = getRoot(player)
		if root then
			root.CFrame = stage.SpawnCFrame * CFrame.new(math.random(-8, 8), 0, math.random(-4, 4))
		end
	end
end

local function resetRound()
	for player in caught do
		rescue(player)
	end
	daruma:reset()
	teleportAll()
	roundStart = os.clock()
	phase = "safe"
	setHalfColors()
	broadcast("round", nil)
end

local function endRound(winnerName: string?)
	if phase == "ended" then
		return
	end
	phase = "ended"
	setHalfColors()
	if winnerName then
		daruma:paintSecondEye()
		-- 完成した顔を見せる
		if not daruma.isLooking then
			daruma:turnToFace()
		end
		broadcast("win", winnerName)
	else
		broadcast("lose", nil)
	end
	task.wait(Config.END_WAIT)
	resetRound()
end

local function setMode(name: string)
	modeName = name
	M = Config.MODES[name]
	ReplicatedStorage:SetAttribute("Mode", name)
	applyLighting()
end
setMode("normal")

-- モード選びの台。選ぶと全員スタートに戻って、そのモードでやり直し
for name, stand in stage.ModeStands do
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = name == "hard" and "むずかしいで遊ぶ / Play HARD" or "ふつうで遊ぶ / Play NORMAL"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = stand
	prompt.Triggered:Connect(function()
		if name == modeName or phase == "ended" then
			return
		end
		setMode(name)
		resetRound()
		broadcast("mode", name)
	end)
end

-- 目入れの台座
do
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "目を入れる / Paint the eye"
	prompt.ObjectText = "だるま / Daruma"
	prompt.HoldDuration = Config.PAINT_HOLD
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = stage.Pedestal
	prompt.Triggered:Connect(function(byPlayer)
		if phase ~= "ended" and not caught[byPlayer] then
			task.spawn(endRound, byPlayer.Name)
		end
	end)
end

-- 毎フレーム: 見られている側で動いた人を捕まえる。だるま化した人を揺らす。
RunService.Heartbeat:Connect(function()
	local now = os.clock()
	if phase == "look" and now - lookStart > M.GRACE then
		for _, player in Players:GetPlayers() do
			if not caught[player] then
				local root = getRoot(player)
				if root and daruma:canSee(root.Position) then
					if root.AssemblyLinearVelocity.Magnitude > M.MOVE_THRESHOLD then
						catch(player)
					end
				end
			end
		end
	end
	for player, info in caught do
		local root = getRoot(player)
		if root then
			local t = now - info.t0
			root.CFrame = info.base * CFrame.Angles(0, 0, math.sin(t * 5) * 0.22)
		end
	end
	if phase ~= "ended" and now - roundStart > M.ROUND_TIME then
		task.spawn(endRound, nil)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	caught[player] = nil
end)
local function watchCharacter(player: Player)
	player.CharacterAdded:Connect(function()
		caught[player] = nil
	end)
end
Players.PlayerAdded:Connect(watchCharacter)
-- Studio では、このスクリプトより先に入室している場合がある
for _, player in Players:GetPlayers() do
	watchCharacter(player)
end

local function between(a: number, b: number): number
	return math.random() * (b - a) + a
end

-- だるまのリズム
task.spawn(function()
	while true do
		if phase == "ended" then
			task.wait(0.2)
			continue
		end
		phase = "safe"
		setHalfColors()
		broadcast("safe", nil)
		daruma:turnAway()
		-- むずかしい: ときどき、背を向けてすぐ振り向く
		if math.random() < M.QUICK_TURN_CHANCE then
			task.wait(between(0.6, 1.1))
		else
			task.wait(between(M.SAFE_MIN, M.SAFE_MAX))
		end
		if phase == "ended" then
			continue
		end
		daruma:turnToFace()
		-- 入れ替えの予告は、振り向いてから見せる（背中側では目が見えない）。予告中はまだ捕まえない
		local roll = math.random()
		if roll < M.EYE_SWAP_CHANCE then
			broadcast("wink", nil)
			daruma:wink(M.WINK_TIME)
			daruma:swapEye()
		elseif roll < M.EYE_SWAP_CHANCE + M.FAKE_WINK_CHANCE then
			-- 嘘のチカチカ: 入れ替えない
			broadcast("wink", nil)
			daruma:wink(M.WINK_TIME)
		end
		if phase == "ended" then
			continue
		end
		lookStart = os.clock()
		phase = "look"
		setHalfColors()
		broadcast("look", daruma.eyeSide)
		task.wait(between(M.LOOK_MIN, M.LOOK_MAX))
	end
end)
