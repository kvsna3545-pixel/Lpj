--[[
========================================================
 HELLOHUB | UI LIBRARY v9.2.0 (Animated Horizontal Dropdown)
 Runtime: Roblox Studio | Executor (loadstring)
========================================================
 Changelog v9.2.0:
 - 🆕 Dropdown: Horizontal layout + Stagger animations
 - 🆕 Dropdown: Arrow rotation, spring open/close
 - 🆕 Dropdown: Selected highlight + horizontal scroll
 - ✅ Fixed Dropdown overflow (Floating Menu)
 - ✅ Fixed Smooth Close Animation
 - ✅ Theme-Specific Ambient Effects
 - ✅ Premium Glassmorphism Design
========================================================
]]

local HelloHub = {}
local Effects = {}
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- =====================================================================
-- THEME DEFINITIONS (10 Themes + Effects)
-- =====================================================================
local CONFIG = {
    Name = "HelloHub", Version = "v9.2.0", Logo = "rbxassetid://75164736067854", 
    Window = { Width = 720, Height = 460, MinWidth = 500, MinHeight = 350, Margin = 20 },
    Anim = { Normal = 0.25, Fast = 0.15, Spring = Enum.EasingStyle.Back, Smooth = Enum.EasingStyle.Quint },
    Themes = {
        ["Hello"] = { Effect = "Stars", Bg = Color3.fromRGB(18, 18, 24), Panel = Color3.fromRGB(25, 25, 35), Accent = Color3.fromRGB(150, 100, 255), Accent2 = Color3.fromRGB(200, 120, 255), Text = Color3.fromRGB(240, 240, 255), SubText = Color3.fromRGB(150, 150, 170), Stroke = Color3.fromRGB(60, 50, 80) },
        ["Dark"] = { Effect = "Stars", Bg = Color3.fromRGB(10, 10, 10), Panel = Color3.fromRGB(20, 20, 20), Accent = Color3.fromRGB(200, 200, 200), Accent2 = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(255, 255, 255), SubText = Color3.fromRGB(120, 120, 120), Stroke = Color3.fromRGB(40, 40, 40) },
        ["Ocean"] = { Effect = "Bubbles", Bg = Color3.fromRGB(10, 20, 30), Panel = Color3.fromRGB(15, 30, 45), Accent = Color3.fromRGB(0, 150, 255), Accent2 = Color3.fromRGB(0, 255, 200), Text = Color3.fromRGB(220, 240, 255), SubText = Color3.fromRGB(120, 160, 200), Stroke = Color3.fromRGB(30, 60, 90) },
        ["Mint"] = { Effect = "Sparkles", Bg = Color3.fromRGB(15, 25, 20), Panel = Color3.fromRGB(20, 35, 28), Accent = Color3.fromRGB(0, 255, 150), Accent2 = Color3.fromRGB(150, 255, 200), Text = Color3.fromRGB(230, 255, 240), SubText = Color3.fromRGB(130, 180, 150), Stroke = Color3.fromRGB(40, 80, 60) },
        ["Sunset"] = { Effect = "Leaves", Bg = Color3.fromRGB(25, 15, 20), Panel = Color3.fromRGB(40, 20, 30), Accent = Color3.fromRGB(255, 100, 50), Accent2 = Color3.fromRGB(255, 50, 100), Text = Color3.fromRGB(255, 240, 230), SubText = Color3.fromRGB(200, 150, 150), Stroke = Color3.fromRGB(80, 40, 50) },
        ["Autumn"] = { Effect = "Leaves", Bg = Color3.fromRGB(20, 15, 10), Panel = Color3.fromRGB(35, 25, 15), Accent = Color3.fromRGB(255, 120, 0), Accent2 = Color3.fromRGB(200, 50, 0), Text = Color3.fromRGB(255, 235, 200), SubText = Color3.fromRGB(180, 140, 100), Stroke = Color3.fromRGB(80, 50, 20) },
        ["Christmas"] = { Effect = "Snow", Bg = Color3.fromRGB(15, 20, 15), Panel = Color3.fromRGB(25, 35, 25), Accent = Color3.fromRGB(255, 50, 50), Accent2 = Color3.fromRGB(50, 200, 50), Text = Color3.fromRGB(255, 255, 255), SubText = Color3.fromRGB(150, 180, 150), Stroke = Color3.fromRGB(60, 80, 60) },
        ["Valentine"] = { Effect = "Hearts", Bg = Color3.fromRGB(25, 15, 20), Panel = Color3.fromRGB(40, 20, 30), Accent = Color3.fromRGB(255, 50, 100), Accent2 = Color3.fromRGB(255, 150, 200), Text = Color3.fromRGB(255, 240, 245), SubText = Color3.fromRGB(200, 150, 170), Stroke = Color3.fromRGB(100, 40, 60) },
        ["Summer"] = { Effect = "Fireflies", Bg = Color3.fromRGB(15, 25, 35), Panel = Color3.fromRGB(25, 40, 50), Accent = Color3.fromRGB(255, 200, 0), Accent2 = Color3.fromRGB(0, 200, 255), Text = Color3.fromRGB(255, 255, 220), SubText = Color3.fromRGB(180, 180, 150), Stroke = Color3.fromRGB(80, 80, 40) },
        ["Halloween"] = { Effect = "Pumpkins", Bg = Color3.fromRGB(15, 10, 20), Panel = Color3.fromRGB(25, 15, 30), Accent = Color3.fromRGB(255, 100, 0), Accent2 = Color3.fromRGB(150, 0, 255), Text = Color3.fromRGB(255, 230, 200), SubText = Color3.fromRGB(180, 150, 200), Stroke = Color3.fromRGB(80, 40, 100) },
        ["Cyberpunk"] = { Effect = "Matrix", Bg = Color3.fromRGB(5, 5, 10), Panel = Color3.fromRGB(15, 5, 25), Accent = Color3.fromRGB(255, 0, 150), Accent2 = Color3.fromRGB(0, 255, 255), Text = Color3.fromRGB(255, 255, 255), SubText = Color3.fromRGB(180, 100, 180), Stroke = Color3.fromRGB(60, 10, 90) },
    }
}

