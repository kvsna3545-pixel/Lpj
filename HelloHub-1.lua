--[[
    HelloHub UI Library  |  v1.0.0
    ------------------------------------------------------------
    Window  : HelloHub:CreateWindow({Name, Theme, ToggleKey, Size})
    Tab     : Window:CreateTab(name)
    Element : Tab:AddSection / AddLabel / AddButton / AddToggle /
              AddSlider / AddDropdown / AddTextbox / AddKeybind
    Other   : Window:Notify / SetTheme / Toggle / Destroy
    Themes  : Hello (default, pink-purple) | Ocean | Mint | Sunset | Dark
              หรือส่ง table สีของตัวเองเข้า SetTheme ได้
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UIS              = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local HelloHub = {
	Version = "1.0.0",
	Flags   = {},
}

----------------------------------------------------------------
-- THEMES  (แก้สีตรงนี้ได้เลย)
----------------------------------------------------------------
HelloHub.Themes = {
	Hello = {
		Background  = Color3.fromRGB(18, 12, 26),
		Topbar      = Color3.fromRGB(28, 18, 40),
		Sidebar     = Color3.fromRGB(23, 15, 33),
		Element     = Color3.fromRGB(36, 26, 52),
		ElementHover= Color3.fromRGB(50, 36, 72),
		Accent      = Color3.fromRGB(255, 105, 180),
		Accent2     = Color3.fromRGB(170, 90, 255),
		Text        = Color3.fromRGB(255, 255, 255),
		SubText     = Color3.fromRGB(190, 170, 210),
		Stroke      = Color3.fromRGB(72, 52, 102),
	},
	Ocean = {
		Background  = Color3.fromRGB(10, 18, 28),
		Topbar      = Color3.fromRGB(15, 28, 44),
		Sidebar     = Color3.fromRGB(12, 23, 36),
		Element     = Color3.fromRGB(20, 38, 58),
		ElementHover= Color3.fromRGB(30, 54, 82),
		Accent      = Color3.fromRGB(0, 190, 255),
		Accent2     = Color3.fromRGB(90, 120, 255),
		Text        = Color3.fromRGB(255, 255, 255),
		SubText     = Color3.fromRGB(160, 190, 215),
		Stroke      = Color3.fromRGB(40, 70, 105),
	},
	Mint = {
		Background  = Color3.fromRGB(10, 22, 20),
		Topbar      = Color3.fromRGB(14, 34, 30),
		Sidebar     = Color3.fromRGB(12, 28, 25),
		Element     = Color3.fromRGB(20, 46, 40),
		ElementHover= Color3.fromRGB(30, 66, 58),
		Accent      = Color3.fromRGB(60, 235, 170),
		Accent2     = Color3.fromRGB(80, 200, 255),
		Text        = Color3.fromRGB(255, 255, 255),
		SubText     = Color3.fromRGB(160, 210, 195),
		Stroke      = Color3.fromRGB(40, 90, 78),
	},
	Sunset = {
		Background  = Color3.fromRGB(26, 14, 14),
		Topbar      = Color3.fromRGB(40, 20, 18),
		Sidebar     = Color3.fromRGB(33, 17, 16),
		Element     = Color3.fromRGB(54, 30, 26),
		ElementHover= Color3.fromRGB(76, 42, 34),
		Accent      = Color3.fromRGB(255, 130, 60),
		Accent2     = Color3.fromRGB(255, 70, 110),
		Text        = Color3.fromRGB(255, 255, 255),
		SubText     = Color3.fromRGB(220, 180, 165),
		Stroke      = Color3.fromRGB(105, 60, 48),
	},
	Dark = {
		Background  = Color3.fromRGB(16, 16, 18),
		Topbar      = Color3.fromRGB(24, 24, 27),
		Sidebar     = Color3.fromRGB(20, 20, 23),
		Element     = Color3.fromRGB(32, 32, 36),
		ElementHover= Color3.fromRGB(46, 46, 52),
		Accent      = Color3.fromRGB(235, 235, 240),
		Accent2     = Color3.fromRGB(150, 150, 165),
		Text        = Color3.fromRGB(255, 255, 255),
		SubText     = Color3.fromRGB(170, 170, 180),
		Stroke      = Color3.fromRGB(60, 60, 68),
	},
}

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

local function Tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Corner(r) return New("UICorner", {CornerRadius = UDim.new(0, r or 6)}) end

local function ProtectGui(gui)
	local ok = pcall(function()
		gui.Parent = (gethui and gethui()) or CoreGui
	end)
	if not ok or not gui.Parent then
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
end

-- ผูกพร็อพเพอร์ตี้กับสีธีม
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

local function Row(win, page, height)
	local f = New("Frame", {
		Size = UDim2.new(1, 0, 0, height or 34),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = page,
	}, {Corner(6)})
	Bind(win, f, "BackgroundColor3", "Element")
	local s = New("UIStroke", {Thickness = 1, Parent = f})
	Bind(win, s, "Color", "Stroke")
	return f
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
	local l = Label(win, self.Page, string.upper(name), 12, "Accent")
	l.Font = Enum.Font.GothamBold
	l.Size = UDim2.new(1, 0, 0, 22)
	return l
end

function Tab:AddLabel(text)
	local win = self.Win
	local row = Row(win, self.Page, 30)
	local l = Label(win, row, text, 13, "SubText")
	l.Position = UDim2.fromOffset(10, 0)
	l.Size = UDim2.new(1, -20, 1, 0)
	local obj = {}
	function obj:Set(t) l.Text = t end
	return obj
end

function Tab:AddButton(o)
	local win = self.Win
	local row = Row(win, self.Page, 34)
	local l = Label(win, row, o.Name or "Button", 13, "Text")
	l.Position = UDim2.fromOffset(10, 0)
	l.Size = UDim2.new(1, -20, 1, 0)
	local btn = New("TextButton", {BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row})
	btn.MouseEnter:Connect(function() Tween(row, {BackgroundColor3 = win.Theme.ElementHover}) end)
	btn.MouseLeave:Connect(function() Tween(row, {BackgroundColor3 = win.Theme.Element}) end)
	btn.MouseButton1Click:Connect(function()
		Tween(row, {BackgroundColor3 = win.Theme.Accent}, 0.08)
		task.delay(0.1, function() Tween(row, {BackgroundColor3 = win.Theme.Element}, 0.2) end)
		if o.Callback then task.spawn(o.Callback) end
	end)
end

function Tab:AddToggle(o)
	local win = self.Win
	local state = o.Default == true
	local row = Row(win, self.Page, 34)
	local l = Label(win, row, o.Name or "Toggle", 13, "Text")
	l.Position = UDim2.fromOffset(10, 0)
	l.Size = UDim2.new(1, -70, 1, 0)

	local track = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(38, 20), BorderSizePixel = 0, Parent = row,
	}, {Corner(10)})
	local knob = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(14, 14), BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1), Parent = track,
	}, {Corner(7)})

	local function paint(instant)
		local t = instant and 0 or 0.15
		Tween(track, {BackgroundColor3 = state and win.Theme.Accent or win.Theme.Stroke}, t)
		Tween(knob, {Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, t)
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
	local row = Row(win, self.Page, 48)

	local l = Label(win, row, o.Name or "Slider", 13, "Text")
	l.Position = UDim2.fromOffset(10, 4)
	l.Size = UDim2.new(1, -90, 0, 20)
	local vl = Label(win, row, "", 12, "SubText", Enum.TextXAlignment.Right)
	vl.Position = UDim2.new(1, -90, 0, 4)
	vl.Size = UDim2.fromOffset(80, 20)

	local bar = New("Frame", {
		Position = UDim2.new(0, 10, 1, -14), Size = UDim2.new(1, -20, 0, 6),
		BorderSizePixel = 0, Parent = row,
	}, {Corner(3)})
	Bind(win, bar, "BackgroundColor3", "Stroke")
	local fill = New("Frame", {Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Parent = bar}, {Corner(3)})
	AccentGradient(win, fill)

	local obj = {}
	local function render()
		local rel = (value - min) / math.max(max - min, 1e-9)
		fill.Size = UDim2.fromScale(rel, 1)
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
	local ROW_H, ITEM_H = 34, 26

	local row = Row(win, self.Page, ROW_H)
	local l = Label(win, row, o.Name or "Dropdown", 13, "Text")
	l.Position = UDim2.fromOffset(10, 0)
	l.Size = UDim2.new(1, -140, 0, ROW_H)
	local vl = Label(win, row, tostring(current or "..."), 12, "SubText", Enum.TextXAlignment.Right)
	vl.Position = UDim2.new(1, -130, 0, 0)
	vl.Size = UDim2.fromOffset(110, ROW_H)
	local arrow = Label(win, row, "v", 12, "Accent", Enum.TextXAlignment.Center)
	arrow.Position = UDim2.new(1, -20, 0, 0)
	arrow.Size = UDim2.fromOffset(16, ROW_H)

	local list = New("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, ROW_H + 2), Size = UDim2.new(1, 0, 1, -(ROW_H + 4)),
		ScrollBarThickness = 2, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = row,
	}, {
		New("UIListLayout", {Padding = UDim.new(0, 2)}),
		New("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}),
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
		Tween(row, {Size = UDim2.new(1, 0, 0, open and (ROW_H + 6 + visible * (ITEM_H + 2)) or ROW_H)})
		arrow.Text = open and "^" or "v"
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
				BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, ITEM_H),
				Font = Enum.Font.Gotham, TextSize = 12, Text = tostring(name),
				TextXAlignment = Enum.TextXAlignment.Left, Parent = list,
			})
			buttons[name] = b
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
	local row = Row(win, self.Page, 34)
	local l = Label(win, row, o.Name or "Textbox", 13, "Text")
	l.Position = UDim2.fromOffset(10, 0)
	l.Size = UDim2.new(1, -150, 1, 0)

	local box = New("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(130, 22), BorderSizePixel = 0,
		Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
		PlaceholderText = o.Placeholder or "...", Text = o.Default or "",
		Parent = row,
	}, {Corner(5)})
	Bind(win, box, "BackgroundColor3", "Background")
	Bind(win, box, "TextColor3", "Text")
	Bind(win, box, "PlaceholderColor3", "SubText")

	box.FocusLost:Connect(function(enter)
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
	local row = Row(win, self.Page, 34)
	local l = Label(win, row, o.Name or "Keybind", 13, "Text")
	l.Position = UDim2.fromOffset(10, 0)
	l.Size = UDim2.new(1, -110, 1, 0)

	local btn = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(80, 22), BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium, TextSize = 12, Text = key.Name, Parent = row,
	}, {Corner(5)})
	Bind(win, btn, "BackgroundColor3", "Background")
	Bind(win, btn, "TextColor3", "Accent")

	btn.MouseButton1Click:Connect(function()
		listening = true
		btn.Text = "..."
	end)
	table.insert(win._conns, UIS.InputBegan:Connect(function(i, gpe)
		if listening then
			if i.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				key = i.KeyCode
				btn.Text = key.Name
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
-- WINDOW
----------------------------------------------------------------
local Window = {}
Window.__index = Window

function HelloHub:CreateWindow(opts)
	opts = opts or {}
	local win = setmetatable({}, Window)
	win.Theme = {}
	for k, v in pairs(HelloHub.Themes.Hello) do win.Theme[k] = v end
	local preset = type(opts.Theme) == "string" and HelloHub.Themes[opts.Theme]
	if preset then for k, v in pairs(preset) do win.Theme[k] = v end end
	if type(opts.Theme) == "table" then for k, v in pairs(opts.Theme) do win.Theme[k] = v end end

	win._bound, win._refresh, win._conns = {}, {}, {}
	win.Tabs, win.Current, win.Visible = {}, nil, true

	local name = opts.Name or "HelloHub"
	local size = opts.Size or UDim2.fromOffset(560, 360)
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

	local gui = New("ScreenGui", {
		Name = "HelloHub", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	})
	ProtectGui(gui)
	win.Gui = gui

	-- ===== Main =====
	local main = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = size, BorderSizePixel = 0, ClipsDescendants = true, Parent = gui,
	}, {Corner(10)})
	Bind(win, main, "BackgroundColor3", "Background")
	local mainStroke = New("UIStroke", {Thickness = 1.5, Parent = main})
	Bind(win, mainStroke, "Color", "Stroke")
	win.Main = main

	-- Topbar
	local top = New("Frame", {Size = UDim2.new(1, 0, 0, 38), BorderSizePixel = 0, Parent = main})
	Bind(win, top, "BackgroundColor3", "Topbar")
	local line = New("Frame", {Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Parent = top})
	AccentGradient(win, line)

	local title = Label(win, top, name, 16, "Text")
	title.Font = Enum.Font.GothamBold
	title.Position = UDim2.fromOffset(14, 0)
	title.Size = UDim2.new(0.6, 0, 1, -2)
	title.TextColor3 = Color3.new(1, 1, 1)
	AccentGradient(win, title)
	-- (TextColor3 ถูกใช้เป็นฐานของ gradient จึงตั้งเป็นขาว ไม่ bind)
	for i = #win._bound, 1, -1 do
		if win._bound[i][1] == title then table.remove(win._bound, i) end
	end

	local ver = Label(win, top, "v" .. HelloHub.Version, 11, "SubText", Enum.TextXAlignment.Right)
	ver.Position = UDim2.new(1, -88, 0, 0)
	ver.Size = UDim2.new(0, 50, 1, -2)

	local close = New("TextButton", {
		BackgroundTransparency = 1, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14,
		Position = UDim2.new(1, -34, 0, 0), Size = UDim2.fromOffset(30, 36), Parent = top,
	})
	Bind(win, close, "TextColor3", "SubText")
	close.MouseEnter:Connect(function() Tween(close, {TextColor3 = win.Theme.Accent}) end)
	close.MouseLeave:Connect(function() Tween(close, {TextColor3 = win.Theme.SubText}) end)

	-- Sidebar
	local sidebar = New("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 38), Size = UDim2.new(0, 130, 1, -38),
		BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = main,
	}, {
		New("UIListLayout", {Padding = UDim.new(0, 4)}),
		New("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}),
	})
	Bind(win, sidebar, "BackgroundColor3", "Sidebar")

	local content = New("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(130, 38),
		Size = UDim2.new(1, -130, 1, -38), Parent = main,
	})
	win._sidebar, win._content = sidebar, content

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
			end
		end))
	end

	-- ===== Floating button =====
	local fab = New("TextButton", {
		Position = UDim2.new(0, 14, 0.5, -22), Size = UDim2.fromOffset(44, 44),
		BorderSizePixel = 0, Text = "H", Font = Enum.Font.GothamBold, TextSize = 22,
		TextColor3 = Color3.new(1, 1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false, Parent = gui,
	}, {Corner(22)})
	AccentGradient(win, fab, 45)
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

	-- ===== Notifications =====
	local notifHolder = New("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 14), Size = UDim2.fromOffset(270, 400), Parent = gui,
	}, {New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})})
	win._notifHolder = notifHolder

	close.MouseButton1Click:Connect(function() win:Toggle(false) end)
	table.insert(win._conns, UIS.InputBegan:Connect(function(i, gpe)
		if not gpe and i.KeyCode == toggleKey then win:Toggle() end
	end))

	return win
