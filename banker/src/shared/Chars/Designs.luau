-- 登場人物と敵の見た目。全部コードで部品から組む（かわいい 2.5 頭身、顔は Cute の道具）。
-- 座標: cf を足元の中心とし、-Z が正面。原点で組んでから Designs.build が動かす。
local Cute = require(script.Parent.Cute)
local ball, box, cylY, cylZ, cylX, piece = Cute.ball, Cute.box, Cute.cylY, Cute.cylZ, Cute.cylX, Cute.piece
local BLACK, WHITE, PINK = Cute.BLACK, Cute.WHITE, Cute.PINK

local Designs = {}
local builders = {}

local SKIN = Color3.fromRGB(255, 224, 196)
local NAVY = Color3.fromRGB(40, 55, 95)
local CHARCOAL = Color3.fromRGB(55, 55, 65)
local SILVER = Color3.fromRGB(200, 205, 215)
local GOLD = Color3.fromRGB(255, 205, 60)
local RED = Color3.fromRGB(220, 50, 60)
local BROWN = Color3.fromRGB(120, 80, 50)

-- ===== 人（主役・NPC）の共通ビルダー =====
-- o: suit, tie, hair, hairStyle("cap"/"side"/"pony"/"slick"/"bald"), skin, glasses, mustache, bag, scale, eyeStyle, mouth, brows
local function human(m, cf, o)
	local s = o.scale or 1
	local suit = o.suit or NAVY
	local skin = o.skin or SKIN
	-- 足
	for _, side in { -1, 1 } do
		box(m, "Leg", cf * CFrame.new(side * 0.35 * s, 0.45 * s, 0), Vector3.new(0.55, 0.9, 0.6) * s, suit)
		box(m, "Shoe", cf * CFrame.new(side * 0.35 * s, 0.12 * s, -0.1 * s), Vector3.new(0.6, 0.25, 0.85) * s, Color3.fromRGB(40, 30, 30))
	end
	-- 体（スーツ）
	box(m, "Body", cf * CFrame.new(0, 1.55 * s, 0), Vector3.new(1.7, 1.4, 1.0) * s, suit)
	-- シャツの V と ネクタイ
	piece(m, "Shirt", cf * CFrame.new(0, 1.85 * s, -0.5 * s) * CFrame.Angles(0, 0, math.pi / 4), Vector3.new(0.5, 0.5, 0.06) * s, WHITE, "box")
	box(m, "Tie", cf * CFrame.new(0, 1.55 * s, -0.53 * s), Vector3.new(0.22, 0.9, 0.06) * s, o.tie or RED)
	-- 腕
	for _, side in { -1, 1 } do
		box(m, "Arm", cf * CFrame.new(side * 1.05 * s, 1.5 * s, 0), Vector3.new(0.45, 1.2, 0.5) * s, suit)
		ball(m, "Hand", cf * CFrame.new(side * 1.05 * s, 0.85 * s, 0), Vector3.new(0.45, 0.45, 0.45) * s, skin)
	end
	-- 頭（大きい）
	local headY = 3.2 * s
	local hr = 1.15 * s
	ball(m, "Head", cf * CFrame.new(0, headY, 0), Vector3.new(hr * 2, hr * 1.9, hr * 1.9), skin)
	-- 髪
	local hair = o.hair or Color3.fromRGB(45, 35, 35)
	local style = o.hairStyle or "cap"
	if style ~= "bald" then
		ball(m, "Hair", cf * CFrame.new(0, headY + 0.35 * s, 0.1 * s), Vector3.new(hr * 2.1, hr * 1.5, hr * 2.0), hair)
	end
	if style == "side" then
		ball(m, "Hair", cf * CFrame.new(-0.6 * s, headY + 0.4 * s, -0.75 * s), Vector3.new(0.9, 0.5, 0.6) * s, hair)
	elseif style == "pony" then
		ball(m, "Hair", cf * CFrame.new(0, headY + 0.1 * s, 1.1 * s), Vector3.new(0.7, 0.7, 0.7) * s, hair)
		ball(m, "Hair", cf * CFrame.new(0.1 * s, headY - 0.6 * s, 1.25 * s), Vector3.new(0.5, 1.2, 0.5) * s, hair)
		ball(m, "Hair", cf * CFrame.new(0.7 * s, headY + 0.45 * s, -0.7 * s), Vector3.new(0.9, 0.45, 0.6) * s, hair)
	elseif style == "slick" then
		ball(m, "Hair", cf * CFrame.new(0, headY + 0.6 * s, 0.5 * s), Vector3.new(1.4, 0.9, 1.6) * s, hair)
	elseif style == "gray" then
		ball(m, "Hair", cf * CFrame.new(-0.95 * s, headY, 0.2 * s), Vector3.new(0.5, 1.1, 1.3) * s, hair)
		ball(m, "Hair", cf * CFrame.new(0.95 * s, headY, 0.2 * s), Vector3.new(0.5, 1.1, 1.3) * s, hair)
	elseif style == "cap" then
		-- 前髪の束
		for i = -1, 1 do
			ball(m, "Hair", cf * CFrame.new(i * 0.45 * s, headY + 0.55 * s, -0.95 * s), Vector3.new(0.55, 0.5, 0.4) * s, hair)
		end
	end
	Cute.face(m, cf, 0, headY, -hr * 0.92, {
		eyeR = 0.3 * s, eyeX = 0.42 * s, eyeStyle = o.eyeStyle, mouth = o.mouth or "smile", mouthW = 0.4 * s, mouthDrop = 0.5 * s, blushX = 0.85 * s,
	})
	if o.brows then
		for _, side in { -1, 1 } do
			piece(m, "Brow", cf * CFrame.new(side * 0.42 * s, headY + 0.45 * s, -hr * 0.95) * CFrame.Angles(0, 0, side * (o.brows == "angry" and 0.45 or -0.2)), Vector3.new(0.45, 0.1, 0.08) * s, hair, "box")
		end
	end
	if o.glasses then
		for _, side in { -1, 1 } do
			local g = cylZ(m, "Glasses", cf * CFrame.new(side * 0.42 * s, headY, -hr * 1.02), 0.06, 0.36 * s, o.glasses)
			g.Transparency = 0.3
		end
		box(m, "Glasses", cf * CFrame.new(0, headY, -hr * 1.02), Vector3.new(0.2, 0.06, 0.06) * s, o.glasses)
	end
	if o.mustache then
		ball(m, "Mustache", cf * CFrame.new(0, headY - 0.35 * s, -hr * 1.0), Vector3.new(0.8, 0.25, 0.3) * s, o.mustache)
	end
	if o.bag then
		box(m, "Bag", cf * CFrame.new(1.25 * s, 0.9 * s, -0.1 * s), Vector3.new(0.35, 0.9, 1.1) * s, o.bag)
		box(m, "BagClasp", cf * CFrame.new(1.25 * s, 1.1 * s, -0.1 * s), Vector3.new(0.4, 0.12, 0.3) * s, GOLD)
	end
	return headY
