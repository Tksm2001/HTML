-- 初めての人向けの「あそびかた」。最初の 1 回だけ自動で出る。左の「?」ボタンでいつでも見られる。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local tutorialDone = ReplicatedStorage:WaitForChild("TutorialDone")

local screen = Instance.new("ScreenGui")
screen.Name = "Tutorial"
screen.ResetOnSpawn = false
screen.DisplayOrder = 10
screen.Parent = player:WaitForChild("PlayerGui")

local function corner(parent: Instance, px: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px)
	c.Parent = parent
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
-- 小さいスマホでは画面いっぱい、パソコンでは下の MaxSize で止まる
panel.Size = UDim2.fromScale(0.92, 0.88)
panel.BackgroundColor3 = Color3.fromRGB(250, 245, 235)
panel.Visible = false
panel.Parent = screen
corner(panel, 18)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(760, 520)
limit.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 25, 25)
stroke.Thickness = 4
stroke.Parent = panel

local function text(parent: Instance, s: string, pos: UDim2, size: UDim2, color: Color3, maxSize: number): TextLabel
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

local title = text(panel, "あそびかた  How to play", UDim2.fromScale(0.05, 0.03), UDim2.fromScale(0.9, 0.12), Color3.fromRGB(200, 25, 25), 40)
title.TextXAlignment = Enum.TextXAlignment.Center

-- 色の印（床の色と同じ）と説明を 4 行
local rows = {
	{ Color3.fromRGB(40, 140, 60), "だるまが うしろを向いている間に すすもう\nMove while the Daruma looks away" },
	{ Color3.fromRGB(255, 50, 50), "ふりむいたら、赤い床（黒目の側）では うごくな！ 緑の側は うごいてOK\nWhen it turns: FREEZE on RED. GREEN is safe" },
	{ Color3.fromRGB(240, 200, 60), "黄色い台で長押しして 目を入れたら勝ち！\nHold on the yellow stand to paint the eye and win!" },
	{ Color3.fromRGB(200, 25, 25), "だるまにされたら 仲間に助けてもらうか「やりなおす」\nCaught? Ask a friend, or press Restart" },
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
ok.Name = "OK"
ok.AnchorPoint = Vector2.new(0.5, 0)
ok.Position = UDim2.fromScale(0.5, 0.85)
ok.Size = UDim2.fromScale(0.4, 0.11)
ok.BackgroundColor3 = Color3.fromRGB(200, 25, 25)
ok.TextColor3 = Color3.fromRGB(255, 255, 255)
ok.TextScaled = true
ok.Font = Enum.Font.FredokaOne
ok.Text = "わかった！  OK"
ok.Parent = panel
corner(ok, 12)

-- いつでも見られる「?」ボタン（画面の左端、まん中あたり）
local help = Instance.new("TextButton")
help.Name = "Help"
help.Position = UDim2.fromScale(0.01, 0.42)
help.Size = UDim2.fromOffset(44, 44)
help.BackgroundColor3 = Color3.fromRGB(200, 25, 25)
help.TextColor3 = Color3.fromRGB(255, 255, 255)
help.TextScaled = true
help.Font = Enum.Font.FredokaOne
help.Text = "?"
help.Parent = screen
corner(help, 22)

ok.Activated:Connect(function()
	panel.Visible = false
	tutorialDone:FireServer()
end)
help.Activated:Connect(function()
	panel.Visible = not panel.Visible
end)

-- 記録の読み込みを少し待って、まだ見ていなければ出す
local t0 = os.clock()
while player:GetAttribute("TutorialSeen") == nil and os.clock() - t0 < 10 do
	task.wait(0.2)
end
if player:GetAttribute("TutorialSeen") ~= true then
	panel.Visible = true
end
