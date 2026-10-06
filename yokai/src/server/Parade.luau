-- 百鬼夜行。広場の輪の上を妖怪が練り歩く。値札つきで、買える。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Designs = require(script.Parent.Yokai.Designs)

local Parade = {}

local folder = Instance.new("Folder")
folder.Name = "Parade"
folder.Parent = workspace

local walkers = {} -- { model, angle, def, gold, prompt }
local onBuy: (Player, any) -> boolean = function() return false end

local byId = {}
for _, d in Config.YOKAI do
	byId[d.id] = d
end
Parade.byId = byId

local function pickDef()
	local roll = math.random() * 100
	local acc = 0
	local rarity = "common"
	for _, r in { "common", "rare", "legend" } do
		acc += Config.PARADE_RARITY_WEIGHTS[r]
		if roll <= acc then
			rarity = r
			break
		end
	end
	local pool = {}
	for _, d in Config.YOKAI do
		if d.rarity == rarity then
			table.insert(pool, d)
		end
	end
	return pool[math.random(#pool)]
end

local function posAt(angle: number): Vector3
	return Vector3.new(math.sin(angle) * Config.PARADE_RADIUS, 0, math.cos(angle) * Config.PARADE_RADIUS)
end

-- 値札（名前と値段）
local function priceTag(root: BasePart, def, gold: boolean)
	local bb = Instance.new("BillboardGui")
	bb.Name = "Tag"
	bb.Size = UDim2.fromOffset(170, 56)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.MaxDistance = 70
	bb.AlwaysOnTop = true
	bb.Parent = root
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
	frame.BackgroundTransparency = 0.25
	frame.Parent = bb
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	local name = Instance.new("TextLabel")
	name.Size = UDim2.fromScale(1, 0.5)
	name.BackgroundTransparency = 1
	name.TextScaled = true
	name.Font = Enum.Font.FredokaOne
	name.TextColor3 = gold and Config.RARITY.god.color or Config.RARITY[def.rarity].color
	name.Text = (gold and "✨" or "") .. def.name .. " " .. def.nameEn
	name.Parent = frame
	local price = Instance.new("TextLabel")
	price.Size = UDim2.fromScale(1, 0.5)
	price.Position = UDim2.fromScale(0, 0.5)
	price.BackgroundTransparency = 1
	price.TextScaled = true
	price.Font = Enum.Font.FredokaOne
	price.TextColor3 = Color3.fromRGB(255, 220, 120)
	price.Text = "¥" .. def.price .. "  +" .. (def.income * (gold and Config.GOLD_MULTIPLIER or 1)) .. "/s"
	price.Parent = frame
end

local function spawnOne()
	local def = pickDef()
	local gold = math.random() < Config.GOLD_CHANCE
	local angle = 0
	local model = Designs.build(def.id, CFrame.lookAt(posAt(angle), posAt(angle + 0.1)), folder)
	if gold then
		Designs.paintGold(model)
	end
	local root = model.PrimaryPart :: BasePart
	priceTag(root, def, gold)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "買う / Buy ¥" .. def.price
	prompt.ObjectText = def.name
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 9
	prompt.RequiresLineOfSight = false
	prompt.Parent = root
	local w = { model = model, angle = angle, def = def, gold = gold, prompt = prompt }
	prompt.Triggered:Connect(function(player)
		if w.sold then
			return
		end
		if onBuy(player, w) then
			w.sold = true
			local i = table.find(walkers, w)
			if i then
				table.remove(walkers, i)
			end
		end
	end)
	table.insert(walkers, w)
end

-- 買われたときに呼ぶ処理を登録する。true を返したら行列から外す
function Parade.onBuy(fn)
	onBuy = fn
end

function Parade.start()
	task.spawn(function()
		while true do
			if #walkers < Config.PARADE_MAX then
				spawnOne()
			end
			task.wait(Config.PARADE_SPAWN_EVERY)
		end
	end)
	RunService.Heartbeat:Connect(function(dt)
		local step = Config.PARADE_SPEED / Config.PARADE_RADIUS * dt
		for i = #walkers, 1, -1 do
			local w = walkers[i]
			w.angle += step
			-- 行列の進む向きに体を向ける。少し上下にゆれる
			local bob = math.sin(os.clock() * 6 + i) * 0.12
			w.model:PivotTo(CFrame.lookAt(posAt(w.angle) + Vector3.new(0, 1.8 + bob, 0), posAt(w.angle + 0.05) + Vector3.new(0, 1.8 + bob, 0)))
			if w.angle > math.pi * 2 * Config.PARADE_LAPS then
				w.model:Destroy()
				table.remove(walkers, i)
			end
		end
	end)
end

return Parade
