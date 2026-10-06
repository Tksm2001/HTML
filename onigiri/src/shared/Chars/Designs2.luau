-- おにぎりーず 第 2 弾「麺とパン」の見た目。Designs.luau から読み込まれる。
-- 部品の名前は「味ちがい」の色替えで使うので、変えるときは Config.VARIANTS も直す。
local Cute = require(script.Parent.Cute)
local ball, box, cylY, cylZ, cylX, piece = Cute.ball, Cute.box, Cute.cylY, Cute.cylZ, Cute.cylX, Cute.piece
local BLACK, WHITE, PINK = Cute.BLACK, Cute.WHITE, Cute.PINK

local builders = {}

local BREAD = Color3.fromRGB(225, 175, 105)
local CRUST = Color3.fromRGB(190, 130, 70)
local BOWL = Color3.fromRGB(252, 250, 245)

-- どんぶり（段々の円柱）。半径 r、高さ h。戻り値: 上面の y
local function bowl(m, r: number, h: number, color: Color3, rim: Color3?)
	local steps = 5
	for i = 0, steps - 1 do
		local t = i / (steps - 1)
		cylY(m, "Bowl", CFrame.new(0, 0.3 + i * h / steps + h / steps / 2, 0), h / steps + 0.02, r * (0.55 + 0.45 * t), color)
	end
	if rim then
		cylY(m, "Rim", CFrame.new(0, 0.3 + h, 0), 0.18, r + 0.05, rim)
	end
	return 0.3 + h
end

-- 麺のかたまり（短い円柱をランダムに）
local function noodles(m, name: string, center: Vector3, radius: number, count: number, color: Color3, thick: number, seed: number)
	local rng = Random.new(seed)
	for i = 1, count do
		local a = i / count * math.pi * 2
		local r = rng:NextNumber(0.1, 1) * radius
		local cf = CFrame.new(center + Vector3.new(math.cos(a) * r, rng:NextNumber(-0.15, 0.25), math.sin(a) * r)) * CFrame.Angles(rng:NextNumber(-0.5, 0.5), rng:NextNumber(0, 6.28), rng:NextNumber(0.6, 1.2))
		piece(m, name, cf * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(rng:NextNumber(0.6, 1.3), thick, thick), color, "cyl")
	end
end

-- 13. うどんちゃん: 白いどんぶり、太い白麺、かまぼこ、わかめ（Topping）
builders.udon = function(m, cf)
	local top = bowl(m, 1.7, 1.9, BOWL, Color3.fromRGB(60, 90, 160))
	cylY(m, "Soup", CFrame.new(0, top + 0.05, 0), 0.12, 1.55, Color3.fromRGB(235, 215, 170))
	noodles(m, "Noodle", Vector3.new(0, top + 0.35, 0), 1.0, 14, Color3.fromRGB(255, 252, 240), 0.22, 13)
	local kama = cylY(m, "Kamaboko", CFrame.new(0.7, top + 0.55, -0.3) * CFrame.Angles(0.3, 0, 0), 0.14, 0.42, Color3.fromRGB(255, 250, 250))
	ball(m, "KamabokoPink", CFrame.new(0.7, top + 0.63, -0.3), Vector3.new(0.6, 0.05, 0.45), Color3.fromRGB(255, 130, 160))
	box(m, "Topping", CFrame.new(-0.7, top + 0.5, 0.2) * CFrame.Angles(0, 0.4, 0), Vector3.new(1.0, 0.12, 0.8), Color3.fromRGB(70, 110, 80))
	for i = 1, 4 do
		cylY(m, "Negi", CFrame.new(-0.3 + i * 0.25, top + 0.6, -0.5 + (i % 2) * 0.4), 0.1, 0.11, Color3.fromRGB(120, 200, 90))
	end
	for i = 1, 3 do
		local s = ball(m, "Steam", CFrame.new(-0.4 + i * 0.35, top + 1.0 + i * 0.25, 0), Vector3.new(0.4, 0.5, 0.4), WHITE)
		s.Transparency = 0.5
	end
	Cute.face(m, cf, 0, 1.25, -1.62, { eyeR = 0.32, eyeX = 0.48, mouth = "w", mouthW = 0.5, mouthDrop = 0.5, blushX = 0.95 })
	Cute.limbs(m, cf, 1.1, 1.65, { size = 0.42, feet = false })
end

