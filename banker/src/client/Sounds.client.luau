-- 効果音（Roblox 公式ライブラリの無料音源。おにぎりーずで確認済みの ID）
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local event = ReplicatedStorage:WaitForChild("GameEvent")

local IDS = {
	sparkle = 9116394545, -- キラキラ（レベルアップ・名刺・電卓）
	fanfare = 1840076509, -- ファンファーレ（試験合格・昇進・帰還）
	miss = 9120222115, -- キュッ（かわした・罠）
	pick = 9126073001, -- チーン（拾う・階段）
	hit = 9126267420, -- ドン（攻撃）
}
local sfx = {}
for k, id in IDS do
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Volume = 0.6
	s.Parent = SoundService
	sfx[k] = s
end
local last = {}
local function play(k: string, vol: number?)
	-- 同じ音が 1 フレームに何度も鳴らないように
	if last[k] and os.clock() - last[k] < 0.08 then
		return
	end
	last[k] = os.clock()
	sfx[k].Volume = vol or 0.6
	sfx[k].TimePosition = 0
	sfx[k]:Play()
end

event.OnClientEvent:Connect(function(kind, data)
	if kind == "run" then
		for _, e in data.events do
			if e.t == "hit" then
				play("hit", e.target == "player" and 0.8 or 0.5)
			elseif e.t == "miss" or e.t == "trap" then
				play("miss")
			elseif e.t == "pickup" or e.t == "floor" then
				play("pick")
			elseif e.t == "levelup" or e.t == "card" or e.t == "beam" then
				play("sparkle")
			elseif e.t == "exam_clear" then
				play("fanfare", 0.8)
			elseif e.t == "end" and e.result ~= "dead" then
				play("fanfare", 0.8)
			end
		end
	elseif kind == "dialog" and data.tag and string.sub(data.tag, 1, 4) == "rank" then
		play("fanfare", 0.8)
	elseif kind == "toast" then
		play("pick", 0.4)
	end
end)