local ActiveThemeName = "Hello"
local Theme = table.clone(CONFIG.Themes[ActiveThemeName])

-- =====================================================================
-- HELPERS & EFFECTS ENGINE
-- =====================================================================
local function create(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function corner(obj, radius) return create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, obj) end
local function stroke(obj, color, transparency, thickness)
    return create("UIStroke", { Color = color or Theme.Stroke, Thickness = thickness or 1, Transparency = transparency or 0.5 }, obj)
end
local function padding(obj, l, r, t, b)
    return create("UIPadding", { PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r), PaddingTop = UDim.new(0, t), PaddingBottom = UDim.new(0, b) }, obj)
end
local function tween(obj, duration, props, style, dir)
    if not obj or not obj.Parent then return end
    local info = TweenInfo.new(duration or CONFIG.Anim.Normal, style or CONFIG.Anim.Smooth, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end
local function safeCallback(cb, ...)
    if type(cb) ~= "function" then return end
    local args = table.pack(...)
    local ok, err = xpcall(function() cb(table.unpack(args, 1, args.n)) end, debug.traceback)
    if not ok then warn("[HelloHub] Error in callback: " .. tostring(err)) end
end
local function isAlive(obj) return obj and obj.Parent ~= nil end

function Effects.Glow(target, color, speed)
    local glowStroke = create("UIStroke", { Color = color or Theme.Accent, Thickness = 2, Transparency = 0.5 }, target)
    task.spawn(function() 
        while isAlive(target) do 
            tween(glowStroke, speed or 1, { Transparency = 0.8 }, Enum.EasingStyle.Sine)
            task.wait(speed or 1)
            tween(glowStroke, speed or 1, { Transparency = 0.2 }, Enum.EasingStyle.Sine)
            task.wait(speed or 1) 
        end 
    end)
    return glowStroke
end

local function createParticleBurst(parent, color)
    task.spawn(function()
        for i = 1, 8 do
            local p = create("Frame", {
                Size = UDim2.fromOffset(math.random(3, 6), math.random(3, 6)),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundColor3 = color, BackgroundTransparency = 0, ZIndex = 100
            }, parent)
            corner(p, 100)
            local angle = math.rad(math.random(0, 360))
            local dist = math.random(20, 40)
            tween(p, 0.4, { 
                Position = UDim2.new(0.5, math.cos(angle) * dist, 0.5, math.sin(angle) * dist), 
                BackgroundTransparency = 1, Size = UDim2.fromOffset(0,0)
            }, Enum.EasingStyle.Quint)
            task.delay(0.4, function() if isAlive(p) then p:Destroy() end end)
        end
    end)
end

-- Ambient Theme Effects Spawner
local function spawnThemeEffect(container, effectType)
    if not isAlive(container) then return end
    
    if effectType == "Stars" then
        local s = create("TextLabel", { Size = UDim2.fromOffset(math.random(4,10), math.random(4,10)), Position = UDim2.new(math.random(), 0, math.random(), 0), BackgroundTransparency = 1, Text = "✦", TextColor3 = Theme.Text, TextTransparency = 0.5, ZIndex = 2 }, container)
        tween(s, 2, { TextTransparency = 1, Rotation = math.random(-180, 180) })
        task.delay(2, function() if isAlive(s) then s:Destroy() end end)
        
    elseif effectType == "Leaves" then
        local s = create("TextLabel", { Size = UDim2.fromOffset(math.random(15,25), math.random(15,25)), Position = UDim2.new(math.random(), 0, -0.1, 0), BackgroundTransparency = 1, Text = math.random(1,2) == 1 and "🍁" or "🍂", TextSize = 20, Rotation = math.random(0, 360), ZIndex = 2 }, container)
        local t = tween(s, math.random(4,7), { Position = UDim2.new(s.Position.X.Scale + (math.random(-10,10)/100), 0, 1.1, 0), Rotation = s.Rotation + math.random(-180,180) }, Enum.EasingStyle.Linear)
        if t then t.Completed:Connect(function() s:Destroy() end) end
        
    elseif effectType == "Bubbles" then
        local s = create("Frame", { Size = UDim2.fromOffset(math.random(10,20), math.random(10,20)), Position = UDim2.new(math.random(), 0, 1.1, 0), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.5, ZIndex = 2 }, container)
        corner(s, 100); stroke(s, Theme.Accent2, 0.2, 1)
        local t = tween(s, math.random(3,6), { Position = UDim2.new(s.Position.X.Scale + (math.random(-10,10)/100), 0, -0.1, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Linear)
        if t then t.Completed:Connect(function() s:Destroy() end) end
        
    elseif effectType == "Snow" then
        local s = create("Frame", { Size = UDim2.fromOffset(math.random(4,8), math.random(4,8)), Position = UDim2.new(math.random(), 0, -0.1, 0), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.3, ZIndex = 2 }, container)
        corner(s, 100)
        local t = tween(s, math.random(5,8), { Position = UDim2.new(s.Position.X.Scale + (math.random(-5,5)/100), 0, 1.1, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Linear)
        if t then t.Completed:Connect(function() s:Destroy() end) end
        
    elseif effectType == "Hearts" then
        local s = create("TextLabel", { Size = UDim2.fromOffset(15,15), Position = UDim2.new(math.random(), 0, 1.1, 0), BackgroundTransparency = 1, Text = "❤️", TextSize = 15, ZIndex = 2 }, container)
        local t = tween(s, math.random(3,5), { Position = UDim2.new(s.Position.X.Scale + (math.random(-10,10)/100), 0, -0.1, 0), TextTransparency = 1 }, Enum.EasingStyle.Sine)
        if t then t.Completed:Connect(function() s:Destroy() end) end
        
    elseif effectType == "Fireflies" then
        local s = create("Frame", { Size = UDim2.fromOffset(6,6), Position = UDim2.new(math.random(), 0, math.random(), 0), BackgroundColor3 = Theme.Accent, ZIndex = 2 }, container)
        corner(s, 100); Effects.Glow(s, Theme.Accent2, 0.5)
        local t = tween(s, math.random(2,4), { Position = UDim2.new(math.clamp(s.Position.X.Scale + (math.random(-20,20)/100), 0, 1), 0, math.clamp(s.Position.Y.Scale + (math.random(-20,20)/100), 0, 1), 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Sine)
        if t then t.Completed:Connect(function() s:Destroy() end) end
        
    elseif effectType == "Matrix" then
        local s = create("TextLabel", { Size = UDim2.fromOffset(12,12), Position = UDim2.new(math.random(), 0, -0.1, 0), BackgroundTransparency = 1, Text = string.char(math.random(33,126)), TextColor3 = Theme.Accent2, TextSize = 12, Font = Enum.Font.Code, ZIndex = 2 }, container)
        local t = tween(s, math.random(1,3), { Position = UDim2.new(s.Position.X.Scale, 0, 1.1, 0), TextTransparency = 1 }, Enum.EasingStyle.Linear)
        if t then t.Completed:Connect(function() s:Destroy() end) end
        
    elseif effectType == "Pumpkins" then
        local s = create("TextLabel", { Size = UDim2.fromOffset(20,20), Position = UDim2.new(math.random(), 0, -0.1, 0), BackgroundTransparency = 1, Text = "🎃", TextSize = 20, Rotation = math.random(0,360), ZIndex = 2 }, container)
        local t = tween(s, math.random(4,7), { Position = UDim2.new(s.Position.X.Scale + (math.random(-10,10)/100), 0, 1.1, 0), Rotation = s.Rotation + 360 }, Enum.EasingStyle.Linear)
        if t then t.Completed:Connect(function() s:Destroy() end) end
        
    elseif effectType == "Sparkles" then
        local s = create("TextLabel", { Size = UDim2.fromOffset(10,10), Position = UDim2.new(math.random(), 0, math.random(), 0), BackgroundTransparency = 1, Text = "✨", TextSize = 10, ZIndex = 2 }, container)
        tween(s, 1.5, { TextTransparency = 1, Size = UDim2.fromOffset(20,20) })
        task.delay(1.5, function() if isAlive(s) then s:Destroy() end end)
    end
end

-- =====================================================================
-- WINDOW CLASS
-- =====================================================================
function HelloHub.new(options)
    options = options or {}
    local self = setmetatable({}, Window)
    self.Connections = {}
    self.Tabs = {}
    self.Flags = table.clone(options.Flags or {})
    self.Destroyed = false
    self.Hidden = true
    self.Minimized = false
    self.NormalPos = UDim2.fromOffset(50, 50)
    self.NormalSize = UDim2.fromOffset(CONFIG.Window.Width, CONFIG.Window.Height)

    local function getBaseScale()
        local v = workspace.CurrentCamera.ViewportSize
        return math.clamp(math.min(v.X / 900, v.Y / 650), 0.6, 1)
    end

    local screen = create("ScreenGui", { Name = "HelloHub_Premium", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, PlayerGui)
    self.Screen = screen

    -- Main Window (ClipsDescendants = true to prevent overflow)
    local main = create("Frame", { Name = "Main", Position = self.NormalPos, Size = self.NormalSize, BackgroundColor3 = Theme.Bg, BackgroundTransparency = 0.35, BorderSizePixel = 0, ClipsDescendants = true, Visible = false }, screen)
    self.Main = main
    corner(main, 12)
    create("UIStroke", { Thickness = 1.5, Color = Theme.Stroke, Transparency = 0.3 }, main)
    
    self.UIScale = create("UIScale", { Scale = getBaseScale() }, main)

    -- Ambient Effects Container
    self.AmbientContainer = create("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 1 }, main)
    
    -- Ambient Loop
    task.spawn(function()
        while not self.Destroyed do
            if main.Visible and not self.Hidden and not self.Minimized then
                local effect = CONFIG.Themes[ActiveThemeName] and CONFIG.Themes[ActiveThemeName].Effect
                if effect then
                    spawnThemeEffect(self.AmbientContainer, effect)
                    if math.random() > 0.5 then spawnThemeEffect(self.AmbientContainer, effect) end
                end
            end
            task.wait(0.2)
        end
    end)

    -- TITLE BAR
    local topBar = create("Frame", { Name = "TopBar", Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 10 }, main)
    create("ImageLabel", { Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(15, 11), BackgroundTransparency = 1, Image = options.Logo or CONFIG.Logo, ZIndex = 11 }, topBar)
    create("TextLabel", { Size = UDim2.new(0, 200, 1, 0), Position = UDim2.fromOffset(55, 0), BackgroundTransparency = 1, Text = options.Title or CONFIG.Name, TextColor3 = Theme.Text, TextSize = 16, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 }, topBar)
    
    local minBtn = create("TextButton", { Size = UDim2.fromOffset(40, 50), Position = UDim2.new(1, -90, 0, 0), BackgroundTransparency = 1, Text = "−", TextColor3 = Theme.SubText, TextSize = 22, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 11 }, topBar)
    local closeBtn = create("TextButton", { Size = UDim2.fromOffset(40, 50), Position = UDim2.new(1, -45, 0, 0), BackgroundTransparency = 1, Text = "×", TextColor3 = Theme.SubText, TextSize = 22, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 11 }, topBar)
    
    for _, btn in ipairs({minBtn, closeBtn}) do
        local isClose = btn == closeBtn
        table.insert(self.Connections, btn.MouseEnter:Connect(function() tween(btn, 0.1, { TextColor3 = isClose and Color3.fromRGB(255, 100, 100) or Theme.Text }) end))
        table.insert(self.Connections, btn.MouseLeave:Connect(function() tween(btn, 0.1, { TextColor3 = Theme.SubText }) end))
    end
    
    table.insert(self.Connections, closeBtn.Activated:Connect(function() self:ToggleWindow(false) end))
    table.insert(self.Connections, minBtn.Activated:Connect(function() 
        self.Minimized = not self.Minimized
        minBtn.Text = self.Minimized and "+" or "−"
        tween(main, 0.3, { Size = self.Minimized and UDim2.new(main.Size.X.Scale, main.Size.X.Offset, 0, 50) or self.NormalSize }, CONFIG.Anim.Spring)
    end))

    -- SIDEBAR
    local sidebar = create("Frame", { Size = UDim2.new(0, 160, 1, -60), Position = UDim2.fromOffset(0, 50), BackgroundColor3 = Theme.Bg, BackgroundTransparency = 0.5, ZIndex = 5 }, main)
    create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Theme.Stroke, BackgroundTransparency = 0.5, ZIndex = 6 }, sidebar)
    self.TabHolder = create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 6 }, sidebar)
    create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, self.TabHolder)
    padding(self.TabHolder, 10, 10, 10, 10)

    -- CONTENT AREA
    local content = create("Frame", { Size = UDim2.new(1, -160, 1, -60), Position = UDim2.fromOffset(160, 50), BackgroundTransparency = 1, ZIndex = 5 }, main)
    local searchBar = create("Frame", { Size = UDim2.new(1, -20, 0, 35), Position = UDim2.fromOffset(10, 10), BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.3, ZIndex = 6 }, content)
    corner(searchBar, 8); stroke(searchBar, Theme.Stroke, 0.6)
    create("TextLabel", { Size = UDim2.fromOffset(30, 35), BackgroundTransparency = 1, Text = "🔍", TextSize = 14, ZIndex = 7 }, searchBar)
    self.SearchBox = create("TextBox", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(30, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = "Search...", PlaceholderColor3 = Theme.SubText, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 7 }, searchBar)
    
    self.PageHolder = create("Frame", { Size = UDim2.new(1, -20, 1, -55), Position = UDim2.fromOffset(10, 55), BackgroundTransparency = 1, ZIndex = 6 }, content)
    create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10) }, self.PageHolder)

    -- FLOATING BUTTON
    local launcher = create("ImageButton", { 
        Size = UDim2.fromOffset(50, 50), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 20, 1, -20),
        BackgroundColor3 = Theme.Accent, Image = options.Logo or CONFIG.Logo, ScaleType = Enum.ScaleType.Crop, 
        Visible = false, AutoButtonColor = false, ZIndex = 50 
    }, screen)
    self.Launcher = launcher
    corner(launcher, 100); create("UIStroke", { Thickness = 2, Color = Color3.new(1,1,1), Transparency = 0.5 }, launcher)
    
    local lDrag, lStart, lPos, lMoved = false, nil, nil, 0
    table.insert(self.Connections, launcher.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then lDrag = true; lStart = i.Position; lPos = launcher.Position; lMoved = 0 end end))
    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(i)
        if lDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - lStart; lMoved += math.abs(d.X) + math.abs(d.Y)
            local v = workspace.CurrentCamera.ViewportSize
            launcher.Position = UDim2.new(0, math.clamp(lPos.X.Offset + d.X, 0, v.X - 50), 1, math.clamp(lPos.Y.Offset + d.Y, -v.Y + 50, -10))
        end
    end))
    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(i)
        if lDrag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            lDrag = false
            if lMoved < 10 then self:ToggleWindow(self.Hidden) end
        end
    end))

    -- TOGGLE WINDOW
    function self:ToggleWindow(show)
        if self.Destroyed or self.Hidden == not show then return end
        self.Hidden = not show
        local baseScale = getBaseScale()
        
        if show then
            main.Visible = true
            self.UIScale.Scale = baseScale * 0.9
            main.Position = UDim2.new(self.NormalPos.X.Scale, self.NormalPos.X.Offset, self.NormalPos.Y.Scale, self.NormalPos.Y.Offset + 20)
            main.BackgroundTransparency = 1
            tween(main, 0.4, { Position = self.NormalPos, BackgroundTransparency = 0.35 }, CONFIG.Anim.Spring)
            tween(self.UIScale, 0.4, { Scale = baseScale }, CONFIG.Anim.Spring)
        else
            local tw = tween(main, 0.3, { Position = UDim2.new(self.NormalPos.X.Scale, self.NormalPos.X.Offset, self.NormalPos.Y.Scale, self.NormalPos.Y.Offset + 20), BackgroundTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            tween(self.UIScale, 0.3, { Scale = baseScale * 0.95 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            if tw then 
                tw.Completed:Wait()
                if not self.Destroyed then 
                    main.Visible = false 
                    self.UIScale.Scale = baseScale
                end
            end
        end
    end

    -- INTRO & RESPONSIVE
    table.insert(self.Connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if not self.Hidden then self.UIScale.Scale = getBaseScale() end
    end))

    task.spawn(function()
        task.wait(0.5)
        launcher.Visible = true
        launcher.Size = UDim2.fromOffset(0,0)
        tween(launcher, 0.5, { Size = UDim2.fromOffset(50, 50) }, CONFIG.Anim.Spring)
        task.wait(0.3)
        self:ToggleWindow(true)
    end)

    -- DRAG LOGIC
    local drag, dStart, wPos = false, nil, nil
    table.insert(self.Connections, topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; dStart = i.Position; wPos = main.Position end end))
    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = (i.Position - dStart) / self.UIScale.Scale
            local v = workspace.CurrentCamera.ViewportSize
            main.Position = UDim2.new(0, math.clamp(wPos.X.Offset + d.X, 0, v.X - main.AbsoluteSize.X), 0, math.clamp(wPos.Y.Offset + d.Y, 0, v.Y - main.AbsoluteSize.Y))
            self.NormalPos = main.Position
        end
    end))
    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end))

    -- KEYBIND TOGGLE
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.RightShift then self:ToggleWindow(self.Hidden) end end))

    function self:Notify(data) return Window.Notify(self, data) end
    function self:Destroy() return Window.Destroy(self) end
    function self:ConnectSearch() return Window.ConnectSearch(self) end
    return self
