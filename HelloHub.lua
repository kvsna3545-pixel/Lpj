--[[
=========================================================
                  HELLOHUB UI LIBRARY
                       v1.0.0
=========================================================

COMPONENTS
- Window (drag, minimize, hide/show, floating button, intro)
- Tab / Section
- Label, Button, Toggle, Slider, Input
- Dropdown (single / multi), Keybind, ColorPicker
- Notify (info / success / warning / error)

THEMES (live switch)
- "Hello"    sky blue + sunny yellow  (default)
- "Sunny"    warm yellow
- "Midnight" indigo + pink

USAGE
    local HelloHub = loadstring(game:HttpGet("YOUR_RAW_URL"))()
    local Win = HelloHub:CreateWindow({ Title = "HelloHub" })
    local Tab = Win:CreateTab("Main", "home")
    Tab:CreateButton({ Name = "Hi", Callback = function() print("hi") end })

=========================================================
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local HelloHub = {
	Name = "HelloHub",
	Version = "1.0.0",
}

--=========================================================
-- THEMES
--=========================================================

HelloHub.Themes = {

	Hello = {
		Background = Color3.fromRGB(13, 19, 33),
		Sidebar = Color3.fromRGB(9, 14, 25),
		Card = Color3.fromRGB(21, 31, 50),
		CardHover = Color3.fromRGB(30, 44, 70),
		Primary = Color3.fromRGB(56, 189, 248),
		Accent = Color3.fromRGB(253, 224, 71),
		Text = Color3.fromRGB(240, 248, 255),
		SubText = Color3.fromRGB(140, 163, 192),
		ToggleOff = Color3.fromRGB(52, 65, 90),
		Stroke = Color3.fromRGB(40, 58, 88),
		Success = Color3.fromRGB(74, 222, 128),
		Danger = Color3.fromRGB(248, 113, 113),
		Warning = Color3.fromRGB(251, 191, 36),
		OnPrimary = Color3.fromRGB(8, 20, 36),
	},

	Sunny = {
		Background = Color3.fromRGB(30, 24, 12),
		Sidebar = Color3.fromRGB(22, 17, 8),
		Card = Color3.fromRGB(46, 37, 18),
		CardHover = Color3.fromRGB(66, 53, 24),
		Primary = Color3.fromRGB(250, 204, 21),
		Accent = Color3.fromRGB(56, 189, 248),
		Text = Color3.fromRGB(255, 250, 235),
		SubText = Color3.fromRGB(196, 180, 140),
		ToggleOff = Color3.fromRGB(80, 68, 40),
		Stroke = Color3.fromRGB(96, 78, 30),
		Success = Color3.fromRGB(74, 222, 128),
		Danger = Color3.fromRGB(248, 113, 113),
		Warning = Color3.fromRGB(251, 146, 60),
		OnPrimary = Color3.fromRGB(34, 26, 4),
	},

	Midnight = {
		Background = Color3.fromRGB(16, 16, 26),
		Sidebar = Color3.fromRGB(11, 11, 19),
		Card = Color3.fromRGB(26, 27, 42),
		CardHover = Color3.fromRGB(38, 40, 62),
		Primary = Color3.fromRGB(129, 140, 248),
		Accent = Color3.fromRGB(244, 114, 182),
		Text = Color3.fromRGB(240, 241, 255),
		SubText = Color3.fromRGB(150, 154, 190),
		ToggleOff = Color3.fromRGB(58, 60, 88),
		Stroke = Color3.fromRGB(52, 54, 86),
		Success = Color3.fromRGB(74, 222, 128),
		Danger = Color3.fromRGB(248, 113, 113),
		Warning = Color3.fromRGB(251, 191, 36),
		OnPrimary = Color3.fromRGB(14, 14, 36),
	},
}

HelloHub.Theme = HelloHub.Themes.Hello
HelloHub.ThemeName = "Hello"

--=========================================================
-- INTERNAL HELPERS
--=========================================================

local Bound = {} -- { object, property, themeKey }
local Hooks = {} -- { win, fn }

local function Create(className, props)
	local obj = Instance.new(className)
	local parent

	for key, value in pairs(props or {}) do
		if key == "Parent" then
			parent = value
		else
			obj[key] = value
		end
	end

	if parent then
		obj.Parent = parent
	end

	return obj
end

local function Bind(obj, property, key)
	obj[property] = HelloHub.Theme[key]
	table.insert(Bound, { obj, property, key })
	return obj
end

local function Hook(win, fn)
	table.insert(Hooks, { win = win, fn = fn })
	fn()
end

local function Tween(obj, time, props, style, direction)
	local tween = TweenService:Create(
		obj,
		TweenInfo.new(
			time or 0.2,
			style or Enum.EasingStyle.Quad,
			direction or Enum.EasingDirection.Out
		),
		props
	)
	tween:Play()
	return tween
end

local function Corner(obj, radius)
	return Create("UICorner", {
		CornerRadius = UDim.new(0, radius or 8),
		Parent = obj,
	})
end

local function Stroke(obj, color, transparency, thickness)
	return Create("UIStroke", {
		Color = color or Color3.new(1, 1, 1),
		Transparency = transparency or 0,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = obj,
	})
end

local function Padding(obj, top, right, bottom, left)
	return Create("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft = UDim.new(0, left or 0),
		Parent = obj,
	})
end

local function ListLayout(obj, gap)
	return Create("UIListLayout", {
		Padding = UDim.new(0, gap or 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = obj,
	})
end

local function Fire(callback, ...)
	if type(callback) == "function" then
		task.spawn(callback, ...)
	end
end

local function GetGuiParent()
	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end

	local ok, core = pcall(function()
		return game:GetService("CoreGui")
	end)

	if ok and core then
		-- ทดสอบว่าเขียนลง CoreGui ได้จริงไหม
		local test = Instance.new("Folder")
		local success = pcall(function()
			test.Parent = core
		end)
		test:Destroy()
		if success then
			return core
		end
	end

	return LocalPlayer:WaitForChild("PlayerGui")
end

local Glyphs = {
	home = "⌂", main = "⌂", house = "⌂",
	settings = "⚙", setting = "⚙", cog = "⚙",
	combat = "⚔", sword = "⚔",
	visuals = "◉", eye = "◉",
	player = "☻", user = "☻",
	misc = "◈", star = "★", info = "ℹ",
	teleport = "➤", farm = "✿", bolt = "⚡", zap = "⚡",
	heart = "♥", list = "☰", menu = "☰", search = "⌕",
}

--=========================================================
-- THEME SWITCH
--=========================================================

function HelloHub:SetTheme(name)
	local theme = self.Themes[name]
	if not theme then
		return false
	end

	self.Theme = theme
	self.ThemeName = name

	for i = #Bound, 1, -1 do
		local item = Bound[i]
		if item[1]:IsDescendantOf(game) then
			item[1][item[2]] = theme[item[3]]
		else
			table.remove(Bound, i)
		end
	end

	for i = #Hooks, 1, -1 do
		local hook = Hooks[i]
		if hook.win.Destroyed then
			table.remove(Hooks, i)
		else
			pcall(hook.fn)
		end
	end

	return true
end

function HelloHub:AddTheme(name, theme)
	local base = self.Themes.Hello
	local merged = {}
	for key, value in pairs(base) do
		merged[key] = value
	end
	for key, value in pairs(theme or {}) do
		merged[key] = value
	end
	self.Themes[name] = merged
end

--=========================================================
-- ELEMENT FACTORY
-- ใช้ร่วมกันระหว่าง Tab และ Section
--=========================================================

local function MakeCard(height)
	local card = Create("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})
	Bind(card, "BackgroundColor3", "Card")
	Corner(card, 8)
	Bind(Stroke(card, nil, 0.4, 1), "Color", "Stroke")
	return card
end

local function Hover(card)
	card.MouseEnter:Connect(function()
		Tween(card, 0.15, { BackgroundColor3 = HelloHub.Theme.CardHover })
	end)
	card.MouseLeave:Connect(function()
		Tween(card, 0.15, { BackgroundColor3 = HelloHub.Theme.Card })
	end)
end

local function CardLabels(card, name, description, rightPad)
	local title = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, description and 6 or 0),
		Size = UDim2.new(1, -(rightPad or 12) - 12, 0, description and 18 or 38),
		Text = name or "",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	Bind(title, "TextColor3", "Text")

	if description then
		local sub = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 24),
			Size = UDim2.new(1, -(rightPad or 12) - 12, 0, 14),
			Text = description,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = card,
		})
		Bind(sub, "TextColor3", "SubText")
	end

	return title