end

function Window:Toggle(v)
	if v == nil then v = not self.Visible end
	self.Visible = v
	self.Main.Visible = v
end

function Window:SetTheme(theme)
	local t = type(theme) == "string" and HelloHub.Themes[theme] or theme
	if type(t) ~= "table" then return end
	for k, v in pairs(t) do self.Theme[k] = v end
	for _, b in ipairs(self._bound) do
		local obj, prop, key = b[1], b[2], b[3]
		if obj and obj.Parent then Tween(obj, {[prop] = self.Theme[key]}, 0.25) end
	end
	for _, fn in ipairs(self._refresh) do pcall(fn) end
end

function Window:Notify(o)
	local theme = self.Theme
	local f = New("Frame", {
		Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = theme.Topbar, BorderSizePixel = 0,
		ClipsDescendants = true, Parent = self._notifHolder,
	}, {Corner(8)})
	New("UIStroke", {Color = theme.Stroke, Thickness = 1, Parent = f})
	local bar = New("Frame", {Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0, BackgroundColor3 = theme.Accent, Parent = f})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -22, 0, 18),
		Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = o.Title or "HelloHub", Parent = f,
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 26), Size = UDim2.new(1, -22, 0, 26),
		Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.SubText, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		Text = o.Content or "", Parent = f,
	})
	-- เลื่อนเข้า
	bar.Size = UDim2.new(0, 4, 1, 0)
	task.delay(o.Duration or 4, function()
		if f.Parent then
			Tween(f, {BackgroundTransparency = 1}, 0.25)
			task.wait(0.27)
			f:Destroy()
		end
	end)
end

function Window:CreateTab(name)
	local win = self
	local tab = setmetatable({Win = win, Name = name}, Tab)

	local btn = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 30), BorderSizePixel = 0, AutoButtonColor = false,
		Font = Enum.Font.GothamMedium, TextSize = 13, Text = name,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = win._sidebar,
	}, {Corner(6), New("UIPadding", {PaddingLeft = UDim.new(0, 10)})})

	local page = New("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false, Parent = win._content,
	}, {
		New("UIListLayout", {Padding = UDim.new(0, 6)}),
		New("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 10)}),
	})
	Bind(win, page, "ScrollBarImageColor3", "Accent")
	tab.Page, tab.Button = page, btn

	local function paint()
		local active = win.Current == tab
		Tween(btn, {
			BackgroundColor3 = active and win.Theme.Element or win.Theme.Sidebar,
			TextColor3 = active and win.Theme.Accent or win.Theme.SubText,
		})
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

function Window:Destroy()
	for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
	self.Gui:Destroy()
end

return HelloHub
