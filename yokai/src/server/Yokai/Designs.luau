-- 妖怪の見た目。全部コードで部品から組む。
-- かわいさの共通ルール: 丸い体、大きな目（白目＋黒目＋光）、ほっぺの赤み、小さい手足。1 体に 1 つ、遠くから分かる特徴。
-- 座標: cf を足元の中心とし、-Z が正面。

local Designs = {}

local BLACK = Color3.fromRGB(30, 28, 30)
local WHITE = Color3.fromRGB(250, 250, 250)
local PINK = Color3.fromRGB(255, 150, 170)
local SKIN = Color3.fromRGB(255, 220, 195)

-- 基本の部品。球は SpecialMesh で楕円にできる
local function piece(model: Model, name: string, cf: CFrame, size: Vector3, color: Color3, shape: string?, material: Enum.Material?): BasePart
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape == "ball" or shape == nil then
		local m = Instance.new("SpecialMesh")
		m.MeshType = Enum.MeshType.Sphere
		m.Parent = p
	elseif shape == "cyl" then
		p.Shape = Enum.PartType.Cylinder
	elseif shape == "wedge" then
		local w = Instance.new("WedgePart")
		w.Name = name
		w.Size = size
		w.CFrame = cf
		w.Color = color
		w.Material = p.Material
		w.Anchored = true
		w.CanCollide = false
		w.CanQuery = false
		w.Parent = model
		p:Destroy()
		return w
	end
	p.Parent = model
	return p
end

local function ball(model, name, cf, size, color, material)
	return piece(model, name, cf, size, color, "ball", material)
end
local function box(model, name, cf, size, color, material)
	return piece(model, name, cf, size, color, "box", material)
end
-- 縦向きの円柱（長さ length、太さ radius）
local function cylY(model, name, cf, length, radius, color, material)
	return piece(model, name, cf * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(length, radius * 2, radius * 2), color, "cyl", material)
end
-- 前向き（-Z）の円柱
local function cylZ(model, name, cf, length, radius, color, material)
	return piece(model, name, cf * CFrame.Angles(0, math.pi / 2, 0), Vector3.new(length, radius * 2, radius * 2), color, "cyl", material)
end

-- 目。center = 目の中心、r = 白目の半径。style = "open" / "happy"（にっこり）
local function eye(model, cf: CFrame, center: Vector3, r: number, style: string?)
	if style == "happy" then
		-- にっこり目: 短い棒 2 本で「^」
		for _, s in { -1, 1 } do
			piece(model, "Eye", cf * CFrame.new(center + Vector3.new(s * r * 0.45, 0, 0)) * CFrame.Angles(0, 0, s * 0.9) * CFrame.Angles(0, 0, math.pi / 2),
				Vector3.new(r * 1.1, r * 0.35, r * 0.25), BLACK, "cyl")
		end
		return
	end
	ball(model, "EyeWhite", cf * CFrame.new(center), Vector3.new(r * 2, r * 2.1, r * 1.2), WHITE)
	ball(model, "Pupil", cf * CFrame.new(center + Vector3.new(0, -r * 0.05, -r * 0.42)), Vector3.new(r * 1.15, r * 1.25, r * 0.6), BLACK)
	ball(model, "Shine", cf * CFrame.new(center + Vector3.new(-r * 0.3, r * 0.35, -r * 0.7)), Vector3.new(r * 0.45, r * 0.45, r * 0.25), WHITE)
	ball(model, "Shine", cf * CFrame.new(center + Vector3.new(r * 0.25, -r * 0.25, -r * 0.7)), Vector3.new(r * 0.2, r * 0.2, r * 0.2), WHITE)
end

local function blush(model, cf: CFrame, center: Vector3, w: number)
	ball(model, "Blush", cf * CFrame.new(center), Vector3.new(w, w * 0.55, 0.12), PINK)
end

