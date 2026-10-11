-- コントローラー（PS5 / Xbox）でメニューを操作できるようにする。
-- 持ち物・売店・結果・会話・オフィスの売店/持ち物/ロッカーが開いたら、最初のボタンを選択状態にする。
-- スティック/十字キーで選んで ×(A) で決定、○(B) で閉じる。全部閉じたら選択を外す（塔の中で歩けるように）。
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- { ScreenGui の名前, フレームの名前 }（上ほど優先）
local PANELS = {
	{ "RunUI", "Result" },
	{ "OfficeUI", "Dialog" },
	{ "RunUI", "Inventory" },
	{ "RunUI", "Shop" },
	{ "OfficeUI", "Shop" },
	{ "OfficeUI", "Bag" },
	{ "OfficeUI", "Locker" },
}

local function usingGamepad(): boolean
	local t = UserInputService:GetLastInputType()
	return t == Enum.UserInputType.Gamepad1 or t == Enum.UserInputType.Gamepad2 or UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled
end

local function visible(obj: GuiObject): boolean
	local o: Instance? = obj
	while o and o:IsA("GuiObject") do
		if not o.Visible then
			return false
		end
		o = o.Parent
	end
	if o and o:IsA("ScreenGui") and not o.Enabled then
		return false
	end
	return true
end

local function openPanel(): GuiObject?
	for _, p in PANELS do
		local sg = gui:FindFirstChild(p[1])
		local f = sg and sg:FindFirstChild(p[2])
		if f and f:IsA("GuiObject") and visible(f) then
			return f
		end
	end
	return nil
end

-- パネルの中で最初に押せるボタン（× の閉じるボタンは後回し）
local function firstButton(f: GuiObject): GuiButton?
	local closeBtn = nil
	for _, d in f:GetDescendants() do
		if d:IsA("GuiButton") and d.Selectable and visible(d) then
			if d:IsA("TextButton") and d.Text == "×" then
				closeBtn = closeBtn or d
			else
				return d
			end
		end
	end
	return closeBtn
end

local function closeButton(f: GuiObject): GuiButton?
	for _, d in f:GetDescendants() do
		if d:IsA("TextButton") and d.Text == "×" and visible(d) then
			return d
		end
	end
	return nil
end

local lastPanel: GuiObject? = nil
RunService.RenderStepped:Connect(function()
	local f = openPanel()
	if f then
		local sel = GuiService.SelectedObject
		local inside = sel ~= nil and sel:IsDescendantOf(f) and visible(sel)
		if (f ~= lastPanel or not inside) and usingGamepad() then
			GuiService.SelectedObject = firstButton(f)
		end
	elseif lastPanel then
		GuiService.SelectedObject = nil
	end
	lastPanel = f
end)

-- ○(B): 開いているパネルを閉じる（会話は次へ進む）
ContextActionService:BindActionAtPriority("BankerBack", function(_, state)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local f = openPanel()
	if not f then
		return Enum.ContextActionResult.Pass
	end
	if f.Name == "Dialog" or f.Name == "Result" then
		-- 会話・結果は「決定」と同じ（選択中のボタンを押す）
		return Enum.ContextActionResult.Pass
	end
	local c = closeButton(f)
	if c then
		f.Visible = false
	end
	return Enum.ContextActionResult.Sink
end, false, 3000, Enum.KeyCode.ButtonB)
