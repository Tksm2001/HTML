-- ガチャの結果の演出（カプセルがゆれて開く → 子が出てくる）と、クレーンゲームのバー。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Designs = require(ReplicatedStorage.Shared:WaitForChild("Chars"):WaitForChild("Designs"))
local event = ReplicatedStorage:WaitForChild("GameEvent")
local request = ReplicatedStorage:WaitForChild("GameRequest")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

local byId = Config.BY_ID

local function corner(p: Instance, r: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
end

local screen = Instance.new("ScreenGui")
screen.Name = "Gacha"
screen.ResetOnSpawn = false
screen.DisplayOrder = 8
screen.Parent = gui

-- ===== 結果の画面 =====
local reveal = Instance.new("Frame")
reveal.AnchorPoint = Vector2.new(0.5, 0.5)
reveal.Position = UDim2.fromScale(0.5, 0.5)
reveal.Size = UDim2.fromScale(0.6, 0.8)
reveal.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
reveal.Visible = false
reveal.Parent = screen
corner(reveal, 20)
local rlimit = Instance.new("UISizeConstraint")
rlimit.MaxSize = Vector2.new(520, 560)
rlimit.Parent = reveal
local rstroke = Instance.new("UIStroke")
rstroke.Thickness = 5
rstroke.Parent = reveal

local vp = Instance.new("ViewportFrame")
vp.Size = UDim2.fromScale(1, 0.62)
vp.Position = UDim2.fromScale(0, 0.06)
vp.BackgroundTransparency = 1
vp.Ambient = Color3.fromRGB(200, 200, 210)
vp.LightColor = Color3.fromRGB(255, 250, 240)
vp.LightDirection = Vector3.new(-1, -1.5, -1)
vp.Parent = reveal
local world = Instance.new("WorldModel")
world.Parent = vp
local cam = Instance.new("Camera")
cam.FieldOfView = 40
cam.Parent = vp
vp.CurrentCamera = cam

local newBadge = Instance.new("TextLabel")
newBadge.Size = UDim2.fromScale(0.3, 0.1)
newBadge.Position = UDim2.fromScale(0.04, 0.03)
newBadge.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
newBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
newBadge.TextScaled = true
newBadge.Font = Enum.Font.FredokaOne
newBadge.Text = "NEW!"
newBadge.Rotation = -8
newBadge.Parent = reveal
corner(newBadge, 10)

local nameL = Instance.new("TextLabel")
nameL.Size = UDim2.fromScale(0.9, 0.12)
nameL.Position = UDim2.fromScale(0.05, 0.68)
nameL.BackgroundTransparency = 1
nameL.TextScaled = true
nameL.Font = Enum.Font.FredokaOne
nameL.TextColor3 = Color3.fromRGB(60, 45, 40)
nameL.Parent = reveal
local rarL = Instance.new("TextLabel")
rarL.Size = UDim2.fromScale(0.9, 0.07)
rarL.Position = UDim2.fromScale(0.05, 0.8)
rarL.BackgroundTransparency = 1
rarL.TextScaled = true
rarL.Font = Enum.Font.FredokaOne
rarL.Parent = reveal
local ok = Instance.new("TextButton")
ok.AnchorPoint = Vector2.new(0.5, 0)
ok.Position = UDim2.fromScale(0.5, 0.88)
ok.Size = UDim2.fromScale(0.4, 0.09)
ok.BackgroundColor3 = Color3.fromRGB(230, 90, 90)
ok.TextColor3 = Color3.fromRGB(255, 255, 255)
ok.TextScaled = true
ok.Font = Enum.Font.FredokaOne
ok.Text = "やったー！  OK"
ok.Parent = reveal
corner(ok, 12)
ok.Activated:Connect(function()
	reveal.Visible = false
end)

local current: Model? = nil
local function showResult(data)
	local c = byId[data.id]
	if not c then
		return
	end
	for _, ch in world:GetChildren() do
		ch:Destroy()
	end
	local col = Config.RARITY[c.rarity].color
	rstroke.Color = col
	rarL.TextColor3 = col
	rarL.Text = Config.RARITY[c.rarity].name .. "  " .. Config.RARITY[c.rarity].nameEn
	nameL.Text = c.name .. "  " .. c.nameEn
	newBadge.Visible = data.isNew == true
	reveal.Visible = true
	-- カプセル（半分ずつ）がゆれて、ぱかっと開く
	local capTop = Instance.new("Part")
	capTop.Shape = Enum.PartType.Ball
	capTop.Size = Vector3.new(4.4, 4.4, 4.4)
	capTop.Color = col
	capTop.Material = Enum.Material.SmoothPlastic
	capTop.Anchored = true
	capTop.CFrame = CFrame.new(0, 2.2, 0)
	capTop.Parent = world
	local capBottom = capTop:Clone()
	capBottom.Color = Color3.fromRGB(250, 250, 250)
	capBottom.CFrame = CFrame.new(0, 2.0, 0)
	capBottom.Size = Vector3.new(4.3, 4.0, 4.3)
	capBottom.Parent = world
	cam.CFrame = CFrame.lookAt(Vector3.new(0, 2.8, -8.5), Vector3.new(0, 2.0, 0))
	-- ゆれる
	for i = 1, 10 do
		local a = math.sin(i * 1.3) * 0.25
		capTop.CFrame = CFrame.new(0, 2.2, 0) * CFrame.Angles(0, 0, a)
		capBottom.CFrame = CFrame.new(0, 2.0, 0) * CFrame.Angles(0, 0, a)
		task.wait(0.06)
	end
	-- 開く
	for i = 1, 12 do
		capTop.CFrame = CFrame.new(0, 2.2 + i * 0.35, 0) * CFrame.Angles(0, 0, -i * 0.12)
		capBottom.CFrame = CFrame.new(0, 2.0 - i * 0.12, 0)
		capTop.Transparency = i / 12
		capBottom.Transparency = i / 12
		task.wait(0.03)
	end
	capTop:Destroy()
	capBottom:Destroy()
	current = Designs.build(c.id, CFrame.new(), world)
end

event.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "got" then
		task.spawn(showResult, data)
	end
end)
RunService.RenderStepped:Connect(function(dt)
	if reveal.Visible and current and current.Parent then
		current:PivotTo(current:GetPivot() * CFrame.Angles(0, dt * 1.2, 0))
	end
end)

