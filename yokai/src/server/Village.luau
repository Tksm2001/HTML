-- 村をコードで組み立てる。Studio で手で置く物はゼロ。
-- 真ん中が広場（百鬼夜行が回る）。そのまわりに 8 つの神社（各プレイヤーの拠点）。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Parts = require(script.Parent.Parts)
local part, pillar, ball, sign = Parts.part, Parts.pillar, Parts.ball, Parts.sign
local VERMILION, BLACK, STONE, WOOD, GOLD = Parts.VERMILION, Parts.BLACK, Parts.STONE, Parts.WOOD, Parts.GOLD

local Village = {}

-- 台座の位置（神社の敷地の中。-Z が広場側 = 正面）。順番に使う
local SLOT_OFFSETS = {
	Vector3.new(-3, 0, 1), Vector3.new(3, 0, 1), Vector3.new(-9, 0, 1), Vector3.new(9, 0, 1),
	Vector3.new(-3, 0, 7), Vector3.new(3, 0, 7), Vector3.new(-9, 0, 7), Vector3.new(9, 0, 7),
}

local function lantern(parent: Instance, cf: CFrame)
	local f = Parts.folder(parent, "Lantern")
	pillar(f, cf.Position + Vector3.new(0, 2.5, 0), 5, 0.5, WOOD, Enum.Material.Wood)
	local l = part({ Size = Vector3.new(1.4, 1.8, 1.4), CFrame = cf * CFrame.new(0, 5.6, 0), Color = Color3.fromRGB(255, 215, 150), Material = Enum.Material.Neon, Transparency = 0.1, Parent = f })
	local pl = Instance.new("PointLight")
	pl.Color = Color3.fromRGB(255, 200, 130)
	pl.Range = 16
	pl.Brightness = 1.5
	pl.Parent = l
	part({ Size = Vector3.new(1.9, 0.4, 1.9), CFrame = cf * CFrame.new(0, 6.7, 0), Color = BLACK, Parent = f })
end

local function tree(parent: Instance, pos: Vector3, scale: number, leaf: Color3)
	local f = Parts.folder(parent, "Tree")
	pillar(f, pos + Vector3.new(0, 4 * scale, 0), 8 * scale, 1.4 * scale, Color3.fromRGB(95, 65, 45), Enum.Material.Wood)
	for _, o in { Vector3.new(0, 9, 0), Vector3.new(2.8, 7.8, 1.2), Vector3.new(-2.5, 8, -1.2), Vector3.new(0.4, 11.5, -0.6) } do
		ball(f, pos + o * scale, (o.Y > 10 and 5 or 6.5) * scale, leaf, Enum.Material.Grass)
	end
end

-- 台座 1 つ。slot = 何番目か
function Village.buildPedestal(plot, slot: number): BasePart
	local off = SLOT_OFFSETS[slot]
	local cf = plot.CFrame * CFrame.new(off)
	local f = Parts.folder(plot.Folder, "Pedestal" .. slot)
	local base = part({
		Name = "Pedestal",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.6, 3.6, 3.6),
		CFrame = cf * CFrame.new(0, 0.3, 0) * CFrame.Angles(0, 0, math.pi / 2),
		Color = STONE,
		Material = Enum.Material.Slate,
		Parent = f,
	})
	part({ Name = "Cushion", Size = Vector3.new(2.4, 0.3, 2.4), CFrame = cf * CFrame.new(0, 0.75, 0), Color = Color3.fromRGB(200, 40, 50), Material = Enum.Material.Fabric, Parent = f })
	-- 妖怪が座る位置（高さは台座の上）。格の色で光る輪
	local ring = part({ Name = "Ring", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.1, 4.2, 4.2), CFrame = cf * CFrame.new(0, 0.62, 0) * CFrame.Angles(0, 0, math.pi / 2), Color = Color3.fromRGB(255, 255, 255), Material = Enum.Material.Neon, Transparency = 1, CanCollide = false, Parent = f })
	base:SetAttribute("Plot", plot.Index)
	base:SetAttribute("Slot", slot)
	plot.Pedestals[slot] = { Part = base, Ring = ring, SeatCFrame = cf * CFrame.new(0, 0.9, 0), Yokai = nil }
	return base
end

