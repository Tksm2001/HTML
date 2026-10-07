-- BGM。オフィス / 塔 / ボス（取締役会）を場面で切り替え、クロスフェードする。
-- 曲は MiniMax-Music3 で自作（publish/bgm/*.wav）。Roblox にアップロードした ID を TRACKS に入れる。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local event = ReplicatedStorage:WaitForChild("GameEvent")

local TRACKS = {
	office = { id = "", volume = 0.35 },
	tower = { id = "", volume = 0.3 },
	boss = { id = "", volume = 0.4 },
}

local sounds: { [string]: Sound } = {}
for name, t in TRACKS do
	if t.id ~= "" then
		local s = Instance.new("Sound")
		s.Name = "BGM_" .. name
		s.SoundId = t.id
		s.Looped = true
		s.Volume = 0
		s.Parent = SoundService
		sounds[name] = s
	end
end

local current: string? = nil
local function play(name: string)
	if current == name then
		return
	end
	local prev = current and sounds[current]
	current = name
	local nxt = sounds[name]
	if prev then
		local tw = TweenService:Create(prev, TweenInfo.new(1.2), { Volume = 0 })
		tw:Play()
		tw.Completed:Once(function()
			if current ~= name or prev ~= sounds[current] then
				prev:Stop()
			end
		end)
	end
	if nxt then
		if not nxt.IsPlaying then
			nxt.Volume = 0
			nxt:Play()
		end
		TweenService:Create(nxt, TweenInfo.new(1.5), { Volume = TRACKS[name].volume }):Play()
	end
end

event.OnClientEvent:Connect(function(kind, data)
	if kind == "run" then
		if data.floor >= Config.BOSS_FLOOR then
			play("boss")
		else
			play("tower")
		end
	elseif kind == "runEnd" then
		play("office")
	end
end)

task.delay(1, function()
	play("office")
end)
