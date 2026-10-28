--[[
    HelloHub UI Library  |  v1.2.0 (Pretty Edition)
    ------------------------------------------------------------
    ปรับปรุงหน้าตา: เงาลึก, มุมโค้งนุ่ม, gradient, อนิเมชันสมูธขึ้น
    API เดิมใช้ได้ทั้งหมด 100%
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UIS              = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")

local HelloHub = {
	Version = "1.2.0",
	Flags   = {},
}

----------------------------------------------------------------
-- THEMES (ปรับให้พรีเมียมขึ้น: accent สว่าง, bg ลึกนุ่ม)
----------------------------------------------------------------
HelloHub.Themes = {
	Hello = {
		Background  = Color3.fromRGB(20, 14, 30),
		Topbar      = Color3.fromRGB(32, 22, 46),
		Sidebar     = Color3.fromRGB(24, 16, 36),
		Element     = Color3.fromRGB(40, 30, 56),
		ElementHover= Color3.fromRGB(56, 42, 78),
		Accent      = Color3.fromRGB(255, 115, 195),
		Accent2     = Color3.fromRGB(160, 105, 255),
		Text        = Color3.fromRGB(255, 255, 255),
		SubText     = Color3.fromRGB(200, 185, 220),
		Stroke      = Color3.fromRGB(80, 60, 112),
		Shadow      = Color3.fromRGB(0, 0, 0),
	},
	Ocean = {
		Background  = Color3.fromRGB(10, 20, 32),
		Topbar      = Color3.fromRGB(16, 32, 50),
		Sidebar     = Color3.fromRGB(12, 26, 40),
		Element     = Color3.fromRGB(24, 44, 66),
		ElementHover= Color3.fromRGB(36, 62, 92),
		Accent      = Color3.fromRGB(0, 200, 255),
		Accent2     = Color3.fromRGB(100, 130, 255),
		Text        = Color3.fromRGB(255, 255, 255),
		SubText     = Color3.fromRGB(170, 200, 225),
		Stroke      = Color3.fromRGB(45, 80, 120),
		Shadow      = Color3.fromRGB(0, 0, 0),
	},
	Mint = {
		Background  = Color3.fromRGB(10, 24, 22),
		Topbar      = Color3.fromRGB(16, 38, 34),
		Sidebar     = Color3.fromRGB(14, 30, 28),
		Element     = Color3.fromRGB(24, 52, 46),
		ElementHover= Color3.fromRGB(36, 74, 66),
		Accent      = Color3.fromRGB(70, 245, 180),
		Accent2     = Color3.fromRGB(90, 210, 255),
		Text        = Color3.fromRGB(255, 255, 255),
		SubText     = Color3.fromRGB(170, 220, 205),
		Stroke      = Color3.fromRGB(45, 100, 85),
		Shadow      = Color3.fromRGB(0, 0, 0),
	},
	Sunset = {
		Background  = Color3.fromRGB(30, 16, 16),
		Topbar      = Color3.fromRGB(46, 24, 22),
		Sidebar     = Color3.fromRGB(36, 20, 18),
		Element     = Color3.fromRGB(62, 36, 30),
		ElementHover= Color3.fromRGB(84, 50, 40),
		Accent      = Color3.fromRGB(255, 140, 70),
		Accent2     = Color3.fromRGB(255, 80, 130),
		Text        = Color3.fromRGB(255, 255, 255),
		SubText     = Color3.fromRGB(230, 190, 175),
		Stroke      = Color3.fromRGB(115, 70, 55),
		Shadow      = Color3.fromRGB(0, 0, 0),
	},
	Christmas = {
		Animation   = "snow",
		Background  = Color3.fromRGB(18, 38, 45),
		Topbar      = Color3.fromRGB(25, 52, 58),
		Sidebar     = Color3.fromRGB(15, 32, 38),
		Element     = Color3.fromRGB(30, 64, 68),
		ElementHover= Color3.fromRGB(44, 92, 88),
		Accent      = Color3.fromRGB(228, 65, 78),
		Accent2     = Color3.fromRGB(215, 190, 90),
		Text        = Color3.fromRGB(248, 255, 248),
		SubText     = Color3.fromRGB(180, 220, 208),
		Stroke      = Color3.fromRGB(30, 135, 105),
		Shadow      = Color3.fromRGB(0, 0, 0),
	},
	Valentine = {
		Animation   = "hearts",
		Background  = Color3.fromRGB(48, 20, 36),
		Topbar      = Color3.fromRGB(64, 26, 48),
		Sidebar     = Color3.fromRGB(34, 14, 28),
		Element     = Color3.fromRGB(78, 32, 58),
		ElementHover= Color3.fromRGB(108, 44, 80),
		Accent      = Color3.fromRGB(255, 95, 155),
		Accent2     = Color3.fromRGB(255, 180, 215),
		Text        = Color3.fromRGB(255, 244, 250),
		SubText     = Color3.fromRGB(230, 170, 200),
		Stroke      = Color3.fromRGB(185, 55, 115),
		Shadow      = Color3.fromRGB(0, 0, 0),
	},
	Summer = {
		Animation   = "bubbles",
		Background  = Color3.fromRGB(14, 52, 70),
		Topbar      = Color3.fromRGB(18, 66, 86),
		Sidebar     = Color3.fromRGB(10, 38, 54),
		Element     = Color3.fromRGB(22, 86, 100),
		ElementHover= Color3.fromRGB(32, 118, 130),
		Accent      = Color3.fromRGB(255, 205, 70),
		Accent2     = Color3.fromRGB(60, 215, 205),
		Text        = Color3.fromRGB(242, 255, 255),
		SubText     = Color3.fromRGB(155, 220, 230),
		Stroke      = Color3.fromRGB(25, 170, 190),
		Shadow      = Color3.fromRGB(0, 0, 0),
	},
	Halloween = {
		Animation   = "halloween",
		Background  = Color3.fromRGB(16, 8, 22),
		Topbar      = Color3.fromRGB(34, 16, 46),
		Sidebar     = Color3.fromRGB(24, 12, 32),
		Element     = Color3.fromRGB(50, 26, 66),
		ElementHover= Color3.fromRGB(70, 38, 90),
		Accent      = Color3.fromRGB(255, 135, 30),
		Accent2     = Color3.fromRGB(175, 105, 235),
		Text        = Color3.fromRGB(255, 245, 215),
		SubText     = Color3.fromRGB(215, 180, 230),
		Stroke      = Color3.fromRGB(105, 55, 150),
		Shadow      = Color3.fromRGB(0, 0, 0),
	},
	Dark = {
		Background  = Color3.fromRGB(18, 18, 22),
		Topbar      = Color3.fromRGB(26, 26, 32),
		Sidebar     = Color3.fromRGB(22, 22, 28),
		Element     = Color3.fromRGB(34, 34, 42),
		ElementHover= Color3.fromRGB(50, 50, 60),
		Accent      = Color3.fromRGB(240, 240, 245),
		Accent2     = Color3.fromRGB(165, 165, 180),
		Text        = Color3.fromRGB(255, 255, 255),
		SubText     = Color3.fromRGB(180, 180, 195),
		Stroke      = Color3.fromRGB(64, 64, 74),
		Shadow      = Color3.fromRGB(0, 0, 0),
	},
}

local function ResolveThemeName(n)
	if n == "Auto" then
		local ok, d = pcall(os.date, "*t")
		if ok and type(d) == "table" and d.month == 10 and d.day >= 6 and d.day <= 30 then
			return "Halloween"
		end
		return "Hello"
	end
	if type(n) == "string" and HelloHub.Themes[n] then return n end
	return nil
end

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------
local function New(class, props, children)
	local o = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else o[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = o end
	if parent then o.Parent = parent end
	return o
end

local function Tween(obj, props, t, style, dir)
	TweenService:Create(obj, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
end

local function Corner(r) return New("UICorner", {CornerRadius = UDim.new(0, r or 8)}) end

-- เงานุ่ม (Drop Shadow) — ยกระดับวัตถุให้ดูลอย
local function Shadow(obj, color, transparency, thickness)
	return New("UIStroke", {
		Color = color or Color3.fromRGB(0, 0, 0),
		Transparency = transparency or 0.7,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = obj,
	})
end

local function ProtectGui(gui)
	local ok = pcall(function()
		gui.Parent = (gethui and gethui()) or CoreGui
	end)
	if not ok or not gui.Parent then
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
end

local function Bind(win, obj, prop, key)
	obj[prop] = win.Theme[key]
	table.insert(win._bound, {obj, prop, key})
end

local function OnRefresh(win, fn)
	table.insert(win._refresh, fn)
	fn(true)
end

local function Label(win, parent, text, size, key, align)
	local l = New("TextLabel", {
		BackgroundTransparency = 1,
		Text = text or "",
		Font = Enum.Font.GothamMedium,
		TextSize = size or 13,
		TextXAlignment = align or Enum.TextXAlignment.Left,
		Parent = parent,
	})
	Bind(win, l, "TextColor3", key or "Text")
	return l
end

local function AccentGradient(win, parent, rotation)
	local g = New("UIGradient", {Rotation = rotation or 0, Parent = parent})
	OnRefresh(win, function()
		g.Color = ColorSequence.new(win.Theme.Accent, win.Theme.Accent2)
	end)
	return g
end

-- การ์ด element (มี gradient overlay บางๆ + stroke + hover)
local function Row(win, page, height)
	local f = New("Frame", {
		Size = UDim2.new(1, 0, 0, height or 36),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = page,
	}, {Corner(9)})
	Bind(win, f, "BackgroundColor3", "Element")
	local stroke = New("UIStroke", {Thickness = 1, Transparency = 0.35, Parent = f})
	Bind(win, stroke, "Color", "Stroke")

	-- ไฮไลต์จางด้านบน (ให้ดูมีมิติ)
	local hl = New("Frame", {
		Size = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		Parent = f,
	}, {Corner(9)})
	New("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.0),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Parent = hl,
	})
	hl.ZIndex = 0

	if win._rows then
		table.insert(win._rows, f)
		if win.BgImage and win.BgImage.Visible then f.BackgroundTransparency = HelloHub.Glass.Card end
	end
	return f, stroke
end

local function SetFlag(o, value)
	if o.Flag then HelloHub.Flags[o.Flag] = value end
end

----------------------------------------------------------------
-- TAB
----------------------------------------------------------------
local Tab = {}
Tab.__index = Tab

function Tab:AddSection(name)
	local win = self.Win
	local wrap = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = self.Page,
	})
	local bar = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(3, 14),
		BorderSizePixel = 0,
		Parent = wrap,
	}, {Corner(2)})
	AccentGradient(win, bar, 90)
	local l = Label(win, wrap, string.upper(name), 11, "Accent")
	l.Font = Enum.Font.GothamBold
	l.Position = UDim2.fromOffset(10, 0)
	l.Size = UDim2.new(1, -10, 1, 0)
	return l
