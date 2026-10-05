-- ステージをコードで組み立てる。Studioで手で置く物はゼロ。
-- テーマ: だるま神社。参道（石畳）に鳥居が並び、奥の拝殿の前に巨大だるまが座っている。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local StageBuilder = {}

local VERMILION = Color3.fromRGB(215, 60, 35)
local BLACK = Color3.fromRGB(30, 28, 26)
local STONE = Color3.fromRGB(150, 148, 140)
local WOOD = Color3.fromRGB(110, 72, 45)
local GOLD = Color3.fromRGB(225, 175, 55)

local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	local parent = props.Parent
	props.Parent = nil
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end

-- 縦向きの円柱（Roblox の円柱は X 軸方向なので 90 度倒す）
local function pillar(parent: Instance, pos: Vector3, height: number, width: number, color: Color3, material: Enum.Material?): Part
	return part({
		Name = "Pillar",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(height, width, width),
		CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2),
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		Parent = parent,
	})
end

-- 看板の文字（板の手前側の面に書く）
local function sign(p: BasePart, text: string, color: Color3, face: Enum.NormalId?)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Back
	gui.LightInfluence = 0
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 12
	gui.Parent = p
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
end

-- 鳥居。参道をまたぐ。柱は垣根の外なので邪魔にならない
local function torii(parent: Instance, z: number, span: number)
	local folder = Instance.new("Folder")
	folder.Name = "Torii"
	folder.Parent = parent
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
	sign(plaque, "達\n磨", GOLD, Enum.NormalId.Front)
end

-- 石灯籠
local function lantern(parent: Instance, x: number, z: number)
	local folder = Instance.new("Folder")
	folder.Name = "Lantern"
	folder.Parent = parent
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
	local folder = Instance.new("Folder")
	folder.Name = "Sakura"
	folder.Parent = parent
	pillar(folder, Vector3.new(x, 5 * scale, z), 10 * scale, 1.8 * scale, Color3.fromRGB(85, 55, 40), Enum.Material.Wood)
	local pink = Color3.fromRGB(255, 183, 205)
	for _, o in { Vector3.new(0, 11, 0), Vector3.new(3.5, 9.5, 1.5), Vector3.new(-3, 9.8, -1.5), Vector3.new(0.5, 13.5, -1) } do
		part({
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * (o.Y > 12 and 6 or 8) * scale,
			Position = Vector3.new(x, 0, z) + o * scale,
			Color = pink,
			Material = Enum.Material.Grass,
			CanCollide = false,
			Parent = folder,
		})
	end
end

-- 奥の拝殿。だるまの背中側
local function shrine(parent: Instance, z: number)
	local folder = Instance.new("Folder")
	folder.Name = "Shrine"
	folder.Parent = parent
	part({ Name = "Platform", Size = Vector3.new(46, 3, 26), Position = Vector3.new(0, 1.5, z), Color = STONE, Material = Enum.Material.Slate, Parent = folder })
	part({ Name = "Floor", Size = Vector3.new(40, 0.6, 22), Position = Vector3.new(0, 3.3, z), Color = WOOD, Material = Enum.Material.WoodPlanks, Parent = folder })
	for _, x in { -18, -6, 6, 18 } do
		for _, dz in { -9, 9 } do
			pillar(folder, Vector3.new(x, 9.5, z + dz), 12, 1.8, VERMILION)
		end
	end
	part({ Name = "Wall", Size = Vector3.new(36, 11, 1), Position = Vector3.new(0, 9, z - 9), Color = Color3.fromRGB(245, 238, 225), Parent = folder })
	-- 切妻屋根: 2 枚の板を山形に
	local ridgeY, ridgeZ = 22, z
	for _, s in { 1, -1 } do
		part({
			Name = "Roof",
			Size = Vector3.new(52, 1.4, 17),
			CFrame = CFrame.new(0, ridgeY - 8.5 * math.sin(0.45), ridgeZ + s * 8.5 * math.cos(0.45)) * CFrame.Angles(s * 0.45, 0, 0),
			Color = Color3.fromRGB(55, 60, 66),
			Material = Enum.Material.Slate,
			Parent = folder,
		})
	end
	part({ Name = "Ridge", Size = Vector3.new(54, 1.8, 1.8), Position = Vector3.new(0, ridgeY + 0.4, ridgeZ), Color = BLACK, Parent = folder })
	-- しめ縄と紙垂（しで）
	part({ Name = "Shimenawa", Shape = Enum.PartType.Cylinder, Size = Vector3.new(34, 1.4, 1.4), Position = Vector3.new(0, 14.6, z + 9.5), Color = Color3.fromRGB(215, 190, 120), Material = Enum.Material.Fabric, Parent = folder })
	for _, x in { -10, 0, 10 } do
		part({ Name = "Shide", Size = Vector3.new(1, 3, 0.1), Position = Vector3.new(x, 12.6, z + 9.6), Color = Color3.fromRGB(255, 255, 255), Parent = folder })
	end
end

