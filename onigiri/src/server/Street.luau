-- もぐもぐ商店街をコードで組み立てる。Studio で手で置く物はゼロ。
-- 道は X 方向にまっすぐ。北側（+Z）にお店、南側（-Z）に 8 つの「へや」が並ぶアパート。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Parts = require(script.Parent.Parts)
local part, pillar, ball, sign = Parts.part, Parts.pillar, Parts.ball, Parts.sign
local BLACK, WOOD, GOLD = Parts.BLACK, Parts.WOOD, Parts.GOLD

local Street = {}

local STREET_LENGTH = 150
local ROAD_W = 14
local SHOP_Z = 7       -- お店の正面の Z
local ROOM_Z = -7      -- アパートの正面の Z
local ROOM_W, ROOM_D = 16, 14

local function textBoard(parent, cf, size, text, bg, fg)
	local b = part({ Name = "Sign", Size = size, CFrame = cf, Color = bg, Parent = parent })
	sign(b, text, fg, Enum.NormalId.Front)
	return b
end

-- のれん
local function noren(parent, cf, width, color, text)
	for i = 0, 2 do
		local x = -width / 2 + width / 6 + i * width / 3
		local n = part({ Name = "Noren", Size = Vector3.new(width / 3 - 0.2, 2.6, 0.08), CFrame = cf * CFrame.new(x, 0, 0), Color = color, Material = Enum.Material.Fabric, CanCollide = false, Parent = parent })
		if i == 1 and text then
			sign(n, text, Color3.fromRGB(255, 255, 255), Enum.NormalId.Front)
		end
	end
end

-- お店の建物（間口 w）。正面は -Z（道側）
local function shop(parent, x: number, w: number, color: Color3, name: string, norenColor: Color3?)
	local f = Parts.folder(parent, "Shop_" .. name)
	local d = 12
	local cz = SHOP_Z + d / 2
	part({ Name = "Floor", Size = Vector3.new(w, 0.6, d), CFrame = CFrame.new(x, 0.3, cz), Color = Color3.fromRGB(200, 190, 170), Material = Enum.Material.WoodPlanks, Parent = f })
	part({ Name = "Back", Size = Vector3.new(w, 9, 0.6), CFrame = CFrame.new(x, 4.5, cz + d / 2), Color = color, Parent = f })
	for _, s in { -1, 1 } do
		part({ Name = "Side", Size = Vector3.new(0.6, 9, d), CFrame = CFrame.new(x + s * w / 2, 4.5, cz), Color = color, Parent = f })
	end
	-- ひさし（瓦）
	part({ Name = "Eave", Size = Vector3.new(w + 1.5, 0.6, 4), CFrame = CFrame.new(x, 8.6, SHOP_Z + 1) * CFrame.Angles(0.2, 0, 0), Color = Color3.fromRGB(60, 65, 75), Material = Enum.Material.Slate, Parent = f })
	part({ Name = "Roof", Size = Vector3.new(w + 1, 0.8, d + 1), CFrame = CFrame.new(x, 9.3, cz), Color = Color3.fromRGB(70, 75, 85), Material = Enum.Material.Slate, Parent = f })
	-- 看板
	textBoard(f, CFrame.new(x, 7.4, SHOP_Z - 0.2) * CFrame.Angles(0, math.pi, 0), Vector3.new(w - 1, 1.8, 0.3), name, Color3.fromRGB(40, 35, 40), Color3.fromRGB(255, 240, 200))
	if norenColor then
		noren(f, CFrame.new(x, 5.5, SHOP_Z - 0.1) * CFrame.Angles(0, math.pi, 0), w - 2, norenColor, nil)
	end
	return f
end