-- 口。kind = "w"（ねこ口）/ "o"（まる口）/ "open"（あーん。舌つき）/ "smile"
local function mouth(model, cf: CFrame, center: Vector3, w: number, kind: string?)
	if kind == "open" then
		ball(model, "Mouth", cf * CFrame.new(center), Vector3.new(w, w * 0.9, 0.3), BLACK)
		ball(model, "Tongue", cf * CFrame.new(center + Vector3.new(0, -w * 0.25, -0.05)), Vector3.new(w * 0.55, w * 0.45, 0.3), PINK)
	elseif kind == "o" then
		ball(model, "Mouth", cf * CFrame.new(center), Vector3.new(w * 0.5, w * 0.5, 0.2), BLACK)
	elseif kind == "smile" then
		piece(model, "Mouth", cf * CFrame.new(center) * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(w * 0.18, w, w * 0.18), BLACK, "cyl")
	else
		for _, s in { -1, 1 } do
			piece(model, "Mouth", cf * CFrame.new(center + Vector3.new(s * w * 0.25, 0, 0)) * CFrame.Angles(0, 0, -s * 0.7) * CFrame.Angles(0, 0, math.pi / 2),
				Vector3.new(w * 0.5, w * 0.16, w * 0.16), BLACK, "cyl")
		end
	end
end

-- 丸い体の表面に、目・ほっぺ・口をまとめて置く。center = 体の中心、r = 体の半径（前後）
local function face(model, cf, center: Vector3, r: number, o)
	o = o or {}
	local er = o.eyeR or r * 0.3
	local ex = o.eyeX or r * 0.4
	local ey = o.eyeY or r * 0.15
	local front = center.Z - r * 0.78
	if o.eyes ~= 1 then
		eye(model, cf, Vector3.new(center.X - ex, center.Y + ey, front - er * 0.3), er, o.eyeStyle)
		eye(model, cf, Vector3.new(center.X + ex, center.Y + ey, front - er * 0.3), er, o.eyeStyle)
	else
		eye(model, cf, Vector3.new(center.X, center.Y + ey, front - er * 0.3), er, o.eyeStyle)
	end
	if o.blush ~= false then
		local bx = o.blushX or (ex + er * 1.1)
		blush(model, cf, Vector3.new(center.X - bx, center.Y + ey - er * 1.1, front), er * 1.1)
		blush(model, cf, Vector3.new(center.X + bx, center.Y + ey - er * 1.1, front), er * 1.1)
	end
	if o.mouth ~= false then
		mouth(model, cf, Vector3.new(center.X, center.Y + (o.mouthY or (ey - er * 1.6)), front - 0.05), o.mouthW or er * 1.2, o.mouth)
	end
end

-- ちいさな手足
local function stubs(model, cf, color, bodyY: number, bodyR: number, o)
	o = o or {}
	local s = o.size or bodyR * 0.4
	-- 手
	for _, side in { -1, 1 } do
		ball(model, "Arm", cf * CFrame.new(side * (bodyR * 0.95), bodyY - bodyR * 0.1, -bodyR * 0.2), Vector3.new(s, s * 0.9, s), color)
	end
	-- 足
	if o.feet ~= false then
		for _, side in { -1, 1 } do
			ball(model, "Foot", cf * CFrame.new(side * (bodyR * 0.45), s * 0.35, -bodyR * 0.15), Vector3.new(s * 1.1, s * 0.7, s * 1.3), o.footColor or color)
		end
	end
end

-- ========== 各妖怪 ==========
local builders = {}

