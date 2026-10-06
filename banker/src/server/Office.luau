-- 拠点「ホワイトタワー証券 本社オフィス」。みんなが歩き回る普通の 3D 空間。
-- 売店（ミサキ）・部長の部屋（カネモト）・エレベーター（塔へ）・本日の案件・ロッカー・社内ランキング
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Designs = require(ReplicatedStorage.Shared.Chars.Designs)

local Office = {}

local FLOOR_C = Color3.fromRGB(225, 220, 210)
local WALL_C = Color3.fromRGB(245, 243, 238)
local WOOD = Color3.fromRGB(150, 110, 75)
local GLASS = Color3.fromRGB(170, 210, 240)

local function part(parent, name, cf, size, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.Parent = parent
	return p
end

local function label(parent, cf, size, text, textColor, bg)
	local p = part(parent, "Sign", cf, Vector3.new(size.X, size.Y, 0.2), bg or Color3.fromRGB(40, 45, 60))
	local g = Instance.new("SurfaceGui")
	g.Face = Enum.NormalId.Front
	g.CanvasSize = Vector2.new(size.X * 50, size.Y * 50)
	g.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = Enum.Font.FredokaOne
	t.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
	t.Text = text
	t.Parent = g
	return p, t
end

local function prompt(parent: BasePart, action: string, object: string, hold: number?)
	local pp = Instance.new("ProximityPrompt")
	pp.ActionText = action
	pp.ObjectText = object
	pp.HoldDuration = hold or 0
	pp.MaxActivationDistance = 9
	pp.RequiresLineOfSight = false
	pp.Parent = parent
	return pp
end

local function desk(parent, cf)
	part(parent, "DeskTop", cf * CFrame.new(0, 2.6, 0), Vector3.new(6, 0.3, 3), WOOD, Enum.Material.Wood)
	for _, sx in { -1, 1 } do
		part(parent, "DeskLeg", cf * CFrame.new(sx * 2.7, 1.3, 0), Vector3.new(0.4, 2.6, 2.6), Color3.fromRGB(90, 90, 100))
	end
	-- モニターと書類
	part(parent, "Monitor", cf * CFrame.new(-1, 3.6, 0.8), Vector3.new(2.2, 1.5, 0.15), Color3.fromRGB(30, 30, 40))
	part(parent, "Screen", cf * CFrame.new(-1, 3.6, 0.7), Vector3.new(2.0, 1.3, 0.05), Color3.fromRGB(120, 200, 255), Enum.Material.Neon)
	part(parent, "Paper", cf * CFrame.new(1.6, 2.8, -0.3) * CFrame.Angles(0, 0.2, 0), Vector3.new(1.2, 0.1, 1.6), Color3.fromRGB(255, 255, 255))
	part(parent, "Chair", cf * CFrame.new(0, 1.4, -2.3), Vector3.new(1.6, 0.4, 1.6), Color3.fromRGB(50, 55, 70))
	part(parent, "ChairBack", cf * CFrame.new(0, 2.3, -3.0), Vector3.new(1.6, 1.8, 0.3), Color3.fromRGB(50, 55, 70))
end

local function plant(parent, cf)
	part(parent, "Pot", cf * CFrame.new(0, 0.6, 0), Vector3.new(1.4, 1.2, 1.4), Color3.fromRGB(200, 120, 80))
	for i = 1, 5 do
		local a = i / 5 * math.pi * 2
		local leaf = part(parent, "Leaf", cf * CFrame.new(math.cos(a) * 0.5, 2.0 + (i % 2) * 0.5, math.sin(a) * 0.5) * CFrame.Angles(0, -a, 0.6), Vector3.new(0.3, 1.8, 0.9), Color3.fromRGB(70, 150, 80))
		local m = Instance.new("SpecialMesh")
		m.MeshType = Enum.MeshType.Sphere
		m.Parent = leaf
	end
end

function Office.build(): { Folder: Folder, Elevator: BasePart, Shop: BasePart, Boss: BasePart, Daily: BasePart, Locker: BasePart, RankText: TextLabel, RankText2: TextLabel, SpawnCFrame: CFrame }
	local folder = Instance.new("Folder")
	folder.Name = "Office"
	folder.Parent = workspace

	local W, D = 80, 56 -- 横・奥行き
	-- 床・天井
	part(folder, "Floor", CFrame.new(0, 0.5, 0), Vector3.new(W, 1, D), FLOOR_C, Enum.Material.Marble)
	local carpet = part(folder, "Carpet", CFrame.new(0, 1.02, 4), Vector3.new(W - 14, 0.05, D - 20), Color3.fromRGB(70, 90, 130), Enum.Material.Fabric)
	part(folder, "Ceiling", CFrame.new(0, 16, 0), Vector3.new(W, 1, D), Color3.fromRGB(250, 250, 250))
	for i = -2, 2 do
		local l = part(folder, "Lamp", CFrame.new(i * 15, 15.4, 0), Vector3.new(6, 0.2, 2), Color3.fromRGB(255, 255, 240), Enum.Material.Neon)
		local pl = Instance.new("PointLight")
		pl.Range = 30
		pl.Brightness = 0.8
		pl.Parent = l
	end
	-- 壁（奥は大きな窓）
	part(folder, "WallL", CFrame.new(-W / 2, 8, 0), Vector3.new(1, 16, D), WALL_C)
	part(folder, "WallR", CFrame.new(W / 2, 8, 0), Vector3.new(1, 16, D), WALL_C)
	part(folder, "WallF", CFrame.new(0, 8, -D / 2), Vector3.new(W, 16, 1), WALL_C)
	-- 奥の窓（街が見える）
	part(folder, "WallBLow", CFrame.new(0, 2, D / 2), Vector3.new(W, 4, 1), WALL_C)
	part(folder, "WallBHigh", CFrame.new(0, 14.5, D / 2), Vector3.new(W, 3, 1), WALL_C)
	local win = part(folder, "Window", CFrame.new(0, 8.5, D / 2), Vector3.new(W, 9, 0.4), GLASS, Enum.Material.Glass)
	win.Transparency = 0.5
	for i = -3, 3 do
		part(folder, "WindowBar", CFrame.new(i * 11, 8.5, D / 2), Vector3.new(0.5, 9, 0.6), Color3.fromRGB(80, 80, 90))
	end
	-- 窓の外の街（遠くのビル）
	local rng = Random.new(42)
	for i = 1, 26 do
		local x = -60 + i * 4.6
		local h = rng:NextInteger(10, 40)
		local b = part(folder, "CityBuilding", CFrame.new(x, h / 2 - 6, D / 2 + 30 + rng:NextInteger(0, 40)), Vector3.new(rng:NextInteger(4, 8), h, 6), Color3.fromRGB(60 + rng:NextInteger(0, 40), 70 + rng:NextInteger(0, 40), 100 + rng:NextInteger(0, 40)))
		for wy = 1, math.floor(h / 4) do
			local w2 = part(folder, "CityWindow", b.CFrame * CFrame.new(0, -h / 2 + wy * 4 - 2, -b.Size.Z / 2 - 0.05), Vector3.new(b.Size.X * 0.6, 1.4, 0.1), Color3.fromRGB(255, 240, 180), Enum.Material.Neon)
		end
	end
	-- マネータワー（窓の外、ひときわ高い）
	part(folder, "Tower", CFrame.new(10, 40, D / 2 + 90), Vector3.new(18, 110, 18), Color3.fromRGB(40, 45, 70), Enum.Material.Metal)
	part(folder, "TowerTop", CFrame.new(10, 97, D / 2 + 90), Vector3.new(10, 6, 10), Color3.fromRGB(255, 205, 60), Enum.Material.Neon)
	for fy = 1, 24 do
		part(folder, "TowerWindow", CFrame.new(10, fy * 4 - 10, D / 2 + 80.9), Vector3.new(12, 1.5, 0.1), Color3.fromRGB(255, 230, 150), Enum.Material.Neon)
	end

	-- ===== 机の列（社員の席）=====
	for row = 0, 1 do
		for col = -2, 2 do
			desk(folder, CFrame.new(col * 11, 1, -6 + row * 12))
		end
	end
	plant(folder, CFrame.new(-W / 2 + 4, 1, -D / 2 + 4))
	plant(folder, CFrame.new(W / 2 - 4, 1, -D / 2 + 4))
	plant(folder, CFrame.new(-W / 2 + 4, 1, 18))

	-- ===== エレベーター（塔へ）: 右の壁 =====
	local elevX = W / 2 - 0.8
	part(folder, "ElevFrame", CFrame.new(elevX, 6, 14), Vector3.new(0.8, 12, 9), Color3.fromRGB(200, 170, 80), Enum.Material.Metal)
	local door = part(folder, "ElevDoor", CFrame.new(elevX - 0.5, 5.5, 14), Vector3.new(0.4, 10, 7), Color3.fromRGB(120, 125, 140), Enum.Material.Metal)
	part(folder, "ElevSplit", CFrame.new(elevX - 0.75, 5.5, 14), Vector3.new(0.1, 10, 0.2), Color3.fromRGB(40, 40, 50))
	label(folder, CFrame.new(elevX - 0.6, 12.5, 14) * CFrame.Angles(0, math.pi / 2, 0), Vector2.new(9, 1.8), "▲ マネータワー  MONEY TOWER", Color3.fromRGB(255, 220, 120))
	local elevPad = part(folder, "ElevPad", CFrame.new(elevX - 4, 1.06, 14), Vector3.new(6, 0.1, 7), Color3.fromRGB(255, 205, 60))
	prompt(door, "塔へ行く", "エレベーター")

	-- ===== 本日の案件（受付デスク）=====
	local dailyDesk = part(folder, "DailyDesk", CFrame.new(elevX - 8, 2, 26), Vector3.new(6, 3, 2.5), Color3.fromRGB(60, 70, 100))
	label(folder, CFrame.new(elevX - 8, 5.5, 26), Vector2.new(6, 1.4), "本日の案件  DAILY", Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 80, 80))
	prompt(dailyDesk, "挑戦する", "本日の案件（全員同じ塔）")

	-- ===== 売店（ミサキ）: 左の壁 =====
	local shopX = -W / 2 + 6
	part(folder, "ShopCounter", CFrame.new(shopX, 2, 12), Vector3.new(3, 3, 12), WOOD, Enum.Material.Wood)
	part(folder, "ShopTop", CFrame.new(shopX, 3.6, 12), Vector3.new(3.4, 0.3, 12.4), Color3.fromRGB(240, 230, 210))
	-- 棚
	for i = 0, 2 do
		part(folder, "ShopShelf", CFrame.new(-W / 2 + 1.2, 4 + i * 2.5, 12), Vector3.new(1.4, 0.2, 11), WOOD, Enum.Material.Wood)
		for j = -2, 2 do
			local c = { Color3.fromRGB(255, 220, 110), Color3.fromRGB(120, 80, 50), Color3.fromRGB(230, 90, 90), Color3.fromRGB(80, 160, 230), Color3.fromRGB(255, 255, 255) }
			part(folder, "ShopGoods", CFrame.new(-W / 2 + 1.2, 4.6 + i * 2.5, 12 + j * 2.2), Vector3.new(0.8, 1.0, 0.8), c[j + 3])
		end
	end
	label(folder, CFrame.new(shopX + 0.5, 11.5, 12) * CFrame.Angles(0, -math.pi / 2, 0), Vector2.new(10, 1.8), "売店  SHOP", Color3.fromRGB(255, 255, 255), Color3.fromRGB(230, 120, 60))
	local misaki = Designs.build("misaki", CFrame.new(shopX - 2.5, 1, 12) * CFrame.Angles(0, -math.pi / 2, 0), folder)
	local shopPad = part(folder, "ShopPad", CFrame.new(shopX + 4, 1.06, 12), Vector3.new(5, 0.1, 8), Color3.fromRGB(255, 200, 120))
	prompt(misaki.PrimaryPart, "話す / 買う", "先輩 ミサキ")

	-- ===== ロッカー =====
	local locker = part(folder, "Locker", CFrame.new(shopX - 2, 4, -16), Vector3.new(2, 8, 8), Color3.fromRGB(110, 120, 140), Enum.Material.Metal)
	for i = -1, 1 do
		part(folder, "LockerDoor", CFrame.new(shopX - 0.95, 4, -16 + i * 2.6), Vector3.new(0.1, 7.5, 2.4), Color3.fromRGB(130, 140, 160), Enum.Material.Metal)
		part(folder, "LockerHandle", CFrame.new(shopX - 0.85, 4, -16 + i * 2.6 + 0.9), Vector3.new(0.1, 0.8, 0.2), Color3.fromRGB(60, 60, 70))
	end
	label(folder, CFrame.new(shopX - 0.9, 9, -16) * CFrame.Angles(0, -math.pi / 2, 0), Vector2.new(8, 1.4), "ロッカー  LOCKER", Color3.fromRGB(255, 255, 255), Color3.fromRGB(70, 90, 130))
	prompt(locker, "開ける", "ロッカー（装備を預ける）")

	-- ===== 部長の部屋（奥の左）=====
	local bx, bz = -24, 20
	part(folder, "BossWall", CFrame.new(bx + 10, 6, bz - 1), Vector3.new(0.5, 12, 14), Color3.fromRGB(200, 205, 215), Enum.Material.Glass).Transparency = 0.4
	part(folder, "BossWall2", CFrame.new(bx, 6, bz - 8), Vector3.new(20, 12, 0.5), Color3.fromRGB(200, 205, 215), Enum.Material.Glass).Transparency = 0.4
	part(folder, "BossDesk", CFrame.new(bx, 2, bz + 3), Vector3.new(9, 3.2, 3.5), Color3.fromRGB(80, 50, 35), Enum.Material.Wood)
	part(folder, "BossChair", CFrame.new(bx, 3, bz + 6), Vector3.new(2.4, 5, 1.0), Color3.fromRGB(40, 30, 30), Enum.Material.Leather)
	label(folder, CFrame.new(bx, 12.5, bz - 7.6), Vector2.new(10, 1.6), "部長室", Color3.fromRGB(255, 255, 255), Color3.fromRGB(60, 50, 80))
	local kanemoto = Designs.build("kanemoto", CFrame.new(bx, 1, bz + 1), folder)
	prompt(kanemoto.PrimaryPart, "話す", "部長 カネモト")
	-- 賞状
	for i = -1, 1 do
		local f = part(folder, "Frame", CFrame.new(bx + i * 4, 9, bz + 10.5), Vector3.new(3, 2.2, 0.2), Color3.fromRGB(200, 170, 80), Enum.Material.Metal)
		part(folder, "FrameInner", CFrame.new(bx + i * 4, 9, bz + 10.3), Vector3.new(2.5, 1.7, 0.1), Color3.fromRGB(255, 250, 240))
	end

	-- ===== ライバル ハヤテ（窓ぎわ）=====
	local hayate = Designs.build("hayate", CFrame.new(20, 1, 24) * CFrame.Angles(0, math.pi * 0.85, 0), folder)
	prompt(hayate.PrimaryPart, "話す", "ハヤテ（他社）")

	-- ===== 社内ランキングの壁（正面の壁）=====
	local _, rankText = label(folder, CFrame.new(-10, 8, -D / 2 + 0.7) * CFrame.Angles(0, math.pi, 0), Vector2.new(24, 10), "社内ランキング\n…", Color3.fromRGB(255, 255, 255), Color3.fromRGB(35, 40, 60))
	local _, rankText2 = label(folder, CFrame.new(18, 8, -D / 2 + 0.7) * CFrame.Angles(0, math.pi, 0), Vector2.new(24, 10), "本日の案件 ランキング\n…", Color3.fromRGB(255, 255, 255), Color3.fromRGB(60, 35, 50))
	label(folder, CFrame.new(4, 14.2, -D / 2 + 0.7) * CFrame.Angles(0, math.pi, 0), Vector2.new(40, 1.8), "ホワイトタワー証券  WHITE TOWER SECURITIES", Color3.fromRGB(255, 220, 120), Color3.fromRGB(25, 30, 45))

	-- ===== 遊び方の看板 =====
	label(folder, CFrame.new(-W / 2 + 0.7, 8, 24) * CFrame.Angles(0, -math.pi / 2, 0), Vector2.new(14, 7),
		"あそびかた\n1. 売店で コーヒーとおにぎりを買う\n2. エレベーターで塔へ\n3. 矢印/WASD で 1 歩ずつ。敵にぶつかると攻撃\n4. 階段で「のぼる」。危なくなったら 帰還の名刺\n5. 倒れても ランクは残る！",
		Color3.fromRGB(255, 255, 255), Color3.fromRGB(50, 90, 70))

	return {
		Folder = folder,
		Elevator = door,
		Shop = misaki.PrimaryPart,
		Boss = kanemoto.PrimaryPart,
		Rival = hayate.PrimaryPart,
		Daily = dailyDesk,
		Locker = locker,
		RankText = rankText,
		RankText2 = rankText2,
		SpawnCFrame = CFrame.new(0, 4, -2),
	}
end

return Office
