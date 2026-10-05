-- ステージ「富士山」。登山道の奥、湖の向こうに富士山がそびえる。五重塔と松・紅葉。
local Parts = require(script.Parent.Parent.Parts)
local part, pillar, ball = Parts.part, Parts.pillar, Parts.ball
local WOOD, VERMILION, GOLD = Parts.WOOD, Parts.VERMILION, Parts.GOLD

local Fuji = {}

Fuji.name = "富士山"
Fuji.nameEn = "MT. FUJI"
Fuji.floor = { color = Color3.fromRGB(165, 150, 125), material = Enum.Material.Pebble }
Fuji.centerLine = { color = Color3.fromRGB(210, 190, 140), material = Enum.Material.Fabric }
Fuji.lighting = {
	normal = {
		ClockTime = 10.5,
		Brightness = 2.5,
		Ambient = Color3.fromRGB(90, 95, 110),
		OutdoorAmbient = Color3.fromRGB(140, 150, 170),
		atmosphere = { Density = 0.12, Color = Color3.fromRGB(200, 220, 255), Decay = Color3.fromRGB(120, 150, 200) },
		lights = 1,
	},
	hard = {
		ClockTime = 21,
		Brightness = 0.8,
		Ambient = Color3.fromRGB(40, 45, 70),
		OutdoorAmbient = Color3.fromRGB(60, 70, 110),
		atmosphere = { Density = 0.25, Color = Color3.fromRGB(80, 90, 140), Decay = Color3.fromRGB(30, 40, 80) },
		lights = 3,
	},
}

local ROPE = Color3.fromRGB(210, 190, 140)

-- 富士山。円柱を下から積んで、すそ野が広がる形にする。上の方は雪
local function mountFuji(parent: Instance, z: number)
	local folder = Parts.folder(parent, "MtFuji")
	local R, H, step = 470, 390, 6
	for y = 0, H, step do
		local t = y / H
		local r = R * (1 - t) ^ 1.5 + 22 -- 頂上は少し平ら
		local snow = t > 0.68
		pillar(folder, Vector3.new(0, y + step / 2, z), step, r * 2,
			snow and Color3.fromRGB(245, 248, 255) or Color3.fromRGB(78, 92, 125),
			snow and Enum.Material.Snow or Enum.Material.Rock)
	end
end

-- 五重塔
local function pagoda(parent: Instance, x: number, z: number)
	local folder = Parts.folder(parent, "Pagoda")
	part({ Name = "Base", Size = Vector3.new(18, 2, 18), Position = Vector3.new(x, 1, z), Color = Color3.fromRGB(150, 145, 135), Material = Enum.Material.Slate, Parent = folder })
	local y = 2
	for i = 0, 4 do
		local w = 12 - i * 1.3
		part({ Name = "Body", Size = Vector3.new(w, 5, w), Position = Vector3.new(x, y + 2.5, z), Color = VERMILION, Parent = folder })
		part({ Name = "Roof", Size = Vector3.new(w + 8, 0.9, w + 8), Position = Vector3.new(x, y + 5.4, z), Color = Color3.fromRGB(55, 45, 45), Material = Enum.Material.Slate, Parent = folder })
		y += 5.9
	end
	pillar(folder, Vector3.new(x, y + 4, z), 8, 0.8, GOLD, Enum.Material.Metal)
end

local function pine(parent: Instance, x: number, z: number, scale: number)
	local folder = Parts.folder(parent, "Pine")
	pillar(folder, Vector3.new(x, 5 * scale, z), 10 * scale, 1.6 * scale, Color3.fromRGB(90, 60, 40), Enum.Material.Wood)
	local green = Color3.fromRGB(45, 95, 55)
	for k, w in { 9, 7, 5, 3 } do
		part({ Size = Vector3.new(w, 2.4, w) * scale, Position = Vector3.new(x, (6 + k * 2.6) * scale, z), Color = green, Material = Enum.Material.LeafyGrass, CanCollide = false, Parent = folder })
	end
end

