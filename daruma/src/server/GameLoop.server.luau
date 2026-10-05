-- ラウンド進行、捕まえる、だるま化、救出、目入れ。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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

-- 捕まっている人: [Player] = { mini = Part, base = CFrame, parts = {[BasePart]=number} }
local caught: { [Player]: any } = {}

local function broadcast(kind: string, data: any?)
	remote:FireAllClients(kind, data)
end

local function setHalfColors()
	for side, h in stage.Halves do
		if phase == "look" and side == daruma.eyeSide then
			h.Transparency = 0.5
			h.Color = Color3.fromRGB(255, 60, 60)
		else
			h.Transparency = 1
		end
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
	local base = CFrame.new(root.Position) -- 回転は捨てて位置だけ

	-- 小さなだるまを被せる
	local mini = Instance.new("Part")
	mini.Name = "MiniDaruma"
	mini.Shape = Enum.PartType.Ball
	mini.Size = Vector3.new(4.5, 4.5, 4.5)
	mini.Color = Color3.fromRGB(200, 30, 30)
	mini.Material = Enum.Material.SmoothPlastic
	mini.CanCollide = false
	mini.Massless = true
	mini.Parent = char
	local face = Instance.new("Part")
	face.Name = "MiniFace"
	face.Shape = Enum.PartType.Ball
	face.Size = Vector3.new(2.6, 2.6, 2.6)
	face.Color = Color3.fromRGB(250, 240, 225)
	face.CanCollide = false
	face.Massless = true
	face.Parent = mini
	local w1 = Instance.new("Weld")
	w1.Part0 = root
	w1.Part1 = mini
	w1.C0 = CFrame.new(0, -0.5, 0)
	w1.Parent = mini
	local w2 = Instance.new("Weld")
	w2.Part0 = mini
	w2.Part1 = face
	w2.C0 = CFrame.new(0, 0.6, -1.3)
	w2.Parent = face

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
			root.CFrame = stage.SpawnCFrame * CFrame.new(math.random(-20, 20), 0, math.random(-6, 6))
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
	if phase == "look" and now - lookStart > Config.GRACE then
		for _, player in Players:GetPlayers() do
			if not caught[player] then
				local root = getRoot(player)
				if root and daruma:canSee(root.Position) then
					if root.AssemblyLinearVelocity.Magnitude > Config.MOVE_THRESHOLD then
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
	if phase ~= "ended" and now - roundStart > Config.ROUND_TIME then
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
		task.wait(math.random() * (Config.SAFE_MAX - Config.SAFE_MIN) + Config.SAFE_MIN)
		if phase == "ended" then
			continue
		end
		daruma:turnToFace()
		-- 入れ替えの予告は、振り向いてから見せる（背中側では目が見えない）。予告中はまだ捕まえない
		if math.random() < Config.EYE_SWAP_CHANCE then
			broadcast("wink", nil)
			daruma:wink()
			daruma:swapEye()
		end
		lookStart = os.clock()
		phase = "look"
		setHalfColors()
		broadcast("look", daruma.eyeSide)
		task.wait(math.random() * (Config.LOOK_MAX - Config.LOOK_MIN) + Config.LOOK_MIN)
	end
end)
