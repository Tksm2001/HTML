-- お札を投げる。当たった人は 3 秒かかしになり、担いでいた物を落とす。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage.Shared.Config)
local Parts = require(script.Parent.Parts)

local Ofuda = {}

local lastThrow: { [Player]: number } = {}
local kakashiUntil: { [Player]: number } = {}
local onHit: (Player, Player) -> () = function() end

local folder = Instance.new("Folder")
folder.Name = "Ofuda"
folder.Parent = workspace

function Ofuda.onHit(fn)
	onHit = fn
end

function Ofuda.isKakashi(player: Player): boolean
	return os.clock() < (kakashiUntil[player] or 0)
end

-- かかしに変える: 体を消して、かかしの部品を被せ、その場に固定
function Ofuda.makeKakashi(player: Player)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or Ofuda.isKakashi(player) then
		return
	end
	kakashiUntil[player] = os.clock() + Config.KAKASHI_SECONDS
	player:SetAttribute("Kakashi", true)

	local hidden = {}
	local mikoshi = char:FindFirstChild("Mikoshi")
	for _, d in char:GetDescendants() do
		if (d:IsA("BasePart") or d:IsA("Decal")) and d.Transparency < 1 and not (mikoshi and d:IsDescendantOf(mikoshi)) then
			hidden[d] = d.Transparency
			d.Transparency = 1
		end
	end
	root.Anchored = true
	root.CFrame = CFrame.new(root.Position)

	local k = Instance.new("Model")
	k.Name = "Kakashi"
	local function weld(p: BasePart, off: CFrame)
		p.CFrame = root.CFrame * off
		p.Anchored = false
		p.CanCollide = false
		p.Massless = true
		local w = Instance.new("WeldConstraint")
		w.Part0 = root
		w.Part1 = p
		w.Parent = p
		p.Parent = k
	end
	weld(Parts.part({ Name = "Pole", Size = Vector3.new(0.4, 5.5, 0.4), Color = Color3.fromRGB(120, 85, 50), Material = Enum.Material.Wood }), CFrame.new(0, -0.3, 0))
	weld(Parts.part({ Name = "Arms", Size = Vector3.new(4.2, 0.35, 0.35), Color = Color3.fromRGB(120, 85, 50), Material = Enum.Material.Wood }), CFrame.new(0, 0.8, 0))
	weld(Parts.part({ Name = "Straw", Size = Vector3.new(2.0, 2.2, 1.2), Color = Color3.fromRGB(225, 195, 110), Material = Enum.Material.Grass }), CFrame.new(0, 0.2, 0))
	local head = Parts.part({ Name = "Head", Shape = Enum.PartType.Ball, Size = Vector3.new(1.7, 1.7, 1.7), Color = Color3.fromRGB(240, 220, 170), Material = Enum.Material.Fabric })
	weld(head, CFrame.new(0, 2.0, 0))
	-- 笠
	for i, rad in { 1.4, 1.0, 0.5 } do
		local hat = Parts.part({ Name = "Hat", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.25, rad * 2, rad * 2), Color = Color3.fromRGB(200, 170, 110) })
		weld(hat, CFrame.new(0, 2.7 + (i - 1) * 0.25, 0) * CFrame.Angles(0, 0, math.pi / 2))
	end
	-- 「×」の目
	for _, s in { -1, 1 } do
		for _, a in { 0.7, -0.7 } do
			local x = Parts.part({ Name = "EyeX", Size = Vector3.new(0.5, 0.1, 0.1), Color = Color3.fromRGB(40, 30, 30) })
			weld(x, CFrame.new(s * 0.4, 2.1, -0.8) * CFrame.Angles(0, 0, a))
		end
	end
	k.Parent = char

	task.delay(Config.KAKASHI_SECONDS, function()
		if k.Parent then
			k:Destroy()
		end
		for p, t in hidden do
			if p.Parent then
				p.Transparency = t
			end
		end
		if root.Parent then
			root.Anchored = false
		end
		player:SetAttribute("Kakashi", nil)
	end)
end

-- 投げる。direction は投げる向き（単位ベクトル）
function Ofuda.throw(player: Player, direction: Vector3)
	local now = os.clock()
	if now - (lastThrow[player] or 0) < Config.OFUDA_COOLDOWN or Ofuda.isKakashi(player) then
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return
	end
	lastThrow[player] = now
	if direction.Magnitude < 0.01 then
		direction = root.CFrame.LookVector
	end
	direction = Vector3.new(direction.X, direction.Y * 0.3, direction.Z).Unit

	local p = Parts.part({
		Name = "Ofuda",
		Size = Vector3.new(0.9, 1.6, 0.08),
		CFrame = CFrame.lookAt(root.Position + direction * 2 + Vector3.new(0, 1, 0), root.Position + direction * 10),
		Color = Color3.fromRGB(250, 245, 230),
		Anchored = true,
		CanCollide = false,
		Parent = folder,
	})
	Parts.sign(p, "封", Color3.fromRGB(200, 30, 30))
	local start = p.Position
	local travelled = 0
	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		if not p.Parent then
			conn:Disconnect()
			return
		end
		local step = direction * Config.OFUDA_SPEED * dt
		travelled += step.Magnitude
		p.CFrame = p.CFrame * CFrame.Angles(0, 0, dt * 12) + step
		-- 当たり判定: 他のプレイヤーの体の近く
		for _, other in Players:GetPlayers() do
			if other ~= player then
				local oc = other.Character
				local orp = oc and oc:FindFirstChild("HumanoidRootPart") :: BasePart?
				if orp and (orp.Position - p.Position).Magnitude < 3.2 then
					conn:Disconnect()
					p:Destroy()
					-- 先に担いでいた物を落とさせてから、かかしにする（妖怪まで透明にしないため）
					onHit(player, other)
					Ofuda.makeKakashi(other)
					return
				end
			end
		end
		if travelled > Config.OFUDA_RANGE then
			conn:Disconnect()
			p:Destroy()
		end
	end)
	Debris:AddItem(p, 3)
end

function Ofuda.forget(player: Player)
	lastThrow[player] = nil
	kakashiUntil[player] = nil
end

return Ofuda