-- 14. やきそばくん: お皿に茶色い麺、青のり、紅しょうが
builders.yakisoba = function(m, cf)
	cylY(m, "Plate", CFrame.new(0, 0.4, 0), 0.25, 2.0, WHITE)
	ball(m, "Heap", CFrame.new(0, 1.3, 0), Vector3.new(3.2, 1.7, 2.6), Color3.fromRGB(175, 115, 60))
	noodles(m, "Noodle", Vector3.new(0, 1.8, 0), 1.3, 18, Color3.fromRGB(205, 140, 70), 0.18, 14)
	for i = 1, 6 do
		local a = i / 6 * math.pi * 2
		box(m, "Aonori", CFrame.new(math.cos(a) * 0.8, 2.25, math.sin(a) * 0.6) * CFrame.Angles(0, a, 0), Vector3.new(0.2, 0.05, 0.12), Color3.fromRGB(70, 120, 60))
	end
	for i = 1, 3 do
		box(m, "Beni", CFrame.new(0.9, 2.2, -0.6 + i * 0.25) * CFrame.Angles(0, 0.5 * i, 0), Vector3.new(0.5, 0.08, 0.1), Color3.fromRGB(240, 70, 90))
	end
	ball(m, "Mayo", CFrame.new(-0.6, 2.25, 0.5), Vector3.new(0.7, 0.15, 0.4), Color3.fromRGB(255, 250, 220))
	Cute.face(m, cf, 0, 1.45, -1.3, { eyeR = 0.32, eyeX = 0.46, mouth = "open", mouthW = 0.5, mouthDrop = 0.5, blushX = 0.95 })
	Cute.limbs(m, cf, 1.1, 1.55, { size = 0.42, feet = false })
end

-- 15. メロンパンちゃん: 丸いパンに、クッキー生地（Top）と格子（Grid）
builders.melonpan = function(m, cf)
	ball(m, "Body", CFrame.new(0, 1.5, 0), Vector3.new(3.0, 2.4, 2.9), BREAD)
	ball(m, "Top", CFrame.new(0, 1.75, 0), Vector3.new(3.05, 2.1, 2.95), Color3.fromRGB(245, 215, 150))
	-- 格子: 上面に斜めの線
	for i = -2, 2 do
		for _, a in { 0.78, -0.78 } do
			piece(m, "Grid", CFrame.new(0, 2.78, 0) * CFrame.Angles(0, a, 0) * CFrame.new(i * 0.55, 0, 0) * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(0.08, 0.06, 2.6 - math.abs(i) * 0.5), Color3.fromRGB(200, 160, 100), "cyl")
		end
	end
	Cute.face(m, cf, 0, 1.45, -1.42, { eyeR = 0.34, eyeX = 0.48, eyeStyle = "happy", mouth = "w", mouthW = 0.5, mouthDrop = 0.5, blushX = 0.95 })
	Cute.limbs(m, cf, 1.2, 1.45, { size = 0.45 })
end

-- 16. あんパンくん: つやつやの丸いパン、てっぺんにごま、へそ
builders.anpan = function(m, cf)
	ball(m, "Body", CFrame.new(0, 1.5, 0), Vector3.new(3.0, 2.3, 2.9), Color3.fromRGB(200, 135, 75))
	ball(m, "Shine", CFrame.new(-0.6, 2.3, -0.9), Vector3.new(0.9, 0.5, 0.4), Color3.fromRGB(230, 180, 120))
	ball(m, "Navel", CFrame.new(0, 2.6, 0), Vector3.new(0.6, 0.2, 0.6), Color3.fromRGB(160, 100, 55))
	for i = 1, 5 do
		local a = i / 5 * math.pi * 2
		ball(m, "Sesame", CFrame.new(math.cos(a) * 0.45, 2.66, math.sin(a) * 0.45), Vector3.new(0.14, 0.08, 0.2), WHITE)
	end
	Cute.face(m, cf, 0, 1.4, -1.4, { eyeR = 0.34, eyeX = 0.48, mouth = "o", mouthW = 0.4, mouthDrop = 0.5, blushX = 0.95 })
	Cute.limbs(m, cf, 1.2, 1.45, { size = 0.45 })
end

