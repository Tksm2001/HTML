-- オフィスの画面: キャリア表示、会話ウィンドウ、売店、ロッカー、持ち物、お知らせ。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Items = require(ReplicatedStorage.Shared.Items)
local Story = require(ReplicatedStorage.Shared.Story)
local event = ReplicatedStorage:WaitForChild("GameEvent")
local request = ReplicatedStorage:WaitForChild("GameRequest")
local getProfile = ReplicatedStorage:WaitForChild("GetProfile")
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
local function panel(name, w, h, strokeColor)
	local f = Instance.new("Frame")
	f.Name = name
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.fromScale(0.5, 0.5)
	f.Size = UDim2.fromScale(0.92, 0.88)
	f.BackgroundColor3 = Color3.fromRGB(250, 246, 238)
	f.Visible = false
	corner(f, 14)
	local lim = Instance.new("UISizeConstraint")
	lim.MaxSize = Vector2.new(w, h)
	lim.Parent = f
	local s = Instance.new("UIStroke")
	s.Thickness = 4
	s.Color = strokeColor
	s.Parent = f
	local close = button(f, UDim2.fromOffset(36, 36), UDim2.new(1, -46, 0, 8), "×", Color3.fromRGB(200, 80, 80))
	close.Activated:Connect(function()
		f.Visible = false
	end)
	local list = Instance.new("ScrollingFrame")
	list.Position = UDim2.fromOffset(12, 80)
	list.Size = UDim2.new(1, -24, 1, -92)
	list.BackgroundTransparency = 1
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = f
	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 6)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Parent = list
	return f, list
end
local function clearList(list)
	for _, c in list:GetChildren() do
		if c:IsA("Frame") then
			c:Destroy()
		end
	end
end
local function row(list, h, order)
	local r = Instance.new("Frame")
	r.Size = UDim2.new(1, -8, 0, h)
	r.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	r.LayoutOrder = order
	r.Parent = list
	corner(r, 8)
	return r
end

local screen = Instance.new("ScreenGui")
screen.Name = "OfficeUI"
screen.ResetOnSpawn = false
screen.DisplayOrder = 9
screen.Parent = gui

local profile = nil
local function inRun()
	return player:GetAttribute("InRun") == true
end

-- ===== 左上: キャリア =====
local career = Instance.new("Frame")
career.Position = UDim2.fromOffset(12, 12)
career.Size = UDim2.fromOffset(300, 96)
career.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
career.BackgroundTransparency = 0.15
career.Parent = screen
corner(career, 12)
local titleL = label(career, UDim2.fromOffset(280, 32), UDim2.fromOffset(10, 4), "インターン", Color3.fromRGB(255, 220, 120))
local ptsBg = Instance.new("Frame")
ptsBg.Position = UDim2.fromOffset(10, 40)
ptsBg.Size = UDim2.fromOffset(280, 16)
ptsBg.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
ptsBg.BorderSizePixel = 0
ptsBg.Parent = career
corner(ptsBg, 6)
local ptsFg = Instance.new("Frame")
ptsFg.Size = UDim2.fromScale(0, 1)
ptsFg.BackgroundColor3 = Color3.fromRGB(120, 200, 255)
ptsFg.BorderSizePixel = 0
ptsFg.Parent = ptsBg
corner(ptsFg, 6)
local ptsT = label(career, UDim2.fromOffset(280, 18), UDim2.fromOffset(10, 58), "", Color3.fromRGB(200, 210, 230), nil, Enum.Font.Gotham)
ptsT.TextScaled = false
ptsT.TextSize = 13
local yenT = label(career, UDim2.fromOffset(280, 18), UDim2.fromOffset(10, 76), "", Color3.fromRGB(255, 220, 120), nil, Enum.Font.Gotham)
yenT.TextScaled = false
yenT.TextSize = 14
local bagBtn = button(screen, UDim2.fromOffset(150, 40), UDim2.fromOffset(12, 116), "持ち物・装備", Color3.fromRGB(70, 110, 170))

