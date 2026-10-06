-- 初めての人向けの「あそびかた」。最初の 1 回だけ出る。左の「?」でいつでも。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local request = ReplicatedStorage:WaitForChild("GameRequest")

local screen = Instance.new("ScreenGui")
screen.Name = "Tutorial"
screen.ResetOnSpawn = false
screen.DisplayOrder = 10
screen.Parent = player:WaitForChild("PlayerGui")

local function corner(p: Instance, r: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
end

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.92, 0.88)
panel.BackgroundColor3 = Color3.fromRGB(252, 246, 232)
panel.Visible = false
panel.Parent = screen
corner(panel, 18)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(760, 520)
limit.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(230, 90, 90)
stroke.Thickness = 4
stroke.Parent = panel

local function text(parent, s, pos, size, color, maxSize)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = pos
	t.Size = size
	t.Text = s
	t.TextColor3 = color
	t.TextScaled = true
	t.TextWrapped = true
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Font = Enum.Font.FredokaOne
	t.Parent = parent
	local c = Instance.new("UITextSizeConstraint")
	c.MaxTextSize = maxSize
	c.Parent = t
	return t
end

local title = text(panel, "あそびかた  How to play", UDim2.fromScale(0.05, 0.03), UDim2.fromScale(0.9, 0.12), Color3.fromRGB(230, 90, 90), 40)
title.TextXAlignment = Enum.TextXAlignment.Center

local rows = {
	{ Color3.fromRGB(230, 60, 60), "だがしやの前の ガチャガチャを まわそう（¥100）\nTurn the gacha in front of the candy shop (¥100)" },
	{ Color3.fromRGB(255, 120, 150), "ゲームコーナーの クレーンゲームは まん中で止めると レアが出やすい\nStop the claw bar in the middle for better odds" },
	{ Color3.fromRGB(190, 170, 130), "じぶんの へやの たなの前で「かざる」→ 図鑑から えらぶ。かざるとコインが増える\nDisplay friends on your shelf to earn more coins" },
	{ Color3.fromRGB(240, 180, 60), "ダブった子は 図鑑で「おかえし」してコインに。毎日来ると ボーナス！\nReturn duplicates for coins. Daily login bonus!" },
}
for i, row in rows do
	local y = 0.17 + (i - 1) * 0.165
	local chip = Instance.new("Frame")
	chip.BackgroundColor3 = row[1]
	chip.Position = UDim2.fromScale(0.05, y + 0.02)
	chip.Size = UDim2.fromScale(0.06, 0.1)
	chip.Parent = panel
	corner(chip, 8)
	text(panel, row[2], UDim2.fromScale(0.14, y), UDim2.fromScale(0.82, 0.14), Color3.fromRGB(40, 30, 25), 24)
end

local ok = Instance.new("TextButton")
ok.AnchorPoint = Vector2.new(0.5, 0)
ok.Position = UDim2.fromScale(0.5, 0.85)
ok.Size = UDim2.fromScale(0.4, 0.11)
ok.BackgroundColor3 = Color3.fromRGB(230, 90, 90)
ok.TextColor3 = Color3.fromRGB(255, 255, 255)
ok.TextScaled = true
ok.Font = Enum.Font.FredokaOne
ok.Text = "わかった！  OK"
ok.Parent = panel
corner(ok, 12)

local help = Instance.new("TextButton")
help.Position = UDim2.fromScale(0.01, 0.42)
help.Size = UDim2.fromOffset(44, 44)
help.BackgroundColor3 = Color3.fromRGB(230, 90, 90)
help.TextColor3 = Color3.fromRGB(255, 255, 255)
help.TextScaled = true
help.Font = Enum.Font.FredokaOne
help.Text = "?"
help.Parent = screen
corner(help, 22)

ok.Activated:Connect(function()
	panel.Visible = false
	request:FireServer("tutorialDone")
end)
help.Activated:Connect(function()
	panel.Visible = not panel.Visible
end)

local t0 = os.clock()
while player:GetAttribute("TutorialSeen") == nil and os.clock() - t0 < 10 do
	task.wait(0.2)
end
if player:GetAttribute("TutorialSeen") ~= true then
	panel.Visible = true
end
