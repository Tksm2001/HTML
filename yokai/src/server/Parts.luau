-- ステージの部品を作る道具。各ステージ（Stages フォルダ）から使う。
local Parts = {}

Parts.BLACK = Color3.fromRGB(30, 28, 26)
Parts.STONE = Color3.fromRGB(150, 148, 140)
Parts.WOOD = Color3.fromRGB(110, 72, 45)
Parts.GOLD = Color3.fromRGB(225, 175, 55)
Parts.VERMILION = Color3.fromRGB(215, 60, 35)

-- 固定された直方体。props にプロパティを並べる（Parent は最後に設定する）
function Parts.part(props: { [string]: any }): Part
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
function Parts.pillar(parent: Instance, pos: Vector3, height: number, width: number, color: Color3, material: Enum.Material?): Part
	return Parts.part({
		Name = "Pillar",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(height, width, width),
		CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2),
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		Parent = parent,
	})
end

-- 球
function Parts.ball(parent: Instance, pos: Vector3, size: number, color: Color3, material: Enum.Material?, collide: boolean?): Part
	return Parts.part({
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * size,
		Position = pos,
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		CanCollide = collide == true,
		Parent = parent,
	})
end

-- 板の面に文字を書く。face を省略すると Front（部品の -Z 側の面）
function Parts.sign(p: BasePart, text: string, color: Color3, face: Enum.NormalId?, background: Color3?)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.LightInfluence = 0
	-- 1 スタッドあたりの画素を少なくして、文字を大きく描く
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 12
	gui.Parent = p
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = background and 0 or 1
	label.BackgroundColor3 = background or Color3.new()
	label.Text = text
	label.TextScaled = true
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
end

-- 文字を書くための板。Front 面が look の方向を向く
function Parts.board(parent: Instance, pos: Vector3, size: Vector3, look: Vector3, color: Color3, text: string?, textColor: Color3?, material: Enum.Material?): Part
	local p = Parts.part({
		Name = "Board",
		Size = size,
		CFrame = CFrame.lookAt(pos, pos + look),
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		Parent = parent,
	})
	if text then
		Parts.sign(p, text, textColor or Color3.new(1, 1, 1))
	end
	return p
end

-- 道をふさぐ障害物（wall）の横幅。壁際から中央線を 4 スタッド越えたところまで。
-- 中央線をまたぐので、抜けるには反対側の半分へ渡るしかない
function Parts.wallSpan(halfW: number, side: string)
	local sign = side == "L" and -1 or 1
	local inner, outer = -4, halfW -- inner がマイナス = 中央線を越えて反対側にはみ出す
	return {
		sign = sign,
		inner = inner,
		outer = outer,
		length = outer - inner,
		cx = sign * (inner + outer) / 2,
	}
end

function Parts.folder(parent: Instance, name: string): Folder
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

return Parts