-- かっぱ: 頭のお皿、くちばし、甲羅、きゅうり
builders.kappa = function(m, cf)
	local green = Color3.fromRGB(110, 190, 90)
	local dark = Color3.fromRGB(70, 140, 70)
	local r = 1.3
	local c = Vector3.new(0, 1.65, 0)
	ball(m, "Body", cf * CFrame.new(c), Vector3.new(2.6, 2.9, 2.4), green)
	-- 甲羅
	ball(m, "Shell", cf * CFrame.new(0, 1.7, 0.75), Vector3.new(2.2, 2.3, 1.3), Color3.fromRGB(150, 110, 60))
	ball(m, "ShellRim", cf * CFrame.new(0, 1.7, 0.6), Vector3.new(2.5, 2.6, 1.1), Color3.fromRGB(190, 150, 90))
	-- 髪（お皿のまわり）
	for i = 0, 7 do
		local a = i / 8 * math.pi * 2
		ball(m, "Hair", cf * CFrame.new(math.cos(a) * 0.95, 2.85, math.sin(a) * 0.95), Vector3.new(0.5, 0.45, 0.5), dark)
	end
	-- お皿（特徴）
	cylY(m, "Dish", cf * CFrame.new(0, 3.05, 0), 0.16, 0.85, Color3.fromRGB(230, 220, 150))
	cylY(m, "Water", cf * CFrame.new(0, 3.14, 0), 0.08, 0.7, Color3.fromRGB(140, 210, 255), Enum.Material.Glass)
	-- くちばし
	ball(m, "Beak", cf * CFrame.new(0, 1.35, -1.25), Vector3.new(1.1, 0.5, 0.8), Color3.fromRGB(255, 200, 70))
	face(m, cf, c, r, { eyeR = 0.4, eyeX = 0.52, eyeY = 0.3, mouth = false, blushX = 1.0 })
	stubs(m, cf, green, 1.5, r)
	-- きゅうり
	cylZ(m, "Cucumber", cf * CFrame.new(1.35, 1.5, -0.6) * CFrame.Angles(0.5, 0, 0), 1.3, 0.2, Color3.fromRGB(60, 150, 60))
end

-- たぬき: 笠と葉っぱ、大きなおなか、しま模様のしっぽ
builders.tanuki = function(m, cf)
	local brown = Color3.fromRGB(150, 105, 65)
	local dark = Color3.fromRGB(85, 55, 35)
	local cream = Color3.fromRGB(245, 225, 190)
	local r = 1.4
	local c = Vector3.new(0, 1.7, 0)
	ball(m, "Body", cf * CFrame.new(c), Vector3.new(2.9, 3.1, 2.7), brown)
	ball(m, "Belly", cf * CFrame.new(0, 1.25, -1.05), Vector3.new(2.0, 2.0, 0.9), cream)
	-- 目のまわりの模様
	for _, s in { -1, 1 } do
		ball(m, "Mask", cf * CFrame.new(s * 0.6, 2.05, -1.1), Vector3.new(1.0, 0.8, 0.4), dark)
	end
	-- 耳
	for _, s in { -1, 1 } do
		ball(m, "Ear", cf * CFrame.new(s * 0.9, 3.0, 0.1), Vector3.new(0.6, 0.6, 0.4), brown)
	end
	-- 笠（特徴）: 円柱を重ねて三角に。目にかぶらないよう、小さめで後ろ寄り
	for i, rad in { 1.4, 1.1, 0.8, 0.45 } do
		cylY(m, "Hat", cf * CFrame.new(0, 3.3 + (i - 1) * 0.2, 0.25) * CFrame.Angles(-0.15, 0, 0), 0.22, rad, Color3.fromRGB(215, 185, 120))
	end
	ball(m, "Leaf", cf * CFrame.new(0.3, 4.1, 0.1) * CFrame.Angles(0, 0, 0.4), Vector3.new(0.9, 0.45, 0.1), Color3.fromRGB(90, 170, 80))
	-- しっぽ
	for i, col in { brown, dark, brown, dark } do
		ball(m, "Tail", cf * CFrame.new(0.9 + i * 0.25, 0.9 + i * 0.15, 1.2 + i * 0.2), Vector3.new(0.8, 0.8, 0.8), col)
	end
	face(m, cf, c, r, { eyeR = 0.38, eyeX = 0.6, eyeY = 0.35, mouth = "w", mouthW = 0.6, blushX = 1.2 })
	stubs(m, cf, brown, 1.4, r)
end

