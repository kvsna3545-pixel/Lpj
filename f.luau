-- ══════════════════════════════════════════════════════════════
--  🐟 FISH MAP HUB — ใช้ API ของ HelloHub (ตาม Hh_ui.luau ของคุณ)
-- ══════════════════════════════════════════════════════════════

local HelloHubLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/kvsna3545-pixel/Lpj/refs/heads/main/Hh_ui.luau"
))()

-- ─── Services ─────────────────────────────────────────────────
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local VirtualUser       = game:GetService("VirtualUser")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

-- ลบ GUI เก่า
do
    local parents = {PlayerGui}
    if gethui then pcall(function() table.insert(parents, gethui()) end) end
    for _, p in ipairs(parents) do
        for _, g in ipairs(p:GetChildren()) do
            if g:IsA("ScreenGui") and g.Name == "HelloHub" then
                pcall(function() g:Destroy() end)
            end
        end
    end
end

-- ─── Window ───────────────────────────────────────────────────
local Win = HelloHubLib:CreateWindow({
    Name = "Fish Map Hub",
    Theme = "Halloween",
    Size = UDim2.fromOffset(580, 420),
    ToggleKey = Enum.KeyCode.RightShift,
})

local TabFarm = Win:CreateTab("ฟาร์ม")
local TabTP   = Win:CreateTab("วาร์ป")
local TabMisc = Win:CreateTab("อื่นๆ")

-- ─── State ────────────────────────────────────────────────────
local State = {
    AutoFish  = false,
    AutoSell  = false,
    FishDelay = 1.5,
    SellDelay = 2,
    AntiAFK   = true,
}

-- ─── ค้นหา Remote (แก้ชื่อให้ตรงกับเกม Fish ที่คุณเล่น) ───────
local function findRemote(...)
    for _, name in ipairs({...}) do
        local r = ReplicatedStorage:FindFirstChild(name, true)
        if r then return r end
    end
    return nil
end

local CastRemote = findRemote("CastRod", "Cast", "CastRodEvent", "CastEvent", "CastLine", "CastFishing")
local ReelRemote = findRemote("ReelRod", "Reel", "ReelRodEvent", "ReelEvent", "ReelLine", "ReelFishing")
local SellRemote = findRemote("SellFish", "SellAll", "Sell", "SellEvent", "SellInventory")

task.defer(function()
    Win:Notify({
        Title = "Fish Map",
        Content = (CastRemote and "✅ พบ Cast" or "⚠️ ไม่พบ Cast Remote") .. " | " ..
                  (ReelRemote and "✅ พบ Reel" or "⚠️ ไม่พบ Reel Remote"),
        Duration = 5,
    })
end)

-- ─── Loops ────────────────────────────────────────────────────
local function autoFishLoop()
    while State.AutoFish do
        pcall(function() if CastRemote then CastRemote:FireServer() end end)
        task.wait(math.random(10, 25) / 10)
        pcall(function() if ReelRemote then ReelRemote:FireServer() end end)
        task.wait(State.FishDelay)
    end
end

local function autoSellLoop()
    while State.AutoSell do
        pcall(function()
            if not SellRemote then return end
            if SellRemote:IsA("RemoteFunction") then
                SellRemote:InvokeServer()
            else
                SellRemote:FireServer()
            end
        end)
        task.wait(State.SellDelay)
    end
end

-- ══════════════════════════════════════════════════════════════
--  TAB ฟาร์ม
-- ══════════════════════════════════════════════════════════════
TabFarm:AddLabel("🐟 ระบบตกปลา")

TabFarm:AddToggle({
    Name = "Auto Fish (ตกปลาอัตโนมัติ)",
    Default = false,
    Callback = function(Value)
        State.AutoFish = Value
        if Value then
            task.spawn(autoFishLoop)
            Win:Notify({Title = "Fish Map", Content = "เปิด Auto Fish แล้ว", Duration = 3})
        else
            Win:Notify({Title = "Fish Map", Content = "ปิด Auto Fish แล้ว", Duration = 3})
        end
    end,
})

TabFarm:AddSlider({
    Name = "หน่วงเวลาตกปลา",
    Min = 0.5,
    Max = 5,
    Default = 1.5,
    Increment = 0.1,
    Callback = function(Value)
        State.FishDelay = tonumber(Value) or 1.5
    end,
})

TabFarm:AddLabel("💰 ระบบขายปลา")

TabFarm:AddToggle({
    Name = "Auto Sell (ขายปลาอัตโนมัติ)",
    Default = false,
    Callback = function(Value)
        State.AutoSell = Value
        if Value then
            task.spawn(autoSellLoop)
            Win:Notify({Title = "Fish Map", Content = "เปิด Auto Sell แล้ว", Duration = 3})
        else
            Win:Notify({Title = "Fish Map", Content = "ปิด Auto Sell แล้ว", Duration = 3})
        end
    end,
})

TabFarm:AddSlider({
    Name = "หน่วงเวลาขายปลา",
    Min = 1,
    Max = 10,
    Default = 2,
    Increment = 0.5,
    Callback = function(Value)
        State.SellDelay = tonumber(Value) or 2
    end,
})

TabFarm:AddButton({
    Name = "ขายปลาทันที (ครั้งเดียว)",
    Callback = function()
        if not SellRemote then
            Win:Notify({Title = "Fish Map", Content = "ไม่พบ Sell Remote", Duration = 3})
            return
        end
        pcall(function()
            if SellRemote:IsA("RemoteFunction") then
                SellRemote:InvokeServer()
            else
                SellRemote:FireServer()
            end
        end)
        Win:Notify({Title = "Fish Map", Content = "ขายปลาแล้ว", Duration = 3})
    end,
})

