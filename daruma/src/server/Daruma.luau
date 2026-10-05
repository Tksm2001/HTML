-- 巨大な片目だるま。体、顔、目、振り向き、視界判定。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)

local Daruma = {}
Daruma.__index = Daruma

local RED = Color3.fromRGB(200, 25, 25)
local GOLD = Color3.fromRGB(225, 175, 55)
local WHITE = Color3.fromRGB(250, 245, 235)
local BLACK = Color3.fromRGB(20, 20, 20)

-- 楕円体（球を引き伸ばした形）。だるまの部品は全部これで作る。
local function ellipsoid(name: string, size: Vector3, color: Color3, parent: Instance): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Anchored = true
	p.CanCollide = false
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	p.Parent = parent
	return p
end

function Daruma.new(stage)
	local self = setmetatable({}, Daruma)
	self.stage = stage
	self.facing = stage.Facing                       -- こちらを見ている向き
	self.away = stage.Facing * CFrame.Angles(0, math.pi, 0) -- 背を向けた向き
	self.isLooking = false
	self.eyeSide = "left"                            -- 入っている目。"left" / "right"（だるまから見て）
	self.secondEyePainted = false

	local model = Instance.new("Model")
	model.Name = "Daruma"
	model.Parent = stage.Folder

	-- 部品は「こちらを見ている向き」基準で置く。オブジェクト空間では -Z が正面、+X が「だるまの右」
	local r = Config.DARUMA_RADIUS
	local function place(p: BasePart, x: number, y: number, z: number, rot: CFrame?)
		p.CFrame = self.facing * CFrame.new(x * r, y * r, z * r) * (rot or CFrame.identity)
	end

	-- 体: 少し縦長の卵形
	local body = ellipsoid("Body", Vector3.new(2 * r, 2.3 * r, 1.9 * r), RED, model)
	body.CanCollide = true
	place(body, 0, 0, 0)
	model.PrimaryPart = body

	-- 顔: 金の縁取りの上に白い顔
	place(ellipsoid("FaceRim", Vector3.new(1.42 * r, 1.27 * r, 0.45 * r), GOLD, model), 0, 0.3, -0.76)
	place(ellipsoid("Face", Vector3.new(1.3 * r, 1.15 * r, 0.5 * r), WHITE, model), 0, 0.3, -0.78)

	-- 目: 白目と黒目。入っていない目は白いまま（本物のだるまと同じ）
	self.eyes = {}
	self.pupils = {}
	for _, side in { "left", "right" } do
		local sign = side == "right" and 1 or -1
		local white = ellipsoid("Eye_" .. side, Vector3.new(0.4 * r, 0.4 * r, 0.12 * r), WHITE, model)
		place(white, sign * 0.3, 0.45, -0.97)
		local pupil = ellipsoid("Pupil_" .. side, Vector3.new(0.26 * r, 0.26 * r, 0.1 * r), BLACK, model)
		place(pupil, sign * 0.3, 0.45, -1.0)
		self.eyes[side] = white
		self.pupils[side] = pupil

		-- 眉（鶴）: 外側に向かって跳ね上がる
		local brow = ellipsoid("Brow_" .. side, Vector3.new(0.44 * r, 0.1 * r, 0.1 * r), BLACK, model)
		place(brow, sign * 0.3, 0.72, -0.92, CFrame.Angles(0, 0, sign * 0.3))
		-- ひげ（亀）: 外側に向かって垂れる
		local mustache = ellipsoid("Mustache_" .. side, Vector3.new(0.34 * r, 0.08 * r, 0.08 * r), BLACK, model)
		place(mustache, sign * 0.17, 0.12, -1.0, CFrame.Angles(0, 0, -sign * 0.35))
	end
	place(ellipsoid("Beard", Vector3.new(0.45 * r, 0.14 * r, 0.1 * r), Color3.fromRGB(45, 45, 45), model), 0, -0.12, -0.95)

	-- お腹の「福」
	local belly = Instance.new("Part")
	belly.Name = "Belly"
	belly.Size = Vector3.new(0.7 * r, 0.55 * r, 0.1)
	belly.Transparency = 1
	belly.Anchored = true
	belly.CanCollide = false
	belly.CanQuery = false
	belly.Parent = model
	place(belly, 0, -0.55, -0.87, CFrame.Angles(-0.4, 0, 0))
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	-- 1 スタッドあたりの画素を少なくして、文字を大きく描く
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 12
	gui.Parent = belly
	local kanji = Instance.new("TextLabel")
	kanji.Size = UDim2.fromScale(1, 1)
	kanji.BackgroundTransparency = 1
	kanji.Text = "福"
	kanji.TextScaled = true
	kanji.TextColor3 = GOLD
	kanji.Font = Enum.Font.GothamBlack
	kanji.Parent = gui

	-- 各パーツの「見ている向き」基準での相対位置を覚えておく（回転に使う）
	self.offsets = {}
	for _, p in model:GetChildren() do
		if p:IsA("BasePart") then
			self.offsets[p] = self.facing:ToObjectSpace(p.CFrame)
		end
	end

	self.model = model
	self:reset()
	self:_applyPivot(self.away)
	return self
end

function Daruma:_applyPivot(cf: CFrame)
	for p, off in self.offsets do
		p.CFrame = cf * off
	end
end

-- 180度回る。tween で滑らかに。
function Daruma:_rotateTo(target: CFrame, seconds: number)
	local from = self.isLooking and self.facing or self.away
	local v = Instance.new("CFrameValue")
	v.Value = from
	local conn = v.Changed:Connect(function()
		self:_applyPivot(v.Value)
	end)
	local tw = TweenService:Create(v, TweenInfo.new(seconds, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Value = target })
	tw:Play()
	tw.Completed:Wait()
	conn:Disconnect()
	v:Destroy()
	self:_applyPivot(target)
end

function Daruma:turnToFace()
	self:_rotateTo(self.facing, 0.25)
	self.isLooking = true
end

function Daruma:turnAway()
	self:_rotateTo(self.away, 0.6)
	self.isLooking = false
end

function Daruma:_paintEyes()
	for side, pupil in self.pupils do
		local painted = self.secondEyePainted or side == self.eyeSide
		pupil.Transparency = painted and 0 or 1
	end
end

-- 目を入れ替える前の予告。黒目がチカチカする。
function Daruma:wink(seconds: number)
	local pupil = self.pupils[self.eyeSide]
	for _ = 1, 3 do
		pupil.Transparency = 1
		task.wait(seconds / 6)
		pupil.Transparency = 0
		task.wait(seconds / 6)
	end
end

function Daruma:swapEye()
	self.eyeSide = self.eyeSide == "left" and "right" or "left"
	self:_paintEyes()
end

function Daruma:paintSecondEye()
	self.secondEyePainted = true
	self:_paintEyes()
end

function Daruma:reset()
	self.secondEyePainted = false
	self.eyeSide = math.random() < 0.5 and "left" or "right"
	self:_paintEyes()
end

-- その座標はだるまに見えているか。入っている目の側の半分だけ見える。
function Daruma:canSee(pos: Vector3): boolean
	if not self.isLooking then
		return false
	end
	local rel = pos - self.stage.DarumaPosition
	local side = rel:Dot(self.facing.RightVector)
	-- 真ん中の線の上はどちらの目からも見える（線の上を歩けば安全、を防ぐ）
	if self.eyeSide == "right" then
		return side >= -0.5
	else
		return side <= 0.5
	end
end

return Daruma
