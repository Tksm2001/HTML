-- おにぎりーず 第 1 弾の見た目。全部コードで部品から組む。
-- 共通ルール: 体は食べ物の形そのまま / 顔は体の高さの 55〜60% / 目は大きく / ほっぺ必須 / 手足はクリーム色で小さく / 1 体に 1 つ飾り
-- 座標: cf を足元の中心とし、-Z が正面。
local Cute = require(script.Parent.Cute)
local ball, box, cylY, cylZ, cylX, piece = Cute.ball, Cute.box, Cute.cylY, Cute.cylZ, Cute.cylX, Cute.piece
local BLACK, WHITE, PINK = Cute.BLACK, Cute.WHITE, Cute.PINK

local Designs = {}
local builders = {}

local RICE = Color3.fromRGB(250, 248, 240)
local NORI = Color3.fromRGB(35, 45, 35)
local GOLD = Color3.fromRGB(255, 205, 60)

-- おにぎりの体（三角の角を丸めた形）。高さ h、幅 w、奥行き d。色 color。中心は (0, h/2 + 0.3, 0)
local function onigiriBody(m, cf, w: number, h: number, d: number, color: Color3, material: Enum.Material?)
	local y0 = 0.3
	-- 三角: 2 つのくさびを背中合わせに。角は少し短くして、玉で丸める
	local wh, ww = h - 0.5, w - 0.9
	for _, s in { -1, 1 } do
		piece(m, "Body", cf * CFrame.new(s * ww / 4, y0 + wh / 2, 0) * CFrame.Angles(0, -s * math.pi / 2, 0), -- 高い側が真ん中に来る向き
			Vector3.new(d, wh, ww / 2), color, "wedge", material)
	end
	-- 下の帯（底を少し厚く）
	box(m, "Body", cf * CFrame.new(0, y0 + 0.3, 0), Vector3.new(ww, 0.6, d), color, material)
	-- 角を丸める玉（てっぺんと、下の両角）
	ball(m, "Body", cf * CFrame.new(0, y0 + wh - 0.1, 0), Vector3.new(d * 0.85, d * 0.85, d), color, material)
	for _, s in { -1, 1 } do
		ball(m, "Body", cf * CFrame.new(s * (ww / 2 - 0.15), y0 + 0.4, 0), Vector3.new(d * 0.85, d * 0.8, d), color, material)
	end
	return y0 + h / 2
end

-- 1. おにぎりくん（しお）: 主役
builders.onigiri = function(m, cf)
	local w, h, d = 3.2, 3.0, 1.9
	onigiriBody(m, cf, w, h, d, RICE)
	-- のりのベルト（下の前面）
	box(m, "Nori", cf * CFrame.new(0, 0.95, -d * 0.52), Vector3.new(1.3, 1.2, 0.2), NORI)
	box(m, "Nori", cf * CFrame.new(0, 0.95, 0), Vector3.new(1.3, 1.2, d * 1.06), NORI)
	-- しおの粒
	for _, o in { Vector3.new(-0.9, 2.4, -1.0), Vector3.new(0.5, 2.7, -1.0), Vector3.new(1.0, 1.9, -1.0) } do
		ball(m, "Salt", cf * CFrame.new(o), Vector3.new(0.16, 0.16, 0.1), Color3.fromRGB(230, 240, 255))
	end
	Cute.face(m, cf, 0, 2.0, -d * 0.56, { eyeR = 0.36, eyeX = 0.5, mouth = "w", mouthW = 0.5, mouthDrop = 0.55 })
	Cute.limbs(m, cf, 1.5, 1.25, { size = 0.5, armZ = 0.3 })
end