local function refreshCareer()
	if not profile then
		return
	end
	titleL.Text = profile.title .. "  (" .. profile.titleEn .. ")"
	local r = profile.rank
	local base = Config.RANKS[r].points
	local nxt = profile.nextPoints
	local frac = nxt > base and math.clamp((profile.points - base) / (nxt - base), 0, 1) or 1
	ptsFg.Size = UDim2.fromScale(frac, 1)
	ptsT.Text = r < #Config.RANKS and string.format("キャリア %d / 次の昇進 %d 点   行ける階 %dF", profile.points, nxt, profile.floorCap) or string.format("キャリア %d 点   伝説（エンドレス塔）", profile.points)
	yenT.Text = string.format("%d 円   挑戦 %d 回   最高 %dF", profile.yen, profile.runs, profile.bestFloor)
end

-- ===== 会話 =====
local dlg = Instance.new("Frame")
dlg.AnchorPoint = Vector2.new(0.5, 1)
dlg.Position = UDim2.new(0.5, 0, 1, -30)
dlg.Size = UDim2.new(0.7, 0, 0, 150)
dlg.BackgroundColor3 = Color3.fromRGB(30, 34, 50)
dlg.Visible = false
dlg.Parent = screen
corner(dlg, 14)
local dlgStroke = Instance.new("UIStroke")
dlgStroke.Thickness = 3
dlgStroke.Color = Color3.fromRGB(255, 205, 60)
dlgStroke.Parent = dlg
local dlgLimit = Instance.new("UISizeConstraint")
dlgLimit.MaxSize = Vector2.new(760, 150)
dlgLimit.Parent = dlg
-- 顔絵（左）
local dlgFace = Instance.new("ImageLabel")
dlgFace.Size = UDim2.fromOffset(118, 118)
dlgFace.Position = UDim2.fromOffset(14, 16)
dlgFace.BackgroundColor3 = Color3.fromRGB(255, 248, 230)
dlgFace.BorderSizePixel = 0
dlgFace.ScaleType = Enum.ScaleType.Crop
dlgFace.Visible = false
dlgFace.Parent = dlg
corner(dlgFace, 12)
local dlgWho = label(dlg, UDim2.fromOffset(300, 30), UDim2.fromOffset(146, 10), "", Color3.fromRGB(255, 220, 120))
local dlgText = label(dlg, UDim2.new(1, -164, 0, 80), UDim2.fromOffset(146, 44), "", Color3.fromRGB(250, 250, 250), nil, Enum.Font.Gotham)
dlgText.TextScaled = false
dlgText.TextSize = 20
dlgText.TextWrapped = true
dlgText.TextYAlignment = Enum.TextYAlignment.Top
local dlgNext = label(dlg, UDim2.fromOffset(200, 22), UDim2.new(1, -216, 1, -28), "クリックで次へ ▶", Color3.fromRGB(180, 190, 220), Enum.TextXAlignment.Right, Enum.Font.Gotham)
dlgNext.TextScaled = false
dlgNext.TextSize = 14
local dlgBtn = Instance.new("TextButton")
dlgBtn.Size = UDim2.fromScale(1, 1)
dlgBtn.BackgroundTransparency = 1
dlgBtn.Text = ""
dlgBtn.Parent = dlg