-- からかさ: 傘の体、ひとつ目、長い舌、一本足に下駄
builders.karakasa = function(m, cf)
	local paper = Color3.fromRGB(240, 225, 190)
	-- 一本足（持ち手）と下駄
	cylY(m, "Leg", cf * CFrame.new(0, 1.2, 0), 1.8, 0.16, Color3.fromRGB(120, 80, 50))
	box(m, "Geta", cf * CFrame.new(0, 0.35, -0.05), Vector3.new(0.8, 0.25, 1.3), Color3.fromRGB(190, 150, 100))
	for _, dz in { -0.4, 0.4 } do
		box(m, "GetaTooth", cf * CFrame.new(0, 0.12, dz), Vector3.new(0.8, 0.25, 0.2), Color3.fromRGB(150, 110, 70))
	end
	-- 傘（特徴）: 細かい段で、なめらかな三角に。紙の色が基本で、赤い帯を 1 本
	local steps = 9
	for i = 0, steps - 1 do
		local t = i / (steps - 1)
		local rad = 1.8 * (1 - t) ^ 0.8 + 0.15
		local col = (i == 2) and Color3.fromRGB(205, 60, 60) or paper
		cylY(m, "Canopy", cf * CFrame.new(0, 2.0 + i * 0.2, 0), 0.22, rad, col)
	end
	cylY(m, "Tip", cf * CFrame.new(0, 3.85, 0), 0.3, 0.15, Color3.fromRGB(120, 80, 50))
	-- 顔は傘の前面に
	eye(m, cf, Vector3.new(0, 2.5, -1.5), 0.5, "open")
	blush(m, cf, Vector3.new(-0.75, 2.05, -1.45), 0.45)
	blush(m, cf, Vector3.new(0.75, 2.05, -1.45), 0.45)
	mouth(m, cf, Vector3.new(0, 1.85, -1.6), 0.6, "open")
	-- 長い舌
	ball(m, "LongTongue", cf * CFrame.new(0, 1.45, -1.55) * CFrame.Angles(0.25, 0, 0), Vector3.new(0.45, 1.1, 0.25), PINK)
	-- 腕（傘の下から）
	for _, s in { -1, 1 } do
		ball(m, "Arm", cf * CFrame.new(s * 1.25, 1.75, -0.4), Vector3.new(0.45, 0.4, 0.45), paper)
	end
end

-- ちょうちんおばけ: 赤い提灯の体、ひとつ目、あーんと開いた口、光る
builders.chochin = function(m, cf)
	local red = Color3.fromRGB(230, 70, 60)
	local dark = Color3.fromRGB(150, 35, 35)
	local c = Vector3.new(0, 2.0, 0)
	local body = ball(m, "Body", cf * CFrame.new(c), Vector3.new(2.5, 3.0, 2.5), red)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 190, 120)
	light.Range = 10
	light.Brightness = 1.5
	light.Parent = body
	-- 提灯のひだ
	for i = -2, 2 do
		local y = 2.0 + i * 0.5
		local rad = math.sqrt(math.max(0.05, 1 - (i * 0.5 / 1.5) ^ 2)) * 1.27
		cylY(m, "Ridge", cf * CFrame.new(0, y, 0), 0.08, rad, dark)
	end
	-- 上下の木枠と持ち手
	cylY(m, "Cap", cf * CFrame.new(0, 3.55, 0), 0.3, 0.75, BLACK)
	cylY(m, "Cap", cf * CFrame.new(0, 0.45, 0), 0.3, 0.75, BLACK)
	cylZ(m, "Handle", cf * CFrame.new(0, 3.95, 0), 0.9, 0.08, BLACK)
	-- 顔（特徴: ひとつ目とあーん）
	eye(m, cf, Vector3.new(0, 2.55, -1.15), 0.5)
	blush(m, cf, Vector3.new(-0.85, 2.1, -1.0), 0.5)
	blush(m, cf, Vector3.new(0.85, 2.1, -1.0), 0.5)
	mouth(m, cf, Vector3.new(0, 1.6, -1.25), 0.9, "open")
	ball(m, "LongTongue", cf * CFrame.new(0, 1.05, -1.25) * CFrame.Angles(0.3, 0, 0), Vector3.new(0.55, 1.2, 0.25), PINK)