end

-- ===== 主役 =====
builders.taku = function(m, cf)
	human(m, cf, { suit = NAVY, tie = RED, hairStyle = "cap", bag = BROWN, mouth = "smile" })
end
-- 部長 カネモト（白髪まじり・口ひげ・めがね・大きめ）
builders.kanemoto = function(m, cf)
	human(m, cf, { suit = CHARCOAL, tie = Color3.fromRGB(90, 70, 120), hair = Color3.fromRGB(190, 190, 195), hairStyle = "gray", mustache = Color3.fromRGB(190, 190, 195), glasses = Color3.fromRGB(80, 80, 90), scale = 1.12, mouth = "w", brows = "angry" })
end
-- 先輩 ミサキ（ポニーテール・売店のエプロン）
builders.misaki = function(m, cf)
	local headY = human(m, cf, { suit = Color3.fromRGB(70, 90, 140), tie = Color3.fromRGB(255, 160, 80), hair = Color3.fromRGB(110, 60, 40), hairStyle = "pony", eyeStyle = "happy", mouth = "smile" })
	box(m, "Apron", cf * CFrame.new(0, 1.3, -0.52), Vector3.new(1.3, 1.0, 0.06), Color3.fromRGB(255, 240, 200))
	box(m, "ApronPocket", cf * CFrame.new(0, 1.1, -0.56), Vector3.new(0.6, 0.35, 0.06), Color3.fromRGB(255, 200, 120))