local dlgQueue = {}
local dlgTag = nil
local typing = false
local function showLine()
	local l = dlgQueue[1]
	if not l then
		dlg.Visible = false
		if dlgTag == "intro" then
			request:FireServer("introDone")
		end
		dlgTag = nil
		return
	end
	dlg.Visible = true
	dlgWho.Text = Story.NAMES[l.who] or l.who
	local face = Story.PORTRAITS[l.who]
	if face and face ~= "" then
		dlgFace.Image = face
		dlgFace.Visible = true
		dlgWho.Position = UDim2.fromOffset(146, 10)
		dlgText.Position = UDim2.fromOffset(146, 44)
		dlgText.Size = UDim2.new(1, -164, 0, 80)
	else
		dlgFace.Visible = false
		dlgWho.Position = UDim2.fromOffset(18, 10)
		dlgText.Position = UDim2.fromOffset(18, 44)
		dlgText.Size = UDim2.new(1, -36, 0, 80)
	end
	typing = true
	task.spawn(function()
		local full = l.text
		for i = 1, #full do
			if dlgQueue[1] ~= l then
				return
			end
			dlgText.Text = string.sub(full, 1, i)
			-- 日本語はバイト数が多いので 3 バイトごと
			if i % 3 == 0 then
				task.wait(0.015)
			end
		end
		dlgText.Text = full
		typing = false
	end)
end
dlgBtn.Activated:Connect(function()
	if typing then
		typing = false
		dlgText.Text = dlgQueue[1] and dlgQueue[1].text or ""
		dlgQueue[1] = dlgQueue[1] and table.clone(dlgQueue[1]) -- 打ち込みを止める
		return
	end
	table.remove(dlgQueue, 1)
	showLine()
end)
local function startDialog(lines, tag)
	dlgQueue = table.clone(lines)
	dlgTag = tag
	showLine()
end

-- ===== 売店（オフィス）=====
local shopF, shopList = panel("Shop", 600, 460, Color3.fromRGB(230, 120, 60))
shopF.Parent = screen
label(shopF, UDim2.fromOffset(400, 36), UDim2.fromOffset(16, 8), "売店  先輩ミサキ", Color3.fromRGB(150, 80, 40))
local shopSub = label(shopF, UDim2.fromOffset(500, 24), UDim2.fromOffset(16, 46), "", Color3.fromRGB(120, 90, 40), nil, Enum.Font.Gotham)
shopSub.TextScaled = false
shopSub.TextSize = 14

