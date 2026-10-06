-- BGM と効果音。担いでいる間は祭り囃子。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local event = ReplicatedStorage:WaitForChild("GameEvent")
local player = Players.LocalPlayer

-- Roblox 公式ライブラリの無料音源（1 本目と同じ提供元）
local IDS = {
	bgm = 1842506077,      -- Kawachi Ondo（お祭り）
	festival = 1842506077, -- 担いでいる間（同じ曲を速く・大きく）
	buy = 9126073001,      -- チーン
	place = 9116394545,    -- キラキラ
	hit = 9120222115,      -- キュッ（かかし）
	stolen = 9125585534,   -- 銅鑼
	lock = 9126267420,     -- ドン
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
for _, k in { "buy", "place", "hit", "stolen", "lock" } do
	sfx[k] = make(IDS[k], 0.7)
end
local function play(k: string)
	sfx[k].TimePosition = 0
	sfx[k]:Play()
end

-- 担いでいる間は曲を速く・大きく（お祭り感）
local function updateCarry()
	if player:GetAttribute("Carrying") then
		bgm.PlaybackSpeed = 1.15
		bgm.Volume = 0.55
	else
		bgm.PlaybackSpeed = 1
		bgm.Volume = 0.3
	end
end
updateCarry()
player:GetAttributeChangedSignal("Carrying"):Connect(updateCarry)

event.OnClientEvent:Connect(function(kind: string)
	if kind == "bought" then
		play("buy")
	elseif kind == "placed" or kind == "returned" then
		play("place")
	elseif kind == "kakashi" then
		play("hit")
	elseif kind == "stolen" or kind == "lost" then
		play("stolen")
	elseif kind == "locked" then
		play("lock")
	end
end)
