-- 塔の中の画面: HP・やる気・階・円、ログ、持ち物、臨時売店、周の結果。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local event = ReplicatedStorage:WaitForChild("GameEvent")
local request = ReplicatedStorage:WaitForChild("GameRequest")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

local function corner(p: Instance, r: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
end
local function label(parent, size, pos, text, color, align, font)
	local t = Instance.new("TextLabel")
	t.Size = size
	t.Position = pos
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = font or Enum.Font.FredokaOne
	t.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	t.TextXAlignment = align or Enum.TextXAlignment.Left
	t.Text = text
	t.Parent = parent
	return t
end
local function button(parent, size, pos, text, color)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.BackgroundColor3 = color or Color3.fromRGB(60, 90, 150)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextScaled = true
	b.Font = Enum.Font.FredokaOne
	b.Text = text
	b.Parent = parent
	corner(b, 10)
	return b
end

local screen = Instance.new("ScreenGui")
screen.Name = "RunUI"
screen.ResetOnSpawn = false
screen.DisplayOrder = 7
screen.Enabled = false
screen.Parent = gui

-- ===== 左上: ステータス =====
local stat = Instance.new("Frame")
stat.Position = UDim2.fromOffset(12, 12)
stat.Size = UDim2.fromOffset(300, 118)
stat.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
stat.BackgroundTransparency = 0.15
stat.Parent = screen
corner(stat, 12)
local floorL = label(stat, UDim2.fromOffset(90, 40), UDim2.fromOffset(10, 4), "1F", Color3.fromRGB(255, 220, 120))
local lvL = label(stat, UDim2.fromOffset(190, 24), UDim2.fromOffset(100, 6), "Lv 1  攻 3  防 0", Color3.fromRGB(220, 225, 240))
local yenL = label(stat, UDim2.fromOffset(190, 22), UDim2.fromOffset(100, 28), "0 円", Color3.fromRGB(255, 220, 120))
local function bar(y, colorBg, colorFg, name)
	local bg = Instance.new("Frame")
	bg.Position = UDim2.fromOffset(10, y)
	bg.Size = UDim2.fromOffset(280, 20)
	bg.BackgroundColor3 = colorBg
	bg.BorderSizePixel = 0
	bg.Parent = stat
	corner(bg, 6)
	local fg = Instance.new("Frame")
	fg.Size = UDim2.fromScale(1, 1)
	fg.BackgroundColor3 = colorFg
	fg.BorderSizePixel = 0
	fg.Parent = bg
	corner(fg, 6)
	local t = label(bg, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), name, Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Center)
	t.TextStrokeTransparency = 0.4
	return fg, t
end
local hpBar, hpT = bar(52, Color3.fromRGB(70, 30, 30), Color3.fromRGB(90, 210, 110), "HP")
local hgBar, hgT = bar(78, Color3.fromRGB(50, 45, 30), Color3.fromRGB(255, 190, 70), "やる気")
local statusL = label(stat, UDim2.fromOffset(280, 18), UDim2.fromOffset(10, 100), "", Color3.fromRGB(255, 160, 160))

-- ===== 右上: ボタン =====
local btns = Instance.new("Frame")
btns.AnchorPoint = Vector2.new(1, 0)
btns.Position = UDim2.new(1, -12, 0, 60)
btns.Size = UDim2.fromOffset(150, 230)
btns.BackgroundTransparency = 1
btns.Parent = screen
local invBtn = button(btns, UDim2.fromOffset(150, 44), UDim2.fromOffset(0, 0), "持ち物  [I]", Color3.fromRGB(70, 110, 170))
local climbBtn = button(btns, UDim2.fromOffset(150, 44), UDim2.fromOffset(0, 50), "▲ のぼる  [E]", Color3.fromRGB(200, 150, 40))
climbBtn.Visible = false
local waitBtn = button(btns, UDim2.fromOffset(150, 44), UDim2.fromOffset(0, 100), "まつ  [Q]", Color3.fromRGB(80, 90, 110))
local shopBtn = button(btns, UDim2.fromOffset(150, 44), UDim2.fromOffset(0, 150), "売店", Color3.fromRGB(230, 120, 60))
shopBtn.Visible = false
local giveBtn = button(btns, UDim2.fromOffset(150, 30), UDim2.fromOffset(0, 200), "あきらめる", Color3.fromRGB(90, 50, 50))