end

function Tab:AddLabel(text)
	local win = self.Win
	local row = Row(win, self.Page, 30)
	local l = Label(win, row, text, 13, "SubText")
	l.Position = UDim2.fromOffset(12, 0)
	l.Size = UDim2.new(1, -24, 1, 0)
	local obj = {}
	function obj:Set(t) l.Text = t end
	return obj
end

function Tab:AddButton(o)
	local win = self.Win
	local row = Row(win, self.Page, 36)
	local l = Label(win, row, o.Name or "Button", 13, "Text")
	l.Position = UDim2.fromOffset(12, 0)
	l.Size = UDim2.new(1, -24, 1, 0)
	l.Font = Enum.Font.GothamMedium
	local btn = New("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row})

	-- แถบ gradient ด้านซ้าย (โผล่ตอน hover)
	local accentBar = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(0, 20),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = row,
	}, {Corner(2)})
	AccentGradient(win, accentBar, 90)

	btn.MouseEnter:Connect(function()
		Tween(row, {BackgroundColor3 = win.Theme.ElementHover})
		Tween(accentBar, {Size = UDim2.fromOffset(3, 20), BackgroundTransparency = 0.05})
	end)
	btn.MouseLeave:Connect(function()
		Tween(row, {BackgroundColor3 = win.Theme.Element})
		Tween(accentBar, {Size = UDim2.fromOffset(0, 20), BackgroundTransparency = 0.3})
	end)
	btn.MouseButton1Click:Connect(function()
		Tween(row, {BackgroundColor3 = win.Theme.Accent}, 0.08)
		Tween(accentBar, {BackgroundTransparency = 0}, 0.08)
		task.delay(0.12, function()
			Tween(row, {BackgroundColor3 = win.Theme.ElementHover}, 0.25)
			Tween(accentBar, {BackgroundTransparency = 0.05}, 0.25)
		end)
		if o.Callback then task.spawn(o.Callback) end
	end)
end

function Tab:AddToggle(o)
	local win = self.Win
	local state = o.Default == true
	local row = Row(win, self.Page, 36)
	local l = Label(win, row, o.Name or "Toggle", 13, "Text")
	l.Position = UDim2.fromOffset(12, 0)
	l.Size = UDim2.new(1, -72, 1, 0)
	l.Font = Enum.Font.GothamMedium

	local track = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(42, 22), BorderSizePixel = 0, Parent = row,
	}, {Corner(11)})
	local trackStroke = New("UIStroke", {Thickness = 1, Transparency = 0.5, Parent = track})
	Bind(win, trackStroke, "Color", "Stroke")

	local knob = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16), BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1), Parent = track,
	}, {Corner(8)})
	-- เงาใต้ knob
	local knobShadow = New("UIStroke", {Color = Color3.fromRGB(0, 0, 0), Transparency = 0.75, Thickness = 1, Parent = knob})

	local function paint(instant)
		local t = instant and 0 or 0.22
		Tween(track, {BackgroundColor3 = state and win.Theme.Accent or win.Theme.Stroke}, t)
		Tween(knob, {Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, t, Enum.EasingStyle.Quint)
		knobShadow.Transparency = state and 0.4 or 0.75
	end
	OnRefresh(win, function() paint(true) end)

	local obj = {}
	function obj:Set(v, silent)
		state = v and true or false
		paint()
		SetFlag(o, state)
		if not silent and o.Callback then task.spawn(o.Callback, state) end
	end
	function obj:Get() return state end

	local btn = New("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row})
	btn.MouseButton1Click:Connect(function() obj:Set(not state) end)
	SetFlag(o, state)
	return obj
end

function Tab:AddSlider(o)
	local win = self.Win
	local min, max, inc = o.Min or 0, o.Max or 100, o.Increment or 1
	local value = math.clamp(o.Default or min, min, max)
	local row = Row(win, self.Page, 52)

	local l = Label(win, row, o.Name or "Slider", 13, "Text")
	l.Position = UDim2.fromOffset(12, 6)
	l.Size = UDim2.new(1, -100, 0, 20)
	l.Font = Enum.Font.GothamMedium
	local vl = Label(win, row, "", 12, "Accent", Enum.TextXAlignment.Right)
	vl.Position = UDim2.new(1, -100, 0, 6)
	vl.Size = UDim2.fromOffset(88, 20)
	vl.Font = Enum.Font.GothamBold

	local bar = New("Frame", {
		Position = UDim2.new(0, 12, 1, -16), Size = UDim2.new(1, -24, 0, 6),
		BorderSizePixel = 0, Parent = row,
	}, {Corner(3)})
	Bind(win, bar, "BackgroundColor3", "Stroke")
	local fill = New("Frame", {Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Parent = bar}, {Corner(3)})
	AccentGradient(win, fill)

	-- Thumb (หัวจับ)
	local thumb = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = bar,
	}, {Corner(7)})
	local thumbStroke = New("UIStroke", {Thickness = 2, Parent = thumb})
	Bind(win, thumbStroke, "Color", "Accent")

	local obj = {}
	local function render()
		local rel = (value - min) / math.max(max - min, 1e-9)
		fill.Size = UDim2.fromScale(rel, 1)
		thumb.Position = UDim2.new(rel, 0, 0.5, 0)
		vl.Text = tostring(value) .. (o.Suffix or "")
	end
	function obj:Set(v, silent)
		v = math.clamp(math.floor((v - min) / inc + 0.5) * inc + min, min, max)
		v = math.floor(v * 1000 + 0.5) / 1000
		value = v
		render()
		SetFlag(o, value)
		if not silent and o.Callback then task.spawn(o.Callback, value) end
	end
	function obj:Get() return value end

	local dragging = false
	local function fromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		obj:Set(min + (max - min) * rel)
	end
	local hit = New("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row})
	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			Tween(thumb, {Size = UDim2.fromOffset(18, 18)}, 0.12)
			fromX(i.Position.X)
		end
	end)
	table.insert(win._conns, UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			fromX(i.Position.X)
		end
	end))
	table.insert(win._conns, UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			if dragging then Tween(thumb, {Size = UDim2.fromOffset(14, 14)}, 0.15, Enum.EasingStyle.Back) end
			dragging = false
		end
	end))

	render()
	SetFlag(o, value)
	return obj