-- 17. しょくパンさん: 食パンの形（上が丸い四角）、バター
builders.shokupan = function(m, cf)
	box(m, "Crust", CFrame.new(0, 1.7, 0), Vector3.new(3.0, 2.6, 1.0), CRUST)
	cylZ(m, "Crust", CFrame.new(-0.8, 3.0, 0), 1.0, 0.75, CRUST)
	cylZ(m, "Crust", CFrame.new(0.8, 3.0, 0), 1.0, 0.75, CRUST)
	box(m, "Crust", CFrame.new(0, 3.1, 0), Vector3.new(1.6, 1.2, 1.0), CRUST)
	-- 中身（前後に薄く）
	for _, z in { -0.52, 0.52 } do
		box(m, "Crumb", CFrame.new(0, 1.7, z), Vector3.new(2.7, 2.3, 0.05), Color3.fromRGB(255, 245, 220))
		cylZ(m, "Crumb", CFrame.new(-0.8, 3.0, z), 0.05, 0.6, Color3.fromRGB(255, 245, 220))
		cylZ(m, "Crumb", CFrame.new(0.8, 3.0, z), 0.05, 0.6, Color3.fromRGB(255, 245, 220))
		box(m, "Crumb", CFrame.new(0, 3.0, z), Vector3.new(1.6, 1.1, 0.05), Color3.fromRGB(255, 245, 220))
	end
	box(m, "Butter", CFrame.new(0.5, 2.45, -0.6) * CFrame.Angles(0, 0.3, 0), Vector3.new(0.7, 0.3, 0.5), Color3.fromRGB(255, 230, 120))
	Cute.face(m, cf, 0, 1.9, -0.58, { eyeR = 0.34, eyeX = 0.5, mouth = "smile", mouthW = 0.5, mouthDrop = 0.55, blushX = 0.95 })
	Cute.limbs(m, cf, 1.3, 1.5, { size = 0.42 })
end

-- 18. コッペパンくん: 細長いパン、まん中の切れ目
builders.koppepan = function(m, cf)
	ball(m, "Body", CFrame.new(0, 1.4, 0), Vector3.new(3.6, 2.0, 2.2), BREAD)
	ball(m, "Shine", CFrame.new(-0.9, 2.0, -0.6), Vector3.new(1.1, 0.4, 0.5), Color3.fromRGB(245, 205, 140))
	box(m, "Slit", CFrame.new(0, 2.3, 0), Vector3.new(2.6, 0.12, 0.25), Color3.fromRGB(255, 240, 200))
	Cute.face(m, cf, 0, 1.4, -1.05, { eyeR = 0.32, eyeX = 0.5, eyeStyle = "happy", mouth = "w", mouthW = 0.5, mouthDrop = 0.5, blushX = 0.95 })
	Cute.limbs(m, cf, 1.1, 1.75, { size = 0.42 })
end

-- 19. カレーパンくん（R）: 楕円のパン、パン粉、かじった所からカレー
builders.currypan = function(m, cf)
	ball(m, "Body", CFrame.new(0, 1.4, 0), Vector3.new(3.4, 2.2, 2.4), Color3.fromRGB(190, 120, 60))
	local rng = Random.new(19)
	for i = 1, 26 do
		local a = rng:NextNumber(0, 6.28)
		local b = rng:NextNumber(-0.6, 1.0)
		local x, y, z = math.cos(a) * 1.6 * math.cos(b), 1.4 + math.sin(b) * 1.0, math.sin(a) * 1.15 * math.cos(b)
		ball(m, "Crumbs", CFrame.new(x, y, z), Vector3.new(0.22, 0.16, 0.22), i % 2 == 0 and Color3.fromRGB(230, 170, 100) or Color3.fromRGB(150, 90, 45))
	end
	ball(m, "Curry", CFrame.new(1.5, 1.6, -0.2), Vector3.new(0.9, 1.0, 1.2), Color3.fromRGB(170, 110, 40))
	Cute.face(m, cf, -0.3, 1.4, -1.15, { eyeR = 0.32, eyeX = 0.46, mouth = "open", mouthW = 0.5, mouthDrop = 0.5, blushX = 0.95 })
	Cute.limbs(m, cf, 1.1, 1.65, { size = 0.42 })
end