end
-- ライバル ハヤテ（オールバック・サングラス・シルバーのスーツ）
builders.hayate = function(m, cf)
	local headY = human(m, cf, { suit = SILVER, tie = Color3.fromRGB(30, 30, 40), hair = Color3.fromRGB(30, 30, 40), hairStyle = "slick", mouth = "smile", brows = "angry" })
	for _, side in { -1, 1 } do
		box(m, "Shades", cf * CFrame.new(side * 0.42, headY, -1.08), Vector3.new(0.7, 0.42, 0.08), Color3.fromRGB(20, 20, 25))
	end
	box(m, "Shades", cf * CFrame.new(0, headY, -1.08), Vector3.new(0.3, 0.08, 0.08), Color3.fromRGB(20, 20, 25))
end
-- 迷子のインターン（小さい・パーカー）
builders.intern = function(m, cf)
	human(m, cf, { suit = Color3.fromRGB(90, 170, 120), tie = Color3.fromRGB(90, 170, 120), hair = Color3.fromRGB(80, 50, 30), hairStyle = "side", scale = 0.8, mouth = "o" })
	ball(m, "Hood", cf * CFrame.new(0, 2.3, 0.45), Vector3.new(1.4, 0.7, 0.9), Color3.fromRGB(90, 170, 120))
end
-- 気むずかしいクライアント（昇進試験）
builders.client = function(m, cf)
	human(m, cf, { suit = Color3.fromRGB(80, 60, 50), tie = Color3.fromRGB(200, 160, 40), hair = Color3.fromRGB(60, 50, 45), hairStyle = "slick", scale = 1.15, mouth = "w", brows = "angry", glasses = Color3.fromRGB(120, 90, 40) })
	box(m, "Case", cf * CFrame.new(-1.4, 0.9, -0.1), Vector3.new(0.3, 0.9, 1.2), Color3.fromRGB(40, 30, 30))
end
-- 取締役（30F）
builders.director = function(m, cf)
	local headY = human(m, cf, { suit = Color3.fromRGB(25, 25, 35), tie = GOLD, hair = Color3.fromRGB(220, 220, 225), hairStyle = "gray", mustache = Color3.fromRGB(220, 220, 225), scale = 1.2, mouth = "w", brows = "angry" })
	ball(m, "Badge", cf * CFrame.new(-0.6, 2.1, -0.62), Vector3.new(0.35, 0.35, 0.1), GOLD, Enum.Material.Metal)
end

-- ===== 敵 =====
local function shadow(m, cf, r)
	local s = cylY(m, "Shadow", cf * CFrame.new(0, 0.03, 0), 0.05, r, Color3.fromRGB(20, 20, 30))
	s.Transparency = 0.6
end

-- あかじくん: 赤いしずく。おでこに「−」
builders.akaji = function(m, cf)
	local red = Color3.fromRGB(235, 70, 70)
	ball(m, "Body", cf * CFrame.new(0, 1.2, 0), Vector3.new(2.0, 2.1, 1.9), red)
	ball(m, "Top", cf * CFrame.new(0, 2.35, 0), Vector3.new(0.9, 1.1, 0.9), red)
	ball(m, "Top", cf * CFrame.new(0, 2.85, 0), Vector3.new(0.4, 0.6, 0.4), red)
	box(m, "Minus", cf * CFrame.new(0, 1.85, -0.9), Vector3.new(0.6, 0.14, 0.08), WHITE)
	Cute.face(m, cf, 0, 1.25, -0.95, { eyeR = 0.28, eyeX = 0.38, mouth = "w", mouthW = 0.4, mouthDrop = 0.45 })
	Cute.limbs(m, cf, 1.0, 0.95, { size = 0.4, color = red })
end
-- バブルん: 透けるピンクのシャボン玉
builders.bubble = function(m, cf)
	local pinkG = Color3.fromRGB(255, 170, 210)
	local b = ball(m, "Body", cf * CFrame.new(0, 1.5, 0), Vector3.new(2.6, 2.6, 2.6), pinkG, Enum.Material.Glass)
	b.Transparency = 0.35
	b.Reflectance = 0.15
	ball(m, "Shine", cf * CFrame.new(-0.7, 2.3, -0.7), Vector3.new(0.6, 0.35, 0.3), WHITE)
	Cute.face(m, cf, 0, 1.55, -1.2, { eyeR = 0.3, eyeX = 0.42, eyeStyle = "happy", mouth = "o", mouthW = 0.35, mouthDrop = 0.5 })
	-- 小さな泡
	for i, o in { Vector3.new(1.3, 2.6, 0.2), Vector3.new(-1.4, 2.2, 0.5), Vector3.new(0.9, 0.5, -0.6) } do
		local s = ball(m, "Bubble", cf * CFrame.new(o), Vector3.new(0.4, 0.4, 0.4) * (1 + i * 0.1), pinkG, Enum.Material.Glass)
		s.Transparency = 0.4
	end