end

-- =====================================================================
-- TAB & COMPONENTS
-- =====================================================================
function Window:CreateTab(options)
    local name = options.Name or "Tab"
    local tab = setmetatable({ Window = self, Name = name, Connections = {}, Components = {} }, Tab)
    
    tab.Button = create("TextButton", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.8, Text = "", AutoButtonColor = false, ZIndex = 7 }, self.TabHolder)
    corner(tab.Button, 6)
    
    tab.Indicator = create("Frame", { Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(0, -5, 0.2, 0), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, ZIndex = 8 }, tab.Button)
    corner(tab.Indicator, 100)
    
    create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(15, 0), BackgroundTransparency = 1, Text = (options.Icon or "◆").."  "..name, TextColor3 = Theme.SubText, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8 }, tab.Button)

    tab.Page = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false }, self.PageHolder)
    tab.LeftCol = create("ScrollingFrame", { Size = UDim2.new(0.5, -5, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new() }, tab.Page)
    create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tab.LeftCol)
    tab.RightCol = create("ScrollingFrame", { Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new() }, tab.Page)
    create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tab.RightCol)

    self.Tabs[name] = tab
    tab.Button.Activated:Connect(function() self:SelectTab(name) end)
    if not self.ActiveTab then self:SelectTab(name) end
    return tab
