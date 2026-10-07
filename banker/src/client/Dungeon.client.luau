-- 塔の中の見た目（自分だけに見える）とカメラ、操作。サーバーから来る snapshot を 3D にする。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Config = require(ReplicatedStorage.Shared.Config)
local Designs = require(ReplicatedStorage.Shared.Chars.Designs)
local Decor = require(script.Parent:WaitForChild("Decor"))
local event = ReplicatedStorage:WaitForChild("GameEvent")
local request = ReplicatedStorage:WaitForChild("GameRequest")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

local CELL = Config.CELL
local ORIGIN = Vector3.new(0, 300, 1200)
local YAW = { [1] = 0, [2] = -math.pi / 2, [3] = math.pi, [4] = math.pi / 2 }

local root = Instance.new("Folder")
root.Name = "DungeonView"
root.Parent = workspace

local tiles: { [string]: BasePart } = {}
local walls: { [string]: BasePart } = {}
local entities: { [any]: { model: Model, target: CFrame, bb: BillboardGui? } } = {}
local itemModels: { [string]: Model } = {}
local trapModels: { [string]: BasePart } = {}
local stairsModel: Model? = nil
local shopModel: Model? = nil
local hero: Model? = nil
local heroTarget = CFrame.new()
local inRun = false
local currentFloor = 0
local snap = nil

local function cellPos(x: number, y: number): Vector3
	return ORIGIN + Vector3.new(x * CELL, 0, y * CELL)
end