end

function Tab:AddDropdown(o)
	local win = self.Win
	local items = o.Items or {}
	local current = o.Default
	local open = false
	local ROW_H, ITEM_H = 36, 28

	local row = Row(win, self.Page, ROW_H)
	local l = Label(win, row, o.Name or "Dropdown", 13, "Text")
	l.Position = UDim2.fromOffset(12, 0)
	l.Size = UDim2.new(1, -150, 0, ROW_H)
	l.Font = Enum.Font.GothamMedium
	local vl = Label(win, row, tostring(current or "..."), 12, "SubText", Enum.TextXAlignment.Right)
	vl.Position = UDim2.new(1, -140, 0, 0)
	vl.Size = UDim2.fromOffset(115, ROW_H)
	local arrow = Label(win, row, "▾", 14, "Accent", Enum.TextXAlignment.Center)
	arrow.Position = UDim2.new(1, -24, 0, 0)
	arrow.Size = UDim2.fromOffset(16, ROW_H)
	arrow.Font = Enum.Font.GothamBold

	local listWrap = New("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(6, ROW_H + 2), Size = UDim2.new(1, -12, 1, -(ROW_H + 6)),
		ClipsDescendants = true, Parent = row,
	})
	local list = New("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 2, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = listWrap,
	}, {
		New("UIListLayout", {Padding = UDim.new(0, 3)}),
	})

	local buttons = {}
	local obj = {}

	local function paint()
		for name, b in pairs(buttons) do
			b.TextColor3 = (name == current) and win.Theme.Accent or win.Theme.SubText
		end
		vl.Text = tostring(current or "...")
	end
	OnRefresh(win, paint)

	local function setOpen(v)
		open = v
		local visible = math.min(#items, 5)
		Tween(row, {Size = UDim2.new(1, 0, 0, open and (ROW_H + 8 + visible * (ITEM_H + 3)) or ROW_H)},
			0.28, Enum.EasingStyle.Back)
		Tween(arrow, {Rotation = open and 180 or 0}, 0.28, Enum.EasingStyle.Quint)
	end

	function obj:Set(v, silent)
		current = v
		paint()
		SetFlag(o, current)
		if not silent and o.Callback then task.spawn(o.Callback, current) end
	end
	function obj:Get() return current end
	function obj:SetItems(newItems)
		items = newItems
		for _, b in pairs(buttons) do b:Destroy() end
		buttons = {}
		for _, name in ipairs(items) do
			local b = New("TextButton", {
				BackgroundColor3 = win.Theme.Element,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, ITEM_H),
				Font = Enum.Font.Gotham, TextSize = 12, Text = tostring(name),
				TextXAlignment = Enum.TextXAlignment.Left, Parent = list,
			}, {Corner(6), New("UIPadding", {PaddingLeft = UDim.new(0, 10)})})
			buttons[name] = b
			b.MouseEnter:Connect(function() Tween(b, {BackgroundColor3 = win.Theme.ElementHover}) end)
			b.MouseLeave:Connect(function() Tween(b, {BackgroundColor3 = win.Theme.Element}) end)
			b.MouseButton1Click:Connect(function()
				obj:Set(name)
				setOpen(false)
			end)
		end
		paint()
		if open then setOpen(true) end
	end

	local head = New("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, ROW_H), Parent = row})
	head.MouseButton1Click:Connect(function() setOpen(not open) end)

	obj:SetItems(items)
	SetFlag(o, current)
	return obj
end

function Tab:AddTextbox(o)
	local win = self.Win
	local row = Row(win, self.Page, 36)
	local l = Label(win, row, o.Name or "Textbox", 13, "Text")
	l.Position = UDim2.fromOffset(12, 0)
	l.Size = UDim2.new(1, -160, 1, 0)
	l.Font = Enum.Font.GothamMedium

	local box = New("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(140, 24), BorderSizePixel = 0,
		Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
		PlaceholderText = o.Placeholder or "...", Text = o.Default or "",
		Parent = row,
	}, {Corner(7)})
	Bind(win, box, "BackgroundColor3", "Background")
	Bind(win, box, "TextColor3", "Text")
	Bind(win, box, "PlaceholderColor3", "SubText")

	local boxStroke = New("UIStroke", {Thickness = 1, Transparency = 0.5, Parent = box})
	Bind(win, boxStroke, "Color", "Stroke")

	box.Focused:Connect(function()
		Tween(boxStroke, {Transparency = 0.05}, 0.15)
		OnRefresh(win, function()
			boxStroke.Color = win.Theme.Accent
		end)
	end)
	box.FocusLost:Connect(function(enter)
		Tween(boxStroke, {Transparency = 0.5}, 0.15)
		OnRefresh(win, function()
			boxStroke.Color = win.Theme.Stroke
		end)
		SetFlag(o, box.Text)
		if o.Callback then task.spawn(o.Callback, box.Text, enter) end
	end)
	SetFlag(o, box.Text)

	local obj = {}
	function obj:Set(t) box.Text = t SetFlag(o, t) end
	function obj:Get() return box.Text end
	return obj
end

function Tab:AddKeybind(o)
	local win = self.Win
	local key = o.Default or Enum.KeyCode.F
	local listening = false
	local row = Row(win, self.Page, 36)
	local l = Label(win, row, o.Name or "Keybind", 13, "Text")
	l.Position = UDim2.fromOffset(12, 0)
	l.Size = UDim2.new(1, -120, 1, 0)
	l.Font = Enum.Font.GothamMedium

	local btn = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(88, 24), BorderSizePixel = 0,
		Font = Enum.Font.GothamBold, TextSize = 12, Text = key.Name, Parent = row,
	}, {Corner(7)})
	Bind(win, btn, "BackgroundColor3", "Background")
	Bind(win, btn, "TextColor3", "Accent")

	local btnStroke = New("UIStroke", {Thickness = 1, Transparency = 0.5, Parent = btn})
	Bind(win, btnStroke, "Color", "Stroke")

	btn.MouseButton1Click:Connect(function()
		listening = true
		btn.Text = "..."
		OnRefresh(win, function()
			btnStroke.Color = win.Theme.Accent
			btnStroke.Transparency = 0.1
		end)
	end)
	table.insert(win._conns, UIS.InputBegan:Connect(function(i, gpe)
		if listening then
			if i.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				key = i.KeyCode
				btn.Text = key.Name
				OnRefresh(win, function()
					btnStroke.Color = win.Theme.Stroke
					btnStroke.Transparency = 0.5
				end)
				SetFlag(o, key)
				if o.Changed then task.spawn(o.Changed, key) end
			end
		elseif not gpe and i.KeyCode == key and i.UserInputType == Enum.UserInputType.Keyboard then
			if o.Callback then task.spawn(o.Callback) end
		end
	end))
	SetFlag(o, key)

	local obj = {}
	function obj:Get() return key end
	return obj