-- ガチャガチャの筐体。前面が -Z
local function gachaMachine(parent, x: number, z: number, color: Color3, label: string)
	local f = Parts.folder(parent, "Gacha")
	part({ Name = "Base", Size = Vector3.new(2.6, 2.4, 2.4), CFrame = CFrame.new(x, 1.2, z), Color = color, Parent = f })
	part({ Name = "Panel", Size = Vector3.new(2.0, 1.0, 0.1), CFrame = CFrame.new(x, 1.5, z - 1.22), Color = Color3.fromRGB(250, 245, 235), Parent = f })
	local dome = ball(f, Vector3.new(x, 3.5, z), 2.6, Color3.fromRGB(200, 235, 255), Enum.Material.Glass, true)
	dome.Transparency = 0.45
	dome.Name = "Dome"
	-- 中のカプセル
	local rng = Random.new(math.floor(x * 10))
	local caps = { Color3.fromRGB(255, 90, 100), Color3.fromRGB(90, 170, 255), Color3.fromRGB(255, 210, 80), Color3.fromRGB(120, 220, 130), Color3.fromRGB(255, 255, 255) }
	for i = 1, 9 do
		local c = ball(f, Vector3.new(x + rng:NextNumber(-0.7, 0.7), 2.9 + rng:NextNumber(0, 1.0), z + rng:NextNumber(-0.7, 0.7)), 0.55, caps[i % #caps + 1])
		c.Name = "Capsule"
	end
	-- ハンドルと取り出し口
	local knob = part({ Name = "Knob", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 0.9, 0.9), CFrame = CFrame.new(x, 1.0, z - 1.35) * CFrame.Angles(0, math.pi / 2, 0), Color = Color3.fromRGB(80, 80, 85), Material = Enum.Material.Metal, Parent = f })
	part({ Name = "KnobBar", Size = Vector3.new(0.8, 0.18, 0.2), CFrame = CFrame.new(x, 1.0, z - 1.5), Color = Color3.fromRGB(60, 60, 65), Parent = f })
	part({ Name = "Outlet", Size = Vector3.new(1.0, 0.5, 0.1), CFrame = CFrame.new(x + 0.6, 0.45, z - 1.22), Color = BLACK, Parent = f })
	local lbl = textBoard(f, CFrame.new(x, 1.75, z - 1.26), Vector3.new(1.9, 0.5, 0.05), label, Color3.fromRGB(250, 245, 235), Color3.fromRGB(60, 40, 40))
	lbl.Name = "Label"
	return f, knob
end

-- クレーンゲームの筐体
local function clawMachine(parent, x: number, z: number)
	local f = Parts.folder(parent, "Claw")
	part({ Name = "Base", Size = Vector3.new(5, 2.2, 4), CFrame = CFrame.new(x, 1.1, z), Color = Color3.fromRGB(255, 120, 150), Parent = f })
	local g = part({ Name = "Glass", Size = Vector3.new(5, 4.6, 4), CFrame = CFrame.new(x, 4.5, z), Color = Color3.fromRGB(210, 240, 255), Material = Enum.Material.Glass, Parent = f })
	g.Transparency = 0.55
	part({ Name = "Top", Size = Vector3.new(5.4, 0.8, 4.4), CFrame = CFrame.new(x, 7.2, z), Color = Color3.fromRGB(255, 120, 150), Parent = f })
	textBoard(f, CFrame.new(x, 7.2, z - 2.25), Vector3.new(5, 0.7, 0.05), "クレーンゲーム  CLAW", Color3.fromRGB(255, 120, 150), Color3.fromRGB(255, 255, 255))
	-- クレーン
	part({ Name = "Rail", Size = Vector3.new(4.6, 0.2, 0.2), CFrame = CFrame.new(x, 6.6, z), Color = Color3.fromRGB(90, 90, 95), Material = Enum.Material.Metal, Parent = f })
	local arm = part({ Name = "Arm", Size = Vector3.new(0.15, 1.6, 0.15), CFrame = CFrame.new(x, 5.7, z), Color = Color3.fromRGB(120, 120, 125), Material = Enum.Material.Metal, Parent = f })
	for _, s in { -1, 1 } do
		part({ Name = "Finger", Size = Vector3.new(0.15, 0.9, 0.15), CFrame = CFrame.new(x + s * 0.3, 4.6, z) * CFrame.Angles(0, 0, -s * 0.5), Color = Color3.fromRGB(230, 60, 60), Parent = f })
	end
	-- 中にぬいぐるみ代わりのカプセル
	local rng = Random.new(42)
	for i = 1, 8 do
		local c = ball(f, Vector3.new(x + rng:NextNumber(-1.8, 1.8), 2.6, z + rng:NextNumber(-1.2, 1.2)), 0.9, Color3.fromHSV(rng:NextNumber(), 0.5, 1))
		c.Name = "Prize"
	end
	-- 操作パネル
	part({ Name = "Panel", Size = Vector3.new(3, 0.6, 1.2), CFrame = CFrame.new(x, 2.4, z - 2.4) * CFrame.Angles(-0.4, 0, 0), Color = Color3.fromRGB(240, 240, 240), Parent = f })
	ball(f, Vector3.new(x + 0.8, 2.75, z - 2.5), 0.5, Color3.fromRGB(230, 50, 60))
	return f
end

-- へや（アパートの 1 室）。正面（ドア）は +Z（道側）
local function room(parent, index: number)
	local x = -STREET_LENGTH / 2 + ROOM_W / 2 + 4 + (index - 1) * (ROOM_W + 2)
	local cz = ROOM_Z - ROOM_D / 2
	local f = Parts.folder(parent, "Room" .. index)
	local wall = Color3.fromRGB(245, 240, 225)
	part({ Name = "Floor", Size = Vector3.new(ROOM_W, 0.6, ROOM_D), CFrame = CFrame.new(x, 0.3, cz), Color = Color3.fromRGB(190, 170, 130), Material = Enum.Material.WoodPlanks, Parent = f })
	-- たたみ
	for i = 0, 2 do
		part({ Name = "Tatami", Size = Vector3.new(ROOM_W - 2, 0.1, (ROOM_D - 2) / 3 - 0.2), CFrame = CFrame.new(x, 0.65, cz - (ROOM_D - 2) / 2 + (ROOM_D - 2) / 6 + i * (ROOM_D - 2) / 3), Color = i % 2 == 0 and Color3.fromRGB(170, 185, 120) or Color3.fromRGB(160, 175, 110), Material = Enum.Material.Fabric, Parent = f })
	end
	part({ Name = "Back", Size = Vector3.new(ROOM_W, 8, 0.6), CFrame = CFrame.new(x, 4, cz - ROOM_D / 2), Color = wall, Parent = f })
	for _, s in { -1, 1 } do
		part({ Name = "Side", Size = Vector3.new(0.6, 8, ROOM_D), CFrame = CFrame.new(x + s * ROOM_W / 2, 4, cz), Color = wall, Parent = f })
		-- 正面の壁（ドアの左右）
		part({ Name = "Front", Size = Vector3.new(ROOM_W / 2 - 2, 8, 0.6), CFrame = CFrame.new(x + s * (ROOM_W / 4 + 1), 4, ROOM_Z), Color = wall, Parent = f })
	end
	part({ Name = "Lintel", Size = Vector3.new(4.2, 1.5, 0.6), CFrame = CFrame.new(x, 7.25, ROOM_Z), Color = wall, Parent = f })
	part({ Name = "Roof", Size = Vector3.new(ROOM_W + 1, 0.8, ROOM_D + 1), CFrame = CFrame.new(x, 8.4, cz), Color = Color3.fromRGB(70, 75, 85), Material = Enum.Material.Slate, Parent = f })
	-- 表札
	local plate = textBoard(f, CFrame.new(x + 3.5, 6.0, ROOM_Z + 0.35), Vector3.new(3.2, 1.0, 0.1), "", Color3.fromRGB(70, 45, 30), GOLD)
	plate.Name = "NamePlate"
	-- 棚: 奥の壁に 3 段、1 段 4 つ
	local slots = {}
	for row = 0, 2 do
		local y = 1.4 + row * 2.5
		part({ Name = "Shelf", Size = Vector3.new(ROOM_W - 2, 0.25, 2.2), CFrame = CFrame.new(x, y, cz - ROOM_D / 2 + 1.4), Color = WOOD, Material = Enum.Material.Wood, Parent = f })
		for col = 0, 3 do
			local sx = x - (ROOM_W - 2) / 2 + (ROOM_W - 2) / 8 + col * (ROOM_W - 2) / 4
			local slot = part({ Name = "Slot", Size = Vector3.new(2.4, 0.1, 1.8), CFrame = CFrame.new(sx, y + 0.18, cz - ROOM_D / 2 + 1.4), Color = Color3.fromRGB(230, 210, 170), Material = Enum.Material.SmoothPlastic, CanCollide = false, Parent = f })
			local n = #slots + 1
			slot:SetAttribute("Slot", n)
			slot:SetAttribute("Room", index)
			slots[n] = { Part = slot, CFrame = CFrame.new(sx, y + 0.23, cz - ROOM_D / 2 + 1.4), Model = nil, Id = nil }
		end
	end
	-- ちゃぶ台と座布団
	part({ Name = "Table", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 3.6, 3.6), CFrame = CFrame.new(x, 1.0, cz + 1) * CFrame.Angles(0, 0, math.pi / 2), Color = Color3.fromRGB(110, 70, 45), Material = Enum.Material.Wood, Parent = f })
	for _, o in { Vector3.new(2.6, 0.9, 1), Vector3.new(-2.6, 0.9, 1) } do
		part({ Name = "Zabuton", Size = Vector3.new(1.8, 0.3, 1.8), CFrame = CFrame.new(x + o.X, o.Y, cz + o.Z), Color = Color3.fromRGB(90, 110, 170), Material = Enum.Material.Fabric, Parent = f })
	end
	-- 明かり
	local lamp = part({ Name = "Lamp", Size = Vector3.new(2.2, 0.5, 2.2), CFrame = CFrame.new(x, 7.6, cz), Color = Color3.fromRGB(255, 240, 210), Material = Enum.Material.SmoothPlastic, Parent = f })
	local pl = Instance.new("PointLight")
	pl.Range = 14
	pl.Brightness = 0.6
	pl.Parent = lamp
	return { Index = index, Folder = f, X = x, CFrame = CFrame.new(x, 0, cz), Slots = slots, NamePlate = plate, Owner = nil, DoorPosition = Vector3.new(x, 3, ROOM_Z + 3) }