local function buildPlot(root: Folder, index: number)
	local a = (index - 1) / Config.PLOTS * math.pi * 2
	local center = Vector3.new(math.sin(a) * Config.PLOT_RADIUS, 0, math.cos(a) * Config.PLOT_RADIUS)
	local cf = CFrame.lookAt(center, Vector3.new(0, 0, 0)) -- -Z（正面）が広場を向く
	local half = Config.PLOT_SIZE / 2
	local f = Parts.folder(root, "Plot" .. index)

	-- 敷地（石畳）と縁石
	part({ Name = "Ground", Size = Vector3.new(Config.PLOT_SIZE, 1, Config.PLOT_SIZE), CFrame = cf * CFrame.new(0, -0.5, 0), Color = Color3.fromRGB(190, 182, 165), Material = Enum.Material.Cobblestone, Parent = f })
	part({ Name = "Step", Size = Vector3.new(10, 0.5, 3), CFrame = cf * CFrame.new(0, -0.25, -half - 1.5), Color = STONE, Material = Enum.Material.Slate, Parent = f })

	-- 高い塀（横と後ろ）。正面だけ鳥居の入口が開いている
	local h = 8
	for _, side in { -1, 1 } do
		part({ Name = "Fence", Size = Vector3.new(1, h, Config.PLOT_SIZE), CFrame = cf * CFrame.new(side * half, h / 2, 0), Color = VERMILION, Parent = f })
		part({ Name = "FenceTop", Size = Vector3.new(1.6, 0.6, Config.PLOT_SIZE + 1), CFrame = cf * CFrame.new(side * half, h + 0.3, 0), Color = BLACK, Parent = f })
		-- 正面の塀（鳥居の左右）
		part({ Name = "Fence", Size = Vector3.new(half - 5, h, 1), CFrame = cf * CFrame.new(side * (half - (half - 5) / 2), h / 2, -half), Color = VERMILION, Parent = f })
		part({ Name = "FenceTop", Size = Vector3.new(half - 5, 0.6, 1.6), CFrame = cf * CFrame.new(side * (half - (half - 5) / 2), h + 0.3, -half), Color = BLACK, Parent = f })
	end
	part({ Name = "Fence", Size = Vector3.new(Config.PLOT_SIZE, h, 1), CFrame = cf * CFrame.new(0, h / 2, half), Color = VERMILION, Parent = f })
	part({ Name = "FenceTop", Size = Vector3.new(Config.PLOT_SIZE + 1, 0.6, 1.6), CFrame = cf * CFrame.new(0, h + 0.3, half), Color = BLACK, Parent = f })

	-- 鳥居（入口）
	local th = 11
	for _, side in { -1, 1 } do
		pillar(f, (cf * CFrame.new(side * 5, th / 2, -half)).Position, th, 1.4, VERMILION)
	end
	part({ Name = "Nuki", Size = Vector3.new(12, 0.9, 0.8), CFrame = cf * CFrame.new(0, th - 2.6, -half), Color = VERMILION, Parent = f })
	part({ Name = "Kasagi", Size = Vector3.new(14, 1.0, 1.4), CFrame = cf * CFrame.new(0, th, -half), Color = VERMILION, Parent = f })
	part({ Name = "KasagiTop", Size = Vector3.new(15, 0.7, 1.8), CFrame = cf * CFrame.new(0, th + 0.8, -half), Color = BLACK, Parent = f })
	-- 結界（閉めると見える・通れない板。普段は透明で通れる）
	local barrier = part({ Name = "Barrier", Size = Vector3.new(10, th - 3, 0.6), CFrame = cf * CFrame.new(0, (th - 3) / 2, -half), Color = Color3.fromRGB(120, 200, 255), Material = Enum.Material.ForceField, Transparency = 1, CanCollide = false, Parent = f })

	-- 奥の小さな社（名前の札つき）
	local sh = Parts.folder(f, "Shrine")
	part({ Size = Vector3.new(12, 1.5, 7), CFrame = cf * CFrame.new(0, 0.75, 11), Color = STONE, Material = Enum.Material.Slate, Parent = sh })
	part({ Size = Vector3.new(9, 5, 5), CFrame = cf * CFrame.new(0, 4, 11.5), Color = Color3.fromRGB(245, 235, 215), Parent = sh })
	for _, side in { -1, 1 } do
		pillar(sh, (cf * CFrame.new(side * 4.6, 4.2, 8.8)).Position, 5.4, 0.8, VERMILION)
	end
	for _, s in { 1, -1 } do
		part({ Size = Vector3.new(13, 0.8, 4.2), CFrame = cf * CFrame.new(0, 7.6 - 2 * math.sin(0.5), 11.5 + s * 2 * math.cos(0.5)) * CFrame.Angles(s * 0.5, 0, 0), Color = Color3.fromRGB(55, 60, 66), Material = Enum.Material.Slate, Parent = sh })
	end
	part({ Size = Vector3.new(13.5, 0.9, 0.9), CFrame = cf * CFrame.new(0, 8.0, 11.5), Color = BLACK, Parent = sh })
	local plaque = part({ Name = "NamePlate", Size = Vector3.new(7, 1.6, 0.3), CFrame = cf * CFrame.new(0, 5.6, 8.6), Color = Color3.fromRGB(70, 45, 30), Material = Enum.Material.Wood, Parent = sh })
	sign(plaque, "", GOLD, Enum.NormalId.Front)

	-- 灯籠と木
	for _, side in { -1, 1 } do
		lantern(f, cf * CFrame.new(side * 8, 0, -half + 3))
		tree(f, (cf * CFrame.new(side * (half + 6), 0, 6)).Position, 1.1, Color3.fromRGB(70, 140, 80))
	end

	local plot = {
		Index = index,
		Folder = f,
		CFrame = cf,
		Half = half,
		Barrier = barrier,
		NamePlate = plaque,
		Pedestals = {},
		PedestalCount = 0,
		Owner = nil,
		LockedUntil = 0,
		LockReadyAt = 0,
	}
	for s = 1, Config.PEDESTALS_START do
		Village.buildPedestal(plot, s)
	end
	plot.PedestalCount = Config.PEDESTALS_START
	return plot