end

function Window:SelectTab(name)
    if not self.Tabs[name] then return end
    self.ActiveTab = name
    for tName, tab in pairs(self.Tabs) do
        local active = tName == name
        tab.Page.Visible = active
        tween(tab.Button, 0.2, { BackgroundColor3 = active and Theme.Accent or Theme.Panel, BackgroundTransparency = active and 0.5 or 0.8 })
        tween(tab.Indicator, 0.2, { BackgroundTransparency = active and 0 or 1 })
        local txt = tab.Button:FindFirstChildOfClass("TextLabel")
        if txt then tween(txt, 0.2, { TextColor3 = active and Theme.Text or Theme.SubText }) end
    end
end

local function getTarget(tab, opt) return opt.Column == "Right" and tab.RightCol or tab.LeftCol end
local function createCard(tab, height, opt)
    local c = create("Frame", { Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.3, Name = opt.Name or "" }, getTarget(tab, opt))
    corner(c, 8); stroke(c, Theme.Stroke, 0.7)
    return c
end

-- COMPONENTS
function Tab:AddSection(icon, name, opt)
    local t = getTarget(self, opt or {})
    local f = create("Frame", { Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1 }, t)
    create("TextLabel", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = (icon or "").." "..name, TextColor3 = Theme.Accent, TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left }, f)