local function maple(parent: Instance, x: number, z: number, scale: number)
	local folder = Parts.folder(parent, "Maple")
	pillar(folder, Vector3.new(x, 4.5 * scale, z), 9 * scale, 1.5 * scale, Color3.fromRGB(85, 55, 40), Enum.Material.Wood)
	local colors = { Color3.fromRGB(220, 60, 30), Color3.fromRGB(240, 130, 30), Color3.fromRGB(200, 40, 40) }
	for k, o in { Vector3.new(0, 10, 0), Vector3.new(3, 8.5, 1), Vector3.new(-3, 9, -1), Vector3.new(0, 12.5, 0.5) } do
		ball(folder, Vector3.new(x, 0, z) + o * scale, (k == 4 and 5 or 7) * scale, colors[(k - 1) % #colors + 1], Enum.Material.Grass)
	end
end

-- 山小屋（だるまの後ろ）
local function hut(parent: Instance, z: number)
	local folder = Parts.folder(parent, "Hut")
	part({ Name = "Walls", Size = Vector3.new(34, 11, 16), Position = Vector3.new(0, 5.5, z), Color = WOOD, Material = Enum.Material.WoodPlanks, Parent = folder })
	for _, s in { 1, -1 } do
		part({
			Name = "Roof",
			Size = Vector3.new(38, 1.2, 11),
			CFrame = CFrame.new(0, 14 - 5.5 * math.sin(0.5), z + s * 5.5 * math.cos(0.5)) * CFrame.Angles(s * 0.5, 0, 0),
			Color = Color3.fromRGB(60, 70, 80),
			Material = Enum.Material.CorrodedMetal,
			Parent = folder,
		})
	end
	local signBoard = Parts.board(folder, Vector3.new(0, 8.5, z + 8.3), Vector3.new(14, 3.2, 0.4), Vector3.new(0, 0, 1), Color3.fromRGB(70, 45, 30), "五合目", Color3.fromRGB(250, 240, 220), Enum.Material.Wood)
	signBoard.Name = "Sign"
	local lamp = part({ Size = Vector3.new(1.6, 1.6, 1.6), Position = Vector3.new(9, 9, z + 8.6), Color = Color3.fromRGB(255, 210, 140), Material = Enum.Material.Neon, Parent = folder })
	local pl = Instance.new("PointLight")
	pl.Color = Color3.fromRGB(255, 200, 130)
	pl.Range = 24
	pl.Parent = lamp
end

-- 登山道の行灯
local function trailLamp(parent: Instance, x: number, z: number)
	local folder = Parts.folder(parent, "TrailLamp")
	pillar(folder, Vector3.new(x, 2.5, z), 5, 0.6, WOOD, Enum.Material.Wood)
	local lamp = part({ Size = Vector3.new(1.6, 2, 1.6), Position = Vector3.new(x, 6, z), Color = Color3.fromRGB(255, 220, 160), Material = Enum.Material.Neon, Transparency = 0.1, Parent = folder })
	local pl = Instance.new("PointLight")
	pl.Color = Color3.fromRGB(255, 200, 130)
	pl.Range = 16
	pl.Parent = lamp
end

function Fuji.decorate(ctx)
	local folder, halfW, length = ctx.folder, ctx.halfW, ctx.length

	-- 遠くまで続く草原（芝生の板の外側も埋める）と湖
	part({ Name = "Meadow", Size = Vector3.new(2048, 1, 2048), Position = Vector3.new(0, -0.6, -500), Color = Color3.fromRGB(95, 135, 70), Material = Enum.Material.Grass, Parent = folder })
	part({ Name = "Lake", Size = Vector3.new(1100, 0.3, 240), Position = Vector3.new(0, 0.05, -400), Color = Color3.fromRGB(60, 115, 165), Material = Enum.Material.Glass, Reflectance = 0.25, Transparency = 0.1, CanCollide = false, Parent = folder })
	mountFuji(folder, -900)

	-- ロープの柵
	for _, x in { -halfW - 1, halfW + 1 } do
		local fence = Parts.folder(folder, "RopeFence")
		for z = -length / 2, length / 2, 8 do
			pillar(fence, Vector3.new(x, 1.75, z), 3.5, 0.8, WOOD, Enum.Material.Wood)
		end
		for _, y in { 1.6, 3 } do
			part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(length, 0.35, 0.35), CFrame = CFrame.new(x, y, 0) * CFrame.Angles(0, math.pi / 2, 0), Color = ROPE, Material = Enum.Material.Fabric, CanCollide = false, Parent = fence })
		end
	end

	-- 五重塔、松、紅葉
	pagoda(folder, -halfW - 32, -45)
	local rng = Random.new(3776)
	for z = -95, 95, 19 do
		for _, sx in { -1, 1 } do
			local x = sx * (halfW + rng:NextNumber(9, 24))
			if not (sx < 0 and z > -70 and z < -20) then -- 五重塔の場所はあける
				if rng:NextNumber() < 0.55 then
					pine(folder, x, z + rng:NextNumber(-4, 4), rng:NextNumber(0.9, 1.3))
				else
					maple(folder, x, z + rng:NextNumber(-4, 4), rng:NextNumber(0.9, 1.2))
				end
			end
		end
	end
	for z = -80, 80, 40 do
		trailLamp(folder, -halfW - 4, z)
		trailLamp(folder, halfW + 4, z + 20)
	end

	-- 山小屋（だるまの後ろ）と登山口の看板
	hut(folder, ctx.darumaZ - 30)
	local post = Parts.folder(folder, "Trailhead")
	pillar(post, Vector3.new(halfW + 6, 3, 80), 6, 0.8, WOOD, Enum.Material.Wood)
	Parts.board(post, Vector3.new(halfW + 6, 6.5, 80.5), Vector3.new(6, 4, 0.4), Vector3.new(0, 0, 1), Color3.fromRGB(120, 85, 55), "富士山\n登山口", Color3.fromRGB(250, 245, 230), Enum.Material.Wood)
