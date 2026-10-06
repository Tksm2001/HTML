-- 画面表示: コイン、収入、お知らせ、図鑑ボタン。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local event = ReplicatedStorage:WaitForChild("GameEvent")
local player = Players.LocalPlayer

local screen = Instance.new("ScreenGui")
screen.Name = "Hud"
screen.ResetOnSpawn = false
screen.Parent = player:WaitForChild("PlayerGui")

local function corner(p: Instance, r: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
end

local coins = Instance.new("TextLabel")
coins.Size = UDim2.fromScale(0.22, 0.07)
coins.Position = UDim2.fromScale(0.02, 0.03)
coins.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
coins.BackgroundTransparency = 0.2
coins.TextColor3 = Color3.fromRGB(255, 225, 120)
coins.TextScaled = true
coins.Font = Enum.Font.FredokaOne
coins.Parent = screen
corner(coins, 12)
local income = Instance.new("TextLabel")
income.Size = UDim2.fromScale(0.22, 0.04)
income.Position = UDim2.fromScale(0.02, 0.105)
income.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
income.BackgroundTransparency = 0.35
income.TextColor3 = Color3.fromRGB(210, 255, 210)
income.TextScaled = true
income.Font = Enum.Font.FredokaOne
income.Parent = screen
corner(income, 8)
local function update()
	coins.Text = "¥ " .. tostring(player:GetAttribute("Coins") or 0)
	income.Text = "+" .. tostring(player:GetAttribute("Income") or 0) .. " /秒  かざると増える"
end
update()
player:GetAttributeChangedSignal("Coins"):Connect(update)
player:GetAttributeChangedSignal("Income"):Connect(update)

-- 図鑑ボタン（左下）。Collection の画面がこれを探して使う
local zukan = Instance.new("TextButton")
zukan.Name = "ZukanButton"
zukan.Size = UDim2.fromScale(0.16, 0.07)
zukan.Position = UDim2.fromScale(0.02, 0.6)
zukan.BackgroundColor3 = Color3.fromRGB(230, 90, 90)
zukan.TextColor3 = Color3.fromRGB(255, 255, 255)
zukan.TextScaled = true
zukan.Font = Enum.Font.FredokaOne
zukan.Text = "図鑑・もちもの\nCollection"
zukan.Parent = screen
corner(zukan, 12)

-- お知らせ
local banner = Instance.new("TextLabel")
banner.Name = "Banner"
banner.Size = UDim2.fromScale(0.56, 0.08)
banner.Position = UDim2.fromScale(0.22, 0.03)
banner.BackgroundColor3 = Color3.fromRGB(40, 30, 35)
banner.BackgroundTransparency = 0.25
banner.TextColor3 = Color3.fromRGB(255, 255, 255)
banner.TextScaled = true
banner.TextWrapped = true
banner.Font = Enum.Font.FredokaOne
banner.Visible = false
banner.Parent = screen
corner(banner, 12)
local count = 0
local function show(text: string, color: Color3?, seconds: number?)
	count += 1
	local mine = count
	banner.Text = text
	banner.BackgroundColor3 = color or Color3.fromRGB(40, 30, 35)
	banner.Visible = true
	task.delay(seconds or 4, function()
		if count == mine then
			banner.Visible = false
		end
	end)
end

event.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "msg" then
		show(tostring(data))
	elseif kind == "placed" then
		show(tostring(data) .. " をかざった！ コインが増えやすくなる  Displayed!", Color3.fromRGB(40, 120, 70))
	elseif kind == "ur" then
		show("✨ " .. tostring(data), Color3.fromRGB(200, 150, 20), 7)
	elseif kind == "daily" then
		show("おかえり！ " .. tostring(data.streak) .. " 日連続で ¥" .. tostring(data.bonus) .. " もらった  Daily bonus", Color3.fromRGB(230, 150, 30), 6)
	elseif kind == "claw_miss" then
		show("あーっ、おちた…  Missed!", Color3.fromRGB(120, 50, 60))
	elseif kind == "pick" then
		show("図鑑から かざる子を えらんでね  Pick one from your collection", Color3.fromRGB(40, 100, 180), 5)
	end
end)