-- ===== クレーンゲームのバー =====
local claw = Instance.new("Frame")
claw.AnchorPoint = Vector2.new(0.5, 0.5)
claw.Position = UDim2.fromScale(0.5, 0.5)
claw.Size = UDim2.fromScale(0.6, 0.4)
claw.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
claw.Visible = false
claw.Parent = screen
corner(claw, 20)
local climit = Instance.new("UISizeConstraint")
climit.MaxSize = Vector2.new(520, 280)
climit.Parent = claw
local cstroke = Instance.new("UIStroke")
cstroke.Thickness = 5
cstroke.Color = Color3.fromRGB(255, 120, 150)
cstroke.Parent = claw
local ctitle = Instance.new("TextLabel")
ctitle.Size = UDim2.fromScale(0.9, 0.2)
ctitle.Position = UDim2.fromScale(0.05, 0.05)
ctitle.BackgroundTransparency = 1
ctitle.TextScaled = true
ctitle.Font = Enum.Font.FredokaOne
ctitle.TextColor3 = Color3.fromRGB(230, 90, 120)
ctitle.Text = "まん中で とめろ！  Stop in the middle!"
ctitle.Parent = claw
local track = Instance.new("Frame")
track.Size = UDim2.fromScale(0.86, 0.18)
track.Position = UDim2.fromScale(0.07, 0.36)
track.BackgroundColor3 = Color3.fromRGB(230, 225, 215)
track.Parent = claw
corner(track, 10)
local good = Instance.new("Frame")
good.Size = UDim2.fromScale(Config.CLAW_OK, 1)
good.Position = UDim2.fromScale(0.5 - Config.CLAW_OK / 2, 0)
good.BackgroundColor3 = Color3.fromRGB(180, 230, 180)
good.Parent = track
corner(good, 10)
local best = Instance.new("Frame")
best.Size = UDim2.fromScale(Config.CLAW_GOOD, 1)
best.Position = UDim2.fromScale(0.5 - Config.CLAW_GOOD / 2, 0)
best.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
best.Parent = track
corner(best, 10)
local marker = Instance.new("Frame")
marker.Size = UDim2.new(0, 10, 1.4, 0)
marker.Position = UDim2.fromScale(0, -0.2)
marker.AnchorPoint = Vector2.new(0.5, 0)
marker.BackgroundColor3 = Color3.fromRGB(230, 60, 80)
marker.Parent = track
corner(marker, 4)
local stopBtn = Instance.new("TextButton")
stopBtn.AnchorPoint = Vector2.new(0.5, 0)
stopBtn.Position = UDim2.fromScale(0.5, 0.64)
stopBtn.Size = UDim2.fromScale(0.5, 0.26)
stopBtn.BackgroundColor3 = Color3.fromRGB(230, 60, 80)
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextScaled = true
stopBtn.Font = Enum.Font.FredokaOne
stopBtn.Text = "とめる！  STOP"
stopBtn.Parent = claw
corner(stopBtn, 14)

local playing = false
local t0 = 0
local function stop()
	if not playing then
		return
	end
	playing = false
	local pos = marker.Position.X.Scale
	local off = math.abs(pos - 0.5) * 2
	claw.Visible = false
	request:FireServer("claw_stop", off)
end
stopBtn.Activated:Connect(stop)
UserInputService.InputBegan:Connect(function(input, processed)
	if playing and input.KeyCode == Enum.KeyCode.Space then
		stop()
	end
end)
RunService.RenderStepped:Connect(function()
	if playing then
		local t = (os.clock() - t0) * Config.CLAW_BAR_SPEED
		local x = (1 - math.cos(t * math.pi * 2)) / 2 -- 0〜1 を往復
		marker.Position = UDim2.fromScale(x, -0.2)
	end
end)
event.OnClientEvent:Connect(function(kind: string)
	if kind == "claw_start" then
		playing = true
		t0 = os.clock()
		claw.Visible = true
	end
end)
