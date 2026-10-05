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

local function show(text: string, color: Color3)
	label.Text = text
	label.BackgroundColor3 = color
end

remote.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "safe" then
		show("にげろ！  RUN!", Color3.fromRGB(30, 140, 60))
	elseif kind == "wink" then
		show("目が…？  The eye…?", Color3.fromRGB(200, 150, 20))
	elseif kind == "look" then
		show("赤い側は動くな！  FREEZE on red!", Color3.fromRGB(190, 30, 30))
	elseif kind == "caught" then
		if data == player.Name then
			show("だるまにされた！ 仲間を待て  You're a daruma! Wait for a friend", Color3.fromRGB(120, 30, 30))
		end
	elseif kind == "rescued" then
		if data == player.Name then
			show("たすかった！  Rescued!", Color3.fromRGB(30, 120, 180))
		end
	elseif kind == "win" then
		show(tostring(data) .. " が目を入れた！  painted the eye!", Color3.fromRGB(240, 180, 20))
	elseif kind == "lose" then
		show("時間切れ… だるまの勝ち  Time's up, Daruma wins", Color3.fromRGB(60, 60, 60))
	elseif kind == "round" then
		show("つぎのラウンド  Next round", Color3.fromRGB(80, 80, 80))
	end
end)