end

-- きつね: 大きな頭、赤い隈取り、とがった耳、ふさふさの 3 本しっぽ
builders.kitsune = function(m, cf)
	local white = Color3.fromRGB(252, 248, 240)
	local orange = Color3.fromRGB(255, 160, 70)
	local red = Color3.fromRGB(220, 50, 50)
	ball(m, "Body", cf * CFrame.new(0, 1.2, 0), Vector3.new(2.0, 2.2, 1.8), white)
	-- 赤い首かざり
	cylY(m, "Collar", cf * CFrame.new(0, 2.1, 0), 0.3, 0.95, red)
	local hc = Vector3.new(0, 3.0, -0.1)
	local hr = 1.1
	ball(m, "Head", cf * CFrame.new(hc), Vector3.new(2.3, 2.1, 2.1), white)
	-- 耳（特徴）。耳の先だけ赤
	for _, s in { -1, 1 } do
		ball(m, "Ear", cf * CFrame.new(s * 0.75, 3.95, 0) * CFrame.Angles(0, 0, -s * 0.35), Vector3.new(0.6, 1.1, 0.4), white)
		ball(m, "EarTip", cf * CFrame.new(s * 0.85, 4.35, 0) * CFrame.Angles(0, 0, -s * 0.35), Vector3.new(0.35, 0.4, 0.3), red)
		ball(m, "EarIn", cf * CFrame.new(s * 0.75, 3.9, -0.12) * CFrame.Angles(0, 0, -s * 0.35), Vector3.new(0.3, 0.7, 0.3), PINK)
		-- 隈取り: 目の下の小さな赤いしずく（目と交差させない）
		ball(m, "Mark", cf * CFrame.new(s * 0.62, 2.55, -1.05), Vector3.new(0.18, 0.4, 0.12), red)
	end
	-- 鼻先
	ball(m, "Snout", cf * CFrame.new(0, 2.65, -1.0), Vector3.new(0.8, 0.5, 0.6), white)
	ball(m, "Nose", cf * CFrame.new(0, 2.72, -1.3), Vector3.new(0.3, 0.22, 0.2), BLACK)
	face(m, cf, hc, hr, { eyeR = 0.36, eyeX = 0.5, eyeY = 0.18, mouth = false, blushX = 1.0 })
	-- しっぽ 3 本（特徴）
	for i, a in { -0.6, 0, 0.6 } do
		local tail = cf * CFrame.new(0, 1.3, 0.9) * CFrame.Angles(0, a, 0) * CFrame.Angles(0.9, 0, 0)
		ball(m, "Tail", tail * CFrame.new(0, 0.9, 0), Vector3.new(0.9, 2.0, 0.8), orange)
		ball(m, "TailTip", tail * CFrame.new(0, 1.75, 0), Vector3.new(0.6, 0.7, 0.6), white)
	end
	stubs(m, cf, white, 1.1, 1.0, { size = 0.45 })
end

-- ぬりかべ: 大きな壁に、ちいさな顔と手足
builders.nurikabe = function(m, cf)
	local gray = Color3.fromRGB(200, 196, 185)
	local dark = Color3.fromRGB(160, 155, 145)
	box(m, "Wall", cf * CFrame.new(0, 1.95, 0), Vector3.new(3.4, 3.5, 1.0), gray, Enum.Material.Concrete)
	box(m, "WallTop", cf * CFrame.new(0, 3.75, 0), Vector3.new(3.6, 0.2, 1.2), dark, Enum.Material.Concrete)
	-- ちいさな顔（特徴: 大きな壁に小さい顔）
	local c = Vector3.new(0, 2.4, -0.5)
	eye(m, cf, Vector3.new(-0.5, 2.5, -0.55), 0.28)
	eye(m, cf, Vector3.new(0.5, 2.5, -0.55), 0.28)
	blush(m, cf, Vector3.new(-0.95, 2.1, -0.52), 0.4)
	blush(m, cf, Vector3.new(0.95, 2.1, -0.52), 0.4)
	mouth(m, cf, Vector3.new(0, 1.95, -0.55), 0.4, "o")
	-- ちいさな手足
	for _, s in { -1, 1 } do
		box(m, "Arm", cf * CFrame.new(s * 1.9, 1.6, 0), Vector3.new(0.45, 0.45, 0.45), gray)
		box(m, "Foot", cf * CFrame.new(s * 0.9, 0.1, -0.1), Vector3.new(0.6, 0.25, 0.8), dark)
	end