end
-- 手数料コウモリ: 紫のまるい体、羽、コインを抱える
builders.fee = function(m, cf)
	local purple = Color3.fromRGB(110, 70, 150)
	ball(m, "Body", cf * CFrame.new(0, 1.7, 0), Vector3.new(1.6, 1.5, 1.4), purple)
	for _, side in { -1, 1 } do
		piece(m, "Wing", cf * CFrame.new(side * 1.3, 2.0, 0.1) * CFrame.Angles(0, 0, side * 0.5) * CFrame.Angles(0, side * math.pi / 2, 0), Vector3.new(0.6, 0.9, 1.4), purple, "wedge")
		piece(m, "Ear", cf * CFrame.new(side * 0.5, 2.55, 0) * CFrame.Angles(0, 0, side * 0.3), Vector3.new(0.35, 0.6, 0.2), purple, "box")
	end
	cylZ(m, "Coin", cf * CFrame.new(0, 0.9, -0.55), 0.12, 0.45, GOLD, Enum.Material.Metal)
	Cute.face(m, cf, 0, 1.8, -0.72, { eyeR = 0.26, eyeX = 0.36, mouth = "w", mouthW = 0.35, mouthDrop = 0.4 })
	for _, side in { -1, 1 } do
		ball(m, "Foot", cf * CFrame.new(side * 0.3, 0.95, 0.1), Vector3.new(0.3, 0.35, 0.3), purple)
	end
end
-- インフレねずみ: 灰色、大きな耳、「↑」の札
builders.inflation = function(m, cf)
	local gray = Color3.fromRGB(170, 170, 180)
	ball(m, "Body", cf * CFrame.new(0, 1.0, 0), Vector3.new(2.0, 1.7, 2.2), gray)
	for _, side in { -1, 1 } do
		cylZ(m, "Ear", cf * CFrame.new(side * 0.8, 2.1, 0.2), 0.2, 0.55, gray)
		cylZ(m, "EarIn", cf * CFrame.new(side * 0.8, 2.1, 0.08), 0.1, 0.35, PINK)
	end
	ball(m, "Nose", cf * CFrame.new(0, 0.95, -1.15), Vector3.new(0.3, 0.25, 0.3), PINK)
	cylX(m, "Tail", cf * CFrame.new(0.6, 0.5, 1.4) * CFrame.Angles(0, 0.8, 0.3), 1.6, 0.08, PINK)
	-- 上向き矢印の札
	box(m, "Sign", cf * CFrame.new(1.2, 1.8, -0.3), Vector3.new(0.7, 0.7, 0.08), WHITE)
	box(m, "Arrow", cf * CFrame.new(1.2, 1.75, -0.36), Vector3.new(0.12, 0.4, 0.04), RED)
	piece(m, "Arrow", cf * CFrame.new(1.2, 2.0, -0.36) * CFrame.Angles(0, -math.pi / 2, 0), Vector3.new(0.04, 0.25, 0.4), RED, "wedge")
	cylY(m, "SignPole", cf * CFrame.new(1.2, 1.1, -0.3), 0.8, 0.05, BROWN)
	Cute.face(m, cf, 0, 1.3, -1.0, { eyeR = 0.24, eyeX = 0.4, mouth = "o", mouthW = 0.3, mouthDrop = 0.35, blushX = 0.75 })
	Cute.limbs(m, cf, 0.8, 1.0, { size = 0.32, color = gray })
end
-- リスクのカゲ: 半透明の黒いもや、光る目だけ
builders.risk = function(m, cf)
	local dark = Color3.fromRGB(30, 25, 45)
	for i, o in { { Vector3.new(0, 1.4, 0), 2.4 }, { Vector3.new(0.6, 2.4, 0.2), 1.3 }, { Vector3.new(-0.7, 2.2, -0.1), 1.1 }, { Vector3.new(0, 0.6, 0.3), 1.6 } } do
		local b = ball(m, "Body", cf * CFrame.new(o[1]), Vector3.new(o[2], o[2] * 0.9, o[2]), dark)
		b.Transparency = 0.35
	end
	for _, side in { -1, 1 } do
		ball(m, "GlowEye", cf * CFrame.new(side * 0.4, 1.6, -0.9), Vector3.new(0.45, 0.3, 0.2), Color3.fromRGB(255, 240, 120), Enum.Material.Neon)
	end