end

----------------------------------------------------------------
-- EFFECTS (ตัดส่วนเกินให้กระชับ คงเอนิเมชันที่ทำให้สวย)
----------------------------------------------------------------
HelloHub.FX = {
	Tint = true, Web = true, HeaderLine = true, TitleShine = true,
	Embers = true, Ghosts = true, Moon = true, Fog = true,
	Lightning = true, BorderPulse = true,
	ScreenIntro = true, ScreenIntroOnce = true, ScreenIntroTitle = true,
}

local function Tw(o, time, props, style, dir)
	local tw = TweenService:Create(o, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end
local function Round(o) New("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = o}) end
local function AddStroke(o, color, transp, thick)
	return New("UIStroke", {Color = color, Transparency = transp, Thickness = thick, Parent = o})
end
local function Emoji(text, props)
	props.BackgroundTransparency = 1
	props.Text = text
	props.Font = Enum.Font.GothamBold
	return New("TextLabel", props)
end
local function FxColors(t)
	return {
		Primary = t.Accent, Stroke1 = t.Stroke, Stroke2 = t.Accent,
		FxDark = t.Stroke, FxMid = t.Accent2, FxSilver = t.Accent,
		FxLight = t.Accent:Lerp(Color3.new(1, 1, 1), 0.45), FxWhite = t.Text,
		Text = t.Text, SubText = t.SubText, Background = t.Background, Sidebar = t.Sidebar,
	}
end

-- ฉากเปิด Halloween (เวอร์ชันย่อ — คงเอกลักษณ์แต่ลดโค้ด)
local function BuildScreenIntro(win, titleText, subText)
	local FX = HelloHub.FX
	if not FX.ScreenIntro then return end
	if FX.ScreenIntroOnce and HelloHub._introPlayed then return end
	HelloHub._introPlayed = true

	local C = FxColors(win.Theme)
	local Root = New("Frame", {Name = "HelloIntro", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 200, Parent = win.Gui})
	local function Alive() return Root:IsDescendantOf(game) end
	task.delay(10, function() if Root.Parent then Root:Destroy() end end)

	local Dim = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 2, 10), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 0, Parent = Root})
	local Moon = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.36, 0), Size = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.12, BorderSizePixel = 0, ZIndex = 2, Parent = Root,
	})
	Round(Moon)
	New("UIGradient", {Rotation = 90, Color = ColorSequence.new(C.FxLight, C.FxSilver), Parent = Moon})
	local Halo = AddStroke(Moon, C.FxLight, 0.78, 20)

	local Flash = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(240, 230, 255), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 6, Parent = Root})

	local function Crow(delay, y, size, dur)
		task.delay(delay, function()
			if not Alive() then return end
			local bird = Emoji("🦇", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(-0.08, 0, y, 0),
				Size = UDim2.fromOffset(size, size), TextSize = math.floor(size * 0.8),
				TextColor3 = C.Text, TextTransparency = 0.15, ZIndex = 3, Parent = Root,
			})
			local start = os.clock()
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if not Alive() then conn:Disconnect() return end
				local p = (os.clock() - start) / dur
				if p >= 1 then conn:Disconnect() bird:Destroy() return end
				bird.Position = UDim2.new(-0.08 + 1.2 * p, 0, y + math.sin(p * math.pi * 4) * 0.02, 0)
				bird.Rotation = math.sin(p * math.pi * 8) * 10
			end)
		end)
	end

	local function WolfRun()
		local wolf = Emoji("🐺", {
			AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(-0.12, 0, 0.94, 0), Size = UDim2.fromOffset(96, 96),
			TextSize = 72, TextColor3 = C.FxWhite, ZIndex = 7, Parent = Root,
		})
		local RunIn, Leap, RunOut = 1.0, 0.95, 0.7
		local Total = RunIn + Leap + RunOut
		local elapsed, pulsed = 0, false
		local conn
		conn = RunService.Heartbeat:Connect(function(dt)
			if not Alive() then conn:Disconnect() return end
			elapsed += dt
			local X, Y, Rot
			if elapsed < RunIn then
				local u = elapsed / RunIn
				X, Y = -0.12 + 0.46 * u, 0.94 - math.abs(math.sin(u * math.pi * 5)) * 0.025
				Rot = math.sin(u * math.pi * 5) * 6
			elseif elapsed < RunIn + Leap then
				local u = (elapsed - RunIn) / Leap
				X, Y = 0.34 + 0.34 * u, 0.94 - 0.62 * math.sin(u * math.pi)
				Rot = -32 + 64 * u
				if u > 0.45 and not pulsed then
					pulsed = true
					Tw(Halo, 0.25, {Transparency = 0.4})
					Tw(Moon, 0.25, {BackgroundTransparency = 0})
					task.delay(0.3, function()
						Tw(Halo, 0.5, {Transparency = 0.78})
						Tw(Moon, 0.5, {BackgroundTransparency = 0.12})
					end)
				end
			else
				local u = math.min((elapsed - RunIn - Leap) / RunOut, 1)
				X, Y = 0.68 + 0.46 * u, 0.94 - math.abs(math.sin(u * math.pi * 4)) * 0.025
				Rot = math.sin(u * math.pi * 4) * 6
			end
			wolf.Position = UDim2.new(X, 0, Y, 0)
			wolf.Rotation = Rot
			if elapsed >= Total then conn:Disconnect() end
		end)
		task.wait(Total + 0.1)
		wolf:Destroy()
	end

	-- Title typing
	local TitleObjects = {}
	local function ShowTitle()
		if FX.ScreenIntroTitle == false then return end
		local text = tostring(titleText or "HelloHub")
		local label = New("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.62, 0), Size = UDim2.new(1, 0, 0, 56),
			BackgroundTransparency = 1, Text = "", TextColor3 = C.Text, TextSize = 44, Font = Enum.Font.GothamBlack, ZIndex = 8, Parent = Root,
		})
		New("UIStroke", {Color = C.Primary, Thickness = 2.5, Transparency = 0.45, Parent = label})
		local sub = New("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.62, 40), Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1, Text = tostring(subText or ""), TextColor3 = C.Primary, TextSize = 15,
			Font = Enum.Font.GothamBold, TextTransparency = 1, ZIndex = 8, Parent = Root,
		})
		TitleObjects = {label, sub}
		for i = 1, (utf8.len(text) or #text) do
			if not Alive() then return end
			local cut = utf8.offset(text, i + 1)
			label.Text = cut and string.sub(text, 1, cut - 1) or text
			task.wait(0.06)
		end
		Tw(sub, 0.4, {TextTransparency = 0})
	end

	task.spawn(function()
		Tw(Dim, 0.5, {BackgroundTransparency = 0.45})
		task.wait(0.55)
		Flash.BackgroundTransparency = 0.4
		task.wait(0.06)
		Tw(Flash, 0.2, {BackgroundTransparency = 1})
		Tw(Moon, 0.9, {Size = UDim2.fromOffset(160, 160)}, Enum.EasingStyle.Back)
		Crow(0.0, 0.22, 26, 3.0) Crow(0.25, 0.30, 20, 3.2) Crow(0.45, 0.18, 22, 2.8)
		task.wait(0.9)
		WolfRun()
		task.wait(0.3)
		ShowTitle()
		task.wait(2.0)
		Tw(Dim, 0.8, {BackgroundTransparency = 1})
		Tw(Moon, 0.7, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		for _, obj in ipairs(TitleObjects) do
			if obj:IsA("TextLabel") then Tw(obj, 0.6, {TextTransparency = 1}) end
		end
		task.wait(0.9)
		if Root.Parent then Root:Destroy() end
	end)
end

-- ฉากเปิดธีมอื่นๆ
local function BuildSeasonIntro(win)
	local t, mode = win.Theme, win.Theme.Animation or "clean"
	local C = FxColors(t)
	local Root = New("Frame", {Name = "SeasonIntro", Size = UDim2.fromScale(1, 1), BackgroundColor3 = t.Background, BackgroundTransparency = 0.12, BorderSizePixel = 0, ZIndex = 200, Parent = win.Gui})
	local Dim = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = t.Background, BackgroundTransparency = 0.18, BorderSizePixel = 0, ZIndex = 201, Parent = Root})
	local symbol = mode == "clean" and "✦" or (mode == "snow" and "❄" or (mode == "hearts" and "♥" or "☀"))
	local accentColor = mode == "clean" and C.FxLight or C.Primary
	local Icon = Emoji(symbol, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(0, 0), TextColor3 = accentColor, TextTransparency = 1, TextSize = 48, ZIndex = 204, Parent = Root})
	local Ring = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 203, Parent = Root}, {Corner(200)})
	AddStroke(Ring, accentColor, 0.18, 2)
	local Line = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.54), Size = UDim2.fromOffset(0, 2), BackgroundColor3 = C.Stroke2, BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 204, Parent = Root})
	local Label = New("TextLabel", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.57), Size = UDim2.new(0.8, 0, 0, 34), BackgroundTransparency = 1, Text = win.Title, TextColor3 = t.Text, TextTransparency = 1, TextSize = 24, Font = Enum.Font.GothamBold, ZIndex = 204, Parent = Root})
	local Sub = New("TextLabel", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.64), Size = UDim2.new(0.8, 0, 0, 22), BackgroundTransparency = 1, Text = win.Subtitle, TextColor3 = t.SubText, TextTransparency = 1, TextSize = 13, Font = Enum.Font.Gotham, ZIndex = 204, Parent = Root})

	Tw(Icon, 0.55, {Size = UDim2.fromOffset(96, 96), TextTransparency = 0}, Enum.EasingStyle.Back)
	Tw(Ring, 0.85, {Size = UDim2.fromOffset(210, 210)}, Enum.EasingStyle.Back)
	Tw(Line, 0.8, {Size = UDim2.fromOffset(230, 2)}, Enum.EasingStyle.Quint)
	Tw(Label, 0.55, {TextTransparency = 0})
	Tw(Sub, 0.75, {TextTransparency = 0})
	task.delay(1.4, function()
		if Root.Parent then
			Tw(Dim, 0.5, {BackgroundTransparency = 1})
			Tw(Icon, 0.5, {TextTransparency = 1, Size = UDim2.fromOffset(160, 160)})
			Tw(Ring, 0.6, {Size = UDim2.fromOffset(420, 420)})
			Tw(Label, 0.3, {TextTransparency = 1})
			Tw(Sub, 0.3, {TextTransparency = 1})
			task.delay(0.7, function() if Root.Parent then Root:Destroy() end end)
		end
	end)
