-- 図鑑・もちものの画面。持っている子は 3D で表示、持っていない子は「？」。
-- たなの「かざる」を押したあとは、ここで子を選ぶと飾られる。ダブりは「おかえし」でコインに。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Designs = require(ReplicatedStorage.Shared:WaitForChild("Chars"):WaitForChild("Designs"))
local event = ReplicatedStorage:WaitForChild("GameEvent")
local request = ReplicatedStorage:WaitForChild("GameRequest")
local getInventory = ReplicatedStorage:WaitForChild("GetInventory")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

local function corner(p: Instance, r: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
end

local screen = Instance.new("ScreenGui")
screen.Name = "Collection"
screen.ResetOnSpawn = false
screen.DisplayOrder = 5
screen.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.52)
panel.Size = UDim2.fromScale(0.9, 0.86)
panel.BackgroundColor3 = Color3.fromRGB(252, 246, 232)
panel.Visible = false
panel.Parent = screen
corner(panel, 18)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(900, 620)
limit.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(230, 90, 90)
stroke.Thickness = 4
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(0.7, 0.1)
title.Position = UDim2.fromScale(0.03, 0.02)
title.BackgroundTransparency = 1
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.FredokaOne
title.TextColor3 = Color3.fromRGB(230, 90, 90)
title.Text = "図鑑  Collection"
title.Parent = panel

local close = Instance.new("TextButton")
close.Size = UDim2.fromScale(0.08, 0.09)
close.Position = UDim2.fromScale(0.9, 0.02)
close.BackgroundColor3 = Color3.fromRGB(230, 90, 90)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextScaled = true
close.Font = Enum.Font.FredokaOne
close.Text = "×"
close.Parent = panel
corner(close, 12)

local hint = Instance.new("TextLabel")
hint.Size = UDim2.fromScale(0.94, 0.06)
hint.Position = UDim2.fromScale(0.03, 0.11)
hint.BackgroundTransparency = 1
hint.TextScaled = true
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Font = Enum.Font.FredokaOne
hint.TextColor3 = Color3.fromRGB(90, 70, 60)
hint.Parent = panel

