-- BGM と効果音。サーバーからの合図（GameEvent）に合わせて鳴らす。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remote = ReplicatedStorage:WaitForChild("GameEvent")
local player = Players.LocalPlayer

local function makeSound(id: number, volume: number, looped: boolean?): Sound
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Volume = volume
	s.Looped = looped == true
	s.Parent = SoundService
	return s
end

-- BGM はステージごとに 1 曲。ステージが変わったら入れ替える
local bgms = {}
for stageKey, id in Config.SOUNDS.bgm do
	bgms[stageKey] = makeSound(id, Config.BGM_VOLUME, true)
end
local current: Sound? = nil

local function fadeTo(s: Sound, volume: number, seconds: number)
	TweenService:Create(s, TweenInfo.new(seconds), { Volume = volume }):Play()
end

local function updateBgm()
	local key = ReplicatedStorage:GetAttribute("StageKey")
	local nextBgm = key and bgms[key]
	-- むずかしいモードは少し速く
	local speed = ReplicatedStorage:GetAttribute("Mode") == "hard" and 1.08 or 1
	if nextBgm ~= current then
		if current then
			current:Stop()
		end
		current = nextBgm
		if current then
			current.Volume = Config.BGM_VOLUME
			current:Play()
		end
	end
	if current then
		current.PlaybackSpeed = speed
	end
end
updateBgm()
ReplicatedStorage:GetAttributeChangedSignal("StageKey"):Connect(updateBgm)
ReplicatedStorage:GetAttributeChangedSignal("Mode"):Connect(updateBgm)

local sfx = {}
for _, name in { "turn", "away", "wink", "caught", "rescue", "win", "lose" } do
	sfx[name] = makeSound(Config.SOUNDS[name], Config.SFX_VOLUME)
end
local function play(name: string, volume: number?)
	local s = sfx[name]
	s.Volume = volume or Config.SFX_VOLUME
	s.TimePosition = 0
	s:Play()
end

remote.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "look" then
		play("turn")
		if current then
			fadeTo(current, Config.BGM_VOLUME_LOOK, 0.3)
		end
	elseif kind == "safe" then
		play("away", 0.5)
		if current then
			fadeTo(current, Config.BGM_VOLUME, 0.8)
		end
	elseif kind == "wink" then
		play("wink")
	elseif kind == "caught" then
		-- 自分が捕まったときは大きく、他の人のときは小さく
		play("caught", data == player.Name and 1 or 0.4)
	elseif kind == "rescued" or kind == "respawned" then
		if data == player.Name then
			play("rescue")
		end
	elseif kind == "win" then
		play("win", 1)
		if current then
			fadeTo(current, Config.BGM_VOLUME, 0.5)
		end
	elseif kind == "lose" then
		play("lose", 0.8)
	end
end)
