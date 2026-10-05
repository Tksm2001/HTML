-- ステージ「渋谷」。スクランブル交差点のような横断歩道とビル街。だるまが見ている間は歩行者信号が赤になる。
local Parts = require(script.Parent.Parent.Parts)
local part, pillar, sign = Parts.part, Parts.pillar, Parts.sign

local Shibuya = {}

Shibuya.name = "渋谷"
Shibuya.nameEn = "SHIBUYA"
Shibuya.floor = { color = Color3.fromRGB(58, 58, 64), material = Enum.Material.Asphalt }
Shibuya.centerLine = { color = Color3.fromRGB(240, 200, 40), material = Enum.Material.SmoothPlastic }
Shibuya.lighting = {
	normal = {
		ClockTime = 18.2,
		Brightness = 1.6,
		Ambient = Color3.fromRGB(75, 65, 85),
		OutdoorAmbient = Color3.fromRGB(125, 105, 125),
		atmosphere = { Density = 0.35, Color = Color3.fromRGB(255, 185, 150), Decay = Color3.fromRGB(120, 80, 120) },
		lights = 2,
	},
	hard = {
		ClockTime = 22,
		Brightness = 0.6,
		Ambient = Color3.fromRGB(45, 45, 75),
		OutdoorAmbient = Color3.fromRGB(55, 55, 95),
		atmosphere = { Density = 0.4, Color = Color3.fromRGB(60, 60, 120), Decay = Color3.fromRGB(30, 30, 70) },
		lights = 4,
	},
}

local WHITE = Color3.fromRGB(235, 235, 235)
local METAL = Color3.fromRGB(150, 155, 160)
local SCREEN_TEXTS = {
	{ "だるまさんが\nころんだ", Color3.fromRGB(255, 60, 160) },
	{ "DARUMA", Color3.fromRGB(40, 200, 255) },
	{ "にげろ！", Color3.fromRGB(255, 200, 30) },
	{ "見てるぞ", Color3.fromRGB(255, 70, 60) },
	{ "福", Color3.fromRGB(120, 255, 120) },
	{ "RUN!", Color3.fromRGB(180, 90, 255) },
}
local SHOP_SIGNS = { "ラーメン", "カラオケ", "古着", "本屋", "喫茶", "薬局" }

local function light(p: BasePart, color: Color3, range: number)
	local pl = Instance.new("PointLight")
	pl.Color = color
	pl.Range = range
	pl.Brightness = 2
	pl.Parent = p
end