-- 20. クリームパンちゃん（R）: グローブの形、クリームがのぞく
builders.creampan = function(m, cf)
	ball(m, "Body", CFrame.new(0, 1.4, 0), Vector3.new(3.2, 2.2, 2.2), BREAD)
	for i = -2, 2 do
		ball(m, "Body", CFrame.new(i * 0.6, 2.35, 0), Vector3.new(0.8, 0.9, 1.8), BREAD)
	end
	ball(m, "Cream", CFrame.new(1.3, 1.5, -0.6), Vector3.new(0.7, 0.6, 0.6), Color3.fromRGB(255, 240, 170))
	Cute.face(m, cf, -0.2, 1.4, -1.05, { eyeR = 0.32, eyeX = 0.46, eyeStyle = "happy", mouth = "smile", mouthW = 0.45, mouthDrop = 0.5, blushX = 0.9 })
	Cute.limbs(m, cf, 1.1, 1.55, { size = 0.42 })
end

-- 21. ざるそばさん（R）: 竹のざる、そば、のり、つゆ
builders.zarusoba = function(m, cf)
	cylY(m, "Zaru", CFrame.new(0, 0.5, 0), 0.5, 1.9, Color3.fromRGB(215, 185, 120), Enum.Material.Wood)
	for i = -3, 3 do
		box(m, "ZaruLine", CFrame.new(i * 0.5, 0.77, 0), Vector3.new(0.08, 0.03, 3.4), Color3.fromRGB(170, 140, 80))
	end
	ball(m, "Heap", CFrame.new(0, 1.2, 0), Vector3.new(3.0, 1.3, 2.4), Color3.fromRGB(150, 130, 110))
	noodles(m, "Noodle", Vector3.new(0, 1.55, 0), 1.2, 18, Color3.fromRGB(175, 155, 130), 0.1, 21)
	for i = 1, 5 do
		box(m, "Nori", CFrame.new(-0.6 + i * 0.3, 1.95, -0.2 + (i % 2) * 0.3) * CFrame.Angles(0, 0.4 * i, 0), Vector3.new(0.5, 0.03, 0.08), BLACK)
	end
	cylY(m, "Cup", CFrame.new(1.9, 0.9, 0.8), 1.2, 0.5, Color3.fromRGB(60, 60, 70))
	cylY(m, "Tsuyu", CFrame.new(1.9, 1.52, 0.8), 0.06, 0.42, Color3.fromRGB(90, 60, 40))
	Cute.face(m, cf, -0.2, 1.3, -1.2, { eyeR = 0.3, eyeX = 0.45, mouth = "w", mouthW = 0.45, mouthDrop = 0.48, blushX = 0.9 })
	Cute.limbs(m, cf, 1.0, 1.5, { size = 0.4, feet = false })
end

-- 22. つけめんさん（R）: 麺のどんぶりと、濃いスープのどんぶり
builders.tsukemen = function(m, cf)
	local top = bowl(m, 1.5, 1.7, BOWL, Color3.fromRGB(200, 50, 50))
	noodles(m, "Noodle", Vector3.new(0, top + 0.3, 0), 1.0, 14, Color3.fromRGB(255, 230, 150), 0.18, 22)
	-- つけ汁（小さいどんぶり、右奥）
	for i = 0, 3 do
		cylY(m, "SoupBowl", CFrame.new(1.9, 0.3 + i * 0.35, 0.9), 0.37, 0.6 + i * 0.12, Color3.fromRGB(60, 50, 50))
	end
	cylY(m, "Soup", CFrame.new(1.9, 1.75, 0.9), 0.1, 0.9, Color3.fromRGB(120, 70, 40))
	cylY(m, "Negi", CFrame.new(1.7, 1.85, 0.8), 0.1, 0.12, Color3.fromRGB(120, 200, 90))
	ball(m, "Egg", CFrame.new(-0.6, top + 0.5, -0.3), Vector3.new(0.7, 0.3, 0.5), Color3.fromRGB(255, 255, 240))
	ball(m, "Yolk", CFrame.new(-0.6, top + 0.62, -0.3), Vector3.new(0.4, 0.15, 0.3), Color3.fromRGB(255, 180, 60))
	Cute.face(m, cf, 0, 1.15, -1.45, { eyeR = 0.3, eyeX = 0.45, mouth = "smile", mouthW = 0.45, mouthDrop = 0.48, blushX = 0.9 })
	Cute.limbs(m, cf, 1.0, 1.45, { size = 0.4, feet = false })
end

