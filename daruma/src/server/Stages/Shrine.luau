-- ステージ「だるま神社」。参道（石畳）に鳥居が並び、奥の拝殿の前に巨大だるまが座っている。
local Parts = require(script.Parent.Parent.Parts)
local part, pillar, sign, ball = Parts.part, Parts.pillar, Parts.sign, Parts.ball
local VERMILION, BLACK, STONE, WOOD, GOLD = Parts.VERMILION, Parts.BLACK, Parts.STONE, Parts.WOOD, Parts.GOLD

local Shrine = {}

Shrine.name = "だるま神社"
Shrine.nameEn = "DARUMA SHRINE"
Shrine.floor = { color = Color3.fromRGB(168, 162, 150), material = Enum.Material.Cobblestone }
Shrine.centerLine = { color = Color3.fromRGB(215, 190, 120), material = Enum.Material.Fabric }
Shrine.lighting = {
	normal = {
		ClockTime = 16.4,
		Brightness = 2.2,
		Ambient = Color3.fromRGB(70, 60, 55),
		OutdoorAmbient = Color3.fromRGB(140, 125, 115),
		atmosphere = { Density = 0.3, Color = Color3.fromRGB(255, 220, 190), Decay = Color3.fromRGB(200, 140, 110) },
		lights = 1,
	},
	hard = {
		ClockTime = 20.5,
		Brightness = 1,
		Ambient = Color3.fromRGB(40, 35, 60),
		OutdoorAmbient = Color3.fromRGB(60, 55, 90),
		atmosphere = { Density = 0.4, Color = Color3.fromRGB(90, 80, 130), Decay = Color3.fromRGB(40, 30, 70) },
		lights = 3,
	},
}

-- 鳥居。参道をまたぐ。柱は垣根の外なので邪魔にならない
local function torii(parent: Instance, z: number, span: number)
	local folder = Parts.folder(parent, "Torii")
	local h = 28
	for _, x in { -span / 2, span / 2 } do
		pillar(folder, Vector3.new(x, h / 2, z), h, 2.6, VERMILION)
		pillar(folder, Vector3.new(x, 1.5, z), 3, 3.4, BLACK)
	end
	-- 貫（ぬき）: 下の横木
	part({ Name = "Nuki", Size = Vector3.new(span + 6, 1.6, 1.4), Position = Vector3.new(0, h - 6, z), Color = VERMILION, Parent = folder })
	-- 笠木（かさぎ）: 上の横木。黒い屋根付き
	part({ Name = "Kasagi", Size = Vector3.new(span + 12, 1.8, 2.6), Position = Vector3.new(0, h - 0.6, z), Color = VERMILION, Parent = folder })
	part({ Name = "KasagiTop", Size = Vector3.new(span + 16, 1.2, 3.2), Position = Vector3.new(0, h + 0.9, z), Color = BLACK, Parent = folder })
	-- 額（がく）
	part({ Name = "Gakuzuka", Size = Vector3.new(1.4, 4.6, 1.2), Position = Vector3.new(0, h - 3.5, z), Color = VERMILION, Parent = folder })
	-- 正面（Front）が参道の手前側を向くように 180 度回す
	local plaque = part({ Name = "Plaque", Size = Vector3.new(4.5, 6, 0.6), CFrame = CFrame.new(0, h - 3.5, z + 0.9) * CFrame.Angles(0, math.pi, 0), Color = BLACK, Parent = folder })
	sign(plaque, "達\n磨", GOLD)
end

-- 石灯籠
local function lantern(parent: Instance, x: number, z: number)
	local folder = Parts.folder(parent, "Lantern")
	part({ Size = Vector3.new(3.2, 1, 3.2), Position = Vector3.new(x, 1, z), Color = STONE, Material = Enum.Material.Slate, Parent = folder })
	pillar(folder, Vector3.new(x, 3.5, z), 4, 1.3, STONE, Enum.Material.Slate)
	part({ Size = Vector3.new(3.2, 0.6, 3.2), Position = Vector3.new(x, 5.8, z), Color = STONE, Material = Enum.Material.Slate, Parent = folder })
	local light = part({
		Name = "Light",
		Size = Vector3.new(2.2, 2, 2.2),
		Position = Vector3.new(x, 7.1, z),
		Color = Color3.fromRGB(255, 205, 130),
		Material = Enum.Material.Neon,
		Transparency = 0.15,
		Parent = folder,
	})
	local pl = Instance.new("PointLight")
	pl.Color = Color3.fromRGB(255, 190, 120)
	pl.Range = 18
	pl.Brightness = 2
	pl.Parent = light
	part({ Size = Vector3.new(4, 0.8, 4), Position = Vector3.new(x, 8.5, z), Color = STONE, Material = Enum.Material.Slate, Parent = folder })
	part({ Size = Vector3.new(1.2, 1, 1.2), Position = Vector3.new(x, 9.4, z), Color = STONE, Material = Enum.Material.Slate, Parent = folder })