-- 2. だんごさん: 3 色だんごに串。上の団子に顔
builders.dango = function(m, cf)
	cylY(m, "Stick", cf * CFrame.new(0, 2.0, 0), 4.0, 0.12, Color3.fromRGB(225, 200, 150))
	local colors = { Color3.fromRGB(120, 190, 110), Color3.fromRGB(252, 250, 245), Color3.fromRGB(255, 170, 190) }
	for i, col in colors do
		ball(m, "Dango", cf * CFrame.new(0, 0.9 + (i - 1) * 1.2, 0), Vector3.new(1.5, 1.3, 1.5), col)
	end
	Cute.face(m, cf, 0, 3.4, -0.7, { eyeR = 0.24, eyeX = 0.33, mouth = "o", mouthW = 0.3, mouthDrop = 0.4, blushX = 0.62 })
	-- 真ん中と下の団子にも小さなにっこり目
	Cute.eye(m, cf, Vector3.new(-0.3, 2.15, -0.7), 0.16, "happy")
	Cute.eye(m, cf, Vector3.new(0.3, 2.15, -0.7), 0.16, "happy")
	Cute.limbs(m, cf, 2.1, 0.75, { size = 0.4, feet = false })
	for _, side in { -1, 1 } do
		ball(m, "Foot", cf * CFrame.new(side * 0.4, 0.25, -0.3), Vector3.new(0.45, 0.3, 0.55), Cute.CREAM)
	end
end

-- 3. たまごやきちゃん: 黄色い巻き。うずまきの筋
builders.tamagoyaki = function(m, cf)
	local yellow = Color3.fromRGB(255, 215, 80)
	local deep = Color3.fromRGB(240, 170, 50)
	box(m, "Body", cf * CFrame.new(0, 1.6, 0), Vector3.new(2.8, 2.4, 2.2), yellow)
	-- 角を丸く
	for _, sx in { -1, 1 } do
		for _, sy in { -1, 1 } do
			cylZ(m, "Edge", cf * CFrame.new(sx * 1.2, 1.6 + sy * 1.0, 0), 2.2, 0.4, yellow)
		end
	end
	-- うずまき（側面）
	for _, sx in { -1, 1 } do
		for i, r in { 0.9, 0.55, 0.2 } do
			cylX(m, "Swirl", cf * CFrame.new(sx * 1.42, 1.6, 0), 0.08, r, i % 2 == 1 and deep or yellow)
		end
	end
	-- 上に小さなだいこんおろし
	ball(m, "Oroshi", cf * CFrame.new(0.6, 2.95, -0.3), Vector3.new(0.8, 0.5, 0.7), Color3.fromRGB(250, 250, 245))
	Cute.face(m, cf, 0, 1.85, -1.12, { eyeR = 0.34, eyeX = 0.5, eyeStyle = "happy", mouth = "smile", mouthW = 0.45, mouthDrop = 0.55, blushX = 0.95 })
	Cute.limbs(m, cf, 1.3, 1.4, { size = 0.45 })
end

-- 4. たこやきぼうや: 茶色い丸にソース、青のり、揺れるかつおぶし
builders.takoyaki = function(m, cf)
	local brown = Color3.fromRGB(205, 140, 70)
	local sauce = Color3.fromRGB(95, 55, 35)
	ball(m, "Body", cf * CFrame.new(0, 1.7, 0), Vector3.new(2.8, 2.8, 2.8), brown)
	ball(m, "Sauce", cf * CFrame.new(0, 2.5, 0), Vector3.new(2.3, 1.2, 2.3), sauce)
	-- マヨネーズの線
	for _, x in { -0.5, 0.2 } do
		box(m, "Mayo", cf * CFrame.new(x, 3.08, 0) * CFrame.Angles(0, 0.4, 0), Vector3.new(0.12, 0.08, 1.6), Color3.fromRGB(255, 250, 220))
	end
	-- 青のり
	for i = 1, 6 do
		local a = i / 6 * math.pi * 2
		box(m, "Aonori", cf * CFrame.new(math.cos(a) * 0.7, 3.05, math.sin(a) * 0.7) * CFrame.Angles(0, a, 0), Vector3.new(0.18, 0.05, 0.1), Color3.fromRGB(70, 120, 60))
	end
	-- かつおぶし（薄くて反った板）
	for i, o in { Vector3.new(-0.6, 3.3, 0.2), Vector3.new(0.5, 3.35, -0.3) } do
		piece(m, "Katsuo", cf * CFrame.new(o) * CFrame.Angles(0.3 * i, 0.5 * i, 0.2), Vector3.new(0.8, 0.04, 0.6), Color3.fromRGB(215, 170, 130), "box")
	end
	Cute.face(m, cf, 0, 1.75, -1.3, { eyeR = 0.36, eyeX = 0.5, mouth = "open", mouthW = 0.6, mouthDrop = 0.6 })
	-- 舟（たこやきの船）
	box(m, "Boat", cf * CFrame.new(0, 0.2, 0), Vector3.new(3.4, 0.35, 2.6), Color3.fromRGB(240, 220, 180))
	Cute.limbs(m, cf, 1.4, 1.35, { size = 0.45, feet = false })