end
-- 不良債権ワニ: 緑の長い体、大きな口と歯
builders.gator = function(m, cf)
	local green = Color3.fromRGB(80, 150, 80)
	local belly = Color3.fromRGB(200, 220, 160)
	box(m, "Body", cf * CFrame.new(0, 0.9, 0.4), Vector3.new(1.8, 1.2, 2.6), green)
	box(m, "Belly", cf * CFrame.new(0, 0.6, 0.4), Vector3.new(1.4, 0.5, 2.3), belly)
	-- 口（上あご・下あご）
	box(m, "Jaw", cf * CFrame.new(0, 1.3, -1.6), Vector3.new(1.4, 0.45, 1.6), green)
	box(m, "JawLow", cf * CFrame.new(0, 0.75, -1.5), Vector3.new(1.3, 0.35, 1.4), belly)
	for i = 0, 3 do
		for _, side in { -1, 1 } do
			piece(m, "Tooth", cf * CFrame.new(side * 0.5, 1.0, -1.0 - i * 0.35) * CFrame.Angles(math.pi, 0, 0), Vector3.new(0.14, 0.22, 0.14), WHITE, "wedge")
		end
	end
	-- 目（頭の上）
	for _, side in { -1, 1 } do
		ball(m, "EyeBump", cf * CFrame.new(side * 0.55, 1.75, -0.7), Vector3.new(0.6, 0.5, 0.6), green)
	end
	Cute.eye(m, cf, Vector3.new(-0.55, 1.85, -0.95), 0.22)
	Cute.eye(m, cf, Vector3.new(0.55, 1.85, -0.95), 0.22)
	-- しっぽ、背中のとげ
	piece(m, "Tail", cf * CFrame.new(0, 0.8, 2.2) * CFrame.Angles(0, 0, 0) * CFrame.Angles(-math.pi / 2, 0, 0), Vector3.new(1.0, 1.4, 0.8), green, "wedge")
	for i = 0, 3 do
		piece(m, "Spike", cf * CFrame.new(0, 1.65, -0.4 + i * 0.6) * CFrame.Angles(0, math.pi / 2, 0), Vector3.new(0.4, 0.35, 0.3), Color3.fromRGB(60, 110, 60), "wedge")
	end
	for _, side in { -1, 1 } do
		for _, z in { -0.5, 1.2 } do
			ball(m, "Foot", cf * CFrame.new(side * 1.0, 0.3, z), Vector3.new(0.6, 0.45, 0.7), green)
		end
	end
	Cute.blush(m, cf, Vector3.new(-0.95, 1.2, -0.9), 0.35)
	Cute.blush(m, cf, Vector3.new(0.95, 1.2, -0.9), 0.35)
end
-- 為替カメレオン: 緑に色の斑点、ぐるぐるしっぽ、大きな目
builders.fx = function(m, cf)
	local lime = Color3.fromRGB(130, 200, 90)
	ball(m, "Body", cf * CFrame.new(0, 1.1, 0.1), Vector3.new(2.2, 1.6, 2.6), lime)
	ball(m, "Head", cf * CFrame.new(0, 1.8, -1.0), Vector3.new(1.5, 1.3, 1.4), lime)
	piece(m, "Crest", cf * CFrame.new(0, 2.5, -1.0) * CFrame.Angles(0, math.pi / 2, 0), Vector3.new(0.8, 0.5, 0.3), Color3.fromRGB(90, 160, 70), "wedge")
	for i, col in { Color3.fromRGB(255, 170, 60), Color3.fromRGB(80, 160, 255), Color3.fromRGB(255, 100, 150) } do
		ball(m, "Spot" .. i, cf * CFrame.new(-0.8 + i * 0.6, 1.4 + (i % 2) * 0.3, -0.3 + i * 0.3), Vector3.new(0.5, 0.4, 0.3), col)
	end
	-- ぐるぐるしっぽ
	for i = 0, 5 do
		local a = i * 0.9
		ball(m, "Tail", cf * CFrame.new(0, 1.0 + math.sin(a) * 0.5, 1.5 + math.cos(a) * 0.5), Vector3.new(0.5 - i * 0.05, 0.5 - i * 0.05, 0.5 - i * 0.05), lime)
	end
	-- 出目
	for _, side in { -1, 1 } do
		ball(m, "EyeBump", cf * CFrame.new(side * 0.6, 2.05, -1.3), Vector3.new(0.65, 0.65, 0.65), lime)
	end
	Cute.eye(m, cf, Vector3.new(-0.6, 2.1, -1.6), 0.24)
	Cute.eye(m, cf, Vector3.new(0.6, 2.1, -1.6), 0.24)
	Cute.mouth(m, cf, Vector3.new(0, 1.55, -1.7), 0.45, "smile")
	for _, side in { -1, 1 } do
		for _, z in { -0.5, 0.8 } do
			ball(m, "Foot", cf * CFrame.new(side * 1.0, 0.35, z), Vector3.new(0.5, 0.45, 0.6), lime)
		end
	end
