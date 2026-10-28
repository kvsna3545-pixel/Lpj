--[[
    HelloHub UI Library  |  v1.0.0
    ------------------------------------------------------------
    Window  : HelloHub:CreateWindow({Name, Theme, ToggleKey, Size})
    Tab     : Window:CreateTab(name)
    Element : Tab:AddSection / AddLabel / AddButton / AddToggle /
              AddSlider / AddDropdown / AddTextbox / AddKeybind
    Other   : Window:Notify / SetTheme / Toggle / Destroy
    Button  : Window:CreateFloatingButton({Name, Title, Mode="Toggle"|"Button",
              OnText, OffText, ReadyText, Cooldown, Default, Flag, Callback})
              HelloHub:CreateFloatingButton(cfg)  -- ใช้เดี่ยว ๆ ไม่ต้องมีหน้าต่าง
              คืน handle: :Set(v) :Get() :SetTitle(t) :SetVisible(b) :Destroy()
    Themes  : Hello (default, pink-purple) | Ocean | Mint | Sunset | Dark
              หรือส่ง table สีของตัวเองเข้า SetTheme ได้
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UIS              = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")

local HelloHub = {
	Version = "1.1.0",
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
	Christmas = {
		Animation   = "snow",
		Background  = Color3.fromRGB(18, 35, 42),
		Topbar      = Color3.fromRGB(23, 47, 52),
		Sidebar     = Color3.fromRGB(13, 28, 34),
		Element     = Color3.fromRGB(27, 58, 61),
		ElementHover= Color3.fromRGB(39, 83, 80),
		Accent      = Color3.fromRGB(218, 55, 68),
		Accent2     = Color3.fromRGB(205, 180, 80),
		Text        = Color3.fromRGB(245, 255, 246),
		SubText     = Color3.fromRGB(170, 211, 198),
		Stroke      = Color3.fromRGB(25, 125, 95),
	},
	Valentine = {
		Animation   = "hearts",
		Background  = Color3.fromRGB(45, 18, 34),
		Topbar      = Color3.fromRGB(58, 22, 44),
		Sidebar     = Color3.fromRGB(31, 12, 25),
		Element     = Color3.fromRGB(72, 28, 54),
		ElementHover= Color3.fromRGB(100, 38, 72),
		Accent      = Color3.fromRGB(255, 82, 145),
		Accent2     = Color3.fromRGB(255, 170, 210),
		Text        = Color3.fromRGB(255, 239, 247),
		SubText     = Color3.fromRGB(220, 160, 190),
		Stroke      = Color3.fromRGB(175, 45, 105),
	},
	Summer = {
		Animation   = "bubbles",
		Background  = Color3.fromRGB(12, 47, 64),
		Topbar      = Color3.fromRGB(15, 60, 78),
		Sidebar     = Color3.fromRGB(8, 33, 49),
		Element     = Color3.fromRGB(19, 78, 91),
		ElementHover= Color3.fromRGB(27, 108, 119),
		Accent      = Color3.fromRGB(255, 194, 62),
		Accent2     = Color3.fromRGB(50, 205, 195),
		Text        = Color3.fromRGB(239, 255, 255),
		SubText     = Color3.fromRGB(143, 211, 220),
		Stroke      = Color3.fromRGB(20, 155, 175),
	},
	Halloween = {
		Animation   = "halloween",
		Background  = Color3.fromRGB(14, 7, 18),
		Topbar      = Color3.fromRGB(30, 14, 40),
		Sidebar     = Color3.fromRGB(22, 10, 29),
		Element     = Color3.fromRGB(44, 22, 58),
		ElementHover= Color3.fromRGB(62, 32, 80),
		Accent      = Color3.fromRGB(255, 125, 20),
		Accent2     = Color3.fromRGB(165, 95, 225),
		Text        = Color3.fromRGB(255, 240, 210),
		SubText     = Color3.fromRGB(205, 170, 225),
		Stroke      = Color3.fromRGB(95, 45, 140),
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

-- "Auto" = Halloween ช่วง 6-30 ต.ค. นอกนั้น Hello
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
	if win._rows then
		table.insert(win._rows, f)
		if win.BgImage and win.BgImage.Visible then f.BackgroundTransparency = HelloHub.Glass.Card end
	end
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
-- EFFECTS (ย้ายมาจาก UI เก่า: ฉากเปิดจอเต็ม + เอฟเฟกต์บนหน้าต่าง + ตัวช่วย Glow/Pulse/...)
--   HelloHub.FX  = ตั้งเปิด/ปิดเอฟเฟกต์ Halloween (แก้ก่อน CreateWindow)
--   Window opts  = {Animation=false} ปิดทุกเอฟเฟกต์ | {Intro=false} ปิดเฉพาะฉากเปิด
----------------------------------------------------------------
HelloHub.FX = {
	Tint = true,         -- เฉดม่วง/ส้มบนพื้นหลัง
	Web = true,          -- ใยแมงมุมมุมซ้ายบน
	HeaderLine = true,   -- เส้นวิบวับใต้แถบหัว
	TitleShine = true,   -- ชื่อหน้าต่างไล่เฉดวิบวับ
	Embers = true,       -- ประกายลอยขึ้น
	Ghosts = true,       -- ผีลอยผ่านนาน ๆ ครั้ง
	Moon = true,         -- พระจันทร์เรืองแสงมุมขวาบน
	Fog = true,          -- หมอกลอยด้านล่าง
	Lightning = true,    -- ฟ้าแลบวาบ ๆ
	BorderPulse = true,  -- ขอบหน้าต่างหนาบางตามจังหวะ
	ScreenIntro = true,      -- ฉากเปิดเต็มจอ (Halloween)
	ScreenIntroOnce = true,  -- เล่นครั้งเดียวต่อการรันสคริปต์
	ScreenIntroTitle = true, -- พิมพ์ชื่อกลางจอตอนท้ายฉาก
	-- HowlSoundId = "rbxassetid://0",  -- (ไม่บังคับ) เสียงหอนตอนหมาป่ากระโดดข้ามพระจันทร์
}

local function Tw(o, time, props, style, dir)
	local tw = TweenService:Create(o, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
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

-- ===== ฉากเปิดเต็มจอ Halloween: ขอบมืด+ส้ม, พระจันทร์, ฟ้าผ่า, ฝูงค้างคาว, ตาเรืองแสง, หมาป่าวิ่งกระโดด, พิมพ์ชื่อ =====
local function BuildScreenIntro(win, titleText, subText)
	local FX = HelloHub.FX
	if not FX.ScreenIntro then return end
	if FX.ScreenIntroOnce and HelloHub._introPlayed then return end
	HelloHub._introPlayed = true

	local C = FxColors(win.Theme)
	local Root = New("Frame", {Name = "HelloIntro", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 200, Parent = win.Gui})
	local function Alive() return Root:IsDescendantOf(game) end
	local function ScreenSize()
		local s = Root.AbsoluteSize
		if s.X < 10 or s.Y < 10 then
			local cam = workspace.CurrentCamera
			return cam and cam.ViewportSize or Vector2.new(800, 450)
		end
		return s
	end
	task.delay(12, function() if Root.Parent then Root:Destroy() end end) -- กันค้าง

	-- Dim + ขอบ 4 ด้าน
	local Dim = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 2, 10), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 0, Parent = Root})
	local Edges = {}
	local function Edge(anchor, position, size, rotation)
		local f = New("Frame", {AnchorPoint = anchor, Position = position, Size = size, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1, Parent = Root})
		New("UIGradient", {
			Rotation = rotation,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, C.Primary), ColorSequenceKeypoint.new(0.14, C.Stroke1),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 16))}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.22, 0.6), NumberSequenceKeypoint.new(1, 1)}),
			Parent = f,
		})
		table.insert(Edges, f)
	end
	Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0.3, 0), 90)
	Edge(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0), UDim2.new(1, 0, 0.3, 0), 270)
	Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), UDim2.new(0.2, 0, 1, 0), 0)
	Edge(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0), UDim2.new(0.2, 0, 1, 0), 180)

	-- พระจันทร์ดวงใหญ่
	local MoonSize = math.clamp(math.floor(math.min(ScreenSize().X, ScreenSize().Y) * 0.34), 110, 200)
	local Moon = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.34, 0), Size = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.12, BorderSizePixel = 0, ZIndex = 2, Parent = Root,
	})
	Round(Moon)
	New("UIGradient", {Rotation = 90, Color = ColorSequence.new(C.FxLight, C.FxSilver), Parent = Moon})
	local Halo = AddStroke(Moon, C.FxLight, 0.78, 20)
	for _, cr in ipairs({{0.2, 0.25, 0.2}, {0.55, 0.5, 0.15}, {0.3, 0.65, 0.12}}) do
		local hole = New("Frame", {
			Position = UDim2.fromScale(cr[1], cr[2]), Size = UDim2.fromScale(cr[3], cr[3]),
			BackgroundColor3 = C.FxDark, BackgroundTransparency = 0.8, BorderSizePixel = 0, ZIndex = 3, Parent = Moon,
		})
		Round(hole)
	end

	-- ฟ้าผ่า
	local Flash = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(240, 230, 255), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 6, Parent = Root})
	local function Lightning()
		local size = ScreenSize()
		local bolt = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 5, Parent = Root})
		local prev = Vector2.new(size.X * (0.3 + math.random() * 0.4), 0)
		local SEG, pieces = 8, {}
		for _ = 1, SEG do
			local nxt = Vector2.new(prev.X + math.random(-45, 45), prev.Y + size.Y * 0.62 / SEG)
			local d, mid = nxt - prev, (prev + nxt) / 2
			local piece = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(mid.X, mid.Y),
				Size = UDim2.fromOffset(d.Magnitude + 2, 3), Rotation = math.deg(math.atan2(d.Y, d.X)),
				BackgroundColor3 = Color3.fromRGB(245, 235, 255), BorderSizePixel = 0, Parent = bolt,
			})
			table.insert(pieces, {piece, AddStroke(piece, C.FxMid, 0.45, 4)})
			prev = nxt
		end
		Flash.BackgroundTransparency = 0.3
		task.wait(0.06)
		Tw(Flash, 0.15, {BackgroundTransparency = 1})
		task.wait(0.12)
		Flash.BackgroundTransparency = 0.55
		task.wait(0.04)
		Tw(Flash, 0.3, {BackgroundTransparency = 1})
		for _, it in ipairs(pieces) do
			Tw(it[1], 0.35, {BackgroundTransparency = 1})
			Tw(it[2], 0.35, {Transparency = 1})
		end
		task.wait(0.4)
		bolt:Destroy()
	end

	-- ฝูงสัตว์บินผ่านพระจันทร์
	local function Crow(delay, y, size, duration)
		task.delay(delay, function()
			if not Alive() then return end
			local bird = Emoji("🦇", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(-0.08, 0, y, 0),
				Size = UDim2.fromOffset(size, size), TextSize = math.floor(size * 0.8),
				TextColor3 = C.Text, TextTransparency = 0.15, ZIndex = 3, Parent = Root,
			})
			local start, conn = os.clock(), nil
			conn = RunService.Heartbeat:Connect(function()
				if not Alive() then conn:Disconnect() return end
				local p = (os.clock() - start) / duration
				if p >= 1 then conn:Disconnect() bird:Destroy() return end
				bird.Position = UDim2.new(-0.08 + 1.2 * p, 0, y + math.sin(p * math.pi * 4) * 0.02, 0)
				bird.Rotation = math.sin(p * math.pi * 8) * 10
			end)
		end)
	end

	-- ตาเรืองแสงในความมืด
	local function EyePair(x, y, delay)
		task.delay(delay, function()
			if not Alive() then return end
			local pair = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(x, 0, y, 0), Size = UDim2.fromOffset(40, 12), BackgroundTransparency = 1, ZIndex = 4, Parent = Root})
			local eyes = {}
			for idx, off in ipairs({-12, 12}) do
				local eye = New("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, off, 0.5, 0), Size = UDim2.fromOffset(12, 4),
					Rotation = idx == 1 and 14 or -14, BackgroundColor3 = Color3.fromRGB(255, 170, 40),
					BackgroundTransparency = 1, BorderSizePixel = 0, Parent = pair,
				}, {Corner(2)})
				local glow = AddStroke(eye, Color3.fromRGB(255, 120, 20), 1, 3)
				Tw(eye, 0.3, {BackgroundTransparency = 0})
				Tw(glow, 0.3, {Transparency = 0.5})
				table.insert(eyes, {eye, glow})
			end
			task.wait(0.9)
			for _, it in ipairs(eyes) do it[1].Size = UDim2.fromOffset(12, 1) end
			task.wait(0.12)
			for _, it in ipairs(eyes) do it[1].Size = UDim2.fromOffset(12, 4) end
			task.wait(0.6)
			for _, it in ipairs(eyes) do Tw(it[1], 0.4, {BackgroundTransparency = 1}) Tw(it[2], 0.4, {Transparency = 1}) end
			task.wait(0.45)
			pair:Destroy()
		end)
	end

	local Howl
	if FX.HowlSoundId then
		Howl = New("Sound", {Volume = 0.6, Parent = Root})
		local id = tostring(FX.HowlSoundId)
		Howl.SoundId = tonumber(id) and ("rbxassetid://" .. id) or id
	end

	-- พิมพ์ชื่อทีละตัวอักษร + กะพริบ
	local TitleObjects = {}
	local function ShowTitle()
		if FX.ScreenIntroTitle == false then return end
		task.spawn(function()
			pcall(function()
				local text = tostring(titleText or "HelloHub")
				local label = New("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.62, 0), Size = UDim2.new(1, 0, 0, 56),
					BackgroundTransparency = 1, Text = "", TextColor3 = C.Text, TextSize = 44, Font = Enum.Font.GothamBlack, ZIndex = 8, Parent = Root,
				})
				local ls = New("UIStroke", {Color = C.Primary, Thickness = 2.5, Transparency = 0.45, Parent = label})
				local sub = New("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.62, 40), Size = UDim2.new(1, 0, 0, 20),
					BackgroundTransparency = 1, Text = tostring(subText or ""), TextColor3 = C.Primary, TextSize = 15,
					Font = Enum.Font.GothamBold, TextTransparency = 1, ZIndex = 8, Parent = Root,
				})
				TitleObjects = {label, ls, sub}
				for i = 1, (utf8.len(text) or #text) do
					if not Alive() then return end
					local cut = utf8.offset(text, i + 1)
					label.Text = cut and string.sub(text, 1, cut - 1) or text
					task.wait(0.07)
				end
				Tw(sub, 0.4, {TextTransparency = 0})
				for _ = 1, 2 do
					label.TextTransparency = 0.6 task.wait(0.05)
					label.TextTransparency = 0 task.wait(0.07)
				end
			end)
		end)
	end

	-- หมาป่า: วิ่งเข้า -> กระโดดข้ามพระจันทร์ -> วิ่งออก (มีรอยเท้า/ประกายตามหลัง)
	local function SpawnTrail(x, y, onGround)
		if onGround then
			local paw = Emoji("🐾", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(x, -34, y, -6), Size = UDim2.fromOffset(16, 16),
				TextSize = 14, TextColor3 = C.Primary, TextTransparency = 0.2, Rotation = 90, ZIndex = 4, Parent = Root,
			})
			Tw(paw, 1.2, {TextTransparency = 1})
			task.delay(1.3, function() paw:Destroy() end)
		else
			local ember = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(x, math.random(-12, 12), y, -40 + math.random(-10, 10)),
				Size = UDim2.fromOffset(4, 4), BackgroundColor3 = C.Primary, BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 6, Parent = Root,
			})
			Round(ember)
			Tw(ember, 0.7, {BackgroundTransparency = 1, Position = UDim2.new(x, math.random(-20, 20), y, -70)})
			task.delay(0.75, function() ember:Destroy() end)
		end
	end

	local function WolfRun()
		local wolf = Emoji("🐺", {
			AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(-0.12, 0, 0.94, 0), Size = UDim2.fromOffset(96, 96),
			TextSize = 72, TextColor3 = C.FxWhite, ZIndex = 7, Parent = Root,
		})
		local RunIn, Leap, RunOut = 1.1, 1.0, 0.8
		local Total = RunIn + Leap + RunOut
		local elapsed, trail, finished, pulsed, titled = 0, 0, false, false, false
		local conn
		conn = RunService.Heartbeat:Connect(function(dt)
			if not Alive() then conn:Disconnect() finished = true return end
			elapsed += dt
			trail += dt
			local X, Y, Rot, onGround
			if elapsed < RunIn then
				local u = elapsed / RunIn
				X, Y = -0.12 + 0.46 * u, 0.94 - math.abs(math.sin(u * math.pi * 5)) * 0.025
				Rot, onGround = math.sin(u * math.pi * 5) * 6, true
			elseif elapsed < RunIn + Leap then
				local u = (elapsed - RunIn) / Leap
				X, Y = 0.34 + 0.34 * u, 0.94 - 0.62 * math.sin(u * math.pi)
				Rot, onGround = -32 + 64 * u, false
				if u > 0.45 and not pulsed then
					pulsed = true
					Tw(Halo, 0.25, {Transparency = 0.4})
					Tw(Moon, 0.25, {BackgroundTransparency = 0})
					task.delay(0.3, function()
						Tw(Halo, 0.5, {Transparency = 0.78})
						Tw(Moon, 0.5, {BackgroundTransparency = 0.12})
					end)
					if Howl then pcall(function() Howl:Play() end) end
				end
			else
				local u = math.min((elapsed - RunIn - Leap) / RunOut, 1)
				X, Y = 0.68 + 0.46 * u, 0.94 - math.abs(math.sin(u * math.pi * 4)) * 0.025
				Rot, onGround = math.sin(u * math.pi * 4) * 6, true
			end
			wolf.Position = UDim2.new(X, 0, Y, 0)
			wolf.Rotation = Rot
			if elapsed > RunIn + Leap and not titled then titled = true ShowTitle() end
			if trail >= (onGround and 0.14 or 0.05) then trail = 0 SpawnTrail(X, Y, onGround) end
			if elapsed >= Total then conn:Disconnect() finished = true end
		end)
		while not finished and Alive() do task.wait() end
		wolf:Destroy()
	end

	-- Timeline
	task.spawn(function()
		pcall(function()
			Tw(Dim, 0.5, {BackgroundTransparency = 0.45})
			for _, f in ipairs(Edges) do Tw(f, 0.6, {BackgroundTransparency = 0}) end
			task.wait(0.55)
			task.spawn(Lightning)
			task.wait(0.15)
			Tw(Moon, 0.9, {Size = UDim2.fromOffset(MoonSize, MoonSize)}, Enum.EasingStyle.Back)
			Crow(0.0, 0.22, 26, 3.2) Crow(0.25, 0.30, 20, 3.4) Crow(0.45, 0.18, 22, 3.0)
			Crow(0.7, 0.38, 16, 3.6) Crow(0.9, 0.26, 18, 3.2)
			EyePair(0.06, 0.45, 0.5) EyePair(0.95, 0.6, 1.1) EyePair(0.08, 0.78, 1.7)
			task.wait(0.9)
			WolfRun()
			task.wait(1.1)
			for _, f in ipairs(Edges) do Tw(f, 0.8, {BackgroundTransparency = 1}) end
			Tw(Dim, 0.8, {BackgroundTransparency = 1})
			Tw(Moon, 0.7, {Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			if TitleObjects[1] then
				Tw(TitleObjects[1], 0.6, {TextTransparency = 1})
				Tw(TitleObjects[2], 0.6, {Transparency = 1})
				Tw(TitleObjects[3], 0.6, {TextTransparency = 1})
			end
			task.wait(0.9)
		end)
		if Root.Parent then Root:Destroy() end
	end)
end

-- ===== ฉากเปิดของธีมอื่น: clean(ดาว) / snow(หิมะ) / hearts(หัวใจ) / bubbles(ดวงอาทิตย์) =====
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

	local function sym(props) props.BackgroundTransparency = 1 props.Font = Enum.Font.GothamBold props.AnchorPoint = Vector2.new(0.5, 0.5) props.Parent = Root return New("TextLabel", props) end
	if mode == "clean" then
		for i = 1, 22 do
			local s = sym({Position = UDim2.fromScale(math.random(), math.random()), Size = UDim2.fromOffset(18, 18), Text = (i % 3 == 0 and "✦" or "."), TextColor3 = C.FxLight, TextTransparency = 1, TextSize = math.random(8, 18), ZIndex = 202})
			Tw(s, 1.1 + math.random() * 1.2, {TextTransparency = 0.2, Rotation = 180}, Enum.EasingStyle.Sine)
		end
	elseif mode == "snow" then
		for i = 1, 26 do
			local s = sym({Position = UDim2.new(math.random(), 0, math.random(-20, 20) / 100, 0), Size = UDim2.fromOffset(20, 20), Text = "❄", TextColor3 = (i % 4 == 0 and C.Stroke2 or C.FxWhite), TextTransparency = 1, TextSize = math.random(10, 22), ZIndex = 202})
			Tw(s, 1.5 + math.random() * 1.1, {Position = UDim2.new(math.random(), 0, 1.1, 0), TextTransparency = 0.12, Rotation = math.random(-60, 60)}, Enum.EasingStyle.Sine)
		end
	elseif mode == "hearts" then
		for i = 1, 16 do
			local s = sym({Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(24, 24), Text = (i % 3 == 0 and "✦" or "♥"), TextColor3 = (i % 3 == 0 and C.FxWhite or C.Primary), TextTransparency = 1, TextSize = math.random(14, 28), ZIndex = 202})
			local ang, rad = math.pi * 2 * i / 16, 0.25 + math.random() * 0.22
			Tw(s, 1.1, {Position = UDim2.fromScale(0.5 + math.cos(ang) * rad, 0.46 + math.sin(ang) * rad), TextTransparency = 0.1, Rotation = math.random(-30, 30)}, Enum.EasingStyle.Back)
		end
	else
		local sun = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(0, 0), BackgroundColor3 = C.FxLight, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 202, Parent = Root}, {Corner(200)})
		AddStroke(sun, C.Primary, 0.2, 3)
		for i = 1, 12 do
			local ray = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(4, 0), Rotation = i * 30, BackgroundColor3 = C.FxLight, BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 202, Parent = Root})
			Tw(ray, 0.9, {Size = UDim2.fromOffset(4, 110)}, Enum.EasingStyle.Back)
		end
	end
	Tw(Icon, 0.55, {Size = UDim2.fromOffset(96, 96), TextTransparency = 0}, Enum.EasingStyle.Back)
	Tw(Ring, 0.85, {Size = UDim2.fromOffset(210, 210)}, Enum.EasingStyle.Back)
	Tw(Line, 0.8, {Size = UDim2.fromOffset(230, 2)}, Enum.EasingStyle.Quart)
	Tw(Label, 0.55, {TextTransparency = 0})
	Tw(Sub, 0.75, {TextTransparency = 0})
	task.delay(1.45, function()
		if Root.Parent then
			Tw(Dim, 0.55, {BackgroundTransparency = 1})
			Tw(Icon, 0.55, {TextTransparency = 1, Size = UDim2.fromOffset(160, 160)})
			Tw(Ring, 0.7, {Size = UDim2.fromOffset(420, 420)})
			Tw(Label, 0.35, {TextTransparency = 1})
			Tw(Sub, 0.35, {TextTransparency = 1})
			task.delay(0.75, function() if Root.Parent then Root:Destroy() end end)
		end
	end)

	-- สัญลักษณ์ตกลงมาบนหน้าต่างหลัก 3 วิ
	local Layer = New("Frame", {Name = "SeasonFX", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 25, Parent = win.Main})
	local ms = mode == "clean" and "✦" or (mode == "snow" and "❄" or (mode == "hearts" and "♥" or "○"))
	for _ = 1, (mode == "snow" and 18 or 12) do
		local p = Emoji(ms, {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(math.random(5, 95) / 100, 0, math.random(0, 30) / 100, 0),
			Size = UDim2.fromOffset(22, 22), TextColor3 = (mode == "snow" and C.FxWhite or C.Primary), TextTransparency = 0.15,
			TextSize = math.random(10, 20), ZIndex = 28, Parent = Layer,
		})
		Tw(p, 1.3 + math.random() * 1.2, {Position = UDim2.new(math.random(5, 95) / 100, 0, 1.15, 0), TextTransparency = 1, Rotation = math.random(-45, 45)}, Enum.EasingStyle.Sine)
	end
	task.delay(3.2, function() if Layer.Parent then Layer:Destroy() end end)