end

-- 5. たいやきくん: 魚の形。しっぽとヒレ
builders.taiyaki = function(m, cf)
	local dough = Color3.fromRGB(215, 160, 90)
	local dark = Color3.fromRGB(180, 125, 70)
	ball(m, "Body", cf * CFrame.new(0, 1.6, 0), Vector3.new(3.4, 2.4, 1.6), dough)
	-- しっぽ（二又）
	for _, s in { -1, 1 } do
		piece(m, "Tail", cf * CFrame.new(2.0, 1.6 + s * 0.45, 0) * CFrame.Angles(0, 0, s * 0.6), Vector3.new(1.3, 0.6, 0.9), dough, "box")
	end
	-- 背びれ・胸びれ
	piece(m, "Fin", cf * CFrame.new(0.2, 2.9, 0) * CFrame.Angles(0, 0, -0.3), Vector3.new(1.4, 0.5, 0.6), dark, "box")
	piece(m, "Fin", cf * CFrame.new(0.6, 1.0, -0.6) * CFrame.Angles(0.4, 0, 0.5), Vector3.new(0.8, 0.35, 0.3), dark, "box")
	-- うろこの筋
	for i = 1, 3 do
		cylY(m, "Scale", cf * CFrame.new(0.4 + i * 0.4, 1.6, -0.75), 1.4, 0.06, dark)
	end
	-- あんこが少しのぞく（しっぽの根元）
	ball(m, "Anko", cf * CFrame.new(1.55, 1.6, 0), Vector3.new(0.5, 0.9, 0.5), Color3.fromRGB(90, 40, 50))
	Cute.face(m, cf, -0.7, 1.85, -0.8, { eyeR = 0.34, eyeX = 0.45, mouth = "o", mouthW = 0.4, mouthDrop = 0.55, blushX = 0.9 })
	Cute.limbs(m, cf, 1.3, 1.6, { size = 0.42, feet = true, footX = 0.6 })
end

-- 6. いちごだいふくちゃん: 白い丸、頭からいちご
builders.daifuku = function(m, cf)
	local mochi = Color3.fromRGB(252, 250, 246)
	ball(m, "Body", cf * CFrame.new(0, 1.55, 0), Vector3.new(2.9, 2.6, 2.8), mochi)
	-- いちご（頭から）
	ball(m, "Strawberry", cf * CFrame.new(0, 2.95, -0.1), Vector3.new(1.4, 1.5, 1.4), Color3.fromRGB(235, 50, 60))
	for i = 1, 8 do
		local a = i / 8 * math.pi * 2
		ball(m, "Seed", cf * CFrame.new(math.cos(a) * 0.55, 2.9 + math.sin(i) * 0.2, math.sin(a) * 0.55), Vector3.new(0.1, 0.14, 0.1), Color3.fromRGB(255, 230, 140))
	end
	for i = 1, 5 do
		local a = i / 5 * math.pi * 2
		piece(m, "Leaf", cf * CFrame.new(math.cos(a) * 0.35, 3.65, math.sin(a) * 0.35) * CFrame.Angles(0, -a, 0) * CFrame.Angles(0, 0, -0.5), Vector3.new(0.6, 0.08, 0.3), Color3.fromRGB(90, 170, 80), "box")
	end
	-- 粉
	for _, o in { Vector3.new(-0.9, 1.9, -1.2), Vector3.new(0.7, 2.3, -1.1) } do
		ball(m, "Powder", cf * CFrame.new(o), Vector3.new(0.3, 0.2, 0.1), Color3.fromRGB(255, 255, 255))
	end
	Cute.face(m, cf, 0, 1.6, -1.3, { eyeR = 0.36, eyeX = 0.5, eyeStyle = "happy", mouth = "w", mouthW = 0.5, mouthDrop = 0.5 })
	Cute.limbs(m, cf, 1.3, 1.4, { size = 0.48 })