-- ランクごとの品ぞろえ
local STOCK_BY_RANK = {
	{ "onigiri", "bento", "coffee", "tea", "pen_cheap", "suit_cheap" },
	{ "card_return", "card_identify", "energy", "pen_steel", "suit_navy" },
	{ "calc_zap", "calc_sleep", "card_map", "card_sleep", "coffee_big" },
	{ "tie_red", "tie_blue", "card_upgrade", "calc_swap", "calc_blow", "pen_gold", "suit_tailor" },
	{ "tie_gold", "tie_green", "card_merge", "calc_shrink", "bento_big", "card_bonus" },
	{ "pen_legend", "suit_legend" },
	{},
}
local function refreshShop()
	clearList(shopList)
	if not profile then
		return
	end
	shopSub.Text = string.format("持っている円: %d    持ち物 %d / %d", profile.yen, #(profile.bag or {}), Config.INVENTORY_MAX)
	local order = 0
	for r = 1, profile.rank do
		for _, id in STOCK_BY_RANK[r] do
			local def = Items.BY_ID[id]
			order += 1
			local rw = row(shopList, 54, order)
			label(rw, UDim2.fromOffset(320, 26), UDim2.fromOffset(10, 4), def.name, Color3.fromRGB(40, 45, 60))
			local d = label(rw, UDim2.fromOffset(380, 20), UDim2.fromOffset(10, 30), def.desc, Color3.fromRGB(110, 110, 120), nil, Enum.Font.Gotham)
			d.TextScaled = false
			d.TextSize = 13
			local b = button(rw, UDim2.fromOffset(120, 38), UDim2.new(1, -130, 0, 8), def.price .. " 円", profile.yen >= def.price and Color3.fromRGB(70, 150, 90) or Color3.fromRGB(150, 150, 150))
			b.Activated:Connect(function()
				request:FireServer("shopBuy", id)
			end)
		end
	end
	if profile.rank < #Config.RANKS then
		order += 1
		local rw = row(shopList, 36, order)
		rw.BackgroundColor3 = Color3.fromRGB(240, 235, 225)
		label(rw, UDim2.new(1, -20, 1, 0), UDim2.fromOffset(10, 0), "…昇進すると品ぞろえが増える", Color3.fromRGB(130, 120, 110), Enum.TextXAlignment.Center)
	end
end

-- ===== 持ち物（オフィス）=====
local bagF, bagList = panel("Bag", 600, 460, Color3.fromRGB(70, 110, 170))
bagF.Parent = screen
label(bagF, UDim2.fromOffset(400, 36), UDim2.fromOffset(16, 8), "持ち物・装備（塔に持っていく）", Color3.fromRGB(50, 60, 90))
local bagSub = label(bagF, UDim2.fromOffset(500, 24), UDim2.fromOffset(16, 46), "", Color3.fromRGB(100, 100, 110), nil, Enum.Font.Gotham)
bagSub.TextScaled = false
bagSub.TextSize = 14
local function instName(inst)
	return Items.displayName(inst, nil, nil)
end
local function refreshBag()
	clearList(bagList)
	if not profile then
		return
	end
	local bag = profile.bag or {}
	bagSub.Text = string.format("%d / %d    Ｅ = 装備中。倒れると持ち物は全部なくなる（ロッカーの中は残る）", #bag, Config.INVENTORY_MAX)
	for i, inst in bag do
		local def = Items.BY_ID[inst.id]
		local rw = row(bagList, 54, i)
		rw.BackgroundColor3 = inst.equipped and Color3.fromRGB(230, 240, 255) or Color3.fromRGB(255, 255, 255)
		label(rw, UDim2.fromOffset(300, 26), UDim2.fromOffset(10, 4), (inst.equipped and "Ｅ " or "") .. instName(inst), Color3.fromRGB(40, 45, 60))
		local d = label(rw, UDim2.fromOffset(380, 20), UDim2.fromOffset(10, 30), def.desc, Color3.fromRGB(110, 110, 120), nil, Enum.Font.Gotham)
		d.TextScaled = false
		d.TextSize = 13
		if def.kind == "weapon" or def.kind == "armor" or def.kind == "acc" then
			local b = button(rw, UDim2.fromOffset(90, 38), UDim2.new(1, -200, 0, 8), inst.equipped and "はずす" or "装備", Color3.fromRGB(70, 150, 90))
			b.Activated:Connect(function()
				request:FireServer("bagEquip", i)
			end)
		end
		local price = math.floor(def.price * 0.4) + (inst.plus or 0) * 100
		local s = button(rw, UDim2.fromOffset(100, 38), UDim2.new(1, -106, 0, 8), "売る " .. price, Color3.fromRGB(180, 80, 120))
		s.Activated:Connect(function()
			request:FireServer("shopSell", i)
		end)
	end
end

-- ===== ロッカー =====
local lockF, lockList = panel("Locker", 600, 460, Color3.fromRGB(90, 110, 150))
lockF.Parent = screen
label(lockF, UDim2.fromOffset(400, 36), UDim2.fromOffset(16, 8), "ロッカー（倒れても残る）", Color3.fromRGB(50, 60, 90))
local lockSub = label(lockF, UDim2.fromOffset(500, 24), UDim2.fromOffset(16, 46), "", Color3.fromRGB(100, 100, 110), nil, Enum.Font.Gotham)
lockSub.TextScaled = false
lockSub.TextSize = 14
local function refreshLocker()
	clearList(lockList)
	if not profile then
		return
	end
	lockSub.Text = string.format("ロッカー %d / %d 枠（ランクが上がると増える）", #profile.locker, profile.lockerSlots)
	local order = 0
	for i, inst in profile.locker do
		order += 1
		local rw = row(lockList, 46, order)
		rw.BackgroundColor3 = Color3.fromRGB(230, 235, 245)
		label(rw, UDim2.fromOffset(340, 26), UDim2.fromOffset(10, 10), "🔒 " .. instName(inst), Color3.fromRGB(40, 45, 60))
		local b = button(rw, UDim2.fromOffset(110, 34), UDim2.new(1, -120, 0, 6), "取り出す", Color3.fromRGB(70, 150, 90))
		b.Activated:Connect(function()
			request:FireServer("lockerTake", i)
		end)
	end
	order += 1
	local hd = row(lockList, 30, order)
	hd.BackgroundColor3 = Color3.fromRGB(240, 235, 225)
	label(hd, UDim2.new(1, -20, 1, 0), UDim2.fromOffset(10, 0), "▼ 持ち物から預ける", Color3.fromRGB(100, 90, 80))
	for i, inst in profile.bag or {} do
		order += 1
		local rw = row(lockList, 46, order)
		label(rw, UDim2.fromOffset(340, 26), UDim2.fromOffset(10, 10), instName(inst), Color3.fromRGB(40, 45, 60))
		local b = button(rw, UDim2.fromOffset(110, 34), UDim2.new(1, -120, 0, 6), "預ける", Color3.fromRGB(90, 110, 150))
		b.Activated:Connect(function()
			request:FireServer("lockerPut", i)
		end)
	end
end

-- ===== お知らせ =====
local toast = label(screen, UDim2.new(0.6, 0, 0, 40), UDim2.new(0.2, 0, 0, 20), "", Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Center)
toast.TextStrokeTransparency = 0.3
toast.Visible = false
local function showToast(text)
	toast.Text = text
	toast.Visible = true
	toast.TextTransparency = 0
	task.delay(2, function()
		if toast.Text == text then
			TweenService:Create(toast, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		end
	end)
end

-- テスト用（execute_luau から Fire できる）
local test = Instance.new("BindableEvent")
test.Name = "Test"
test.Parent = screen
test.Event:Connect(function(cmd)
	if cmd == "bag" then
		bagF.Visible = true
		refreshBag()
	elseif cmd == "locker" then
		lockF.Visible = true
		refreshLocker()
	elseif cmd == "shop" then
		shopF.Visible = true
		refreshShop()
	elseif cmd == "next" then
		dlgBtn:Activate()
		table.remove(dlgQueue, 1)
		showLine()
	elseif cmd == "close" then
		bagF.Visible = false
		lockF.Visible = false
		shopF.Visible = false
	end
end)

bagBtn.Activated:Connect(function()
	if inRun() then
		return
	end
	bagF.Visible = not bagF.Visible
	shopF.Visible = false
	lockF.Visible = false
	if bagF.Visible then
		refreshBag()
	end
end)

event.OnClientEvent:Connect(function(kind, data)
	if kind == "profile" then
		profile = data
		refreshCareer()
		if shopF.Visible then
			refreshShop()
		end
		if bagF.Visible then
			refreshBag()
		end
		if lockF.Visible then
			refreshLocker()
		end
	elseif kind == "dialog" then
		startDialog(data.lines, data.tag)
	elseif kind == "openShop" then
		profile = data
		shopF.Visible = true
		bagF.Visible = false
		lockF.Visible = false
		refreshShop()
	elseif kind == "openLocker" then
		profile = data
		lockF.Visible = true
		bagF.Visible = false
		shopF.Visible = false
		refreshLocker()
	elseif kind == "toast" then
		showToast(data)
	elseif kind == "run" then
		career.Visible = false
		bagBtn.Visible = false
		shopF.Visible = false
		bagF.Visible = false
		lockF.Visible = false
		dlg.Visible = false
	elseif kind == "runEnd" then
		task.delay(0.5, function()
			career.Visible = true
			bagBtn.Visible = true
		end)
	end
end)

-- 最初の 1 回: 部長があいさつ
task.delay(2, function()
	profile = getProfile:InvokeServer()
	refreshCareer()
	if player:GetAttribute("Intro") == false then
		startDialog(Story.INTRO, "intro")
	end
end)
