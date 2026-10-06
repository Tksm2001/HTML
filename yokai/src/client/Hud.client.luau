-- 画面表示: お賽銭、収入、お知らせ、お札ボタン、結界ボタン。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local event = ReplicatedStorage:WaitForChild("GameEvent")
local request = ReplicatedStorage:WaitForChild("GameRequest")
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

-- お賽銭（左上）
local coins = Instance.new("TextLabel")
coins.Size = UDim2.fromScale(0.22, 0.07)
coins.Position = UDim2.fromScale(0.02, 0.03)
coins.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
coins.BackgroundTransparency = 0.25
coins.TextColor3 = Color3.fromRGB(255, 220, 120)
coins.TextScaled = true
coins.Font = Enum.Font.FredokaOne
coins.Parent = screen
corner(coins, 12)
local income = Instance.new("TextLabel")
income.Size = UDim2.fromScale(0.22, 0.04)
income.Position = UDim2.fromScale(0.02, 0.105)
income.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
income.BackgroundTransparency = 0.4
income.TextColor3 = Color3.fromRGB(200, 255, 200)
income.TextScaled = true
income.Font = Enum.Font.FredokaOne
income.Parent = screen
corner(income, 8)

local function updateCoins()
	coins.Text = "¥ " .. tostring(player:GetAttribute("Coins") or 0)
	income.Text = "+" .. tostring(player:GetAttribute("Income") or 0) .. " /秒  per sec"
end
updateCoins()
player:GetAttributeChangedSignal("Coins"):Connect(updateCoins)
player:GetAttributeChangedSignal("Income"):Connect(updateCoins)

-- お知らせ（上の真ん中）。数秒で消える
local banner = Instance.new("TextLabel")
banner.Size = UDim2.fromScale(0.56, 0.08)
banner.Position = UDim2.fromScale(0.22, 0.03)
banner.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
banner.BackgroundTransparency = 0.3
banner.TextColor3 = Color3.fromRGB(255, 255, 255)
banner.TextScaled = true
banner.TextWrapped = true
banner.Font = Enum.Font.FredokaOne
banner.Visible = false
banner.Parent = screen
corner(banner, 12)
local bannerCount = 0
local function show(text: string, color: Color3?, seconds: number?)
	bannerCount += 1
	local mine = bannerCount
	banner.Text = text
	banner.BackgroundColor3 = color or Color3.fromRGB(30, 25, 30)
	banner.Visible = true
	task.delay(seconds or 4, function()
		if bannerCount == mine then
			banner.Visible = false
		end
	end)
end

-- 担いでいる物（下の真ん中）
local carryLabel = Instance.new("TextLabel")
carryLabel.Size = UDim2.fromScale(0.4, 0.06)
carryLabel.Position = UDim2.fromScale(0.3, 0.86)
carryLabel.BackgroundColor3 = Color3.fromRGB(190, 40, 40)
carryLabel.BackgroundTransparency = 0.2
carryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
carryLabel.TextScaled = true
carryLabel.Font = Enum.Font.FredokaOne
carryLabel.Visible = false
carryLabel.Parent = screen
corner(carryLabel, 12)
local function updateCarry()
	local c = player:GetAttribute("Carrying")
	carryLabel.Visible = c ~= nil
	carryLabel.Text = c and ("担いでいる: " .. c .. "  Carrying") or ""
end
updateCarry()
player:GetAttributeChangedSignal("Carrying"):Connect(updateCarry)

-- ボタン（右下）: お札、結界
local function button(text: string, y: number, color: Color3): TextButton
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromScale(0.16, 0.07)
	b.Position = UDim2.fromScale(0.82, y)
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextScaled = true
	b.Font = Enum.Font.FredokaOne
	b.Text = text
	b.Parent = screen
	corner(b, 12)
	return b
end
-- スマホのジャンプボタン（右下）と重ならない高さに置く
local throwBtn = button(UserInputService.KeyboardEnabled and "お札を投げる [クリック]\nThrow ofuda" or "お札を投げる\nThrow ofuda", 0.52, Color3.fromRGB(200, 40, 50))
local lockBtn = button(UserInputService.KeyboardEnabled and "結界 [Q]\nBarrier" or "結界\nBarrier", 0.61, Color3.fromRGB(40, 110, 200))

throwBtn.Activated:Connect(function()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then
		request:FireServer("throw", root.CFrame.LookVector)
	end
end)
lockBtn.Activated:Connect(function()
	request:FireServer("lock")
end)

-- クリック／タップで、その方向にお札を投げる（ボタンの上は除く）
local mouse = player:GetMouse()
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not root then
			return
		end
		local target = mouse.Hit and mouse.Hit.Position or (root.Position + root.CFrame.LookVector * 10)
		local dir = (Vector3.new(target.X, root.Position.Y, target.Z) - root.Position)
		request:FireServer("throw", dir.Magnitude > 0.1 and dir.Unit or root.CFrame.LookVector)
	elseif input.KeyCode == Enum.KeyCode.Q then
		request:FireServer("lock")
	end
end)

-- サーバーからの合図
event.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "msg" then
		show(tostring(data))
	elseif kind == "bought" then
		show(tostring(data) .. " を買った！ 自分の神社の台座に置こう  Bought! Place it on your pedestal", Color3.fromRGB(40, 110, 60))
	elseif kind == "placed" then
		show(tostring(data) .. " を置いた。お賽銭が貯まる  Placed. Coins will flow", Color3.fromRGB(40, 110, 60))
	elseif kind == "stolen" then
		show(tostring(data), Color3.fromRGB(190, 40, 40), 6)
	elseif kind == "lost" then
		show(tostring(data) .. " を取られた…  You lost it", Color3.fromRGB(120, 30, 30), 5)
	elseif kind == "returned" then
		show(tostring(data) .. " が神社に戻ってきた  Came back home", Color3.fromRGB(40, 110, 200))
	elseif kind == "kakashi" then
		show("かかしにされた！  You're a scarecrow!", Color3.fromRGB(120, 30, 30), Config.KAKASHI_SECONDS)
	elseif kind == "locked" then
		show("結界をはった（" .. tostring(data) .. " 秒）  Barrier up", Color3.fromRGB(40, 110, 200))
	elseif kind == "offline" then
		show("留守のあいだに ¥" .. tostring(data) .. " 貯まっていた！  Earned while away", Color3.fromRGB(240, 180, 20), 6)
	end
end)