end

-- その座標が敷地の中か
function Village.isInside(plot, pos: Vector3): boolean
	local l = plot.CFrame:PointToObjectSpace(pos)
	return math.abs(l.X) < plot.Half and math.abs(l.Z) < plot.Half and l.Y > -2 and l.Y < 20
end

function Village.build()
	local root = Instance.new("Folder")
	root.Name = "Village"
	root.Parent = Workspace

	-- 広場（丸い石畳）と、行列の道（輪）
	part({ Name = "Plaza", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1, 90, 90), CFrame = CFrame.new(0, -0.5, 0) * CFrame.Angles(0, 0, math.pi / 2), Color = Color3.fromRGB(205, 195, 175), Material = Enum.Material.Cobblestone, Parent = root })
	part({ Name = "ParadeRing", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.12, (Config.PARADE_RADIUS + 3.5) * 2, (Config.PARADE_RADIUS + 3.5) * 2), CFrame = CFrame.new(0, 0.06, 0) * CFrame.Angles(0, 0, math.pi / 2), Color = Color3.fromRGB(175, 160, 135), Material = Enum.Material.Cobblestone, CanCollide = false, Parent = root })
	part({ Name = "ParadeRingInner", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.14, (Config.PARADE_RADIUS - 3.5) * 2, (Config.PARADE_RADIUS - 3.5) * 2), CFrame = CFrame.new(0, 0.07, 0) * CFrame.Angles(0, 0, math.pi / 2), Color = Color3.fromRGB(205, 195, 175), Material = Enum.Material.Cobblestone, CanCollide = false, Parent = root })
	-- 真ん中の大きな御神木と提灯
	tree(root, Vector3.new(0, 0, 0), 2.2, Color3.fromRGB(255, 183, 205))
	for i = 0, 11 do
		local a = i / 12 * math.pi * 2
		lantern(root, CFrame.new(math.sin(a) * (Config.PARADE_RADIUS + 6), 0, math.cos(a) * (Config.PARADE_RADIUS + 6)))
	end
	-- 広場の外の木
	for i = 0, 15 do
		local a = (i + 0.5) / 16 * math.pi * 2
		if i % 2 == 0 then
			tree(root, Vector3.new(math.sin(a) * 95, 0, math.cos(a) * 95), 1.3, Color3.fromRGB(70, 140, 80))
		end
	end

	local plots = {}
	for i = 1, Config.PLOTS do
		plots[i] = buildPlot(root, i)
	end
	return { Folder = root, Plots = plots }
end

return Village