end

-- 丸太の柵（wall）
local function logFence(parent: Instance, halfW: number, side: string, z: number)
	local folder = Parts.folder(parent, "LogFence")
	local s = Parts.wallSpan(halfW, side)
	local browns = { Color3.fromRGB(120, 85, 55), Color3.fromRGB(135, 95, 60), Color3.fromRGB(110, 75, 50) }
	for k, y in { 1.6, 3.7, 5.8, 7.9 } do
		part({ Name = "Log", Shape = Enum.PartType.Cylinder, Size = Vector3.new(s.length, 2.2, 2.2), Position = Vector3.new(s.cx, y, z), Color = browns[k % #browns + 1], Material = Enum.Material.Wood, Parent = folder })
	end
	for _, f in { -0.5, 0, 0.5 } do
		for _, dz in { -1.4, 1.4 } do
			pillar(folder, Vector3.new(s.cx + f * (s.length - 1), 4.75, z + dz), 9.5, 0.8, Color3.fromRGB(90, 60, 40), Enum.Material.Wood)
		end
	end
end

-- 大きな岩（block）
local function boulder(parent: Instance, x: number, z: number)
	local folder = Parts.folder(parent, "Boulder")
	local gray = Color3.fromRGB(120, 118, 112)
	ball(folder, Vector3.new(x, 2.4, z), 6, gray, Enum.Material.Slate, true)
	ball(folder, Vector3.new(x + 2.6, 1.8, z + 0.6), 4, Color3.fromRGB(105, 103, 98), Enum.Material.Slate, true)
	ball(folder, Vector3.new(x - 2.4, 1.4, z - 0.8), 3, gray, Enum.Material.Slate, true)
end

-- お地蔵さん（round）
local function jizo(parent: Instance, x: number, z: number)
	local folder = Parts.folder(parent, "Jizo")
	local stone = Color3.fromRGB(150, 148, 140)
	for _, dx in { -1.6, 1.6 } do
		part({ Name = "Base", Size = Vector3.new(3, 1, 3), Position = Vector3.new(x + dx, 1, z), Color = stone, Material = Enum.Material.Slate, Parent = folder })
		pillar(folder, Vector3.new(x + dx, 2.9, z), 2.8, 2, stone, Enum.Material.Slate)
		ball(folder, Vector3.new(x + dx, 4.9, z), 1.8, stone, Enum.Material.Slate, true)
		-- 赤いよだれかけ
		part({ Name = "Bib", Size = Vector3.new(1.8, 1.2, 0.2), Position = Vector3.new(x + dx, 3.6, z + 1.05), Color = Color3.fromRGB(200, 30, 30), Material = Enum.Material.Fabric, CanCollide = false, Parent = folder })
	end
end

function Fuji.obstacle(ctx, o)
	if o.kind == "wall" then
		logFence(ctx.folder, ctx.halfW, o.side, o.z)
	elseif o.kind == "block" then
		boulder(ctx.folder, o.x, o.z)
	elseif o.kind == "round" then
		jizo(ctx.folder, o.x, o.z)
	end
end

return Fuji