local grid = Instance.new("ScrollingFrame")
grid.Position = UDim2.fromScale(0.03, 0.18)
grid.Size = UDim2.fromScale(0.94, 0.8)
grid.BackgroundTransparency = 1
grid.ScrollBarThickness = 8
grid.CanvasSize = UDim2.new(0, 0, 0, 0)
grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
grid.Parent = panel
local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.fromOffset(150, 190)
layout.CellPadding = UDim2.fromOffset(10, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = grid

-- かざるモード: たなの番号。nil なら ふつうの図鑑
local pickingSlot: number? = nil
local inv = nil
local cells = {}

-- セルの 3D 表示
local function makeViewport(parent: Instance, id: string): ViewportFrame
	local vp = Instance.new("ViewportFrame")
	vp.Size = UDim2.fromScale(1, 0.62)
	vp.BackgroundTransparency = 1
	vp.Ambient = Color3.fromRGB(200, 200, 210)
	vp.LightColor = Color3.fromRGB(255, 250, 240)
	vp.LightDirection = Vector3.new(-1, -1.5, -1)
	vp.Parent = parent
	local world = Instance.new("WorldModel")
	world.Parent = vp
	local m = Designs.build(id, CFrame.new(), world)
	local cam = Instance.new("Camera")
	cam.CFrame = CFrame.lookAt(Vector3.new(0, 2.6, -7.2), Vector3.new(0, 1.9, 0))
	cam.FieldOfView = 40
	cam.Parent = vp
	vp.CurrentCamera = cam
	vp:SetAttribute("ModelId", id)
	return vp
end

local function buildCells()
	for i, c in Config.ALL do
		local cell = Instance.new("TextButton")
		cell.Name = c.id
		cell.LayoutOrder = i
		cell.Text = ""
		cell.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		cell.AutoButtonColor = true
		cell.Parent = grid
		corner(cell, 12)
		local st = Instance.new("UIStroke")
		st.Thickness = 3
		st.Color = Config.RARITY[c.rarity].color
		st.Parent = cell
		local vp = makeViewport(cell, c.id)
		local unknown = Instance.new("TextLabel")
		unknown.Name = "Unknown"
		unknown.Size = UDim2.fromScale(1, 0.62)
		unknown.BackgroundColor3 = Color3.fromRGB(225, 220, 210)
		unknown.TextScaled = true
		unknown.Font = Enum.Font.FredokaOne
		unknown.TextColor3 = Color3.fromRGB(150, 140, 130)
		unknown.Text = "？"
		unknown.Parent = cell
		corner(unknown, 12)
		local name = Instance.new("TextLabel")
		name.Name = "Label"
		name.Size = UDim2.fromScale(1, 0.2)
		name.Position = UDim2.fromScale(0, 0.62)
		name.BackgroundTransparency = 1
		name.TextScaled = true
		name.TextWrapped = true
		name.Font = Enum.Font.FredokaOne
		name.TextColor3 = Color3.fromRGB(60, 45, 40)
		name.Text = c.name
		name.Parent = cell
		local countL = Instance.new("TextLabel")
		countL.Name = "Count"
		countL.Size = UDim2.fromScale(0.5, 0.16)
		countL.Position = UDim2.fromScale(0.02, 0.82)
		countL.BackgroundTransparency = 1
		countL.TextScaled = true
		countL.Font = Enum.Font.FredokaOne
		countL.TextColor3 = Config.RARITY[c.rarity].color
		countL.TextXAlignment = Enum.TextXAlignment.Left
		countL.Parent = cell
		local sell = Instance.new("TextButton")
		sell.Name = "Sell"
		sell.Size = UDim2.fromScale(0.46, 0.15)
		sell.Position = UDim2.fromScale(0.52, 0.83)
		sell.BackgroundColor3 = Color3.fromRGB(240, 180, 60)
		sell.TextColor3 = Color3.fromRGB(60, 40, 20)
		sell.TextScaled = true
		sell.Font = Enum.Font.FredokaOne
		sell.Text = "おかえし ¥" .. Config.SELL_PRICE[c.rarity]
		sell.Visible = false
		sell.Parent = cell
		corner(sell, 8)
		sell.Activated:Connect(function()
			request:FireServer("sell", c.id)
		end)
		cell.Activated:Connect(function()
			if pickingSlot and inv and (inv.counts[c.id] or 0) > 0 then
				request:FireServer("place", pickingSlot, c.id)
				pickingSlot = nil
				panel.Visible = false
			end
		end)
		cells[c.id] = cell
	end
end

local function freeCount(id: string): number
	if not inv then
		return 0
	end
	local placed = 0
	for _, pid in inv.placed do
		if pid == id then
			placed += 1
		end
	end
	return (inv.counts[id] or 0) - placed
end

local function refresh()
	if not inv then
		return
	end
	local have = 0
	for _, c in Config.ALL do
		local cell = cells[c.id]
		local n = inv.counts[c.id] or 0
		local owned = inv.collected[c.id] == true
		if owned then
			have += 1
		end
		cell.Unknown.Visible = not owned
		cell.Unknown.Text = c.secret and "？\nひみつ" or "？"
		cell.Label.Text = owned and c.name or (c.secret and "ひみつの子" or "？？？")
		cell.Count.Text = owned and ("× " .. n .. "  かざれる " .. freeCount(c.id)) or ""
		cell.Sell.Visible = owned and n >= 2 and not pickingSlot and not c.secret
	end
	title.Text = string.format("図鑑  Collection   %d / %d", have, #Config.ALL)
	if pickingSlot then
		hint.Text = "かざる子を えらんでね（かざれる数が 1 以上の子）  Pick one to display"
	else
		hint.Text = "たなの前で「かざる」を押すと ここから選べる。ダブりは「おかえし」でコインに"
	end
end

local function open(slot: number?)
	pickingSlot = slot
	inv = getInventory:InvokeServer()
	refresh()
	panel.Visible = true
end

buildCells()
gui:WaitForChild("Hud"):WaitForChild("ZukanButton").Activated:Connect(function()
	if panel.Visible then
		panel.Visible = false
		pickingSlot = nil
	else
		open(nil)
	end
end)
close.Activated:Connect(function()
	panel.Visible = false
	pickingSlot = nil
end)

event.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "pick" then
		open(tonumber(data))
	elseif kind == "inventory" then
		inv = data
		refresh()
	elseif kind == "got" or kind == "placed" then
		if panel.Visible then
			inv = getInventory:InvokeServer()
			refresh()
		end
	end
end)

-- 図鑑の子をゆっくり回す
RunService.RenderStepped:Connect(function(dt)
	if not panel.Visible then
		return
	end
	for _, cell in cells do
		local vp = cell:FindFirstChildOfClass("ViewportFrame")
		local world = vp and vp:FindFirstChildOfClass("WorldModel")
		local m = world and world:FindFirstChildOfClass("Model")
		if m then
			m:PivotTo(m:GetPivot() * CFrame.Angles(0, dt * 0.8, 0))
		end
	end
end)