end

-- ろくろ首: 着物の体、長くのびた首、にっこり顔
builders.rokurokubi = function(m, cf)
	local kimono = Color3.fromRGB(230, 90, 110)
	local obi = Color3.fromRGB(250, 210, 80)
	local hair = Color3.fromRGB(40, 30, 40)
	ball(m, "Body", cf * CFrame.new(0, 1.2, 0), Vector3.new(2.0, 2.4, 1.8), kimono)
	cylY(m, "Obi", cf * CFrame.new(0, 1.15, 0), 0.5, 0.98, obi)
	-- えり
	for _, s in { -1, 1 } do
		piece(m, "Collar", cf * CFrame.new(s * 0.3, 2.1, -0.75) * CFrame.Angles(0, 0, s * 0.5) * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(0.9, 0.2, 0.2), WHITE, "cyl")
	end
	-- 首（特徴）: 玉を重ねてなめらかに前へカーブ
	for i = 0, 11 do
		local t = i / 11
		ball(m, "Neck", cf * CFrame.new(0, 2.3 + t * 2.4, -t * t * 1.2), Vector3.new(0.62, 0.62, 0.62), SKIN)
	end
	local hc = Vector3.new(0, 5.2, -1.4)
	local hr = 0.9
	ball(m, "Head", cf * CFrame.new(hc), Vector3.new(1.8, 1.8, 1.8), SKIN)
	-- 髪: 上と横
	ball(m, "Hair", cf * CFrame.new(hc + Vector3.new(0, 0.3, 0.15)), Vector3.new(1.95, 1.6, 1.9), hair)
	for _, s in { -1, 1 } do
		ball(m, "HairSide", cf * CFrame.new(hc + Vector3.new(s * 0.85, -0.2, -0.1)), Vector3.new(0.4, 1.3, 0.8), hair)
	end
	ball(m, "Kanzashi", cf * CFrame.new(hc + Vector3.new(0.7, 0.75, -0.2)), Vector3.new(0.45, 0.45, 0.3), Color3.fromRGB(255, 80, 90))
	face(m, cf, hc, hr, { eyeR = 0.3, eyeX = 0.38, eyeY = 0.05, mouth = "smile", mouthW = 0.4, mouthY = -0.4, blushX = 0.75 })
	stubs(m, cf, kimono, 1.0, 0.95, { size = 0.4, footColor = Color3.fromRGB(240, 220, 190) })
end