end

-- 7. まぐろずしさん（R）: シャリに赤身、わさび
builders.maguro = function(m, cf)
	box(m, "Rice", cf * CFrame.new(0, 1.0, 0), Vector3.new(3.0, 1.4, 1.9), RICE)
	for _, sx in { -1, 1 } do
		cylZ(m, "RiceEdge", cf * CFrame.new(sx * 1.3, 1.0, 0), 1.9, 0.5, RICE)
	end
	-- 赤身（少し反らせて乗せる）
	local tuna = Color3.fromRGB(225, 60, 70)
	box(m, "Tuna", cf * CFrame.new(0, 1.95, 0), Vector3.new(3.6, 0.7, 2.0), tuna)
	ball(m, "Tuna", cf * CFrame.new(1.6, 2.1, 0), Vector3.new(1.0, 0.9, 2.0), tuna)
	ball(m, "Tuna", cf * CFrame.new(-1.6, 2.1, 0), Vector3.new(1.0, 0.9, 2.0), tuna)
	-- 身の筋
	for i = -1, 1 do
		box(m, "Sinew", cf * CFrame.new(i * 0.9, 2.32, 0) * CFrame.Angles(0, 0.2, 0), Vector3.new(0.12, 0.05, 1.9), Color3.fromRGB(255, 190, 190))
	end
	-- わさび
	ball(m, "Wasabi", cf * CFrame.new(-0.9, 2.45, -0.7), Vector3.new(0.5, 0.35, 0.5), Color3.fromRGB(150, 200, 90))
	Cute.face(m, cf, 0, 1.1, -0.98, { eyeR = 0.3, eyeX = 0.45, mouth = "w", mouthW = 0.45, mouthDrop = 0.45, blushX = 0.95 })
	Cute.limbs(m, cf, 0.9, 1.6, { size = 0.42, armDrop = 0.1 })
end

-- 8. いくらおにぎりちゃん（R）: 三角から いくらがこぼれる
builders.ikura = function(m, cf)
	local w, h, d = 3.2, 3.0, 1.9
	onigiriBody(m, cf, w, h, d, RICE)
	box(m, "Nori", cf * CFrame.new(0, 0.95, 0), Vector3.new(1.3, 1.2, d * 1.06), NORI)
	box(m, "Nori", cf * CFrame.new(0, 0.95, -d * 0.52), Vector3.new(1.3, 1.2, 0.2), NORI)
	-- いくら（頭の上から前にこぼれる）
	local ikura = Color3.fromRGB(255, 120, 40)
	local rng = Random.new(8)
	for i = 1, 14 do
		local t = i / 14
		local x = rng:NextNumber(-0.9, 0.9) * t
		local y = 3.45 - t * 1.0
		local z = -d * 0.25 - t * 0.9
		local egg = ball(m, "Ikura", cf * CFrame.new(x, y, z), Vector3.new(0.42, 0.42, 0.42), ikura, Enum.Material.Glass)
		egg.Transparency = 0.15
		egg.Reflectance = 0.1
	end
	Cute.face(m, cf, 0, 1.9, -d * 0.56, { eyeR = 0.36, eyeX = 0.5, mouth = "open", mouthW = 0.55, mouthDrop = 0.55 })
	Cute.limbs(m, cf, 1.5, 1.25, { size = 0.5, armZ = 0.3 })
