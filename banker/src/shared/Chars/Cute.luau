-- かわいい顔と手足を作る共通の道具。全キャラがこれを使うので、見た目の統一がここで決まる。
-- 座標: cf を足元の中心とし、-Z が正面。
local Cute = {}

Cute.BLACK = Color3.fromRGB(35, 30, 35)
Cute.WHITE = Color3.fromRGB(252, 252, 252)
Cute.PINK = Color3.fromRGB(255, 150, 170)
Cute.CREAM = Color3.fromRGB(255, 235, 205) -- 手足の色（全キャラ共通）

-- 基本の部品。shape = "ball"（楕円にできる球）/ "box" / "cyl" / "wedge"
function Cute.piece(model: Instance, name: string, cf: CFrame, size: Vector3, color: Color3, shape: string?, material: Enum.Material?): BasePart
	local p: BasePart
	if shape == "wedge" then
		p = Instance.new("WedgePart")
	else
		p = Instance.new("Part")
		if shape == "cyl" then
			(p :: Part).Shape = Enum.PartType.Cylinder
		end
	end
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape == "ball" or shape == nil then
		local m = Instance.new("SpecialMesh")
		m.MeshType = Enum.MeshType.Sphere
		m.Parent = p
	end
	p.Parent = model
	return p
end

function Cute.ball(m, name, cf, size, color, material)
	return Cute.piece(m, name, cf, size, color, "ball", material)
end
function Cute.box(m, name, cf, size, color, material)
	return Cute.piece(m, name, cf, size, color, "box", material)
end
-- 縦向きの円柱
function Cute.cylY(m, name, cf, length, radius, color, material)
	return Cute.piece(m, name, cf * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(length, radius * 2, radius * 2), color, "cyl", material)
end
-- 前向き（-Z）の円柱
function Cute.cylZ(m, name, cf, length, radius, color, material)
	return Cute.piece(m, name, cf * CFrame.Angles(0, math.pi / 2, 0), Vector3.new(length, radius * 2, radius * 2), color, "cyl", material)
end
-- 横向き（X）の円柱
function Cute.cylX(m, name, cf, length, radius, color, material)
	return Cute.piece(m, name, cf, Vector3.new(length, radius * 2, radius * 2), color, "cyl", material)
end

-- 目 1 つ。center = 目の中心、r = 白目の半径。style = "open"（ぱっちり）/ "happy"（にっこり）/ "wink"
function Cute.eye(m, cf: CFrame, center: Vector3, r: number, style: string?)
	if style == "happy" then
		for _, s in { -1, 1 } do
			Cute.piece(m, "Eye", cf * CFrame.new(center + Vector3.new(s * r * 0.45, 0, 0)) * CFrame.Angles(0, 0, s * 0.9) * CFrame.Angles(0, 0, math.pi / 2),
				Vector3.new(r * 1.1, r * 0.35, r * 0.25), Cute.BLACK, "cyl")
		end
		return
	end
	Cute.ball(m, "EyeWhite", cf * CFrame.new(center), Vector3.new(r * 2, r * 2.1, r * 1.2), Cute.WHITE)
	Cute.ball(m, "Pupil", cf * CFrame.new(center + Vector3.new(0, -r * 0.05, -r * 0.42)), Vector3.new(r * 1.2, r * 1.3, r * 0.6), Cute.BLACK)
	Cute.ball(m, "Shine", cf * CFrame.new(center + Vector3.new(-r * 0.3, r * 0.35, -r * 0.72)), Vector3.new(r * 0.48, r * 0.48, r * 0.25), Cute.WHITE)
	Cute.ball(m, "Shine", cf * CFrame.new(center + Vector3.new(r * 0.28, -r * 0.28, -r * 0.72)), Vector3.new(r * 0.22, r * 0.22, r * 0.2), Cute.WHITE)
end

function Cute.blush(m, cf: CFrame, center: Vector3, w: number)
	Cute.ball(m, "Blush", cf * CFrame.new(center), Vector3.new(w, w * 0.55, 0.12), Cute.PINK)
end