end
-- 利息ヘビ: とぐろを巻いた黄色いヘビ、頭に「%」
builders.interest = function(m, cf)
	local yellow = Color3.fromRGB(240, 200, 70)
	local dark = Color3.fromRGB(190, 140, 40)
	for i = 0, 10 do
		local a = i * 0.65
		local r = 1.0 - i * 0.05
		ball(m, "Coil", cf * CFrame.new(math.cos(a) * r, 0.45 + i * 0.13, math.sin(a) * r), Vector3.new(0.8, 0.7, 0.8), i % 2 == 0 and yellow or dark)
	end
	ball(m, "Head", cf * CFrame.new(0, 2.5, -0.5), Vector3.new(1.3, 1.1, 1.4), yellow)
	-- 舌
	box(m, "Tongue", cf * CFrame.new(0, 2.3, -1.3), Vector3.new(0.1, 0.06, 0.5), RED)
	-- ％ の札
	box(m, "Sign", cf * CFrame.new(0, 3.3, -0.3), Vector3.new(0.7, 0.6, 0.08), WHITE)
	ball(m, "Pct", cf * CFrame.new(-0.18, 3.42, -0.36), Vector3.new(0.2, 0.2, 0.05), dark)
	ball(m, "Pct", cf * CFrame.new(0.18, 3.18, -0.36), Vector3.new(0.2, 0.2, 0.05), dark)
	piece(m, "Pct", cf * CFrame.new(0, 3.3, -0.36) * CFrame.Angles(0, 0, 0.8), Vector3.new(0.08, 0.5, 0.04), dark, "box")
	Cute.face(m, cf, 0, 2.6, -1.15, { eyeR = 0.24, eyeX = 0.34, mouth = "w", mouthW = 0.35, mouthDrop = 0.35, blushX = 0.7 })
end
-- 会議のねむけ: 水色のもこもこ雲、ナイトキャップ、閉じた目
builders.sleepy = function(m, cf)
	local cloud = Color3.fromRGB(200, 225, 255)
	for _, o in { { Vector3.new(0, 1.2, 0), 2.2 }, { Vector3.new(0.9, 1.5, 0.2), 1.4 }, { Vector3.new(-0.9, 1.5, 0.2), 1.4 }, { Vector3.new(0, 2.0, 0.1), 1.6 }, { Vector3.new(0.4, 0.7, -0.6), 1.2 } } do
		ball(m, "Body", cf * CFrame.new(o[1]), Vector3.new(o[2], o[2] * 0.85, o[2]), cloud)
	end
	-- ナイトキャップ
	piece(m, "Cap", cf * CFrame.new(0.3, 3.0, 0) * CFrame.Angles(0, 0, -0.5) * CFrame.Angles(0, math.pi / 2, 0), Vector3.new(1.0, 1.2, 1.0), Color3.fromRGB(100, 110, 200), "wedge")
	ball(m, "CapBall", cf * CFrame.new(0.9, 3.4, 0), Vector3.new(0.4, 0.4, 0.4), WHITE)
	Cute.face(m, cf, 0, 1.45, -1.05, { eyeR = 0.3, eyeX = 0.42, eyeStyle = "happy", mouth = "o", mouthW = 0.3, mouthDrop = 0.45 })
	-- Zzz
	for i = 1, 3 do
		local z = box(m, "Zzz", cf * CFrame.new(1.2 + i * 0.3, 2.3 + i * 0.4, -0.3), Vector3.new(0.25, 0.25, 0.05) * (0.7 + i * 0.15), Color3.fromRGB(120, 140, 255), Enum.Material.Neon)
	end