end

-- 9. かきごおりちゃん（R）: 山形の氷、青いシロップ、カップ、スプーン、旗
builders.kakigori = function(m, cf)
	local cup = cylY(m, "Cup", cf * CFrame.new(0, 0.95, 0), 1.7, 1.25, Color3.fromRGB(190, 230, 255), Enum.Material.Glass)
	cup.Transparency = 0.35
	cylY(m, "CupBase", cf * CFrame.new(0, 0.15, 0), 0.3, 0.9, Color3.fromRGB(190, 230, 255), Enum.Material.Glass)
	-- 氷（段々の山）
	local ice = Color3.fromRGB(240, 250, 255)
	for i = 0, 6 do
		local t = i / 6
		cylY(m, "Ice", cf * CFrame.new(0, 1.8 + i * 0.3, 0), 0.32, 1.35 * (1 - t) ^ 0.7 + 0.1, ice, Enum.Material.Sand)
	end
	-- シロップ（上から垂れる）
	local blue = Color3.fromRGB(80, 170, 255)
	ball(m, "Syrup", cf * CFrame.new(0, 3.5, 0), Vector3.new(1.4, 0.6, 1.4), blue)
	for i = 1, 4 do
		local a = i / 4 * math.pi * 2 + 0.5
		ball(m, "Drip", cf * CFrame.new(math.cos(a) * 0.9, 3.0, math.sin(a) * 0.9), Vector3.new(0.3, 0.7, 0.3), blue)
	end
	-- スプーンと旗
	cylY(m, "Spoon", cf * CFrame.new(0.9, 3.4, -0.4) * CFrame.Angles(0, 0, -0.4), 1.4, 0.07, Color3.fromRGB(235, 235, 240))
	ball(m, "SpoonHead", cf * CFrame.new(0.65, 2.75, -0.45), Vector3.new(0.35, 0.15, 0.5), Color3.fromRGB(235, 235, 240))
	Cute.flag(m, cf * CFrame.new(-0.6, 3.4, 0.2), Color3.fromRGB(255, 80, 90))
	Cute.face(m, cf, 0, 2.3, -1.15, { eyeR = 0.32, eyeX = 0.45, mouth = "smile", mouthW = 0.45, mouthDrop = 0.5, blushX = 0.9 })
	Cute.limbs(m, cf, 1.3, 1.25, { size = 0.42, feet = false })
end

-- 10. プリンさん（R）: 台形にカラメル、さくらんぼ
builders.purin = function(m, cf)
	local custard = Color3.fromRGB(255, 220, 110)
	local caramel = Color3.fromRGB(120, 60, 30)
	for i = 0, 5 do
		local t = i / 5
		cylY(m, "Body", cf * CFrame.new(0, 0.5 + i * 0.42, 0), 0.44, 1.6 - t * 0.45, custard)
	end
	ball(m, "Caramel", cf * CFrame.new(0, 2.75, 0), Vector3.new(2.3, 0.55, 2.3), caramel)
	for i = 1, 3 do
		local a = i / 3 * math.pi * 2 + 0.3
		ball(m, "Drip", cf * CFrame.new(math.cos(a) * 1.0, 2.35, math.sin(a) * 1.0), Vector3.new(0.3, 0.6, 0.3), caramel)
	end
	-- 皿、さくらんぼ、クリーム
	cylY(m, "Plate", cf * CFrame.new(0, 0.2, 0), 0.2, 2.0, Color3.fromRGB(255, 255, 255))
	ball(m, "Cream", cf * CFrame.new(0, 3.05, 0), Vector3.new(0.9, 0.55, 0.9), Color3.fromRGB(255, 255, 250))
	ball(m, "Cherry", cf * CFrame.new(0, 3.4, 0), Vector3.new(0.5, 0.5, 0.5), Color3.fromRGB(220, 30, 60))
	cylY(m, "Stem", cf * CFrame.new(0.15, 3.85, 0) * CFrame.Angles(0, 0, 0.4), 0.6, 0.04, Color3.fromRGB(90, 130, 60))
	Cute.face(m, cf, 0, 1.75, -1.4, { eyeR = 0.34, eyeX = 0.48, mouth = "w", mouthW = 0.5, mouthDrop = 0.5, blushX = 0.95 })
	Cute.limbs(m, cf, 1.3, 1.5, { size = 0.45, feet = false })