end

function Tab:AddLabel(text, opt)
    local t = getTarget(self, opt or {})
    local f = create("TextLabel", { Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.SubText, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left }, t)
    return { Set = function(_, v) f.Text = tostring(v) end }
end
Tab.AddText = Tab.AddLabel

function Tab:AddButton(opt)
    local c = createCard(self, 40, opt)
    local btn = create("TextButton", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = opt.Name or "Button", TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamBold }, c)
    btn.MouseEnter:Connect(function() tween(c, 0.15, { BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.2 }) end)
    btn.MouseLeave:Connect(function() tween(c, 0.15, { BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.3 }) end)
    btn.Activated:Connect(function() createParticleBurst(c, Theme.Accent); safeCallback(opt.Callback) end)
    return { Instance = btn, SetText = function(_, v) btn.Text = tostring(v) end }
end

function Tab:AddToggle(opt)
    local state = self.Window.Flags[opt.Flag or opt.Name] ~= nil and self.Window.Flags[opt.Flag or opt.Name] or opt.Default
    local c = createCard(self, 40, opt)
    create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = opt.Name or "Toggle", TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left }, c)
    local sw = create("Frame", { Size = UDim2.fromOffset(36, 20), Position = UDim2.new(1, -48, 0.5, -10), BackgroundColor3 = state and Theme.Accent or Theme.Stroke }, c)
    corner(sw, 20)
    local knob = create("Frame", { Size = UDim2.fromOffset(16, 16), Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2), BackgroundColor3 = Color3.new(1,1,1) }, sw)
    corner(knob, 20)
    local btn = create("TextButton", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "" }, c)
    
    local function set(val)
        state = val; self.Window.Flags[opt.Flag or opt.Name] = val
        tween(sw, 0.2, { BackgroundColor3 = val and Theme.Accent or Theme.Stroke })
        tween(knob, 0.2, { Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2) }, CONFIG.Anim.Spring)
        safeCallback(opt.Callback, val)
    end
    btn.Activated:Connect(function() set(not state) end)
    self.Window.Flags[opt.Flag or opt.Name] = state
    return { Get = function() return state end, Set = function(_, v) set(v) end }