-- ===== 下: ログ =====
local logF = Instance.new("Frame")
logF.AnchorPoint = Vector2.new(0.5, 1)
logF.Position = UDim2.new(0.5, 0, 1, -14)
logF.Size = UDim2.new(0.5, 0, 0, 110)
logF.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
logF.BackgroundTransparency = 0.25
logF.Parent = screen
corner(logF, 10)
local logLines = {}
for i = 1, 5 do
	local t = label(logF, UDim2.new(1, -16, 0, 20), UDim2.fromOffset(8, 4 + (i - 1) * 21), "", Color3.fromRGB(240, 240, 240), nil, Enum.Font.Gotham)
	t.TextScaled = false
	t.TextSize = 16
	t.TextTruncate = Enum.TextTruncate.AtEnd
	logLines[i] = t
end
local logBuf = {}
local function addLog(text)
	table.insert(logBuf, text)
	while #logBuf > 5 do
		table.remove(logBuf, 1)
	end
	for i = 1, 5 do
		logLines[i].Text = logBuf[i] or ""
		logLines[i].TextTransparency = 0.5 - (i / 5) * 0.5
	end
end

-- ===== 持ち物 =====
local inv = Instance.new("Frame")
inv.AnchorPoint = Vector2.new(0.5, 0.5)
inv.Position = UDim2.fromScale(0.5, 0.5)
inv.Size = UDim2.fromScale(0.92, 0.88)
local invLim = Instance.new("UISizeConstraint")
invLim.MaxSize = Vector2.new(560, 420)
invLim.Parent = inv
inv.BackgroundColor3 = Color3.fromRGB(250, 246, 238)
inv.Visible = false
inv.Parent = screen
corner(inv, 14)
local invStroke = Instance.new("UIStroke")
invStroke.Thickness = 4
invStroke.Color = Color3.fromRGB(70, 110, 170)
invStroke.Parent = inv
label(inv, UDim2.fromOffset(300, 36), UDim2.fromOffset(16, 8), "持ち物  Items", Color3.fromRGB(50, 60, 90))
local invCount = label(inv, UDim2.fromOffset(200, 24), UDim2.fromOffset(300, 14), "", Color3.fromRGB(100, 100, 110), Enum.TextXAlignment.Right)
local invClose = button(inv, UDim2.fromOffset(36, 36), UDim2.new(1, -46, 0, 8), "×", Color3.fromRGB(200, 80, 80))
local invList = Instance.new("ScrollingFrame")
invList.Position = UDim2.fromOffset(12, 52)
invList.Size = UDim2.new(1, -24, 1, -64)
invList.BackgroundTransparency = 1
invList.ScrollBarThickness = 6
invList.AutomaticCanvasSize = Enum.AutomaticSize.Y
invList.CanvasSize = UDim2.new()
invList.Parent = inv
local invLayout = Instance.new("UIListLayout")
invLayout.Padding = UDim.new(0, 6)
invLayout.SortOrder = Enum.SortOrder.LayoutOrder
invLayout.Parent = invList

local snap = nil
local function sendAct(kind, a)
	if _G.DungeonSend then
		_G.DungeonSend(kind, a)
	else
		request:FireServer(kind, a)
	end
end