-- ══════════════════════════════════════════════════════════════
--  TAB วาร์ป
-- ══════════════════════════════════════════════════════════════
local function tp(pos)
    local c = LocalPlayer.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if r then r.CFrame = CFrame.new(pos) end
end

TabTP:AddButton({
    Name = "วาร์ปไปจุดเกิด (Spawn)",
    Callback = function()
        tp(Vector3.new(0, 10, 0)) -- ⚠️ แก้พิกัดตามแมพจริง
        Win:Notify({Title = "Fish Map", Content = "วาร์ปไป Spawn แล้ว", Duration = 3})
    end,
})

TabTP:AddButton({
    Name = "วาร์ปไปจุดตกปลา",
    Callback = function()
        tp(Vector3.new(100, 10, 100)) -- ⚠️ แก้พิกัดตามแมพจริง
        Win:Notify({Title = "Fish Map", Content = "วาร์ปไปจุดตกปลาแล้ว", Duration = 3})
    end,
})

TabTP:AddTextbox({
    Name = "ตำแหน่งกำหนดเอง (x,y,z)",
    Placeholder = "เช่น 0, 10, 0",
    Default = "",
    Callback = function(text)
        local x, y, z = tostring(text):match("([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)")
        if x and y and z then
            tp(Vector3.new(tonumber(x), tonumber(y), tonumber(z)))
            Win:Notify({Title = "Fish Map", Content = ("วาร์ปไป (%s, %s, %s)"):format(x, y, z), Duration = 3})
        else
            Win:Notify({Title = "Fish Map", Content = "รูปแบบไม่ถูกต้อง ใช้ x,y,z", Duration = 3})
        end
    end,
})

-- วาร์ปหาผู้เล่น
local SelectedPlayer = nil
local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    table.sort(names)
    return names
end

local PlayerDropdown = TabTP:AddDropdown({
    Name = "เลือกผู้เล่น",
    Items = getPlayerNames(),
    Default = nil,
    Callback = function(v) SelectedPlayer = v end,
})

Players.PlayerAdded:Connect(function()
    task.wait(0.2)
    if PlayerDropdown and PlayerDropdown.SetItems then
        PlayerDropdown:SetItems(getPlayerNames())
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if SelectedPlayer == p.Name then SelectedPlayer = nil end
    task.wait(0.2)
    if PlayerDropdown and PlayerDropdown.SetItems then
        PlayerDropdown:SetItems(getPlayerNames())
    end
end)

TabTP:AddButton({
    Name = "วาร์ปไปหาผู้เล่นที่เลือก",
    Callback = function()
        if not SelectedPlayer then
            Win:Notify({Title = "Fish Map", Content = "กรุณาเลือกผู้เล่นก่อน", Duration = 3})
            return
        end
        local target = Players:FindFirstChild(SelectedPlayer)
        if not target or not target.Character then
            Win:Notify({Title = "Fish Map", Content = "ไม่พบผู้เล่นหรือ Character", Duration = 3})
            return
        end
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and myRoot then
            myRoot.CFrame = targetRoot.CFrame
            Win:Notify({Title = "Fish Map", Content = "วาร์ปไปหา " .. target.Name .. " แล้ว", Duration = 3})
        end
    end,
})

-- ══════════════════════════════════════════════════════════════
--  TAB อื่นๆ
-- ══════════════════════════════════════════════════════════════
TabMisc:AddToggle({
    Name = "กันโดนเตะ (Anti-AFK)",
    Default = true,
    Callback = function(Value)
        State.AntiAFK = Value
        Win:Notify({
            Title = "Fish Map",
            Content = Value and "เปิด Anti-AFK แล้ว" or "ปิด Anti-AFK แล้ว",
            Duration = 3,
        })
    end,
})

LocalPlayer.Idled:Connect(function()
    if not State.AntiAFK then return end
    pcall(function()
        local cam = workspace.CurrentCamera
        VirtualUser:Button2Down(Vector2.new(0, 0), cam.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), cam.CFrame)
    end)
end)

TabMisc:AddButton({
    Name = "รีเซ็ตตัวละคร (Reset)",
    Callback = function()
        local c = LocalPlayer.Character
        if c then
            pcall(function() c:BreakJoints() end)
            Win:Notify({Title = "Fish Map", Content = "รีเซ็ตตัวละครแล้ว", Duration = 3})
        end
    end,
})

-- Noclip
local NoclipEnabled = false
local NoclipSaved, NoclipConn = {}, nil

local function setNoclip(on)
    if on then
        if not NoclipConn then
            NoclipConn = RunService.Stepped:Connect(function()
                if not NoclipEnabled then return end
                local c = LocalPlayer.Character
                if not c then return end
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if NoclipSaved[p] == nil then
                            NoclipSaved[p] = p.CanCollide
                        end
                        p.CanCollide = false
                    end
                end
            end)
        end
    else
        if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
        for p, v in pairs(NoclipSaved) do
            if p.Parent then p.CanCollide = v end
        end
        NoclipSaved = {}
    end
end

TabMisc:AddToggle({
    Name = "ทะลุกำแพง (Noclip)",
    Default = false,
    Callback = function(Value)
        NoclipEnabled = Value
        setNoclip(Value)
    end,
})

-- ══════════════════════════════════════════════════════════════
--  แจ้งเตือนโหลดเสร็จ
-- ══════════════════════════════════════════════════════════════
Win:Notify({
    Title = "Fish Map Hub",
    Content = "โหลดสำเร็จ! กด RightShift เพื่อเปิด/ปิด UI",
    Duration = 5,
})

print("[Fish Map Hub] โหลดสำเร็จ")