local function part(name, cf, size, color, material, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or root
	return p
end

-- 階ごとの章（色・材質・小物）は Decor にまとめてある
local function theme(floor: number)
	return Decor.theme(floor)
end
local restoreLighting: (() -> ())? = nil
local props: { [string]: boolean } = {}

local function clearAll()
	root:ClearAllChildren()
	tiles, walls, entities, itemModels, trapModels, props = {}, {}, {}, {}, {}, {}
	stairsModel, shopModel, hero = nil, nil, nil
	-- 塔の外は暗い床（空が見えないように）
	local base = part("Base", CFrame.new(ORIGIN + Vector3.new(Config.MAP_W * CELL / 2, -1.2, Config.MAP_H * CELL / 2)), Vector3.new(Config.MAP_W * CELL + 400, 1.5, Config.MAP_H * CELL + 400), Color3.fromRGB(18, 18, 26), Enum.Material.Slate)
	base.CastShadow = false
end

-- ===== 床と壁 =====
local function buildTiles(s)
	local th = theme(s.floor)
	local rows = s.rows
	local function at(x, y)
		if x < 1 or y < 1 or x > Config.MAP_W or y > Config.MAP_H then
			return "9"
		end
		return string.sub(rows[y], x, x)
	end
	for y = 1, Config.MAP_H do
		local row = rows[y]
		for x = 1, Config.MAP_W do
			local c = string.sub(row, x, x)
			if c ~= "9" then
				local k = x .. "," .. y
				local n = tonumber(c)
				local kind = n % 3 -- 0 壁 1 部屋 2 通路
				local visible = n >= 3
				if kind ~= 0 then
					local t = tiles[k]
					if not t then
						t = part("Tile", CFrame.new(cellPos(x, y) + Vector3.new(0, -0.2, 0)), Vector3.new(CELL - 0.15, 0.4, CELL - 0.15), kind == 1 and th.room or th.corridor, kind == 1 and th.roomMat or th.corrMat)
						tiles[k] = t
						-- 周りの壁
						for dy = -1, 1 do
							for dx = -1, 1 do
								local nx, ny = x + dx, y + dy
								local nc = at(nx, ny)
								if nc ~= "9" and tonumber(nc) % 3 == 0 then
									local wk = nx .. "," .. ny
									if not walls[wk] then
										local w = part("Wall", CFrame.new(cellPos(nx, ny) + Vector3.new(0, Config.WALL_H / 2 - 0.4, 0)), Vector3.new(CELL, Config.WALL_H, CELL), th.wall, th.wallMat)
										if th.wallMat == Enum.Material.Glass then
											w.Transparency = 0.35
										end
										walls[wk] = w
										-- 上は壁より少し明るいふた、下は細い巾木（部屋側に 0.15 はみ出す）
										local h, sat, val = th.wall:ToHSV()
										local cap = part("Trim", CFrame.new(cellPos(nx, ny) + Vector3.new(0, Config.WALL_H - 0.35, 0)), Vector3.new(CELL + 0.02, 0.2, CELL + 0.02), Color3.fromHSV(h, sat * 0.8, math.min(1, val * 1.15 + 0.05)), th.wallMat)
										cap.Parent = w
										local base = part("WallBase", CFrame.new(cellPos(nx, ny) + Vector3.new(0, 0.1, 0)), Vector3.new(CELL + 0.3, 0.3, CELL + 0.3), th.trim)
										base.Parent = w
									end
									-- 部屋の壁ぎわ: 小物と壁の明かり（4 方向の壁だけ）
									if kind == 1 and (dx == 0 or dy == 0) and not props[k] then
										props[k] = true
										local wallDir = Vector3.new(dx, 0, dy)
										Decor.prop(th, s.floor, x, y, cellPos(x, y), wallDir, t)
										Decor.sconce(th, s.floor, x, y, cellPos(x, y), wallDir, t)
									end
								end
							end
						end
					end
					local dim = visible and 0 or 0.45
					if t:GetAttribute("Dim") ~= dim then
						t:SetAttribute("Dim", dim)
						t.Transparency = dim
					end
				end
			end
		end
	end
end

-- ===== 道具の見た目 =====
local function makeItemModel(it): Model
	local m = Instance.new("Model")
	m.Name = "Item"
	local pos = cellPos(it.x, it.y) + Vector3.new(0, 0.6, 0)
	local k = it.kind
	if k == "yen" then
		local c = part("Coin", CFrame.new(pos) * CFrame.Angles(math.pi / 2, 0, 0), Vector3.new(0.3, 1.2, 1.2), Color3.fromRGB(255, 205, 60), Enum.Material.Metal, m)
		c.Shape = Enum.PartType.Cylinder
		c.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2)
	elseif k == "food" then
		local b = part("Rice", CFrame.new(pos), Vector3.new(1.2, 1.1, 1.0), Color3.fromRGB(250, 250, 245), nil, m)
		local sm = Instance.new("SpecialMesh")
		sm.MeshType = Enum.MeshType.Sphere
		sm.Parent = b
		part("Nori", CFrame.new(pos + Vector3.new(0, -0.3, -0.45)), Vector3.new(0.6, 0.5, 0.15), Color3.fromRGB(35, 45, 35), nil, m)
	elseif k == "drink" then
		local c = part("Can", CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(1.2, 0.7, 0.7), Color3.fromRGB(120, 80, 50), Enum.Material.Metal, m)
		c.Shape = Enum.PartType.Cylinder
	elseif k == "card" then
		part("Card", CFrame.new(pos) * CFrame.Angles(0.3, 0.4, 0), Vector3.new(1.3, 0.08, 0.8), Color3.fromRGB(255, 255, 250), nil, m)
		part("CardLine", CFrame.new(pos + Vector3.new(0, 0.06, 0)) * CFrame.Angles(0.3, 0.4, 0), Vector3.new(0.8, 0.04, 0.12), Color3.fromRGB(60, 60, 80), nil, m)
	elseif k == "calc" then
		part("Calc", CFrame.new(pos), Vector3.new(0.9, 0.3, 1.3), Color3.fromRGB(70, 70, 80), nil, m)
		part("CalcScreen", CFrame.new(pos + Vector3.new(0, 0.17, -0.35)), Vector3.new(0.7, 0.04, 0.35), Color3.fromRGB(180, 230, 190), Enum.Material.Neon, m)
	elseif k == "weapon" then
		local c = part("Pen", CFrame.new(pos) * CFrame.Angles(0, 0, 0.9), Vector3.new(1.6, 0.25, 0.25), Color3.fromRGB(40, 40, 60), Enum.Material.Metal, m)
		c.Shape = Enum.PartType.Cylinder
		part("PenTip", CFrame.new(pos + Vector3.new(0.6, -0.6, 0)) * CFrame.Angles(0, 0, 0.9), Vector3.new(0.3, 0.2, 0.2), Color3.fromRGB(255, 205, 60), Enum.Material.Metal, m)
	elseif k == "armor" then
		part("Suit", CFrame.new(pos), Vector3.new(1.1, 1.2, 0.5), Color3.fromRGB(40, 55, 95), Enum.Material.Fabric, m)
		part("SuitTie", CFrame.new(pos + Vector3.new(0, 0.1, -0.28)), Vector3.new(0.15, 0.7, 0.05), Color3.fromRGB(220, 50, 60), nil, m)
	elseif k == "acc" then
		part("Tie", CFrame.new(pos) * CFrame.Angles(0, 0, 0.3), Vector3.new(0.25, 1.3, 0.1), Color3.fromRGB(220, 50, 60), Enum.Material.Fabric, m)
	else
		part("Box", CFrame.new(pos), Vector3.new(1, 1, 1), Color3.fromRGB(200, 200, 200), nil, m)
	end
	-- 名前
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(120, 22)
	bb.StudsOffset = Vector3.new(0, 1.6, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 60
	bb.Adornee = m:FindFirstChildWhichIsA("BasePart")
	bb.Parent = m
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = Enum.Font.FredokaOne
	t.TextColor3 = k == "yen" and Color3.fromRGB(255, 220, 100) or Color3.fromRGB(255, 255, 255)
	t.TextStrokeTransparency = 0.3
	t.Text = it.name
	t.Parent = bb
	m.Parent = root
	return m
end

local function syncItems(s)
	local keep = {}
	for _, it in s.items do
		local k = it.x .. "," .. it.y .. "|" .. it.name
		keep[k] = true
		if not itemModels[k] then
			itemModels[k] = makeItemModel(it)
		end
	end
	for k, m in itemModels do
		if not keep[k] then
			m:Destroy()
			itemModels[k] = nil
		end
	end
end

local function syncTraps(s)
	for _, tr in s.traps do
		local k = tr.x .. "," .. tr.y
		if not trapModels[k] then
			local p = part("Trap", CFrame.new(cellPos(tr.x, tr.y) + Vector3.new(0, 0.05, 0)), Vector3.new(CELL - 1, 0.1, CELL - 1), Color3.fromRGB(200, 60, 60))
			p.Transparency = 0.3
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.fromOffset(120, 20)
			bb.StudsOffset = Vector3.new(0, 1, 0)
			bb.AlwaysOnTop = true
			bb.MaxDistance = 50
			bb.Parent = p
			local t = Instance.new("TextLabel")
			t.Size = UDim2.fromScale(1, 1)
			t.BackgroundTransparency = 1
			t.TextScaled = true
			t.Font = Enum.Font.FredokaOne
			t.TextColor3 = Color3.fromRGB(255, 120, 120)
			t.TextStrokeTransparency = 0.3
			t.Text = "⚠ " .. tr.name
			t.Parent = bb
			trapModels[k] = p
		end
	end
end

local function syncStairs(s)
	if s.stairs and not stairsModel then
		local m = Instance.new("Model")
		m.Name = "Stairs"
		local pos = cellPos(s.stairs[1], s.stairs[2])
		for i = 0, 3 do
			part("Step", CFrame.new(pos + Vector3.new(0, 0.2 + i * 0.5, 1.2 - i * 0.8)), Vector3.new(3, 0.5, 1), Color3.fromRGB(255, 205, 60), Enum.Material.Metal, m)
		end
		local glow = part("Glow", CFrame.new(pos + Vector3.new(0, 2.5, -1.5)), Vector3.new(3, 0.3, 1), Color3.fromRGB(255, 240, 150), Enum.Material.Neon, m)
		local l = Instance.new("PointLight")
		l.Color = Color3.fromRGB(255, 220, 120)
		l.Range = 14
		l.Brightness = 1.5
		l.Parent = glow
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.fromOffset(100, 26)
		bb.StudsOffset = Vector3.new(0, 2, 0)
		bb.AlwaysOnTop = true
		bb.Parent = glow
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.TextScaled = true
		t.Font = Enum.Font.FredokaOne
		t.TextColor3 = Color3.fromRGB(255, 230, 120)
		t.TextStrokeTransparency = 0.2
		t.Text = "▲ 階段"
		t.Parent = bb
		m.Parent = root
		stairsModel = m
	end
end

local function syncShop(s)
	if s.shop and not shopModel then
		shopModel = Designs.build("misaki", CFrame.new(cellPos(s.shop.x, s.shop.y)) * CFrame.Angles(0, math.pi, 0), root)
		shopModel:ScaleTo(0.8)
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.fromOffset(140, 26)
		bb.StudsOffset = Vector3.new(0, 4, 0)
		bb.AlwaysOnTop = true
		bb.Parent = shopModel.PrimaryPart
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.TextScaled = true
		t.Font = Enum.Font.FredokaOne
		t.TextColor3 = Color3.fromRGB(255, 200, 120)
		t.TextStrokeTransparency = 0.2
		t.Text = "臨時売店 ミサキ"
		t.Parent = bb
	end
end

-- ===== 敵・部下・主役 =====
local function statusBillboard(m: Model, name: string, color: Color3): (BillboardGui, TextLabel, Frame)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(110, 34)
	bb.StudsOffset = Vector3.new(0, 3.6, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = m.PrimaryPart
	bb.Parent = m.PrimaryPart
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 0.6)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = Enum.Font.FredokaOne
	t.TextColor3 = color
	t.TextStrokeTransparency = 0.3
	t.Text = name
	t.Parent = bb
	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.fromScale(1, 0.25)
	barBg.Position = UDim2.fromScale(0, 0.7)
	barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	barBg.BorderSizePixel = 0
	barBg.Parent = bb
	local bar = Instance.new("Frame")
	bar.Size = UDim2.fromScale(1, 1)
	bar.BackgroundColor3 = Color3.fromRGB(90, 220, 110)
	bar.BorderSizePixel = 0
	bar.Parent = barBg
	bar.Name = "Bar"
	return bb, t, bar
end

local function syncEntities(s)
	local keep = {}
	for _, m in s.monsters do
		keep[m.uid] = true
		local e = entities[m.uid]
		local cf = CFrame.new(cellPos(m.x, m.y))
		if not e then
			local model = Designs.build(m.id, cf, root)
			model:ScaleTo(0.78 + (m.grow or 0) * 0.06)
			local bb, label, bar = statusBillboard(model, m.name, Color3.fromRGB(255, 150, 150))
			e = { model = model, target = cf, bb = bb, label = label, bar = bar, grow = m.grow, pos = cf }
			entities[m.uid] = e
			model:PivotTo(cf * CFrame.new(0, 1.5, 0))
		end
		e.target = cf
		if e.grow ~= m.grow then
			e.grow = m.grow
			e.model:ScaleTo(0.78 + (m.grow or 0) * 0.06)
		end
		e.bar.Size = UDim2.fromScale(math.clamp(m.hp / m.hpMax, 0, 1), 1)
		e.label.Text = (m.asleep and "💤 " or "") .. m.name
		if m.shade then
			for _, p in e.model:GetDescendants() do
				if p:IsA("BasePart") and p.Name == "Body" then
					p.Color = (m.shade % 2 == 1) and Color3.fromRGB(255, 150, 90) or Color3.fromRGB(130, 200, 90)
				end
			end
		end
	end
	for uid, e in entities do
		if uid ~= "intern" and not keep[uid] then
			e.model:Destroy()
			entities[uid] = nil
		end
	end
	-- 部下
	if s.intern then
		local cf = CFrame.new(cellPos(s.intern.x, s.intern.y))
		local e = entities.intern
		if not e then
			local model = Designs.build("intern", cf, root)
			model:ScaleTo(0.8)
			local bb, label, bar = statusBillboard(model, "インターン", Color3.fromRGB(150, 255, 170))
			e = { model = model, target = cf, bb = bb, label = label, bar = bar, pos = cf }
			entities.intern = e
			model:PivotTo(cf * CFrame.new(0, 1.5, 0))
		end
		e.target = cf
		e.bar.Size = UDim2.fromScale(math.clamp(s.intern.hp / 20, 0, 1), 1)
	elseif entities.intern then
		entities.intern.model:Destroy()
		entities.intern = nil
	end
	-- 主役
	local hcf = CFrame.new(cellPos(s.px, s.py)) * CFrame.Angles(0, YAW[s.facing] or 0, 0)
	if not hero then
		hero = Designs.build("taku", hcf, root)
		hero:ScaleTo(0.85)
		heroTarget = hcf
		hero:PivotTo(hcf * CFrame.new(0, 1.5, 0))
	end
	heroTarget = hcf
end

-- ===== 演出 =====
local function floatText(pos: Vector3, text: string, color: Color3, big: boolean?)
	local p = part("Fx", CFrame.new(pos + Vector3.new(0, 3, 0)), Vector3.new(0.1, 0.1, 0.1), color)
	p.Transparency = 1
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(big and 160 or 90, big and 50 or 32)
	bb.AlwaysOnTop = true
	bb.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = Enum.Font.FredokaOne
	t.TextColor3 = color
	t.TextStrokeTransparency = 0.2
	t.Text = text
	t.Parent = bb
	TweenService:Create(p, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = p.CFrame + Vector3.new(0, 2.5, 0) }):Play()
	TweenService:Create(t, TweenInfo.new(0.9), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(1, function()
		p:Destroy()
	end)
end

local function flash(model: Model?, color: Color3)
	if not model then
		return
	end
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p.Name ~= "Root" then
			local orig = p.Color
			p.Color = color
			task.delay(0.12, function()
				if p.Parent then
					p.Color = orig
				end
			end)
		end
	end
end

local function beam(from, to, color)
	local a, b = cellPos(from[1], from[2]) + Vector3.new(0, 1.8, 0), cellPos(to[1], to[2]) + Vector3.new(0, 1.8, 0)
	local len = math.max(0.5, (b - a).Magnitude)
	local p = part("Beam", CFrame.lookAt((a + b) / 2, b), Vector3.new(0.4, 0.4, len), color, Enum.Material.Neon)
	TweenService:Create(p, TweenInfo.new(0.35), { Transparency = 1 }):Play()
	task.delay(0.4, function()
		p:Destroy()
	end)
end

local function throwFx(from, to)
	local a, b = cellPos(from[1], from[2]) + Vector3.new(0, 2, 0), cellPos(to[1], to[2]) + Vector3.new(0, 1, 0)
	local p = part("Thrown", CFrame.new(a), Vector3.new(0.6, 0.6, 0.6), Color3.fromRGB(255, 255, 255))
	TweenService:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Linear), { CFrame = CFrame.new(b) }):Play()
	task.delay(0.35, function()
		p:Destroy()
	end)