end

local function ClickArea(card)
	return Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 2,
		Parent = card,
	})
end

-- แถบลาก (ใช้กับ Slider / ColorPicker)
local function DragBar(win, track, onAlpha)
	local dragging = false

	local function Update(x)
		local width = math.max(track.AbsoluteSize.X, 1)
		local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
		onAlpha(alpha)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			Update(input.Position.X)
		end
	end)

	win.Connect(UserInputService.InputChanged, function(input)
		if dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
			Update(input.Position.X)
		end
	end)

	win.Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local function AddElements(self, parent, win)
	local order = 0

	local function Place(obj)
		order += 1
		obj.LayoutOrder = order
		obj.Parent = parent
	end

	local function SaveFlag(cfg, value)
		if cfg.Flag then
			win.Flags[cfg.Flag] = value
		end
	end

	------------------------------------------------------
	-- SECTION
	------------------------------------------------------

	function self:CreateSection(title)
		local container = Create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		ListLayout(container, 6)

		local header = Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Text = string.upper(tostring(title or "Section")),
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 0,
			Parent = container,
		})
		Bind(header, "TextColor3", "Accent")
		Padding(header, 0, 0, 0, 2)

		Place(container)

		local section = {}
		AddElements(section, container, win)
		return section
	end

	------------------------------------------------------
	-- LABEL
	------------------------------------------------------

	function self:CreateLabel(text)
		local label = Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = tostring(text or ""),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		Bind(label, "TextColor3", "SubText")
		Padding(label, 2, 4, 2, 4)
		Place(label)

		local obj = {}
		function obj:Set(value)
			label.Text = tostring(value)
		end
		return obj
	end

	------------------------------------------------------
	-- BUTTON
	------------------------------------------------------

	function self:CreateButton(cfg)
		cfg = cfg or {}

		local card = MakeCard(cfg.Description and 46 or 38)
		CardLabels(card, cfg.Name or "Button", cfg.Description, 28)

		local arrow = Create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			BackgroundTransparency = 1,
			Text = "›",
			Font = Enum.Font.GothamBold,
			TextSize = 20,
			Parent = card,
		})
		Bind(arrow, "TextColor3", "Primary")

		Hover(card)

		local click = ClickArea(card)
		click.MouseButton1Click:Connect(function()
			card.BackgroundColor3 = HelloHub.Theme.Primary
			Tween(card, 0.3, { BackgroundColor3 = HelloHub.Theme.Card })
			Fire(cfg.Callback)
		end)

		Place(card)
	end

	------------------------------------------------------
	-- TOGGLE
	------------------------------------------------------

	function self:CreateToggle(cfg)
		cfg = cfg or {}

		local state = cfg.Default == true
		local card = MakeCard(cfg.Description and 46 or 38)
		CardLabels(card, cfg.Name or "Toggle", cfg.Description, 58)

		local switch = Create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(38, 20),
			BorderSizePixel = 0,
			Parent = card,
		})
		Corner(switch, 10)

		local knob = Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Parent = switch,
		})
		Corner(knob, 7)

		local function Render(animate)
			local theme = HelloHub.Theme
			local duration = animate and 0.18 or 0
			Tween(switch, duration, {
				BackgroundColor3 = state and theme.Primary or theme.ToggleOff,
			})
			Tween(knob, duration, {
				Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			})
		end

		local obj = {}

		function obj:Set(value, silent)
			state = value == true
			Render(true)
			SaveFlag(cfg, state)
			if not silent then
				Fire(cfg.Callback, state)
			end
		end

		function obj:Get()
			return state
		end

		Hook(win, function()
			Render(false)
		end)
		SaveFlag(cfg, state)

		Hover(card)
		ClickArea(card).MouseButton1Click:Connect(function()
			obj:Set(not state)
		end)

		Place(card)
		return obj
	end

	------------------------------------------------------
	-- SLIDER
	------------------------------------------------------

	function self:CreateSlider(cfg)
		cfg = cfg or {}

		local min = cfg.Min or 0
		local max = cfg.Max or 100
		local increment = cfg.Increment or 1
		local suffix = cfg.Suffix or ""
		local value = math.clamp(cfg.Default or min, min, max)

		local card = MakeCard(52)

		local title = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 6),
			Size = UDim2.new(0.65, -12, 0, 18),
			Text = cfg.Name or "Slider",
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card,
		})
		Bind(title, "TextColor3", "Text")

		local valueLabel = Create("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 6),
			Size = UDim2.new(0.35, -12, 0, 18),
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})
		Bind(valueLabel, "TextColor3", "Primary")

		local track = Create("Frame", {
			Position = UDim2.new(0, 12, 0, 35),
			Size = UDim2.new(1, -24, 0, 6),
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = card,
		})
		Bind(track, "BackgroundColor3", "ToggleOff")
		Corner(track, 3)

		local fill = Create("Frame", {
			Size = UDim2.fromScale(0, 1),
			BorderSizePixel = 0,
			Parent = track,
		})
		Bind(fill, "BackgroundColor3", "Primary")
		Corner(fill, 3)

		local knob = Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = track,
		})
		Corner(knob, 6)

		local obj = {}

		local function SetValue(v, fire)
			v = math.clamp(math.floor((v - min) / increment + 0.5) * increment + min, min, max)
			v = tonumber(string.format("%.4f", v))

			local changed = v ~= value
			value = v

			local alpha = (max - min) == 0 and 0 or (v - min) / (max - min)
			Tween(fill, 0.08, { Size = UDim2.fromScale(alpha, 1) })
			Tween(knob, 0.08, { Position = UDim2.new(alpha, 0, 0.5, 0) })
			valueLabel.Text = tostring(v) .. suffix
			SaveFlag(cfg, v)

			if fire and changed then
				Fire(cfg.Callback, v)
			end
		end

		function obj:Set(v, silent)
			SetValue(v, not silent)
		end

		function obj:Get()
			return value
		end

		DragBar(win, track, function(alpha)
			SetValue(min + (max - min) * alpha, true)
		end)

		task.defer(function()
			SetValue(value, false)
		end)

		Hover(card)
		Place(card)
		return obj
	end

	------------------------------------------------------
	-- INPUT
	------------------------------------------------------

	function self:CreateInput(cfg)
		cfg = cfg or {}

		local card = MakeCard(cfg.Description and 46 or 38)
		CardLabels(card, cfg.Name or "Input", cfg.Description, 150)

		local box = Create("TextBox", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(130, 24),
			BorderSizePixel = 0,
			Text = cfg.Default or "",
			PlaceholderText = cfg.Placeholder or "Type here...",
			ClearTextOnFocus = cfg.ClearOnFocus == true,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = card,
		})
		Bind(box, "BackgroundColor3", "Background")
		Bind(box, "TextColor3", "Text")
		Bind(box, "PlaceholderColor3", "SubText")
		Corner(box, 6)
		Padding(box, 0, 6, 0, 6)

		local boxStroke = Stroke(box, nil, 0.5, 1)
		Bind(boxStroke, "Color", "Stroke")

		box.Focused:Connect(function()
			boxStroke.Color = HelloHub.Theme.Primary
			boxStroke.Transparency = 0
		end)

		box.FocusLost:Connect(function(enterPressed)
			boxStroke.Color = HelloHub.Theme.Stroke
			boxStroke.Transparency = 0.5
			SaveFlag(cfg, box.Text)
			if enterPressed or cfg.CallbackOnBlur then
				Fire(cfg.Callback, box.Text)
			end
		end)

		local obj = {}
		function obj:Set(text)
			box.Text = tostring(text)
			SaveFlag(cfg, box.Text)
		end
		function obj:Get()
			return box.Text
		end

		Place(card)
		return obj
	end

	------------------------------------------------------
	-- DROPDOWN (single / multi)
	------------------------------------------------------

	function self:CreateDropdown(cfg)
		cfg = cfg or {}

		local options = cfg.Options or {}
		local multi = cfg.Multi == true
		local open = false

		local current = nil
		local picked = {}

		if multi then
			if type(cfg.Default) == "table" then
				for _, name in ipairs(cfg.Default) do
					picked[name] = true
				end
			end
		else
			current = cfg.Default
		end

		local card = MakeCard(38)

		local header = Create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 38),
			Parent = card,
		})

		local title = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(0.5, -12, 1, 0),
			Text = cfg.Name or "Dropdown",
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		Bind(title, "TextColor3", "Text")

		local valueLabel = Create("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -30, 0, 0),
			Size = UDim2.new(0.5, -34, 1, 0),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		Bind(valueLabel, "TextColor3", "Primary")

		local arrow = Create("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			Text = "▾",
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			Parent = header,
		})
		Bind(arrow, "TextColor3", "SubText")

		local list = Create("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 44),
			Size = UDim2.new(1, -16, 1, -50),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 2,
			Parent = card,
		})
		Bind(list, "ScrollBarImageColor3", "Primary")
		ListLayout(list, 2)

		local buttons = {}

		local function PickedArray()
			local result = {}
			for _, name in ipairs(options) do
				if picked[name] then
					table.insert(result, name)
				end
			end
			return result
		end

		local function RefreshText()
			if multi then
				local array = PickedArray()
				valueLabel.Text = #array > 0 and table.concat(array, ", ") or "None"
			else
				valueLabel.Text = current ~= nil and tostring(current) or "Select..."
			end
		end

		local function Restyle()
			local theme = HelloHub.Theme
			for name, button in pairs(buttons) do
				local active = multi and picked[name] or (not multi and current == name)
				button.TextColor3 = active and theme.Primary or theme.Text
				button.BackgroundColor3 = theme.Background
				button.BackgroundTransparency = active and 0 or 1
			end
		end

		local function Resize()
			local rows = math.min(#options, 6)
			local height = open and (38 + 12 + rows * 28) or 38
			Tween(card, 0.2, { Size = UDim2.new(1, 0, 0, height) })
			Tween(arrow, 0.2, { Rotation = open and 180 or 0 })
		end

		local obj = {}

		local function Commit(name)
			if multi then
				picked[name] = not picked[name] or nil
				SaveFlag(cfg, PickedArray())
				Fire(cfg.Callback, PickedArray())
			else
				current = name
				open = false
				Resize()
				SaveFlag(cfg, current)
				Fire(cfg.Callback, current)
			end
			RefreshText()
			Restyle()
		end

		local function Build()
			for _, child in ipairs(list:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
			buttons = {}

			for index, name in ipairs(options) do
				local button = Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundTransparency = 1,
					Text = tostring(name),
					Font = Enum.Font.Gotham,
					TextSize = 12,
					AutoButtonColor = false,
					LayoutOrder = index,
					Parent = list,
				})
				Corner(button, 6)
				buttons[name] = button

				button.MouseButton1Click:Connect(function()
					Commit(name)
				end)
			end

			RefreshText()
			Restyle()
		end

		function obj:Set(value, silent)
			if multi then
				picked = {}
				for _, name in ipairs(value or {}) do
					picked[name] = true
				end
				SaveFlag(cfg, PickedArray())
				if not silent then
					Fire(cfg.Callback, PickedArray())
				end
			else
				current = value
				SaveFlag(cfg, current)
				if not silent then
					Fire(cfg.Callback, current)
				end
			end
			RefreshText()
			Restyle()
		end

		function obj:Get()
			return multi and PickedArray() or current
		end

		function obj:Refresh(newOptions)
			options = newOptions or {}
			Build()
			Resize()
		end

		Hook(win, Restyle)
		Build()

		local click = Create("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 38),
			Text = "",
			ZIndex = 2,
			Parent = card,
		})
		click.MouseButton1Click:Connect(function()
			open = not open
			Resize()
		end)

		Place(card)
		return obj
	end

	------------------------------------------------------
	-- KEYBIND
	------------------------------------------------------

	function self:CreateKeybind(cfg)
		cfg = cfg or {}

		local key = cfg.Default or Enum.KeyCode.F
		local listening = false

		local card = MakeCard(cfg.Description and 46 or 38)
		CardLabels(card, cfg.Name or "Keybind", cfg.Description, 90)

		local button = Create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(72, 24),
			BorderSizePixel = 0,
			Text = key.Name,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			AutoButtonColor = false,
			ZIndex = 2,
			Parent = card,
		})
		Bind(button, "BackgroundColor3", "Background")
		Bind(button, "TextColor3", "Primary")
		Corner(button, 6)

		local obj = {}

		function obj:Set(newKey)
			key = newKey
			button.Text = key.Name
			SaveFlag(cfg, key)
		end

		function obj:Get()
			return key
		end

		button.MouseButton1Click:Connect(function()
			listening = true
			button.Text = "..."
		end)

		win.Connect(UserInputService.InputBegan, function(input, processed)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					if input.KeyCode == Enum.KeyCode.Escape then
						button.Text = key.Name
					else
						obj:Set(input.KeyCode)
						Fire(cfg.OnChanged, input.KeyCode)
					end
				end
			elseif not processed and input.KeyCode == key then
				Fire(cfg.Callback, key)
			end
		end)

		SaveFlag(cfg, key)
		Hover(card)
		Place(card)
		return obj
	end

	------------------------------------------------------
	-- COLOR PICKER
	------------------------------------------------------

	function self:CreateColorPicker(cfg)
		cfg = cfg or {}

		local color = cfg.Default or Color3.fromRGB(56, 189, 248)
		local hue, sat, val = color:ToHSV()
		local open = false

		local card = MakeCard(38)
		CardLabels(card, cfg.Name or "Color", nil, 54)

		local swatch = Create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(34, 20),
			BorderSizePixel = 0,
			BackgroundColor3 = color,
			Parent = card,
		})
		Corner(swatch, 6)
		Stroke(swatch, Color3.new(1, 1, 1), 0.7, 1)

		local obj = {}
		local hueBar, satBar, valBar

		local function Apply(fire)
			color = Color3.fromHSV(hue, sat, val)
			swatch.BackgroundColor3 = color
			SaveFlag(cfg, color)

			if satBar then
				satBar.Grad.Color = ColorSequence.new(
					Color3.fromHSV(hue, 0, val),
					Color3.fromHSV(hue, 1, val)
				)
			end
			if valBar then
				valBar.Grad.Color = ColorSequence.new(
					Color3.new(0, 0, 0),
					Color3.fromHSV(hue, sat, 1)
				)
			end

			if fire then
				Fire(cfg.Callback, color)
			end
		end

		local function Bar(y, onChange)
			local track = Create("Frame", {
				Position = UDim2.new(0, 12, 0, y),
				Size = UDim2.new(1, -24, 0, 10),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Parent = card,
			})
			Corner(track, 5)

			local grad = Create("UIGradient", { Parent = track })

			local knob = Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				ZIndex = 3,
				Parent = track,
			})
			Corner(knob, 7)
			Stroke(knob, Color3.new(0, 0, 0), 0.5, 1)

			DragBar(win, track, function(alpha)
				knob.Position = UDim2.new(alpha, 0, 0.5, 0)
				onChange(alpha)
			end)

			return {
				Grad = grad,
				SetAlpha = function(alpha)
					knob.Position = UDim2.new(alpha, 0, 0.5, 0)
				end,
			}
		end

		hueBar = Bar(48, function(alpha)
			hue = alpha
			Apply(true)
		end)
		hueBar.Grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
			ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
			ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
			ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
			ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
			ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
		})

		satBar = Bar(72, function(alpha)
			sat = alpha
			Apply(true)
		end)

		valBar = Bar(96, function(alpha)
			val = alpha
			Apply(true)
		end)

		hueBar.SetAlpha(hue)
		satBar.SetAlpha(sat)
		valBar.SetAlpha(val)
		Apply(false)

		function obj:Set(newColor, silent)
			hue, sat, val = newColor:ToHSV()
			hueBar.SetAlpha(hue)
			satBar.SetAlpha(sat)
			valBar.SetAlpha(val)
			Apply(not silent)
		end

		function obj:Get()
			return color
		end

		local click = Create("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 38),
			Text = "",
			ZIndex = 2,
			Parent = card,
		})
		click.MouseButton1Click:Connect(function()
			open = not open
			Tween(card, 0.2, { Size = UDim2.new(1, 0, 0, open and 118 or 38) })
		end)

		Place(card)
		return obj
	end