-- 天狗: 赤い顔、長い鼻、白いまゆ毛、黒いつばさ、葉っぱのうちわ
builders.tengu = function(m, cf)
	local red = Color3.fromRGB(225, 70, 60)
	local robe = Color3.fromRGB(60, 70, 120)
	local fluff = Color3.fromRGB(245, 245, 245)
	ball(m, "Body", cf * CFrame.new(0, 1.0, 0), Vector3.new(2.2, 1.9, 1.9), robe)
	local hc = Vector3.new(0, 2.5, 0)
	local hr = 1.15
	ball(m, "Head", cf * CFrame.new(hc), Vector3.new(2.4, 2.2, 2.3), red)
	-- 長い鼻（特徴）
	cylZ(m, "Nose", cf * CFrame.new(0, 2.4, -1.75), 1.8, 0.28, red)
	ball(m, "NoseTip", cf * CFrame.new(0, 2.4, -2.65), Vector3.new(0.6, 0.6, 0.6), red)
	-- まゆ毛とひげ
	for _, s in { -1, 1 } do
		ball(m, "Brow", cf * CFrame.new(s * 0.5, 3.1, -1.0) * CFrame.Angles(0, 0, -s * 0.3), Vector3.new(0.9, 0.35, 0.4), fluff)
		ball(m, "Mustache", cf * CFrame.new(s * 0.55, 1.95, -1.0) * CFrame.Angles(0, 0, s * 0.4), Vector3.new(0.9, 0.3, 0.3), fluff)
	end
	ball(m, "HairBack", cf * CFrame.new(0, 2.6, 0.7), Vector3.new(2.2, 2.0, 1.4), fluff)
	-- 頭巾（ちいさい帽子）
	box(m, "Tokin", cf * CFrame.new(0, 3.65, -0.2), Vector3.new(0.7, 0.45, 0.7), BLACK)
	-- 目（鼻の上）
	eye(m, cf, Vector3.new(-0.5, 2.75, -0.95), 0.28)
	eye(m, cf, Vector3.new(0.5, 2.75, -0.95), 0.28)
	blush(m, cf, Vector3.new(-1.0, 2.3, -0.75), 0.4)
	blush(m, cf, Vector3.new(1.0, 2.3, -0.75), 0.4)
	-- つばさ（特徴）
	for _, s in { -1, 1 } do
		local w = cf * CFrame.new(s * 1.3, 2.0, 0.6) * CFrame.Angles(0, -s * 0.5, s * 0.35)
		ball(m, "Wing", w * CFrame.new(s * 0.9, 0, 0), Vector3.new(2.4, 0.9, 0.3), BLACK)
		ball(m, "Wing", w * CFrame.new(s * 1.6, -0.35, 0), Vector3.new(1.6, 0.6, 0.25), BLACK)
	end
	-- うちわ
	cylZ(m, "FanHandle", cf * CFrame.new(1.3, 1.1, -0.6) * CFrame.Angles(0.4, 0, 0), 1.0, 0.1, Color3.fromRGB(120, 80, 50))
	ball(m, "Fan", cf * CFrame.new(1.3, 1.5, -1.2) * CFrame.Angles(0.4, 0, 0), Vector3.new(1.0, 1.3, 0.12), Color3.fromRGB(230, 200, 130))
	stubs(m, cf, robe, 0.95, 1.0, { size = 0.45, footColor = Color3.fromRGB(190, 150, 100) })
end

Designs.ids = { "kappa", "tanuki", "karakasa", "chochin", "kitsune", "nurikabe", "rokurokubi", "tengu" }

-- 金ぴかにする。顔のパーツ以外を金色に寄せて、金属にする
local FACE_PARTS = { EyeWhite = true, Pupil = true, Shine = true, Blush = true, Mouth = true, Tongue = true, LongTongue = true, Eye = true, Water = true }
function Designs.paintGold(model: Model)
	local gold = Color3.fromRGB(255, 205, 60)
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p.Name ~= "Root" and not FACE_PARTS[p.Name] then
			p.Color = p.Color:Lerp(gold, 0.7)
			p.Material = Enum.Material.Metal
			p.Reflectance = 0.15
		end
	end
	model:SetAttribute("Gold", true)
end

-- 妖怪を組み立てて返す。cf = 足元の中心（-Z が正面）
function Designs.build(id: string, cf: CFrame, parent: Instance): Model
	local m = Instance.new("Model")
	m.Name = id
	-- 持ち運びや当たり判定の基準になる見えない芯
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(2.4, 3.6, 2.4)
	root.CFrame = cf * CFrame.new(0, 1.8, 0)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.Parent = m
	m.PrimaryPart = root
	builders[id](m, cf)
	m.Parent = parent
	return m
end

return Designs