end

-- เอฟเฟกต์บนหน้าต่าง (เฉพาะ Halloween)
local function ClearWindowFX(win)
	local fx = win._fx
	if not fx then return end
	fx.dead = true
	for _, c in ipairs(fx.conns) do pcall(function() c:Disconnect() end) end
	for _, o in ipairs(fx.objs) do pcall(function() o:Destroy() end) end
	win._fx = nil
end

local function BuildWindowFX(win)
	ClearWindowFX(win)
	if win.Theme.Animation ~= "halloween" then return end
	local FX, t = HelloHub.FX, win.Theme
	local C = FxColors(t)
	local main = win.Main
	local fx = {dead = false, conns = {}, objs = {}}
	win._fx = fx
	local function reg(o) table.insert(fx.objs, o) return o end

	local Layer = reg(New("Frame", {Name = "HalloweenFX", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 25, Parent = main}))

	if FX.Tint then
		local tint = reg(New("Frame", {Name = "HalloweenTint", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 0, Parent = main}, {Corner(12)}))
		New("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.Stroke1), ColorSequenceKeypoint.new(0.55, C.Background), ColorSequenceKeypoint.new(1, C.Stroke2)}),
			Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.84), NumberSequenceKeypoint.new(0.55, 1), NumberSequenceKeypoint.new(1, 0.82)}),
			Parent = tint,
		})
	end

	if FX.Moon then
		local moon = reg(New("Frame", {
			Name = "HalloweenMoon", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -78, 0, 34),
			Size = UDim2.fromOffset(86, 86), BackgroundColor3 = C.FxLight, BackgroundTransparency = 0.86, BorderSizePixel = 0, ZIndex = 0, Parent = main,
		}, {Corner(43)}))
		AddStroke(moon, C.FxLight, 0.8, 6)
	end

	local mainStroke = FX.BorderPulse and win._mainStroke or nil
	local clock = 0
	table.insert(fx.conns, RunService.Heartbeat:Connect(function(dt)
		if fx.dead or win.Destroyed then return end
		clock += dt
		if FX.HeaderLine and win._lineGrad then win._lineGrad.Offset = Vector2.new((clock * 0.35) % 2 - 1, 0) end
		if FX.TitleShine and win._titleGrad then win._titleGrad.Offset = Vector2.new((clock * 0.5) % 2 - 1, 0) end
		if mainStroke then mainStroke.Thickness = 1.7 + 0.9 * (0.5 + 0.5 * math.sin(clock * 1.8)) end
	end))
end

-- Effects helper
HelloHub.Effects = {}
function HelloHub.Effects:Glow(obj, color)
	if not obj or not obj.Parent then return end
	local s = obj:FindFirstChild("HelloHub_Glow")
	if not s then
		s = New("UIStroke", {Name = "HelloHub_Glow", Thickness = 1, Transparency = 0.8, Color = color or HelloHub.Themes.Hello.Accent, Parent = obj})
	end
	Tw(s, 0.25, {Transparency = 0.12, Thickness = 2})
	return s