end

--=========================================================
-- CREATE WINDOW
--=========================================================

function HelloHub:CreateWindow(cfg)
	cfg = cfg or {}

	if cfg.Theme then
		self:SetTheme(cfg.Theme)
	end

	local Window = {
		Title = cfg.Title or "HelloHub",
		Subtitle = cfg.Subtitle or ("v" .. self.Version),
		Tabs = {},
		Flags = {},
		Connections = {},
		Destroyed = false,
		Visible = true,
		Minimized = false,
		ToggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift,
	}

	function Window.Connect(signal, fn)
		local connection = signal:Connect(fn)
		table.insert(Window.Connections, connection)
		return connection
	end

	-- ขนาดหน้าต่าง (ย่อให้พอดีจอมือถือ)
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local wanted = cfg.Size or Vector2.new(620, 400)
	local size = Vector2.new(
		math.min(wanted.X, viewport.X - 24),
		math.min(wanted.Y, viewport.Y - 24)
	)
	local sidebarWidth = size.X < 520 and 120 or 150
	local headerHeight = 50

	--=====================================================
	-- SCREEN GUI
	--=====================================================

	local parent = GetGuiParent()

	local old = parent:FindFirstChild("HelloHub_UI")
	if old then
		old:Destroy()
	end

	local ScreenGui = Create("ScreenGui", {
		Name = "HelloHub_UI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
	})
	ScreenGui.Parent = parent
	Window.ScreenGui = ScreenGui

	--=====================================================
	-- MAIN
	--=====================================================

	local Main = Create("Frame", {
		Name = "Main",
		Size = UDim2.fromOffset(size.X, size.Y),
		Position = UDim2.new(0.5, -size.X / 2, 0.5, -size.Y / 2),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = ScreenGui,
	})
	Bind(Main, "BackgroundColor3", "Background")
	Corner(Main, 14)
	Window.Main = Main

	local Scale = Create("UIScale", { Scale = 1, Parent = Main })

	local mainStroke = Stroke(Main, Color3.new(1, 1, 1), 0.2, 1.5)
	local strokeGradient = Create("UIGradient", { Parent = mainStroke })

	Hook(Window, function()
		strokeGradient.Color = ColorSequence.new(
			HelloHub.Theme.Primary,
			HelloHub.Theme.Accent
		)
	end)

	--=====================================================
	-- HEADER
	--=====================================================

	local Header = Create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, headerHeight),
		BackgroundTransparency = 1,
		Active = true,
		Parent = Main,
	})

	local logo = Create("TextLabel", {
		Position = UDim2.fromOffset(14, 10),
		Size = UDim2.fromOffset(30, 30),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Text = "H",
		Font = Enum.Font.GothamBlack,
		TextSize = 18,
		Parent = Header,
	})
	Bind(logo, "TextColor3", "OnPrimary")
	Corner(logo, 9)

	local logoGradient = Create("UIGradient", { Rotation = 45, Parent = logo })

	local titleLabel = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(54, 7),
		Size = UDim2.new(1, -150, 0, 20),
		Text = Window.Title,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Header,
	})
	local titleGradient = Create("UIGradient", { Parent = titleLabel })

	local subtitleLabel = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(54, 27),
		Size = UDim2.new(1, -150, 0, 14),
		Text = Window.Subtitle,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Header,
	})
	Bind(subtitleLabel, "TextColor3", "SubText")

	Hook(Window, function()
		local seq = ColorSequence.new(HelloHub.Theme.Primary, HelloHub.Theme.Accent)
		logoGradient.Color = seq
		titleGradient.Color = seq
	end)

	local headerLine = Create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		Parent = Header,
	})
	Bind(headerLine, "BackgroundColor3", "Stroke")

	local function HeaderButton(text, offset)
		local button = Create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, offset, 0.5, 0),
			Size = UDim2.fromOffset(28, 28),
			BackgroundTransparency = 1,
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			AutoButtonColor = false,
			Parent = Header,
		})
		Bind(button, "TextColor3", "SubText")
		Corner(button, 8)

		button.MouseEnter:Connect(function()
			button.BackgroundTransparency = 0
			button.BackgroundColor3 = HelloHub.Theme.CardHover
			button.TextColor3 = HelloHub.Theme.Text
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundTransparency = 1
			button.TextColor3 = HelloHub.Theme.SubText
		end)

		return button
	end

	local closeButton = HeaderButton("×", -10)
	local minimizeButton = HeaderButton("–", -42)

	-- ลากหน้าต่าง
	do
		local dragging = false
		local dragStart, startPos

		Header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = Main.Position
			end
		end)

		Window.Connect(UserInputService.InputChanged, function(input)
			if dragging
				and (input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				Main.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)

		Window.Connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	end

	--=====================================================
	-- BODY (SIDEBAR + CONTENT)
	--=====================================================

	local Body = Create("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(0, headerHeight),
		Size = UDim2.new(1, 0, 1, -headerHeight),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = Main,
	})

	local Sidebar = Create("Frame", {
		Size = UDim2.new(0, sidebarWidth, 1, 0),
		BorderSizePixel = 0,
		Parent = Body,
	})
	Bind(Sidebar, "BackgroundColor3", "Sidebar")

	local TabList = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -58),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		Parent = Sidebar,
	})
	ListLayout(TabList, 4)
	Padding(TabList, 8, 8, 8, 8)

	-- การ์ดผู้เล่นด้านล่าง sidebar
	local Footer = Create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -16, 0, 42),
		BorderSizePixel = 0,
		Parent = Sidebar,
	})
	Bind(Footer, "BackgroundColor3", "Card")
	Corner(Footer, 10)

	local avatar = Create("ImageLabel", {
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.fromOffset(30, 30),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=48&h=48",
		Parent = Footer,
	})
	Bind(avatar, "BackgroundColor3", "Background")
	Corner(avatar, 15)

	local nameLabel = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(42, 5),
		Size = UDim2.new(1, -46, 0, 16),
		Text = LocalPlayer.DisplayName,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Footer,
	})
	Bind(nameLabel, "TextColor3", "Text")

	local userLabel = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(42, 21),
		Size = UDim2.new(1, -46, 0, 14),
		Text = "@" .. LocalPlayer.Name,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Footer,
	})
	Bind(userLabel, "TextColor3", "SubText")

	local Pages = Create("Frame", {
		Position = UDim2.fromOffset(sidebarWidth, 0),
		Size = UDim2.new(1, -sidebarWidth, 1, 0),
		BackgroundTransparency = 1,
		Parent = Body,
	})

	--=====================================================
	-- NOTIFICATIONS
	--=====================================================

	local Notifier = Create("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(270, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = ScreenGui,
	})
	Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Parent = Notifier,
	})

	function Window:Notify(options)
		if Window.Destroyed then
			return
		end

		options = type(options) == "table" and options or { Content = tostring(options) }

		local colorKey = ({
			success = "Success",
			warning = "Warning",
			error = "Danger",
			danger = "Danger",
		})[string.lower(options.Type or "")] or "Primary"

		local duration = options.Duration or 4

		local wrap = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = Notifier,
		})

		local card = Create("Frame", {
			Position = UDim2.new(1, 300, 0, 0),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = wrap,
		})
		Bind(card, "BackgroundColor3", "Card")
		Corner(card, 10)
		Bind(Stroke(card, nil, 0.3, 1), "Color", "Stroke")

		local accent = Create("Frame", {
			Size = UDim2.new(0, 4, 1, 0),
			BorderSizePixel = 0,
			Parent = card,
		})
		Bind(accent, "BackgroundColor3", colorKey)

		local inner = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = card,
		})
		ListLayout(inner, 2)
		Padding(inner, 10, 12, 14, 16)

		local title = Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Text = options.Title or Window.Title,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
			Parent = inner,
		})
		Bind(title, "TextColor3", "Text")

		local content = Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = tostring(options.Content or ""),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = 2,
			Parent = inner,
		})
		Bind(content, "TextColor3", "SubText")

		local progress = Create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 2),
			BorderSizePixel = 0,
			Parent = card,
		})
		Bind(progress, "BackgroundColor3", colorKey)

		Tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
		Tween(progress, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

		task.delay(duration, function()
			if wrap.Parent then
				Tween(card, 0.25, { Position = UDim2.new(1, 300, 0, 0) })
				task.wait(0.3)
				wrap:Destroy()
			end
		end)
	end

	--=====================================================
	-- WINDOW CONTROLS
	--=====================================================

	function Window:SetVisible(visible)
		Window.Visible = visible

		if visible then
			Main.Visible = true
			Scale.Scale = 0.92
			Tween(Scale, 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
		else
			Tween(Scale, 0.15, { Scale = 0.92 })
			task.delay(0.15, function()
				if not Window.Visible then
					Main.Visible = false
				end
			end)
		end
	end

	function Window:Toggle()
		Window:SetVisible(not Window.Visible)
	end

	function Window:Minimize()
		Window.Minimized = not Window.Minimized

		if Window.Minimized then
			Body.Visible = false
			Tween(Main, 0.25, { Size = UDim2.fromOffset(size.X, headerHeight) })
		else
			Tween(Main, 0.25, { Size = UDim2.fromOffset(size.X, size.Y) })
			task.delay(0.1, function()
				if not Window.Minimized then
					Body.Visible = true
				end
			end)
		end
	end

	function Window:Destroy()
		if Window.Destroyed then
			return
		end

		Window.Destroyed = true

		for _, connection in ipairs(Window.Connections) do
			connection:Disconnect()
		end

		ScreenGui:Destroy()
	end

	function Window:SetTheme(name)
		return HelloHub:SetTheme(name)
	end

	closeButton.MouseButton1Click:Connect(function()
		Window:Destroy()
	end)

	minimizeButton.MouseButton1Click:Connect(function()
		Window:Minimize()
	end)

	Window.Connect(UserInputService.InputBegan, function(input, processed)
		if not processed and input.KeyCode == Window.ToggleKey then
			Window:Toggle()
		end
	end)

	--=====================================================
	-- FLOATING BUTTON
	--=====================================================

	if cfg.FloatingButton ~= false then
		local float = Create("TextButton", {
			Name = "HelloFloat",
			Position = UDim2.fromOffset(20, 120),
			Size = UDim2.fromOffset(46, 46),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = "H",
			Font = Enum.Font.GothamBlack,
			TextSize = 22,
			AutoButtonColor = false,
			Parent = ScreenGui,
		})
		Bind(float, "TextColor3", "OnPrimary")
		Corner(float, 23)

		local floatGradient = Create("UIGradient", { Rotation = 45, Parent = float })
		local floatStroke = Stroke(float, Color3.new(1, 1, 1), 0.6, 2)

		Hook(Window, function()
			floatGradient.Color = ColorSequence.new(
				HelloHub.Theme.Primary,
				HelloHub.Theme.Accent
			)
			floatStroke.Color = HelloHub.Theme.Text
		end)

		local pressing = false
		local moved = false
		local dragStart, startPos

		float.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				pressing = true
				moved = false
				dragStart = input.Position
				startPos = float.Position
			end
		end)

		Window.Connect(UserInputService.InputChanged, function(input)
			if pressing
				and (input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				if delta.Magnitude > 5 then
					moved = true
				end
				if moved then
					float.Position = UDim2.new(
						startPos.X.Scale,
						startPos.X.Offset + delta.X,
						startPos.Y.Scale,
						startPos.Y.Offset + delta.Y
					)
				end
			end
		end)

		Window.Connect(UserInputService.InputEnded, function(input)
			if pressing
				and (input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch) then
				pressing = false
				if not moved then
					Window:Toggle()
				end
			end
		end)
	end

	--=====================================================
	-- TABS
	--=====================================================

	function Window:SelectTab(tab)
		for _, other in ipairs(Window.Tabs) do
			other.SetActive(other == tab)
		end
	end

	function Window:CreateTab(name, icon)
		local Tab = { Name = name or "Tab" }

		local button = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 34),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = #Window.Tabs + 1,
			Parent = TabList,
		})
		Bind(button, "BackgroundColor3", "Card")
		Corner(button, 8)

		local bar = Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(3, 0),
			BorderSizePixel = 0,
			Parent = button,
		})
		Bind(bar, "BackgroundColor3", "Primary")
		Corner(bar, 2)

		local iconObject
		local iconText = tostring(icon or "misc")

		if iconText:find("rbxassetid://", 1, true) then
			iconObject = Create("ImageLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(10, 8),
				Size = UDim2.fromOffset(18, 18),
				Image = iconText,
				Parent = button,
			})
		else
			iconObject = Create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.fromOffset(22, 34),
				Text = Glyphs[string.lower(iconText)] or iconText,
				Font = Enum.Font.GothamBold,
				TextSize = 15,
				Parent = button,
			})
		end

		local label = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(34, 0),
			Size = UDim2.new(1, -38, 1, 0),
			Text = Tab.Name,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = button,
		})

		local page = Create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			Visible = false,
			Parent = Pages,
		})
		Bind(page, "ScrollBarImageColor3", "Primary")
		ListLayout(page, 8)
		Padding(page, 12, 12, 12, 12)

		local active = false

		local function Render(animate)
			local theme = HelloHub.Theme
			local duration = animate and 0.18 or 0

			Tween(button, duration, { BackgroundTransparency = active and 0 or 1 })
			Tween(bar, duration, { Size = UDim2.fromOffset(3, active and 18 or 0) })
			Tween(label, duration, { TextColor3 = active and theme.Text or theme.SubText })

			if iconObject:IsA("TextLabel") then
				Tween(iconObject, duration, { TextColor3 = active and theme.Primary or theme.SubText })
			else
				Tween(iconObject, duration, { ImageColor3 = active and theme.Primary or theme.SubText })
			end
		end

		function Tab.SetActive(value)
			active = value
			page.Visible = value
			Render(true)
		end

		Hook(Window, function()
			Render(false)
		end)

		button.MouseButton1Click:Connect(function()
			Window:SelectTab(Tab)
		end)

		AddElements(Tab, page, Window)

		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then
			Window:SelectTab(Tab)
		end

		return Tab
	end

	--=====================================================
	-- INTRO
	--=====================================================

	if cfg.Intro ~= false then
		local overlay = Create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			ZIndex = 50,
			Parent = Main,
		})
		Bind(overlay, "BackgroundColor3", "Sidebar")

		local hello = Create("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.45),
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			Text = "Hello, " .. LocalPlayer.DisplayName .. "!",
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 1,
			Font = Enum.Font.GothamBlack,
			TextSize = 28,
			ZIndex = 51,
			Parent = overlay,
		})
		local helloGradient = Create("UIGradient", { Parent = hello })

		local welcome = Create("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.58),
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = "Welcome to " .. Window.Title,
			TextTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			ZIndex = 51,
			Parent = overlay,
		})
		Bind(welcome, "TextColor3", "SubText")

		helloGradient.Color = ColorSequence.new(HelloHub.Theme.Primary, HelloHub.Theme.Accent)

		task.spawn(function()
			Tween(hello, 0.45, { TextTransparency = 0 })
			task.wait(0.2)
			Tween(welcome, 0.45, { TextTransparency = 0 })
			task.wait(1.2)
			Tween(hello, 0.4, { TextTransparency = 1 })
			Tween(welcome, 0.4, { TextTransparency = 1 })
			Tween(overlay, 0.5, { BackgroundTransparency = 1 })
			task.wait(0.55)
			overlay:Destroy()
		end)
	end

	Scale.Scale = 0.92
	Tween(Scale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)

	table.insert(HelloHub, Window)
	return Window
end

return HelloHub