function StageBuilder.build()
	local folder = Instance.new("Folder")
	folder.Name = "Stage"
	folder.Parent = Workspace

	-- だるまの中心。体の高さ（2.3 倍）の半分だけ床から上げる
	local darumaPos = Vector3.new(0, Config.DARUMA_RADIUS * 1.15 + 0.5, Config.DARUMA_Z)
	-- だるまが「こちらを見ている」ときの向き。LookVector がスタート地点を向く。
	local facing = CFrame.lookAt(darumaPos, darumaPos + Vector3.new(0, 0, 1))

	-- 参道（石畳）
	part({
		Name = "Floor",
		Size = Vector3.new(Config.FIELD_WIDTH, 1, Config.FIELD_LENGTH),
		Position = Vector3.new(0, 0, 0),
		Color = Color3.fromRGB(168, 162, 150),
		Material = Enum.Material.Cobblestone,
		Parent = folder,
	})

	-- 左右の半分。振り向いている間、見られている側を赤、安全な側を緑に光らせる薄い板。
	local halfW = Config.FIELD_WIDTH / 2
	local halves = {}
	for _, x in { -halfW / 2, halfW / 2 } do
		local h = part({
			Name = "Half",
			Size = Vector3.new(halfW, 0.2, Config.FIELD_LENGTH),
			Position = Vector3.new(x, 0.6, 0),
			Material = Enum.Material.Neon,
			Transparency = 1,
			CanCollide = false,
			CanQuery = false,
			Parent = folder,
		})
		-- だるまから見て右側なら "right"
		local side = (h.Position - darumaPos):Dot(facing.RightVector) > 0 and "right" or "left"
		h:SetAttribute("Side", side)
		halves[side] = h
	end

	-- 中央線（しめ縄の色）
	part({
		Name = "CenterLine",
		Size = Vector3.new(0.8, 0.3, Config.FIELD_LENGTH),
		Position = Vector3.new(0, 0.65, 0),
		Color = Color3.fromRGB(215, 190, 120),
		Material = Enum.Material.Fabric,
		CanCollide = false,
		Parent = folder,
	})

	-- 見えない壁（落ちないように）と、その外側の赤い垣根
	for _, x in { -halfW - 1, halfW + 1 } do
		part({
			Name = "Wall",
			Size = Vector3.new(2, 12, Config.FIELD_LENGTH),
			Position = Vector3.new(x, 6, 0),
			Transparency = 1,
			Parent = folder,
		})
		local fence = Instance.new("Folder")
		fence.Name = "Fence"
		fence.Parent = folder
		for z = -Config.FIELD_LENGTH / 2, Config.FIELD_LENGTH / 2, 10 do
			part({ Size = Vector3.new(1.2, 4.4, 1.2), Position = Vector3.new(x, 2.2, z), Color = VERMILION, Parent = fence })
		end
		for _, y in { 1.6, 3.6 } do
			part({ Size = Vector3.new(0.6, 0.7, Config.FIELD_LENGTH), Position = Vector3.new(x, y, 0), Color = VERMILION, Parent = fence })
		end
	end

	-- 鳥居 3 基（手前ほど大きく見える）
	for _, z in { 62, 12, -38 } do
		torii(folder, z, Config.FIELD_WIDTH + 8)
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

	-- 拝殿（だるまの背中側）
	shrine(folder, Config.DARUMA_Z - 34)

	-- スタート地点の木の床。灰色のスポーン板は見えなくする
	part({ Name = "StartDeck", Size = Vector3.new(32, 0.4, 16), Position = Vector3.new(0, 0.7, Config.SPAWN_Z), Color = WOOD, Material = Enum.Material.WoodPlanks, Parent = folder })
	local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
	if spawn then
		spawn.Transparency = 1
		for _, d in spawn:GetChildren() do
			if d:IsA("Decal") then
				d:Destroy()
			end
		end
	end

	-- 目入れの台座（だるまの足元、少し手前）。大きな筆が置いてある
	local pedestal = part({
		Name = "Pedestal",
		Size = Vector3.new(10, 1, 6),
		Position = Vector3.new(0, 1, Config.DARUMA_Z + Config.DARUMA_RADIUS + 6),
		Color = Color3.fromRGB(240, 200, 60),
		Material = Enum.Material.Neon,
		Parent = folder,
	})
	part({
		Name = "BrushHandle",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(7, 0.7, 0.7),
		CFrame = CFrame.new(pedestal.Position + Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0.4, 0),
		Color = Color3.fromRGB(120, 80, 40),
		Material = Enum.Material.Wood,
		CanCollide = false,
		Parent = folder,
	})
	part({
		Name = "BrushTip",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1.4, 1.4, 1.4),
		Position = pedestal.Position + Vector3.new(0, 1, 0) + CFrame.Angles(0, 0.4, 0).RightVector * 3.6,
		Color = BLACK,
		CanCollide = false,
		Parent = folder,
	})

	-- モード選びの台（スタート地点の左右）
	local modeStands = {}
	for mode, x in { normal = -13, hard = 13 } do
		local stand = part({
			Name = "ModeStand_" .. mode,
			Size = Vector3.new(4, 3, 4),
			Position = Vector3.new(x, 2, Config.SPAWN_Z - 2),
			Color = mode == "hard" and Color3.fromRGB(60, 20, 25) or STONE,
			Material = Enum.Material.Slate,
			Parent = folder,
		})
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.fromOffset(160, 60)
		bb.StudsOffset = Vector3.new(0, 4, 0)
		bb.MaxDistance = 60
		bb.Parent = stand
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 0.3
		label.BackgroundColor3 = mode == "hard" and Color3.fromRGB(150, 20, 30) or Color3.fromRGB(40, 110, 60)
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.FredokaOne
		label.Text = mode == "hard" and "むずかしい\nHARD" or "ふつう\nNORMAL"
		label.Parent = bb
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = label
		modeStands[mode] = stand
	end

	-- 灯籠の明かり（夜のモードで目立つ）
	local lights = {}
	for _, d in folder:GetDescendants() do
		if d:IsA("PointLight") then
			table.insert(lights, d)
		end
	end

	return {
		Folder = folder,
		DarumaPosition = darumaPos,
		Facing = facing,
		Halves = halves,
		Pedestal = pedestal,
		ModeStands = modeStands,
		Lights = lights,
		SpawnCFrame = CFrame.new(0, 4, Config.SPAWN_Z),
	}
end

return StageBuilder