end
function HelloHub.Effects:Pulse(obj)
	if not obj then return end
	local sc = obj:FindFirstChild("HelloHub_PulseScale") or New("UIScale", {Name = "HelloHub_PulseScale", Scale = 1, Parent = obj})
	task.spawn(function()
		while obj.Parent do
			Tw(sc, 0.7, {Scale = 1.025}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(0.7)
			if not obj.Parent then break end
			Tw(sc, 0.7, {Scale = 1}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(0.7)
		end
	end)
end
function HelloHub.Effects:Shake(obj, strength)
	if not obj then return end
	strength = strength or 4
	local orig = obj.Position
	task.spawn(function()
		for _ = 1, 8 do
			if not obj.Parent then return end
			obj.Position = UDim2.new(orig.X.Scale, orig.X.Offset + math.random(-strength, strength), orig.Y.Scale, orig.Y.Offset + math.random(-strength, strength))
			task.wait(0.035)
		end
		if obj.Parent then obj.Position = orig end
	end)
end

----------------------------------------------------------------
-- BACKGROUND
----------------------------------------------------------------
HelloHub.Background = {
	Enabled = true,
	Image = "",
	File = "HelloHub_bg.jpg",
	Url = "",
	Transparency = 0.5,
}
HelloHub.Glass = {Main = 0.2, Sidebar = 0.3, Card = 0.4}

local function ResolveBackground(cfg)
	if not cfg.Enabled then return nil end
	if cfg.Image and cfg.Image ~= "" then return cfg.Image end
	local getAsset = getcustomasset or getsynasset
	if not (getAsset and isfile and writefile) then return nil end
	if not cfg.File or cfg.File == "" then return nil end
	pcall(function()
		if cfg.Url and cfg.Url ~= "" and not isfile(cfg.File) then
			writefile(cfg.File, game:HttpGet(cfg.Url))
		end
	end)
	local ok, asset = pcall(function()
		if isfile(cfg.File) then return getAsset(cfg.File) end
	end)
	if ok and asset then return asset end
	return nil
end

local function FixImage(img)
	task.spawn(function()
		local original = img.Image
		if original == "" then return end
		local ok, result = pcall(function() return game:GetObjects(original) end)
		if ok and type(result) == "table" and result[1] then
			local asset, texture = result[1], nil
			if asset:IsA("Decal") or asset:IsA("Texture") then
				texture = asset.Texture
			else
				local found = asset:FindFirstChildWhichIsA("Decal", true)
				if found then texture = found.Texture end
			end
			if texture and texture ~= "" then img.Image = texture end
		end
	end)
end

----------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------
local Window = {}
Window.__index = Window

function Window:_ApplyGlass()
	if not self.BgImage then return end
	local has, g = self.BgImage.Visible, HelloHub.Glass
	self.Main.BackgroundTransparency = has and g.Main or 0
	self._sidebarFrame.BackgroundTransparency = has and g.Sidebar or 0
	for _, r in ipairs(self._rows) do
		if r.Parent then r.BackgroundTransparency = has and g.Card or 0 end
	end
end

function Window:SetBackground(cfg)
	if type(cfg) == "string" then cfg = {Image = cfg, Enabled = true}
	elseif cfg == false then cfg = {Enabled = false}
	elseif type(cfg) ~= "table" then return end
	for k, v in pairs(cfg) do self._bgCfg[k] = v end
	local asset = ResolveBackground(self._bgCfg)
	self.BgImage.Image = asset or ""
	self.BgImage.Visible = asset ~= nil
	Tw(self.BgImage, 0.3, {ImageTransparency = self._bgCfg.Transparency})
	if asset then FixImage(self.BgImage) end
	self:_ApplyGlass()
end

function Window:SetBackgroundTransparency(v)
	self._bgCfg.Transparency = v
	Tw(self.BgImage, 0.2, {ImageTransparency = v})
end

function HelloHub:CreateWindow(opts)
	opts = opts or {}
	local win = setmetatable({}, Window)
	win.Theme = {}
	for k, v in pairs(HelloHub.Themes.Hello) do win.Theme[k] = v end
	local tn = ResolveThemeName(opts.Theme)
	win.ThemeName = tn or "Hello"
	local preset = tn and HelloHub.Themes[tn]
	if preset then for k, v in pairs(preset) do win.Theme[k] = v end end
	win.Theme.Animation = preset and preset.Animation or "clean"
	if type(opts.Theme) == "table" then
		win.ThemeName = "Custom"
		for k, v in pairs(opts.Theme) do win.Theme[k] = v end
		win.Theme.Animation = opts.Theme.Animation or "clean"
	end

	win._bound, win._refresh, win._conns, win._rows = {}, {}, {}, {}
	win.Tabs, win.Current, win.Visible = {}, nil, true

	local name = opts.Name or "HelloHub"
	local size = opts.Size or UDim2.fromOffset(580, 380)
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

	local gui = New("ScreenGui", {
		Name = "HelloHub", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	})
	ProtectGui(gui)
	win.Gui = gui

	-- ===== Main ===== (มีเงา 3 ชั้น + corner ใหญ่ขึ้น)
	local shadowOuter = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, size.X.Offset + 24, 0, size.Y.Offset + 24),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0, ZIndex = 0, Parent = gui,
	}, {Corner(18)})

	local main = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = size, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 1, Parent = gui,
	}, {Corner(14)})
	Bind(win, main, "BackgroundColor3", "Background")
	local mainStroke = New("UIStroke", {Thickness = 1.5, Transparency = 0.2, Parent = main})
	Bind(win, mainStroke, "Color", "Stroke")
	win.Main = main

	-- Topbar
	local top = New("Frame", {
		Size = UDim2.new(1, 0, 0, 42), BorderSizePixel = 0, Parent = main,
	})
	Bind(win, top, "BackgroundColor3", "Topbar")
	-- gradient บน topbar (ให้ดูมีมิติ)
	New("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.6, 0.6, 0.6)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.94),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = top,
	})
	-- เส้น accent ใต้ topbar
	local line = New("Frame", {Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Parent = top, ZIndex = 2})
	win._lineGrad = AccentGradient(win, line)

	local title = Label(win, top, name, 16, "Text")
	title.Font = Enum.Font.GothamBold
	title.Position = UDim2.fromOffset(16, 0)
	title.Size = UDim2.new(0.6, 0, 1, -2)
	title.TextColor3 = Color3.new(1, 1, 1)
	win._titleGrad = AccentGradient(win, title)
	for i = #win._bound, 1, -1 do
		if win._bound[i][1] == title then table.remove(win._bound, i) end
	end

	local ver = Label(win, top, "v" .. HelloHub.Version, 11, "SubText", Enum.TextXAlignment.Right)
	ver.Position = UDim2.new(1, -90, 0, 0)
	ver.Size = UDim2.new(0, 52, 1, -2)

	local close = New("TextButton", {
		BackgroundTransparency = 1, Text = "✕", Font = Enum.Font.GothamBold, TextSize = 14,
		Position = UDim2.new(1, -36, 0, 0), Size = UDim2.fromOffset(30, 40), Parent = top,
	})
	Bind(win, close, "TextColor3", "SubText")
	close.MouseEnter:Connect(function() Tween(close, {TextColor3 = win.Theme.Accent}) end)
	close.MouseLeave:Connect(function() Tween(close, {TextColor3 = win.Theme.SubText}) end)

	-- Sidebar
	local sidebar = New("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 42), Size = UDim2.new(0, 140, 1, -42),
		BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = main,
	}, {
		New("UIListLayout", {Padding = UDim.new(0, 5)}),
		New("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)}),
	})
	Bind(win, sidebar, "BackgroundColor3", "Sidebar")

	local content = New("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(140, 42),
		Size = UDim2.new(1, -140, 1, -42), Parent = main,
	})
	win._sidebar, win._content = sidebar, content

	-- Background image
	win._bgCfg = {}
	for k, v in pairs(HelloHub.Background) do win._bgCfg[k] = v end
	if type(opts.Background) == "string" then
		win._bgCfg.Image = opts.Background
	elseif type(opts.Background) == "table" then
		for k, v in pairs(opts.Background) do win._bgCfg[k] = v end
	elseif opts.Background == false then
		win._bgCfg.Enabled = false
	end
	local bgAsset = ResolveBackground(win._bgCfg)
	win.BgImage = New("ImageLabel", {
		Name = "BackgroundImage", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		Image = bgAsset or "", ImageTransparency = win._bgCfg.Transparency, ScaleType = Enum.ScaleType.Crop,
		ZIndex = 0, Visible = bgAsset ~= nil, Parent = main,
	}, {Corner(14)})
	win._sidebarFrame = sidebar
	if bgAsset then FixImage(win.BgImage) end
	win:_ApplyGlass()

	-- drag window
	do
		local dragging, start, orig
		top.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging, start, orig = true, i.Position, main.Position
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		table.insert(win._conns, UIS.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - start
				main.Position = UDim2.new(orig.X.Scale, orig.X.Offset + d.X, orig.Y.Scale, orig.Y.Offset + d.Y)
				shadowOuter.Position = main.Position
			end
		end))
	end

	-- ===== FAB (ปุ่มลอย) =====
	local fab = New("TextButton", {
		Position = UDim2.new(0, 16, 0.5, -24), Size = UDim2.fromOffset(48, 48),
		BorderSizePixel = 0, Text = "H", Font = Enum.Font.GothamBold, TextSize = 22,
		TextColor3 = Color3.new(1, 1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false, Parent = gui,
	}, {Corner(24)})
	AccentGradient(win, fab, 45)
	Shadow(fab, Color3.new(0, 0, 0), 0.6, 2)
	do
		local dragging, start, orig, moved = false, nil, nil, 0
		fab.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging, start, orig, moved = true, i.Position, fab.Position, 0
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then
						dragging = false
						if moved < 6 then win:Toggle() end
					end
				end)
			end
		end)
		table.insert(win._conns, UIS.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - start
				moved = math.max(moved, d.Magnitude)
				fab.Position = UDim2.new(orig.X.Scale, orig.X.Offset + d.X, orig.Y.Scale, orig.Y.Offset + d.Y)
			end
		end))
	end

	-- Notifications
	local notifHolder = New("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16), Size = UDim2.fromOffset(280, 400), Parent = gui,
	}, {New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})})
	win._notifHolder = notifHolder

	close.MouseButton1Click:Connect(function() win:Toggle(false) end)
	table.insert(win._conns, UIS.InputBegan:Connect(function(i, gpe)
		if not gpe and i.KeyCode == toggleKey then win:Toggle() end
	end))

	-- FX
	win.Title = name
	win.Subtitle = opts.Subtitle or ("HelloHub v" .. HelloHub.Version)
	win.Destroyed = false
	win._mainStroke = mainStroke
	win._shadowOuter = shadowOuter
	if opts.Animation ~= false then
		BuildWindowFX(win)
		if opts.Intro ~= false then
			task.spawn(function()
				local ok, err = pcall(function()
					if win.Theme.Animation == "halloween" then
						BuildScreenIntro(win, win.Title, win.Subtitle)
					else
						BuildSeasonIntro(win)
					end
				end)
				if not ok then warn("[HelloHub] intro error: " .. tostring(err)) end
			end)
		end
	end
	win._animation = opts.Animation ~= false

	return win