end
-- 破産おばけ: 白いおばけ、下がひらひら、空っぽの財布
builders.bankrupt = function(m, cf)
	local ghost = Color3.fromRGB(245, 245, 255)
	local b = ball(m, "Body", cf * CFrame.new(0, 1.8, 0), Vector3.new(2.2, 2.6, 2.0), ghost)
	b.Transparency = 0.1
	for i = 0, 4 do
		local x = -0.8 + i * 0.4
		local f = ball(m, "Frill", cf * CFrame.new(x, 0.6 + (i % 2) * 0.25, 0), Vector3.new(0.5, 0.7, 1.6), ghost)
		f.Transparency = 0.1
	end
	-- ひっくり返した空の財布
	box(m, "Wallet", cf * CFrame.new(-1.1, 1.3, -0.5) * CFrame.Angles(0, 0, 0.6), Vector3.new(0.8, 0.5, 0.2), BROWN)
	Cute.face(m, cf, 0, 2.0, -0.95, { eyeR = 0.32, eyeX = 0.45, mouth = "open", mouthW = 0.5, mouthDrop = 0.55 })
	for _, side in { -1, 1 } do
		local a = ball(m, "Arm", cf * CFrame.new(side * 1.25, 1.6, -0.3), Vector3.new(0.6, 0.5, 0.6), ghost)
		a.Transparency = 0.1
	end
end
-- 監査ロボ: 銀の箱、アンテナ、画面の目
builders.auditor = function(m, cf)
	local metal = Color3.fromRGB(190, 195, 205)
	box(m, "Body", cf * CFrame.new(0, 1.3, 0), Vector3.new(2.0, 1.8, 1.6), metal, Enum.Material.Metal)
	box(m, "Head", cf * CFrame.new(0, 2.75, 0), Vector3.new(1.7, 1.1, 1.4), metal, Enum.Material.Metal)
	box(m, "Screen", cf * CFrame.new(0, 2.75, -0.72), Vector3.new(1.3, 0.75, 0.06), Color3.fromRGB(30, 40, 60))
	for _, side in { -1, 1 } do
		box(m, "ScreenEye", cf * CFrame.new(side * 0.35, 2.8, -0.76), Vector3.new(0.3, 0.3, 0.04), Color3.fromRGB(120, 255, 200), Enum.Material.Neon)
	end
	box(m, "ScreenMouth", cf * CFrame.new(0, 2.5, -0.76), Vector3.new(0.6, 0.08, 0.04), Color3.fromRGB(120, 255, 200), Enum.Material.Neon)
	cylY(m, "Antenna", cf * CFrame.new(0, 3.55, 0), 0.6, 0.05, metal)
	ball(m, "AntennaBall", cf * CFrame.new(0, 3.9, 0), Vector3.new(0.3, 0.3, 0.3), RED, Enum.Material.Neon)
	-- 胸のランプとスタンプ
	for i, col in { Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 220, 80), Color3.fromRGB(80, 255, 120) } do
		ball(m, "Lamp", cf * CFrame.new(-0.5 + i * 0.35, 1.6, -0.82), Vector3.new(0.2, 0.2, 0.1), col, Enum.Material.Neon)
	end
	box(m, "Stamp", cf * CFrame.new(1.3, 1.0, -0.4), Vector3.new(0.4, 0.5, 0.4), RED)
	for _, side in { -1, 1 } do
		box(m, "Arm", cf * CFrame.new(side * 1.25, 1.3, 0), Vector3.new(0.4, 1.2, 0.4), Color3.fromRGB(120, 125, 135), Enum.Material.Metal)
		box(m, "Tread", cf * CFrame.new(side * 0.6, 0.25, 0), Vector3.new(0.7, 0.5, 1.7), Color3.fromRGB(60, 60, 70))
	end
	Cute.blush(m, cf, Vector3.new(-0.7, 2.45, -0.72), 0.3)
	Cute.blush(m, cf, Vector3.new(0.7, 2.45, -0.72), 0.3)