end

function Street.build()
	local root = Instance.new("Folder")
	root.Name = "Street"
	root.Parent = Workspace

	-- 道と歩道
	part({ Name = "Road", Size = Vector3.new(STREET_LENGTH + 20, 1, ROAD_W), CFrame = CFrame.new(0, -0.5, 0), Color = Color3.fromRGB(175, 170, 160), Material = Enum.Material.Cobblestone, Parent = root })
	for _, z in { SHOP_Z - 1.5, ROOM_Z + 1.5 } do
		part({ Name = "Curb", Size = Vector3.new(STREET_LENGTH + 20, 1.1, 3), CFrame = CFrame.new(0, -0.45, z), Color = Color3.fromRGB(205, 200, 190), Material = Enum.Material.Concrete, Parent = root })
	end
	-- アーケードの看板（道の両端）
	for _, x in { -STREET_LENGTH / 2 - 2, STREET_LENGTH / 2 + 2 } do
		for _, z in { -ROAD_W / 2 - 1, ROAD_W / 2 + 1 } do
			pillar(root, Vector3.new(x, 6, z), 12, 1.2, Color3.fromRGB(200, 60, 60))
		end
		local arch = part({ Name = "Arch", Size = Vector3.new(1.2, 3, ROAD_W + 4), CFrame = CFrame.new(x, 12.5, 0), Color = Color3.fromRGB(200, 60, 60), Parent = root })
		local b = part({ Name = "ArchSign", Size = Vector3.new(0.3, 2.4, ROAD_W + 2), CFrame = CFrame.new(x + (x > 0 and -0.8 or 0.8), 12.5, 0) * CFrame.Angles(0, x > 0 and math.pi / 2 or -math.pi / 2, 0), Color = Color3.fromRGB(255, 245, 225), Parent = root })
		sign(b, "もぐもぐ商店街  MOGUMOGU ST.", Color3.fromRGB(200, 60, 60), Enum.NormalId.Front)
	end
	-- 提灯の列
	for x = -STREET_LENGTH / 2 + 10, STREET_LENGTH / 2 - 10, 12 do
		for _, z in { SHOP_Z - 2.5, ROOM_Z + 2.5 } do
			pillar(root, Vector3.new(x, 3, z), 6, 0.4, Color3.fromRGB(60, 50, 45))
			-- 昼なので光らせない（赤い紙の提灯）
			local l = part({ Name = "Lantern", Size = Vector3.new(1.2, 1.6, 1.2), CFrame = CFrame.new(x, 6.6, z), Color = Color3.fromRGB(240, 90, 70), Material = Enum.Material.SmoothPlastic, Parent = root })
			part({ Name = "LanternRing", Size = Vector3.new(1.3, 0.12, 1.3), CFrame = CFrame.new(x, 6.6, z), Color = Color3.fromRGB(160, 50, 40), Parent = root })
			part({ Name = "LanternCap", Size = Vector3.new(0.8, 0.2, 0.8), CFrame = CFrame.new(x, 7.5, z), Color = BLACK, Parent = root })
		end
	end

	-- 道のまわりの舗装（芝生を隠す）と、奥に並ぶ背景の建物
	for _, z in { SHOP_Z + 27, ROOM_Z - 27 } do
		part({ Name = "Pavement", Size = Vector3.new(STREET_LENGTH + 80, 1, 58), CFrame = CFrame.new(0, -0.55, z), Color = Color3.fromRGB(185, 180, 170), Material = Enum.Material.Concrete, Parent = root })
	end
	for _, x in { -STREET_LENGTH / 2 - 30, STREET_LENGTH / 2 + 30 } do
		part({ Name = "Pavement", Size = Vector3.new(40, 1, 120), CFrame = CFrame.new(x, -0.55, 0), Color = Color3.fromRGB(185, 180, 170), Material = Enum.Material.Concrete, Parent = root })
	end
	local rng = Random.new(7)
	local bldColors = { Color3.fromRGB(215, 205, 190), Color3.fromRGB(190, 200, 210), Color3.fromRGB(225, 215, 200), Color3.fromRGB(200, 190, 180), Color3.fromRGB(180, 195, 185) }
	for i = 0, 11 do
		local x = -STREET_LENGTH / 2 + i * (STREET_LENGTH / 11)
		for _, side in { 1, -1 } do
			local w = rng:NextNumber(12, 18)
			local h = rng:NextNumber(14, 30)
			local z = side * (SHOP_Z + 24) + side * rng:NextNumber(0, 6)
			local b = part({ Name = "Backdrop", Size = Vector3.new(w, h, 12), CFrame = CFrame.new(x + rng:NextNumber(-3, 3), h / 2, z), Color = bldColors[rng:NextInteger(1, #bldColors)], Material = Enum.Material.Concrete, Parent = root })
			-- 窓
			for wy = 4, h - 3, 4 do
				part({ Name = "Window", Size = Vector3.new(w - 3, 1.6, 0.2), CFrame = CFrame.new(b.Position.X, wy, z - side * 6.1), Color = Color3.fromRGB(120, 150, 180), Material = Enum.Material.Glass, CanCollide = false, Parent = root })
			end
			part({ Name = "BackdropRoof", Size = Vector3.new(w + 1, 0.8, 13), CFrame = CFrame.new(b.Position.X, h + 0.4, z), Color = Color3.fromRGB(90, 90, 100), Parent = root })
		end
	end

	-- お店（北側）
	local dagashi = shop(root, -40, 22, Color3.fromRGB(215, 160, 110), "だがしや  DAGASHI", Color3.fromRGB(60, 90, 160))
	local game = shop(root, -10, 18, Color3.fromRGB(240, 200, 220), "ゲームコーナー  GAME", nil)
	shop(root, 14, 14, Color3.fromRGB(170, 200, 150), "やおや  VEGGIES", Color3.fromRGB(80, 150, 90))
	shop(root, 32, 14, Color3.fromRGB(150, 180, 220), "さかなや  FISH", Color3.fromRGB(50, 90, 170))
	shop(root, 52, 18, Color3.fromRGB(230, 190, 150), "ぱんや  BAKERY", Color3.fromRGB(200, 120, 60))
	-- だがしやの駄菓子棚（飾り）
	for i = 0, 2 do
		part({ Size = Vector3.new(6, 0.3, 1.2), CFrame = CFrame.new(-40, 2 + i * 1.6, SHOP_Z + 10.5), Color = WOOD, Material = Enum.Material.Wood, Parent = dagashi })
		for j = 0, 5 do
			part({ Size = Vector3.new(0.7, 0.9, 0.5), CFrame = CFrame.new(-42.5 + j, 2.6 + i * 1.6, SHOP_Z + 10.5), Color = Color3.fromHSV((i * 6 + j) / 18, 0.6, 1), Parent = dagashi })
		end
	end
	-- お店の店先の商品台（やおや・さかなや・ぱんや）
	local function stall(parent, x: number, w: number, items: { Color3 }, shape: string)
		part({ Name = "Stall", Size = Vector3.new(w - 4, 1.6, 2.2), CFrame = CFrame.new(x, 0.8, SHOP_Z + 2.2), Color = WOOD, Material = Enum.Material.Wood, Parent = parent })
		local r2 = Random.new(math.floor(x))
		for i = 1, 10 do
			local col = items[(i - 1) % #items + 1]
			local px = x - (w - 4) / 2 + 0.8 + (i - 1) * ((w - 4) - 1.6) / 9
			local pz = SHOP_Z + 2.2 + r2:NextNumber(-0.5, 0.5)
			if shape == "ball" then
				ball(parent, Vector3.new(px, 1.95, pz), 0.75, col)
			else
				part({ Size = Vector3.new(0.9, 0.5, 1.4), CFrame = CFrame.new(px, 1.85, pz) * CFrame.Angles(0, r2:NextNumber(-0.3, 0.3), 0), Color = col, Parent = parent })
			end
		end
	end
	stall(root, 14, 14, { Color3.fromRGB(230, 60, 50), Color3.fromRGB(90, 170, 80), Color3.fromRGB(255, 160, 40), Color3.fromRGB(140, 80, 160) }, "ball")
	stall(root, 32, 14, { Color3.fromRGB(120, 150, 190), Color3.fromRGB(220, 100, 90), Color3.fromRGB(200, 200, 210) }, "box")
	stall(root, 52, 18, { Color3.fromRGB(225, 175, 105), Color3.fromRGB(200, 135, 75), Color3.fromRGB(245, 215, 150) }, "ball")
	-- お店の前の幕と小さな看板
	for _, info in { { x = 14, t = "本日とくばい" }, { x = 32, t = "朝どれ" }, { x = 52, t = "やきたて" } } do
		local b = part({ Name = "MiniSign", Size = Vector3.new(3.2, 0.9, 0.1), CFrame = CFrame.new(info.x + 4, 3.0, SHOP_Z - 0.3) * CFrame.Angles(0, math.pi, 0), Color = Color3.fromRGB(255, 250, 235), Parent = root })
		sign(b, info.t, Color3.fromRGB(200, 50, 50), Enum.NormalId.Front)
	end

	-- ガチャ 3 台（だがしやの前）とクレーン（ゲームコーナー）
	local gachas = {}
	for i, c in { Color3.fromRGB(230, 60, 60), Color3.fromRGB(60, 140, 230), Color3.fromRGB(240, 190, 50) } do
		local f, knob = gachaMachine(root, -46 + (i - 1) * 4.5, SHOP_Z + 2.5, c, "第1弾 ¥" .. Config.GACHA_PRICE)
		table.insert(gachas, { Folder = f, Knob = knob })
	end
	local claw = clawMachine(root, -10, SHOP_Z + 4)

	-- アパート（南側）
	local rooms = {}
	for i = 1, Config.ROOMS do
		rooms[i] = room(root, i)
	end

	return {
		Folder = root,
		Gachas = gachas,
		Claw = claw,
		Rooms = rooms,
		SpawnCFrame = CFrame.new(-30, 4, 0),
	}
end

return Street