end

function Window:Toggle(v)
	if v == nil then v = not self.Visible end
	self.Visible = v
	self.Main.Visible = v
	if self._shadowOuter then self._shadowOuter.Visible = v end
	if v then
		self.Main.Size = self.Main.Size
	end
end

function Window:SetTheme(theme)
	local t
	if type(theme) == "string" then
		local n = ResolveThemeName(theme)
		if not n then return end
		self.ThemeName = n
		t = HelloHub.Themes[n]
	elseif type(theme) == "table" then
		self.ThemeName = "Custom"
		t = theme
	else
		return
	end
	for k, v in pairs(t) do self.Theme[k] = v end
	self.Theme.Animation = t.Animation or "clean"
	for _, b in ipairs(self._bound) do
		local obj, prop, key = b[1], b[2], b[3]
		if obj and obj.Parent then Tween(obj, {[prop] = self.Theme[key]}, 0.25) end
	end
	for _, fn in ipairs(self._refresh) do pcall(fn) end
	if self.Main and self._animation then BuildWindowFX(self) end
end

-- Notification แบบสไลด์จากขวา
function Window:Notify(o)
	local theme = self.Theme
	local f = New("Frame", {
		Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = theme.Topbar, BorderSizePixel = 0,
		ClipsDescendants = true, Parent = self._notifHolder,
		Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 0.05,
	}, {Corner(10)})
	New("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.3, Parent = f})
	local bar = New("Frame", {Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0, BackgroundColor3 = theme.Accent, Parent = f})
	AccentGradient(win_or(f, self), bar, 90)
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 8), Size = UDim2.new(1, -26, 0, 20),
		Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = o.Title or "HelloHub", Parent = f,
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 30), Size = UDim2.new(1, -26, 0, 28),
		Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.SubText, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		Text = o.Content or "", Parent = f,
	})
	Tween(f, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back)
	task.delay(o.Duration or 4, function()
		if f.Parent then
			Tween(f, {Position = UDim2.new(1, 60, 0, 0), BackgroundTransparency = 1}, 0.35)
			task.wait(0.4)
			f:Destroy()
		end
	end)
end

-- helper ย่อย
function win_or(_, self) return self end

function Window:CreateTab(name)
	local win = self
	local tab = setmetatable({Win = win, Name = name}, Tab)

	local btn = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 34), BorderSizePixel = 0, AutoButtonColor = false,
		Font = Enum.Font.GothamMedium, TextSize = 13, Text = name,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = win._sidebar,
	}, {Corner(8), New("UIPadding", {PaddingLeft = UDim.new(0, 12)})})

	-- accent bar ด้านซ้าย (แสดงเมื่อ active)
	local accent = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(0, 20), BorderSizePixel = 0,
		BackgroundTransparency = 0.3, Parent = btn, ZIndex = 2,
	}, {Corner(2)})
	AccentGradient(win, accent, 90)

	local page = New("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 2, ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false, Parent = win._content,
	}, {
		New("UIListLayout", {Padding = UDim.new(0, 7)}),
		New("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12)}),
	})
	Bind(win, page, "ScrollBarImageColor3", "Accent")
	tab.Page, tab.Button, tab._accent = page, btn, accent

	local function paint()
		local active = win.Current == tab
		Tween(btn, {
			BackgroundColor3 = active and win.Theme.Element or win.Theme.Sidebar,
			TextColor3 = active and win.Theme.Accent or win.Theme.SubText,
		}, 0.2)
		Tween(accent, {Size = UDim2.fromOffset(active and 3 or 0, 20), BackgroundTransparency = active and 0.05 or 0.3}, 0.25)
	end
	tab._paint = paint
	OnRefresh(win, paint)

	btn.MouseButton1Click:Connect(function() win:SelectTab(tab) end)
	table.insert(win.Tabs, tab)
	if not win.Current then win:SelectTab(tab) end
	return tab
end

function Window:SelectTab(tab)
	self.Current = tab
	for _, t in ipairs(self.Tabs) do
		t.Page.Visible = (t == tab)
		t._paint()
	end
end

----------------------------------------------------------------
-- FLOATING BUTTON
----------------------------------------------------------------
local function GetFabGui(win)
	if win._fabGui and win._fabGui.Parent then return win._fabGui end
	local g = New("ScreenGui", {
		Name = "HelloHub_Buttons", ResetOnSpawn = false, IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 998,
	})
	ProtectGui(g)
	win._fabGui = g
	return g
end