end

local function dieFx(uid, x, y)
	local e = entities[uid]
	local pos = cellPos(x, y)
	if e then
		local m = e.model
		entities[uid] = nil
		task.spawn(function()
			for i = 1, 6 do
				m:ScaleTo(math.max(0.05, m:GetScale() * 0.7))
				m:PivotTo(m:GetPivot() * CFrame.Angles(0, 0.5, 0))
				task.wait(0.03)
			end
			m:Destroy()
		end)
	end
	for i = 1, 6 do
		local a = i / 6 * math.pi * 2
		local s = part("Star", CFrame.new(pos + Vector3.new(0, 1.5, 0)), Vector3.new(0.4, 0.4, 0.4), Color3.fromRGB(255, 230, 120), Enum.Material.Neon)
		TweenService:Create(s, TweenInfo.new(0.5), { CFrame = CFrame.new(pos + Vector3.new(math.cos(a) * 3, 2.5, math.sin(a) * 3)), Transparency = 1 }):Play()
		task.delay(0.6, function()
			s:Destroy()
		end)
	end
end

local function handleEvents(s)
	for _, e in s.events do
		if e.t == "hit" then
			if e.target == "player" then
				flash(hero, Color3.fromRGB(255, 80, 80))
				floatText(cellPos(s.px, s.py), "-" .. e.dmg, Color3.fromRGB(255, 90, 90), true)
			elseif e.target == "intern" and entities.intern then
				flash(entities.intern.model, Color3.fromRGB(255, 80, 80))
				floatText(cellPos(s.intern and s.intern.x or s.px, s.intern and s.intern.y or s.py), "-" .. e.dmg, Color3.fromRGB(255, 150, 150))
			else
				local en = entities[e.target]
				if en then
					flash(en.model, Color3.fromRGB(255, 255, 255))
					floatText(en.target.Position, tostring(e.dmg), Color3.fromRGB(255, 240, 120), true)
					-- 主役が踏み込む（戻りは毎フレームのなめらか化にまかせる）
					if e.from == "player" and hero then
						local dir = (en.target.Position - heroTarget.Position)
						if dir.Magnitude > 0.1 then
							hero:PivotTo(hero:GetPivot() + dir.Unit * 1.6)
						end
					end
				end
			end
		elseif e.t == "attack" then
			local en = entities[e.from]
			if en and hero then
				local dir = (heroTarget.Position - en.target.Position)
				if dir.Magnitude > 0.1 then
					en.model:PivotTo(en.model:GetPivot() + dir.Unit * 1.6)
				end
			end
		elseif e.t == "miss" then
			floatText(cellPos(s.px, s.py), "MISS", Color3.fromRGB(200, 200, 255))
		elseif e.t == "die" then
			dieFx(e.uid, e.x, e.y)
		elseif e.t == "beam" then
			beam(e.from, e.to, e.id == "calc_zap" and Color3.fromRGB(255, 240, 100) or Color3.fromRGB(150, 200, 255))
		elseif e.t == "throw" then
			throwFx(e.from, e.to)
		elseif e.t == "trap" then
			floatText(cellPos(e.x, e.y), "⚠ 罠！", Color3.fromRGB(255, 120, 120), true)
		elseif e.t == "levelup" then
			floatText(cellPos(s.px, s.py), "LEVEL UP!", Color3.fromRGB(120, 255, 160), true)
		elseif e.t == "pickup" then
			if e.yen then
				floatText(cellPos(e.x, e.y), "+" .. e.yen .. " 円", Color3.fromRGB(255, 220, 100))
			end
		elseif e.t == "floor" then
			-- 新しい階: 全部作り直す
			clearAll()
			currentFloor = e.floor
		elseif e.t == "exam_clear" then
			floatText(cellPos(s.px, s.py), "昇進試験 合格！", Color3.fromRGB(255, 230, 120), true)
		end
	end