end

-- 11. ラーメンさま（SR）: どんぶりに麺の髪、なると、たまご、割りばし
builders.ramen = function(m, cf)
	local bowl = Color3.fromRGB(252, 250, 245)
	local red = Color3.fromRGB(210, 50, 50)
	for i = 0, 4 do
		local t = i / 4
		cylY(m, "Bowl", cf * CFrame.new(0, 0.45 + i * 0.4, 0), 0.42, 0.9 + t * 0.8, bowl)
	end
	cylY(m, "BowlRim", cf * CFrame.new(0, 2.25, 0), 0.2, 1.75, red)
	-- 雷文（赤い模様）
	for i = 1, 8 do
		local a = i / 8 * math.pi * 2
		box(m, "Pattern", cf * CFrame.new(math.cos(a) * 1.62, 1.6, math.sin(a) * 1.62) * CFrame.Angles(0, -a, 0), Vector3.new(0.12, 0.45, 0.4), red)
	end
	-- スープと麺（髪）
	cylY(m, "Soup", cf * CFrame.new(0, 2.3, 0), 0.15, 1.6, Color3.fromRGB(230, 180, 110))
	local noodle = Color3.fromRGB(255, 225, 130)
	local rng = Random.new(11)
	for i = 1, 14 do
		local a = i / 14 * math.pi * 2
		local r = 0.3 + rng:NextNumber(0, 1.0)
		cylY(m, "Noodle", cf * CFrame.new(math.cos(a) * r, 2.65 + rng:NextNumber(0, 0.4), math.sin(a) * r) * CFrame.Angles(rng:NextNumber(-0.4, 0.4), 0, rng:NextNumber(-0.4, 0.4)), 0.9, 0.09, noodle)
	end
	-- なると、たまご、ねぎ、のり
	local naruto = cylY(m, "Naruto", cf * CFrame.new(0.6, 2.85, -0.4), 0.12, 0.45, Color3.fromRGB(255, 250, 250))
	ball(m, "NarutoSwirl", cf * CFrame.new(0.6, 2.93, -0.4), Vector3.new(0.45, 0.04, 0.45), Color3.fromRGB(255, 120, 150))
	ball(m, "Egg", cf * CFrame.new(-0.7, 2.85, -0.3), Vector3.new(0.7, 0.25, 0.5), Color3.fromRGB(255, 255, 240))
	ball(m, "Yolk", cf * CFrame.new(-0.7, 2.95, -0.3), Vector3.new(0.4, 0.15, 0.3), Color3.fromRGB(255, 180, 60))
	box(m, "Nori", cf * CFrame.new(-0.2, 3.0, 0.9) * CFrame.Angles(-0.4, 0, 0), Vector3.new(0.9, 0.9, 0.05), NORI)
	for i = 1, 5 do
		cylY(m, "Negi", cf * CFrame.new(rng:NextNumber(-0.8, 0.8), 2.95, rng:NextNumber(-0.6, 0.6)), 0.12, 0.12, Color3.fromRGB(120, 200, 90))
	end
	-- 割りばし
	cylY(m, "Chopstick", cf * CFrame.new(1.4, 3.1, 0.3) * CFrame.Angles(0, 0, -0.5), 2.4, 0.07, Color3.fromRGB(225, 200, 150))
	cylY(m, "Chopstick", cf * CFrame.new(1.55, 3.1, 0.5) * CFrame.Angles(0, 0, -0.5), 2.4, 0.07, Color3.fromRGB(225, 200, 150))
	-- 湯気
	for i = 1, 3 do
		local s = ball(m, "Steam", cf * CFrame.new(-0.3 + i * 0.3, 3.6 + i * 0.25, 0), Vector3.new(0.4, 0.5, 0.4), Color3.fromRGB(255, 255, 255))
		s.Transparency = 0.5
	end
	Cute.face(m, cf, 0, 1.45, -1.62, { eyeR = 0.34, eyeX = 0.5, mouth = "smile", mouthW = 0.5, mouthDrop = 0.5, blushX = 0.95 })
	Cute.limbs(m, cf, 1.2, 1.7, { size = 0.45, feet = false })
	Cute.sparkles(m, cf, 2.0, 2.3, 6, Color3.fromRGB(255, 230, 150))