-- 23. ナポリタンちゃん（SR）: 赤い麺、ソーセージ、ピーマン、たまご。キラキラ
builders.napolitan = function(m, cf)
	cylY(m, "Plate", CFrame.new(0, 0.4, 0), 0.25, 2.1, WHITE)
	ball(m, "Heap", CFrame.new(0, 1.3, 0), Vector3.new(3.2, 1.7, 2.6), Color3.fromRGB(215, 90, 50))
	noodles(m, "Noodle", Vector3.new(0, 1.8, 0), 1.3, 20, Color3.fromRGB(240, 120, 60), 0.14, 23)
	for i = 1, 4 do
		local a = i / 4 * math.pi * 2
		cylY(m, "Sausage", CFrame.new(math.cos(a) * 0.9, 2.2, math.sin(a) * 0.7) * CFrame.Angles(0.5, a, 0), 0.25, 0.3, Color3.fromRGB(200, 80, 80))
	end
	for i = 1, 3 do
		cylY(m, "Pepper", CFrame.new(-0.9 + i * 0.6, 2.3, 0.3) * CFrame.Angles(0.4, 0, 0), 0.08, 0.3, Color3.fromRGB(80, 160, 70))
	end
	ball(m, "Egg", CFrame.new(0.3, 2.2, -0.5), Vector3.new(1.0, 0.25, 0.8), Color3.fromRGB(255, 255, 240))
	ball(m, "Yolk", CFrame.new(0.3, 2.32, -0.5), Vector3.new(0.5, 0.2, 0.45), Color3.fromRGB(255, 180, 60))
	Cute.face(m, cf, 0, 1.45, -1.3, { eyeR = 0.32, eyeX = 0.46, eyeStyle = "happy", mouth = "w", mouthW = 0.5, mouthDrop = 0.5, blushX = 0.95 })
	Cute.limbs(m, cf, 1.1, 1.55, { size = 0.42, feet = false })
	Cute.sparkles(m, cf, 1.8, 2.3, 6, Color3.fromRGB(255, 220, 150))
end

-- 24. 金のメロンパン（UR）: 金属の質感、王冠、キラキラ
builders.goldmelonpan = function(m, cf)
	local gold = Color3.fromRGB(255, 205, 60)
	ball(m, "Body", CFrame.new(0, 1.5, 0), Vector3.new(3.0, 2.4, 2.9), gold, Enum.Material.Metal)
	ball(m, "Top", CFrame.new(0, 1.75, 0), Vector3.new(3.05, 2.1, 2.95), Color3.fromRGB(255, 230, 140), Enum.Material.Metal)
	for i = -2, 2 do
		for _, a in { 0.78, -0.78 } do
			piece(m, "Grid", CFrame.new(0, 2.78, 0) * CFrame.Angles(0, a, 0) * CFrame.new(i * 0.55, 0, 0) * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(0.08, 0.06, 2.6 - math.abs(i) * 0.5), Color3.fromRGB(200, 150, 60), "cyl", Enum.Material.Metal)
		end
	end
	cylY(m, "CrownCloth", CFrame.new(0, 2.95, 0), 0.4, 0.55, Color3.fromRGB(200, 40, 60), Enum.Material.Fabric)
	cylY(m, "Crown", CFrame.new(0, 3.1, 0), 0.3, 0.7, Color3.fromRGB(255, 240, 150), Enum.Material.Metal)
	for i = 1, 6 do
		local a = i / 6 * math.pi * 2
		box(m, "CrownTip", CFrame.new(math.cos(a) * 0.58, 3.45, math.sin(a) * 0.58), Vector3.new(0.2, 0.5, 0.2), Color3.fromRGB(255, 240, 150), Enum.Material.Metal)
		ball(m, "CrownBall", CFrame.new(math.cos(a) * 0.58, 3.73, math.sin(a) * 0.58), Vector3.new(0.22, 0.22, 0.22), Color3.fromRGB(255, 60, 90), Enum.Material.Neon)
	end
	Cute.face(m, cf, 0, 1.45, -1.42, { eyeR = 0.34, eyeX = 0.48, eyeStyle = "happy", mouth = "smile", mouthW = 0.5, mouthDrop = 0.5, blushX = 0.95 })
	Cute.limbs(m, cf, 1.2, 1.45, { size = 0.45, color = Color3.fromRGB(255, 225, 140) })
	Cute.sparkles(m, cf, 1.8, 2.3, 8, Color3.fromRGB(255, 240, 180))
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") and p.Material == Enum.Material.Metal then
			p.Reflectance = 0.2
		end
	end
end

return builders