end

-- ===== snapshot を受け取る =====
local function apply(s)
	snap = s
	if not inRun then
		inRun = true
		clearAll()
		currentFloor = s.floor
	end
	if s.floor ~= currentFloor then
		clearAll()
		currentFloor = s.floor
	end
	if restoreLighting then
		restoreLighting()
	end
	restoreLighting = Decor.applyLighting(theme(s.floor))
	handleEvents(s)
	buildTiles(s)
	syncStairs(s)
	syncShop(s)
	syncItems(s)
	syncTraps(s)
	syncEntities(s)
	if s.ended then
		inRun = false
	end
end

-- ===== カメラと動きのなめらか化 =====
local cam = workspace.CurrentCamera
local camPos = nil
RunService.RenderStepped:Connect(function(dt)
	if not snap then
		return
	end
	local a = math.min(1, dt * 14)
	for _, c in CollectionService:GetTagged("FloatCoin") do
		if c.Parent then
			c.CFrame = c.CFrame * CFrame.Angles(0, dt * 1.5, 0) + Vector3.new(0, math.sin(os.clock() * 2 + c:GetAttribute("Float")) * dt * 0.6, 0)
		end
	end
	if hero then
		local cur = hero:GetPivot()
		local goal = heroTarget * CFrame.new(0, 1.5, 0)
		hero:PivotTo(cur:Lerp(goal, a))
	end
	for _, e in entities do
		local cur = e.model:GetPivot()
		local goal = e.target * CFrame.new(0, 1.5, 0)
		-- 進む向きを向く
		local d = (e.target.Position - cur.Position)
		local yaw = cur.Rotation
		if d.Magnitude > 0.3 then
			yaw = CFrame.lookAt(Vector3.zero, Vector3.new(d.X, 0, d.Z)).Rotation
		end
		e.model:PivotTo(cur.Position:Lerp(goal.Position, a) == goal.Position and goal or CFrame.new(cur.Position:Lerp(goal.Position, a)) * yaw)
	end
	if inRun or (snap and snap.ended) then
		cam.CameraType = Enum.CameraType.Scriptable
		local hp = heroTarget.Position
		local want = hp + Vector3.new(0, 30, 20)
		camPos = camPos and camPos:Lerp(want, math.min(1, dt * 6)) or want
		cam.CFrame = CFrame.lookAt(camPos, camPos - Vector3.new(0, 30, 20) + Vector3.new(0, 1, 0))
		cam.FieldOfView = 55
	end
end)

