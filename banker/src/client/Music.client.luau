-- BGM。オフィス / 塔（章ごとに 6 曲）/ ボス（取締役会）を場面で切り替え、クロスフェードする。
-- 曲は MiniMax-Music3 で自作（publish/bgm/*.wav）。Roblox にアップロードした ID を TRACKS に入れる。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local event = ReplicatedStorage:WaitForChild("GameEvent")

local TRACKS = {
	office = { id = "rbxassetid://83067380452905", volume = 0.35 }, -- bgm_office
	rookie = { id = "rbxassetid://76425901272693", volume = 0.3 }, -- bgm_tower（1〜4F 新人フロア）
	sales = { id = "rbxassetid://130807154758191", volume = 0.3 }, -- bgm_sales（5〜9F）
	meeting = { id = "rbxassetid://77719614994821", volume = 0.3 }, -- bgm_meeting（10〜14F）
	vault = { id = "rbxassetid://102621193967324", volume = 0.3 }, -- bgm_vault（15〜19F）
	exec = { id = "rbxassetid://88875132839728", volume = 0.3 }, -- bgm_exec（20〜24F）
	dark = { id = "rbxassetid://139704837121609", volume = 0.32 }, -- bgm_dark（25〜29F）
	boss = { id = "rbxassetid://131102793368653", volume = 0.4 }, -- bgm_boss（30F 取締役会）
}

-- 章の始まりの階 → 曲
local CHAPTER_TRACK = { [1] = "rookie", [5] = "sales", [10] = "meeting", [15] = "vault", [20] = "exec", [25] = "dark", [30] = "boss" }

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
	if prev and prev ~= nxt then
		local tw = TweenService:Create(prev, TweenInfo.new(1.2), { Volume = 0 })
		tw:Play()
		tw.Completed:Once(function()
			if sounds[current or ""] ~= prev then
				prev:Stop()
			end
		end)
	end
	if nxt then
		if not nxt.IsPlaying then
			nxt.Volume = 0
			nxt.TimePosition = 0
			nxt:Play()
		end
		TweenService:Create(nxt, TweenInfo.new(1.5), { Volume = TRACKS[name].volume }):Play()
	end
end

local function trackForFloor(floor: number): string
	local ch = Config.chapterFor(floor)
	return CHAPTER_TRACK[ch.from] or "rookie"
end

event.OnClientEvent:Connect(function(kind, data)
	if kind == "run" then
		play(trackForFloor(data.floor))
	elseif kind == "runEnd" then
		play("office")
	end
end)

task.delay(1, function()
	play("office")
end)
