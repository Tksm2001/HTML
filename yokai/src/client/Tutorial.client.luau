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
panel.BackgroundColor3 = Color3.fromRGB(250, 245, 235)
panel.Visible = false
panel.Parent = screen
corner(panel, 18)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(760, 520)
limit.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 40, 50)
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

local title = text(panel, "あそびかた  How to play", UDim2.fromScale(0.05, 0.03), UDim2.fromScale(0.9, 0.12), Color3.fromRGB(200, 40, 50), 40)
title.TextXAlignment = Enum.TextXAlignment.Center

local rows = {
	{ Color3.fromRGB(255, 200, 70), "広場の行列から妖怪を買って、自分の神社の台座に置く → お賽銭が貯まる\nBuy a yokai from the parade, place it on your pedestal → coins flow" },
	{ Color3.fromRGB(200, 40, 50), "よその神社の妖怪を担いで、自分の鳥居まで走れば自分の物！\nCarry a yokai from another shrine through your torii to keep it!" },
	{ Color3.fromRGB(250, 245, 230), "クリックでお札を投げる。当たった泥棒は 3 秒かかしになる\nClick to throw an ofuda. A hit turns the thief into a scarecrow" },
	{ Color3.fromRGB(40, 110, 200), "Q で結界。60 秒だけ神社を閉められる\nPress Q for a barrier that closes your shrine for 60 s" },
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
ok.BackgroundColor3 = Color3.fromRGB(200, 40, 50)
ok.TextColor3 = Color3.fromRGB(255, 255, 255)
ok.TextScaled = true
ok.Font = Enum.Font.FredokaOne
ok.Text = "わかった！  OK"
ok.Parent = panel
corner(ok, 12)

local help = Instance.new("TextButton")
help.Position = UDim2.fromScale(0.01, 0.42)
help.Size = UDim2.fromOffset(44, 44)
help.BackgroundColor3 = Color3.fromRGB(200, 40, 50)
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