local function leaveRun()
	snap = nil
	inRun = false
	camPos = nil
	clearAll()
	if restoreLighting then
		restoreLighting()
		restoreLighting = nil
	end
	cam.CameraType = Enum.CameraType.Custom
	local ch = player.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if hum then
		cam.CameraSubject = hum
		cam.CFrame = ch:GetPivot() * CFrame.new(0, 6, 14)
	end
end

-- ===== 操作 =====
local pending = false
local pendingAt = 0
local function send(kind, a)
	if snap and snap.ended then
		return
	end
	pending = true
	pendingAt = os.clock()
	request:FireServer(kind, a)
end

local KEYS = {
	[Enum.KeyCode.W] = 1,
	[Enum.KeyCode.Up] = 1,
	[Enum.KeyCode.D] = 2,
	[Enum.KeyCode.Right] = 2,
	[Enum.KeyCode.S] = 3,
	[Enum.KeyCode.Down] = 3,
	[Enum.KeyCode.A] = 4,
	[Enum.KeyCode.Left] = 4,
}
local held: { [number]: boolean } = {}
local lastStep = 0

local function tryStep(dir)
	if not inRun or not snap or snap.ended then
		return
	end
	if pending and os.clock() - pendingAt < 0.6 then
		return
	end
	if os.clock() - lastStep < 0.13 then
		return
	end
	lastStep = os.clock()
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		send("face", dir)
	else
		send("step", dir)
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not inRun then
		return
	end
	local dir = KEYS[input.KeyCode]
	if dir then
		held[dir] = true
		tryStep(dir)
	elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.Z then
		send("wait")
	elseif input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.Return then
		if snap and snap.onStairs then
			send("climb")
		end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	local dir = KEYS[input.KeyCode]
	if dir then
		held[dir] = nil
	end