end
-- ダークコイン: 黒い大きなコイン、金のふち、赤い目
builders.darkcoin = function(m, cf)
	cylZ(m, "Rim", cf * CFrame.new(0, 1.5, 0), 0.5, 1.4, GOLD, Enum.Material.Metal)
	cylZ(m, "Body", cf * CFrame.new(0, 1.5, 0), 0.56, 1.2, Color3.fromRGB(35, 30, 45), Enum.Material.Metal)
	-- 「¥」の刻印
	box(m, "Mark", cf * CFrame.new(0, 1.9, -0.3), Vector3.new(0.6, 0.1, 0.04), GOLD)
	box(m, "Mark", cf * CFrame.new(0, 1.7, -0.3), Vector3.new(0.6, 0.1, 0.04), GOLD)
	box(m, "Mark", cf * CFrame.new(0, 1.55, -0.3), Vector3.new(0.1, 0.7, 0.04), GOLD)
	for _, side in { -1, 1 } do
		box(m, "Mark", cf * CFrame.new(side * 0.22, 2.2, -0.3) * CFrame.Angles(0, 0, side * 0.5), Vector3.new(0.1, 0.5, 0.04), GOLD)
	end
	for _, side in { -1, 1 } do
		ball(m, "GlowEye", cf * CFrame.new(side * 0.45, 0.95, -0.3), Vector3.new(0.4, 0.25, 0.1), Color3.fromRGB(255, 70, 70), Enum.Material.Neon)
	end
	Cute.mouth(m, cf, Vector3.new(0, 0.65, -0.3), 0.4, "w")
	Cute.limbs(m, cf, 1.3, 1.3, { size = 0.4, color = Color3.fromRGB(35, 30, 45) })
end
-- ダークマネー（ラスボス）: 紫の大きなもや、コインが埋まっている、コインの王冠
builders.darkmoney = function(m, cf)
	local dark = Color3.fromRGB(60, 30, 90)
	for _, o in { { Vector3.new(0, 2.2, 0), 4.2 }, { Vector3.new(1.4, 3.6, 0.4), 2.2 }, { Vector3.new(-1.5, 3.4, 0.2), 2.0 }, { Vector3.new(0, 4.3, 0.3), 2.4 }, { Vector3.new(0.6, 0.9, -0.6), 2.6 }, { Vector3.new(-0.8, 1.0, 0.5), 2.4 } } do
		local b = ball(m, "Body", cf * CFrame.new(o[1]), Vector3.new(o[2], o[2] * 0.85, o[2]), dark)
		b.Transparency = 0.15
	end
	local rng = Random.new(3)
	for i = 1, 10 do
		local a = i / 10 * math.pi * 2
		cylZ(m, "Coin", cf * CFrame.new(math.cos(a) * 1.9, 1.6 + rng:NextNumber(0, 2.2), math.sin(a) * 1.9) * CFrame.Angles(0, a, 0), 0.15, 0.4, GOLD, Enum.Material.Metal)
	end
	-- コインの王冠
	for i = 1, 7 do
		local a = i / 7 * math.pi * 2
		cylZ(m, "Crown", cf * CFrame.new(math.cos(a) * 0.9, 5.6, math.sin(a) * 0.9) * CFrame.Angles(0, a + math.pi / 2, 0), 0.15, 0.4, GOLD, Enum.Material.Metal)
	end
	for _, side in { -1, 1 } do
		ball(m, "GlowEye", cf * CFrame.new(side * 0.8, 2.8, -1.9), Vector3.new(0.8, 0.5, 0.3), Color3.fromRGB(255, 220, 90), Enum.Material.Neon)
	end
	Cute.mouth(m, cf, Vector3.new(0, 1.9, -2.0), 0.9, "w")
	Cute.sparkles(m, cf, 2.5, 3.0, 8, Color3.fromRGB(200, 120, 255))
end

Designs.ids = {}
for id in builders do
	table.insert(Designs.ids, id)
end
table.sort(Designs.ids)

-- 組み立てて返す。cf = 足元の中心（-Z が正面）
function Designs.build(id: string, cf: CFrame, parent: Instance): Model
	local builder = builders[id] or builders.akaji
	local m = Instance.new("Model")
	m.Name = id
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(2, 3, 2)
	root.CFrame = CFrame.new(0, 1.5, 0)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.Parent = m
	m.PrimaryPart = root
	builder(m, CFrame.new())
	m:PivotTo(cf * CFrame.new(0, 1.5, 0))
	m.Parent = parent
	return m
end

return Designs