local function refreshInv()
	for _, c in invList:GetChildren() do
		if c:IsA("Frame") then
			c:Destroy()
		end
	end
	if not snap then
		return
	end
	invCount.Text = #snap.inv .. " / " .. Config.INVENTORY_MAX
	for i, it in snap.inv do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -8, 0, 58)
		row.BackgroundColor3 = it.equipped and Color3.fromRGB(230, 240, 255) or Color3.fromRGB(255, 255, 255)
		row.LayoutOrder = i
		row.Parent = invList
		corner(row, 8)
		local nameT = label(row, UDim2.fromOffset(260, 26), UDim2.fromOffset(10, 4), (it.equipped and "Ｅ " or "") .. it.name, Color3.fromRGB(40, 45, 60))
		local descT = label(row, UDim2.fromOffset(300, 20), UDim2.fromOffset(10, 32), it.desc, Color3.fromRGB(110, 110, 120), nil, Enum.Font.Gotham)
		descT.TextScaled = false
		descT.TextSize = 13
		local verb = "使う"
		if it.kind == "weapon" or it.kind == "armor" or it.kind == "acc" then
			verb = it.equipped and "はずす" or "装備"
		elseif it.kind == "food" then
			verb = "食べる"
		elseif it.kind == "drink" then
			verb = "飲む"
		elseif it.kind == "card" then
			verb = "読む"
		elseif it.kind == "calc" then
			verb = "振る"
		end
		local useB = button(row, UDim2.fromOffset(68, 40), UDim2.new(1, -230, 0, 9), verb, Color3.fromRGB(70, 150, 90))
		local throwB = button(row, UDim2.fromOffset(68, 40), UDim2.new(1, -156, 0, 9), "投げる", Color3.fromRGB(200, 130, 50))
		local dropB = button(row, UDim2.fromOffset(68, 40), UDim2.new(1, -82, 0, 9), "置く", Color3.fromRGB(120, 120, 130))
		useB.Activated:Connect(function()
			sendAct("use", i)
			inv.Visible = false
		end)
		throwB.Activated:Connect(function()
			sendAct("throw", i)
			inv.Visible = false
		end)
		dropB.Activated:Connect(function()
			sendAct("drop", i)
			inv.Visible = false
		end)
		if snap.shop and snap.shop.near then
			local sellB = button(row, UDim2.fromOffset(68, 40), UDim2.new(1, -304, 0, 9), "売る", Color3.fromRGB(180, 80, 120))
			sellB.Activated:Connect(function()
				sendAct("sell", i)
			end)
		end
	end
end

-- ===== 臨時売店 =====
local shop = Instance.new("Frame")
shop.AnchorPoint = Vector2.new(0.5, 0.5)
shop.Position = UDim2.fromScale(0.5, 0.5)
shop.Size = UDim2.fromScale(0.92, 0.88)
local shopLim = Instance.new("UISizeConstraint")
shopLim.MaxSize = Vector2.new(520, 400)
shopLim.Parent = shop
shop.BackgroundColor3 = Color3.fromRGB(255, 248, 235)
shop.Visible = false
shop.Parent = screen
corner(shop, 14)
local shopStroke = Instance.new("UIStroke")
shopStroke.Thickness = 4
shopStroke.Color = Color3.fromRGB(230, 120, 60)
shopStroke.Parent = shop
label(shop, UDim2.fromOffset(400, 36), UDim2.fromOffset(16, 8), "臨時売店  先輩ミサキ「売るなら持ち物から」", Color3.fromRGB(150, 80, 40))
local shopYen = label(shop, UDim2.fromOffset(200, 24), UDim2.fromOffset(16, 44), "", Color3.fromRGB(120, 90, 40))
local shopClose = button(shop, UDim2.fromOffset(36, 36), UDim2.new(1, -46, 0, 8), "×", Color3.fromRGB(200, 80, 80))
local shopList = Instance.new("ScrollingFrame")
shopList.Position = UDim2.fromOffset(12, 72)
shopList.Size = UDim2.new(1, -24, 1, -84)
shopList.BackgroundTransparency = 1
shopList.ScrollBarThickness = 6
shopList.AutomaticCanvasSize = Enum.AutomaticSize.Y
shopList.CanvasSize = UDim2.new()
shopList.Parent = shop
local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 6)
shopLayout.Parent = shopList