end)
RunService.Heartbeat:Connect(function()
	if not inRun then
		return
	end
	for dir in held do
		tryStep(dir)
		break
	end
end)

-- 画面のボタン（スマホ用の十字キー）
local screen = Instance.new("ScreenGui")
screen.Name = "DungeonPad"
screen.ResetOnSpawn = false
screen.DisplayOrder = 6
screen.Enabled = false
screen.Parent = gui
local pad = Instance.new("Frame")
pad.AnchorPoint = Vector2.new(0, 1)
pad.Position = UDim2.new(0, 16, 1, -16)
pad.Size = UDim2.fromOffset(170, 170)
pad.BackgroundTransparency = 1
pad.Parent = screen
local function padBtn(text, dir, px, py)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(54, 54)
	b.Position = UDim2.fromOffset(px, py)
	b.BackgroundColor3 = Color3.fromRGB(40, 50, 80)
	b.BackgroundTransparency = 0.25
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextScaled = true
	b.Font = Enum.Font.FredokaOne
	b.Text = text
	b.Parent = pad
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 12)
	c.Parent = b
	b.MouseButton1Down:Connect(function()
		held[dir] = true
		tryStep(dir)
	end)
	b.MouseButton1Up:Connect(function()
		held[dir] = nil
	end)
	b.MouseLeave:Connect(function()
		held[dir] = nil
	end)