end

function Tab:AddSlider(opt)
    local min, max = opt.Min or 0, opt.Max or 100
    local val = opt.Default or min
    local c = createCard(self, 55, opt)
    local lbl = create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.fromOffset(12, 5), BackgroundTransparency = 1, Text = opt.Name.." : "..val, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left }, c)
    
    local bar = create("Frame", { Size = UDim2.new(1, -24, 0, 6), Position = UDim2.fromOffset(12, 35), BackgroundColor3 = Theme.Bg }, c)
    corner(bar, 10)
    local fill = create("Frame", { Size = UDim2.new((val-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.Accent }, bar)
    corner(fill, 10)
    local thumb = create("Frame", { Size = UDim2.fromOffset(12,12), AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new((val-min)/(max-min), 0, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1) }, bar)
    corner(thumb, 100); stroke(thumb, Theme.Accent, 0, 2)
    
    local hit = create("TextButton", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, -7), BackgroundTransparency = 1, Text = "" }, bar)
    local drag = false
    local function update(x, silent)
        local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        val = math.floor((min + (max-min)*pct) + 0.5)
        fill.Size = UDim2.new(pct, 0, 1, 0); thumb.Position = UDim2.new(pct, 0, 0.5, 0)
        lbl.Text = opt.Name.." : "..val
        if not silent then safeCallback(opt.Callback, val) end
    end
    hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; update(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    return { Get = function() return val end, Set = function(_, v) update(bar.AbsolutePosition.X + (bar.AbsoluteSize.X * ((v - min) / (max - min)))) end }
end

-- 🌟 DROPDOWN v2 (Horizontal + Animated)
function Tab:AddDropdown(opt)
    local choices = opt.Options or {}
    local sel = opt.Default or choices[1]
    local c = createCard(self, 40, opt)
    local txt = create("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = tostring(sel), TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10 }, c)
    local arrow = create("TextLabel", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -35, 0.5, -15), BackgroundTransparency = 1, Text = ">", TextColor3 = Theme.Text, TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 10 }, c)
    local btn = create("TextButton", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "", ZIndex = 11 }, c)

    local opened = false
    local overlay, dropList

    local function closeDropdown()
        if dropList then
            local d = dropList
            dropList = nil
            local t = tween(d, 0.2, {
                Size = UDim2.new(d.Size.X.Scale, d.Size.X.Offset, 0, 0),
                BackgroundTransparency = 1
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            if t then t.Completed:Connect(function() if d and d.Parent then d:Destroy() end end) end
        end
        if overlay then overlay:Destroy() overlay = nil end
        opened = false
        tween(arrow, 0.25, { Rotation = 0 }, CONFIG.Anim.Spring)
    end

    btn.Activated:Connect(function()
        if opened then closeDropdown(); return end
        opened = true
        tween(arrow, 0.3, { Rotation = 90 }, CONFIG.Anim.Spring)

        overlay = create("TextButton", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", ZIndex = 90 }, self.Window.Main)
        overlay.Activated:Connect(closeDropdown)

        local scale = self.Window.UIScale.Scale
        local rx = (c.AbsolutePosition.X - self.Window.Main.AbsolutePosition.X) / scale
        local ry = (c.AbsolutePosition.Y - self.Window.Main.AbsolutePosition.Y) / scale + (c.AbsoluteSize.Y / scale) + 4

        local availableWidth = c.AbsoluteSize.X / scale
        local gap, padX, btnH = 6, 4, 30
        local containerH = btnH + 14

        local idealW = (availableWidth - padX * 2 - gap * (#choices - 1)) / math.max(#choices, 1)
        local btnW = math.clamp(idealW, 70, 110)
        local contentW = #choices * btnW + (#choices - 1) * gap + padX * 2
        local needsScroll = contentW > availableWidth
        local containerW = math.min(availableWidth, contentW)

        dropList = create("ScrollingFrame", {
            Size = UDim2.fromOffset(containerW, 0),
            Position = UDim2.fromOffset(rx, ry),
            BackgroundColor3 = Theme.Bg,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            ZIndex = 95,
            ScrollBarThickness = needsScroll and 3 or 0,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, contentW, 0, containerH),
            ScrollingDirection = Enum.ScrollingDirection.X,
            AutomaticCanvasSize = Enum.AutomaticSize.None,
        }, self.Window.Main)
        corner(dropList, 8)
        stroke(dropList, Theme.Accent, 0.3, 1.5)

        tween(dropList, 0.35, { Size = UDim2.fromOffset(containerW, containerH) }, CONFIG.Anim.Spring)

        for i, choice in ipairs(choices) do
            local finalX = padX + (i - 1) * (btnW + gap)
            local isSel = (choice == sel)

            local ob = create("TextButton", {
                Size = UDim2.fromOffset(0, btnH),
                Position = UDim2.fromOffset(finalX + btnW / 2, 7),
                BackgroundTransparency = 1,
                BackgroundColor3 = isSel and Theme.Accent or Theme.Panel,
                Text = tostring(choice),
                TextColor3 = isSel and Color3.new(1,1,1) or Theme.Text,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                ZIndex = 96
            }, dropList)
            corner(ob, 6)

            task.delay((i - 1) * 0.03, function()
                if not ob or not ob.Parent then return end
                tween(ob, 0.3, {
                    Size = UDim2.fromOffset(btnW, btnH),
                    Position = UDim2.fromOffset(finalX, 7),
                    BackgroundTransparency = isSel and 0.2 or 0.6,
                }, CONFIG.Anim.Spring)
            end)

            ob.MouseEnter:Connect(function() tween(ob, 0.1, { BackgroundTransparency = 0.3, BackgroundColor3 = Theme.Accent }) end)
            ob.MouseLeave:Connect(function() tween(ob, 0.1, { BackgroundTransparency = isSel and 0.2 or 0.6, BackgroundColor3 = isSel and Theme.Accent or Theme.Panel }) end)

            ob.Activated:Connect(function()
                sel = choice
                txt.Text = tostring(choice)
                closeDropdown()
                safeCallback(opt.Callback, choice)
            end)
        end
    end)

    return { Get = function() return sel end, Set = function(_, v) sel = v; txt.Text = tostring(v); safeCallback(opt.Callback, v) end }
end

function Tab:AddInput(opt)
    local c = createCard(self, 50, opt)
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 16), Position = UDim2.fromOffset(12, 4), BackgroundTransparency = 1, Text = opt.Name or "Input", TextColor3 = Theme.SubText, TextSize = 10, Font = Enum.Font.Gotham }, c)
    local box = create("TextBox", { Size = UDim2.new(1, -24, 0, 22), Position = UDim2.fromOffset(12, 22), BackgroundColor3 = Theme.Bg, BackgroundTransparency = 0.4, Text = tostring(opt.Default or ""), PlaceholderText = opt.Placeholder or "Enter...", TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Center }, c)
    corner(box, 6); stroke(box, Theme.Stroke, 0.5)
    box.Focused:Connect(function() tween(box, 0.2, { BackgroundTransparency = 0.1 }); tween(c.UIStroke, 0.2, { Color = Theme.Accent, Transparency = 0 }) end)
    box.FocusLost:Connect(function(enter) 
        tween(box, 0.2, { BackgroundTransparency = 0.4 }); tween(c.UIStroke, 0.2, { Color = Theme.Stroke, Transparency = 0.7 })
        safeCallback(opt.Callback, box.Text, enter) 
    end)
    return { Get = function() return box.Text end, Set = function(_, v) box.Text = tostring(v) end }
end
Tab.AddTextbox = Tab.AddInput

function Tab:AddKeybind(opt)
    local key = opt.Default or "None"
    local c = createCard(self, 40, opt)
    create("TextLabel", { Size = UDim2.new(1, -80, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = opt.Name or "Keybind", TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left }, c)
    local btn = create("TextButton", { Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -72, 0.5, -12), BackgroundColor3 = Theme.Bg, BackgroundTransparency = 0.4, Text = key, TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.GothamBold }, c)
    corner(btn, 6); stroke(btn, Theme.Stroke, 0.5)
    local listening = false
    btn.Activated:Connect(function()
        if listening then return end
        listening = true; btn.Text = "..."
        local conn = UserInputService.InputBegan:Connect(function(i, g)
            if g then return end
            if i.UserInputType == Enum.UserInputType.Keyboard then
                key = i.KeyCode.Name; btn.Text = key; listening = false; conn:Disconnect()
                safeCallback(opt.Callback, key)
            end
        end)
    end)
    return { Get = function() return key end, Set = function(_, v) key = v; btn.Text = v; safeCallback(opt.Callback, v) end }
end

function Window:SetTheme(name)
    if not CONFIG.Themes[name] then return end
    ActiveThemeName = name
    Theme = table.clone(CONFIG.Themes[name])
    
    self.Main.BackgroundColor3 = Theme.Bg
    self.Main.UIStroke.Color = Theme.Stroke
    
    for _, desc in ipairs(self.Screen:GetDescendants()) do
        if desc:IsA("Frame") or desc:IsA("TextButton") then
            if desc.BackgroundColor3 == CONFIG.Themes["Hello"].Panel then desc.BackgroundColor3 = Theme.Panel end
            if desc.BackgroundColor3 == CONFIG.Themes["Hello"].Accent then desc.BackgroundColor3 = Theme.Accent end
            if desc.BackgroundColor3 == CONFIG.Themes["Hello"].Bg then desc.BackgroundColor3 = Theme.Bg end
            if desc.BackgroundColor3 == CONFIG.Themes["Hello"].Stroke then desc.BackgroundColor3 = Theme.Stroke end
        end
        if desc:IsA("TextLabel") or desc:IsA("TextBox") then
            if desc.TextColor3 == CONFIG.Themes["Hello"].Text then desc.TextColor3 = Theme.Text end
            if desc.TextColor3 == CONFIG.Themes["Hello"].Accent then desc.TextColor3 = Theme.Accent end
            if desc.TextColor3 == CONFIG.Themes["Hello"].SubText then desc.TextColor3 = Theme.SubText end
        end
        if desc:IsA("UIStroke") then
            if desc.Color == CONFIG.Themes["Hello"].Stroke then desc.Color = Theme.Stroke end
            if desc.Color == CONFIG.Themes["Hello"].Accent then desc.Color = Theme.Accent end
        end
    end
    
    if self.AmbientContainer then
        for _, child in ipairs(self.AmbientContainer:GetChildren()) do child:Destroy() end
    end
    
    self:Notify({Title="Theme Changed", Content="Switched to "..name, Duration=2})
end

function Window:ConnectSearch()
    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(self.SearchBox.Text)
        for _, tab in pairs(self.Tabs) do
            for _, comp in ipairs(tab.LeftCol:GetChildren()) do if comp:IsA("Frame") then comp.Visible = q=="" or string.find(string.lower(comp.Name or ""), q) end end
            for _, comp in ipairs(tab.RightCol:GetChildren()) do if comp:IsA("Frame") then comp.Visible = q=="" or string.find(string.lower(comp.Name or ""), q) end end
        end
    end)