local function refreshShop()
	for _, c in shopList:GetChildren() do
		if c:IsA("Frame") then
			c:Destroy()
		end
	end
	if not snap or not snap.shop then
		return
	end
	shopYen.Text = "持っている円: " .. snap.yen
	for i, s in snap.shop.stock do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -8, 0, 54)
		row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		row.Parent = shopList
		corner(row, 8)
		label(row, UDim2.fromOffset(300, 26), UDim2.fromOffset(10, 4), s.name, Color3.fromRGB(40, 45, 60))
		local d = label(row, UDim2.fromOffset(320, 20), UDim2.fromOffset(10, 30), s.desc, Color3.fromRGB(110, 110, 120), nil, Enum.Font.Gotham)
		d.TextScaled = false
		d.TextSize = 13
		local b = button(row, UDim2.fromOffset(120, 38), UDim2.new(1, -130, 0, 8), s.price .. " 円", snap.yen >= s.price and Color3.fromRGB(70, 150, 90) or Color3.fromRGB(150, 150, 150))
		b.Activated:Connect(function()
			sendAct("buy", i)
		end)
	end
end

-- ===== 周の結果 =====
local result = Instance.new("Frame")
result.AnchorPoint = Vector2.new(0.5, 0.5)
result.Position = UDim2.fromScale(0.5, 0.5)
result.Size = UDim2.fromScale(0.92, 0.88)
local resultLim = Instance.new("UISizeConstraint")
resultLim.MaxSize = Vector2.new(520, 380)
resultLim.Parent = result
result.BackgroundColor3 = Color3.fromRGB(30, 34, 50)
result.Visible = false
result.Parent = screen
corner(result, 16)
local resStroke = Instance.new("UIStroke")
resStroke.Thickness = 4
resStroke.Color = Color3.fromRGB(255, 205, 60)
resStroke.Parent = result
local resTitle = label(result, UDim2.new(1, -32, 0, 50), UDim2.fromOffset(16, 14), "", Color3.fromRGB(255, 220, 120), Enum.TextXAlignment.Center)
local resBody = label(result, UDim2.new(1, -40, 0, 200), UDim2.fromOffset(20, 72), "", Color3.fromRGB(240, 240, 240), Enum.TextXAlignment.Left, Enum.Font.Gotham)
resBody.TextScaled = false
resBody.TextSize = 18
resBody.TextYAlignment = Enum.TextYAlignment.Top
resBody.TextWrapped = true
local resBtn = button(result, UDim2.fromOffset(220, 48), UDim2.new(0.5, -110, 1, -64), "オフィスへもどる", Color3.fromRGB(70, 150, 90))

-- ===== 更新 =====
local lastLogN = 0
local function apply(s)
	snap = s
	screen.Enabled = true
	stat.Visible = true
	btns.Visible = true
	logF.Visible = true
	if s.turn == 0 and #logBuf > 0 and s.events[1] and s.events[1].t == "floor" then
		logBuf = {}
	end
	floorL.Text = s.floor .. "F" .. (s.special == "exam" and " 試験" or s.special == "board" and " 役員会" or "")
	lvL.Text = string.format("Lv %d  攻 %d  防 %d", s.lv, s.atk, s.def)
	yenL.Text = s.yen .. " 円   行ける階 " .. s.floorCap .. "F"
	hpBar.Size = UDim2.fromScale(math.clamp(s.hp / s.hpMax, 0, 1), 1)
	hpT.Text = "HP " .. s.hp .. " / " .. s.hpMax
	hgBar.Size = UDim2.fromScale(math.clamp(s.hunger / s.hungerMax, 0, 1), 1)
	hgT.Text = "やる気 " .. s.hunger
	local st = {}
	if s.status.sleep > 0 then
		table.insert(st, "💤居眠り")
	end
	if s.status.confuse > 0 then
		table.insert(st, "😵寝不足")
	end
	if s.status.stress > 0 then
		table.insert(st, "😰ストレス")
	end
	if s.status.bold > 0 then
		table.insert(st, "🔥強気 " .. s.status.bold)
	end
	if s.hunger <= 0 then
		table.insert(st, "やる気ゼロ！")
	end
	statusL.Text = table.concat(st, "  ")
	climbBtn.Visible = s.onStairs
	shopBtn.Visible = s.shop ~= nil and s.shop.near
	for _, e in s.events do
		if e.t == "log" then
			addLog(e.text)
		end
	end
	if inv.Visible then
		refreshInv()
	end
	if shop.Visible then
		if s.shop and s.shop.near then
			refreshShop()
		else
			shop.Visible = false
		end
	end