end

-- ===== เอฟเฟกต์ติดหน้าต่าง (ธีม Halloween): tint / ใยแมงมุม / พระจันทร์ / หมอก / ถ่านไฟ / ผี / ฟ้าแลบ / ขอบเต้น =====
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
		local tint = reg(New("Frame", {Name = "HalloweenTint", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 0, Parent = main}, {Corner(10)}))
		New("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.Stroke1), ColorSequenceKeypoint.new(0.55, C.Background), ColorSequenceKeypoint.new(1, C.Stroke2)}),
			Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.84), NumberSequenceKeypoint.new(0.55, 1), NumberSequenceKeypoint.new(1, 0.82)}),
			Parent = tint,
		})
	end

	if FX.Web then
		local SIZE = 58
		local web = New("Frame", {Name = "Cobweb", Size = UDim2.fromOffset(SIZE, SIZE), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 3, Parent = Layer})
		local len = SIZE * 1.5
		for _, ang in ipairs({0, 22.5, 45, 67.5, 90}) do
			local rad = math.rad(ang)
			New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(math.cos(rad) * len / 2, math.sin(rad) * len / 2),
				Size = UDim2.fromOffset(len, 1), Rotation = ang, BackgroundColor3 = C.Text, BackgroundTransparency = 0.78, BorderSizePixel = 0, Parent = web,
			})
		end
		for _, fr in ipairs({0.32, 0.6, 0.9}) do
			local r = SIZE * fr
			local ring = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(r * 2, r * 2), BackgroundTransparency = 1, Parent = web}, {Corner(r)})
			AddStroke(ring, C.Text, 0.8, 1)
		end
	end

	-- ประกายลอยขึ้น
	local embers = {}
	if FX.Embers then
		local colors = {C.Primary, C.FxLight, C.FxMid, C.FxWhite}
		for _ = 1, 12 do
			local d = math.random(2, 3)
			local f = New("Frame", {Size = UDim2.fromOffset(d, d), BackgroundColor3 = colors[math.random(#colors)], BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1, Parent = Layer}, {Corner(3)})
			table.insert(embers, {f = f, x = 0.06 + math.random() * 0.88, speed = 0.04 + math.random() * 0.06, offset = math.random(), sway = 3 + math.random() * 6, rate = 0.8 + math.random() * 1.4, phase = math.random() * math.pi * 2})
		end
	end

	-- พระจันทร์มุมขวาบน (อยู่หลังเนื้อหา)
	local moonStroke
	if FX.Moon then
		local moon = reg(New("Frame", {
			Name = "HalloweenMoon", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -78, 0, 34),
			Size = UDim2.fromOffset(86, 86), BackgroundColor3 = C.FxLight, BackgroundTransparency = 0.86, BorderSizePixel = 0, ZIndex = 0, Parent = main,
		}, {Corner(43)}))
		moonStroke = AddStroke(moon, C.FxLight, 0.8, 6)
		for _, cr in ipairs({{18, 20, 16}, {48, 40, 12}, {30, 56, 9}}) do
			New("Frame", {Position = UDim2.fromOffset(cr[1], cr[2]), Size = UDim2.fromOffset(cr[3], cr[3]), BackgroundColor3 = C.FxDark, BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 0, Parent = moon}, {Corner(cr[3])})
		end
	end

	-- หมอกลอยด้านล่าง
	local fog = {}
	if FX.Fog then
		for _ = 1, 5 do
			local w, h = math.random(170, 240), math.random(46, 70)
			local blob = reg(New("Frame", {
				AnchorPoint = Vector2.new(0, 1), Size = UDim2.fromOffset(w, h), BackgroundColor3 = C.FxWhite,
				BackgroundTransparency = 0.93 + math.random() * 0.04, BorderSizePixel = 0, ZIndex = 0, Parent = main,
			}, {Corner(math.floor(h / 2))}))
			table.insert(fog, {f = blob, speed = 0.012 + math.random() * 0.02, offset = math.random(), y = -math.random() * 14})
		end
	end

	-- ฟ้าแลบ 3 วาบ ทุก 20-40 วิ
	if FX.Lightning then
		local flash = New("Frame", {Name = "HalloweenFlash", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(235, 220, 255), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 40, Parent = Layer}, {Corner(10)})
		task.spawn(function()
			task.wait(12 + math.random() * 10)
			while not fx.dead do
				for _, s in ipairs({0.84, 0.93, 0.8}) do
					flash.BackgroundTransparency = s
					task.wait(0.05)
					Tw(flash, 0.12, {BackgroundTransparency = 1})
					task.wait(0.1)
				end
				task.wait(20 + math.random() * 20)
			end
		end)
	end

	local mainStroke = FX.BorderPulse and win._mainStroke or nil
	local clock, nextGhost, ghosts = 0, 5 + math.random() * 5, {}
	table.insert(fx.conns, RunService.Heartbeat:Connect(function(dt)
		if fx.dead or win.Destroyed then return end
		clock += dt
		if FX.HeaderLine and win._lineGrad then win._lineGrad.Offset = Vector2.new((clock * 0.35) % 2 - 1, 0) end
		if FX.TitleShine and win._titleGrad then win._titleGrad.Offset = Vector2.new((clock * 0.5) % 2 - 1, 0) end
		if mainStroke then mainStroke.Thickness = 1.7 + 0.9 * (0.5 + 0.5 * math.sin(clock * 1.8)) end
		if moonStroke then moonStroke.Transparency = 0.8 + 0.12 * math.sin(clock * 1.2) end

		for _, c in ipairs(fog) do
			c.f.Position = UDim2.new(-0.25 + 1.5 * ((clock * c.speed + c.offset) % 1), 0, 1, c.y)
		end
		for _, e in ipairs(embers) do
			local fr = (clock * e.speed + e.offset) % 1
			e.f.Position = UDim2.new(e.x, math.sin(clock * e.rate + e.phase) * e.sway, 1 - fr, 0)
			e.f.BackgroundTransparency = 0.5 + 0.45 * math.abs(fr * 2 - 1)
		end

		if FX.Ghosts and clock >= nextGhost then
			nextGhost = clock + 9 + math.random() * 7
			local g = Emoji("👻", {Name = "Wisp", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(22, 22), TextSize = 18, TextColor3 = C.Text, TextTransparency = 1, ZIndex = 2, Parent = Layer})
			table.insert(ghosts, {o = g, born = clock, dur = 8 + math.random() * 3, dir = math.random() < 0.5 and 1 or -1, y = 0.25 + math.random() * 0.5})
		end
		for i = #ghosts, 1, -1 do
			local g = ghosts[i]
			local p = (clock - g.born) / g.dur
			if p >= 1 then
				g.o:Destroy() table.remove(ghosts, i)
			else
				local x = g.dir == 1 and (-0.05 + p * 1.1) or (1.05 - p * 1.1)
				g.o.Position = UDim2.new(x, 0, g.y, math.sin(p * 12) * 8)
				g.o.Rotation = math.sin(p * 9) * 8
				g.o.TextTransparency = 1 - 0.45 * math.sin(p * math.pi)
			end
		end
	end))
end

-- ===== ตัวช่วยเอฟเฟกต์ใช้กับ GUI object ใดก็ได้ =====
-- HelloHub.Effects:Glow(obj, color) / :Pulse(obj) / :Shake(obj, strength) / :Rainbow(obj) / :Fire(container)
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

function HelloHub.Effects:Rainbow(obj)
	if not obj then return end
	local g = obj:FindFirstChild("HelloHub_Rainbow")
	if not g then
		g = New("UIGradient", {
			Name = "HelloHub_Rainbow",
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 70)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 210, 70)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(80, 255, 120)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(80, 180, 255)),
				ColorSequenceKeypoint.new(0.8, Color3.fromRGB(170, 90, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 180)),
			}),
			Parent = obj,
		})
	end
	task.spawn(function()
		while obj.Parent do
			g.Rotation = (g.Rotation + 2) % 360
			task.wait(0.03)
		end
	end)
	return g