end

function Window:Notify(data)
    local n = create("Frame", { Size = UDim2.fromOffset(250, 60), Position = UDim2.new(1, 300, 0, 20), BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.2 }, self.Screen)
    corner(n, 8); stroke(n, Theme.Accent, 0.2, 1.5)
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.fromOffset(10, 8), BackgroundTransparency = 1, Text = data.Title or "Notification", TextColor3 = Theme.Accent, TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left }, n)
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 25), Position = UDim2.fromOffset(10, 28), BackgroundTransparency = 1, Text = data.Content or "", TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, n)
    
    tween(n, 0.4, { Position = UDim2.new(1, -270, 0, 20) }, CONFIG.Anim.Spring)
    task.delay(data.Duration or 3, function()
        local out = tween(n, 0.3, { Position = UDim2.new(1, 300, 0, 20), BackgroundTransparency = 1 })
        if out then out.Completed:Wait(); n:Destroy() end
    end)
end

function Window:Destroy()
    self.Destroyed = true
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if self.Screen then self.Screen:Destroy() end
end

HelloHub.Effects = Effects

-- =====================================================================
-- DEMO SCRIPT (ทดสอบ)
-- =====================================================================
task.spawn(function()
    task.wait(1)
    
    local UI = HelloHub.new({ Title = "HelloHub Premium" })
    UI:ConnectSearch()

    local MainTab = UI:CreateTab({ Name = "Main", Icon = "🏠" })
    local ThemeTab = UI:CreateTab({ Name = "Themes", Icon = "🎨" })

    MainTab:AddSection("✨", "Features", { Column = "Left" })
    MainTab:AddButton({ Name = "Click Me (Particle Effect)", Column = "Left", Callback = function() UI:Notify({Title="Action", Content="Clicked!", Duration=2}) end })
    MainTab:AddToggle({ Name = "Auto Farm", Column = "Left", Default = true })
    MainTab:AddSlider({ Name = "Walk Speed", Column = "Left", Min = 16, Max = 200, Default = 16 })
    
    -- ทดสอบ Dropdown แนวนอน (อนิเมชั่น)
    MainTab:AddDropdown({ Name = "Select Mode", Column = "Left", Options = {"ปกติ", "กระโดด", "Hacker", "ฟาร์ม", "อื่นๆ"} })

    MainTab:AddSection("📝", "Info", { Column = "Right" })
    MainTab:AddInput({ Name = "Player Name", Column = "Right", Default = "Admin" })
    MainTab:AddKeybind({ Name = "Toggle UI", Column = "Right", Default = "RightShift" })

    ThemeTab:AddSection("🎨", "Select Theme", { Column = "Left" })
    ThemeTab:AddDropdown({ 
        Name = "Theme", 
        Column = "Left", 
        Options = {"Hello", "Ocean", "Autumn", "Sunset", "Cyberpunk", "Christmas", "Valentine", "Summer", "Halloween", "Dark"},
        Callback = function(theme) UI:SetTheme(theme) end
    })

    UI:Notify({ Title = "Welcome", Content = "Dropdown แนวนอน + อนิเมชั่นพร้อมใช้!", Duration = 4 })
end)