end

-- テスト用（execute_luau から Fire できる）
local test = Instance.new("BindableEvent")
test.Name = "Test"
test.Parent = screen
test.Event:Connect(function(cmd)
	if cmd == "inv" then
		inv.Visible = true
		refreshInv()
	elseif cmd == "shop" then
		shop.Visible = true
		refreshShop()
	elseif cmd == "close" then
		inv.Visible = false
		shop.Visible = false
		if result.Visible then
			result.Visible = false
			screen.Enabled = false
		end
	end
end)

invBtn.Activated:Connect(function()
	inv.Visible = not inv.Visible
	shop.Visible = false
	if inv.Visible then
		refreshInv()
	end
end)
invClose.Activated:Connect(function()
	inv.Visible = false
end)
climbBtn.Activated:Connect(function()
	sendAct("climb")
end)
waitBtn.Activated:Connect(function()
	sendAct("wait")
end)
shopBtn.Activated:Connect(function()
	shop.Visible = not shop.Visible
	inv.Visible = false
	if shop.Visible then
		refreshShop()
	end
end)
shopClose.Activated:Connect(function()
	shop.Visible = false
end)
local giveConfirm = 0
giveBtn.Activated:Connect(function()
	if os.clock() - giveConfirm < 3 then
		sendAct("giveup")
		giveBtn.Text = "あきらめる"
	else
		giveConfirm = os.clock()
		giveBtn.Text = "本当に？ もう一度"
		task.delay(3, function()
			giveBtn.Text = "あきらめる"
		end)
	end
end)
resBtn.Activated:Connect(function()
	result.Visible = false
	screen.Enabled = false
end)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not screen.Enabled then
		return
	end
	if input.KeyCode == Enum.KeyCode.I then
		invBtn:Activate()
		inv.Visible = not inv.Visible
		if inv.Visible then
			refreshInv()
		end
	end
end)

event.OnClientEvent:Connect(function(kind, data)
	if kind == "run" then
		apply(data)
	elseif kind == "runEnd" then
		inv.Visible = false
		shop.Visible = false
		local r = data.result
		local title = r == "dead" and "倒れた…" or r == "cleared" and (data.daily and "本日の案件 クリア！" or "塔の頂上に到達！") or r == "cap" and "ランクの上限まで登った！" or "帰還！"
		resTitle.Text = title
		local lines = {
			"到達: " .. data.floor .. "F    倒した敵: " .. data.kills,
			r == "dead" and "持ち物と " .. data.yen .. " 円は失った…（ランクは残る）" or "持ち帰った: " .. data.yen .. " 円 と 持ち物ぜんぶ",
			"キャリア点 +" .. (data.pts or 0),
			"",
		}
		for _, l in data.story or {} do
			table.insert(lines, "「" .. l.text .. "」")
		end
		if data.newRank then
			table.insert(lines, "")
			table.insert(lines, "★ 昇進！ " .. Config.RANKS[data.newRank].title .. " になった")
		end
		resBody.Text = table.concat(lines, "\n")
		result.Visible = true
		screen.Enabled = true
		-- 結果の窓だけ残す（HUD は次の周まで消す）
		task.delay(1.0, function()
			stat.Visible = false
			btns.Visible = false
			logF.Visible = false
		end)
	end
end)
