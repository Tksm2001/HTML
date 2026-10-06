-- 神社（拠点）の持ち主、台座に置かれた妖怪、結界、お賽銭の収入。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Village = require(script.Parent.Village)
local Designs = require(script.Parent.Yokai.Designs)

local Shrines = {}
local village = nil
local plotOf: { [Player]: any } = {}

function Shrines.init(v)
	village = v
	for _, plot in village.Plots do
		plot.Barrier:SetAttribute("Locked", false)
	end
end

function Shrines.plotOf(player: Player)
	return plotOf[player]
end

function Shrines.plotAt(pos: Vector3)
	for _, plot in village.Plots do
		if Village.isInside(plot, pos) then
			return plot
		end
	end
	return nil
end

local function setNamePlate(plot, text: string)
	local gui = plot.NamePlate:FindFirstChildOfClass("SurfaceGui")
	local label = gui and gui:FindFirstChildOfClass("TextLabel")
	if label then
		label.Text = text
	end
end

-- 入ってきた人に空いている神社を割り当てる
function Shrines.assign(player: Player)
	for _, plot in village.Plots do
		if plot.Owner == nil then
			plot.Owner = player
			plot.ProtectedUntil = os.clock() + Config.NEWBIE_PROTECT_SECONDS
			plotOf[player] = plot
			setNamePlate(plot, player.DisplayName .. " 神社")
			player:SetAttribute("Plot", plot.Index)
			return plot
		end
	end
	return nil
end

function Shrines.release(player: Player)
	local plot = plotOf[player]
	if not plot then
		return
	end
	for _, ped in plot.Pedestals do
		if ped.Yokai then
			ped.Yokai.model:Destroy()
			ped.Yokai = nil
			ped.Ring.Transparency = 1
		end
	end
	plot.Owner = nil
	plot.ProtectedUntil = 0
	setNamePlate(plot, "")
	plotOf[player] = nil
end

-- 空いている台座
function Shrines.freePedestal(plot)
	for s = 1, plot.PedestalCount do
		local ped = plot.Pedestals[s]
		if ped and ped.Yokai == nil then
			return ped, s
		end
	end
	return nil
end

-- 妖怪を台座に置く。yokai = { def, gold, model }
function Shrines.place(plot, slot: number, yokai)
	local ped = plot.Pedestals[slot]
	ped.Yokai = yokai
	yokai.model.Parent = plot.Folder
	yokai.model:PivotTo(ped.SeatCFrame * CFrame.new(0, 1.8, 0))
	for _, p in yokai.model:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
		end
	end
	ped.Ring.Color = yokai.gold and Config.RARITY.god.color or Config.RARITY[yokai.def.rarity].color
	ped.Ring.Transparency = 0.3
	yokai.model:SetAttribute("Plot", plot.Index)
	yokai.model:SetAttribute("Slot", slot)
end

function Shrines.take(plot, slot: number)
	local ped = plot.Pedestals[slot]
	local y = ped.Yokai
	ped.Yokai = nil
	ped.Ring.Transparency = 1
	return y
end

-- 1 秒あたりの収入
function Shrines.income(plot): number
	local total = 0
	for _, ped in plot.Pedestals do
		if ped.Yokai then
			total += ped.Yokai.def.income * (ped.Yokai.gold and Config.GOLD_MULTIPLIER or 1)
		end
	end
	return total
end

function Shrines.isLocked(plot): boolean
	return os.clock() < plot.LockedUntil
end

function Shrines.isProtected(plot): boolean
	return os.clock() < (plot.ProtectedUntil or 0)
end

-- 結界を閉める。戻り値: 閉められたか
function Shrines.lock(plot): boolean
	if os.clock() < plot.LockReadyAt then
		return false
	end
	plot.LockedUntil = os.clock() + Config.LOCK_SECONDS
	plot.LockReadyAt = os.clock() + Config.LOCK_COOLDOWN
	plot.Barrier.Transparency = 0.4
	plot.Barrier.CanCollide = true
	plot.Barrier:SetAttribute("Locked", true)
	task.delay(Config.LOCK_SECONDS, function()
		if os.clock() >= plot.LockedUntil then
			plot.Barrier.Transparency = 1
			plot.Barrier.CanCollide = false
			plot.Barrier:SetAttribute("Locked", false)
		end
	end)
	return true
end

-- 台座を増やす。戻り値: 値段（増やせないときは nil）
function Shrines.nextUpgrade(plot)
	for _, u in Config.PEDESTAL_UPGRADES do
		if u.count > plot.PedestalCount then
			return u
		end
	end
	return nil
end

function Shrines.upgrade(plot)
	local u = Shrines.nextUpgrade(plot)
	if not u then
		return
	end
	for s = plot.PedestalCount + 1, u.count do
		Village.buildPedestal(plot, s)
	end
	plot.PedestalCount = u.count
end

-- 保存用: 置いてある妖怪の一覧
function Shrines.serialize(plot)
	local list = {}
	for s, ped in plot.Pedestals do
		if ped.Yokai then
			table.insert(list, { id = ped.Yokai.def.id, gold = ped.Yokai.gold, slot = s })
		end
	end
	return list
end

-- 保存から復元
function Shrines.restore(plot, list, byId)
	for _, e in list do
		local def = byId[e.id]
		local slot = e.slot
		if def and slot <= plot.PedestalCount and plot.Pedestals[slot].Yokai == nil then
			local model = Designs.build(def.id, CFrame.new(), plot.Folder)
			if e.gold then
				Designs.paintGold(model)
			end
			Shrines.place(plot, slot, { def = def, gold = e.gold == true, model = model })
		end
	end
end

return Shrines
