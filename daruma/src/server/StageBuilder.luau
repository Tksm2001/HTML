-- ステージをコードで組み立てる。Studioで手で置く物はゼロ。
-- build: 全ステージ共通の土台（床、左右の半分、中央線、見えない壁、スタート地点、目入れの台座、モード選びの台）
-- setTheme: ステージごとの景色と障害物（src/server/Stages/ の各ファイル）を付け替える
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Parts = require(script.Parent.Parts)
local part = Parts.part

local Themes = {}
for _, name in Config.STAGE_ORDER do
	Themes[name] = require(script.Parent.Stages[name])
end

local StageBuilder = {}
StageBuilder.Themes = Themes

function StageBuilder.build()
	local folder = Instance.new("Folder")
	folder.Name = "Stage"
	folder.Parent = Workspace

	-- だるまの中心。体の高さ（2.3 倍）の半分だけ床から上げる
	local darumaPos = Vector3.new(0, Config.DARUMA_RADIUS * 1.15 + 0.5, Config.DARUMA_Z)
	-- だるまが「こちらを見ている」ときの向き。LookVector がスタート地点を向く。
	local facing = CFrame.lookAt(darumaPos, darumaPos + Vector3.new(0, 0, 1))

	-- 道の床。色と素材はステージごとに変える
	local floor = part({
		Name = "Floor",
		Size = Vector3.new(Config.FIELD_WIDTH, 1, Config.FIELD_LENGTH),
		Position = Vector3.new(0, 0, 0),
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

	-- 中央線
	local centerLine = part({
		Name = "CenterLine",
		Size = Vector3.new(0.8, 0.3, Config.FIELD_LENGTH),
		Position = Vector3.new(0, 0.65, 0),
		CanCollide = false,
		Parent = folder,
	})

	-- 見えない壁（落ちないように）。見た目の柵はステージごとに付ける
	for _, x in { -halfW - 1, halfW + 1 } do
		part({
			Name = "Wall",
			Size = Vector3.new(2, 12, Config.FIELD_LENGTH),
			Position = Vector3.new(x, 6, 0),
			Transparency = 1,
			Parent = folder,
		})
	end

	-- スタート地点の木の床。灰色のスポーン板は見えなくする
	part({ Name = "StartDeck", Size = Vector3.new(32, 0.4, 16), Position = Vector3.new(0, 0.7, Config.SPAWN_Z), Color = Parts.WOOD, Material = Enum.Material.WoodPlanks, Parent = folder })
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
		Color = Parts.BLACK,
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
			Color = mode == "hard" and Color3.fromRGB(60, 20, 25) or Parts.STONE,
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

	return {
		Folder = folder,
		Floor = floor,
		CenterLine = centerLine,
		DarumaPosition = darumaPos,
		Facing = facing,
		Halves = halves,
		Pedestal = pedestal,
		ModeStands = modeStands,
		SpawnCFrame = CFrame.new(0, 4, Config.SPAWN_Z),
		-- 以下は setTheme で入る
		ThemeName = nil,
		Theme = nil,
		Lights = {},
		Signals = {},
	}
end

-- ステージの景色と障害物を付け替える。hard = むずかしいモードの障害物も置く
function StageBuilder.setTheme(stage, name: string, hard: boolean)
	if stage.ThemeFolder then
		stage.ThemeFolder:Destroy()
	end
	local theme = Themes[name]
	local folder = Parts.folder(stage.Folder, "Theme_" .. name)
	local ctx = {
		folder = folder,
		halfW = Config.FIELD_WIDTH / 2,
		length = Config.FIELD_LENGTH,
		darumaZ = Config.DARUMA_Z,
		spawnZ = Config.SPAWN_Z,
		signals = {},
	}
	theme.decorate(ctx)
	local layout = Config.OBSTACLES[name]
	for _, o in layout.normal do
		theme.obstacle(ctx, o)
	end
	if hard then
		for _, o in layout.hard do
			theme.obstacle(ctx, o)
		end
	end

	stage.Floor.Color = theme.floor.color
	stage.Floor.Material = theme.floor.material
	stage.CenterLine.Color = theme.centerLine.color
	stage.CenterLine.Material = theme.centerLine.material

	local lights = {}
	for _, d in folder:GetDescendants() do
		if d:IsA("PointLight") then
			table.insert(lights, d)
		end
	end
	stage.ThemeFolder = folder
	stage.ThemeName = name
	stage.Theme = theme
	stage.Lights = lights
	stage.Signals = ctx.signals
end

return StageBuilder
