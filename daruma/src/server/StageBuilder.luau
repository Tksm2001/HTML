-- ステージをコードで組み立てる。Studioで手で置く物はゼロ。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local StageBuilder = {}

local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do
		(p :: any)[k] = v
	end
	return p
end

function StageBuilder.build()
	local folder = Instance.new("Folder")
	folder.Name = "Stage"
	folder.Parent = Workspace

	local darumaPos = Vector3.new(0, Config.DARUMA_RADIUS, Config.DARUMA_Z)
	-- だるまが「こちらを見ている」ときの向き。LookVector がスタート地点を向く。
	local facing = CFrame.lookAt(darumaPos, darumaPos + Vector3.new(0, 0, 1))

	-- 床（全体）
	part({
		Name = "Floor",
		Size = Vector3.new(Config.FIELD_WIDTH, 1, Config.FIELD_LENGTH),
		Position = Vector3.new(0, 0, 0),
		Color = Color3.fromRGB(230, 220, 200),
		Material = Enum.Material.SmoothPlastic,
		Parent = folder,
	})

	-- 左右の半分。見られている側を赤く光らせるための薄い板。
	local halfW = Config.FIELD_WIDTH / 2
	local halves = {}
	for _, x in { -halfW / 2, halfW / 2 } do
		local h = part({
			Name = "Half",
			Size = Vector3.new(halfW, 0.2, Config.FIELD_LENGTH),
			Position = Vector3.new(x, 0.6, 0),
			Color = Color3.fromRGB(230, 220, 200),
			Material = Enum.Material.Neon,
			Transparency = 1,
			CanCollide = false,
			Parent = folder,
		})
		-- だるまから見て右側なら "right"
		local side = (h.Position - darumaPos):Dot(facing.RightVector) > 0 and "right" or "left"
		h:SetAttribute("Side", side)
		halves[side] = h
	end

	-- 中央線
	part({
		Name = "CenterLine",
		Size = Vector3.new(0.5, 0.3, Config.FIELD_LENGTH),
		Position = Vector3.new(0, 0.65, 0),
		Color = Color3.fromRGB(60, 60, 60),
		CanCollide = false,
		Parent = folder,
	})

	-- 壁（落ちないように）
	for _, x in { -halfW - 1, halfW + 1 } do
		part({
			Name = "Wall",
			Size = Vector3.new(2, 10, Config.FIELD_LENGTH),
			Position = Vector3.new(x, 5, 0),
			Transparency = 0.6,
			Color = Color3.fromRGB(200, 200, 200),
			Parent = folder,
		})
	end

	-- 目入れの台座（だるまの足元、少し手前）
	local pedestal = part({
		Name = "Pedestal",
		Size = Vector3.new(10, 1, 6),
		Position = Vector3.new(0, 1, Config.DARUMA_Z + Config.DARUMA_RADIUS + 6),
		Color = Color3.fromRGB(240, 200, 60),
		Material = Enum.Material.Neon,
		Parent = folder,
	})

	return {
		Folder = folder,
		DarumaPosition = darumaPos,
		Facing = facing,
		Halves = halves,
		Pedestal = pedestal,
		SpawnCFrame = CFrame.new(0, 4, Config.SPAWN_Z),
	}
end

return StageBuilder
