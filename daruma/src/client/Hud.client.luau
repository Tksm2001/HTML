-- 画面上部の状態表示。文字は最小限、色で伝える。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:WaitForChild("GameEvent")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

local screen = Instance.new("ScreenGui")
screen.Name = "Hud"
screen.ResetOnSpawn = false
screen.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(0.6, 0.1)
label.Position = UDim2.fromScale(0.2, 0.04)
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 0.35
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.FredokaOne
label.Text = ""
label.Parent = screen
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = label

-- 今のモード（右上の小さな札）
local badge = Instance.new("TextLabel")
badge.Name = "ModeBadge"
badge.Size = UDim2.fromScale(0.14, 0.05)
badge.Position = UDim2.fromScale(0.84, 0.05)
badge.TextColor3 = Color3.fromRGB(255, 255, 255)
badge.TextScaled = true
badge.Font = Enum.Font.FredokaOne
badge.Parent = screen
local badgeCorner = Instance.new("UICorner")
badgeCorner.CornerRadius = UDim.new(0, 8)
badgeCorner.Parent = badge

-- 今のステージ名（モードの札の下）
local stageLabel = Instance.new("TextLabel")
stageLabel.Name = "StageLabel"
stageLabel.Size = UDim2.fromScale(0.14, 0.035)
stageLabel.Position = UDim2.fromScale(0.84, 0.105)
stageLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
stageLabel.BackgroundTransparency = 0.4
stageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
stageLabel.TextScaled = true
stageLabel.Font = Enum.Font.FredokaOne
stageLabel.Parent = screen
local stageCorner = Instance.new("UICorner")
stageCorner.CornerRadius = UDim.new(0, 8)
stageCorner.Parent = stageLabel

local function updateBadge()
	local hard = ReplicatedStorage:GetAttribute("Mode") == "hard"
	badge.Text = hard and "むずかしい HARD" or "ふつう NORMAL"
	badge.BackgroundColor3 = hard and Color3.fromRGB(150, 20, 30) or Color3.fromRGB(40, 110, 60)
	stageLabel.Text = ReplicatedStorage:GetAttribute("StageName") or ""
end
updateBadge()
ReplicatedStorage:GetAttributeChangedSignal("Mode"):Connect(updateBadge)
ReplicatedStorage:GetAttributeChangedSignal("StageName"):Connect(updateBadge)

local function show(text: string, color: Color3)
	label.Text = text
	label.BackgroundColor3 = color
end

-- 捕まっている間は「仲間を待て」を出し続ける
local amCaught = false
player.CharacterAdded:Connect(function()
	amCaught = false
end)

remote.OnClientEvent:Connect(function(kind: string, data: any)
	if amCaught and (kind == "safe" or kind == "wink" or kind == "look") then
		return
	end
	if kind == "safe" then
		show("にげろ！  RUN!", Color3.fromRGB(30, 140, 60))
	elseif kind == "wink" then
		show("目が…？  The eye…?", Color3.fromRGB(200, 150, 20))
	elseif kind == "look" then
		show("黒目の側は うごくな！  Freeze on the RED side!", Color3.fromRGB(190, 30, 30))
	elseif kind == "caught" then
		if data == player.Name then
			amCaught = true
			show("だるまにされた！ 仲間を待て  You're a daruma! Wait for a friend", Color3.fromRGB(120, 30, 30))
		end
	elseif kind == "rescued" then
		if data == player.Name then
			amCaught = false
			show("たすかった！  Rescued!", Color3.fromRGB(30, 120, 180))
		end
	elseif kind == "win" then
		show(tostring(data) .. " が目を入れた！  painted the eye!", Color3.fromRGB(240, 180, 20))
	elseif kind == "lose" then
		show("時間切れ… だるまの勝ち  Time's up, Daruma wins", Color3.fromRGB(60, 60, 60))
	elseif kind == "round" then
		show("つぎのラウンド  Next round", Color3.fromRGB(80, 80, 80))
	elseif kind == "stage" then
		show("ステージ: " .. tostring(data), Color3.fromRGB(60, 60, 140))
	elseif kind == "mode" then
		if data == "hard" then
			show("むずかしいモード！ 夜のだるまは嘘をつく  HARD: the night Daruma lies", Color3.fromRGB(150, 20, 30))
		else
			show("ふつうモード  NORMAL", Color3.fromRGB(40, 110, 60))
		end
	end
end)