end

function HelloHub.Effects:Fire(container)
	if not container then return end
	local holder = container:FindFirstChild("HelloHub_Fire")
	if holder then return holder end
	holder = New("Frame", {Name = "HelloHub_Fire", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 5, Parent = container})
	task.spawn(function()
		while holder.Parent do
			local x = math.random(5, 95) / 100
			local e = New("Frame", {
				Size = UDim2.fromOffset(math.random(3, 7), math.random(3, 7)), Position = UDim2.new(x, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(255, math.random(80, 190), math.random(20, 70)),
				BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 6, Parent = holder,
			}, {Corner(20)})
			local tw = Tw(e, math.random(12, 22) / 10, {Position = UDim2.new(x, 0, -0.15, 0), BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 1)})
			tw.Completed:Connect(function() e:Destroy() end)
			task.wait(math.random(10, 24) / 100)
		end
	end)
	return holder
end

----------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------
----------------------------------------------------------------
-- BACKGROUND (พื้นหลังรูปภาพ + โหมดกระจก)  ย้ายมาจาก UI เก่า
--   ใส่รูปได้ 3 แบบ (เรียงลำดับความสำคัญ):
--   1) Image = "rbxassetid://ไอดีรูป"
--   2) File  = "HelloHub_bg.jpg"  (ไฟล์ใน workspace ของ executor)
--   3) Url   = "https://..."      (โหลดมาเซฟเป็น File ให้ครั้งแรก)
--   ตั้งค่าได้ที่ HelloHub.Background (ทั้งระบบ) หรือ CreateWindow({Background = {...}})
--   ปิดด้วย CreateWindow({Background = false}) | เปลี่ยนทีหลังด้วย Window:SetBackground(...)
----------------------------------------------------------------
HelloHub.Background = {
	Enabled = true,
	Image = "",
	File = "HelloHub_bg.jpg",
	Url = "",
	Transparency = 0.5,   -- 0 = เห็นรูปชัด, 1 = ซ่อนรูป
}
-- ความโปร่งใสของ "กระจก" เมื่อมีรูปพื้นหลัง (0 = ทึบ, 1 = ใส)
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

