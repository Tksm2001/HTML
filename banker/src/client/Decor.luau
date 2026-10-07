-- 塔の階ごとの「章」の見た目（色・材質・小物・明かり）。Dungeon.client から使う。
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local Decor = {}

local function part(name, cf, size, color, material, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function ball(name, cf, size, color, material, parent)
	local p = part(name, cf, size, color, material, parent)
	local m = Instance.new("SpecialMesh")
	m.MeshType = Enum.MeshType.Sphere
	m.Parent = p
	return p
end
local function cyl(name, cf, length, radius, color, material, parent)
	local p = part(name, cf * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(length, radius * 2, radius * 2), color, material, parent)
	p.Shape = Enum.PartType.Cylinder
	return p
end
local function light(parent: BasePart, color: Color3, range: number, bright: number)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range
	l.Brightness = bright
	l.Parent = parent
	return l
end

-- ===== 章 =====
-- room/corridor/wall/trim: 色, roomMat/corrMat/wallMat: 材質, props: 小物の種類, sconce: 壁の明かり, ambient: 空間の明るさ, fog
Decor.CHAPTERS = {
	{ from = 1, name = "新人フロア", room = Color3.fromRGB(120, 150, 200), corridor = Color3.fromRGB(165, 170, 180), wall = Color3.fromRGB(225, 225, 230), trim = Color3.fromRGB(110, 130, 170),
		roomMat = Enum.Material.Fabric, corrMat = Enum.Material.SmoothPlastic, wallMat = Enum.Material.SmoothPlastic,
		props = { "desk", "plant", "cabinet", "cooler" }, sconce = { color = Color3.fromRGB(255, 250, 235), every = 5 },
		ambient = Color3.fromRGB(150, 150, 160), outdoor = Color3.fromRGB(140, 140, 150), fog = Color3.fromRGB(200, 205, 215) },
	{ from = 5, name = "営業フロア", room = Color3.fromRGB(190, 150, 100), corridor = Color3.fromRGB(150, 120, 85), wall = Color3.fromRGB(230, 220, 200), trim = Color3.fromRGB(120, 85, 55),
		roomMat = Enum.Material.WoodPlanks, corrMat = Enum.Material.Wood, wallMat = Enum.Material.Plaster,
		props = { "desk", "shelf", "coffee", "plant", "boxes" }, sconce = { color = Color3.fromRGB(255, 230, 180), every = 5 },
		ambient = Color3.fromRGB(140, 130, 115), outdoor = Color3.fromRGB(130, 120, 105), fog = Color3.fromRGB(190, 175, 150) },
	{ from = 10, name = "会議室フロア", room = Color3.fromRGB(45, 60, 110), corridor = Color3.fromRGB(70, 75, 95), wall = Color3.fromRGB(170, 200, 225), trim = Color3.fromRGB(230, 235, 245),
		roomMat = Enum.Material.Fabric, corrMat = Enum.Material.Concrete, wallMat = Enum.Material.Glass,
		props = { "table", "screen", "plant", "whiteboard" }, sconce = { color = Color3.fromRGB(220, 235, 255), every = 4 },
		ambient = Color3.fromRGB(120, 130, 155), outdoor = Color3.fromRGB(110, 120, 145), fog = Color3.fromRGB(150, 170, 200) },
	{ from = 15, name = "金庫フロア", room = Color3.fromRGB(110, 115, 125), corridor = Color3.fromRGB(85, 88, 95), wall = Color3.fromRGB(95, 100, 110), trim = Color3.fromRGB(200, 170, 80),
		roomMat = Enum.Material.DiamondPlate, corrMat = Enum.Material.Metal, wallMat = Enum.Material.Metal,
		props = { "safe", "bars", "goldpile", "pillar" }, sconce = { color = Color3.fromRGB(255, 200, 120), every = 4 },
		ambient = Color3.fromRGB(95, 95, 105), outdoor = Color3.fromRGB(85, 85, 95), fog = Color3.fromRGB(90, 95, 110) },
	{ from = 20, name = "役員フロア", room = Color3.fromRGB(150, 40, 50), corridor = Color3.fromRGB(110, 35, 40), wall = Color3.fromRGB(80, 50, 40), trim = Color3.fromRGB(255, 205, 60),
		roomMat = Enum.Material.Fabric, corrMat = Enum.Material.Fabric, wallMat = Enum.Material.Wood,
		props = { "pillar", "portrait", "plant", "chair", "goldpile" }, sconce = { color = Color3.fromRGB(255, 215, 140), every = 3 },
		ambient = Color3.fromRGB(120, 100, 90), outdoor = Color3.fromRGB(110, 90, 80), fog = Color3.fromRGB(120, 80, 70) },
	{ from = 25, name = "闇フロア", room = Color3.fromRGB(60, 40, 90), corridor = Color3.fromRGB(45, 30, 65), wall = Color3.fromRGB(35, 25, 50), trim = Color3.fromRGB(200, 120, 255),
		roomMat = Enum.Material.Slate, corrMat = Enum.Material.Slate, wallMat = Enum.Material.Slate,
		props = { "floatcoin", "crystal", "pillar", "lamp" }, sconce = { color = Color3.fromRGB(200, 130, 255), every = 3 },
		ambient = Color3.fromRGB(80, 60, 110), outdoor = Color3.fromRGB(70, 50, 100), fog = Color3.fromRGB(50, 30, 80) },
	{ from = 30, name = "取締役会", room = Color3.fromRGB(70, 40, 100), corridor = Color3.fromRGB(50, 30, 70), wall = Color3.fromRGB(45, 30, 60), trim = Color3.fromRGB(255, 205, 60),
		roomMat = Enum.Material.Fabric, corrMat = Enum.Material.Fabric, wallMat = Enum.Material.Marble,
		props = { "pillar", "portrait", "goldpile", "floatcoin" }, sconce = { color = Color3.fromRGB(255, 200, 100), every = 2 },
		ambient = Color3.fromRGB(100, 70, 120), outdoor = Color3.fromRGB(90, 60, 110), fog = Color3.fromRGB(60, 30, 80) },
}

function Decor.theme(floor: number)
	local th = Decor.CHAPTERS[1]
	for _, c in Decor.CHAPTERS do
		if floor >= c.from then
			th = c
		end
	end
	return th
end

-- ===== 小物 =====
local PLANT = Color3.fromRGB(80, 160, 90)
local WOOD = Color3.fromRGB(150, 110, 75)
local GOLD = Color3.fromRGB(255, 205, 60)
local builders = {}

builders.desk = function(cf, p)
	part("DeskTop", cf * CFrame.new(0, 1.3, 0), Vector3.new(2.6, 0.2, 1.3), WOOD, Enum.Material.Wood, p)
	part("DeskLeg", cf * CFrame.new(-1.1, 0.65, 0), Vector3.new(0.2, 1.3, 1.1), Color3.fromRGB(90, 90, 100), nil, p)
	part("DeskLeg", cf * CFrame.new(1.1, 0.65, 0), Vector3.new(0.2, 1.3, 1.1), Color3.fromRGB(90, 90, 100), nil, p)
	part("Monitor", cf * CFrame.new(0.3, 1.9, 0.3), Vector3.new(1.0, 0.7, 0.08), Color3.fromRGB(30, 30, 40), nil, p)
	part("Screen", cf * CFrame.new(0.3, 1.9, 0.25), Vector3.new(0.9, 0.6, 0.03), Color3.fromRGB(120, 200, 255), Enum.Material.Neon, p)
	part("Paper", cf * CFrame.new(-0.7, 1.42, -0.2) * CFrame.Angles(0, 0.3, 0), Vector3.new(0.6, 0.04, 0.8), Color3.fromRGB(255, 255, 255), nil, p)
end
builders.plant = function(cf, p)
	part("Pot", cf * CFrame.new(0, 0.4, 0), Vector3.new(0.9, 0.8, 0.9), Color3.fromRGB(200, 120, 80), nil, p)
	for i = 1, 4 do
		local a = i / 4 * math.pi * 2
		ball("Leaf", cf * CFrame.new(math.cos(a) * 0.3, 1.3 + (i % 2) * 0.3, math.sin(a) * 0.3) * CFrame.Angles(0, -a, 0.5), Vector3.new(0.25, 1.2, 0.6), PLANT, nil, p)
	end
end
builders.cabinet = function(cf, p)
	part("Cabinet", cf * CFrame.new(0, 1.2, 0), Vector3.new(1.4, 2.4, 0.9), Color3.fromRGB(180, 185, 195), Enum.Material.Metal, p)
	for i = 0, 2 do
		part("Handle", cf * CFrame.new(0, 0.5 + i * 0.7, -0.47), Vector3.new(0.5, 0.08, 0.06), Color3.fromRGB(60, 60, 70), nil, p)
	end
end
builders.cooler = function(cf, p)
	part("CoolerBase", cf * CFrame.new(0, 0.6, 0), Vector3.new(0.9, 1.2, 0.9), Color3.fromRGB(240, 240, 245), nil, p)
	local b = cyl("Bottle", cf * CFrame.new(0, 1.85, 0) * CFrame.Angles(0, 0, math.pi / 2), 1.3, 0.38, Color3.fromRGB(150, 200, 255), Enum.Material.Glass, p)
	b.Transparency = 0.4
end
builders.shelf = function(cf, p)
	part("Shelf", cf * CFrame.new(0, 1.4, 0), Vector3.new(2.4, 2.8, 0.8), WOOD, Enum.Material.Wood, p)
	local cols = { Color3.fromRGB(230, 90, 90), Color3.fromRGB(80, 140, 230), Color3.fromRGB(240, 200, 80), Color3.fromRGB(90, 180, 120) }
	for r = 0, 2 do
		for i = 0, 4 do
			part("Binder", cf * CFrame.new(-0.9 + i * 0.45, 0.55 + r * 0.9, -0.2), Vector3.new(0.3, 0.7, 0.45), cols[(i + r) % 4 + 1], nil, p)
		end
	end
end
builders.coffee = function(cf, p)
	part("Counter", cf * CFrame.new(0, 0.6, 0), Vector3.new(1.6, 1.2, 0.9), Color3.fromRGB(90, 70, 60), Enum.Material.Wood, p)
	part("Machine", cf * CFrame.new(-0.3, 1.6, 0), Vector3.new(0.7, 0.8, 0.6), Color3.fromRGB(50, 50, 55), Enum.Material.Metal, p)
	part("Lamp", cf * CFrame.new(-0.3, 1.75, -0.31), Vector3.new(0.12, 0.12, 0.04), Color3.fromRGB(255, 90, 60), Enum.Material.Neon, p)
	cyl("Cup", cf * CFrame.new(0.45, 1.4, -0.1) * CFrame.Angles(0, 0, math.pi / 2), 0.4, 0.17, Color3.fromRGB(255, 255, 255), nil, p)
	for i = 1, 2 do
		local s = ball("Steam", cf * CFrame.new(0.45 + i * 0.1, 1.8 + i * 0.25, -0.1), Vector3.new(0.2, 0.25, 0.2), Color3.fromRGB(255, 255, 255), nil, p)
		s.Transparency = 0.5
	end
end
builders.boxes = function(cf, p)
	part("Box", cf * CFrame.new(0, 0.5, 0), Vector3.new(1.2, 1.0, 1.0), Color3.fromRGB(200, 160, 110), Enum.Material.Wood, p)
	part("Box", cf * CFrame.new(0.2, 1.35, -0.1) * CFrame.Angles(0, 0.3, 0), Vector3.new(0.9, 0.7, 0.8), Color3.fromRGB(210, 170, 120), Enum.Material.Wood, p)
	part("Tape", cf * CFrame.new(0, 1.01, 0), Vector3.new(1.22, 0.02, 0.2), Color3.fromRGB(180, 130, 70), nil, p)
end
builders.table = function(cf, p)
	part("Table", cf * CFrame.new(0, 1.2, 0), Vector3.new(3.0, 0.2, 1.4), Color3.fromRGB(70, 50, 40), Enum.Material.Wood, p)
	part("TableLeg", cf * CFrame.new(0, 0.6, 0), Vector3.new(0.6, 1.2, 0.6), Color3.fromRGB(60, 60, 70), Enum.Material.Metal, p)
	for i = -1, 1 do
		part("Chair", cf * CFrame.new(i * 1.0, 0.7, 1.0), Vector3.new(0.6, 0.15, 0.6), Color3.fromRGB(40, 45, 60), nil, p)
		part("ChairBack", cf * CFrame.new(i * 1.0, 1.1, 1.28), Vector3.new(0.6, 0.8, 0.1), Color3.fromRGB(40, 45, 60), nil, p)
	end
end
builders.screen = function(cf, p)
	part("Stand", cf * CFrame.new(0, 1.0, 0), Vector3.new(0.2, 2.0, 0.2), Color3.fromRGB(60, 60, 70), Enum.Material.Metal, p)
	part("Screen", cf * CFrame.new(0, 2.3, 0), Vector3.new(2.4, 1.4, 0.12), Color3.fromRGB(30, 30, 40), nil, p)
	part("ScreenGlow", cf * CFrame.new(0, 2.3, -0.08), Vector3.new(2.2, 1.2, 0.03), Color3.fromRGB(90, 160, 255), Enum.Material.Neon, p)
	for i = 0, 3 do
		part("Bar", cf * CFrame.new(-0.7 + i * 0.45, 1.85 + i * 0.18, -0.11), Vector3.new(0.3, 0.3 + i * 0.35, 0.02), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, p)
	end
end
builders.whiteboard = function(cf, p)
	part("Board", cf * CFrame.new(0, 2.0, 0), Vector3.new(2.6, 1.6, 0.1), Color3.fromRGB(250, 250, 250), nil, p)
	part("Frame", cf * CFrame.new(0, 1.18, 0), Vector3.new(2.7, 0.08, 0.14), Color3.fromRGB(150, 150, 160), Enum.Material.Metal, p)
	part("Line", cf * CFrame.new(-0.4, 2.3, -0.06) * CFrame.Angles(0, 0, 0.4), Vector3.new(1.4, 0.06, 0.02), Color3.fromRGB(230, 60, 60), nil, p)
	part("Line", cf * CFrame.new(0.3, 1.8, -0.06), Vector3.new(1.0, 0.06, 0.02), Color3.fromRGB(60, 90, 230), nil, p)
end
builders.safe = function(cf, p)
	part("Safe", cf * CFrame.new(0, 1.0, 0), Vector3.new(1.8, 2.0, 1.4), Color3.fromRGB(60, 70, 90), Enum.Material.Metal, p)
	cyl("Dial", cf * CFrame.new(0.3, 1.1, -0.72) * CFrame.Angles(0, math.pi / 2, 0), 0.1, 0.3, GOLD, Enum.Material.Metal, p)
	part("Handle", cf * CFrame.new(-0.4, 1.1, -0.74), Vector3.new(0.1, 0.6, 0.1), GOLD, Enum.Material.Metal, p)
end
builders.bars = function(cf, p)
	for i = -2, 2 do
		cyl("Bar", cf * CFrame.new(i * 0.4, 1.4, 0) * CFrame.Angles(0, 0, math.pi / 2), 2.8, 0.06, Color3.fromRGB(120, 125, 135), Enum.Material.Metal, p)
	end
	part("BarTop", cf * CFrame.new(0, 2.8, 0), Vector3.new(2.0, 0.12, 0.2), Color3.fromRGB(120, 125, 135), Enum.Material.Metal, p)
end
builders.goldpile = function(cf, p)
	local rng = Random.new(math.floor(cf.X * 7 + cf.Z * 13))
	for i = 1, 9 do
		cyl("Coin", cf * CFrame.new(rng:NextNumber(-0.8, 0.8), 0.08 + (i % 3) * 0.12, rng:NextNumber(-0.6, 0.6)) * CFrame.Angles(0, rng:NextNumber(0, 3), 0), 0.08, 0.3, GOLD, Enum.Material.Metal, p)
	end
	local b = ball("GoldLump", cf * CFrame.new(0, 0.35, 0), Vector3.new(1.4, 0.7, 1.1), GOLD, Enum.Material.Metal, p)
	light(b, GOLD, 6, 0.6)
end
builders.pillar = function(cf, p)
	cyl("Pillar", cf * CFrame.new(0, 2.2, 0) * CFrame.Angles(0, 0, math.pi / 2), 4.4, 0.45, Color3.fromRGB(230, 225, 215), Enum.Material.Marble, p)
	part("PillarBase", cf * CFrame.new(0, 0.2, 0), Vector3.new(1.3, 0.4, 1.3), GOLD, Enum.Material.Metal, p)
	part("PillarTop", cf * CFrame.new(0, 4.3, 0), Vector3.new(1.3, 0.3, 1.3), GOLD, Enum.Material.Metal, p)
end
builders.portrait = function(cf, p)
	part("Frame", cf * CFrame.new(0, 2.4, 0), Vector3.new(1.8, 2.2, 0.15), GOLD, Enum.Material.Metal, p)
	part("Canvas", cf * CFrame.new(0, 2.4, -0.09), Vector3.new(1.5, 1.9, 0.05), Color3.fromRGB(60, 50, 70), nil, p)
	ball("Face", cf * CFrame.new(0, 2.7, -0.14), Vector3.new(0.7, 0.8, 0.1), Color3.fromRGB(255, 224, 196), nil, p)
	part("Suit", cf * CFrame.new(0, 2.0, -0.14), Vector3.new(1.0, 0.7, 0.08), Color3.fromRGB(30, 30, 40), nil, p)
	part("Mustache", cf * CFrame.new(0, 2.55, -0.17), Vector3.new(0.4, 0.1, 0.04), Color3.fromRGB(200, 200, 200), nil, p)
end
builders.chair = function(cf, p)
	part("Seat", cf * CFrame.new(0, 0.9, 0), Vector3.new(1.2, 0.3, 1.2), Color3.fromRGB(90, 30, 40), Enum.Material.Leather, p)
	part("Back", cf * CFrame.new(0, 1.8, 0.5), Vector3.new(1.2, 1.6, 0.25), Color3.fromRGB(90, 30, 40), Enum.Material.Leather, p)
	part("Base", cf * CFrame.new(0, 0.4, 0), Vector3.new(0.4, 0.8, 0.4), GOLD, Enum.Material.Metal, p)
end
builders.floatcoin = function(cf, p)
	local rng = Random.new(math.floor(cf.X * 3 + cf.Z * 5))
	for i = 1, 4 do
		local c = cyl("FloatCoin", cf * CFrame.new(rng:NextNumber(-1, 1), 1.5 + i * 0.6, rng:NextNumber(-1, 1)) * CFrame.Angles(rng:NextNumber(0, 3), rng:NextNumber(0, 3), 0), 0.1, 0.3, GOLD, Enum.Material.Neon, p)
		c:SetAttribute("Float", i)
		CollectionService:AddTag(c, "FloatCoin")
	end
end
builders.crystal = function(cf, p)
	local c = part("Crystal", cf * CFrame.new(0, 1.2, 0) * CFrame.Angles(0, 0.8, 0), Vector3.new(0.6, 2.4, 0.6), Color3.fromRGB(200, 120, 255), Enum.Material.Neon, p)
	c.Transparency = 0.2
	part("Crystal", cf * CFrame.new(0.5, 0.7, 0.3) * CFrame.Angles(0.3, 0.2, 0.4), Vector3.new(0.35, 1.4, 0.35), Color3.fromRGB(230, 160, 255), Enum.Material.Neon, p)
	light(c, Color3.fromRGB(200, 120, 255), 10, 1.2)
end
builders.lamp = function(cf, p)
	cyl("LampPole", cf * CFrame.new(0, 1.6, 0) * CFrame.Angles(0, 0, math.pi / 2), 3.2, 0.08, Color3.fromRGB(40, 35, 50), Enum.Material.Metal, p)
	local l = ball("LampGlass", cf * CFrame.new(0, 3.3, 0), Vector3.new(0.7, 0.9, 0.7), Color3.fromRGB(255, 220, 150), Enum.Material.Neon, p)
	light(l, Color3.fromRGB(255, 200, 120), 12, 1.0)
end

-- 部屋の壁ぎわのマスに小物を置く。seed で毎回同じ配置。戻り値: Model か nil
function Decor.prop(th, floor: number, x: number, y: number, pos: Vector3, wallDir: Vector3, parent: Instance): Model?
	local rng = Random.new(floor * 100003 + x * 1009 + y * 7)
	if rng:NextNumber() > 0.28 then
		return nil
	end
	local kind = th.props[rng:NextInteger(1, #th.props)]
	local m = Instance.new("Model")
	m.Name = "Prop_" .. kind
	-- 壁に寄せて、壁の方を背にする
	local back = -wallDir
	local cf = CFrame.lookAt(pos + wallDir * 1.0, pos + wallDir * 1.0 + back)
	builders[kind](cf, m)
	m.Parent = parent
	return m
end

-- 壁の明かり（燭台）。every 個に 1 つ
function Decor.sconce(th, floor: number, x: number, y: number, pos: Vector3, faceDir: Vector3, parent: Instance)
	if (x * 3 + y * 5 + floor) % th.sconce.every ~= 0 then
		return
	end
	local cf = CFrame.lookAt(pos + faceDir * 2.05 + Vector3.new(0, 2.6, 0), pos + faceDir * 3 + Vector3.new(0, 2.6, 0))
	part("SconceBase", cf, Vector3.new(0.5, 0.7, 0.15), Color3.fromRGB(60, 55, 60), Enum.Material.Metal, parent)
	local g = ball("SconceGlow", cf * CFrame.new(0, 0.5, -0.15), Vector3.new(0.45, 0.6, 0.35), th.sconce.color, Enum.Material.Neon, parent)
	light(g, th.sconce.color, 14, 0.9)
end

-- 明かりの雰囲気（自分の画面だけ）。戻り値: 元に戻すための関数
function Decor.applyLighting(th)
	local saved = {
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		FogColor = Lighting.FogColor,
		FogEnd = Lighting.FogEnd,
		FogStart = Lighting.FogStart,
		Brightness = Lighting.Brightness,
		ClockTime = Lighting.ClockTime,
	}
	Lighting.Ambient = th.ambient
	Lighting.OutdoorAmbient = th.outdoor
	Lighting.FogColor = th.fog
	Lighting.FogStart = 60
	Lighting.FogEnd = 160
	Lighting.Brightness = 1.6
	Lighting.ClockTime = 14
	return function()
		for k, v in saved do
			Lighting[k] = v
		end
	end
end

return Decor