end

-- 12. 金のおにぎり（UR）: 金色の三角。キラキラ、小さな王冠
builders.goldonigiri = function(m, cf)
	local w, h, d = 3.2, 3.0, 1.9
	onigiriBody(m, cf, w, h, d, GOLD, Enum.Material.Metal)
	box(m, "Nori", cf * CFrame.new(0, 0.95, 0), Vector3.new(1.3, 1.2, d * 1.06), Color3.fromRGB(60, 50, 30), Enum.Material.Metal)
	box(m, "Nori", cf * CFrame.new(0, 0.95, -d * 0.52), Vector3.new(1.3, 1.2, 0.2), Color3.fromRGB(60, 50, 30), Enum.Material.Metal)
	-- 王冠（赤い布つき。金の体から浮き立つように）
	cylY(m, "CrownCloth", cf * CFrame.new(0, 3.55, 0), 0.5, 0.6, Color3.fromRGB(200, 40, 60), Enum.Material.Fabric)
	cylY(m, "Crown", cf * CFrame.new(0, 3.7, 0), 0.3, 0.75, Color3.fromRGB(255, 240, 150), Enum.Material.Metal)
	for i = 1, 6 do
		local a = i / 6 * math.pi * 2
		box(m, "CrownTip", cf * CFrame.new(math.cos(a) * 0.62, 4.05, math.sin(a) * 0.62), Vector3.new(0.2, 0.5, 0.2), Color3.fromRGB(255, 240, 150), Enum.Material.Metal)
		ball(m, "CrownBall", cf * CFrame.new(math.cos(a) * 0.62, 4.33, math.sin(a) * 0.62), Vector3.new(0.22, 0.22, 0.22), Color3.fromRGB(255, 60, 90), Enum.Material.Neon)
	end
	ball(m, "Jewel", cf * CFrame.new(0, 3.75, -0.72), Vector3.new(0.35, 0.35, 0.2), Color3.fromRGB(255, 60, 90), Enum.Material.Neon)
	Cute.face(m, cf, 0, 2.0, -d * 0.56, { eyeR = 0.36, eyeX = 0.5, eyeStyle = "happy", mouth = "smile", mouthW = 0.5, mouthDrop = 0.55 })
	Cute.limbs(m, cf, 1.5, 1.25, { size = 0.5, armZ = 0.3, color = Color3.fromRGB(255, 225, 140) })
	Cute.sparkles(m, cf, 1.9, 2.2, 8, Color3.fromRGB(255, 240, 180))
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") and p.Material == Enum.Material.Metal then
			p.Reflectance = 0.2
		end
	end
end

Designs.ids = { "onigiri", "dango", "tamagoyaki", "takoyaki", "taiyaki", "daifuku", "maguro", "ikura", "kakigori", "purin", "ramen", "goldonigiri" }

-- キャラを組み立てて返す。cf = 足元の中心（-Z が正面）
function Designs.build(id: string, cf: CFrame, parent: Instance): Model
	local m = Instance.new("Model")
	m.Name = id
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(3.2, 3.8, 2.6)
	root.CFrame = cf * CFrame.new(0, 1.9, 0)
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