-- ถ้าใส่ไอดีเป็น Decal จะแปลงเป็น Image ให้อัตโนมัติ
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
		task.wait(5)
		if img.Parent and not img.IsLoaded then
			warn("[HelloHub] โหลดรูปพื้นหลังไม่ขึ้น: " .. tostring(img.Image) .. " (เช็กว่าเป็น Image ID ไม่ใช่ Decal / ตั้งสิทธิ์ใช้ได้)")
		end
	end)
end

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

-- Window:SetBackground("rbxassetid://123") หรือ {Image=..., File=..., Url=..., Transparency=0.4, Enabled=true}
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
	win._lineGrad = AccentGradient(win, line)

	local title = Label(win, top, name, 16, "Text")
	title.Font = Enum.Font.GothamBold
	title.Position = UDim2.fromOffset(14, 0)
	title.Size = UDim2.new(0.6, 0, 1, -2)
	title.TextColor3 = Color3.new(1, 1, 1)
	win._titleGrad = AccentGradient(win, title)
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

	-- ===== พื้นหลังรูปภาพ + กระจก =====
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
	}, {Corner(10)})
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

	-- ===== เอฟเฟกต์จาก UI เก่า =====
	win.Title = name
	win.Subtitle = opts.Subtitle or ("HelloHub v" .. HelloHub.Version)
	win.Destroyed = false
	win._mainStroke = mainStroke
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
	if self.Main and self._animation then BuildWindowFX(self) end  -- สร้างเอฟเฟกต์บนหน้าต่างใหม่ตามธีม
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