end
padBtn("▲", 1, 58, 0)
padBtn("▶", 2, 116, 58)
padBtn("▼", 3, 58, 116)
padBtn("◀", 4, 0, 58)

local StarterGui = game:GetService("StarterGui")
event.OnClientEvent:Connect(function(kind, data)
	if kind == "run" then
		if not inRun then
			pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
			end)
		end
		apply(data)
		pending = false
		screen.Enabled = true
		-- テスト用に要点を属性へ
		local ms = {}
		for _, m in data.monsters do
			table.insert(ms, m.id .. "@" .. m.x .. "," .. m.y .. ":" .. m.hp)
		end
		player:SetAttribute("Snap", string.format("f=%d p=%d,%d hp=%d/%d lv=%d yen=%d inv=%d stairs=%s onStairs=%s ended=%s intern=%s mons=%s", data.floor, data.px, data.py, data.hp, data.hpMax, data.lv, data.yen, #data.inv, data.stairs and (data.stairs[1] .. "," .. data.stairs[2]) or "?", tostring(data.onStairs), tostring(data.ended), data.intern and (data.intern.x .. "," .. data.intern.y) or "none", table.concat(ms, " ")))
	elseif kind == "runEnd" then
		task.delay(0.3, function()
			leaveRun()
			screen.Enabled = false
			pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
			end)
		end)
	end
end)

-- 他の画面から使えるように
_G.DungeonSend = send