end

-- 桜の木
local function sakura(parent: Instance, x: number, z: number, scale: number)
	local folder = Parts.folder(parent, "Sakura")
	pillar(folder, Vector3.new(x, 5 * scale, z), 10 * scale, 1.8 * scale, Color3.fromRGB(85, 55, 40), Enum.Material.Wood)
	local pink = Color3.fromRGB(255, 183, 205)
	for _, o in { Vector3.new(0, 11, 0), Vector3.new(3.5, 9.5, 1.5), Vector3.new(-3, 9.8, -1.5), Vector3.new(0.5, 13.5, -1) } do
		ball(folder, Vector3.new(x, 0, z) + o * scale, (o.Y > 12 and 6 or 8) * scale, pink, Enum.Material.Grass)
	end
end

-- 奥の拝殿。だるまの背中側
local function haiden(parent: Instance, z: number)
	local folder = Parts.folder(parent, "Haiden")
	part({ Name = "Platform", Size = Vector3.new(46, 3, 26), Position = Vector3.new(0, 1.5, z), Color = STONE, Material = Enum.Material.Slate, Parent = folder })
	part({ Name = "Floor", Size = Vector3.new(40, 0.6, 22), Position = Vector3.new(0, 3.3, z), Color = WOOD, Material = Enum.Material.WoodPlanks, Parent = folder })
	for _, x in { -18, -6, 6, 18 } do
		for _, dz in { -9, 9 } do
			pillar(folder, Vector3.new(x, 9.5, z + dz), 12, 1.8, VERMILION)
		end
	end
	part({ Name = "Wall", Size = Vector3.new(36, 11, 1), Position = Vector3.new(0, 9, z - 9), Color = Color3.fromRGB(245, 238, 225), Parent = folder })
	-- 切妻屋根: 2 枚の板を山形に
	local ridgeY = 22
	for _, s in { 1, -1 } do
		part({
			Name = "Roof",
			Size = Vector3.new(52, 1.4, 17),
			CFrame = CFrame.new(0, ridgeY - 8.5 * math.sin(0.45), z + s * 8.5 * math.cos(0.45)) * CFrame.Angles(s * 0.45, 0, 0),
			Color = Color3.fromRGB(55, 60, 66),
			Material = Enum.Material.Slate,
			Parent = folder,
		})
	end
	part({ Name = "Ridge", Size = Vector3.new(54, 1.8, 1.8), Position = Vector3.new(0, ridgeY + 0.4, z), Color = BLACK, Parent = folder })
	-- しめ縄と紙垂（しで）
	part({ Name = "Shimenawa", Shape = Enum.PartType.Cylinder, Size = Vector3.new(34, 1.4, 1.4), Position = Vector3.new(0, 14.6, z + 9.5), Color = Color3.fromRGB(215, 190, 120), Material = Enum.Material.Fabric, Parent = folder })
	for _, x in { -10, 0, 10 } do
		part({ Name = "Shide", Size = Vector3.new(1, 3, 0.1), Position = Vector3.new(x, 12.6, z + 9.6), Color = Color3.fromRGB(255, 255, 255), Parent = folder })
	end
end

function Shrine.decorate(ctx)
	local folder, halfW, length = ctx.folder, ctx.halfW, ctx.length
	-- 赤い垣根
	for _, x in { -halfW - 1, halfW + 1 } do
		local fence = Parts.folder(folder, "Fence")
		for z = -length / 2, length / 2, 10 do
			part({ Size = Vector3.new(1.2, 4.4, 1.2), Position = Vector3.new(x, 2.2, z), Color = VERMILION, Parent = fence })
		end
		for _, y in { 1.6, 3.6 } do
			part({ Size = Vector3.new(0.6, 0.7, length), Position = Vector3.new(x, y, 0), Color = VERMILION, Parent = fence })
		end
	end
	-- 鳥居 3 基
	for _, z in { 62, 12, -38 } do
		torii(folder, z, halfW * 2 + 8)
	end
	-- 石灯籠と桜（垣根の外）
	for z = -80, 80, 40 do
		lantern(folder, -halfW - 7, z)
		lantern(folder, halfW + 7, z)
	end
	for i, z in { -70, -25, 25, 75 } do
		local s = 1 + (i % 2) * 0.2
		sakura(folder, -halfW - 20, z, s)
		sakura(folder, halfW + 20, z + 12, s)
	end
	haiden(folder, ctx.darumaZ - 34)
