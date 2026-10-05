-- 巨大な片目だるま。体、顔、目、振り向き、視界判定。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)

local Daruma = {}
Daruma.__index = Daruma

local EYE_OFFSET_X = 3.6
local EYE_OFFSET_Y = 1.5
local PAINTED = Color3.fromRGB(20, 20, 20)
local UNPAINTED = Color3.fromRGB(235, 235, 235)

local function ball(name: string, size: number, color: Color3, parent: Instance): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(size, size, size)
	p.Color = color
	p.Anchored = true
	p.CanCollide = true
	p.Material = Enum.Material.SmoothPlastic
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

	local r = Config.DARUMA_RADIUS
	local body = ball("Body", r * 2, Color3.fromRGB(200, 30, 30), model)
	body.CFrame = self.facing
	model.PrimaryPart = body

	-- 顔（白）。体の前面に少しめり込ませる。
	local face = ball("Face", r * 1.2, Color3.fromRGB(250, 240, 225), model)
	face.CanCollide = false
	-- オブジェクト空間では -Z が正面
	face.CFrame = self.facing * CFrame.new(0, r * 0.15, -r * 0.55)

	-- 目。RightVector 方向が「だるまの右」。
	self.eyes = {}
	for _, side in { "left", "right" } do
		local sign = side == "right" and 1 or -1
		local eye = ball("Eye_" .. side, 3, UNPAINTED, model)
		eye.CanCollide = false
		eye.CFrame = self.facing * CFrame.new(sign * EYE_OFFSET_X, r * 0.15 + EYE_OFFSET_Y, -r * 1.05)
		self.eyes[side] = eye
	end

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
	for side, eye in self.eyes do
		local painted = self.secondEyePainted or side == self.eyeSide
		eye.Color = painted and PAINTED or UNPAINTED
	end
end

-- 目を入れ替える前の予告。入っている目がチカチカする。
function Daruma:wink()
	local eye = self.eyes[self.eyeSide]
	for _ = 1, 3 do
		eye.Transparency = 0.7
		task.wait(Config.WINK_TIME / 6)
		eye.Transparency = 0
		task.wait(Config.WINK_TIME / 6)
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
	if self.eyeSide == "right" then
		return side > 0
	else
		return side < 0
	end
end

return Daruma