local function BuildFloatingButton(win, cfg, standalone)
	cfg = cfg or {}
	local name     = cfg.Name or "Button"
	local mode     = cfg.Mode or "Toggle"
	local callback = cfg.Callback or function() end
	local effects  = cfg.Effects ~= false
	local W, H     = cfg.Width or (effects and 170 or 150), cfg.Height or (effects and 62 or 54)
	local TX       = effects and 62 or 18
	local fxUpdate, setFace = function() end, nil
	local OnText   = cfg.OnText or "เปิด"
	local OffText  = cfg.OffText or "ปิด"
	local ReadyText= cfg.ReadyText or "กดเพื่อใช้"
	local cooldown = cfg.Cooldown or 0
	local MARGIN, THRESHOLD, SMOOTH = 4, 6, 28

	win._fabs = win._fabs or {}
	if win._fabs[name] then win._fabs[name]:Destroy() end

	local gui = GetFabGui(win)
	local cam = workspace.CurrentCamera or workspace:WaitForChild("Camera")
	local dead, busy = false, false
	local state = (mode == "Toggle") and cfg.Default == true
	local conns = {}
	local function track(c) table.insert(conns, c) table.insert(win._conns, c) return c end

	local function clamp(v)
		local vs = cam.ViewportSize
		return Vector2.new(
			math.clamp(v.X, MARGIN, math.max(MARGIN, vs.X - W - MARGIN)),
			math.clamp(v.Y, MARGIN, math.max(MARGIN, vs.Y - H - MARGIN)))
	end
	local pos = clamp(cfg.Position or Vector2.new(60, cam.ViewportSize.Y / 2 - H / 2))
	local target = pos

	local holder = New("Frame", {
		Name = name, Size = UDim2.fromOffset(W, H), BackgroundTransparency = 1,
		Position = UDim2.fromOffset(pos.X, pos.Y), Parent = gui,
	})

	-- shadow ชั้นล่าง
	local fabShadow = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 8, 1, 8), BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.7, BorderSizePixel = 0, Parent = holder,
	}, {Corner(H / 2 + 4)})

	local button = New("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(W, H), BackgroundColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false, Text = "", Parent = holder,
	}, {Corner(H / 2)})
	local scale = New("UIScale", {Scale = 1, Parent = button})

	local bgGrad = New("UIGradient", {Rotation = 45, Parent = button})
	local stroke = New("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = button})
	local strokeGrad = New("UIGradient", {Parent = stroke})
	OnRefresh(win, function()
		local t = win.Theme
		bgGrad.Color = ColorSequence.new(t.Topbar, t.Background)
		strokeGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, t.Accent),
			ColorSequenceKeypoint.new(0.5, t.Accent2),
			ColorSequenceKeypoint.new(1, t.Accent),
		})
	end)

	local inner = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Parent = button}, {Corner(H / 2)})

	local titleL = Label(win, inner, cfg.Title or name, 13, "Text")
	titleL.Font = Enum.Font.GothamBold
	titleL.Position = UDim2.new(0, TX, 0.5, -18)
	titleL.Size = UDim2.new(1, -(TX + 14), 0, 18)
	titleL.TextTruncate = Enum.TextTruncate.AtEnd

	local dot = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, TX + 4, 0.5, 10),
		Size = UDim2.fromOffset(8, 8), BorderSizePixel = 0, Parent = inner,
	}, {Corner(4)})
	local statusL = Label(win, inner, "", 12, "SubText")
	statusL.Position = UDim2.new(0, TX + 16, 0.5, 2)
	statusL.Size = UDim2.new(1, -(TX + 28), 0, 16)

	local function paint(instant)
		local t = win.Theme
		local d = instant and 0 or 0.22
		if mode == "Toggle" then
			statusL.Text = state and OnText or OffText
		elseif not busy then
			statusL.Text = ReadyText
		end
		Tween(statusL, {TextColor3 = state and t.Accent or t.SubText}, d)
		Tween(dot, {BackgroundColor3 = state and t.Accent or t.Stroke}, d)
		Tween(titleL, {TextColor3 = state and t.Text or t.SubText}, d)
		if setFace then setFace(state) end
	end
	OnRefresh(win, function() paint(true) end)

	local clock = 0
	track(RunService.Heartbeat:Connect(function(dt)
		if dead then return end
		clock += dt
		if pos ~= target then
			pos = pos:Lerp(target, 1 - math.exp(-dt * SMOOTH))
			if (target - pos).Magnitude < 0.25 then pos = target end
			holder.Position = UDim2.fromOffset(math.round(pos.X), math.round(pos.Y))
		end
		strokeGrad.Rotation = (clock * 60) % 360
		fxUpdate(clock)
	end))

	-- Drag
	local hovering, dragging, moved = false, false, false
	local dragInput, dragOrigin, dragStart

	track(button.MouseEnter:Connect(function()
		hovering = true
		if not dragging then Tween(scale, {Scale = 1.07}) end
	end))
	track(button.MouseLeave:Connect(function()
		hovering = false
		if not dragging then Tween(scale, {Scale = 1}) end
	end))
	track(button.InputBegan:Connect(function(i)
		if dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, moved = true, false
			dragInput, dragOrigin, dragStart = i, i.Position, target
		end
	end))
	track(UIS.InputChanged:Connect(function(i)
		if not dragging or not dragInput then return end
		local isMouse = dragInput.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement
		local isTouch = dragInput.UserInputType == Enum.UserInputType.Touch and i == dragInput
		if not (isMouse or isTouch) then return end
		local delta = Vector2.new(i.Position.X - dragOrigin.X, i.Position.Y - dragOrigin.Y)
		if not moved then
			if delta.Magnitude < THRESHOLD then return end
			moved = true
			dragOrigin, dragStart = i.Position, target
			Tween(scale, {Scale = 0.94}, 0.15)
			return
		end
		target = clamp(dragStart + delta)
	end))
	track(UIS.InputEnded:Connect(function(i)
		if not dragging then return end
		local sameTouch = i == dragInput
		local sameMouse = dragInput and dragInput.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseButton1
		if not (sameTouch or sameMouse) then return end
		dragging, dragInput = false, nil
		if moved then Tween(scale, {Scale = hovering and 1.07 or 1}, 0.2, Enum.EasingStyle.Back) end
	end))
	track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() target = clamp(target) end))

	-- Click ripple
	local function ripple()
		local r = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(W, H), BackgroundTransparency = 1, ZIndex = 9, Parent = button,
		}, {Corner(H / 2 + 4)})
		local s = New("UIStroke", {Color = win.Theme.Accent, Thickness = 2, Transparency = 0.1, Parent = r})
		Tween(r, {Size = UDim2.fromOffset(W + 60, H + 60)}, 0.55)
		Tween(s, {Transparency = 1}, 0.55)
		task.delay(0.6, function() r:Destroy() end)
	end

	local handle = {Gui = gui, Button = button, Holder = holder}
	function handle:Set(v, silent)
		if mode ~= "Toggle" then return end
		state = v and true or false
		paint()
		SetFlag(cfg, state)
		if not silent then task.spawn(callback, state) end
	end
	function handle:Get() return state end
	function handle:SetTitle(t) titleL.Text = t end
	function handle:SetVisible(v) holder.Visible = v end
	function handle:Destroy()
		if dead then return end
		dead = true
		for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
		pcall(function() holder:Destroy() end)
		if win._fabs[name] == handle then win._fabs[name] = nil end
		if standalone then win:Destroy() end
	end

	track(button.Activated:Connect(function()
		if moved or dead then return end
		ripple()
		Tween(scale, {Scale = 0.86}, 0.08)
		task.delay(0.09, function()
			if not dead then Tween(scale, {Scale = hovering and 1.07 or 1}, 0.25, Enum.EasingStyle.Back) end
		end)
		if mode == "Button" then
			if busy then return end
			task.spawn(callback)
			if cooldown > 0 then
				busy = true
				task.spawn(function()
					local untilT = os.clock() + cooldown
					while not dead and os.clock() < untilT do
						statusL.Text = string.format("%.1f", untilT - os.clock())
						statusL.TextColor3 = win.Theme.Accent
						task.wait(0.1)
					end
					busy = false
					if not dead then paint() end
				end)
			end
			return
		end
		handle:Set(not state)
	end))

	SetFlag(cfg, state)
	win._fabs[name] = handle
	return handle
end

function Window:CreateFloatingButton(cfg)
	return BuildFloatingButton(self, cfg, false)
end

function HelloHub:CreateFloatingButton(cfg)
	cfg = cfg or {}
	local host = setmetatable({Theme = {}, _bound = {}, _refresh = {}, _conns = {}, Tabs = {}, Gui = Instance.new("Folder")}, Window)
	for k, v in pairs(HelloHub.Themes.Hello) do host.Theme[k] = v end
	local tn = ResolveThemeName(cfg.Theme)
	host.ThemeName = tn or "Hello"
	local preset = tn and HelloHub.Themes[tn]
	if type(cfg.Theme) == "table" then preset, host.ThemeName = cfg.Theme, "Custom" end
	if preset then for k, v in pairs(preset) do host.Theme[k] = v end end
	local h = BuildFloatingButton(host, cfg, true)
	h.SetTheme = function(_, t) host:SetTheme(t) end
	return h
end

function Window:Destroy()
	for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
	self.Destroyed = true
	ClearWindowFX(self)
	if self._fabGui then pcall(function() self._fabGui:Destroy() end) end
	self.Gui:Destroy()
end

return HelloHub