end

-- 絵馬掛け: 壁際から中央線の少し先までふさぐ木の柵
local EMA_COLORS = { Color3.fromRGB(225, 195, 140), Color3.fromRGB(235, 210, 160), Color3.fromRGB(210, 180, 125) }
local function emaRack(parent: Instance, halfW: number, side: string, z: number)
	local folder = Parts.folder(parent, "EmaRack")
	local s = Parts.wallSpan(halfW, side)
	local h = 8
	for _, x in { s.sign * (s.inner + 0.6), s.sign * (s.outer - 0.6) } do
		part({ Name = "Post", Size = Vector3.new(1.2, h, 1.2), Position = Vector3.new(x, h / 2 + 0.5, z), Color = WOOD, Material = Enum.Material.Wood, Parent = folder })
	end
	-- 板の上端は床から 8 以上（ふつうのジャンプでは届かない）
	part({ Name = "Board", Size = Vector3.new(s.length, h, 0.6), Position = Vector3.new(s.cx, h / 2 + 0.5, z), Color = Color3.fromRGB(135, 95, 60), Material = Enum.Material.WoodPlanks, Parent = folder })
	part({ Name = "Roof", Size = Vector3.new(s.length + 2, 0.6, 2.6), Position = Vector3.new(s.cx, h + 0.8, z), Color = BLACK, Parent = folder })
	-- 絵馬（両面）
	local rng = Random.new(z * 7 + s.sign)
	for i = 0, math.floor(s.length / 1.8) - 1 do
		for _, dz in { -0.45, 0.45 } do
			for _, y in { 3, 5.2 } do
				if rng:NextNumber() < 0.75 then
					part({
						Name = "Ema",
						Size = Vector3.new(1.4, 1, 0.15),
						CFrame = CFrame.new(s.sign * (s.inner + 1.4 + i * 1.8), y, z + dz) * CFrame.Angles(0, 0, rng:NextNumber(-0.15, 0.15)),
						Color = EMA_COLORS[rng:NextInteger(1, #EMA_COLORS)],
						Material = Enum.Material.Wood,
						CanCollide = false,
						Parent = folder,
					})
				end
			end
		end
	end
end

-- 賽銭箱
local function saisenbako(parent: Instance, x: number, z: number)
	local folder = Parts.folder(parent, "Saisenbako")
	part({ Name = "Box", Size = Vector3.new(7, 3.6, 4), Position = Vector3.new(x, 2.3, z), Color = WOOD, Material = Enum.Material.WoodPlanks, Parent = folder })
	for i = -2, 2 do
		part({ Name = "Slat", Size = Vector3.new(6.6, 0.4, 0.5), Position = Vector3.new(x, 4.3, z + i * 0.75), Color = Color3.fromRGB(80, 50, 30), Parent = folder })
	end
	local front = part({ Name = "Front", Size = Vector3.new(4, 1.6, 0.1), CFrame = CFrame.new(x, 2.6, z + 2.06) * CFrame.Angles(0, math.pi, 0), Transparency = 1, CanCollide = false, Parent = folder })
	sign(front, "奉納", GOLD)
end

-- 手水鉢（石の水鉢）
local function basin(parent: Instance, x: number, z: number)
	local folder = Parts.folder(parent, "Basin")
	part({ Name = "Stone", Size = Vector3.new(6, 3, 4.5), Position = Vector3.new(x, 2, z), Color = STONE, Material = Enum.Material.Slate, Parent = folder })
	part({ Name = "Water", Size = Vector3.new(5, 0.2, 3.5), Position = Vector3.new(x, 3.45, z), Color = Color3.fromRGB(70, 140, 190), Material = Enum.Material.Glass, Transparency = 0.3, CanCollide = false, Parent = folder })
	part({ Name = "Ladle", Shape = Enum.PartType.Cylinder, Size = Vector3.new(4, 0.3, 0.3), CFrame = CFrame.new(x + 0.5, 3.8, z) * CFrame.Angles(0, 0.5, 0), Color = Color3.fromRGB(150, 120, 80), CanCollide = false, Parent = folder })
end

function Shrine.obstacle(ctx, o)
	if o.kind == "wall" then
		emaRack(ctx.folder, ctx.halfW, o.side, o.z)
	elseif o.kind == "block" then
		saisenbako(ctx.folder, o.x, o.z)
	elseif o.kind == "round" then
		basin(ctx.folder, o.x, o.z)
	end
end

return Shrine