-- ビル。field 側の面に窓明かりの帯と、ときどき大きな画面・縦看板
local function building(parent: Instance, rng: Random, sx: number, z: number, index: number)
	local folder = Parts.folder(parent, "Building")
	local w = rng:NextNumber(18, 26)
	local d = 26
	local h = rng:NextNumber(50, 130)
	local front = 42 -- field 側の面の x（絶対値）
	local grays = { Color3.fromRGB(120, 118, 125), Color3.fromRGB(170, 160, 150), Color3.fromRGB(90, 95, 105), Color3.fromRGB(200, 195, 185) }
	part({ Name = "Body", Size = Vector3.new(w, h, d), Position = Vector3.new(sx * (front + w / 2), h / 2, z), Color = grays[rng:NextInteger(1, #grays)], Material = Enum.Material.Concrete, Parent = folder })
	local windowColor = rng:NextNumber() < 0.5 and Color3.fromRGB(255, 235, 190) or Color3.fromRGB(200, 230, 255)
	for y = 8, h - 4, 7 do
		part({ Name = "Windows", Size = Vector3.new(0.3, 2.2, d - 4), Position = Vector3.new(sx * (front - 0.15), y, z), Color = windowColor, Material = Enum.Material.Neon, Transparency = 0.3, CanCollide = false, Parent = folder })
	end
	local look = Vector3.new(-sx, 0, 0) -- field の方向
	if index % 2 == 0 then
		local t = SCREEN_TEXTS[(index // 2) % #SCREEN_TEXTS + 1]
		local screen = Parts.board(folder, Vector3.new(sx * (front - 0.7), 26, z), Vector3.new(d - 4, 14, 0.5), look, t[2], t[1], Color3.new(1, 1, 1), Enum.Material.Neon)
		screen.Name = "Screen"
		light(screen, t[2], 30)
	else
		local text = SHOP_SIGNS[(index // 2) % #SHOP_SIGNS + 1]
		-- 縦書き。日本語は 1 文字が複数バイトなので、utf8 で 1 文字ずつ区切って改行する
		local chars = {}
		for _, c in utf8.codes(text) do
			table.insert(chars, utf8.char(c))
		end
		local vertical = table.concat(chars, "\n")
		local colors = { Color3.fromRGB(230, 40, 40), Color3.fromRGB(30, 90, 200), Color3.fromRGB(240, 170, 20) }
		Parts.board(folder, Vector3.new(sx * (front - 1.5), 18, z + d / 2 - 3), Vector3.new(3.2, 3.2 * #chars, 0.5), look, colors[index % #colors + 1], vertical, Color3.new(1, 1, 1), Enum.Material.Neon)
	end
end

-- 歩行者信号。だるまが見ている間は赤、背を向けている間は青（GameLoop が切り替える）
local function signal(ctx, x: number, z: number)
	local folder = Parts.folder(ctx.folder, "Signal")
	pillar(folder, Vector3.new(x, 5, z), 10, 0.8, METAL, Enum.Material.Metal)
	part({ Name = "Box", Size = Vector3.new(2.2, 4.6, 1.4), Position = Vector3.new(x, 9.6, z), Color = Color3.fromRGB(40, 40, 45), Parent = folder })
	local red = part({ Name = "Red", Size = Vector3.new(1.6, 1.6, 0.3), Position = Vector3.new(x, 10.7, z + 0.8), Color = Color3.fromRGB(60, 20, 20), Material = Enum.Material.Neon, Parent = folder })
	local green = part({ Name = "Green", Size = Vector3.new(1.6, 1.6, 0.3), Position = Vector3.new(x, 8.5, z + 0.8), Color = Color3.fromRGB(20, 60, 40), Material = Enum.Material.Neon, Parent = folder })
	table.insert(ctx.signals, { red = red, green = green })
end

-- 忠犬の銅像
local function dogStatue(parent: Instance, x: number, z: number)
	local folder = Parts.folder(parent, "DogStatue")
	local bronze = Color3.fromRGB(115, 85, 55)
	local m = Enum.Material.Metal
	part({ Name = "Base", Size = Vector3.new(5, 3, 7), Position = Vector3.new(x, 1.5, z), Color = Color3.fromRGB(140, 135, 125), Material = Enum.Material.Granite, Parent = folder })
	part({ Size = Vector3.new(2.4, 2.4, 4.6), Position = Vector3.new(x, 5.4, z), Color = bronze, Material = m, Parent = folder })
	part({ Size = Vector3.new(2, 2, 2.2), Position = Vector3.new(x, 7, z - 2.6), Color = bronze, Material = m, Parent = folder })
	part({ Size = Vector3.new(1.2, 1, 1.4), Position = Vector3.new(x, 6.6, z - 4), Color = bronze, Material = m, Parent = folder })
	for _, dx in { -0.6, 0.6 } do
		part({ Size = Vector3.new(0.5, 0.9, 0.4), Position = Vector3.new(x + dx, 8.4, z - 2.4), Color = bronze, Material = m, Parent = folder })
		for _, dz in { -1.6, 1.6 } do
			part({ Size = Vector3.new(0.6, 2.2, 0.6), Position = Vector3.new(x + dx, 4.1, z + dz), Color = bronze, Material = m, Parent = folder })
		end
	end
	part({ Size = Vector3.new(0.5, 0.5, 1.6), CFrame = CFrame.new(x, 6.4, z + 2.8) * CFrame.Angles(0.8, 0, 0), Color = bronze, Material = m, Parent = folder })
	Parts.board(folder, Vector3.new(x, 1.6, z + 3.55), Vector3.new(3.6, 1.6, 0.1), Vector3.new(0, 0, 1), Color3.fromRGB(140, 135, 125), "忠犬", Color3.fromRGB(40, 40, 40))
end

-- 頭上を通る高架の線路と、行ったり来たりする電車
local function railway(parent: Instance, z: number)
	local folder = Parts.folder(parent, "Railway")
	local y = 25
	part({ Name = "Deck", Size = Vector3.new(600, 2.5, 12), Position = Vector3.new(0, y, z), Color = Color3.fromRGB(110, 110, 115), Material = Enum.Material.Concrete, Parent = folder })
	for _, dz in { -5.7, 5.7 } do
		part({ Name = "Side", Size = Vector3.new(600, 2.4, 0.6), Position = Vector3.new(0, y + 2.4, z + dz), Color = Color3.fromRGB(130, 130, 135), Material = Enum.Material.Concrete, Parent = folder })
	end
	for _, x in { -150, -45, 45, 150 } do
		part({ Name = "Support", Size = Vector3.new(4, y - 1.25, 8), Position = Vector3.new(x, (y - 1.25) / 2, z), Color = Color3.fromRGB(120, 120, 125), Material = Enum.Material.Concrete, Parent = folder })
	end
	local cars = {}
	for i = 0, 3 do
		local car = Parts.folder(folder, "Car")
		local cx = i * 31
		local bodyPart = part({ Name = "Body", Size = Vector3.new(30, 7.5, 8.6), Position = Vector3.new(cx, y + 5, z), Color = Color3.fromRGB(205, 210, 215), Material = Enum.Material.Metal, CanCollide = false, Parent = car })
		local stripe = part({ Name = "Stripe", Size = Vector3.new(30.1, 1, 8.7), Position = Vector3.new(cx, y + 3.4, z), Color = Color3.fromRGB(60, 170, 90), CanCollide = false, Parent = car })
		local window = part({ Name = "Window", Size = Vector3.new(28, 2.4, 8.7), Position = Vector3.new(cx, y + 6.2, z), Color = Color3.fromRGB(40, 50, 60), Material = Enum.Material.Glass, CanCollide = false, Parent = car })
		table.insert(cars, { bodyPart, stripe, window })
	end
	-- 電車を左右に走らせる。ステージが片付けられたら止まる
	task.spawn(function()
		local x0, dir = -300, 1
		while folder.Parent do
			local dt = task.wait()
			x0 += dir * 45 * dt
			if x0 > 300 then
				dir = -1
			elseif x0 < -400 then
				dir = 1
				task.wait(3)
			end
			for i, c in cars do
				for _, p in c do
					p.Position = Vector3.new(x0 + (i - 1) * 31, p.Position.Y, p.Position.Z)
				end
			end
		end
	end)
end

function Shibuya.decorate(ctx)
	local folder, halfW, length = ctx.folder, ctx.halfW, ctx.length
	local rng = Random.new(2026)

	-- 街の地面（芝生を隠す）
	for _, x in { -1, 1 } do
		part({ Name = "Ground", Size = Vector3.new(170, 1, 340), Position = Vector3.new(x * (halfW + 85), -0.3, 0), Color = Color3.fromRGB(70, 70, 76), Material = Enum.Material.Asphalt, Parent = folder })
	end
	part({ Name = "Ground", Size = Vector3.new(400, 1, 120), Position = Vector3.new(0, -0.3, -length / 2 - 60), Color = Color3.fromRGB(70, 70, 76), Material = Enum.Material.Asphalt, Parent = folder })
	part({ Name = "Ground", Size = Vector3.new(400, 1, 60), Position = Vector3.new(0, -0.3, length / 2 + 30), Color = Color3.fromRGB(70, 70, 76), Material = Enum.Material.Asphalt, Parent = folder })
	-- 歩道
	for _, x in { -1, 1 } do
		part({ Name = "Sidewalk", Size = Vector3.new(10, 1.2, length + 40), Position = Vector3.new(x * (halfW + 6), 0.1, 0), Color = Color3.fromRGB(175, 170, 160), Material = Enum.Material.Pavement, Parent = folder })
	end

	-- 横断歩道（しま模様）3 本と、道の端の白線
	for _, z in { 72, 2, -60 } do
		for x = -halfW + 2, halfW - 2, 3.2 do
			part({ Name = "Zebra", Size = Vector3.new(1.7, 0.05, 10), Position = Vector3.new(x, 0.53, z), Color = WHITE, CanCollide = false, CanQuery = false, Parent = folder })
		end
	end
	for _, x in { -halfW + 0.8, halfW - 0.8 } do
		part({ Name = "EdgeLine", Size = Vector3.new(0.5, 0.05, length), Position = Vector3.new(x, 0.53, 0), Color = WHITE, CanCollide = false, CanQuery = false, Parent = folder })
	end

	-- ガードレール
	for _, x in { -halfW - 1, halfW + 1 } do
		local rail = Parts.folder(folder, "Guardrail")
		for z = -length / 2, length / 2, 6 do
			part({ Size = Vector3.new(0.6, 3.2, 0.6), Position = Vector3.new(x, 1.6, z), Color = METAL, Material = Enum.Material.Metal, Parent = rail })
		end
		for _, y in { 1.7, 3 } do
			part({ Size = Vector3.new(0.4, 0.8, length), Position = Vector3.new(x, y, 0), Color = WHITE, Material = Enum.Material.Metal, Parent = rail })
		end
	end

	-- ビル街
	local i = 0
	for _, sx in { -1, 1 } do
		for z = -100, 110, 30 do
			i += 1
			building(folder, rng, sx, z, i)
		end
	end
	-- だるまの後ろの大きなビルと大画面
	local back = ctx.darumaZ - 60
	part({ Name = "BackTower", Size = Vector3.new(130, 150, 40), Position = Vector3.new(0, 75, back), Color = Color3.fromRGB(95, 100, 110), Material = Enum.Material.Concrete, Parent = folder })
	for y = 8, 146, 7 do
		part({ Name = "Windows", Size = Vector3.new(126, 2.2, 0.3), Position = Vector3.new(0, y, back + 20.15), Color = Color3.fromRGB(255, 235, 190), Material = Enum.Material.Neon, Transparency = 0.3, CanCollide = false, Parent = folder })
	end
	local big = Parts.board(folder, Vector3.new(0, 62, back + 20.8), Vector3.new(80, 36, 1), Vector3.new(0, 0, 1), Color3.fromRGB(255, 40, 120), "だるまさんが\nころんだ", Color3.new(1, 1, 1), Enum.Material.Neon)
	light(big, Color3.fromRGB(255, 80, 160), 60)

	-- 高架の線路（だるまとスタートの間の上空）
	railway(folder, -45)

	-- 歩行者信号（横断歩道の手前）
	for _, z in { 78, 8, -54 } do
		signal(ctx, -halfW - 3, z)
		signal(ctx, halfW + 3, z)
	end

	-- 街灯
	for z = -80, 80, 40 do
		for _, x in { -halfW - 9, halfW + 9 } do
			local lamp = Parts.folder(folder, "StreetLamp")
			pillar(lamp, Vector3.new(x, 6, z), 12, 0.6, METAL, Enum.Material.Metal)
			local bulb = part({ Size = Vector3.new(2, 0.8, 2), Position = Vector3.new(x, 12.2, z), Color = Color3.fromRGB(255, 240, 200), Material = Enum.Material.Neon, Parent = lamp })
			light(bulb, Color3.fromRGB(255, 230, 190), 22)
		end
	end

	-- 忠犬の銅像（スタート地点の左の歩道）
	dogStatue(folder, -halfW - 6, 88)
end

-- バス: 道をふさぐ障害物（wall）
local function bus(parent: Instance, halfW: number, side: string, z: number)
	local folder = Parts.folder(parent, "Bus")
	local s = Parts.wallSpan(halfW, side)
	-- 高さ 8（ジャンプでは越えられないが、だるまの顔は上から見える）
	part({ Name = "Body", Size = Vector3.new(s.length, 8, 5), Position = Vector3.new(s.cx, 4.5, z), Color = Color3.fromRGB(240, 240, 238), Parent = folder })
	part({ Name = "Stripe", Size = Vector3.new(s.length + 0.1, 1.2, 5.1), Position = Vector3.new(s.cx, 3, z), Color = Color3.fromRGB(40, 160, 90), CanCollide = false, Parent = folder })
	part({ Name = "Windows", Size = Vector3.new(s.length - 2, 2.6, 5.1), Position = Vector3.new(s.cx, 6, z), Color = Color3.fromRGB(40, 50, 60), Material = Enum.Material.Glass, CanCollide = false, Parent = folder })
	for _, f in { -0.38, 0.38 } do
		part({
			Name = "Wheel",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(5.4, 2.6, 2.6),
			CFrame = CFrame.new(s.cx + f * s.length, 1.6, z) * CFrame.Angles(0, math.pi / 2, 0),
			Color = Color3.fromRGB(25, 25, 25),
			CanCollide = false,
			Parent = folder,
		})
	end
end

-- タクシー（block）
local function taxi(parent: Instance, x: number, z: number)
	local folder = Parts.folder(parent, "Taxi")
	part({ Name = "Body", Size = Vector3.new(7, 2.6, 4), Position = Vector3.new(x, 2, z), Color = Color3.fromRGB(240, 200, 40), Parent = folder })
	part({ Name = "Cabin", Size = Vector3.new(4, 1.8, 3.6), Position = Vector3.new(x - 0.3, 4.2, z), Color = Color3.fromRGB(50, 55, 65), Material = Enum.Material.Glass, Parent = folder })
	local roof = part({ Name = "RoofSign", Size = Vector3.new(1.6, 0.7, 0.8), Position = Vector3.new(x - 0.3, 5.45, z), Color = Color3.fromRGB(255, 250, 230), Material = Enum.Material.Neon, Parent = folder })
	sign(roof, "TAXI", Color3.fromRGB(30, 30, 30), Enum.NormalId.Back)
	for _, dx in { -2.4, 2.4 } do
		part({ Name = "Wheel", Shape = Enum.PartType.Cylinder, Size = Vector3.new(4.2, 1.6, 1.6), CFrame = CFrame.new(x + dx, 1.3, z) * CFrame.Angles(0, math.pi / 2, 0), Color = Color3.fromRGB(25, 25, 25), CanCollide = false, Parent = folder })
	end
end

-- 工事中のコーンと看板（round）
local function cones(parent: Instance, x: number, z: number)
	local folder = Parts.folder(parent, "Cones")
	local orange = Color3.fromRGB(255, 110, 20)
	for _, dx in { -2, 2 } do
		part({ Name = "ConeBase", Size = Vector3.new(1.8, 0.3, 1.8), Position = Vector3.new(x + dx, 0.65, z), Color = orange, Parent = folder })
		for k, w in { 1.4, 1.1, 0.8, 0.5 } do
			pillar(folder, Vector3.new(x + dx, 0.8 + (k - 0.5) * 0.7, z), 0.7, w, k == 3 and WHITE or orange)
		end
	end
	local board = Parts.board(folder, Vector3.new(x, 2.2, z), Vector3.new(4.6, 1.4, 0.3), Vector3.new(0, 0, 1), Color3.fromRGB(250, 210, 30), "工事中", Color3.fromRGB(20, 20, 20))
	board.Name = "Barrier"
end

function Shibuya.obstacle(ctx, o)
	if o.kind == "wall" then
		bus(ctx.folder, ctx.halfW, o.side, o.z)
	elseif o.kind == "block" then
		taxi(ctx.folder, o.x, o.z)
	elseif o.kind == "round" then
		cones(ctx.folder, o.x, o.z)
	end
end

return Shibuya