-- 口。kind = "w"（ねこ口）/ "o"（まる口）/ "open"（あーん）/ "smile"
function Cute.mouth(m, cf: CFrame, center: Vector3, w: number, kind: string?)
	if kind == "open" then
		Cute.ball(m, "Mouth", cf * CFrame.new(center), Vector3.new(w, w * 0.9, 0.3), Cute.BLACK)
		Cute.ball(m, "Tongue", cf * CFrame.new(center + Vector3.new(0, -w * 0.25, -0.05)), Vector3.new(w * 0.55, w * 0.45, 0.3), Cute.PINK)
	elseif kind == "o" then
		Cute.ball(m, "Mouth", cf * CFrame.new(center), Vector3.new(w * 0.5, w * 0.5, 0.2), Cute.BLACK)
	elseif kind == "smile" then
		Cute.piece(m, "Mouth", cf * CFrame.new(center) * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(w * 0.18, w, w * 0.18), Cute.BLACK, "cyl")
	else
		for _, s in { -1, 1 } do
			Cute.piece(m, "Mouth", cf * CFrame.new(center + Vector3.new(s * w * 0.25, 0, 0)) * CFrame.Angles(0, 0, -s * 0.7) * CFrame.Angles(0, 0, math.pi / 2),
				Vector3.new(w * 0.5, w * 0.16, w * 0.16), Cute.BLACK, "cyl")
		end
	end
end

-- 顔一式。faceZ = 顔を置く前面の Z（-Z 側）。y = 目の高さ。
-- o: eyeR, eyeX（目の間隔の半分）, eyeStyle, mouth, mouthW, mouthDrop（目から口までの距離）, blushX, blush=false
function Cute.face(m, cf, x: number, y: number, faceZ: number, o)
	o = o or {}
	local er = o.eyeR or 0.3
	local ex = o.eyeX or 0.45
	if o.eyes ~= 1 then
		Cute.eye(m, cf, Vector3.new(x - ex, y, faceZ - er * 0.3), er, o.eyeStyle)
		Cute.eye(m, cf, Vector3.new(x + ex, y, faceZ - er * 0.3), er, o.eyeStyle)
	else
		Cute.eye(m, cf, Vector3.new(x, y, faceZ - er * 0.3), er, o.eyeStyle)
	end
	if o.blush ~= false then
		local bx = o.blushX or (ex + er * 1.15)
		Cute.blush(m, cf, Vector3.new(x - bx, y - er * 1.1, faceZ), er * 1.1)
		Cute.blush(m, cf, Vector3.new(x + bx, y - er * 1.1, faceZ), er * 1.1)
	end
	if o.mouth ~= false then
		Cute.mouth(m, cf, Vector3.new(x, y - (o.mouthDrop or er * 1.7), faceZ - 0.05), o.mouthW or er * 1.2, o.mouth)
	end
end

-- 手（体の横）と足（体の下）。bodyY = 体の中心の高さ、halfW = 体の横幅の半分
function Cute.limbs(m, cf, bodyY: number, halfW: number, o)
	o = o or {}
	local s = o.size or 0.5
	local color = o.color or Cute.CREAM
	for _, side in { -1, 1 } do
		Cute.ball(m, "Arm", cf * CFrame.new(side * (halfW + s * 0.25), bodyY - (o.armDrop or 0.2), -(o.armZ or 0.2)), Vector3.new(s, s * 0.9, s), color)
	end
	if o.feet ~= false then
		for _, side in { -1, 1 } do
			Cute.ball(m, "Foot", cf * CFrame.new(side * (o.footX or halfW * 0.45), s * 0.32, -(o.footZ or 0.2)), Vector3.new(s * 1.1, s * 0.65, s * 1.3), color)
		end
	end
end

-- 持ち手つきの小さな旗（かきごおり等）
function Cute.flag(m, cf, color: Color3)
	Cute.cylY(m, "FlagPole", cf * CFrame.new(0, 0.6, 0), 1.2, 0.05, Color3.fromRGB(240, 230, 210))
	Cute.piece(m, "Flag", cf * CFrame.new(0.3, 1.0, 0), Vector3.new(0.6, 0.4, 0.05), color, "wedge")
end

-- キラキラ（SR 以上）: 小さな光る粒を体のまわりに
function Cute.sparkles(m, cf, centerY: number, radius: number, count: number, color: Color3)
	for i = 1, count do
		local a = i / count * math.pi * 2
		local y = centerY + math.sin(i * 1.7) * radius * 0.6
		Cute.ball(m, "Sparkle", cf * CFrame.new(math.cos(a) * radius, y, math.sin(a) * radius), Vector3.new(0.22, 0.22, 0.22), color, Enum.Material.Neon)
	end
end

return Cute
