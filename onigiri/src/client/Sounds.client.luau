-- BGM と効果音（Roblox 公式ライブラリの無料音源）。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local event = ReplicatedStorage:WaitForChild("GameEvent")

local IDS = {
	bgm = 82270653809303,   -- Japanese Happy Moments（DistroKid）
	gacha = 9116394545,     -- キラキラ
	new = 1840076509,       -- ファンファーレ
	miss = 9120222115,      -- キュッ
	placed = 9126073001,    -- チーン
	coin = 9126267420,      -- ドン（ボーナス）
}
local function make(id: number, volume: number, looped: boolean?): Sound
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Volume = volume
	s.Looped = looped == true
	s.Parent = SoundService
	return s
end
local bgm = make(IDS.bgm, 0.3, true)
bgm:Play()
local sfx = {}
for _, k in { "gacha", "new", "miss", "placed", "coin" } do
	sfx[k] = make(IDS[k], 0.7)
end
local function play(k: string)
	sfx[k].TimePosition = 0
	sfx[k]:Play()
end

event.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "got" then
		play("gacha")
		if type(data) == "table" and data.isNew then
			task.delay(1.0, function()
				play("new")
			end)
		end
	elseif kind == "claw_miss" then
		play("miss")
	elseif kind == "placed" then
		play("placed")
	elseif kind == "daily" or kind == "ur" then
		play("coin")
	end
end)