----------------------------------------------------------------
-- FLOATING BUTTON  (ปุ่มลอยลากได้)
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
	local mode     = cfg.Mode or "Toggle"          -- "Toggle" | "Button"
	local callback = cfg.Callback or function() end
	local effects  = cfg.Effects ~= false            -- เอฟเฟกต์อวกาศ/ฮาโลวีน (ปิดได้ด้วย Effects=false)
	local W, H     = cfg.Width or (effects and 160 or 150), cfg.Height or (effects and 60 or 52)
	local TX       = effects and 60 or 18             -- ตำแหน่งเริ่มข้อความ
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

	-- ===== เอฟเฟกต์: ดาวกะพริบ / ดาวเคราะห์ (ฟักทองตอน Halloween) / วงโคจร / ดาวตก / ค้างคาว =====
	if effects then
		local PX = 31
		local starsList, orbiters = {}, {}
		local function kp(t, c) return ColorSequenceKeypoint.new(t, c) end

		local function addStar(parent, x, y, size, key, z)
			local f = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, x, 0.5, y),
				Size = UDim2.fromOffset(size, size), BorderSizePixel = 0,
				BackgroundTransparency = 0.9, ZIndex = z, Parent = parent,
			}, {Corner(3)})
			Bind(win, f, "BackgroundColor3", key)
			table.insert(starsList, {f = f, rate = 1.5 + math.random() * 2.5, phase = math.random() * math.pi * 2})
		end
		local innerKeys = {"Text", "SubText", "Accent2"}
		local outerKeys = {"Text", "SubText", "Accent2", "Text"}

		for _ = 1, 8 do
			local a = math.random() * math.pi * 2
			local r = math.sqrt(math.random())
			addStar(inner, (-W / 2 + PX) + math.cos(a) * r * 26, math.sin(a) * r * (H / 2 - 10),
				math.random(1, 2), innerKeys[math.random(#innerKeys)], 2)
		end

		local planet = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, PX, 0.5, 0),
			Size = UDim2.fromOffset(26, 26), BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0, ZIndex = 3, Parent = inner,
		}, {Corner(13)})
		local pGrad = New("UIGradient", {Rotation = 45, Parent = planet})

		local ring = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, PX, 0.5, 0),
			Size = UDim2.fromOffset(46, 14), BackgroundTransparency = 1, Rotation = -22,
			ZIndex = 4, Parent = inner,
		}, {Corner(8)})
		local ringStroke = New("UIStroke", {Thickness = 2, Transparency = 0.15, Parent = ring})
		Bind(win, ringStroke, "Color", "SubText")

		-- หน้าฟักทอง (แสดงเฉพาะธีม Halloween)
		local FACE_OFF, FACE_ON = Color3.fromRGB(40, 14, 48), Color3.fromRGB(255, 235, 120)
		local face = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 4, Parent = planet})
		local faceParts = {}
		local function part(x, y, w, h, rot, rad, color, isFace)
			local p = New("Frame", {
				Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), Rotation = rot,
				BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 4, Parent = face,
			}, {Corner(rad)})
			if isFace then table.insert(faceParts, p) end
		end
		part(5, 8, 5, 5, 45, 1, FACE_OFF, true)
		part(16, 8, 5, 5, 45, 1, FACE_OFF, true)
		part(7, 16, 12, 5, 0, 2, FACE_OFF, true)
		part(11, -3, 5, 6, -12, 2, Color3.fromRGB(80, 130, 50), false)
		setFace = function(on)
			for _, p in ipairs(faceParts) do Tween(p, {BackgroundColor3 = on and FACE_ON or FACE_OFF}, 0.3) end
		end

		OnRefresh(win, function()
			local t = win.Theme
			pGrad.Color = ColorSequence.new({
				kp(0, t.Text:Lerp(t.Accent, 0.35)), kp(0.6, t.Accent), kp(1, t.Accent2:Lerp(t.Background, 0.5)),
			})
			local hw = win.ThemeName == "Halloween"
			face.Visible, ring.Visible = hw, not hw
		end)

		-- วงเรืองแสงรอบปุ่ม
		local fx = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 5, Parent = button})
		local function nebula(pad, thick, transp)
			local r = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, pad, 1, pad), BackgroundTransparency = 1, ZIndex = 4, Parent = fx,
			}, {Corner(H / 2 + pad / 2)})
			local s = New("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = thick, Transparency = transp, Parent = r})
			local g = New("UIGradient", {Parent = s})
			OnRefresh(win, function()
				g.Color = ColorSequence.new({kp(0, win.Theme.Accent), kp(0.5, win.Theme.Accent2), kp(1, win.Theme.Accent)})
			end)
			return s, g
		end
		local glowS, glowG = nebula(16, 6, 0.8)
		local _, sharpG = nebula(9, 1.5, 0.25)

		for _ = 1, 14 do
			local a = math.random() * math.pi * 2
			local gap = math.random(14, 30)
			addStar(fx, math.cos(a) * (W / 2 + gap), math.sin(a) * (H / 2 + gap),
				math.random(2, 3), outerKeys[math.random(#outerKeys)], 6)
		end

		-- ดวงโคจรรอบปุ่ม (มีหางตามหลัง)
		local orbitDefs = {
			{Gap = 14, Size = 7, Speed = 1.1,  Phase = 0,   Key = "Text"},
			{Gap = 22, Size = 5, Speed = -0.75, Phase = 2.1, Key = "SubText"},
			{Gap = 30, Size = 4, Speed = 0.5,  Phase = 4.2, Key = "Accent2"},
		}
		local tilt = math.rad(-20)
		for _, d in ipairs(orbitDefs) do
			d.RX, d.RY, d.Dots = W / 2 + d.Gap, H / 2 + d.Gap * 0.8, {}
			for k = 1, 4 do
				local s = d.Size * (1 - (k - 1) * 0.2)
				local dot = New("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(s, s),
					BackgroundTransparency = (k - 1) * 0.22, BorderSizePixel = 0, ZIndex = 7, Parent = fx,
				}, {Corner(10)})
				Bind(win, dot, "BackgroundColor3", d.Key)
				d.Dots[k] = dot
			end
			table.insert(orbiters, d)
		end

		fxUpdate = function(clk)
			glowS.Transparency = 0.72 + 0.16 * math.sin(clk * 2)
			glowG.Rotation = (clk * 50) % 360
			sharpG.Rotation = (-clk * 72) % 360
			for _, s in ipairs(starsList) do
				s.f.BackgroundTransparency = 0.5 + 0.45 * math.sin(clk * s.rate + s.phase)
			end
			planet.Position = UDim2.new(0, PX, 0.5, math.sin(clk * 1.6) * 1.5)
			ring.Rotation = -22 + math.sin(clk * 1.2) * 5
			for _, d in ipairs(orbiters) do
				local dir = d.Speed > 0 and 1 or -1
				for k, dot in ipairs(d.Dots) do
					local a = d.Phase + clk * d.Speed - (k - 1) * 0.16 * dir
					local x, y = math.cos(a) * d.RX, math.sin(a) * d.RY
					dot.Position = UDim2.new(0.5, x * math.cos(tilt) - y * math.sin(tilt),
						0.5, x * math.sin(tilt) + y * math.cos(tilt))
					local s = d.Size * (1 - (k - 1) * 0.2) * (1 + 0.25 * math.sin(a))
					dot.Size = UDim2.fromOffset(s, s)
				end
			end
		end

		-- ค้างคาวบิน (Halloween) / ดาวตก (ธีมอื่น) ทุก 3-6 วิ
		task.spawn(function()
			while not dead do
				task.wait(math.random(3, 6))
				if dead then break end
				local yo = math.random(-6, 6)
				if win.ThemeName == "Halloween" then
					local bat = New("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(20, 20),
						Position = UDim2.new(0.5, W / 2 + 40, 0.5, -(H / 2 + 22) + yo),
						BackgroundTransparency = 1, Text = "🦇", TextSize = 16,
						TextColor3 = win.Theme.Text, ZIndex = 8, Parent = fx,
					})
					Tween(bat, {Position = UDim2.new(0.5, -(W / 2 + 40), 0.5, -(H / 2 + 6) + yo), TextTransparency = 1}, 1.3)
					task.delay(1.35, function() bat:Destroy() end)
				else
					local streak = New("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(28, 2),
						Position = UDim2.new(0.5, W / 2 + 40, 0.5, -(H / 2 + 30) + yo), Rotation = -9,
						BackgroundColor3 = win.Theme.Text, BorderSizePixel = 0, ZIndex = 8, Parent = fx,
					})
					New("UIGradient", {Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}), Parent = streak})
					Tween(streak, {Position = UDim2.new(0.5, -(W / 2 + 40), 0.5, -(H / 2 + 8) + yo), BackgroundTransparency = 1}, 0.8)
					task.delay(0.85, function() streak:Destroy() end)
				end
			end
		end)
	end

	local titleL = Label(win, inner, cfg.Title or name, 13, "Text")
	titleL.Font = Enum.Font.GothamBold
	titleL.Position = UDim2.new(0, TX, 0.5, -17)
	titleL.Size = UDim2.new(1, -(TX + 12), 0, 16)
	titleL.TextTruncate = Enum.TextTruncate.AtEnd
	-- (ไม่ bind สี Title ตรง ๆ เพราะจะ tween เองตามสถานะ)

	local dot = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, TX + 4, 0.5, 9),
		Size = UDim2.fromOffset(8, 8), BorderSizePixel = 0, Parent = inner,
	}, {Corner(4)})
	local statusL = Label(win, inner, "", 12, "SubText")
	statusL.Position = UDim2.new(0, TX + 15, 0.5, 1)
	statusL.Size = UDim2.new(1, -(TX + 27), 0, 16)

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

	-- ===== animation (ลาก + ขอบหมุน) =====
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

	-- ===== hover / drag =====
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

	-- ===== click =====
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

-- ผูกกับหน้าต่าง (อยู่/ตายพร้อมหน้าต่าง, เปลี่ยนสีตาม SetTheme)
function Window:CreateFloatingButton(cfg)
	return BuildFloatingButton(self, cfg, false)
end

-- ใช้ได้โดยไม่ต้องสร้างหน้าต่าง
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
