local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local HELLOHUB_UI_VERSION = "6.2.0"

-- ปิดอินสแตนซ์ Infinity Slide จากสคริปต์เก่าที่อาจยังค้างอยู่
local StartupEnv = getgenv()
if type(StartupEnv.KRYVEX_SlideCleanup) == "function" then
    pcall(StartupEnv.KRYVEX_SlideCleanup)
    StartupEnv.KRYVEX_SlideCleanup = nil
end
StartupEnv.KRYVEX_SlideSpeedOverrideActive = nil

-- [FIX] ตัวช่วยค้นหา/รอ Remote แบบมี timeout (เดิมใช้ WaitForChild ไม่จำกัดเวลา
-- ถ้าเกมอัปเดตแล้วชื่อ/ตำแหน่ง Remote เปลี่ยน สคริปต์จะค้างตรงนั้นและส่วนที่เหลือไม่โหลดเลย)
local HelloHubUtil = {
    MissingPaths = {},
    WarnedPaths = {},
}

function HelloHubUtil.PathKey(root, path)
    return tostring(root) .. "/" .. table.concat(path, "/")
end

function HelloHubUtil.FindPath(root, path)
    local current = root
    for _, name in ipairs(path) do
        if not current then
            return nil
        end
        current = current:FindFirstChild(name)
    end
    return current
end

-- คืนค่า Instance ปลายทาง หรือ nil ถ้าไม่พบภายในเวลาที่กำหนด
-- ถ้าเคยรอแล้วไม่เจอ จะไม่รอซ้ำ (กันหน่วงตอนโหลดสคริปต์หลายบล็อกที่ใช้ path เดียวกัน)
function HelloHubUtil.WaitPath(root, path, timeout)
    local key = HelloHubUtil.PathKey(root, path)
    local found = HelloHubUtil.FindPath(root, path)
    if found then
        HelloHubUtil.MissingPaths[key] = nil
        return found
    end
    if HelloHubUtil.MissingPaths[key] then
        return nil
    end

    local deadline = os.clock() + (timeout or 5)
    local current = root
    for _, name in ipairs(path) do
        current = current:WaitForChild(name, math.max(0.05, deadline - os.clock()))
        if not current then
            HelloHubUtil.MissingPaths[key] = true
            return nil
        end
    end
    return current
end

-- คืน RemoteEvent จริงถ้าเจอ ถ้าไม่เจอจะคืนตัวแทนที่มี :FireServer
-- (จะลองหา Remote ใหม่ทุกครั้งที่เรียก และ error เมื่อยังไม่พบ ซึ่งโค้ดเดิมครอบ pcall อยู่แล้ว)
function HelloHubUtil.RemoteProxy(root, path, timeout)
    local remote = HelloHubUtil.WaitPath(root, path, timeout)
    if remote then
        return remote
    end

    local label = table.concat(path, ".")
    if not HelloHubUtil.WarnedPaths[label] then
        HelloHubUtil.WarnedPaths[label] = true
        warn("[HelloHub] ไม่พบ Remote: " .. label .. " (ฟีเจอร์ที่ใช้ Remote นี้จะข้ามไปจนกว่าจะพบ)")
    end

    return {
        FireServer = function(_, ...)
            local found = HelloHubUtil.FindPath(root, path)
            if not found then
                error("ไม่พบ Remote: " .. label, 0)
            end
            return found:FireServer(...)
        end,
    }
end

-- HelloHub UI v6.2.0
-- ไฟล์ต้นทางมี Test Suite ต่อท้ายและไม่มี return HelloHub:
-- ตัดส่วนทดสอบออกเพื่อไม่ให้สร้างหน้าต่างทดสอบซ้อน แล้วคืนค่าไลบรารีอย่างชัดเจน
local HELLOHUB_UI_URL = "https://raw.githubusercontent.com/kvsna3545-pixel/Lpj/refs/heads/main/test_ui_testbyme"

local HelloHubLoadOk, HelloHub = pcall(function()
    local Source = game:HttpGet(HELLOHUB_UI_URL)
    local TestMarker = string.find(Source, "-- PART 2: TEST SCRIPT", 1, true)

    if TestMarker then
        Source = string.sub(Source, 1, TestMarker - 1)
    end

    Source = Source .. "\nreturn HelloHub"

    local LibraryChunk, CompileError = loadstring(Source)
    if not LibraryChunk then
        error("คอมไพล์ HelloHub v6.2.0 ไม่สำเร็จ: " .. tostring(CompileError))
    end

    local Library = LibraryChunk()
    if type(Library) ~= "table" or type(Library.new) ~= "function" then
        error("ไฟล์ UI ไม่ได้ส่งออก HelloHub.new ตาม API v6.2.0")
    end

    return Library
end)

if not HelloHubLoadOk or not HelloHub then
    warn("[HelloHub] โหลด UI v6.2.0 ไม่สำเร็จ: " .. tostring(HelloHub))
    return
end

-- API v6.2.0: HelloHub.new({ Title, Logo, Flags })
local Window = HelloHub.new({
    Title = "HelloHub | Evade Edition",
    Logo = "rbxassetid://75164736067854",
    Flags = {},
})

if not Window then
    warn("[HelloHub] สร้างหน้าต่าง UI ไม่สำเร็จ")
    return
end

Window:ConnectSearch()

-- ลำดับแท็บเดิม โดยใช้รูปแบบ options table ของ API v6.2.0
local MainTab = Window:CreateTab({ Name = "เมนูหลัก" })
local DashTab = Window:CreateTab({ Name = "แดช" })
local VisualTab = Window:CreateTab({ Name = "มองสิ่งต่างๆ" })
local ScreenTab = Window:CreateTab({ Name = "ภาพจอ" })
local TeleportTab = Window:CreateTab({ Name = "วาร์ป" })
local FarmTab = Window:CreateTab({ Name = "ฟาร์ม" })
local EventTab = Window:CreateTab({ Name = "อีเวนท์" })
local MapTab = Window:CreateTab({ Name = "แมพ" })
local SettingsTab = Window:CreateTab({ Name = "ตั้งค่า" })
local OtherTab = Window:CreateTab({ Name = "อื่นๆ" })

local currentSettings = {
Speed = 1555,
JumpCap = 2,
AirStrafeAcceleration = 187
}

getgenv().ApplyMode = "Optimized"
getgenv().AutoApplySettings = true
getgenv().KRYVEX_PreserveSpeedBoost = true

local MAX_VALUE = 30000

local function safe(Value)
Value = tonumber(Value) or 0

if Value > MAX_VALUE then
return MAX_VALUE
end

if Value < 0 then
return 0
end

return Value

end

local requiredFields = {
Friction = true,
AirStrafeAcceleration = true,
JumpHeight = true,
RunDeaccel = true,
JumpSpeedMultiplier = true,
JumpCap = true,
SprintCap = true,
WalkSpeedMultiplier = true,
BhopEnabled = true,
Speed = true,
AirAcceleration = true,
RunAccel = true,
SprintAcceleration = true
}

local cachedTables

-- จดค่า Speed ดั้งเดิมต่อ table เพื่อแยกการเปลี่ยนชั่วคราวออกจากการคืนค่าเกม
local SpeedMonitorEnv = getgenv()
SpeedMonitorEnv.KRYVEX_SpeedBaselineMonitorGeneration =
    (SpeedMonitorEnv.KRYVEX_SpeedBaselineMonitorGeneration or 0) + 1
local SpeedMonitorGeneration = SpeedMonitorEnv.KRYVEX_SpeedBaselineMonitorGeneration

local NativeSpeedByTable = SpeedMonitorEnv.KRYVEX_NativeSpeedByTable
if type(NativeSpeedByTable) ~= "table" then
    NativeSpeedByTable = setmetatable({}, { __mode = "k" })
    SpeedMonitorEnv.KRYVEX_NativeSpeedByTable = NativeSpeedByTable
end

local NativeReturnSince = setmetatable({}, { __mode = "k" })
local SPEED_RESTORE_STABLE_TIME = 2.5
local SPEED_COMPARE_EPSILON = 0.001

local function getMatchingTables()
-- ใช้ cache ไปจนกว่าจะมีการ invalidate (เปลี่ยนค่า/เกิดใหม่)
-- ป้องกันการสแกน getgc(true) ทั้งเกมซ้ำทุกไม่กี่วินาที
if cachedTables then
return cachedTables
end

local Result = {}

-- [FIX] executor บางตัวไม่มี getgc: คืนตารางว่างแทนการ error
if type(getgc) ~= "function" then
    return Result
end

for _, Object in ipairs(getgc(true)) do
if typeof(Object) == "table" then
local Valid = true

for Field in pairs(requiredFields) do
if rawget(Object, Field) == nil then
Valid = false
break
end
end

if Valid then
table.insert(Result, Object)
end

end

end

if #Result > 0 then
cachedTables = Result
end
return Result

end

local function applyToTables()
local Mode = getgenv().ApplyMode
local Tables = getMatchingTables()

for _, Table in ipairs(Tables) do
pcall(function()
if Mode == "Not Optimized" then
if getgenv().KRYVEX_PreserveSpeedBoost ~= true then
Table.Speed = currentSettings.Speed
end
Table.JumpCap = currentSettings.JumpCap
Table.AirStrafeAcceleration =
currentSettings.AirStrafeAcceleration
else
if getgenv().KRYVEX_PreserveSpeedBoost ~= true
and Table.Speed ~= currentSettings.Speed then
Table.Speed = currentSettings.Speed
end

if Table.JumpCap ~= currentSettings.JumpCap then
Table.JumpCap = currentSettings.JumpCap
end

if Table.AirStrafeAcceleration
~= currentSettings.AirStrafeAcceleration then

Table.AirStrafeAcceleration =          
        currentSettings.AirStrafeAcceleration          
end

end

end)

end

end

local function applySpeedBaseline()
    local Tables = getMatchingTables()
    local Applied = 0

    for _, Table in ipairs(Tables) do
        local CurrentSpeed = rawget(Table, "Speed")
        if NativeSpeedByTable[Table] == nil and type(CurrentSpeed) == "number" then
            NativeSpeedByTable[Table] = CurrentSpeed
        end

        local Success = pcall(function()
            Table.Speed = currentSettings.Speed
        end)
        if Success then
            Applied += 1
        end
    end

    return Applied > 0, Applied
end

local function RefreshNativeSpeedCache(Tables)
    for _, Table in ipairs(Tables) do
        local CurrentSpeed = rawget(Table, "Speed")
        if type(CurrentSpeed) == "number" then
            NativeSpeedByTable[Table] = CurrentSpeed
            NativeReturnSince[Table] = nil
        end
    end
end

-- ถ้าเกมคืน Speed เป็นค่าเดิมหลังบัฟหมด ให้รอค่านิ่งก่อนคืนค่าฐาน
-- อ่านเฉพาะ cache ที่มีอยู่ ไม่เรียก getgc ซ้ำในลูปนี้
local function StartSpeedBaselineMonitor()
    task.spawn(function()
        while SpeedMonitorEnv.KRYVEX_SpeedBaselineMonitorGeneration
            == SpeedMonitorGeneration do
            if getgenv().KRYVEX_PreserveSpeedBoost == true and cachedTables then
                for _, Table in ipairs(cachedTables) do
                    local CurrentSpeed = rawget(Table, "Speed")
                    local NativeSpeed = NativeSpeedByTable[Table]

                    if type(CurrentSpeed) == "number"
                        and type(NativeSpeed) == "number"
                        and math.abs(CurrentSpeed - NativeSpeed) <= SPEED_COMPARE_EPSILON
                        and math.abs(currentSettings.Speed - NativeSpeed) > SPEED_COMPARE_EPSILON then

                        local Since = NativeReturnSince[Table]
                        if not Since then
                            NativeReturnSince[Table] = os.clock()
                        elseif os.clock() - Since >= SPEED_RESTORE_STABLE_TIME then
                            pcall(function()
                                local LatestSpeed = rawget(Table, "Speed")
                                if type(LatestSpeed) == "number"
                                    and math.abs(LatestSpeed - NativeSpeed) <= SPEED_COMPARE_EPSILON
                                    and getgenv().KRYVEX_PreserveSpeedBoost == true then
                                    Table.Speed = currentSettings.Speed
                                end
                            end)
                            NativeReturnSince[Table] = nil
                        end
                    else
                        NativeReturnSince[Table] = nil
                    end
                end
            end

            task.wait(1)
        end
    end)
end

StartSpeedBaselineMonitor()

-- ส่ง SetPlayerMode(true) เพียงครั้งเดียว เมื่อผู้ใช้เปลี่ยน Speed ครั้งแรก
local SpeedModeSignalSent = false
local SpeedBaselineReapplyPending = false
local function SendSpeedModeSignalOnce()
    if SpeedModeSignalSent then
        return
    end

    local RequestWithReturn = getgenv().KRYVEX_SendSpeedModeWithReturnPosition
    if type(RequestWithReturn) ~= "function" then
        -- UI อาจถูกกดก่อนบล็อก Auto Respawn จะประกาศ bridge; อนุญาตให้ลองใหม่เมื่อมีการแก้ค่าอีกครั้ง
        warn("[HelloHub Speed] ระบบคืนตำแหน่งยังไม่พร้อม")
        return
    end

    -- ล็อกก่อนเรียก เพื่อไม่ให้การปรับครั้งถัดไปส่งซ้ำ
    SpeedModeSignalSent = true

    local CallSuccess, RequestSuccess, ErrorMessage = pcall(RequestWithReturn)
    if not CallSuccess then
        warn("[HelloHub Speed] เรียก SetPlayerMode ไม่สำเร็จ:", RequestSuccess)
    elseif RequestSuccess == false then
        warn("[HelloHub Speed] ส่ง SetPlayerMode ไม่สำเร็จ:", ErrorMessage)
    end
end

-- ปรับค่าเป็นรอบละ 1 วินาที แทนการเขียนซ้ำทุกเฟรม
-- Generation ทำให้ loop เก่าหยุดเองเมื่อรันสคริปต์ซ้ำ
local AutoApplyEnv = getgenv()
AutoApplyEnv.KRYVEX_AutoApplyGeneration =
    (AutoApplyEnv.KRYVEX_AutoApplyGeneration or 0) + 1
local AutoApplyGeneration = AutoApplyEnv.KRYVEX_AutoApplyGeneration

task.spawn(function()
    while AutoApplyEnv.KRYVEX_AutoApplyGeneration == AutoApplyGeneration do
        if AutoApplyEnv.AutoApplySettings then
            applyToTables()
        end
        task.wait(1)
    end
end)


SettingsTab:AddInput({
Name = "ความเร็ว",
Placeholder = "ใส่ตัวเลข",
Default = tostring(currentSettings.Speed),

Callback = function(Value)
local Number = tonumber(Value)

if Number then
local NewSpeed = safe(Number)
local SpeedChanged = NewSpeed ~= currentSettings.Speed

currentSettings.Speed = NewSpeed
cachedTables = nil

if getgenv().KRYVEX_PreserveSpeedBoost == true then
    applySpeedBaseline()
else
    applyToTables()
end

if SpeedChanged then
    SpeedBaselineReapplyPending = true
    SendSpeedModeSignalOnce()
end
end

end

})

SettingsTab:AddToggle({
    Name = "รักษาบัฟความเร็ว",
    Default = true,
    Callback = function(Value)
        getgenv().KRYVEX_PreserveSpeedBoost = Value and true or false
        cachedTables = nil

        if getgenv().KRYVEX_PreserveSpeedBoost then
            -- เปิดรักษาบัฟ: อย่าเขียนทับ Speed ปัจจุบัน แต่อัปเดตค่าอื่นได้
            applyToTables()
        else
            -- ปิดรักษาบัฟ: กลับไปคุม Speed ตามค่าที่กรอก
            applySpeedBaseline()
            applyToTables()
        end
    end,
})

SettingsTab:AddInput({
Name = "ขีดจำกัดการกระโดด",
Placeholder = "ใส่ตัวเลข",
Default = tostring(currentSettings.JumpCap),

Callback = function(Value)
local Number = tonumber(Value)

if Number then
currentSettings.JumpCap = safe(Number)
applyToTables()
end

end

})

SettingsTab:AddInput({
Name = "ความเร่งกลางอากาศ",
Placeholder = "ใส่ตัวเลข",
Default = tostring(currentSettings.AirStrafeAcceleration),

Callback = function(Value)
local Number = tonumber(Value)

if Number then
currentSettings.AirStrafeAcceleration = safe(Number)
applyToTables()
end

end

})


SettingsTab:AddDropdown({
Name = "วิธีการปรับค่า",

Options = {
"Not Optimized",
"Optimized"
},

Default = "Optimized",

Callback = function(Option)
getgenv().ApplyMode = Option
cachedTables = nil
applyToTables()
end

})

SettingsTab:AddToggle({
Name = "ปรับค่าอัตโนมัติ",
Default = true,

Callback = function(Value)
getgenv().AutoApplySettings = Value

if Value then
cachedTables = nil
applyToTables()
end

end

})

SettingsTab:AddButton({
Name = "รีเซ็ตค่าการเคลื่อนไหว",

Callback = function()
currentSettings.Speed = 1500
currentSettings.JumpCap = 2
currentSettings.AirStrafeAcceleration = 187

cachedTables = nil
applyToTables()
applySpeedBaseline()

Window:Notify({
Title = "HelloHub",
Content = "รีเซ็ตค่าการเคลื่อนไหวแล้ว",
Duration = 3
})

end

})

local SpeedRespawnEnv = getgenv()
SpeedRespawnEnv.KRYVEX_SpeedRespawnGeneration =
    (SpeedRespawnEnv.KRYVEX_SpeedRespawnGeneration or 0) + 1
local SpeedRespawnGeneration = SpeedRespawnEnv.KRYVEX_SpeedRespawnGeneration

local function ApplySpeedAfterCharacter(Character)
    task.spawn(function()
        local Humanoid = Character:WaitForChild("Humanoid", 10)
        local Root = Character:WaitForChild("HumanoidRootPart", 10)
        if not Humanoid or not Root then
            return
        end

        task.wait(0.75)

        for Attempt = 1, 8 do
            if SpeedRespawnEnv.KRYVEX_SpeedRespawnGeneration ~= SpeedRespawnGeneration
                or LocalPlayer.Character ~= Character then
                return
            end

            local ShouldApplySpeed = getgenv().AutoApplySettings == true
                or SpeedBaselineReapplyPending
            if not ShouldApplySpeed then
                return
            end

            cachedTables = nil
            local Tables = getMatchingTables()
            RefreshNativeSpeedCache(Tables)

            if getgenv().AutoApplySettings then
                applyToTables()
            end

            local Applied = applySpeedBaseline()
            if Applied then
                SpeedBaselineReapplyPending = false
                return
            end

            if Attempt < 8 then
                task.wait(0.75)
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(ApplySpeedAfterCharacter)

if LocalPlayer.Character then
    ApplySpeedAfterCharacter(LocalPlayer.Character)
end

local AutoJump = false
local AutoJumpConnection = nil
local AutoJumpLastTime = 0
local AUTO_JUMP_COOLDOWN = 0.22

local function DoAutoJump()
local Character = LocalPlayer.Character
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

if not Humanoid or Humanoid.Health <= 0 then
return
end

if Humanoid.FloorMaterial ~= Enum.Material.Air
    and os.clock() - AutoJumpLastTime >= AUTO_JUMP_COOLDOWN then
    AutoJumpLastTime = os.clock()
    Humanoid.Jump = true
    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end

local function StartAutoJump()
if AutoJumpConnection then
AutoJumpConnection:Disconnect()
AutoJumpConnection = nil
end

AutoJumpConnection = RunService.Heartbeat:Connect(function()
if not AutoJump then
return
end

local Character = LocalPlayer.Character
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
local Root = Character and Character:FindFirstChild("HumanoidRootPart")

if not Humanoid or not Root or Humanoid.Health <= 0 then
return
end

-- ใช้ FloorMaterial แทน Raycast ระยะ 4 studs เพื่อไม่สั่งกระโดดซ้ำกลางอากาศ
if Humanoid.FloorMaterial ~= Enum.Material.Air
    and os.clock() - AutoJumpLastTime >= AUTO_JUMP_COOLDOWN then
    AutoJumpLastTime = os.clock()
    Humanoid.Jump = true
    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end)
end

local function SetAutoJump(Value)
AutoJump = Value
if Value then
    AutoJumpLastTime = 0
    DoAutoJump()
end
end

StartAutoJump()

local CONFIG = {
Width = 156,
Height = 60,
Corner = 28,
StartX = 60,
DragThreshold = 6,
DragSmoothing = 28,
EdgeMargin = 4,

ThemeMode = "hello",

Halloween = {
Month = 10,
FromDay = 6,
ToDay = 30,
},

}

local W = CONFIG.Width
local H = CONFIG.Height

local function IsHalloweenSeason()
local OK, Date = pcall(function()
return os.date("*t")
end)

return OK
and type(Date) == "table"
and Date.month == CONFIG.Halloween.Month
and Date.day >= CONFIG.Halloween.FromDay
and Date.day <= CONFIG.Halloween.ToDay

end

local Themes = {

Hello = {
Dark = Color3.fromRGB(160, 105, 255),
Mid = Color3.fromRGB(210, 145, 255),
Silver = Color3.fromRGB(255, 115, 195),
Light = Color3.fromRGB(255, 190, 225),
White = Color3.fromRGB(255, 255, 255),

BgTop = Color3.fromRGB(42, 24, 58),
BgBottom = Color3.fromRGB(16, 10, 26),

PlanetA = Color3.fromRGB(255, 180, 220),
PlanetB = Color3.fromRGB(190, 130, 255),
PlanetC = Color3.fromRGB(90, 55, 125),

On = Color3.fromRGB(255, 150, 210),
Off = Color3.fromRGB(165, 145, 185),
TitleOn = Color3.fromRGB(255, 255, 255),
TitleOff = Color3.fromRGB(205, 190, 220),

},

Halloween = {
Dark = Color3.fromRGB(95, 45, 140),
Mid = Color3.fromRGB(165, 95, 225),
Silver = Color3.fromRGB(255, 125, 20),
Light = Color3.fromRGB(255, 185, 80),
White = Color3.fromRGB(255, 240, 210),

BgTop = Color3.fromRGB(48, 22, 62),
BgBottom = Color3.fromRGB(12, 6, 16),

PlanetA = Color3.fromRGB(255, 175, 60),
PlanetB = Color3.fromRGB(240, 110, 20),
PlanetC = Color3.fromRGB(150, 60, 10),

On = Color3.fromRGB(255, 150, 40),
Off = Color3.fromRGB(150, 115, 175),
TitleOn = Color3.fromRGB(255, 240, 210),
TitleOff = Color3.fromRGB(225, 205, 240),

},

}

local IS_HALLOWEEN =
CONFIG.ThemeMode == "halloween"
or (
CONFIG.ThemeMode == "auto"
and IsHalloweenSeason()
)

local C =
IS_HALLOWEEN
and Themes.Halloween
or Themes.Hello

local GUI_NAME = "HelloHub_FloatingButtons"

local FloatingGui
local FloatingButtons = {}

local function New(Class, Props, Parent)
local Object = Instance.new(Class)

for Key, Value in pairs(Props or {}) do
Object[Key] = Value
end

if Parent then
Object.Parent = Parent
end

return Object

end

local function Corner(Object, Radius)
return New(
"UICorner",
{
CornerRadius = UDim.new(0, Radius)
},
Object
)
end

local function Stroke(
Object,
Color,
Transparency,
Thickness
)
return New(
"UIStroke",
{
Color = Color,
Transparency = Transparency,
Thickness = Thickness,
ApplyStrokeMode =
Enum.ApplyStrokeMode.Border,
},
Object
)
end

local function Tween(
Object,
Time,
Properties,
Style,
Direction
)
local Tw = TweenService:Create(
Object,
TweenInfo.new(
Time,
Style or Enum.EasingStyle.Quad,
Direction or Enum.EasingDirection.Out
),
Properties
)

Tw:Play()

return Tw

end

local function ThemeGradient(Parent)
return New(
"UIGradient",
{
Color = ColorSequence.new({
ColorSequenceKeypoint.new(
0,
C.Dark
),
ColorSequenceKeypoint.new(
0.35,
C.Light
),
ColorSequenceKeypoint.new(
0.7,
C.Silver
),
ColorSequenceKeypoint.new(
1,
C.Dark
),
}),
},
Parent
)
end

local function GetFloatingGui()
if FloatingGui
and FloatingGui.Parent then

return FloatingGui
end

pcall(function()
local Hui = gethui()

if Hui then
local Old = Hui:FindFirstChild(
GUI_NAME
)

if Old then
Old:Destroy()
end

FloatingGui = New(
"ScreenGui",
{
Name = GUI_NAME,
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior =
Enum.ZIndexBehavior.Sibling,
},
Hui
)

end

end)

if not FloatingGui then
FloatingGui = New(
"ScreenGui",
{
Name = GUI_NAME,
ResetOnSpawn = false,
IgnoreGuiInset = true,
ZIndexBehavior =
Enum.ZIndexBehavior.Sibling,
},
game:GetService("CoreGui")
)
end

return FloatingGui

end

local function RemoveFloatingButton(Name)
local Data = FloatingButtons[Name]

if Data then
Data:Destroy()
FloatingButtons[Name] = nil
end

local Count = 0

for _ in pairs(FloatingButtons) do
Count += 1
end

if Count == 0
and FloatingGui then

FloatingGui:Destroy()
FloatingGui = nil

end

end

function CreateFloatingButton(Config)
Config = Config or {}

local Name = Config.Name or "ปุ่ม"
local Mode = Config.Mode or "Toggle"

local Callback =
Config.Callback
or function() end

RemoveFloatingButton(Name)

local Gui = GetFloatingGui()

local Dead = false
local Connections = {}

local function Track(Connection)
table.insert(
Connections,
Connection
)

return Connection

end

local Camera =
workspace.CurrentCamera
or workspace:WaitForChild("Camera")

local function Alive()
return not Dead
and Gui
and Gui.Parent ~= nil
end

local function ClampPos(Value)
local View =
Camera.ViewportSize

local Margin =
CONFIG.EdgeMargin

return Vector2.new(
math.clamp(
Value.X,
Margin,
math.max(
Margin,
View.X - W - Margin
)
),
math.clamp(
Value.Y,
Margin,
math.max(
Margin,
View.Y - H - Margin
)
)
)

end

local StartView =
Camera.ViewportSize

local Pos = ClampPos(
Vector2.new(
CONFIG.StartX,
StartView.Y / 2 - H / 2
)
)

local Target = Pos

local Holder = New(
"Frame",
{
Name = "Holder",
Size = UDim2.fromOffset(W, H),
Position =
UDim2.fromOffset(
Pos.X,
Pos.Y
),
BackgroundTransparency = 1,
},
Gui
)

local Button = New(
"TextButton",
{
Name = "SpaceButton",
AnchorPoint =
Vector2.new(0.5, 0.5),
Position =
UDim2.fromScale(0.5, 0.5),
Size =
UDim2.fromOffset(W, H),
BackgroundColor3 = C.White,
AutoButtonColor = false,
Text = "",
},
Holder
)

Corner(Button, CONFIG.Corner)

New(
"UIGradient",
{
Rotation = 45,

Color =
ColorSequence.new({
ColorSequenceKeypoint.new(
0,
C.BgTop
),
ColorSequenceKeypoint.new(
1,
C.BgBottom
),
}),
},
Button

)

local Scale = New(
"UIScale",
{
Scale = 1
},
Button
)

local EdgeStroke =
Stroke(
Button,
C.White,
0,
2
)

local EdgeGrad =
ThemeGradient(EdgeStroke)

local Inner = New(
"Frame",
{
Name = "Inner",
Size = UDim2.fromScale(1, 1),
BackgroundTransparency = 1,
ClipsDescendants = true,
ZIndex = 2,
},
Button
)

Corner(
Inner,
CONFIG.Corner
)

local Stars = {}

local function AddStar(
Parent,
X,
Y,
Size,
Color,
ZIndex
)
local Star = New(
"Frame",
{
AnchorPoint =
Vector2.new(0.5, 0.5),

Position =
UDim2.new(
0.5,
X,
0.5,
Y
),

Size =
UDim2.fromOffset(
Size,
Size
),

BackgroundColor3 =          
    Color,          

BackgroundTransparency =          
    0.9,          

BorderSizePixel = 0,          

ZIndex = ZIndex,

},
Parent

)

Corner(Star, 3)

table.insert(
Stars,
{
Frame = Star,
Rate =
1.5

- math.random() * 2.5,
  Phase =
  math.random()

- math.pi
- 2,
  }
  )

end

local InnerStarColors = {
C.White,
C.Silver,
C.Mid
}

local PLANET_X = 31

for _ = 1, 8 do
local Angle =
math.random()

- math.pi
- 2

local Radius =
math.sqrt(
math.random()
)

AddStar(
Inner,
(-W / 2 + PLANET_X)

- math.cos(Angle)

- Radius
- 26,

math.sin(Angle)
* Radius
* (H / 2 - 10),

math.random(1, 2),

InnerStarColors[
math.random(
#InnerStarColors
)
],

2

)

end

local Planet = New(
"Frame",
{
AnchorPoint =
Vector2.new(0.5, 0.5),

Position =
UDim2.new(
0,
PLANET_X,
0.5,
0
),

Size =
UDim2.fromOffset(
26,
26
),

BackgroundColor3 =
C.White,

BorderSizePixel = 0,

ZIndex = 3,

},
Inner

)

Corner(Planet, 13)

New(
"UIGradient",
{
Rotation = 45,

Color =
ColorSequence.new({
ColorSequenceKeypoint.new(
0,
C.PlanetA
),
ColorSequenceKeypoint.new(
0.6,
C.PlanetB
),
ColorSequenceKeypoint.new(
1,
C.PlanetC
),
}),
},
Planet

)

local PlanetRing = New(
"Frame",
{
AnchorPoint =
Vector2.new(0.5, 0.5),

Position =
UDim2.new(
0,
PLANET_X,
0.5,
0
),

Size =
UDim2.fromOffset(
46,
14
),

BackgroundTransparency = 1,
Rotation = -22,
ZIndex = 4,

},
Inner

)

Corner(PlanetRing, 8)

Stroke(
PlanetRing,
C.Silver,
0.15,
2
)

local FaceParts = {}

local FaceOff =
Color3.fromRGB(
40,
14,
48
)

local FaceOn =
Color3.fromRGB(
255,
235,
120
)

if IS_HALLOWEEN then
PlanetRing.Visible = false

local function Part(
X,
Y,
Width,
Height,
Rotation,
Radius,
Color,
Face
)
local PartObject = New(
"Frame",
{
Position =
UDim2.fromOffset(
X,
Y
),

Size =
UDim2.fromOffset(
Width,
Height
),

Rotation = Rotation,          

    BackgroundColor3 =          
        Color,          

    BorderSizePixel = 0,          

    ZIndex = 4,          
},          
Planet

)

Corner(
PartObject,
Radius
)

if Face then
table.insert(
FaceParts,
PartObject
)
end

end

Part(
5,
8,
5,
5,
45,
1,
FaceOff,
true
)

Part(
16,
8,
5,
5,
45,
1,
FaceOff,
true
)

Part(
7,
16,
12,
5,
0,
2,
FaceOff,
true
)

Part(
11,
-3,
5,
6,
-12,
2,
Color3.fromRGB(
80,
130,
50
),
false
)

end

local FX = New(
"Frame",
{
Name = "SpaceFX",
Size =
UDim2.fromScale(1, 1),
BackgroundTransparency = 1,
ZIndex = 5,
},
Button
)

local function NebulaRing(
Padding,
Thickness,
Transparency
)
local Ring = New(
"Frame",
{
AnchorPoint =
Vector2.new(0.5, 0.5),

Position =
UDim2.fromScale(
0.5,
0.5
),

Size =
UDim2.new(
1,
Padding,
1,
Padding
),

BackgroundTransparency = 1,          
ZIndex = 4,

},
FX

)

Corner(
Ring,
CONFIG.Corner

- Padding / 2
  )

local RingStroke =
Stroke(
Ring,
C.White,
Transparency,
Thickness
)

return RingStroke,
ThemeGradient(RingStroke)

end

local GlowStroke,
GlowGrad =
NebulaRing(
16,
6,
0.8
)

local _,
SharpGrad =
NebulaRing(
9,
1.5,
0.25
)

local OuterStarColors = {
C.White,
C.Silver,
C.Mid,
C.White
}

for _ = 1, 14 do
local Angle =
math.random()

- math.pi
- 2

local Gap =
math.random(
14,
30
)

AddStar(
FX,

math.cos(Angle)
* (W / 2 + Gap),

math.sin(Angle)
* (H / 2 + Gap),

math.random(2, 3),

OuterStarColors[
math.random(
#OuterStarColors
)
],

6

)

end

local Orbiters = {
{
Gap = 14,
Size = 7,
Speed = 1.1,
Phase = 0,
Color = C.Light
},

{
Gap = 22,
Size = 5,
Speed = -0.75,
Phase = 2.1,
Color = C.Silver
},

{
Gap = 30,
Size = 4,
Speed = 0.5,
Phase = 4.2,
Color = C.Mid
},

}

local Tilt = math.rad(-20)

for _, Orbiter in ipairs(Orbiters) do
Orbiter.RX =
W / 2

- Orbiter.Gap

Orbiter.RY =
(H / 2

- Orbiter.Gap)

- 0.85

Orbiter.Dots = {}

for K = 1, 4 do
local Size =
Orbiter.Size

- (
  1

- (K - 1)

- 0.2
  )

local Dot = New(
"Frame",
{
AnchorPoint =
Vector2.new(
0.5,
0.5
),

Size =          
        UDim2.fromOffset(          
            Size,          
            Size          
        ),          

    BackgroundColor3 =          
        Orbiter.Color,          

    BackgroundTransparency =          
        (K - 1)          
        * 0.22,          

    BorderSizePixel = 0,          

    ZIndex = 7,          
},          
FX

)

Corner(Dot, 10)

if K == 1 then
Stroke(
Dot,
Orbiter.Color,
0.55,
2
)
end

Orbiter.Dots[K] = Dot

end

end

local TEXT_X = 60

local TitleLabel = New(
"TextLabel",
{
Name = "Title",

Position =
UDim2.new(
0,
TEXT_X,
0.5,
-17
),

Size =
UDim2.new(
1,
-(TEXT_X + 12),
0,
16
),

BackgroundTransparency = 1,

Text =
Config.Title
or Name,

TextColor3 =
C.TitleOff,

TextSize = 13,

Font =
Enum.Font.GothamBold,

TextXAlignment =
Enum.TextXAlignment.Left,

TextTruncate =
Enum.TextTruncate.AtEnd,

ZIndex = 8,

},
Inner

)

local StatusDot = New(
"Frame",
{
AnchorPoint =
Vector2.new(
0.5,
0.5
),

Position =
UDim2.new(
0,
TEXT_X + 4,
0.5,
9
),

Size =
UDim2.fromOffset(
7,
7
),

BackgroundColor3 =
C.Dark,

BorderSizePixel = 0,

ZIndex = 8,

},
Inner

)

Corner(StatusDot, 7)

local DotGlow =
Stroke(
StatusDot,
C.On,
1,
2
)

local StatusLabel = New(
"TextLabel",
{
Name = "Status",

Position =
UDim2.new(
0,
TEXT_X + 13,
0.5,
1
),

Size =
UDim2.new(
1,
-(TEXT_X + 25),
0,
16
),

BackgroundTransparency = 1,

Text =
Mode == "Button"
and "กดเพื่อใช้"
or "ปิด",

TextColor3 =
C.Off,

TextSize = 12,

Font =
Enum.Font.GothamMedium,

TextXAlignment =
Enum.TextXAlignment.Left,

ZIndex = 8,

},
Inner

)

local function SetState(On)
StatusLabel.Text =
On
and (Config.OnText or "เปิด")
or (Config.OffText or "ปิด")

StatusLabel.TextTransparency = 1

Tween(
StatusLabel,
0.2,
{
TextTransparency = 0,
TextColor3 =
On
and C.On
or C.Off
}
)

Tween(
StatusDot,
0.25,
{
BackgroundColor3 =
On
and C.On
or C.Dark
}
)

for _, PartObject in ipairs(
FaceParts
) do
Tween(
PartObject,
0.3,
{
BackgroundColor3 =
On
and FaceOn
or FaceOff
}
)
end

Tween(
DotGlow,
0.25,
{
Transparency =
On
and 0.45
or 1
}
)

Tween(
TitleLabel,
0.25,
{
TextColor3 =
On
and C.TitleOn
or C.TitleOff
}
)

end

SetState(false)

local Clock = 0

local AnimationConnection =
RunService.Heartbeat:Connect(
function(Dt)
if not Alive() then
return
end

Clock += Dt

if Pos ~= Target then
Pos =
Pos:Lerp(
Target,
1
- math.exp(
-Dt
* CONFIG.DragSmoothing
)
)

if (          
        Target - Pos          
    ).Magnitude < 0.25 then          
        Pos = Target          
    end          

    Holder.Position =          
        UDim2.fromOffset(          
            math.round(          
                Pos.X          
            ),          
            math.round(          
                Pos.Y          
            )          
        )          
end          

EdgeGrad.Rotation =          
    (Clock * 60)          
    % 360          

GlowGrad.Rotation =          
    (Clock * 50)          
    % 360          

SharpGrad.Rotation =          
    (-Clock * 72)          
    % 360          

GlowStroke.Transparency =          
    0.72          
    + 0.16          
    * math.sin(          
        Clock * 2          
    )          

for _, Star in ipairs(          
    Stars          
) do          
    Star.Frame.BackgroundTransparency =          
        0.5          
        + 0.45          
        * math.sin(          
            Clock          
                * Star.Rate          
                + Star.Phase          
        )          
end          

Planet.Position =          
    UDim2.new(          
        0,          
        PLANET_X,          
        0.5,          
        math.sin(          
            Clock * 1.6          
        ) * 1.5          
    )          

PlanetRing.Rotation =          
    -22          
    + math.sin(          
        Clock * 1.2          
    ) * 5          

for _, Orbiter in ipairs(          
    Orbiters          
) do          
    local Direction =          
        Orbiter.Speed > 0          
        and 1          
        or -1          

    for K, Dot in ipairs(          
        Orbiter.Dots          
    ) do          
        local Angle =          
            Orbiter.Phase          
            + Clock          
                * Orbiter.Speed          
            - (K - 1)          
                * 0.16          
                * Direction          

        local X =          
            math.cos(Angle)          
            * Orbiter.RX          

        local Y =          
            math.sin(Angle)          
            * Orbiter.RY          

        Dot.Position =          
            UDim2.new(          
                0.5,          
                X          
                    * math.cos(          
                        Tilt          
                    )          
                    - Y          
                    * math.sin(          
                        Tilt          
                    ),          

                0.5,          
                X          
                    * math.sin(          
                        Tilt          
                    )          
                    + Y          
                    * math.cos(          
                        Tilt          
                    )          
            )          

        local Size =          
            Orbiter.Size          
            * (          
                1          
                - (K - 1)          
                    * 0.2          
            )          
            * (          
                1          
                + 0.25          
                    * math.sin(          
                        Angle          
                    )          
            )          

        Dot.Size =          
            UDim2.fromOffset(          
                Size,          
                Size          
            )          
    end          
end

end

)

Track(AnimationConnection)

task.spawn(function()
while Alive() do
task.wait(
math.random(3, 6)
)

if not Alive() then
break
end

local YOffset =
math.random(-6, 6)

if IS_HALLOWEEN then
local Bat = New(
"TextLabel",
{
AnchorPoint =
Vector2.new(
0.5,
0.5
),

Size =          
            UDim2.fromOffset(          
                20,          
                20          
            ),          

        Position =          
            UDim2.new(          
                0.5,          
                W / 2 + 40,          
                0.5,          
                -(H / 2 + 22)          
                    + YOffset          
            ),          

        BackgroundTransparency = 1,          

        Text = "🦇",          

        TextSize = 16,          

        TextColor3 =          
            C.White,          

        ZIndex = 8,          
    },          
    FX          
)          

Tween(          
    Bat,          
    1.3,          
    {          
        Position =          
            UDim2.new(          
                0.5,          
                -(W / 2 + 40),          
                0.5,          
                -(H / 2 + 6)          
                    + YOffset          
            ),          

        TextTransparency = 1,          
    },          
    Enum.EasingStyle.Sine,          
    Enum.EasingDirection.In          
)          

task.delay(          
    1.35,          
    function()          
        if Bat then          
            Bat:Destroy()          
        end          
    end          
)

else
local Streak = New(
"Frame",
{
AnchorPoint =
Vector2.new(
0.5,
0.5
),

Size =          
            UDim2.fromOffset(          
                28,          
                2          
            ),          

        Position =          
            UDim2.new(          
                0.5,          
                W / 2 + 40,          
                0.5,          
                -(H / 2 + 30)          
                    + YOffset          
            ),          

        Rotation = -9,          

        BackgroundColor3 =          
            C.White,          

        BorderSizePixel = 0,          

        ZIndex = 8,          
    },          
    FX          
)          

New(          
    "UIGradient",          
    {          
        Transparency =          
            NumberSequence.new({          
                NumberSequenceKeypoint.new(          
                    0,          
                    0          
                ),          

                NumberSequenceKeypoint.new(          
                    1,          
                    1          
                ),          
            }),          
    },          
    Streak          
)          

Tween(          
    Streak,          
    0.8,          
    {          
        Position =          
            UDim2.new(          
                0.5,          
                -(W / 2 + 40),          
                0.5,          
                -(H / 2 + 8)          
                    + YOffset          
            ),          

        BackgroundTransparency = 1,          
    },          
    Enum.EasingStyle.Quad,          
    Enum.EasingDirection.In          
)          

task.delay(          
    0.85,          
    function()          
        if Streak then          
            Streak:Destroy()          
        end          
    end          
)

end

end

end)

local Hovering = false
local Dragging = false
local Moved = false

Track(
Button.MouseEnter:Connect(
function()
Hovering = true

if not Dragging then
Tween(
Scale,
0.18,
{
Scale = 1.08
}
)

Tween(
EdgeStroke,
0.18,
{
Thickness = 2.5
}
)
end
end

)

)

Track(
Button.MouseLeave:Connect(
function()
Hovering = false

if not Dragging then
Tween(
Scale,
0.18,
{
Scale = 1
}
)

Tween(
EdgeStroke,
0.18,
{
Thickness = 2
}
)
end
end

)

)

local DragInput
local DragOrigin
local DragStartPos

Track(
Button.InputBegan:Connect(
function(Input)
if Dragging then
return
end

if Input.UserInputType
== Enum.UserInputType.MouseButton1
or Input.UserInputType
== Enum.UserInputType.Touch then

Dragging = true
Moved = false
DragInput = Input
DragOrigin =
Input.Position
DragStartPos = Target
end
end

)

)

Track(
UserInputService.InputChanged:Connect(
function(Input)
if not Dragging then
return
end

if not DragInput then
return
end

local IsMouse =
DragInput.UserInputType
== Enum.UserInputType.MouseButton1
and Input.UserInputType
== Enum.UserInputType.MouseMovement

local IsTouch =          
    DragInput.UserInputType          
        == Enum.UserInputType.Touch          
    and Input == DragInput          

if not (          
    IsMouse          
    or IsTouch          
) then          
    return          
end          

local Delta =          
    Vector2.new(          
        Input.Position.X          
            - DragOrigin.X,          

        Input.Position.Y          
            - DragOrigin.Y          
    )          

if not Moved then          
    if Delta.Magnitude          
        < CONFIG.DragThreshold then          
        return          
    end          

    Moved = true          

    DragOrigin =          
        Input.Position          

    DragStartPos =          
        Target          

    Tween(          
        Scale,          
        0.15,          
        {          
            Scale = 0.94          
        }          
    )          

    return          
end          

Target =          
    ClampPos(          
        DragStartPos          
            + Delta          
    )

end

)

)

Track(
UserInputService.InputEnded:Connect(
function(Input)
if not Dragging then
return
end

local SameTouch =
Input == DragInput

local SameMouse =
DragInput
and DragInput.UserInputType
== Enum.UserInputType.MouseButton1
and Input.UserInputType
== Enum.UserInputType.MouseButton1

if not (          
    SameTouch          
    or SameMouse          
) then          
    return          
end          

Dragging = false          

if Moved then          
    Tween(          
        Scale,          
        0.22,          
        {          
            Scale =          
                Hovering          
                and 1.08          
                or 1          
        },          
        Enum.EasingStyle.Back          
    )          
end          

DragInput = nil

end

)

)

Track(
Camera:GetPropertyChangedSignal(
"ViewportSize"
):Connect(
function()
Target =
ClampPos(Target)
end
)
)

local Active = false
local Busy = false

local function Ripple()
local RippleFrame = New(
"Frame",
{
AnchorPoint =
Vector2.new(
0.5,
0.5
),

Position =
UDim2.fromScale(
0.5,
0.5
),

Size =
UDim2.fromOffset(
W,
H
),

BackgroundTransparency = 1,          

ZIndex = 9,

},
FX

)

Corner(
RippleFrame,
CONFIG.Corner + 4
)

local RippleStroke =
Stroke(
RippleFrame,
C.Light,
0.1,
2
)

Tween(
RippleFrame,
0.55,
{
Size =
UDim2.fromOffset(
W + 60,
H + 60
)
}
)

Tween(
RippleStroke,
0.55,
{
Transparency = 1
}
)

task.delay(
0.6,
function()
if RippleFrame then
RippleFrame:Destroy()
end
end
)

end

local function ButtonCountdown()
if Busy then
return
end

Busy = true

for Number = 3, 1, -1 do
if not Alive() then
break
end

StatusLabel.Text =
tostring(Number)

StatusLabel.TextTransparency =
1

Tween(
StatusLabel,
0.12,
{
TextTransparency = 0,
TextColor3 = C.On
},
Enum.EasingStyle.Back
)

Tween(
Scale,
0.12,
{
Scale = 1.12
},
Enum.EasingStyle.Back
)

task.wait(0.12)

Tween(
Scale,
0.18,
{
Scale = 1
}
)

task.wait(
Config.CountdownStep
or 0.35
)

end

if Alive() then
StatusLabel.Text =
"พร้อม"

StatusLabel.TextColor3 =
C.On

Tween(
StatusLabel,
0.2,
{
TextColor3 = C.Off
}
)

end

Busy = false

end

Track(
Button.Activated:Connect(
function()
if Moved then
return
end

Ripple()

Tween(
Scale,
0.08,
{
Scale = 0.86
}
)

task.delay(          
    0.09,          
    function()          
        if Alive() then          
            Tween(          
                Scale,          
                0.25,          
                {          
                    Scale =          
                        Hovering          
                        and 1.08          
                        or 1          
                },          
                Enum.EasingStyle.Back          
            )          
        end          
    end          
)          

if Mode == "Button" then          
    if Busy then          
        return          
    end          

    task.spawn(          
        function()          
            pcall(          
                Callback          
            )          

            ButtonCountdown()          
        end          
    )          

    return          
end          

Active = not Active          

SetState(Active)          

task.spawn(          
    function()          
        pcall(          
            Callback,          
            Active          
        )          
    end          
)

end

)

)

local Handle = {}

function Handle:Destroy()
if Dead then
return
end

Dead = true

for _, Connection in ipairs(
Connections
) do
pcall(function()
Connection:Disconnect()
end)
end

Connections = {}

pcall(function()
Holder:Destroy()
end)

end

Handle.Gui = Gui
Handle.Button = Button
Handle.Holder = Holder

FloatingButtons[Name] = Handle

return Handle

end

do
local LagBusy = false

local function RunClientDelay()
if LagBusy then
return
end

LagBusy = true

local Character =
LocalPlayer.Character

local Humanoid =
Character
and Character:FindFirstChildOfClass(
"Humanoid"
)

local OldWalkSpeed
local OldJumpPower
local OldAutoRotate

if Humanoid then
OldWalkSpeed =
Humanoid.WalkSpeed

OldJumpPower =
Humanoid.JumpPower

OldAutoRotate =
Humanoid.AutoRotate

Humanoid.WalkSpeed = 0
Humanoid.JumpPower = 0
Humanoid.AutoRotate = false

end

task.wait(0.5)

if Humanoid
and Humanoid.Parent then

Humanoid.WalkSpeed =
OldWalkSpeed

Humanoid.JumpPower =
OldJumpPower

Humanoid.AutoRotate =
OldAutoRotate

end

LagBusy = false

end

local function RunLagSwitch()
if LagBusy then
return
end

task.spawn(
RunClientDelay
)

end


MainTab:AddToggle({
Name = "ออโต้กระโดด",

Default = false,

Callback = function(Value)
SetAutoJump(Value)
end

})

local AutoJumpFloatingHandle

MainTab:AddToggle({
Name = "ออโต้กระโดด (ปุ่มลอย)",

Default = false,

Callback = function(Value)
if Value then

if AutoJumpFloatingHandle then
AutoJumpFloatingHandle:Destroy()
AutoJumpFloatingHandle = nil
end

AutoJumpFloatingHandle =
CreateFloatingButton({
Name = "ออโต้กระโดด",

Mode = "Toggle",          

    OnText = "เปิด",          
    OffText = "ปิด",          

    Callback = function(Active)          
        SetAutoJump(Active)          
    end          
})

else

if AutoJumpFloatingHandle then
AutoJumpFloatingHandle:Destroy()
AutoJumpFloatingHandle = nil
end

RemoveFloatingButton(
"ออโต้กระโดด"
)

SetAutoJump(false)

end

end

})
end

do
local LagBusy = false

local function RunLagSwitch()
if LagBusy then
return
end

LagBusy = true

local Duration = 0.5
local Start = os.clock()

while os.clock() - Start < Duration do
local Temp = {}

for i = 1, 5000 do
Temp[i] = i * i
end

end

LagBusy = false

end


MainTab:AddButton({
Name = "แลคสวิตช์",

Callback = function()
RunLagSwitch()
end

})

local LagFloatingHandle = nil

MainTab:AddToggle({
Name = "แลคสวิตช์ (ปุ่มลอย)",

Default = false,

Callback = function(Value)
if Value then
if LagFloatingHandle then
LagFloatingHandle:Destroy()
LagFloatingHandle = nil
end

LagFloatingHandle =
CreateFloatingButton({
Name = "แลคสวิตช์",

Mode = "Button",

CountdownStep = 0.35,          

    Callback = function()          
        RunLagSwitch()          
    end          
})

Window:Notify({
Title = "HelloHub",
Content = "เปิดปุ่มลอยแลคสวิตช์แล้ว",
Duration = 3
})

else
if LagFloatingHandle then
LagFloatingHandle:Destroy()
LagFloatingHandle = nil
end

RemoveFloatingButton(
"แลคสวิตช์"
)

Window:Notify({
Title = "HelloHub",
Content = "ปิดปุ่มลอยแลคสวิตช์แล้ว",
Duration = 3
})

end

end

})

-- ใช้ AddText ของ HelloHub v6.2.0 สำหรับข้อความช่วยเหลือ
pcall(function()
    MainTab:AddText("กดแล้ว Client จะกระตุกชั่วคราว", { Column = "Left", Height = 20 })

    MainTab:AddText("หลังจากนั้นปุ่มจะนับ 3 → 2 → 1", { Column = "Left", Height = 20 })
end)

Window:Notify({
Title = "HelloHub",
Content = "ระบบแลคสวิตช์พร้อมใช้งาน",
Duration = 3
})
end

-- HelloHub V2 | DYNAMIC SILVER BORDER
-- Default: ON
-- Settings tab toggle
-- Excludes JumpButton

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local CONFIG = {
BorderThickness = 2.2,
BorderTransparency = 0.05,
AnimationDuration = 3.2,
RescanInterval = 2,
}

local GUI_TAG = "KRYVEX_SilverBorder"
local Enabled = true -- เปิดทันทีเมื่อรัน

local Decorated = setmetatable({}, {
__mode = "k"
})

local SilverSequence = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(35, 36, 40)),
ColorSequenceKeypoint.new(0.18, Color3.fromRGB(90, 94, 103)),
ColorSequenceKeypoint.new(0.36, Color3.fromRGB(190, 196, 205)),
ColorSequenceKeypoint.new(0.48, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(0.63, Color3.fromRGB(150, 155, 165)),
ColorSequenceKeypoint.new(0.82, Color3.fromRGB(20, 21, 25)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(35, 36, 40)),
})

local function IsExcluded(Button)
return Button.Name == "JumpButton"
end

local function RemoveBorder(Button)
local Data = Decorated[Button]

if Data then
if Data.Animation then
Data.Animation:Cancel()
end

if Data.Stroke and Data.Stroke.Parent then
Data.Stroke:Destroy()
end

Decorated[Button] = nil

else
local Existing = Button:FindFirstChild(GUI_TAG)
if Existing then
Existing:Destroy()
end
end

end

local function AddBorder(Button)
if not Enabled then return end
if not Button:IsA("GuiButton") then return end
if IsExcluded(Button) then return end
if Decorated[Button] then return end

local Existing = Button:FindFirstChild(GUI_TAG)
if Existing then
-- Don't claim ownership of an unrelated existing border.
return
end

local Stroke = Instance.new("UIStroke")
Stroke.Name = GUI_TAG
Stroke.Thickness = CONFIG.BorderThickness
Stroke.Transparency = CONFIG.BorderTransparency
Stroke.Color = Color3.fromRGB(190, 195, 205)
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.LineJoinMode = Enum.LineJoinMode.Round
Stroke.Parent = Button

local Gradient = Instance.new("UIGradient")
Gradient.Name = "SilverFlow"
Gradient.Color = SilverSequence
Gradient.Rotation = 0
Gradient.Parent = Stroke

local Animation = TweenService:Create(
Gradient,
TweenInfo.new(
CONFIG.AnimationDuration,
Enum.EasingStyle.Linear,
Enum.EasingDirection.InOut,
-1,
false
),
{ Rotation = 360 }
)

Decorated[Button] = {
Stroke = Stroke,
Gradient = Gradient,
Animation = Animation,
}

Animation:Play()

end

local function ScanButtons()
if not Enabled then return end

for _, Object in ipairs(PlayerGui:GetDescendants()) do
if Object:IsA("GuiButton") then
pcall(AddBorder, Object)
end
end

end

local function SetEnabled(Value)
Enabled = Value

if Enabled then
ScanButtons()
print("[HelloHub] Silver Border: ON")
else
for Button in pairs(Decorated) do
if Button and Button.Parent then
RemoveBorder(Button)
else
Decorated[Button] = nil
end
end

print("[HelloHub] Silver Border: OFF")

end

end

-- Connect to the existing KOMAT settings tab.
-- If this code is standalone, create Window and SettingsTab first.
SettingsTab:AddToggle({
Name = "ขอบปุ่มสีเงิน | Silver Border",
Default = true,

Callback = function(Value)
SetEnabled(Value)
end

})

-- Scan current buttons immediately.
ScanButtons()

-- Decorate buttons created later.
PlayerGui.DescendantAdded:Connect(function(Object)
if Object:IsA("GuiButton") then
task.defer(function()
if Object.Parent then
pcall(AddBorder, Object)
end
end)
end
end)

-- Rescan for buttons that load late.
task.spawn(function()
while true do
task.wait(CONFIG.RescanInterval)

if Enabled then
ScanButtons()
end
end

end)

print("[HelloHub] Silver Border enabled by default!")

-- =========================================================
-- HelloHub | DASH ไปหน้า
-- หมวด: เมนูหลัก (MainTab)
-- =========================================================

do
local DashEnabled = false
local DashSpeed = 50
local DashVelocity = nil
local DashFloatingHandle = nil

-- ปิดแดชและลบแรงเคลื่อนที่
local function StopDash()
DashEnabled = false

if DashVelocity then
DashVelocity:Destroy()
DashVelocity = nil
end

end

-- เริ่มแดชตามทิศทางกล้อง
local function StartDash()
if DashVelocity then
return
end

local Character = LocalPlayer.Character
if not Character then
return
end

local Root = Character:FindFirstChild("HumanoidRootPart")
if not Root then
return
end

DashEnabled = true

local Velocity = Instance.new("BodyVelocity")
Velocity.Name = "KRYVEX_DashVelocity"
Velocity.MaxForce = Vector3.new(999999, 0, 999999)
Velocity.P = 1250
Velocity.Velocity = Vector3.zero
Velocity.Parent = Root

DashVelocity = Velocity

task.spawn(function()
while DashEnabled and DashVelocity == Velocity do
local CharacterNow = LocalPlayer.Character
local RootNow = CharacterNow
and CharacterNow:FindFirstChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

if not RootNow or RootNow ~= Root or not Camera then      
        break      
    end      

    local Look = Camera.CFrame.LookVector      
    local Direction = Vector3.new(Look.X, 0, Look.Z)      

    if Direction.Magnitude > 0.001 then      
        Velocity.Velocity = Direction.Unit * DashSpeed      
    else      
        Velocity.Velocity = Vector3.zero      
    end      

    task.wait(0.03)      
end      

if DashVelocity == Velocity then      
    DashVelocity = nil      
end      

if Velocity.Parent then      
    Velocity:Destroy()      
end

end)

end

-- เปิด / ปิดแดช
local function SetDash(Value)
if Value then
StartDash()

Window:Notify({
Title = "HelloHub",
Content = "เปิดแดชไปหน้า | ความเร็ว " .. tostring(DashSpeed),
Duration = 3
})
else
StopDash()

Window:Notify({      
    Title = "HelloHub",      
    Content = "ปิดแดชไปหน้าแล้ว",      
    Duration = 3      
})

end

end

-- ปิดแดชเมื่อเกิดใหม่
LocalPlayer.CharacterAdded:Connect(function()
StopDash()
end)

-- =====================================================
-- เมนูหลัก
-- =====================================================


DashTab:AddToggle({
Name = "แดชไปหน้า",
Default = false,

Callback = function(Value)
SetDash(Value)
end

})

DashTab:AddInput({
Name = "ความเร็วแดช",
Placeholder = "เช่น 50",
Default = tostring(DashSpeed),

Callback = function(Value)
local Number = tonumber(Value)

if Number then      
    DashSpeed = math.clamp(Number, 1, 1000)      
end

end

})

-- =====================================================
-- สร้าง / ลบปุ่มลอย
-- =====================================================

DashTab:AddToggle({
Name = "แดชไปหน้า (ปุ่มลอย)",
Default = false,

Callback = function(Value)
if Value then
if DashFloatingHandle then
DashFloatingHandle:Destroy()
DashFloatingHandle = nil
end

DashFloatingHandle = CreateFloatingButton({      
        Name = "แดชไปหน้า",      
        Mode = "Toggle",      
        OnText = "เปิด",      
        OffText = "ปิด",      

        Callback = function(Active)      
            SetDash(Active)      
        end      
    })      
else      
    StopDash()      

    if DashFloatingHandle then      
        DashFloatingHandle:Destroy()      
        DashFloatingHandle = nil      
    end      

    RemoveFloatingButton("แดชไปหน้า")      
end

end

})

end

-- =========================================================
-- HelloHub | DASH JUMP
-- พุ่ง + กระโดด + เด้งเมื่อใกล้ถึงพื้น
-- หมวด: เมนูหลัก (MainTab)
-- =========================================================

do
local DashJumpEnabled = false
local DashJumpSpeed = 50
local DashJumpVelocity = nil
local DashJumpFloatingHandle = nil
local DashJumpGeneration = 0

local function StopDashJump()
DashJumpEnabled = false
DashJumpGeneration += 1

if DashJumpVelocity then
DashJumpVelocity:Destroy()
DashJumpVelocity = nil
end

end

local function StartDashJump()
if DashJumpEnabled then
return
end

local Character = LocalPlayer.Character
if not Character then
return
end

local Humanoid = Character:FindFirstChildOfClass("Humanoid")
local Root = Character:FindFirstChild("HumanoidRootPart")

if not Humanoid or not Root or Humanoid.Health <= 0 then
return
end

DashJumpEnabled = true
DashJumpGeneration += 1

local MyGeneration = DashJumpGeneration

local Velocity = Instance.new("BodyVelocity")
Velocity.Name = "KRYVEX_DashJumpVelocity"
Velocity.MaxForce = Vector3.new(999999, 0, 999999)
Velocity.P = 1250
Velocity.Velocity = Vector3.zero
Velocity.Parent = Root

DashJumpVelocity = Velocity

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude
RayParams.FilterDescendantsInstances = {Character}
RayParams.IgnoreWater = true

local LastJumpTime = os.clock()

-- กระโดดทันทีเมื่อเปิดระบบ
Humanoid.Jump = true
Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

task.spawn(function()
while DashJumpEnabled
and DashJumpGeneration == MyGeneration
and DashJumpVelocity == Velocity do

local CurrentCharacter = LocalPlayer.Character      
    local CurrentHumanoid = CurrentCharacter      
        and CurrentCharacter:FindFirstChildOfClass("Humanoid")      
    local CurrentRoot = CurrentCharacter      
        and CurrentCharacter:FindFirstChild("HumanoidRootPart")      
    local Camera = workspace.CurrentCamera      

    if not CurrentHumanoid      
        or not CurrentRoot      
        or CurrentRoot ~= Root      
        or not Camera      
        or CurrentHumanoid.Health <= 0 then      
        break      
    end      

    -- พุ่งตามทิศกล้องในแนวราบ      
    local Look = Camera.CFrame.LookVector      
    local Direction = Vector3.new(Look.X, 0, Look.Z)      

    if Direction.Magnitude > 0.001 then      
        Velocity.Velocity = Direction.Unit * DashJumpSpeed      
    else      
        Velocity.Velocity = Vector3.zero      
    end      

    -- ตรวจพื้นด้านล่าง      
    local Result = workspace:Raycast(      
        CurrentRoot.Position,      
        Vector3.new(0, -4.5, 0),      
        RayParams      
    )      

    local VerticalSpeed =      
        CurrentRoot.AssemblyLinearVelocity.Y      

    -- เด้งซ้ำเมื่อกำลังตกและใกล้ถึงพื้น      
    if Result      
        and VerticalSpeed < -2      
        and os.clock() - LastJumpTime >= 0.45 then      

        LastJumpTime = os.clock()      

        CurrentHumanoid.Jump = true      
        CurrentHumanoid:ChangeState(      
            Enum.HumanoidStateType.Jumping      
        )      
    end      

    task.wait(0.025)      
end      

if DashJumpVelocity == Velocity then      
    DashJumpVelocity = nil      
end      

if Velocity.Parent then      
    Velocity:Destroy()      
end

end)

end

local function SetDashJump(Value)
if Value then
StartDashJump()

Window:Notify({
Title = "HelloHub",
Content = "เปิดแดชกระโดด | ความเร็ว "
.. tostring(DashJumpSpeed),
Duration = 3
})
else
StopDashJump()

Window:Notify({      
    Title = "HelloHub",      
    Content = "ปิดแดชกระโดดแล้ว",      
    Duration = 3      
})

end

end

-- ปิดระบบเมื่อเกิดใหม่
LocalPlayer.CharacterAdded:Connect(function()
StopDashJump()
end)

-- =====================================================
-- เมนูหลัก
-- =====================================================


DashTab:AddToggle({
Name = "แดชไปหน้าพร้อมกระโดด",
Default = false,

Callback = function(Value)
SetDashJump(Value)
end

})

DashTab:AddInput({
Name = "ความเร็วแดชกระโดด",
Placeholder = "เช่น 50",
Default = tostring(DashJumpSpeed),

Callback = function(Value)
local Number = tonumber(Value)

if Number then      
    DashJumpSpeed = math.clamp(Number, 1, 1000)      
end

end

})

-- =====================================================
-- ปุ่มลอย
-- =====================================================

DashTab:AddToggle({
Name = "แดชกระโดด (ปุ่มลอย)",
Default = false,

Callback = function(Value)
if Value then
if DashJumpFloatingHandle then
DashJumpFloatingHandle:Destroy()
DashJumpFloatingHandle = nil
end

DashJumpFloatingHandle = CreateFloatingButton({      
        Name = "แดชกระโดด",      
        Mode = "Toggle",      
        OnText = "เปิด",      
        OffText = "ปิด",      

        Callback = function(Active)      
            SetDashJump(Active)      
        end      
    })      
else      
    StopDashJump()      

    if DashJumpFloatingHandle then      
        DashJumpFloatingHandle:Destroy()      
        DashJumpFloatingHandle = nil      
    end      

    RemoveFloatingButton("แดชกระโดด")      
end

end

})

end

-- =========================================================
-- HelloHub | REVERSE DASH
-- แดชถอยหลัง + ปุ่มลอย
-- =========================================================

do
local BackDashEnabled = false
local BackDashSpeed = 50
local BackDashVelocity = nil
local BackDashFloatingHandle = nil
local BackDashToken = 0

local function StopBackDash()
BackDashEnabled = false
BackDashToken += 1

if BackDashVelocity then    
    BackDashVelocity:Destroy()    
    BackDashVelocity = nil    
end

end

local function StartBackDash()
if BackDashEnabled then return end

local Character = LocalPlayer.Character    
local Humanoid = Character    
    and Character:FindFirstChildOfClass("Humanoid")    
local Root = Character    
    and Character:FindFirstChild("HumanoidRootPart")    

if not Humanoid or not Root or Humanoid.Health <= 0 then    
    return    
end    

BackDashEnabled = true    
BackDashToken += 1    
local MyToken = BackDashToken    

local Velocity = Instance.new("BodyVelocity")    
Velocity.Name = "KRYVEX_BackDashVelocity"    
Velocity.MaxForce = Vector3.new(999999, 0, 999999)    
Velocity.P = 1250    
Velocity.Velocity = Vector3.zero    
Velocity.Parent = Root    

BackDashVelocity = Velocity    

task.spawn(function()    
    while BackDashEnabled    
        and BackDashToken == MyToken    
        and BackDashVelocity == Velocity do    

        local CurrentCharacter = LocalPlayer.Character    
        local CurrentHumanoid = CurrentCharacter    
            and CurrentCharacter:FindFirstChildOfClass("Humanoid")    
        local CurrentRoot = CurrentCharacter    
            and CurrentCharacter:FindFirstChild("HumanoidRootPart")    
        local Camera = workspace.CurrentCamera    

        if not CurrentHumanoid or not CurrentRoot    
            or CurrentRoot ~= Root or not Camera    
            or CurrentHumanoid.Health <= 0 then    
            break    
        end    

        local Look = Camera.CFrame.LookVector    
        local Direction = Vector3.new(-Look.X, 0, -Look.Z)    

        if Direction.Magnitude > 0.001 then    
            Velocity.Velocity = Direction.Unit * BackDashSpeed    
        else    
            Velocity.Velocity = Vector3.zero    
        end    

        task.wait(0.03)    
    end    

    if BackDashVelocity == Velocity then    
        BackDashVelocity = nil    
    end    

    if Velocity.Parent then    
        Velocity:Destroy()    
    end    
end)

end

local function SetBackDash(Value)
if Value then
StartBackDash()
else
StopBackDash()
end
end

LocalPlayer.CharacterAdded:Connect(StopBackDash)


DashTab:AddToggle({
Name = "แดชถอยหลัง",
Default = false,
Callback = SetBackDash
})

DashTab:AddInput({
Name = "ความเร็วแดชถอยหลัง",
Placeholder = "เช่น 50",
Default = tostring(BackDashSpeed),
Callback = function(Value)
local Number = tonumber(Value)
if Number then
BackDashSpeed = math.clamp(Number, 1, 1000)
end
end
})

DashTab:AddToggle({
Name = "แดชถอยหลัง (ปุ่มลอย)",
Default = false,
Callback = function(Value)
if Value then
if BackDashFloatingHandle then
BackDashFloatingHandle:Destroy()
end

BackDashFloatingHandle = CreateFloatingButton({    
            Name = "แดชถอยหลัง",    
            Mode = "Toggle",    
            OnText = "เปิด",    
            OffText = "ปิด",    
            Callback = SetBackDash    
        })    
    else    
        SetBackDash(false)    

        if BackDashFloatingHandle then    
            BackDashFloatingHandle:Destroy()    
            BackDashFloatingHandle = nil    
        end    

        RemoveFloatingButton("แดชถอยหลัง")    
    end    
end

})

end

-- =========================================================
-- HelloHub | REVERSE DASH JUMP
-- แดชถอยหลัง + กระโดดซ้ำใกล้พื้น
-- =========================================================

do
local BackDashJumpEnabled = false
local BackDashJumpSpeed = 50
local BackDashJumpVelocity = nil
local BackDashJumpFloatingHandle = nil
local BackDashJumpToken = 0

local function StopBackDashJump()
BackDashJumpEnabled = false
BackDashJumpToken += 1

if BackDashJumpVelocity then    
    BackDashJumpVelocity:Destroy()    
    BackDashJumpVelocity = nil    
end

end

local function StartBackDashJump()
if BackDashJumpEnabled then return end

local Character = LocalPlayer.Character    
local Humanoid = Character    
    and Character:FindFirstChildOfClass("Humanoid")    
local Root = Character    
    and Character:FindFirstChild("HumanoidRootPart")    

if not Humanoid or not Root or Humanoid.Health <= 0 then    
    return    
end    

BackDashJumpEnabled = true    
BackDashJumpToken += 1    
local MyToken = BackDashJumpToken    

local Velocity = Instance.new("BodyVelocity")    
Velocity.Name = "KRYVEX_BackDashJumpVelocity"    
Velocity.MaxForce = Vector3.new(999999, 0, 999999)    
Velocity.P = 1250    
Velocity.Velocity = Vector3.zero    
Velocity.Parent = Root    

BackDashJumpVelocity = Velocity    

local RayParams = RaycastParams.new()    
RayParams.FilterType = Enum.RaycastFilterType.Exclude    
RayParams.FilterDescendantsInstances = {Character}    
RayParams.IgnoreWater = true    

local LastJumpTime = 0    

-- กระโดดทันทีเมื่อเปิดระบบ    
Humanoid.Jump = true    
Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)    
LastJumpTime = os.clock()    

task.spawn(function()    
    while BackDashJumpEnabled    
        and BackDashJumpToken == MyToken    
        and BackDashJumpVelocity == Velocity do    

        local CurrentCharacter = LocalPlayer.Character    
        local CurrentHumanoid = CurrentCharacter    
            and CurrentCharacter:FindFirstChildOfClass("Humanoid")    
        local CurrentRoot = CurrentCharacter    
            and CurrentCharacter:FindFirstChild("HumanoidRootPart")    
        local Camera = workspace.CurrentCamera    

        if not CurrentHumanoid or not CurrentRoot    
            or CurrentRoot ~= Root or not Camera    
            or CurrentHumanoid.Health <= 0 then    
            break    
        end    

        -- แดชถอยหลังตามทิศกล้อง    
        local Look = Camera.CFrame.LookVector    
        local Direction = Vector3.new(-Look.X, 0, -Look.Z)    

        if Direction.Magnitude > 0.001 then    
            Velocity.Velocity =    
                Direction.Unit * BackDashJumpSpeed    
        else    
            Velocity.Velocity = Vector3.zero    
        end    

        -- ตรวจพื้นใกล้ตัวละคร    
        local Result = workspace:Raycast(    
            CurrentRoot.Position,    
            Vector3.new(0, -4.5, 0),    
            RayParams    
        )    

        local VerticalSpeed =    
            CurrentRoot.AssemblyLinearVelocity.Y    

        -- เด้งอีกครั้งเมื่อกำลังตกและมีพื้นอยู่ใกล้    
        if Result    
            and VerticalSpeed < -2    
            and os.clock() - LastJumpTime >= 0.45 then    

            LastJumpTime = os.clock()    
            CurrentHumanoid.Jump = true    
            CurrentHumanoid:ChangeState(    
                Enum.HumanoidStateType.Jumping    
            )    
        end    

        task.wait(0.025)    
    end    

    if BackDashJumpVelocity == Velocity then    
        BackDashJumpVelocity = nil    
    end    

    if Velocity.Parent then    
        Velocity:Destroy()    
    end    
end)

end

local function SetBackDashJump(Value)
if Value then
StartBackDashJump()
else
StopBackDashJump()
end
end

LocalPlayer.CharacterAdded:Connect(StopBackDashJump)


DashTab:AddToggle({
Name = "แดชถอยหลังกระโดด",
Default = false,
Callback = SetBackDashJump
})

DashTab:AddInput({
Name = "ความเร็วแดชถอยหลังกระโดด",
Placeholder = "เช่น 50",
Default = tostring(BackDashJumpSpeed),
Callback = function(Value)
local Number = tonumber(Value)
if Number then
BackDashJumpSpeed = math.clamp(Number, 1, 1000)
end
end
})

DashTab:AddToggle({
Name = "แดชถอยหลังกระโดด (ปุ่มลอย)",
Default = false,
Callback = function(Value)
if Value then
if BackDashJumpFloatingHandle then
BackDashJumpFloatingHandle:Destroy()
end

BackDashJumpFloatingHandle = CreateFloatingButton({    
            Name = "แดชถอยหลังกระโดด",    
            Mode = "Toggle",    
            OnText = "เปิด",    
            OffText = "ปิด",    
            Callback = SetBackDashJump    
        })    
    else    
        SetBackDashJump(false)    

        if BackDashJumpFloatingHandle then    
            BackDashJumpFloatingHandle:Destroy()    
            BackDashJumpFloatingHandle = nil    
        end    

        RemoveFloatingButton("แดชถอยหลังกระโดด")    
    end    
end

})

end

local AutoBounce = false
local AutoBounceHeight = 150
local AutoBounceDistance = 7

local AutoBounceConnection = nil
local AutoBounceCooldown = false

local function GetCharacterData()
local Character = LocalPlayer.Character

if not Character then  
    return nil  
end  

local Humanoid =  
    Character:FindFirstChildOfClass(  
        "Humanoid"  
    )  

local Root =  
    Character:FindFirstChild(  
        "HumanoidRootPart"  
    )  

if not Humanoid or not Root then  
    return nil  
end  

return Character, Humanoid, Root

end

local function CheckGroundDistance(
Character,
Root
)
local Params =
RaycastParams.new()

Params.FilterType =  
    Enum.RaycastFilterType.Exclude  

Params.FilterDescendantsInstances = {  
    Character  
}  

Params.IgnoreWater = true  

local Result =  
    workspace:Raycast(  
        Root.Position,  
        Vector3.new(  
            0,  
            -AutoBounceDistance,  
            0  
        ),  
        Params  
    )  

if Result then  
    return (  
        Root.Position  
        - Result.Position  
    ).Magnitude  
end  

return nil

end

local function DoAutoBounce(
Humanoid,
Root
)
if AutoBounceCooldown then
return
end

AutoBounceCooldown = true  

local Velocity =  
    Root.AssemblyLinearVelocity  

Root.AssemblyLinearVelocity =  
    Vector3.new(  
        Velocity.X,  
        AutoBounceHeight,  
        Velocity.Z  
    )  

Humanoid:ChangeState(  
    Enum.HumanoidStateType.Jumping  
)  

task.delay(  
    0.15,  
    function()  
        AutoBounceCooldown = false  
    end  
)

end

local function StartAutoBounce()
if AutoBounceConnection then
AutoBounceConnection:Disconnect()
AutoBounceConnection = nil
end

AutoBounceConnection =  
    RunService.Heartbeat:Connect(  
        function()  
            if not AutoBounce then  
                return  
            end  

            local Character,  
                Humanoid,  
                Root =  
                GetCharacterData()  

            if not Character  
                or not Humanoid  
                or not Root then  
                return  
            end  

            if Humanoid.Health <= 0 then  
                return  
            end  

            local State =  
                Humanoid:GetState()  

            local Falling =  
                State  
                    == Enum.HumanoidStateType.Freefall  
                or State  
                    == Enum.HumanoidStateType.FallingDown  

            if not Falling then  
                return  
            end  

            local VerticalVelocity =  
                Root.AssemblyLinearVelocity.Y  

            if VerticalVelocity >= 0 then  
                return  
            end  

            local Distance =  
                CheckGroundDistance(  
                    Character,  
                    Root  
                )  

            if Distance  
                and Distance  
                    <= AutoBounceDistance then  

                DoAutoBounce(  
                    Humanoid,  
                    Root  
                )  
            end  
        end  
    )

end

local function SetAutoBounce(
Value
)
AutoBounce = Value

if Value then  
    StartAutoBounce()  
else  
    if AutoBounceConnection then  
        AutoBounceConnection:Disconnect()  
        AutoBounceConnection = nil  
    end  

    AutoBounceCooldown = false  
end

end

StartAutoBounce()


MainTab:AddToggle({
Name = "ออโต้เด้ง",

Default = false,  

Callback = function(Value)  
    SetAutoBounce(Value)  

    Window:Notify({  
        Title = "HelloHub",  

        Content =  
            Value  
            and (  
                "เปิดออโต้เด้ง | ความสูง "  
                .. tostring(  
                    AutoBounceHeight  
                )  
            )  
            or "ปิดออโต้เด้ง",  

        Duration = 3  
    })  
end

})

MainTab:AddInput({
Name = "ความสูงออโต้เด้ง",

Placeholder = "เช่น 150",  

Default =  
    tostring(  
        AutoBounceHeight  
    ),  

Callback = function(Value)  
    local Number =  
        tonumber(Value)  

    if Number then  
        AutoBounceHeight =  
            math.clamp(  
                Number,  
                1,  
                1000  
            )  
    end  
end

})

MainTab:AddInput({
Name = "ระยะตรวจพื้น",

Placeholder = "เช่น 7",  

Default =  
    tostring(  
        AutoBounceDistance  
    ),  

Callback = function(Value)  
    local Number =  
        tonumber(Value)  

    if Number then  
        AutoBounceDistance =  
            math.clamp(  
                Number,  
                1,  
                50  
            )  
    end  
end

})

task.spawn(function()
local ok, err = pcall(function()
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Env = getgenv()
local FloatingButton = nil
local NAME = "กดย่อรัวๆ"

local function FindCrouchButton()  
        local success, button = pcall(function()  
            return PlayerGui.Game.HUD.Mobile.Right.Mobile.CrouchButton  
        end)  

        if success and button then  
            return button  
        end  

        return PlayerGui:FindFirstChild("CrouchButton", true)  
    end  

    local function StopCrouch()  
        Env.KRYVEX_CrouchEnabled = false  

        if Env.KRYVEX_CrouchThread then  
            pcall(task.cancel, Env.KRYVEX_CrouchThread)  
            Env.KRYVEX_CrouchThread = nil  
        end  
    end  

    local function Fire(signal)  
        if firesignal then  
            firesignal(signal)  
        elseif getconnections then  
            for _, connection in ipairs(getconnections(signal)) do  
                connection:Fire()  
            end  
        end  
    end  

    local function StartCrouch()  
        StopCrouch()  
        Env.KRYVEX_CrouchEnabled = true  

        Env.KRYVEX_CrouchThread = task.spawn(function()  
            while Env.KRYVEX_CrouchEnabled do  
                local button = FindCrouchButton()  

                if button then  
                    for _, signalName in ipairs({  
                        "MouseButton1Down",  
                        "MouseButton1Click",  
                        "MouseButton1Up",  
                        "Activated",  
                    }) do  
                        pcall(function()  
                            Fire(button[signalName])  
                        end)  
                    end  
                end  

                task.wait(1 / (Env.KRYVEX_CrouchRate or 8))  
            end  
        end)  
    end  

    Env.KRYVEX_CrouchRate = Env.KRYVEX_CrouchRate or 8  

    MainTab:AddInput({  
        Name = "ความรัวกดย่อ (ครั้ง/วินาที)",  
        Placeholder = "ใส่ตัวเลข",  
        Default = tostring(Env.KRYVEX_CrouchRate),  

        Callback = function(value)  
            local number = tonumber(value)  
            if number then  
                Env.KRYVEX_CrouchRate = math.clamp(number, 1, 30)  
            end  
        end,  
    })  

    MainTab:AddToggle({  
        Name = "กดย่อรัวๆ",  
        Default = false,  

        Callback = function(value)  
            if value then  
                StartCrouch()  
            else  
                StopCrouch()  
            end  
        end,  
    })  

    MainTab:AddToggle({  
        Name = "กดย่อรัวๆ (ปุ่มลอย)",  
        Default = false,  

        Callback = function(value)  
            if value then  
                if FloatingButton then  
                    return  
                end  

                FloatingButton = CreateFloatingButton({  
                    Name = NAME,  
                    OnText = "กดย่อรัวๆ [ON]",  
                    OffText = "กดย่อรัวๆ [OFF]",  

                    Callback = function(active)  
                        if active then  
                            StartCrouch()  
                        else  
                            StopCrouch()  
                        end  
                    end,  
                })  
            else  
                if FloatingButton then  
                    pcall(function()  
                        FloatingButton:Destroy()  
                    end)  
                    FloatingButton = nil  
                end  

                StopCrouch()  
            end  
        end,  
    })  
end)  

if not ok then  
    warn("[HelloHub CROUCH]", err)  
end

end)

do
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Humanoid
local StateConnection
local JumpHeld = false
local BunnyHopEnabled = false
local JumpTouchInput = nil
local LastJumpRequest = 0
local LastAutoJump = 0
local JumpButtonConnections = {}

local function IsPointInside(guiObject, position)
    if not guiObject or not guiObject.Visible then
        return false
    end

    local p = guiObject.AbsolutePosition
    local s = guiObject.AbsoluteSize
    return position.X >= p.X and position.X <= p.X + s.X
        and position.Y >= p.Y and position.Y <= p.Y + s.Y
end

local function FindJumpButton()
    local touchGui = PlayerGui:FindFirstChild("TouchGui")
    if not touchGui then
        return nil
    end

    for _, object in ipairs(touchGui:GetDescendants()) do
        if object.Name == "JumpButton" and object:IsA("GuiObject") then
            return object
        end
    end

    return nil
end

local function BindJumpButton()
    for _, connection in ipairs(JumpButtonConnections) do
        connection:Disconnect()
    end
    table.clear(JumpButtonConnections)

    local button = FindJumpButton()
    if not button then
        return
    end

    table.insert(JumpButtonConnections, button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            JumpTouchInput = input
            JumpHeld = true
        end
    end))

    table.insert(JumpButtonConnections, button.InputEnded:Connect(function(input)
        if input == JumpTouchInput then
            JumpTouchInput = nil
            JumpHeld = false
        end
    end))
end

local function SetupCharacter(Character)
    if StateConnection then
        StateConnection:Disconnect()
        StateConnection = nil
    end

    Humanoid = Character:WaitForChild("Humanoid")
    JumpHeld = false
    JumpTouchInput = nil
    LastAutoJump = 0
    task.defer(BindJumpButton)
end

if Player.Character then
    SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(SetupCharacter)

PlayerGui.DescendantAdded:Connect(function(object)
    if object.Name == "JumpButton" then
        task.defer(BindJumpButton)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not BunnyHopEnabled then
        return
    end

    if input.KeyCode == Enum.KeyCode.Space then
        JumpHeld = true
    elseif input.UserInputType == Enum.UserInputType.Touch then
        local button = FindJumpButton()
        if button and IsPointInside(button, input.Position) then
            JumpTouchInput = input
            JumpHeld = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        JumpHeld = false
    elseif input == JumpTouchInput then
        JumpTouchInput = nil
        JumpHeld = false
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not BunnyHopEnabled then
        return
    end

    LastJumpRequest = os.clock()
    if Humanoid and Humanoid.Parent then
        Humanoid.Jump = true
    end
end)

RunService.Heartbeat:Connect(function()
    if not BunnyHopEnabled or not Humanoid or not Humanoid.Parent then
        return
    end

    -- JumpRequest เป็น fallback สำหรับปุ่มสัมผัส/จอยที่ไม่มี InputEnded ตรงกับปุ่ม
    local requestActive = (os.clock() - LastJumpRequest) <= 0.22
    if not JumpHeld and not requestActive then
        return
    end

    local grounded = Humanoid.FloorMaterial ~= Enum.Material.Air
    if grounded and os.clock() - LastAutoJump >= 0.12 then
        LastAutoJump = os.clock()
        Humanoid.Jump = true
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

MainTab:AddToggle({
    Name = "กระโดดค้างต่อเนื่อง",
    Default = false,

    Callback = function(Value)
        BunnyHopEnabled = Value
        if not Value then
            JumpHeld = false
            JumpTouchInput = nil
            LastJumpRequest = 0
            if Humanoid and Humanoid.Parent then
                Humanoid.Jump = false
            end
            return
        end

        BindJumpButton()
        Window:Notify({
            Title = "HelloHub",
            Content = "เปิดแล้ว กดปุ่มกระโดดค้างไว้",
            Duration = 3,
        })
    end,
})

end


do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")

    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    local Enabled = false
    local TimerGui
    local TimerText
    local StatusText
    local BorderGradient
    local RenderConnection
    local WorkerThread

    local ScanInterval = 0.25
    local StableTime = 2

    local function DestroyClock()
        if RenderConnection then
            RenderConnection:Disconnect()
            RenderConnection = nil
        end

        if WorkerThread then
            pcall(task.cancel, WorkerThread)
            WorkerThread = nil
        end

        if TimerGui then
            TimerGui:Destroy()
            TimerGui = nil
        end

        TimerText = nil
        StatusText = nil
        BorderGradient = nil
    end

    local function CreateClock()
        local OldGui = PlayerGui:FindFirstChild("HelloHubRoundSpaceClock")
        if OldGui then
            OldGui:Destroy()
        end

        TimerGui = Instance.new("ScreenGui")
        TimerGui.Name = "HelloHubRoundSpaceClock"
        TimerGui.ResetOnSpawn = false
        TimerGui.IgnoreGuiInset = true
        TimerGui.DisplayOrder = 100
        TimerGui.Parent = PlayerGui

        local Box = Instance.new("Frame")
        Box.Name = "ClockBox"
        Box.Size = UDim2.fromOffset(190, 78)
        Box.Position = UDim2.new(0.5, -95, 0, 14)
        Box.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
        Box.BorderSizePixel = 0
        Box.ClipsDescendants = true
        Box.Active = false
        Box.Parent = TimerGui
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)

        local BackgroundGradient = Instance.new("UIGradient")
        BackgroundGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 16)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(32, 32, 36)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 23)),
        })
        BackgroundGradient.Rotation = 35
        BackgroundGradient.Parent = Box

        local Stroke = Instance.new("UIStroke")
        Stroke.Thickness = 2
        Stroke.Color = Color3.new(1, 1, 1)
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Parent = Box

        BorderGradient = Instance.new("UIGradient")
        BorderGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 90, 96)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(215, 215, 220)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 90, 96)),
        })
        BorderGradient.Parent = Stroke

        local Random = Random.new()
        for _ = 1, 16 do
            local Star = Instance.new("Frame")
            local Size = Random:NextInteger(1, 2)

            Star.Size = UDim2.fromOffset(Size, Size)
            Star.Position = UDim2.fromScale(
                Random:NextNumber(),
                Random:NextNumber()
            )
            Star.BackgroundColor3 = Color3.fromRGB(230, 230, 235)
            Star.BorderSizePixel = 0
            Star.BackgroundTransparency = Random:NextNumber(0.2, 0.8)
            Star.ZIndex = 1
            Star.Parent = Box

            TweenService:Create(
                Star,
                TweenInfo.new(
                    Random:NextNumber(0.8, 2.2),
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut,
                    -1,
                    true
                ),
                { BackgroundTransparency = 1 }
            ):Play()
        end

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 16)
        Title.Position = UDim2.fromOffset(0, 5)
        Title.BackgroundTransparency = 1
        Title.Text = "◈ ROUND TIMER ◈"
        Title.Font = Enum.Font.Code
        Title.TextSize = 11
        Title.TextColor3 = Color3.fromRGB(150, 150, 158)
        Title.ZIndex = 3
        Title.Parent = Box

        TimerText = Instance.new("TextLabel")
        TimerText.Name = "RoundTimerText"
        TimerText.Size = UDim2.new(1, 0, 0, 34)
        TimerText.Position = UDim2.fromOffset(0, 20)
        TimerText.BackgroundTransparency = 1
        TimerText.Text = "--:--"
        TimerText.Font = Enum.Font.Code
        TimerText.TextSize = 30
        TimerText.TextColor3 = Color3.fromRGB(235, 235, 240)
        TimerText.ZIndex = 3
        TimerText.Parent = Box

        local TextStroke = Instance.new("UIStroke")
        TextStroke.Color = Color3.fromRGB(120, 120, 128)
        TextStroke.Thickness = 1
        TextStroke.Transparency = 0.4
        TextStroke.Parent = TimerText

        StatusText = Instance.new("TextLabel")
        StatusText.Name = "TimerStatus"
        StatusText.Size = UDim2.new(1, 0, 0, 14)
        StatusText.Position = UDim2.fromOffset(0, 56)
        StatusText.BackgroundTransparency = 1
        StatusText.Text = "SEARCHING FOR GAME TIMER"
        StatusText.Font = Enum.Font.Code
        StatusText.TextSize = 9
        StatusText.TextColor3 = Color3.fromRGB(125, 125, 132)
        StatusText.ZIndex = 3
        StatusText.Parent = Box
    end

    local function ScanGameTimer()
        local PreviousText = {}
        local LastChanged = {}
        local Candidates = {}
        local SelectedTimer

        while Enabled and TimerGui and TimerGui.Parent do
            local Success, ErrorMessage = pcall(function()
                local Now = os.clock()
                local FoundNow = {}

                for _, Object in ipairs(PlayerGui:GetDescendants()) do
                    if Object:IsA("TextLabel")
                        and Object.Name == "Timer"
                        and typeof(Object.Text) == "string" then

                        FoundNow[Object] = true

                        if PreviousText[Object] == nil then
                            PreviousText[Object] = Object.Text
                            LastChanged[Object] = Now
                        elseif PreviousText[Object] ~= Object.Text then
                            PreviousText[Object] = Object.Text
                            LastChanged[Object] = Now
                            Candidates[Object] = {
                                ChangedAt = Now,
                            }
                        end

                        if LastChanged[Object]
                            and Now - LastChanged[Object] <= StableTime then
                            Candidates[Object] = Candidates[Object] or {
                                ChangedAt = LastChanged[Object],
                            }
                        end
                    end
                end

                for Object in pairs(PreviousText) do
                    if not FoundNow[Object] then
                        PreviousText[Object] = nil
                        LastChanged[Object] = nil
                        Candidates[Object] = nil

                        if SelectedTimer == Object then
                            SelectedTimer = nil
                        end
                    end
                end

                local Best
                local BestTime

                for Object, Info in pairs(Candidates) do
                    if FoundNow[Object]
                        and Now - Info.ChangedAt <= StableTime then

                        if not BestTime or Info.ChangedAt > BestTime then
                            Best = Object
                            BestTime = Info.ChangedAt
                        end
                    else
                        Candidates[Object] = nil
                    end
                end

                if Best then
                    SelectedTimer = Best
                end

                if SelectedTimer and FoundNow[SelectedTimer] then
                    TimerText.Text = SelectedTimer.Text
                    StatusText.Text = "GAME TIMER // LIVE"
                else
                    SelectedTimer = nil
                    TimerText.Text = "--:--"
                    StatusText.Text = "SEARCHING FOR GAME TIMER"
                end
            end)

            if not Success then
                warn("[HelloHub Round Timer]", ErrorMessage)
            end

            task.wait(ScanInterval)
        end
    end

    local function StartRoundTimer()
        if Enabled then
            return
        end

        Enabled = true
        CreateClock()

        local Rotation = 0
        RenderConnection = RunService.RenderStepped:Connect(function(DeltaTime)
            if not Enabled or not BorderGradient then
                return
            end

            Rotation = (Rotation + 90 * DeltaTime) % 360
            BorderGradient.Rotation = Rotation
        end)

        WorkerThread = task.spawn(ScanGameTimer)
    end

    local function StopRoundTimer()
        Enabled = false
        DestroyClock()
    end


    MainTab:AddToggle({
        Name = "แสดงเวลาในเกม",
        Default = false,

        Callback = function(Value)
            if Value then
                StartRoundTimer()
            else
                StopRoundTimer()
            end
        end,
    })
end

do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local SpinEnabled = false
    local SpinSpeed = 10
    local SpinConnection

    local function SetSpin(Value)
        SpinEnabled = Value

        if SpinConnection then
            SpinConnection:Disconnect()
            SpinConnection = nil
        end

        if Value then
            SpinConnection = RunService.Heartbeat:Connect(function()
                if not SpinEnabled then
                    return
                end

                local Character = LocalPlayer.Character
                local Root = Character
                    and Character:FindFirstChild("HumanoidRootPart")

                if Root then
                    Root.CFrame = Root.CFrame * CFrame.Angles(
                        0,
                        math.rad(SpinSpeed),
                        0
                    )
                end
            end)

            Window:Notify({
                Title = "HelloHub",
                Content = "เปิดหมุนตัวละครแล้ว",
                Duration = 3,
            })
        else
            Window:Notify({
                Title = "HelloHub",
                Content = "ปิดหมุนตัวละครแล้ว",
                Duration = 3,
            })
        end
    end


    MainTab:AddInput({
        Name = "ความเร็วหมุน",
        Placeholder = "ใส่ความเร็ว เช่น 10",
        Default = "10",

        Callback = function(Value)
            local Number = tonumber(Value)
            if Number then
                SpinSpeed = math.clamp(Number, 0, 1000)
            end
        end,
    })

    MainTab:AddToggle({
        Name = "หมุนตัวละคร",
        Default = false,

        Callback = function(Value)
            SetSpin(Value)
        end,
    })
end

do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local FlyEnabled = false
    local FlySpeed = 1.5

    local FlyForce
    local FlySpin
    local FlyConnection
    local FlyFloatingHandle

    local function StopFly()
        FlyEnabled = false

        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end

        if FlyForce then
            FlyForce:Destroy()
            FlyForce = nil
        end

        if FlySpin then
            FlySpin:Destroy()
            FlySpin = nil
        end

        local Character = LocalPlayer.Character
        local Humanoid = Character
            and Character:FindFirstChildOfClass("Humanoid")

        if Humanoid then
            Humanoid.PlatformStand = false
            Humanoid.AutoRotate = true
        end
    end

    local function StartFly()
        local Character = LocalPlayer.Character
        local Humanoid = Character
            and Character:FindFirstChildOfClass("Humanoid")
        local Root = Character
            and Character:FindFirstChild("HumanoidRootPart")
        local Camera = workspace.CurrentCamera

        if not Humanoid or not Root or not Camera then
            return
        end

        if FlyForce then
            FlyForce:Destroy()
        end
        if FlySpin then
            FlySpin:Destroy()
        end

        FlyForce = Instance.new("BodyVelocity")
        FlyForce.Velocity = Vector3.zero
        FlyForce.P = 1000
        FlyForce.MaxForce = Vector3.new(100000, 100000, 100000)
        FlyForce.Parent = Root

        FlySpin = Instance.new("BodyGyro")
        FlySpin.P = 10000
        FlySpin.MaxTorque = Vector3.new(100000, 100000, 100000)
        FlySpin.CFrame = Root.CFrame
        FlySpin.Parent = Root

        Humanoid.PlatformStand = true
        Humanoid.AutoRotate = false
        Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

        FlyConnection = RunService.Heartbeat:Connect(function()
            if not FlyEnabled then
                return
            end

            if not Root.Parent or not Humanoid.Parent then
                StopFly()
                return
            end

            local CurrentCamera = workspace.CurrentCamera
            if not CurrentCamera then
                return
            end

            local Forward = CurrentCamera.CFrame:VectorToWorldSpace(
                Vector3.new(0, 0, -1)
            )
            local Side = CurrentCamera.CFrame:VectorToWorldSpace(
                Vector3.new(-1, 0, 0)
            )

            local CameraFrame = CurrentCamera.CFrame
            local FlatLook = Vector3.new(
                CameraFrame.LookVector.X,
                0,
                CameraFrame.LookVector.Z
            )

            if FlatLook.Magnitude > 0 then
                FlatLook = FlatLook.Unit
            end

            local Move = CFrame.new(
                Vector3.zero,
                FlatLook
            ):VectorToObjectSpace(Humanoid.MoveDirection)

            local Push = Vector3.zero
            Push += Forward * (60 * FlySpeed) * -Move.Z
            Push += Side * (40 * FlySpeed) * -Move.X

            FlySpin.CFrame = CFrame.new(Vector3.zero, Forward)
            FlyForce.Velocity = FlyForce.Velocity:Lerp(Push, 0.2)

            Humanoid.PlatformStand = true
            Humanoid.AutoRotate = false
        end)
    end

    local function SetFly(Value)
        FlyEnabled = Value

        if Value then
            StartFly()
            Window:Notify({
                Title = "HelloHub",
                Content = "เปิดบินแล้ว",
                Duration = 3,
            })
        else
            StopFly()
            Window:Notify({
                Title = "HelloHub",
                Content = "ปิดบินแล้ว",
                Duration = 3,
            })
        end
    end


    MainTab:AddInput({
        Name = "ความเร็วบิน",
        Placeholder = "ใส่ความเร็ว เช่น 1.5",
        Default = "1.5",

        Callback = function(Value)
            local Number = tonumber(Value)
            if Number then
                FlySpeed = math.clamp(Number, 0.1, 100)
            end
        end,
    })

    MainTab:AddToggle({
        Name = "บิน",
        Default = false,

        Callback = function(Value)
            SetFly(Value)
        end,
    })

    MainTab:AddToggle({
        Name = "บิน (ปุ่มลอย)",
        Default = false,

        Callback = function(Value)
            if Value then
                if FlyFloatingHandle then
                    FlyFloatingHandle:Destroy()
                    FlyFloatingHandle = nil
                end

                FlyFloatingHandle = CreateFloatingButton({
                    Name = "บิน",
                    Mode = "Toggle",
                    OnText = "เปิด",
                    OffText = "ปิด",

                    Callback = function(Active)
                        SetFly(Active)
                    end,
                })
            else
                if FlyFloatingHandle then
                    FlyFloatingHandle:Destroy()
                    FlyFloatingHandle = nil
                end

                RemoveFloatingButton("บิน")
                SetFly(false)
            end
        end,
    })

    LocalPlayer.CharacterAdded:Connect(function()
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end

        if FlyForce then
            FlyForce:Destroy()
            FlyForce = nil
        end

        if FlySpin then
            FlySpin:Destroy()
            FlySpin = nil
        end

        if FlyEnabled then
            task.wait(0.3)
            if FlyEnabled then
                StartFly()
            end
        end
    end)
end

do
    local PlayersService = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")

    local LocalPlayer = PlayersService.LocalPlayer
    local PlayerFolder = HelloHubUtil.WaitPath(workspace, { "Players" }, 5)

    local Interact = HelloHubUtil.RemoteProxy(
        ReplicatedStorage,
        { "Remotes", "Character", "Interact" },
        5
    )

    local AutoCarryRange = 25
    local FlexFloatingHandle = nil
    local IsFlexing = false

    local function GetCarryRoot(Model)
        return Model:FindFirstChild("HumanoidRootPart")
            or Model.PrimaryPart
    end

    local function GetCarryHumanoid(Model)
        return Model:FindFirstChildOfClass("Humanoid")
    end

    local function GetObjectTag(Object)
        local Tag = Object:GetAttribute("Tag")
            or Object:GetAttribute("ID")
            or Object.Name

        return tonumber(Tag) or Tag
    end

    local function FindNearestDowned()
        local Character = LocalPlayer.Character
        if not Character then
            return nil, nil
        end

        local MyRoot = GetCarryRoot(Character)
        if not MyRoot then
            return nil, nil
        end

        local Target = nil
        local TargetTag = nil
        local Distance = AutoCarryRange

        -- [FIX] โฟลเดอร์ Players อาจยังไม่มี/ถูกสร้างใหม่ ให้ค้นหาซ้ำแทนการ error
        local Folder = PlayerFolder or workspace:FindFirstChild("Players")
        for _, Object in ipairs(Folder and Folder:GetChildren() or {}) do
            if Object ~= Character and Object.Name ~= LocalPlayer.Name then
                local Humanoid = GetCarryHumanoid(Object)
                local Root = GetCarryRoot(Object)
                local Tag = GetObjectTag(Object)

                if Humanoid and Root and Tag and Humanoid.Health <= 0 then
                    local CurrentDistance =
                        (MyRoot.Position - Root.Position).Magnitude

                    if CurrentDistance <= Distance then
                        Distance = CurrentDistance
                        Target = Object
                        TargetTag = Tag
                    end
                end
            end
        end

        return Target, TargetTag
    end

    local function DoFlexSpinAndReCarry()
        local Character = LocalPlayer.Character
        if not Character or IsFlexing then
            return
        end

        local MyRoot = GetCarryRoot(Character)
        if not MyRoot then
            return
        end

        local Target, Tag = FindNearestDowned()
        if not Target or not Tag then
            return
        end

        local TargetRoot = GetCarryRoot(Target)
        if not TargetRoot then
            return
        end

        IsFlexing = true

        local OriginalAnchored = MyRoot.Anchored
        MyRoot.Anchored = true

        -- สั่งวางหนึ่งครั้ง
        pcall(function()
            Interact:FireServer("Carry", Tag)
        end)

        task.wait(0.15)

        -- เคลื่อนที่วนรอบเป้าหมาย
        local FlyHeight = 7
        local Radius = 12
        local SpinDuration = 0.85
        local Steps = 12

        for Index = 1, Steps do
            if not TargetRoot or not TargetRoot.Parent then
                break
            end

            local CenterPos = TargetRoot.Position
            local Angle = (Index / Steps) * math.rad(360)
            local OffsetX = math.cos(Angle) * Radius
            local OffsetZ = math.sin(Angle) * Radius
            local GoalPos =
                CenterPos + Vector3.new(OffsetX, FlyHeight, OffsetZ)

            local TweenInfoConfig = TweenInfo.new(
                SpinDuration / Steps,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out
            )

            local GoalCFrame = CFrame.new(GoalPos, CenterPos)
            local Tween = TweenService:Create(
                MyRoot,
                TweenInfoConfig,
                { CFrame = GoalCFrame }
            )

            Tween:Play()
            Tween.Completed:Wait()
        end

        -- เคลื่อนลงไปยังตำแหน่งเป้าหมาย
        if TargetRoot and TargetRoot.Parent then
            MyRoot.CFrame = TargetRoot.CFrame + Vector3.new(0, 0.2, 0)
        end

        MyRoot.Anchored = OriginalAnchored
        task.wait(0.08)

        -- สั่งอุ้มอีกหนึ่งครั้ง
        if TargetRoot and TargetRoot.Parent then
            pcall(function()
                Interact:FireServer("Carry", Tag)
            end)
        end

        task.wait(0.2)
        IsFlexing = false
    end


    MainTab:AddToggle({
        Name = "อุ้มแอ็ก (ปุ่มลอย)",
        Default = false,

        Callback = function(Value)
            if Value then
                if FlexFloatingHandle then
                    FlexFloatingHandle:Destroy()
                    FlexFloatingHandle = nil
                end

                FlexFloatingHandle = CreateFloatingButton({
                    Name = "อุ้มแอ็ก",
                    Mode = "Button",
                    OnText = "แอ็ก",
                    OffText = "แอ็ก",

                    Callback = function()
                        if not IsFlexing then
                            task.spawn(DoFlexSpinAndReCarry)
                        end
                    end,
                })
            else
                if FlexFloatingHandle then
                    FlexFloatingHandle:Destroy()
                    FlexFloatingHandle = nil
                end

                if RemoveFloatingButton then
                    RemoveFloatingButton("อุ้มแอ็ก")
                end

                IsFlexing = false
            end
        end,
    })
end


-- HelloHub OtherTab systems add-on
-- Append after the new script has declared OtherTab, Window, LocalPlayer and RunService.
-- Features below were ported from the old OtherTab implementation.


-- ===== ทะลุกำแพง =====

do
    local NoclipFeatureEnabled = false
    local NoclipFeatureConnection = nil

    local function SetNoclipFeature(Value)
        NoclipFeatureEnabled = Value

        if NoclipFeatureConnection then
            NoclipFeatureConnection:Disconnect()
            NoclipFeatureConnection = nil
        end

        if Value then
            NoclipFeatureConnection = RunService.Stepped:Connect(function()
                if not NoclipFeatureEnabled then
                    return
                end

                local NoclipFeatureCharacter = LocalPlayer.Character
                if not NoclipFeatureCharacter then
                    return
                end

                for _, NoclipFeaturePart in ipairs(NoclipFeatureCharacter:GetDescendants()) do
                    if NoclipFeaturePart:IsA("BasePart") then
                        NoclipFeaturePart.CanCollide = false
                    end
                end
            end)

            Window:Notify({
                Title = "HelloHub",
                Content = "เปิดทะลุกำแพงแล้ว",
                Duration = 3
            })
        else
            local NoclipFeatureCharacter = LocalPlayer.Character

            if NoclipFeatureCharacter then
                for _, NoclipFeaturePart in ipairs(NoclipFeatureCharacter:GetDescendants()) do
                    if NoclipFeaturePart:IsA("BasePart") then
                        NoclipFeaturePart.CanCollide = true
                    end
                end
            end

            Window:Notify({
                Title = "HelloHub",
                Content = "ปิดทะลุกำแพงแล้ว",
                Duration = 3
            })
        end
    end


    OtherTab:AddToggle({
        Name = "ทะลุกำแพง",
        Default = false,
        Callback = function(Value)
            SetNoclipFeature(Value)
        end
    })

    LocalPlayer.CharacterAdded:Connect(function(NoclipFeatureCharacter)
        task.wait(0.3)

        if NoclipFeatureEnabled then
            for _, NoclipFeaturePart in ipairs(NoclipFeatureCharacter:GetDescendants()) do
                if NoclipFeaturePart:IsA("BasePart") then
                    NoclipFeaturePart.CanCollide = false
                end
            end
        end
    end)
end


-- ===== กระโดดแบบควบคุมระดับ (แก้การลอยสูงเกิน) =====

do
    local MoonJumpEnabled = false
    local OriginalJumpSettings = setmetatable({}, { __mode = "k" })
    local CONTROLLED_JUMP_POWER = 52

    local function ApplyControlledJump(Character)
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid then
            return
        end

        if not OriginalJumpSettings[Humanoid] then
            OriginalJumpSettings[Humanoid] = {
                UseJumpPower = Humanoid.UseJumpPower,
                JumpPower = Humanoid.JumpPower,
                JumpHeight = Humanoid.JumpHeight,
            }
        end

        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = CONTROLLED_JUMP_POWER
    end

    local function RestoreJumpSettings(Character)
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local saved = Humanoid and OriginalJumpSettings[Humanoid]
        if not Humanoid or not saved then
            return
        end

        Humanoid.UseJumpPower = saved.UseJumpPower
        Humanoid.JumpPower = saved.JumpPower
        Humanoid.JumpHeight = saved.JumpHeight
        OriginalJumpSettings[Humanoid] = nil
    end

    local function SetMoonJump(Value)
        MoonJumpEnabled = Value

        local Character = LocalPlayer.Character
        if Value then
            ApplyControlledJump(Character)
            Window:Notify({
                Title = "HelloHub",
                Content = "เปิดกระโดดแบบควบคุมแล้ว",
                Duration = 3
            })
        else
            RestoreJumpSettings(Character)
            Window:Notify({
                Title = "HelloHub",
                Content = "ปิดกระโดดแบบควบคุมแล้ว",
                Duration = 3
            })
        end
    end

    OtherTab:AddToggle({
        Name = "กระโดดดวงจันทร์",
        Default = false,
        Callback = function(Value)
            SetMoonJump(Value)
        end
    })

    LocalPlayer.CharacterAdded:Connect(function(Character)
        task.wait(0.3)
        if MoonJumpEnabled then
            ApplyControlledJump(Character)
        end
    end)
end


-- ===== แลกโค้ดอัตโนมัติ =====

do
    local RedeemCodeEvent = HelloHubUtil.RemoteProxy(
        game:GetService("ReplicatedStorage"),
        { "Shared", "UserData", "Remotes", "RedeemCode" },
        5
    )

    local RedeemCodeList = {
        "Summer2026",
        "HAPPY4THBIRTHDAYEVADE",
        "isurviveddatahaul",
        "HALLOWEEN2026",
        "iloveevade"
    }


    OtherTab:AddButton({
        Name = "แลกโค้ดอัตโนมัติ",
        Callback = function()
            local RedeemAttemptCount = 0

            for _, RedeemCodeValue in ipairs(RedeemCodeList) do
                pcall(function()
                    RedeemCodeEvent:FireServer(RedeemCodeValue)
                end)

                RedeemAttemptCount += 1
                task.wait(0.15)
            end

            Window:Notify({
                Title = "HelloHub",
                Content = "ส่งโค้ดครบ " .. RedeemAttemptCount .. " โค้ดแล้ว",
                Duration = 3
            })
        end
    })
end

-- ===== มุมมองยืด =====

do
    local StretchedViewEnabled = false
    local StretchedViewConnection = nil
    local StretchedViewFactor = 0.53

    local function StartStretchedView()
        if StretchedViewConnection then
            StretchedViewConnection:Disconnect()
            StretchedViewConnection = nil
        end

        StretchedViewConnection = RunService.RenderStepped:Connect(function()
            if not StretchedViewEnabled then
                return
            end

            local StretchedViewCamera = workspace.CurrentCamera
            if not StretchedViewCamera then
                return
            end

            StretchedViewCamera.CFrame = StretchedViewCamera.CFrame * CFrame.new(
                0, 0, 0,
                1, 0, 0,
                0, StretchedViewFactor, 0,
                0, 0, 1
            )
        end)
    end

    local function StopStretchedView()
        if StretchedViewConnection then
            StretchedViewConnection:Disconnect()
            StretchedViewConnection = nil
        end
    end

    OtherTab:AddToggle({
        Name = "มุมมองยืด",
        Default = false,
        Callback = function(Value)
            StretchedViewEnabled = Value
            if Value then
                StartStretchedView()
                Window:Notify({
                    Title = "HelloHub",
                    Content = "เปิดมุมมองยืดแล้ว",
                    Duration = 3
                })
            else
                StopStretchedView()
                Window:Notify({
                    Title = "HelloHub",
                    Content = "ปิดมุมมองยืดแล้ว",
                    Duration = 3
                })
            end
        end
    })
end


-- ===== แก้จำนวนแสดงผล (5 ช่อง; แก้เฉพาะข้อความ GUI ในเครื่องนี้) =====

do
    local FakeStatsPlayers = game:GetService("Players")
    local FakeStatsLocalPlayer = FakeStatsPlayers.LocalPlayer

    local function FakeStatsFormatNumber(Value)
        local Digits = tostring(Value or ""):gsub("[^%d]", "")
        if Digits == "" then
            return nil
        end

        local Result = Digits
        while true do
            local NewResult, Count = Result:gsub("^(%d+)(%d%d%d)", "%1,%2")
            Result = NewResult
            if Count == 0 then
                break
            end
        end
        return Result
    end

    local function FakeStatsSetAmount(TargetName, Value)
        local AmountText = FakeStatsFormatNumber(Value)
        if not AmountText then
            return
        end

        -- จำกัดการค้นหาใน PlayerGui.HomePage.Root.Bottom.Left
        -- แทนการสแกน descendants ทั้งเกมทุกครั้งที่พิมพ์
        local PlayerGui = FakeStatsLocalPlayer:FindFirstChild("PlayerGui")
        local HomePage = PlayerGui and PlayerGui:FindFirstChild("HomePage")
        local Root = HomePage and HomePage:FindFirstChild("Root")
        local Bottom = Root and Root:FindFirstChild("Bottom")
        local Left = Bottom and Bottom:FindFirstChild("Left")
        local StatObject = Left and Left:FindFirstChild(TargetName, true)

        if not StatObject then
            return
        end

        local AmountLabel
        if StatObject:IsA("TextLabel") then
            AmountLabel = StatObject
        else
            local Body = StatObject:FindFirstChild("Body", true)
            AmountLabel = Body and Body:FindFirstChild("Amount", true)
            AmountLabel = AmountLabel or StatObject:FindFirstChild("Amount", true)
            AmountLabel = AmountLabel or StatObject:FindFirstChildWhichIsA("TextLabel", true)
        end

        if AmountLabel and AmountLabel:IsA("TextLabel") then
            AmountLabel.Text = AmountText
        end
    end

    local function AddFakeStatsInput(DisplayName, TargetName)
        OtherTab:AddInput({
            Name = DisplayName,
            Description = "เปลี่ยนข้อความแสดงผลบนเครื่องนี้เท่านั้น",
            Placeholder = "เช่น 122395",
            Default = "",
            Callback = function(Value)
                FakeStatsSetAmount(TargetName, Value)
            end
        })
    end

    AddFakeStatsInput("เงิน", "Token")
    AddFakeStatsInput("คะแนน", "Points")
    AddFakeStatsInput("ตั๋ว", "Vouchers")
    AddFakeStatsInput("โทเคน", "Tickets")
    AddFakeStatsInput("เอาชีวิตรอด", "Survivals")
end


-- ===== ลบความมืด (ไม่มี polling loop) =====

do
    local removeDarknessLighting = game:GetService("Lighting")
    local removeDarknessEnabled = false
    local removeDarknessOriginalLighting = {}
    local removeDarknessOriginalEffects = {}
    local removeDarknessEffectAddedConnection = nil

    local function isRemoveDarknessEffect(effect)
        return effect:IsA("ColorCorrectionEffect")
            or effect:IsA("BlurEffect")
            or effect:IsA("SunRaysEffect")
    end

    local function disableRemoveDarknessEffect(effect)
        if not isRemoveDarknessEffect(effect) then
            return
        end
        if removeDarknessOriginalEffects[effect] == nil then
            removeDarknessOriginalEffects[effect] = effect.Enabled
        end
        effect.Enabled = false
    end

    local function applyRemoveDarkness()
        if not removeDarknessEnabled then
            return
        end

        removeDarknessLighting.GlobalShadows = false
        removeDarknessLighting.Brightness = 3
        removeDarknessLighting.ExposureCompensation = 0.5
        removeDarknessLighting.Ambient = Color3.fromRGB(180, 180, 180)
        removeDarknessLighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        removeDarknessLighting.FogStart = 0
        removeDarknessLighting.FogEnd = 1000000

        for _, effect in ipairs(removeDarknessLighting:GetDescendants()) do
            if effect:IsA("PostEffect") then
                disableRemoveDarknessEffect(effect)
            end
        end
    end

    local function enableRemoveDarkness()
        if removeDarknessEnabled then
            return
        end

        removeDarknessEnabled = true
        removeDarknessOriginalLighting = {
            GlobalShadows = removeDarknessLighting.GlobalShadows,
            Brightness = removeDarknessLighting.Brightness,
            ExposureCompensation = removeDarknessLighting.ExposureCompensation,
            Ambient = removeDarknessLighting.Ambient,
            OutdoorAmbient = removeDarknessLighting.OutdoorAmbient,
            ClockTime = removeDarknessLighting.ClockTime,
            FogEnd = removeDarknessLighting.FogEnd,
            FogStart = removeDarknessLighting.FogStart
        }
        removeDarknessOriginalEffects = {}

        removeDarknessEffectAddedConnection = removeDarknessLighting.DescendantAdded:Connect(function(effect)
            if removeDarknessEnabled and effect:IsA("PostEffect") then
                disableRemoveDarknessEffect(effect)
            end
        end)

        -- Apply once on enable; new effects are handled by DescendantAdded.
        applyRemoveDarkness()
    end

    local function disableRemoveDarkness()
        if not removeDarknessEnabled then
            return
        end

        removeDarknessEnabled = false
        if removeDarknessEffectAddedConnection then
            removeDarknessEffectAddedConnection:Disconnect()
            removeDarknessEffectAddedConnection = nil
        end

        for property, value in pairs(removeDarknessOriginalLighting) do
            pcall(function()
                removeDarknessLighting[property] = value
            end)
        end

        for effect, wasEnabled in pairs(removeDarknessOriginalEffects) do
            pcall(function()
                if effect.Parent and effect:IsDescendantOf(removeDarknessLighting) then
                    effect.Enabled = wasEnabled
                end
            end)
        end

        removeDarknessOriginalLighting = {}
        removeDarknessOriginalEffects = {}
    end

    OtherTab:AddToggle({
        Name = "ลบความมืด",
        Default = false,
        Callback = function(value)
            if value then
                enableRemoveDarkness()
                Window:Notify({
                    Title = "HelloHub",
                    Content = "เปิดระบบลบความมืดแล้ว",
                    Duration = 3
                })
            else
                disableRemoveDarkness()
                Window:Notify({
                    Title = "HelloHub",
                    Content = "ปิดระบบและคืนค่าแสงเดิมแล้ว",
                    Duration = 3
                })
            end
        end
    })
end

-- ===== ปรับกลางวันและกลางคืน =====
do
    local DayNightLighting = game:GetService("Lighting")
    local DayNightSelectedTime = "กลางวัน"


    OtherTab:AddDropdown({
        Name = "ปรับกลางวันและกลางคืน",
        Description = "เลือกช่วงเวลาที่ต้องการ",
        Options = {"กลางวัน", "กลางคืน"},
        Default = "กลางวัน",

        Callback = function(Value)
            DayNightSelectedTime = Value
        end
    })

    OtherTab:AddButton({
        Name = "ตกลง",
        Description = "ใช้การตั้งค่าเวลาที่เลือก",

        Callback = function()
            if DayNightSelectedTime == "กลางวัน" then
                DayNightLighting.ClockTime = 14
            else
                DayNightLighting.ClockTime = 0
            end

            Window:Notify({
                Title = "HelloHub",
                Content = "ปรับเป็น" .. DayNightSelectedTime .. "แล้ว!",
                Duration = 3
            })
        end
    })
end

-- ===== ลดกราฟฟิค (สแกนครั้งเดียวและติดตามเฉพาะวัตถุใหม่) =====

do
    local LowGraphicsEnabled = false
    local LowGraphicsConnection = nil
    local LowGraphicsGeneration = 0
    local BatchSize = 80
    local BatchPause = 0.03

    local function OptimizePart(Object)
        if not LowGraphicsEnabled or not Object:IsA("BasePart") then
            return
        end

        pcall(function()
            if Object.Material ~= Enum.Material.SmoothPlastic then
                Object.Material = Enum.Material.SmoothPlastic
            end

            if Object.Reflectance ~= 0 then
                Object.Reflectance = 0
            end
        end)
    end

    local function ScanWorkspaceOnce(Generation)
        -- สแกนวัตถุทีละชุด แทนการสแกน Workspace ซ้ำเป็นช่วง ๆ
        local Queue = workspace:GetChildren()
        local Index = 1
        local Processed = 0

        while LowGraphicsEnabled
            and Generation == LowGraphicsGeneration
            and Index <= #Queue do

            local Object = Queue[Index]
            Index += 1

            if Object then
                OptimizePart(Object)

                for _, Child in ipairs(Object:GetChildren()) do
                    Queue[#Queue + 1] = Child
                end
            end

            Processed += 1
            if Processed % BatchSize == 0 then
                task.wait(BatchPause)
            end
        end
    end

    local function StartLowGraphics()
        if LowGraphicsEnabled then
            return
        end

        LowGraphicsEnabled = true
        LowGraphicsGeneration += 1
        local Generation = LowGraphicsGeneration

        if LowGraphicsConnection then
            LowGraphicsConnection:Disconnect()
            LowGraphicsConnection = nil
        end

        -- ปรับเฉพาะวัตถุใหม่ที่ถูกเพิ่มหลังจากเปิดระบบ
        LowGraphicsConnection = workspace.DescendantAdded:Connect(function(Object)
            if LowGraphicsEnabled then
                task.defer(function()
                    if LowGraphicsEnabled
                        and Generation == LowGraphicsGeneration then
                        OptimizePart(Object)
                    end
                end)
            end
        end)

        task.spawn(function()
            local Success, ErrorMessage = pcall(function()
                ScanWorkspaceOnce(Generation)
            end)

            if not Success then
                warn("[HelloHub LowGraphics] Scan error:", ErrorMessage)
            end
        end)
    end

    local function StopLowGraphics()
        LowGraphicsEnabled = false
        LowGraphicsGeneration += 1

        if LowGraphicsConnection then
            LowGraphicsConnection:Disconnect()
            LowGraphicsConnection = nil
        end
    end


    ScreenTab:AddToggle({
        Name = "ลดกราฟฟิค",
        Default = false,

        Callback = function(Value)
            if Value then
                StartLowGraphics()
            else
                StopLowGraphics()
            end

            Window:Notify({
                Title = "HelloHub",
                Content = Value
                    and "เปิดลดกราฟฟิคแล้ว"
                    or "ปิดลดกราฟฟิคแล้ว",
                Duration = 3
            })
        end
    })
end

-- ===== ลบหมอก =====
do
    local Lighting = game:GetService("Lighting")
    local FogEnabled = false
    local OriginalFogStart
    local OriginalFogEnd
    local OriginalAtmospheres = {}
    local AtmosphereAddedConnection

    local function DisableAtmosphere(AtmosphereObject)
        if not AtmosphereObject:IsA("Atmosphere") then
            return
        end

        if OriginalAtmospheres[AtmosphereObject] == nil then
            OriginalAtmospheres[AtmosphereObject] = {
                Density = AtmosphereObject.Density,
                Haze = AtmosphereObject.Haze,
                Glare = AtmosphereObject.Glare,
            }
        end

        AtmosphereObject.Density = 0
        AtmosphereObject.Haze = 0
        AtmosphereObject.Glare = 0
    end

    local function EnableFogRemoval()
        if FogEnabled then
            return
        end

        FogEnabled = true
        OriginalFogStart = Lighting.FogStart
        OriginalFogEnd = Lighting.FogEnd
        OriginalAtmospheres = {}

        Lighting.FogStart = 0
        Lighting.FogEnd = 1000000

        for _, Object in ipairs(Lighting:GetDescendants()) do
            DisableAtmosphere(Object)
        end

        AtmosphereAddedConnection = Lighting.DescendantAdded:Connect(function(Object)
            if FogEnabled then
                DisableAtmosphere(Object)
            end
        end)
    end

    local function RestoreFog()
        if not FogEnabled then
            return
        end

        FogEnabled = false

        if AtmosphereAddedConnection then
            AtmosphereAddedConnection:Disconnect()
            AtmosphereAddedConnection = nil
        end

        if OriginalFogStart ~= nil then
            Lighting.FogStart = OriginalFogStart
        end

        if OriginalFogEnd ~= nil then
            Lighting.FogEnd = OriginalFogEnd
        end

        for AtmosphereObject, Original in pairs(OriginalAtmospheres) do
            if AtmosphereObject.Parent
                and AtmosphereObject:IsDescendantOf(Lighting) then
                pcall(function()
                    AtmosphereObject.Density = Original.Density
                    AtmosphereObject.Haze = Original.Haze
                    AtmosphereObject.Glare = Original.Glare
                end)
            end
        end

        OriginalAtmospheres = {}
        OriginalFogStart = nil
        OriginalFogEnd = nil
    end


    ScreenTab:AddToggle({
        Name = "ลบหมอก",
        Default = false,

        Callback = function(Value)
            if Value then
                EnableFogRemoval()
            else
                RestoreFog()
            end
        end
    })
end

-- ===== บูสFPS =====
do
    local Lighting = game:GetService("Lighting")

    local BoostFPSEnabled = false
    local BoostFPSGeneration = 0
    local SavedProperties = {}
    local WorkspaceAddedConnection = nil
    local LightingAddedConnection = nil

    local FoliageKeywords = {
        "leaf",
        "leaves",
        "foliage",
        "canopy",
    }

    local function RememberAndSet(Object, Property, NewValue)
        local Success, OriginalValue = pcall(function()
            return Object[Property]
        end)

        if not Success then
            return
        end

        local Properties = SavedProperties[Object]
        if not Properties then
            Properties = {}
            SavedProperties[Object] = Properties
        end

        if Properties[Property] == nil then
            Properties[Property] = OriginalValue
        end

        pcall(function()
            Object[Property] = NewValue
        end)
    end

    local function IsFoliageNamed(Object)
        local Current = Object

        while Current and Current ~= workspace do
            local LowerName = string.lower(Current.Name)

            for _, Keyword in ipairs(FoliageKeywords) do
                if string.find(LowerName, Keyword, 1, true) then
                    return true
                end
            end

            Current = Current.Parent
        end

        return false
    end

    local function HideFoliageVisual(Object)
        -- ซ่อน Part, MeshPart หรือชิ้นส่วนอื่นที่สืบทอดจาก BasePart
        if Object:IsA("BasePart") then
            RememberAndSet(Object, "LocalTransparencyModifier", 1)
            return
        end

        -- ซ่อนภาพพื้นผิวที่ติดอยู่กับใบไม้
        if Object:IsA("Decal") or Object:IsA("Texture") then
            RememberAndSet(Object, "Transparency", 1)
            return
        end

        -- ปิดเอฟเฟกต์ที่ใช้แสดงใบไม้หรือเศษใบไม้
        if Object:IsA("ParticleEmitter")
            or Object:IsA("Trail")
            or Object:IsA("Beam")
            or Object:IsA("BillboardGui")
            or Object:IsA("SurfaceGui")
            or Object:IsA("Fire")
            or Object:IsA("Smoke")
            or Object:IsA("Sparkles") then

            RememberAndSet(Object, "Enabled", false)
            return
        end

        -- หากชื่อใบไม้อยู่ที่ Mesh/SurfaceAppearance ให้ซ่อน BasePart ที่เป็นเจ้าของ
        if Object:IsA("SpecialMesh") or Object:IsA("SurfaceAppearance") then
            local Parent = Object.Parent

            while Parent and not Parent:IsA("BasePart") do
                Parent = Parent.Parent
            end

            if Parent then
                RememberAndSet(Parent, "LocalTransparencyModifier", 1)
            end
        end
    end

    local function OptimizeObject(Object)
        if not BoostFPSEnabled then
            return
        end

        -- ปรับวัสดุชิ้นส่วนให้เรียบ
        if Object:IsA("BasePart") then
            RememberAndSet(Object, "Material", Enum.Material.SmoothPlastic)
            RememberAndSet(Object, "Reflectance", 0)
        end

        -- เช็กชื่อวัตถุและชื่อบรรพบุรุษ จึงรองรับ Model/Folder
        -- รวมถึง MeshPart, Decal, Texture และเอฟเฟกต์ต่าง ๆ
        if IsFoliageNamed(Object) then
            HideFoliageVisual(Object)
        end
    end

    local function ApplyFogRemoval()
        RememberAndSet(Lighting, "FogStart", 0)
        RememberAndSet(Lighting, "FogEnd", 1000000)

        for _, Object in ipairs(Lighting:GetDescendants()) do
            if Object:IsA("Atmosphere") then
                RememberAndSet(Object, "Density", 0)
                RememberAndSet(Object, "Haze", 0)
                RememberAndSet(Object, "Glare", 0)
            end
        end
    end

    local function StartBoostFPS()
        if BoostFPSEnabled then
            return
        end

        BoostFPSEnabled = true
        BoostFPSGeneration += 1
        local Generation = BoostFPSGeneration

        ApplyFogRemoval()

        -- จัดการ Atmosphere ที่ถูกเพิ่มเข้ามาทีหลัง โดยไม่ต้องวนสแกนซ้ำ
        LightingAddedConnection = Lighting.DescendantAdded:Connect(function(Object)
            if BoostFPSEnabled and Object:IsA("Atmosphere") then
                RememberAndSet(Object, "Density", 0)
                RememberAndSet(Object, "Haze", 0)
                RememberAndSet(Object, "Glare", 0)
            end
        end)

        -- จัดการวัตถุใหม่ที่ถูกเพิ่มเข้ามาใน Workspace
        WorkspaceAddedConnection = workspace.DescendantAdded:Connect(function(Object)
            task.defer(function()
                if BoostFPSEnabled and Generation == BoostFPSGeneration then
                    OptimizeObject(Object)
                end
            end)
        end)

        -- สแกนฉากครั้งเดียวเป็นชุด เพื่อลดการกระตุกจากการสแกนซ้ำ
        task.spawn(function()
            local Queue = workspace:GetChildren()
            local Index = 1
            local Processed = 0

            while BoostFPSEnabled
                and Generation == BoostFPSGeneration
                and Index <= #Queue do

                local Object = Queue[Index]
                Index += 1

                if Object then
                    OptimizeObject(Object)

                    for _, Child in ipairs(Object:GetChildren()) do
                        Queue[#Queue + 1] = Child
                    end
                end

                Processed += 1
                if Processed % 80 == 0 then
                    task.wait(0.03)
                end
            end
        end)
    end

    local function StopBoostFPS()
        if not BoostFPSEnabled then
            return
        end

        BoostFPSEnabled = false
        BoostFPSGeneration += 1

        if WorkspaceAddedConnection then
            WorkspaceAddedConnection:Disconnect()
            WorkspaceAddedConnection = nil
        end

        if LightingAddedConnection then
            LightingAddedConnection:Disconnect()
            LightingAddedConnection = nil
        end

        -- คืนค่าวัสดุ หมอก ความโปร่งใส และเอฟเฟกต์ที่บันทึกไว้
        for Object, Properties in pairs(SavedProperties) do
            if Object == Lighting or Object.Parent then
                for Property, OriginalValue in pairs(Properties) do
                    pcall(function()
                        Object[Property] = OriginalValue
                    end)
                end
            end
        end

        SavedProperties = {}
    end


    ScreenTab:AddToggle({
        Name = "บูสFPS",
        Default = false,

        Callback = function(Value)
            if Value then
                StartBoostFPS()
            else
                StopBoostFPS()
            end
        end
    })
end

-- HelloHub TeleportTab systems ported from the old script.
-- Append only once, after TeleportTab, Window, LocalPlayer, and floating-button helpers exist.

do
local WarpBotActive = false
local WarpBotConnection = nil

local SavedCFrame = nil
local IsEscaping = false

local function GetRigsFolder()
    return workspace:FindFirstChild("Rigs")
end

local CheckDelay = 0.05
local EscapeHeight = 120
local DetectDistance = 10
local SafeDistance = 12

local function GetHitbox(Rig)
    local Hitbox = Rig:FindFirstChild("Hitbox")

    if Hitbox and Hitbox:IsA("BasePart") then
        return Hitbox
    end

    return nil
end

local function FindNearestNextbot(Root)
    local NearestBot = nil
    local NearestDistance = DetectDistance

    local Folder = GetRigsFolder()
    if not Folder then
        return nil
    end

    for _, Rig in ipairs(Folder:GetChildren()) do
        local Hitbox = GetHitbox(Rig)

        if Hitbox then
            local Distance =
                (Hitbox.Position - Root.Position).Magnitude

            if Distance <= NearestDistance then
                NearestDistance = Distance
                NearestBot = Rig
            end
        end
    end

    return NearestBot
end

local function IsBotNearSavedPosition()
    if not SavedCFrame then
        return false
    end

    local Folder = GetRigsFolder()
    if not Folder then
        return false
    end

    for _, Rig in ipairs(Folder:GetChildren()) do
        local Hitbox = GetHitbox(Rig)

        if Hitbox then
            local Distance =
                (Hitbox.Position - SavedCFrame.Position).Magnitude

            if Distance <= SafeDistance then
                return true
            end
        end
    end

    return false
end

local function StartWarpBot()
    if WarpBotConnection then
        return
    end

    local LastCheck = 0

    WarpBotConnection = RunService.Heartbeat:Connect(function()
        if not WarpBotActive then
            return
        end

        local Now = os.clock()

        if Now - LastCheck < CheckDelay then
            return
        end

        LastCheck = Now

        local Character = LocalPlayer.Character
        if not Character then
            return
        end

        local Root =
            Character:FindFirstChild("HumanoidRootPart")

        if not Root then
            return
        end

        if not IsEscaping then
            local Nextbot =
                FindNearestNextbot(Root)

            if Nextbot then
                SavedCFrame = Root.CFrame
                IsEscaping = true

                Root.CFrame =
                    SavedCFrame +
                    Vector3.new(0, EscapeHeight, 0)

                Root.AssemblyLinearVelocity =
                    Vector3.zero
            end

            return
        end

        Root.AssemblyLinearVelocity =
            Vector3.zero

        if not SavedCFrame then
            IsEscaping = false
            return
        end

        if not IsBotNearSavedPosition() then
            Root.CFrame = SavedCFrame

            SavedCFrame = nil
            IsEscaping = false
        end
    end)
end

local function StopWarpBot()
    if WarpBotConnection then
        WarpBotConnection:Disconnect()
        WarpBotConnection = nil
    end

    SavedCFrame = nil
    IsEscaping = false
end

local function SetWarpBot(Value)
    WarpBotActive = Value

    if Value then
        StartWarpBot()

        Window:Notify({
            Title = "HelloHub",
            Content = "เปิดวาร์ปหนีบอทแล้ว",
            Duration = 3
        })
    else
        StopWarpBot()

        Window:Notify({
            Title = "HelloHub",
            Content = "ปิดวาร์ปหนีบอทแล้ว",
            Duration = 3
        })
    end
end


TeleportTab:AddToggle({
    Name = "วาร์ปหนีบอท",
    Default = false,
    Callback = function(Value)
        SetWarpBot(Value)
    end
})


TeleportTab:AddButton({
    Name = "วาร์ปขึ้นบน",
    Callback = function()
        local Character = LocalPlayer.Character
        if not Character then return end

        local Root = Character:FindFirstChild("HumanoidRootPart")
        if not Root then return end

        Root.CFrame = Root.CFrame + Vector3.new(0, 1200, 0)

        Window:Notify({
            Title = "HelloHub",
            Content = "วาร์ปขึ้นบน 1200 studs แล้ว",
            Duration = 3
        })
    end
})

end

do
    local PlayersService = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Interact = HelloHubUtil.RemoteProxy(
        ReplicatedStorage,
        { "Remotes", "Character", "Interact" },
        5
    )

local function GetTeleportRoot(Model)
    return Model:FindFirstChild("HumanoidRootPart")
        or Model.PrimaryPart
end

local function GetTeleportHumanoid(Model)
    return Model:FindFirstChildOfClass("Humanoid")
end

local function FindNearestDownedForTeleport()
    local Character = LocalPlayer.Character
    if not Character then return nil end

    local MyRoot = GetTeleportRoot(Character)
    if not MyRoot then return nil end

    local PlayerFolder = workspace:FindFirstChild("Players")
    if not PlayerFolder then return nil end

    local Target = nil
    local ClosestDistance = math.huge

    for _, Object in ipairs(PlayerFolder:GetChildren()) do
        if Object ~= Character and Object.Name ~= LocalPlayer.Name then
            local Humanoid = GetTeleportHumanoid(Object)
            local Root = GetTeleportRoot(Object)

            if Humanoid and Root and Humanoid.Health <= 0 then
                local Distance = (MyRoot.Position - Root.Position).Magnitude

                if Distance < ClosestDistance then
                    ClosestDistance = Distance
                    Target = Object
                end
            end
        end
    end

    return Target
end


TeleportTab:AddButton({
    Name = "วาร์ปไปหาผู้เล่นล้ม 1s",
    Callback = function()
        local Character = LocalPlayer.Character
        if not Character then return end

        local MyRoot = GetTeleportRoot(Character)
        if not MyRoot then return end

        local Target = FindNearestDownedForTeleport()

        if not Target then
            Window:Notify({
                Title = "HelloHub",
                Content = "ไม่พบผู้เล่นที่เลือดเหลือ 0",
                Duration = 3
            })
            return
        end

        local TargetRoot = GetTeleportRoot(Target)
        local Tag = Target:GetAttribute("Tag")

        if not TargetRoot or not Tag then
            Window:Notify({
                Title = "HelloHub",
                Content = "ไม่พบข้อมูลผู้เล่น",
                Duration = 3
            })
            return
        end

        local OriginalCFrame = MyRoot.CFrame

        MyRoot.CFrame = TargetRoot.CFrame

        task.wait(0.2)

        pcall(function()
            Interact:FireServer("Carry", Tag)
        end)

        task.wait(1)

        if MyRoot and MyRoot.Parent then
            MyRoot.CFrame = OriginalCFrame
        end

        Window:Notify({
            Title = "HelloHub",
            Content = "ทำรายการเสร็จแล้ว",
            Duration = 3
        })
    end
})

local SelectedTeleportPlayer = nil
local PlayerDropdown = nil

local function GetPlayerNames()
    local Names = {}

    for _, Player in ipairs(PlayersService:GetPlayers()) do
        if Player ~= LocalPlayer then
            table.insert(Names, Player.Name)
        end
    end

    table.sort(Names)

    return Names
end

local function RefreshTeleportPlayers()
    if PlayerDropdown and PlayerDropdown.SetOptions then
        PlayerDropdown:SetOptions(GetPlayerNames())
    end
end


PlayerDropdown = TeleportTab:AddDropdown({
    Name = "เลือกผู้เล่น",
    Options = GetPlayerNames(),
    Default = nil,
    Callback = function(Value)
        SelectedTeleportPlayer = Value
    end
})

TeleportTab:AddButton({
    Name = "วาร์ปไปหาผู้เล่น",
    Callback = function()
        if not SelectedTeleportPlayer then
            Window:Notify({
                Title = "HelloHub",
                Content = "กรุณาเลือกผู้เล่นก่อน",
                Duration = 3
            })
            return
        end

        local Target = PlayersService:FindFirstChild(SelectedTeleportPlayer)

        if not Target or not Target.Character then
            Window:Notify({
                Title = "HelloHub",
                Content = "ไม่พบผู้เล่นหรือ Character",
                Duration = 3
            })
            return
        end

        local Character = LocalPlayer.Character
        local MyRoot = Character and Character:FindFirstChild("HumanoidRootPart")
        local TargetRoot = Target.Character:FindFirstChild("HumanoidRootPart")

        if not MyRoot or not TargetRoot then
            return
        end

        MyRoot.CFrame = TargetRoot.CFrame

        Window:Notify({
            Title = "HelloHub",
            Content = "วาร์ปไปหา " .. Target.Name .. " แล้ว",
            Duration = 3
        })
    end
})

PlayersService.PlayerAdded:Connect(function()
    task.wait(0.1)
    RefreshTeleportPlayers()
end)

PlayersService.PlayerRemoving:Connect(function(Player)
    if SelectedTeleportPlayer == Player.Name then
        SelectedTeleportPlayer = nil
    end

    task.wait(0.1)
    RefreshTeleportPlayers()
end)

local TeleportPlayerFloatingHandle = nil

TeleportTab:AddToggle({
    Name = "วาร์ปไปหาผู้เล่น (ปุ่มลอย)",
    Default = false,
    Callback = function(Value)
        if Value then
            if TeleportPlayerFloatingHandle then
                TeleportPlayerFloatingHandle:Destroy()
                TeleportPlayerFloatingHandle = nil
            end

            TeleportPlayerFloatingHandle = CreateFloatingButton({
                Name = "วาร์ปไปหาผู้เล่น",
                Mode = "Button",
                OnText = "วาร์ป",
                OffText = "วาร์ป",
                Callback = function()
                    if not SelectedTeleportPlayer then
                        Window:Notify({
                            Title = "HelloHub",
                            Content = "กรุณาเลือกผู้เล่นก่อน",
                            Duration = 3
                        })
                        return
                    end

                    local Target = PlayersService:FindFirstChild(SelectedTeleportPlayer)
                    local Character = LocalPlayer.Character

                    if not Target or not Target.Character or not Character then
                        Window:Notify({
                            Title = "HelloHub",
                            Content = "ไม่พบผู้เล่น",
                            Duration = 3
                        })
                        return
                    end

                    local MyRoot = Character:FindFirstChild("HumanoidRootPart")
                    local TargetRoot = Target.Character:FindFirstChild("HumanoidRootPart")

                    if not MyRoot or not TargetRoot then
                        return
                    end

                    MyRoot.CFrame = TargetRoot.CFrame

                    Window:Notify({
                        Title = "HelloHub",
                        Content = "วาร์ปไปหา " .. Target.Name .. " แล้ว",
                        Duration = 3
                    })
                end
            })
        else
            if TeleportPlayerFloatingHandle then
                TeleportPlayerFloatingHandle:Destroy()
                TeleportPlayerFloatingHandle = nil
            end

            RemoveFloatingButton("วาร์ปไปหาผู้เล่น")
        end
    end
})

end


TeleportTab:AddButton({
    Name = "วาร์ปสุ่มผู้เล่น",
    Callback = function()
        local Character = LocalPlayer.Character
        if not Character then
            return
        end

        local Root = Character:FindFirstChild("HumanoidRootPart")
        if not Root then
            return
        end

        local Targets = {}

        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer
                and Player.Character
                and Player.Character:FindFirstChild("HumanoidRootPart") then

                table.insert(Targets, Player)
            end
        end

        if #Targets == 0 then
            Window:Notify({
                Title = "HelloHub",
                Content = "ไม่พบผู้เล่นให้สุ่มวาร์ป",
                Duration = 3
            })
            return
        end

        local Target = Targets[math.random(1, #Targets)]
        local TargetRoot = Target.Character:FindFirstChild("HumanoidRootPart")

        if TargetRoot then
            Root.CFrame = TargetRoot.CFrame + Vector3.new(0, 3, 0)

            Window:Notify({
                Title = "HelloHub",
                Content = "วาร์ปไปหา " .. Target.DisplayName .. " แล้ว",
                Duration = 3
            })
        end
    end
})

--=========================================================
-- HelloHub | CLICK TELEPORT
-- Tab: TeleportTab
--=========================================================

do
    local UIS = game:GetService("UserInputService")
    local Player = game:GetService("Players").LocalPlayer
    local Enabled = false
    local Connection = nil

    local function ToggleClickTeleport(State)
        Enabled = State

        if Connection then
            Connection:Disconnect()
            Connection = nil
        end

        if not Enabled then
            return
        end

        Connection = UIS.InputBegan:Connect(function(Input, Processed)
            if Processed or not Enabled then
                return
            end

            if Input.UserInputType ~= Enum.UserInputType.MouseButton1
                and Input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end

            local Camera = workspace.CurrentCamera
            if not Camera then return end

            local Ray = Camera:ViewportPointToRay(
                Input.Position.X,
                Input.Position.Y
            )

            local Params = RaycastParams.new()
            Params.FilterType = Enum.RaycastFilterType.Exclude
            Params.FilterDescendantsInstances = {
                Player.Character
            }

            local Result = workspace:Raycast(
                Ray.Origin,
                Ray.Direction * 10000,
                Params
            )

            if not Result then return end

            local Character = Player.Character
            local Root = Character
                and Character:FindFirstChild("HumanoidRootPart")

            if not Root then return end

            Root.CFrame = CFrame.new(
                Result.Position + Vector3.new(0, 3, 0)
            )
        end)
    end


    TeleportTab:AddToggle({
        Name = "คลิกเทเลพอร์ต",
        Default = false,

        Callback = function(State)
            ToggleClickTeleport(State)

            Window:Notify({
                Title = "HelloHub",
                Content = State
                    and "เปิดคลิกเทเลพอร์ตแล้ว"
                    or "ปิดคลิกเทเลพอร์ตแล้ว",
                Duration = 3
            })
        end
    })

    print("[HelloHub] Click Teleport Loaded")
end

--=========================================================
-- HelloHub | RESCUE TELEPORT V2
-- Find Downed -> Carry -> Return
--=========================================================

do
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Player = Players.LocalPlayer
    local Interact = HelloHubUtil.RemoteProxy(
        ReplicatedStorage,
        { "Remotes", "Character", "Interact" },
        5
    )

    local RescueBusy = false
    local RescueDelay = 3
    local RescueFloatingHandle = nil

    --=====================================================
    -- NOTIFY
    --=====================================================

    local function Notify(Message)
        pcall(function()
            Window:Notify({
                Title = "HelloHub",
                Content = Message,
                Duration = 3
            })
        end)
    end

    --=====================================================
    -- GET CHARACTER
    --=====================================================

    local function GetCharacterParts()
        local Character = Player.Character
        if not Character then return end

        local Root = Character:FindFirstChild("HumanoidRootPart")
            or Character.PrimaryPart

        local Humanoid = Character:FindFirstChildWhichIsA(
            "Humanoid",
            true
        )

        if not Root or not Humanoid or Humanoid.Health <= 0 then
            return
        end

        return Character, Root, Humanoid
    end

    --=====================================================
    -- GET TARGET TAG
    --=====================================================

    local function GetTargetTag(Target)
        local Tag = Target:GetAttribute("Tag")

        if Tag == nil then
            Tag = Target:GetAttribute("ID")
        end

        if Tag == nil then
            Tag = Target.Name
        end

        if typeof(Tag) == "number" then
            return Tag
        end

        if typeof(Tag) == "string" and Tag ~= "" then
            return tonumber(Tag) or Tag
        end

        return nil
    end

    --=====================================================
    -- FIND DOWNED PLAYERS
    --=====================================================

    local function FindDownedPlayers(Origin)
        local Targets = {}

        local Folder = workspace:FindFirstChild("Players")

        if not Folder then
            warn("[HelloHub Rescue] workspace.Players not found")
            return Targets
        end

        for _, Model in ipairs(Folder:GetChildren()) do
            if Model:IsA("Model") and Model ~= Player.Character then
                local Humanoid = Model:FindFirstChildWhichIsA(
                    "Humanoid",
                    true
                )

                local Root = Model:FindFirstChild("HumanoidRootPart", true)
                    or Model.PrimaryPart

                -- ไม่บังคับให้มี Tag ตอนค้นหา
                if Humanoid and Humanoid.Health <= 0 and Root then
                    table.insert(Targets, {
                        Model = Model,
                        Humanoid = Humanoid,
                        Root = Root,
                        Tag = GetTargetTag(Model),
                        Distance = (Root.Position - Origin).Magnitude
                    })
                end
            end
        end

        table.sort(Targets, function(A, B)
            return A.Distance < B.Distance
        end)

        return Targets
    end

    --=====================================================
    -- CHECK CARRY JOINT
    --=====================================================

    local function BelongsTo(Model, Part)
        return Part
            and Part:IsA("BasePart")
            and Part:IsDescendantOf(Model)
    end

    local function IsConnectedCarry(Character, Target)
        local function CheckObject(Object)
            local Part0, Part1

            if Object:IsA("JointInstance")
                or Object:IsA("WeldConstraint") then

                Part0 = Object.Part0
                Part1 = Object.Part1

            elseif Object:IsA("Constraint") then
                local A, B

                pcall(function()
                    A = Object.Attachment0
                    B = Object.Attachment1
                end)

                Part0 = A and A.Parent
                Part1 = B and B.Parent
            else
                return false
            end

            return (
                BelongsTo(Character, Part0)
                and BelongsTo(Target, Part1)
            ) or (
                BelongsTo(Target, Part0)
                and BelongsTo(Character, Part1)
            )
        end

        for _, Object in ipairs(Character:GetDescendants()) do
            if CheckObject(Object) then
                return true
            end
        end

        for _, Object in ipairs(Target:GetDescendants()) do
            if CheckObject(Object) then
                return true
            end
        end

        return false
    end

    --=====================================================
    -- TELEPORT
    --=====================================================

    local function ReturnToOrigin(OriginCFrame)
        local Character = Player.Character
        local Root = Character
            and Character:FindFirstChild("HumanoidRootPart")

        if Root and OriginCFrame then
            pcall(function()
                Root.CFrame = OriginCFrame
            end)
        end
    end

    --=====================================================
    -- RESCUE
    --=====================================================

    local function RescueDownedPlayers()
        if RescueBusy then
            Notify("กำลังช่วยผู้เล่นอยู่")
            return
        end

        local Character, Root = GetCharacterParts()

        if not Character or not Root then
            Notify("ไม่พบตัวละครที่พร้อมใช้งาน")
            return
        end

        local OriginCFrame = Root.CFrame
        local Targets = FindDownedPlayers(Root.Position)

        if #Targets == 0 then
            Notify("ไม่พบผู้เล่นที่เลือดเหลือ 0 ใน workspace.Players")
            return
        end

        RescueBusy = true

        task.spawn(function()
            local Carried = false
            local Failed = false

            local OK, ErrorMessage = pcall(function()
                for _, Info in ipairs(Targets) do
                    if Player.Character ~= Character then
                        break
                    end

                    local Target = Info.Model
                    local Humanoid = Info.Humanoid
                    local TargetRoot = Info.Root
                    local Tag = Info.Tag

                    if not Target.Parent
                        or not Humanoid.Parent
                        or not TargetRoot.Parent
                        or Humanoid.Health > 0 then
                        continue
                    end

                    if Tag == nil then
                        warn("[HelloHub Rescue] Missing target Tag:", Target:GetFullName())
                        continue
                    end

                    Notify("กำลังไปหา: " .. Target.Name)

                    local TeleportOK = pcall(function()
                        Root.CFrame = TargetRoot.CFrame
                            * CFrame.new(0, 0, 3)
                    end)

                    if not TeleportOK then
                        continue
                    end

                    task.wait(0.2)

                    if Player.Character ~= Character then
                        break
                    end

                    if not Target.Parent or Humanoid.Health > 0 then
                        continue
                    end

                    -- ส่งคำสั่งอุ้มหนึ่งครั้งต่อเป้าหมาย
                    local Sent = pcall(function()
                        Interact:FireServer("Carry", Tag)
                    end)

                    if not Sent then
                        continue
                    end

                    local Started = os.clock()

                    while os.clock() - Started < RescueDelay do
                        if Player.Character ~= Character then
                            break
                        end

                        if not Target.Parent or not TargetRoot.Parent then
                            break
                        end

                        if IsConnectedCarry(Character, Target) then
                            Carried = true
                            break
                        end

                        task.wait(0.15)
                    end

                    if Carried then
                        Notify("อุ้มสำเร็จ กำลังกลับจุดเดิม")
                        break
                    end
                end
            end)

            -- กลับจุดเดิมหลังจบการช่วย
            if Player.Character == Character then
                ReturnToOrigin(OriginCFrame)
            end

            RescueBusy = false

            if not OK then
                warn("[HelloHub Rescue]", ErrorMessage)
                Notify("เกิดข้อผิดพลาดระหว่างช่วยผู้เล่น")
            elseif Carried then
                Notify("กลับจุดเดิมแล้ว")
            else
                Notify("ไม่มีเป้าหมายที่อุ้มสำเร็จ")
            end
        end)
    end

    --=====================================================
    -- TELEPORT TAB BUTTON
    --=====================================================


    TeleportTab:AddButton({
        Name = "วาร์ปไปเก็บผู้เล่นที่ล้ม",
        Callback = function()
            RescueDownedPlayers()
        end
    })

    --=====================================================
    -- FLOATING BUTTON TOGGLE
    --=====================================================

    TeleportTab:AddToggle({
        Name = "ช่วยผู้เล่นที่ล้ม (ปุ่มลอย)",
        Default = false,

        Callback = function(Value)
            if Value then
                if RescueFloatingHandle then
                    RescueFloatingHandle:Destroy()
                    RescueFloatingHandle = nil
                end

                RescueFloatingHandle = CreateFloatingButton({
                    Name = "ช่วยคนล้ม",
                    Mode = "Button",
                    OnText = "ช่วยคนล้ม",
                    OffText = "ช่วยคนล้ม",

                    Callback = function()
                        RescueDownedPlayers()
                    end
                })
            else
                if RescueFloatingHandle then
                    RescueFloatingHandle:Destroy()
                    RescueFloatingHandle = nil
                end

                RemoveFloatingButton("ช่วยคนล้ม")
            end
        end
    })
end

--=========================================================
-- HelloHub | VISUAL ESP (Players / Downed / Bots)
-- ใช้แท็บ VisualTab ที่ประกาศไว้แล้ว
-- กล่องเป็นภาพแสดงผลเฉพาะเครื่อง ไม่แก้ Part ของผู้เล่นคนอื่น
--=========================================================
do
    local ESPPlayers = game:GetService("Players")
    local ESPRunService = game:GetService("RunService")
    local ESPPlayer = ESPPlayers.LocalPlayer

    local ShowAllPlayers = false
    local ShowDownedPlayers = false
    local ShowBots = false
    local Visuals = {}
    local OverlayGui = nil
    local LineHolder = nil
    local ProxyHolder = nil
    local RenderConnection = nil
    local ScanElapsed = 0
    local SCAN_INTERVAL = 0.4

    local ESPColors = {
        Player = Color3.fromRGB(220, 220, 220),
        Downed = Color3.fromRGB(255, 220, 45),
        Bot = Color3.fromRGB(255, 65, 65),
    }

    local BOX_SIZE = Vector3.new(4, 5.5, 2)
    local function AnyESPEnabled()
        return ShowAllPlayers or ShowDownedPlayers or ShowBots
    end

    local function GetOverlayParent()
        if type(gethui) == "function" then
            local OK, Parent = pcall(gethui)
            if OK and Parent then
                return Parent
            end
        end

        local OK, Parent = pcall(function()
            return game:GetService("CoreGui")
        end)
        if OK and Parent then
            return Parent
        end

        return ESPPlayer:WaitForChild("PlayerGui")
    end

    local function EnsureOverlay()
        if OverlayGui and OverlayGui.Parent then
            return
        end

        local Parent = GetOverlayParent()
        local Old = Parent:FindFirstChild("HelloHub_VisualESP")
        if Old then
            Old:Destroy()
        end

        OverlayGui = Instance.new("ScreenGui")
        OverlayGui.Name = "HelloHub_VisualESP"
        OverlayGui.ResetOnSpawn = false
        OverlayGui.IgnoreGuiInset = true
        OverlayGui.DisplayOrder = 999
        OverlayGui.Parent = Parent

        LineHolder = Instance.new("Folder")
        LineHolder.Name = "Lines"
        LineHolder.Parent = OverlayGui

        ProxyHolder = Instance.new("Folder")
        ProxyHolder.Name = "Boxes"
        ProxyHolder.Parent = OverlayGui
    end

    local function GetCamera()
        return workspace.CurrentCamera
    end

    local function GetRoot(Model)
        if not Model then
            return nil
        end

        local Root = Model:FindFirstChild("HumanoidRootPart", true)
            or Model:FindFirstChild("Hitbox", true)

        if Root and Root:IsA("BasePart") then
            return Root
        end

        if Model:IsA("Model") and Model.PrimaryPart then
            return Model.PrimaryPart
        end

        return nil
    end

    local function GetHumanoid(Model)
        return Model and Model:FindFirstChildWhichIsA("Humanoid", true)
    end

    local function IsDowned(Model)
        local Humanoid = GetHumanoid(Model)
        if Humanoid and Humanoid.Health <= 0 then
            return true
        end

        for _, AttributeName in ipairs({"Downed", "IsDowned", "Knocked", "IsKnocked"}) do
            if Model:GetAttribute(AttributeName) == true then
                return true
            end
            if Humanoid and Humanoid:GetAttribute(AttributeName) == true then
                return true
            end
        end

        return false
    end

    local function MakeVisual(Model, Root, Kind, Label)
        EnsureOverlay()

        local Camera = GetCamera()
        if not Camera then
            return nil
        end

        local Proxy = Instance.new("Part")
        Proxy.Name = "HelloHub_ESP_Proxy"
        Proxy.Size = BOX_SIZE
        Proxy.Transparency = 1
        Proxy.Anchored = true
        Proxy.CanCollide = false
        Proxy.CanTouch = false
        Proxy.CanQuery = false
        Proxy.CastShadow = false
        Proxy.CFrame = Root.CFrame
        Proxy.Parent = Camera

        local Color = ESPColors[Kind]

        local Box = Instance.new("BoxHandleAdornment")
        Box.Name = "HelloHub_ESP_Box"
        Box.Adornee = Proxy
        Box.Size = BOX_SIZE
        Box.Color3 = Color
        Box.Transparency = 0.55
        Box.AlwaysOnTop = true
        Box.ZIndex = 5
        Box.Parent = ProxyHolder

        local Outline = Instance.new("SelectionBox")
        Outline.Name = "HelloHub_ESP_Outline"
        Outline.Adornee = Proxy
        Outline.Color3 = Color
        Outline.LineThickness = 0.05
        Outline.SurfaceTransparency = 1
        Outline.Parent = ProxyHolder

        local Billboard = Instance.new("BillboardGui")
        Billboard.Name = "HelloHub_ESP_Label"
        Billboard.Adornee = Proxy
        Billboard.Size = UDim2.fromOffset(180, 32)
        Billboard.StudsOffset = Vector3.new(0, 3.7, 0)
        Billboard.AlwaysOnTop = true
        Billboard.Parent = ProxyHolder

        local Text = Instance.new("TextLabel")
        Text.Name = "Label"
        Text.BackgroundTransparency = 1
        Text.Size = UDim2.fromScale(1, 1)
        Text.Font = Enum.Font.GothamBold
        Text.Text = Label
        Text.TextColor3 = Color
        Text.TextSize = 14
        Text.TextStrokeColor3 = Color3.new(0, 0, 0)
        Text.TextStrokeTransparency = 0.2
        Text.TextWrapped = true
        Text.Parent = Billboard

        local Line = Instance.new("Frame")
        Line.Name = "HelloHub_ESP_Line"
        Line.AnchorPoint = Vector2.new(0.5, 0.5)
        Line.BackgroundColor3 = Color
        Line.BorderSizePixel = 0
        Line.Visible = false
        Line.Parent = LineHolder

        return {
            Model = Model,
            Root = Root,
            Kind = Kind,
            Label = Label,
            Proxy = Proxy,
            Box = Box,
            Outline = Outline,
            Billboard = Billboard,
            Text = Text,
            Line = Line,
        }
    end

    local function RemoveVisual(Model)
        local Item = Visuals[Model]
        if not Item then
            return
        end

        for _, Object in ipairs({Item.Proxy, Item.Box, Item.Outline, Item.Billboard, Item.Line}) do
            if Object then
                pcall(function()
                    Object:Destroy()
                end)
            end
        end
        Visuals[Model] = nil
    end

    local function ClearVisuals()
        local Models = {}
        for Model in pairs(Visuals) do
            Models[#Models + 1] = Model
        end
        for _, Model in ipairs(Models) do
            RemoveVisual(Model)
        end
    end

    local function BuildTargets()
        local Targets = {}

        -- ผู้เล่นปกติ: ใช้ชื่อบัญชีผู้เล่นเป็นข้อความ
        if ShowAllPlayers then
            for _, Player in ipairs(ESPPlayers:GetPlayers()) do
                if Player ~= ESPPlayer then
                    local Character = Player.Character
                    local Root = GetRoot(Character)
                    if Character and Root then
                        Targets[Character] = {
                            Root = Root,
                            Kind = "Player",
                            Label = Player.Name,
                        }
                    end
                end
            end
        end

        -- ผู้เล่นที่ล้ม: วางทับรายการผู้เล่นปกติเพื่อให้สี/ข้อความเป็นเหลือง/ล้ม
        if ShowDownedPlayers then
            local PlayerFolder = workspace:FindFirstChild("Players")
            if PlayerFolder then
                for _, Model in ipairs(PlayerFolder:GetChildren()) do
                    if Model:IsA("Model") and Model ~= ESPPlayer.Character and IsDowned(Model) then
                        local Root = GetRoot(Model)
                        if Root then
                            Targets[Model] = {
                                Root = Root,
                                Kind = "Downed",
                                Label = "ล้ม",
                            }
                        end
                    end
                end
            end

            -- เผื่อโครงสร้างเกมเก็บ Character ไว้นอก workspace.Players
            for _, Player in ipairs(ESPPlayers:GetPlayers()) do
                if Player ~= ESPPlayer and Player.Character and IsDowned(Player.Character) then
                    local Root = GetRoot(Player.Character)
                    if Root then
                        Targets[Player.Character] = {
                            Root = Root,
                            Kind = "Downed",
                            Label = "ล้ม",
                        }
                    end
                end
            end
        end

        -- บอทของ Evade อยู่ใน workspace.Rigs และมักมี Hitbox
        if ShowBots then
            local Rigs = workspace:FindFirstChild("Rigs")
            if Rigs then
                for _, Rig in ipairs(Rigs:GetChildren()) do
                    if Rig:IsA("Model") or Rig:IsA("Folder") then
                        local Root = GetRoot(Rig)
                        if Root and Root:IsA("BasePart") then
                            Targets[Rig] = {
                                Root = Root,
                                Kind = "Bot",
                                Label = "บอท",
                            }
                        end
                    end
                end
            end
        end

        return Targets
    end

    local function SyncTargets()
        local Targets = BuildTargets()

        for Model in pairs(Visuals) do
            if not Targets[Model] or not Model.Parent then
                RemoveVisual(Model)
            end
        end

        for Model, Data in pairs(Targets) do
            local Item = Visuals[Model]
            if not Item then
                Item = MakeVisual(Model, Data.Root, Data.Kind, Data.Label)
                if Item then
                    Visuals[Model] = Item
                end
            else
                Item.Root = Data.Root
                Item.Kind = Data.Kind
                Item.Label = Data.Label

                local Color = ESPColors[Data.Kind]
                Item.Box.Color3 = Color
                Item.Outline.Color3 = Color
                Item.Text.TextColor3 = Color
                Item.Text.Text = Data.Label
                Item.Line.BackgroundColor3 = Color
            end
        end
    end

    local function StopVisuals()
        if RenderConnection then
            RenderConnection:Disconnect()
            RenderConnection = nil
        end

        ClearVisuals()

        if OverlayGui then
            OverlayGui:Destroy()
            OverlayGui = nil
            LineHolder = nil
            ProxyHolder = nil
        end
    end

    local function UpdateVisuals(DeltaTime)
        if not AnyESPEnabled() then
            StopVisuals()
            return
        end

        ScanElapsed += DeltaTime
        if ScanElapsed >= SCAN_INTERVAL then
            ScanElapsed = 0
            SyncTargets()
        end

        local Camera = GetCamera()
        if not Camera then
            return
        end

        local TopCenter = Vector2.new(Camera.ViewportSize.X / 2, 0)

        for Model, Item in pairs(Visuals) do
            local Root = Item.Root
            if not Model.Parent or not Root or not Root.Parent then
                RemoveVisual(Model)
            else
                if Item.Proxy.Parent ~= Camera then
                    Item.Proxy.Parent = Camera
                end

                Item.Proxy.CFrame = Root.CFrame

                local Position, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                if OnScreen and Position.Z > 0 then
                    local Target = Vector2.new(Position.X, Position.Y)
                    local Difference = Target - TopCenter
                    Item.Line.Size = UDim2.fromOffset(Difference.Magnitude, 2)
                    Item.Line.Position = UDim2.fromOffset(
                        (TopCenter.X + Target.X) / 2,
                        (TopCenter.Y + Target.Y) / 2
                    )
                    Item.Line.Rotation = math.deg(math.atan2(Difference.Y, Difference.X))
                    Item.Line.Visible = true
                else
                    Item.Line.Visible = false
                end
            end
        end
    end

    local function SetESPMode(Mode, Value)
        if Mode == "Players" then
            ShowAllPlayers = Value
        elseif Mode == "Downed" then
            ShowDownedPlayers = Value
        elseif Mode == "Bots" then
            ShowBots = Value
        end

        if not AnyESPEnabled() then
            StopVisuals()
            ScanElapsed = 0
            return
        end

        EnsureOverlay()
        SyncTargets()

        if not RenderConnection then
            ScanElapsed = 0
            RenderConnection = ESPRunService.RenderStepped:Connect(UpdateVisuals)
        end
    end


    VisualTab:AddToggle({
        Name = "มองหาผู้เล่นทั้งหมด",
        Default = false,
        Callback = function(Value)
            SetESPMode("Players", Value)
        end,
    })

    VisualTab:AddToggle({
        Name = "มองหาผู้เล่นล้ม",
        Default = false,
        Callback = function(Value)
            SetESPMode("Downed", Value)
        end,
    })

    VisualTab:AddToggle({
        Name = "มองหาบอท",
        Default = false,
        Callback = function(Value)
            SetESPMode("Bots", Value)
        end,
    })
end

do
-- [FIX] แยกบล็อกนี้เป็นฟังก์ชันของตัวเอง เพื่อไม่ให้จำนวน local ในฟังก์ชันหลักเกินขีดจำกัด 200
local function __HelloHub_DragModeBlock()
if not game:IsLoaded() then game.Loaded:Wait() end

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local plr = Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")

-- ===== ตั้งค่า =====
local LUCIDE_NAME = "move"
local RESET_ICON = "rotate-ccw"
local FALLBACK_EMOJI = "✋"
local SLOT = 44
local TOOL_WIDTH = 62
local ICON = 36
local ICON_DRAW = 24
local FALLBACK_X, FALLBACK_Y = 400, 18
local GAP = 8
local OFFSET_X, OFFSET_Y = 0, 0
local DRAG_THRESHOLD = 6
local ON_COLOR = Color3.fromRGB(90, 255, 140)
local OFF_COLOR = Color3.new(0.96863, 0.96863, 0.97255)
-- ===================

local function getParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    if pcall(function() return CoreGui.Name end) then return CoreGui end
    return playerGui
end

-- โหลด Lucide
local Lucide
pcall(function()
    Lucide = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua"
    ))()
end)

local function getAsset(name)
    if not Lucide then return nil end
    local ok, a = pcall(Lucide.GetAsset, name)
    return ok and a or nil
end

local parent = getParent()
local old = parent:FindFirstChild("DragModeBtn")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "DragModeBtn"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = parent

-- ===== หาตำแหน่งต่อท้ายปุ่มขวาสุดของ Topbar =====
local inset = GuiService:GetGuiInset()
local posX, posY = FALLBACK_X, FALLBACK_Y

pcall(function()
    local top = CoreGui:FindFirstChild("TopBarApp")
    if not top then return end

    local right, midY

    for _, o in ipairs(top:GetDescendants()) do
        if o:IsA("GuiObject") and o.Visible then
            local s, p = o.AbsoluteSize, o.AbsolutePosition
            local my = p.Y + s.Y / 2

            if my < 30 then
                my = my + inset.Y
            end

            if s.Y >= 40
                and s.Y <= 56
                and s.X >= 40
                and s.X <= 300
                and my > 15
                and my < 65 then

                local r = p.X + s.X
                if not right or r > right then
                    right, midY = r, my
                end
            end
        end
    end

    if right and right > 100 and right < 700 then
        posX = right + GAP
        posY = midY - SLOT / 2
    end
end)

-- ให้แผงสามปุ่มอยู่ในขอบจอ
local camera = workspace.CurrentCamera
local viewSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)
local panelWidth = SLOT * 2 + GAP * 2 + TOOL_WIDTH

posX = math.clamp(posX, 8, math.max(8, viewSize.X - panelWidth - 8))
posY = math.clamp(posY, 8, math.max(8, viewSize.Y - SLOT - 8))

-- ===== สร้างปุ่มวงกลม/แคปซูล =====
local function makeButton(x, y, lucideName, emoji, width)
    local buttonWidth = width or SLOT

    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(x, y)
    bar.Size = UDim2.fromOffset(buttonWidth, SLOT)
    bar.BackgroundColor3 = Color3.new(0.07059, 0.07059, 0.08235)
    bar.BackgroundTransparency = 0.08
    bar.BorderSizePixel = 0
    bar.Parent = gui

    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local hl = Instance.new("Frame")
    hl.AnchorPoint = Vector2.new(0.5, 0.5)
    hl.Position = UDim2.fromScale(0.5, 0.5)
    hl.Size = UDim2.fromOffset(ICON, ICON)
    hl.BackgroundColor3 = Color3.new(0.81569, 0.85098, 0.98431)
    hl.BackgroundTransparency = 0.92
    hl.BorderSizePixel = 0
    hl.Visible = false
    hl.Parent = bar

    Instance.new("UICorner", hl).CornerRadius = UDim.new(1, 0)

    local asset = getAsset(lucideName)
    local icon

    if asset then
        icon = Instance.new("ImageLabel")
        icon.Image = asset.Url
        icon.ImageRectOffset = asset.ImageRectOffset
        icon.ImageRectSize = asset.ImageRectSize
        icon.ImageColor3 = OFF_COLOR
        icon.Size = UDim2.fromOffset(ICON_DRAW, ICON_DRAW)
    else
        icon = Instance.new("TextLabel")
        icon.Text = emoji
        icon.TextSize = 22
        icon.Font = Enum.Font.GothamBold
        icon.TextColor3 = OFF_COLOR
        icon.Size = UDim2.fromOffset(ICON, ICON)
    end

    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.fromScale(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.Parent = bar

    local hit = Instance.new("ImageButton")
    hit.AnchorPoint = Vector2.new(0.5, 0.5)
    hit.Position = UDim2.fromScale(0.5, 0.5)
    hit.Size = UDim2.fromOffset(buttonWidth, SLOT)
    hit.BackgroundTransparency = 1
    hit.Image = ""
    hit.AutoButtonColor = false
    hit.ZIndex = 5
    hit.Parent = bar

    Instance.new("UICorner", hit).CornerRadius = UDim.new(1, 0)

    return bar, hl, icon, hit
end

local bar, hl, icon, hit =
    makeButton(posX + OFFSET_X, posY + OFFSET_Y, LUCIDE_NAME, FALLBACK_EMOJI)

local rbar, rhl, ricon, rhit =
    makeButton(posX + OFFSET_X + SLOT + GAP, posY + OFFSET_Y, RESET_ICON, "♻")

local toolBar, toolHighlight, toolIcon, toolHit = makeButton(
    posX + OFFSET_X + (SLOT + GAP) * 2,
    posY + OFFSET_Y,
    "wrench",
    "🔧",
    TOOL_WIDTH
)

-- ===== ระบบลากปุ่ม =====
local editMode = false
local moved = {}

local function setColor(ic, c)
    if ic:IsA("ImageLabel") then
        ic.ImageColor3 = c
    else
        ic.TextColor3 = c
    end
end

local function setMode(on)
    editMode = on
    hl.Visible = on
    hl.BackgroundTransparency = on and 0.75 or 0.92
    setColor(icon, on and ON_COLOR or OFF_COLOR)
end

hit.MouseButton1Click:Connect(function()
    setMode(not editMode)
end)

-- รีเซ็ตทุกปุ่มกลับที่เดิม
rhit.MouseButton1Click:Connect(function()
    for obj, info in pairs(moved) do
        if obj and obj.Parent then
            if info.placeholder and info.placeholder.Parent then
                obj.Parent = info.parent
                obj.LayoutOrder = info.layoutOrder
                info.placeholder:Destroy()
            end

            obj.Size = info.size
            obj.Position = info.position
        end
    end

    moved = {}
    rhl.Visible = true

    task.delay(0.2, function()
        rhl.Visible = false
    end)
end)

local function viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1920, 1080)
end

local function tooBig(obj)
    local v = viewport()

    return obj.AbsoluteSize.X >= v.X * 0.6
        and obj.AbsoluteSize.Y >= v.Y * 0.6
end

local function overMine(pos)
    for _, b in ipairs({bar, rbar, toolBar}) do
        local p, s = b.AbsolutePosition, b.AbsoluteSize

        if pos.X >= p.X
            and pos.X <= p.X + s.X
            and pos.Y >= p.Y
            and pos.Y <= p.Y + s.Y then
            return true
        end
    end

    return false
end

-- หาตัวที่จะลาก
local function findTarget(pos)
    local list = playerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
    local fallback

    for _, obj in ipairs(list) do
        if obj:IsA("GuiObject")
            and obj.Visible
            and not tooBig(obj) then

            fallback = fallback or obj
            local cur = obj

            while cur and cur:IsA("GuiObject") do
                if cur:IsA("GuiButton") and not tooBig(cur) then
                    return cur
                end

                cur = cur.Parent
            end
        end
    end

    return fallback
end

local function inLayout(obj)
    local p = obj.Parent
    return p and p:FindFirstChildWhichIsA("UIGridStyleLayout") ~= nil
end

-- ยกปุ่มออกจาก Layout โดยทิ้งตัวแทนล่องหนไว้
local function detach(obj)
    local sg = obj:FindFirstAncestorWhichIsA("ScreenGui")
    if not sg then return false end

    local abs, size = obj.AbsolutePosition, obj.AbsoluteSize

    local ph = Instance.new("Frame")
    ph.Name = "DragPlaceholder"
    ph.BackgroundTransparency = 1
    ph.BorderSizePixel = 0
    ph.Size = UDim2.fromOffset(size.X, size.Y)
    ph.LayoutOrder = obj.LayoutOrder
    ph.Parent = obj.Parent

    local rec = moved[obj]

    if rec then
        rec.placeholder = ph
    else
        moved[obj] = {
            parent = obj.Parent,
            size = obj.Size,
            position = obj.Position,
            layoutOrder = obj.LayoutOrder,
            placeholder = ph,
        }
    end

    obj.Size = UDim2.fromOffset(size.X, size.Y)
    obj.Parent = sg
    obj.Position = UDim2.fromOffset(0, 0)

    local origin = obj.AbsolutePosition
    obj.Position = UDim2.fromOffset(abs.X - origin.X, abs.Y - origin.Y)

    return true
end

local cand, target, dragStart, startPos, activeInput

UIS.InputBegan:Connect(function(input)
    if not editMode or cand then return end

    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local pos = Vector2.new(input.Position.X, input.Position.Y)
    if overMine(pos) then return end

    local t = findTarget(pos)

    if t then
        cand, activeInput, dragStart = t, input, pos
    end
end)

UIS.InputChanged:Connect(function(input)
    if not cand then return end

    if input ~= activeInput
        and input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    local d = Vector2.new(input.Position.X, input.Position.Y) - dragStart

    if not target then
        if d.Magnitude < DRAG_THRESHOLD then return end

        -- เริ่มลากจริง
        if inLayout(cand)
            and (not moved[cand] or moved[cand] == nil) then

            if not detach(cand) then
                cand = nil
                return
            end
        elseif not moved[cand] then
            moved[cand] = {
                parent = cand.Parent,
                size = cand.Size,
                position = cand.Position,
            }
        end

        target = cand
        startPos = target.Position
    end

    target.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + d.X,
        startPos.Y.Scale,
        startPos.Y.Offset + d.Y
    )
end)

UIS.InputEnded:Connect(function(input)
    if input == activeInput
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        cand, target, activeInput = nil, nil, nil
    end
end)

-- ===== PART BUILDER (ปุ่มประแจ) =====
do
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")

    local PANEL_W = 250
    local STEP_SIZE = 0.5
    local STEP_MOVE = 1
    local C_BG = Color3.fromRGB(18, 18, 21)
    local C_ROW = Color3.fromRGB(32, 32, 38)
    local C_TXT = Color3.fromRGB(247, 247, 248)
    local C_DIM = Color3.fromRGB(150, 150, 160)
    local C_ACC = ON_COLOR
    local C_PART = Color3.fromRGB(190, 195, 210)

    local function mk(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        o.Parent = parent
        return o
    end

    local function round(o, r)
        mk("UICorner", {CornerRadius = UDim.new(0, r)}, o)
    end

    local folder = workspace:FindFirstChild("KRYVEX_Parts")
        or mk("Folder", {Name = "KRYVEX_Parts"}, workspace)

    -- ===== แผงเมนู =====
    local toolRight = toolBar.Position.X.Offset + TOOL_WIDTH
    local px = math.clamp(toolRight, PANEL_W + 8, math.max(PANEL_W + 8, viewSize.X - 8))
    local py = toolBar.Position.Y.Offset + SLOT + GAP

    local panel = mk("Frame", {
        Name = "PartPanel",
        Visible = false,
        Active = true,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromOffset(px, py),
        Size = UDim2.fromOffset(PANEL_W, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C_BG,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
    }, gui)
    round(panel, 16)

    local stroke = mk("UIStroke", {
        Thickness = 1.5,
        Transparency = 0.35,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, panel)
    local strokeGrad = mk("UIGradient", {
        Color = ColorSequence.new(Color3.fromRGB(235, 235, 245), Color3.fromRGB(40, 40, 48)),
    }, stroke)

    mk("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }, panel)
    mk("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, panel)
    local scale = mk("UIScale", {Scale = 1}, panel)

    -- ===== หัวเมนู: โมเดล 3D + ข้อความ =====
    local head = mk("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 72),
        LayoutOrder = 1,
    }, panel)

    local vp = mk("ViewportFrame", {
        Size = UDim2.fromOffset(72, 72),
        BackgroundColor3 = C_ROW,
        BorderSizePixel = 0,
        Ambient = Color3.fromRGB(150, 150, 160),
        LightColor = Color3.new(1, 1, 1),
        LightDirection = Vector3.new(-1, -1, -1),
    }, head)
    round(vp, 12)

    local previewPart = mk("Part", {
        Size = Vector3.new(1, 1, 1),
        Color = C_PART,
        Material = Enum.Material.SmoothPlastic,
        Anchored = true,
    }, vp)
    local vcam = mk("Camera", {
        CFrame = CFrame.lookAt(Vector3.new(2.2, 1.6, 2.6), Vector3.zero),
    }, vp)
    vp.CurrentCamera = vcam

    local spawnHit = mk("TextButton", {
        Size = UDim2.fromOffset(72, 72),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
    }, head)

    mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(82, 4),
        Size = UDim2.new(1, -82, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "PART BUILDER",
        TextSize = 15,
        TextColor3 = C_TXT,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, head)
    mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(82, 26),
        Size = UDim2.new(1, -82, 0, 40),
        Font = Enum.Font.Gotham,
        Text = "แตะรูปเพื่อเสก Part ตรงหน้า • แตะตัวเลขเพื่อพิมพ์ค่าเองได้",
        TextSize = 12,
        TextWrapped = true,
        TextColor3 = C_DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, head)

    -- ===== แท็บ ขนาด / ย้าย / เอียง =====
    local tabs = mk("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = 2,
    }, panel)
    mk("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
    }, tabs)

    local function tabBtn(text)
        local b = mk("TextButton", {
            Size = UDim2.new(1 / 3, -4, 1, 0),
            BackgroundColor3 = C_ROW,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            Text = text,
            TextColor3 = C_DIM,
        }, tabs)
        round(b, 10)
        return b
    end
    local tabSize = tabBtn("ขนาด")
    local tabMove = tabBtn("ย้าย")
    local tabRot = tabBtn("เอียง")

    -- ===== สถานะ =====
    local STEP_ROT = 5 -- องศาต่อการกด
    local mode = "size"
    local selected
    local axes = {"X", "Y", "Z"}
    local valueBoxes = {}
    local rowLabels = {}
    local LABELS = {
        size = {"X", "Y", "Z"},
        move = {"X", "Y", "Z"},
        rot = {"เงย", "หมุน", "เอียง"},
    }
    local STEP = {size = STEP_SIZE, move = STEP_MOVE, rot = STEP_ROT}

    local selBox = mk("SelectionBox", {
        LineThickness = 0.04,
        Color3 = C_ACC,
        SurfaceColor3 = C_ACC,
        SurfaceTransparency = 0.85,
    }, gui)

    local function alive()
        return selected ~= nil and selected.Parent ~= nil
    end

    -- มุมเอียงเก็บเป็นองศาไว้ที่ตัว Part (เงย=X, หมุน=Y, เอียงข้าง=Z)
    local function getRot()
        return selected:GetAttribute("rot") or Vector3.zero
    end

    local function getAxis(i)
        local ax = axes[i]
        if mode == "size" then
            return selected.Size[ax]
        elseif mode == "move" then
            return selected.Position[ax]
        end
        return getRot()[ax]
    end

    local function setAxis(i, v)
        if not alive() then return end
        if v ~= v or math.abs(v) > 1e6 then return end

        if mode == "size" then
            local s = selected.Size
            local a = {s.X, s.Y, s.Z}
            a[i] = math.clamp(v, 0.2, 2048)
            selected.Size = Vector3.new(a[1], a[2], a[3])
        elseif mode == "move" then
            local p = selected.Position
            local a = {p.X, p.Y, p.Z}
            a[i] = v
            selected.CFrame = selected.CFrame.Rotation + Vector3.new(a[1], a[2], a[3])
        else
            local r = getRot()
            local a = {r.X, r.Y, r.Z}
            a[i] = ((v + 180) % 360) - 180
            local nr = Vector3.new(a[1], a[2], a[3])
            selected:SetAttribute("rot", nr)
            selected.CFrame = CFrame.new(selected.Position)
                * CFrame.fromEulerAnglesYXZ(math.rad(nr.X), math.rad(nr.Y), math.rad(nr.Z))
        end
    end

    local function refresh()
        for i = 1, 3 do
            rowLabels[i].Text = LABELS[mode][i]
            valueBoxes[i].Text = alive() and string.format("%.1f", getAxis(i)) or "0.0"
        end
    end

    local function selectPart(p)
        selected = p
        selBox.Adornee = p
        refresh()
    end

    local function nudge(i, dir)
        if not alive() then return end
        setAxis(i, getAxis(i) + dir * STEP[mode])
        refresh()
    end

    local function setPartMode(m)
        mode = m
        for key, b in pairs({size = tabSize, move = tabMove, rot = tabRot}) do
            local on = (key == m)
            b.BackgroundColor3 = on and C_ACC or C_ROW
            b.TextColor3 = on and C_BG or C_DIM
        end
        refresh()
    end
    tabSize.MouseButton1Click:Connect(function() setPartMode("size") end)
    tabMove.MouseButton1Click:Connect(function() setPartMode("move") end)
    tabRot.MouseButton1Click:Connect(function() setPartMode("rot") end)

    -- กดค้างเพื่อเพิ่ม/ลดต่อเนื่อง
    local function holdBtn(btn, fn)
        local held, token = false, 0
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                held = true
                token += 1
                local my = token
                fn()
                task.delay(0.35, function()
                    while held and token == my do
                        fn()
                        task.wait(0.06)
                    end
                end)
            end
        end)
        btn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                held = false
            end
        end)
    end

    -- ===== แถว 3 แกน (ปุ่ม - / ช่องพิมพ์เลข / ปุ่ม +) =====
    for i = 1, 3 do
        local row = mk("Frame", {
            BackgroundColor3 = C_ROW,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = 2 + i,
        }, panel)
        round(row, 10)

        rowLabels[i] = mk("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.fromOffset(48, 30),
            Font = Enum.Font.GothamBold,
            Text = axes[i],
            TextSize = 13,
            TextColor3 = C_ACC,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local function stepBtn(text, x)
            local b = mk("TextButton", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, x, 0.5, 0),
                Size = UDim2.fromOffset(44, 22),
                BackgroundColor3 = C_BG,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Font = Enum.Font.GothamBold,
                Text = text,
                TextSize = 16,
                TextColor3 = C_TXT,
            }, row)
            round(b, 8)
            return b
        end

        local minus = stepBtn("-", 62)
        local plus = stepBtn("+", 166)

        -- ช่องพิมพ์เลข: แตะแล้วพิมพ์ค่าที่ต้องการ กด Enter/ปิดคีย์บอร์ดเพื่อใช้ค่า
        local box = mk("TextBox", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 110, 0.5, 0),
            Size = UDim2.fromOffset(52, 22),
            BackgroundColor3 = C_BG,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            Text = "0.0",
            TextSize = 13,
            TextColor3 = C_TXT,
            ClearTextOnFocus = true,
            ClipsDescendants = true,
        }, row)
        round(box, 8)
        valueBoxes[i] = box

        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            if n then setAxis(i, n) end
            refresh()
        end)

        holdBtn(minus, function() nudge(i, -1) end)
        holdBtn(plus, function() nudge(i, 1) end)
    end

    -- ===== ปุ่มล่าง: ลบ / ล้างทั้งหมด =====
    local foot = mk("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = 6,
    }, panel)
    mk("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
    }, foot)

    local function footBtn(text)
        local b = mk("TextButton", {
            Size = UDim2.new(0.5, -3, 1, 0),
            BackgroundColor3 = C_ROW,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 120, 120),
        }, foot)
        round(b, 10)
        return b
    end
    local delBtn = footBtn("ลบอันที่เลือก")
    local clearBtn = footBtn("ล้างทั้งหมด")

    delBtn.MouseButton1Click:Connect(function()
        if alive() then selected:Destroy() end
        local kids = folder:GetChildren()
        selectPart(kids[#kids])
    end)
    clearBtn.MouseButton1Click:Connect(function()
        folder:ClearAllChildren()
        selectPart(nil)
    end)

    -- ===== เสก Part ตรงหน้าตัวละคร =====
    spawnHit.MouseButton1Click:Connect(function()
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local p = Instance.new("Part")
        p.Name = "KRYVEX_Part"
        p.Size = Vector3.new(2, 2, 2)
        p.Color = C_PART
        p.Material = Enum.Material.SmoothPlastic
        p.Anchored = true
        p.Position = hrp.Position + hrp.CFrame.LookVector * 5
        p.Parent = folder
        selectPart(p)
    end)

    -- ===== เปิด/ปิดเมนูด้วยปุ่มประแจ =====
    local previewConn
    local function setPanel(on)
        panel.Visible = on
        toolHighlight.Visible = on
        toolHighlight.BackgroundTransparency = on and 0.75 or 0.92
        setColor(toolIcon, on and ON_COLOR or OFF_COLOR)

        if previewConn then
            previewConn:Disconnect()
            previewConn = nil
        end

        if on then
            scale.Scale = 0.85
            TweenService:Create(
                scale,
                TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Scale = 1}
            ):Play()

            local t0 = os.clock()
            previewConn = RunService.RenderStepped:Connect(function()
                local t = os.clock() - t0
                previewPart.CFrame = CFrame.Angles(t * 0.9, t * 1.3, 0)
                strokeGrad.Rotation = (t * 60) % 360
            end)
        end
    end

    toolHit.MouseButton1Click:Connect(function()
        setPanel(not panel.Visible)
    end)

    setPartMode("size")
end

print(
    "[DragModeBtn] โหลดแล้ว | Lucide:",
    Lucide and "ok" or "ไม่ติด (ใช้อีโมจิ)",
    "| ตำแหน่ง",
    math.floor(posX),
    math.floor(posY)
)
end
__HelloHub_DragModeBlock()
end

--=========================================================
-- ระบบเปลี่ยนธีมท้องฟ้า
-- ต้องมี Window และ OtherTab ประกาศไว้ก่อน
--=========================================================
do
    local Lighting = game:GetService("Lighting")
    local Env = (getgenv and getgenv()) or _G

    -- ปิด/คืนค่าระบบท้องฟ้าจากการรันครั้งก่อน
    if Env.KOMAT_SkyThemes_Stop then
        pcall(Env.KOMAT_SkyThemes_Stop)
    end

    local C = Color3.fromRGB

    local LightingProps = {
        "ClockTime", "Brightness", "Ambient", "OutdoorAmbient",
        "ColorShift_Top", "ColorShift_Bottom", "ExposureCompensation",
        "FogColor", "FogStart", "FogEnd",
        "EnvironmentDiffuseScale", "EnvironmentSpecularScale",
    }

    local AtmosphereProps = {
        "Density", "Offset", "Color", "Decay", "Glare", "Haze",
    }

    local SkyProps = {
        "StarCount", "MoonAngularSize", "SunAngularSize",
        "CelestialBodiesShown",
    }

    local Themes = {
        ["🌌 ราตรีดาวเต็มฟ้า"] = {
            Time = 0,
            Lighting = {
                Brightness = 1,
                Ambient = C(20, 25, 50),
                OutdoorAmbient = C(30, 40, 80),
                ColorShift_Top = C(80, 100, 200),
                ColorShift_Bottom = C(20, 20, 50),
                ExposureCompensation = 0.1,
                FogColor = C(10, 15, 35),
                FogStart = 0,
                FogEnd = 100000,
            },
            Atmo = {
                Density = 0.25, Offset = 0.1,
                Color = C(40, 60, 120), Decay = C(10, 15, 40),
                Glare = 0, Haze = 1,
            },
            CC = {
                Saturation = 0.15, Contrast = 0.1,
                Brightness = 0, TintColor = C(200, 215, 255),
            },
            Bloom = { Intensity = 0.6, Size = 30, Threshold = 1 },
            Sky = {
                StarCount = 6000,
                MoonAngularSize = 14,
                CelestialBodiesShown = true,
            },
        },

        ["🌅 รุ่งอรุณชมพู-ทอง"] = {
            Time = 5.8,
            Lighting = {
                Brightness = 2,
                Ambient = C(140, 110, 120),
                OutdoorAmbient = C(170, 140, 140),
                ColorShift_Top = C(255, 190, 150),
                ColorShift_Bottom = C(255, 170, 190),
                ExposureCompensation = 0.1,
                FogColor = C(255, 205, 170),
                FogStart = 0,
                FogEnd = 100000,
            },
            Atmo = {
                Density = 0.3, Offset = 0.3,
                Color = C(255, 205, 180), Decay = C(255, 160, 170),
                Glare = 0.4, Haze = 1.4,
            },
            CC = {
                Saturation = 0.15, Contrast = 0.05,
                Brightness = 0.02, TintColor = C(255, 235, 225),
            },
            Bloom = { Intensity = 0.4, Size = 24, Threshold = 1.1 },
            Rays = { Intensity = 0.12, Spread = 0.8 },
        },

        ["🌸 Pastel Dreamland"] = {
            Time = 17,
            Lighting = {
                Brightness = 2.2,
                Ambient = C(170, 140, 200),
                OutdoorAmbient = C(190, 160, 220),
                ColorShift_Top = C(220, 170, 255),
                ColorShift_Bottom = C(255, 170, 220),
                ExposureCompensation = 0.2,
                FogColor = C(230, 190, 255),
                FogStart = 0,
                FogEnd = 100000,
            },
            Atmo = {
                Density = 0.35, Offset = 0.2,
                Color = C(230, 190, 255), Decay = C(255, 170, 220),
                Glare = 0.3, Haze = 2,
            },
            CC = {
                Saturation = 0.4, Contrast = -0.05,
                Brightness = 0.05, TintColor = C(255, 235, 255),
            },
            Bloom = { Intensity = 0.6, Size = 40, Threshold = 0.9 },
        },

        ["🌃 Synthwave / Cyberpunk"] = {
            Time = 22,
            Lighting = {
                Brightness = 1.5,
                Ambient = C(90, 40, 140),
                OutdoorAmbient = C(100, 40, 150),
                ColorShift_Top = C(255, 0, 170),
                ColorShift_Bottom = C(0, 200, 255),
                ExposureCompensation = 0.2,
                FogColor = C(80, 20, 120),
                FogStart = 0,
                FogEnd = 100000,
            },
            Atmo = {
                Density = 0.4, Offset = 0.3,
                Color = C(180, 60, 220), Decay = C(255, 0, 150),
                Glare = 1, Haze = 2,
            },
            CC = {
                Saturation = 0.5, Contrast = 0.25,
                Brightness = 0, TintColor = C(255, 200, 255),
            },
            Bloom = { Intensity = 1.2, Size = 40, Threshold = 0.8 },
            Sky = {
                StarCount = 3000,
                MoonAngularSize = 12,
                CelestialBodiesShown = true,
            },
        },

        ["🌫️ หมอกเช้าลึกลับ"] = {
            Time = 6.5,
            Lighting = {
                Brightness = 1.2,
                Ambient = C(90, 105, 100),
                OutdoorAmbient = C(100, 115, 110),
                ColorShift_Top = C(150, 170, 165),
                ColorShift_Bottom = C(80, 95, 95),
                ExposureCompensation = 0,
                FogColor = C(130, 150, 145),
                FogStart = 0,
                FogEnd = 400,
            },
            Atmo = {
                Density = 0.55, Offset = 0,
                Color = C(150, 170, 165), Decay = C(90, 110, 110),
                Glare = 0, Haze = 3,
            },
            CC = {
                Saturation = -0.25, Contrast = 0.1,
                Brightness = 0, TintColor = C(210, 230, 225),
            },
            Bloom = { Intensity = 0.2, Size = 20, Threshold = 1.2 },
        },

        ["🌩️ พายุมืดครึ้ม"] = {
            Time = 14,
            Storm = true,
            Lighting = {
                Brightness = 1,
                Ambient = C(70, 75, 85),
                OutdoorAmbient = C(80, 85, 95),
                ColorShift_Top = C(90, 95, 110),
                ColorShift_Bottom = C(50, 55, 65),
                ExposureCompensation = -0.3,
                FogColor = C(70, 75, 85),
                FogStart = 0,
                FogEnd = 1500,
            },
            Atmo = {
                Density = 0.5, Offset = 0,
                Color = C(100, 105, 115), Decay = C(60, 65, 75),
                Glare = 0, Haze = 3,
            },
            CC = {
                Saturation = -0.3, Contrast = 0.25,
                Brightness = 0, TintColor = C(200, 210, 225),
            },
            Bloom = { Intensity = 0.2, Size = 20, Threshold = 1.2 },
        },

        ["🌈 Golden Hour ทุ่งหญ้า"] = {
            Time = 16.5,
            Lighting = {
                Brightness = 2.6,
                Ambient = C(140, 110, 80),
                OutdoorAmbient = C(170, 140, 100),
                ColorShift_Top = C(255, 200, 110),
                ColorShift_Bottom = C(255, 170, 90),
                ExposureCompensation = 0.15,
                FogColor = C(255, 215, 150),
                FogStart = 0,
                FogEnd = 100000,
            },
            Atmo = {
                Density = 0.28, Offset = 0.3,
                Color = C(255, 210, 140), Decay = C(255, 170, 90),
                Glare = 0.5, Haze = 1.2,
            },
            CC = {
                Saturation = 0.25, Contrast = 0.1,
                Brightness = 0.02, TintColor = C(255, 235, 200),
            },
            Bloom = { Intensity = 0.5, Size = 28, Threshold = 1.1 },
            Rays = { Intensity = 0.2, Spread = 0.85 },
        },

        ["🔴 Blood Moon"] = {
            Time = 0,
            Lighting = {
                Brightness = 1,
                Ambient = C(90, 20, 20),
                OutdoorAmbient = C(110, 25, 25),
                ColorShift_Top = C(180, 20, 20),
                ColorShift_Bottom = C(40, 0, 0),
                ExposureCompensation = 0.1,
                FogColor = C(60, 0, 0),
                FogStart = 0,
                FogEnd = 100000,
            },
            Atmo = {
                Density = 0.35, Offset = 0.1,
                Color = C(160, 20, 20), Decay = C(60, 0, 0),
                Glare = 0, Haze = 1.8,
            },
            CC = {
                Saturation = 0.2, Contrast = 0.2,
                Brightness = 0, TintColor = C(255, 170, 170),
            },
            Bloom = { Intensity = 0.6, Size = 30, Threshold = 1 },
            Sky = {
                StarCount = 2500,
                MoonAngularSize = 40,
                CelestialBodiesShown = true,
            },
        },
    }

    local ThemeOrder = {
        "🌌 ราตรีดาวเต็มฟ้า",
        "🌅 รุ่งอรุณชมพู-ทอง",
        "🌸 Pastel Dreamland",
        "🌃 Synthwave / Cyberpunk",
        "🌫️ หมอกเช้าลึกลับ",
        "🌩️ พายุมืดครึ้ม",
        "🌈 Golden Hour ทุ่งหญ้า",
        "🔴 Blood Moon",
    }

    local function Snapshot(Object, Properties)
        if not Object then
            return nil
        end

        local Values = {}
        for _, Property in ipairs(Properties) do
            local OK, Value = pcall(function()
                return Object[Property]
            end)
            if OK then
                Values[Property] = Value
            end
        end
        return Values
    end

    local function ApplyProperties(Object, Values)
        if not Object or not Values then
            return
        end

        for Property, Value in pairs(Values) do
            pcall(function()
                Object[Property] = Value
            end)
        end
    end

    local SavedLighting
    local OriginalAtmosphere
    local SavedAtmosphere
    local OriginalSky
    local SavedSky
    local OwnAtmosphere
    local OwnSky
    local CreatedEffects = {}
    local ThemeToken = 0
    local SelectedTheme = ThemeOrder[1]

    local function SaveOriginal()
        if SavedLighting then
            return
        end

        SavedLighting = Snapshot(Lighting, LightingProps)
        OriginalAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        SavedAtmosphere = Snapshot(OriginalAtmosphere, AtmosphereProps)
        OriginalSky = Lighting:FindFirstChildOfClass("Sky")
        SavedSky = Snapshot(OriginalSky, SkyProps)
    end

    local function ClearEffects()
        ThemeToken = ThemeToken + 1

        for _, Effect in ipairs(CreatedEffects) do
            pcall(function()
                Effect:Destroy()
            end)
        end

        table.clear(CreatedEffects)
    end

    local function RemoveOwnedObjects()
        if OwnAtmosphere then
            pcall(function()
                OwnAtmosphere:Destroy()
            end)
            OwnAtmosphere = nil
        end

        if OwnSky then
            pcall(function()
                OwnSky:Destroy()
            end)
            OwnSky = nil
        end
    end

    local function RestoreBase()
        ApplyProperties(Lighting, SavedLighting)

        if OriginalAtmosphere and OriginalAtmosphere.Parent then
            ApplyProperties(OriginalAtmosphere, SavedAtmosphere)
        end

        if OriginalSky and OriginalSky.Parent then
            ApplyProperties(OriginalSky, SavedSky)
        end
    end

    local function AddEffect(ClassName, Name, Properties)
        local Effect = Instance.new(ClassName)
        Effect.Name = Name
        ApplyProperties(Effect, Properties)
        Effect.Parent = Lighting
        table.insert(CreatedEffects, Effect)
    end

    local function ResetTheme()
        ClearEffects()
        RemoveOwnedObjects()
        RestoreBase()
    end

    local function ApplyTheme(Theme)
        if not Theme then
            return
        end

        SaveOriginal()
        ResetTheme()

        ApplyProperties(Lighting, Theme.Lighting)
        Lighting.ClockTime = Theme.Time

        local Atmosphere = OriginalAtmosphere
        if not Atmosphere or not Atmosphere.Parent then
            Atmosphere = Instance.new("Atmosphere")
            Atmosphere.Name = "KRYVEX_SkyAtmosphere"
            Atmosphere.Parent = Lighting
            OwnAtmosphere = Atmosphere
        end
        ApplyProperties(Atmosphere, Theme.Atmo)

        if Theme.Sky then
            local Sky = OriginalSky
            if not Sky or not Sky.Parent then
                Sky = Instance.new("Sky")
                Sky.Name = "KRYVEX_Sky"
                Sky.Parent = Lighting
                OwnSky = Sky
            end
            ApplyProperties(Sky, Theme.Sky)
        end

        if Theme.CC then
            AddEffect("ColorCorrectionEffect", "KRYVEX_SkyCC", Theme.CC)
        end

        if Theme.Bloom then
            AddEffect("BloomEffect", "KRYVEX_SkyBloom", Theme.Bloom)
        end

        if Theme.Rays then
            AddEffect("SunRaysEffect", "KRYVEX_SkyRays", Theme.Rays)
        end

        local Token = ThemeToken
        task.spawn(function()
            while Token == ThemeToken do
                task.wait(0.5)
                if Token == ThemeToken then
                    Lighting.ClockTime = Theme.Time
                end
            end
        end)

        if Theme.Storm then
            task.spawn(function()
                local Brightness = Theme.Lighting.Brightness or Lighting.Brightness
                local Exposure = Theme.Lighting.ExposureCompensation
                    or Lighting.ExposureCompensation

                while Token == ThemeToken do
                    task.wait(math.random(3, 9))
                    if Token ~= ThemeToken then
                        break
                    end

                    Lighting.Brightness = 5
                    Lighting.ExposureCompensation = 1
                    task.wait(0.05)

                    if Token == ThemeToken then
                        Lighting.Brightness = Brightness
                        Lighting.ExposureCompensation = Exposure
                    end
                end
            end)
        end
    end

    local function RestoreOriginal()
        ResetTheme()

        SavedLighting = nil
        OriginalAtmosphere = nil
        SavedAtmosphere = nil
        OriginalSky = nil
        SavedSky = nil
    end

    Env.KOMAT_SkyThemes_Stop = RestoreOriginal


    OtherTab:AddDropdown({
        Name = "เลือกธีมท้องฟ้า",
        Options = ThemeOrder,
        Default = ThemeOrder[1],
        Callback = function(Value)
            if type(Value) == "table" then
                Value = Value[1]
            end

            if Themes[Value] then
                SelectedTheme = Value
            end
        end,
    })

    OtherTab:AddButton({
        Name = "ตกลง (เปลี่ยนท้องฟ้า)",
        Callback = function()
            local Theme = Themes[SelectedTheme]
            if not Theme then
                return
            end

            ApplyTheme(Theme)

            Window:Notify({
                Title = "HelloHub",
                Content = "เปลี่ยนเป็น " .. SelectedTheme .. " แล้ว",
                Duration = 3,
            })
        end,
    })

    OtherTab:AddButton({
        Name = "คืนค่าท้องฟ้าเดิม",
        Callback = function()
            RestoreOriginal()

            Window:Notify({
                Title = "HelloHub",
                Content = "คืนค่าท้องฟ้าเดิมแล้ว",
                Duration = 3,
            })
        end,
    })
end

--=========================================================
-- HelloHub | MAP SCALE + TELEPORT ON PART
-- ไม่รวมระบบโหลดแมพ 4 ปุ่ม
--=========================================================
do
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local Tab = MapTab

    if not Tab then
        warn("[HelloHub MAP] ไม่พบ MapTab กรุณาสร้างแท็บแมพก่อน")
        return
    end

    local MapScale = 2
    local MapScaleEnabled = false
    local MapTarget = nil
    local MapParts = {}
    local MapOriginal = {}
    local MapCenter = Vector3.zero

    local function Notify(Message)
        pcall(function()
            Window:Notify({
                Title = "HelloHub MAP",
                Content = Message,
                Duration = 3,
            })
        end)
    end

    local function FindMap()
        local GameFolder = Workspace:FindFirstChild("Game")
        local Map = GameFolder and GameFolder:FindFirstChild("Map")

        return Map or Workspace:FindFirstChild("Map", true)
    end

    local function RestoreMap()
        for Part, Original in pairs(MapOriginal) do
            if Part and Part.Parent then
                pcall(function()
                    Part.Size = Original.Size
                    Part.CFrame = Original.CFrame
                end)
            end
        end
    end

    local function CaptureMap()
        -- คืนขนาดเดิมก่อนเก็บค่าต้นฉบับชุดใหม่
        RestoreMap()

        MapTarget = FindMap()
        MapParts = {}
        MapOriginal = {}

        if not MapTarget then
            return false, "ไม่พบ Instance ชื่อ Map"
        end

        for _, Object in ipairs(MapTarget:GetDescendants()) do
            if Object:IsA("BasePart") then
                MapParts[#MapParts + 1] = Object
                MapOriginal[Object] = {
                    Size = Object.Size,
                    CFrame = Object.CFrame,
                }
            end
        end

        if #MapParts == 0 then
            return false, "ไม่พบชิ้นส่วนภายใน Map"
        end

        local PositionSum = Vector3.zero
        for _, Part in ipairs(MapParts) do
            PositionSum += Part.Position
        end
        MapCenter = PositionSum / #MapParts

        return true
    end

    local function ApplyMapScale(Scale)
        if not MapTarget or not MapTarget.Parent then
            local Success, Message = CaptureMap()
            if not Success then
                Notify(Message)
                return false
            end
        end

        local Updated = 0

        for _, Part in ipairs(MapParts) do
            local Original = MapOriginal[Part]

            if Part.Parent and Original then
                local Success = pcall(function()
                    local Offset = Original.CFrame.Position - MapCenter
                    local NewPosition = MapCenter + Offset * Scale
                    local Rotation = Original.CFrame - Original.CFrame.Position

                    Part.Size = Original.Size * Scale
                    Part.CFrame = CFrame.new(NewPosition) * Rotation
                end)

                if Success then
                    Updated += 1
                    if Updated % 300 == 0 then
                        task.wait()
                    end
                end
            end
        end

        return Updated > 0
    end

    local function TeleportOnMapPart()
        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")

        if not Character or not Root then
            Notify("ไม่พบตัวละคร")
            return false
        end

        if not MapTarget or not MapTarget.Parent then
            Notify("ไม่พบแมพ กรุณาเปิดระบบขยายแมพก่อน")
            return false
        end

        local BestPosition = nil
        local BestDistance = math.huge

        for _, Part in ipairs(MapParts) do
            if Part.Parent and Part:IsA("BasePart")
                and Part.Size.X >= 4 and Part.Size.Z >= 4 then

                -- คำนวณตำแหน่งบน Part ใน local space เพื่อรองรับ Part ที่หมุนอยู่
                local LocalPosition = Part.CFrame:PointToObjectSpace(Root.Position)
                local HalfSize = Part.Size / 2

                local LocalTarget = Vector3.new(
                    math.clamp(LocalPosition.X, -HalfSize.X + 2, HalfSize.X - 2),
                    HalfSize.Y + 5,
                    math.clamp(LocalPosition.Z, -HalfSize.Z + 2, HalfSize.Z - 2)
                )

                local WorldTarget = Part.CFrame:PointToWorldSpace(LocalTarget)
                local Distance = (WorldTarget - Root.Position).Magnitude

                if Distance < BestDistance then
                    BestDistance = Distance
                    BestPosition = WorldTarget
                end
            end
        end

        if not BestPosition then
            Notify("หา Part สำหรับวาร์ปไม่เจอ")
            return false
        end

        Character:PivotTo(CFrame.new(BestPosition))
        return true
    end


    Tab:AddToggle({
        Name = "เปิดใช้งานขยายแมพ",
        Default = false,
        Callback = function(Value)
            if Value then
                local Success, Message = CaptureMap()
                if not Success then
                    Notify(Message)
                    return
                end

                MapScaleEnabled = true

                if ApplyMapScale(MapScale) then
                    task.wait(0.2)
                    if TeleportOnMapPart() then
                        Notify("ขยายแมพ x" .. tostring(MapScale) .. " และวาร์ปขึ้นบน Part แล้ว")
                    end
                else
                    MapScaleEnabled = false
                    Notify("ขยายแมพไม่สำเร็จ")
                end
            else
                MapScaleEnabled = false
                RestoreMap()
                Notify("คืนขนาดแมพเดิมแล้ว")
            end
        end,
    })

    Tab:AddSlider({
        Name = "ขนาดแมพ",
        Min = 1,
        Max = 5,
        Default = 2,
        Increment = 0.5,
        Callback = function(Value)
            MapScale = tonumber(Value) or 2

            if MapScaleEnabled then
                ApplyMapScale(MapScale)
            end
        end,
    })

    Tab:AddButton({
        Name = "คืนขนาดแมพเดิม",
        Callback = function()
            MapScaleEnabled = false
            RestoreMap()
            Notify("คืนขนาดแมพเดิมแล้ว")
        end,
    })

    Tab:AddButton({
        Name = "วาร์ปไปบน Part",
        Callback = function()
            if TeleportOnMapPart() then
                Notify("วาร์ปไปบน Part สำเร็จ")
            end
        end,
    })
end

--=========================================================
-- HelloHub | FARM TIME + ANTI-AFK
-- ต้องมี Window และ FarmTab ประกาศไว้ก่อน
--=========================================================
do
    local farmPlayers = game:GetService("Players")
    local farmPlayer = farmPlayers.LocalPlayer

    local farmEnabled = false
    local farmGuardThread = nil
    local farmCharacterConnection = nil
    local farmPlatform = nil
    local farmOriginCFrame = nil
    local farmPlatformCFrame = nil
    local farmToken = 0

    local FARM_HEIGHT = 1200
    local FARM_IMAGE_ID = "rbxassetid://72855254938167"

    local function FarmNotify(text)
        pcall(function()
            Window:Notify({
                Title = "HelloHub",
                Content = text,
                Duration = 3,
            })
        end)
    end

    local function GetFarmRoot(character)
        character = character or farmPlayer.Character
        if not character then
            return nil
        end
        return character:FindFirstChild("HumanoidRootPart")
    end

    local function CreateFarmPlatform(platformCFrame)
        if farmPlatform then
            farmPlatform:Destroy()
            farmPlatform = nil
        end

        local part = Instance.new("Part")
        part.Name = "KRYVEX_FarmTimePart"
        part.Size = Vector3.new(12, 1, 12)
        part.CFrame = platformCFrame
        part.Anchored = true
        part.CanCollide = true
        part.CanTouch = false
        part.CanQuery = false
        part.CastShadow = false
        part.Material = Enum.Material.SmoothPlastic
        part.Color = Color3.fromRGB(235, 235, 235)
        part.Transparency = 0.05
        part.Parent = workspace

        local image = Instance.new("Decal")
        image.Name = "KRYVEX_FarmPlatformImage"
        image.Texture = FARM_IMAGE_ID
        image.Face = Enum.NormalId.Top
        image.Transparency = 0
        image.Parent = part

        farmPlatform = part
    end

    local function MoveCharacterToFarm(character)
        if not farmPlatformCFrame then
            return false
        end

        local root = GetFarmRoot(character)
        if not root then
            return false
        end

        root.CFrame = farmPlatformCFrame + Vector3.new(0, 4, 0)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        return true
    end

    local function StopFarmTime(restorePosition)
        farmEnabled = false
        farmToken += 1

        if farmGuardThread then
            pcall(task.cancel, farmGuardThread)
            farmGuardThread = nil
        end

        if farmCharacterConnection then
            farmCharacterConnection:Disconnect()
            farmCharacterConnection = nil
        end

        if farmPlatform then
            farmPlatform:Destroy()
            farmPlatform = nil
        end

        if restorePosition and farmOriginCFrame then
            local root = GetFarmRoot()
            if root then
                root.CFrame = farmOriginCFrame
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end

        farmOriginCFrame = nil
        farmPlatformCFrame = nil
    end

    local function StartFarmTime()
        local character = farmPlayer.Character
        local root = GetFarmRoot(character)

        if not root then
            FarmNotify("ยังไม่พบตัวละคร ลองเปิดอีกครั้งหลังเกิดใหม่")
            return false
        end

        if farmEnabled then
            return true
        end

        farmEnabled = true
        farmOriginCFrame = root.CFrame
        farmPlatformCFrame = farmOriginCFrame + Vector3.new(0, FARM_HEIGHT, 0)

        CreateFarmPlatform(farmPlatformCFrame)
        MoveCharacterToFarm(character)

        farmToken += 1
        local myToken = farmToken

        -- ตรวจทุกครึ่งวินาที แทนการย้ายตัวละครทุกเฟรม
        farmGuardThread = task.spawn(function()
            while farmEnabled and myToken == farmToken do
                local currentCharacter = farmPlayer.Character
                local currentRoot = GetFarmRoot(currentCharacter)

                if currentRoot and farmPlatformCFrame then
                    local safePosition =
                        farmPlatformCFrame.Position + Vector3.new(0, 4, 0)

                    if (currentRoot.Position - safePosition).Magnitude > 18 then
                        MoveCharacterToFarm(currentCharacter)
                    end
                end

                task.wait(0.5)
            end
        end)

        farmCharacterConnection = farmPlayer.CharacterAdded:Connect(function(characterAdded)
            task.delay(0.6, function()
                if farmEnabled and characterAdded == farmPlayer.Character then
                    MoveCharacterToFarm(characterAdded)
                end
            end)
        end)

        return true
    end


    FarmTab:AddToggle({
        Name = "ฟาร์มเวล",
        Default = false,
        Callback = function(value)
            if value then
                if StartFarmTime() then
                    FarmNotify("เปิดฟาร์มเวลาแล้ว")
                end
            else
                StopFarmTime(true)
                FarmNotify("ปิดฟาร์มเวลาและคืนตำแหน่งเดิมแล้ว")
            end
        end,
    })

    local antiAfkEnabled = false
local antiAfkConnection = nil
local antiAfkBusy = false

local function SetAntiAfk(value)
    -- ป้องกันการเชื่อมต่อซ้ำ หาก UI เรียก Callback ตอนเริ่มต้น
    if value and antiAfkEnabled and antiAfkConnection then
        return
    end

    antiAfkEnabled = value

    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end

    if not value then
        FarmNotify("ปิดกันโดนเตะแล้ว")
        return
    end

    local connected, connectionOrError = pcall(function()
        return farmPlayer.Idled:Connect(function()
            if not antiAfkEnabled or antiAfkBusy then
                return
            end

            antiAfkBusy = true
            pcall(function()
                local virtualUser = game:GetService("VirtualUser")
                local camera = workspace.CurrentCamera
                local cameraCFrame = camera and camera.CFrame or CFrame.new()

                virtualUser:Button2Down(Vector2.new(0, 0), cameraCFrame)
                task.wait(1)
                virtualUser:Button2Up(Vector2.new(0, 0), cameraCFrame)
            end)
            antiAfkBusy = false
        end)
    end)

    if connected then
        antiAfkConnection = connectionOrError
        FarmNotify("เปิดกันโดนเตะแล้ว")
    else
        antiAfkEnabled = false
        FarmNotify("เชื่อมต่อระบบ AFK ไม่สำเร็จ")
        warn("[HelloHub Anti-AFK]", connectionOrError)
    end
end


FarmTab:AddToggle({
    Name = "กันโดนเตะ",
    Default = true,
    Callback = function(value)
        SetAntiAfk(value)
    end,
})

-- เปิดระบบทันทีตอนรันสคริปต์
SetAntiAfk(true)
end

--=========================================================
-- ออโต้ฟาร์มอีเว้นท์ + ออโต้วาร์ปไปหา NPC อีเว้นท์
-- ใช้ FarmTab และ Window ที่ประกาศไว้แล้ว
--=========================================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local Env = (getgenv and getgenv()) or _G
    local LocalPlayer = Players.LocalPlayer

    -- รันซ้ำ = เก็บกวาดของเก่าก่อน
    if Env.KOMAT_EventFarm_Stop then
        pcall(Env.KOMAT_EventFarm_Stop)
    end

    -- ===== ตั้งค่า =====
    local PART_HEIGHT = 1000
    local PART_SIZE = Vector3.new(60, 2, 60)
    local PART_IMAGE = "rbxassetid://72855254938167"
    local UNDER_OFFSET = 6                     -- ลึกใต้ Visual กี่ studs
    local NPC_WORD = "cat"                     -- ต้องเป็น "ทั้งคำ" (Cat, CatNPC, Event_Cat) ไม่ใช่ Indicator
    local NPC_OFFSET = Vector3.new(0, 0, 0)    -- ระยะเยื้องจากตัว NPC
    local MIN_NPC_Y = -100                     -- ข้ามโมเดลที่อยู่ต่ำกว่านี้ (ของซ่อนใต้แมพ)
    -- ===================

    local FarmOn, NpcOn = false, false
    local FarmToggle, NpcToggle
    local FarmPart, CurrentVisual, CatNpc
    local CatSeen = false
    local CurrentMode = nil
    local ReturnCF, Moved = nil, false
    local WasActive = false
    local NoclipSaved = {}
    local NpcSet = {}
    local LastNpcScan = 0
    local LastVisualScan, LastVisualEmpty = 0, false
    local HbConn, StConn, ScanConn

    local Refresh, FinishNpc

    local function Notify(text)
        pcall(function()
            Window:Notify({Title = "HelloHub", Content = text, Duration = 3})
        end)
    end

    -- พยายามสั่งปิดสวิตช์ในฮับ (ไม่รู้ว่าไลบรารีมีเมธอดไหน ลองหลายแบบ)
    local function SetToggleVisual(toggle, value)
        if type(toggle) ~= "table" then return end
        for _, method in ipairs({"Set", "SetValue", "SetState", "Update"}) do
            if type(toggle[method]) == "function" then
                pcall(toggle[method], toggle, value)
                return
            end
        end
    end

    local function GetChar()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        return char, root, hum
    end

    ------------------------------------------------------------
    -- Part บนฟ้า (ใส่รูปไอดี 72855254938167)
    ------------------------------------------------------------
    local function EnsurePart()
        if FarmPart and FarmPart.Parent then return FarmPart end

        local _, root = GetChar()
        local base = root and root.Position or Vector3.zero

        local p = Instance.new("Part")
        p.Name = "KRYVEX_EventPart"
        p.Size = PART_SIZE
        p.Anchored = true
        p.CanCollide = true
        p.Material = Enum.Material.SmoothPlastic
        p.Color = Color3.fromRGB(60, 60, 70)
        p.CFrame = CFrame.new(base.X, PART_HEIGHT, base.Z)
        p.Parent = Workspace

        for _, face in ipairs({Enum.NormalId.Top, Enum.NormalId.Bottom}) do
            local d = Instance.new("Decal")
            d.Face = face
            d.Texture = PART_IMAGE
            d.Parent = p
        end

        FarmPart = p
        return p
    end

    local function DestroyPart()
        if FarmPart then
            pcall(function() FarmPart:Destroy() end)
            FarmPart = nil
        end
    end

    ------------------------------------------------------------
    -- Visual (workspace.Effects.Tickets.Visual)
    ------------------------------------------------------------
    local function GetTickets()
        local effects = Workspace:FindFirstChild("Effects")
        return effects and effects:FindFirstChild("Tickets")
    end

    local function ObjectPos(obj)
        if not obj or not obj.Parent then return nil end
        if obj:IsA("Model") then
            local ok, cf = pcall(obj.GetPivot, obj)
            return ok and cf.Position or nil
        elseif obj:IsA("BasePart") then
            return obj.Position
        end
        return nil
    end

    local function GetVisual()
        local tickets = GetTickets()
        if not tickets then
            CurrentVisual = nil
            return nil
        end

        -- ยังอยู่ก็ล็อกตัวเดิมต่อ ไม่สลับไปมา
        if CurrentVisual and CurrentVisual.Parent and CurrentVisual:IsDescendantOf(tickets) then
            return CurrentVisual
        end
        CurrentVisual = nil

        local now = os.clock()
        if LastVisualEmpty and now - LastVisualScan < 0.1 then
            return nil
        end
        LastVisualScan = now
        LastVisualEmpty = true

        for _, child in ipairs(tickets:GetChildren()) do
            if child.Name == "Visual" and ObjectPos(child) then
                CurrentVisual = child
                LastVisualEmpty = false
                return child
            end
        end
        return nil
    end

    ------------------------------------------------------------
    -- NPC ชื่อมีคำว่า cat (เช็ก "ทั้งคำ" กันไปจับ Indicator/Location)
    ------------------------------------------------------------
    local function NameHasWord(name)
        -- แยกคำจาก camelCase: CatNPC → "Cat NPC", NPCCat → "NPC Cat"
        local spaced = string.gsub(name, "(%l)(%u)", "%1 %2")
        spaced = string.gsub(spaced, "(%u)(%u%l)", "%1 %2")
        spaced = string.gsub(spaced, "[^%a]", " ")   -- ตัวเลข/_/-/. เป็นตัวคั่น
        for word in string.gmatch(spaced, "%S+") do
            local w = string.lower(word)
            if w == NPC_WORD or w == NPC_WORD .. "s" then
                return true
            end
        end
        return false
    end

    local function IsCat(inst)
        if not inst:IsA("Model") then return false end
        if not NameHasWord(inst.Name) then return false end
        if Players:GetPlayerFromCharacter(inst) then return false end
        if LocalPlayer.Character and inst:IsDescendantOf(LocalPlayer.Character) then return false end
        return inst:FindFirstChildWhichIsA("BasePart", true) ~= nil
    end

    local function FullNpcScan()
        LastNpcScan = os.clock()
        for _, d in ipairs(Workspace:GetDescendants()) do
            if IsCat(d) then NpcSet[d] = true end
        end
    end

    local function StartNpcScan()
        table.clear(NpcSet)
        CatNpc, CatSeen = nil, false
        FullNpcScan()
        if ScanConn then ScanConn:Disconnect() end
        ScanConn = Workspace.DescendantAdded:Connect(function(d)
            if IsCat(d) then NpcSet[d] = true end
        end)
    end

    local function StopNpcScan()
        if ScanConn then ScanConn:Disconnect() ScanConn = nil end
        table.clear(NpcSet)
        CatNpc, CatSeen = nil, false
    end

    local function GetCat()
        if CatNpc and not (CatNpc.Parent and CatNpc:IsDescendantOf(Workspace)) then
            CatNpc = nil
            if CatSeen then
                FinishNpc() -- NPC หายแล้ว → หยุดระบบ
                return nil
            end
        end
        if CatNpc then return CatNpc end

        -- เลือกตัวที่ดีที่สุด: มี Humanoid ก่อน, ข้ามที่อยู่ใต้แมพ
        local best, bestScore
        for model in pairs(NpcSet) do
            if model.Parent and model:IsDescendantOf(Workspace) then
                local pos = ObjectPos(model)
                if pos and pos.Y >= MIN_NPC_Y then
                    local score = model:FindFirstChildOfClass("Humanoid") and 2 or 1
                    if not bestScore or score > bestScore then
                        best, bestScore = model, score
                    end
                end
            else
                NpcSet[model] = nil
            end
        end

        if best then
            CatNpc, CatSeen = best, true
            print("[HelloHub] เจอ NPC:", best:GetFullName())
            Notify("เจอ NPC: " .. best.Name)
            return best
        end

        -- กันชื่อที่เปลี่ยนทีหลัง สแกนซ้ำทุก 5 วิ ตอนยังไม่เจอ
        if os.clock() - LastNpcScan > 5 then FullNpcScan() end
        return nil
    end

    ------------------------------------------------------------
    -- ล็อกตัว + ทะลุ
    ------------------------------------------------------------
    local function SetNoclip(on)
        if on then
            local char = GetChar()
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    if NoclipSaved[p] == nil then NoclipSaved[p] = p.CanCollide end
                    p.CanCollide = false
                end
            end
        else
            for p, v in pairs(NoclipSaved) do
                if p.Parent then p.CanCollide = v end
            end
            table.clear(NoclipSaved)
        end
    end

    local function ReturnToGround()
        SetNoclip(false)
        local _, root, hum = GetChar()
        if Moved and ReturnCF and root and hum and hum.Health > 0 then
            root.CFrame = ReturnCF
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        Moved = false
    end

    -- ตัดสินใจว่าตอนนี้ต้องไปไหน (NPC > Visual > Part)
    local function Decide()
        if NpcOn then
            local npc = GetCat()
            if npc then
                local pos = ObjectPos(npc)
                if pos then
                    return "npc", CFrame.new(pos + NPC_OFFSET)
                end
            end
        end

        if FarmOn then
            local visual = GetVisual()
            if visual then
                local pos = ObjectPos(visual)
                if pos then
                    return "visual", CFrame.new(pos - Vector3.new(0, UNDER_OFFSET, 0))
                end
            end
            local part = EnsurePart()
            return "part", part.CFrame * CFrame.new(0, PART_SIZE.Y / 2 + 3, 0)
        end

        return nil
    end

    local function Disconnect()
        if HbConn then HbConn:Disconnect() HbConn = nil end
        if StConn then StConn:Disconnect() StConn = nil end
    end

    Refresh = function()
        local active = FarmOn or NpcOn

        if active and not WasActive then
            local _, root = GetChar()
            ReturnCF = root and root.CFrame or ReturnCF
            Moved = false
            Disconnect()

            -- ทะลุก่อนฟิสิกส์ทำงาน
            StConn = RunService.Stepped:Connect(function()
                if CurrentMode and CurrentMode ~= "part" then
                    SetNoclip(true)
                elseif next(NoclipSaved) then
                    SetNoclip(false)
                end
            end)

            -- ล็อกตำแหน่งทุกเฟรม (ตายแล้วเกิดใหม่ก็ถูกดึงกลับเอง)
            HbConn = RunService.Heartbeat:Connect(function()
                local mode, cf = Decide()
                CurrentMode = mode
                if not mode then return end

                local _, root, hum = GetChar()
                if not (root and hum and hum.Health > 0) then return end

                root.CFrame = cf
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                Moved = true
            end)

        elseif not active and WasActive then
            Disconnect()
            CurrentMode = nil
            CurrentVisual = nil
            DestroyPart()
            StopNpcScan()
            ReturnToGround()
        end

        WasActive = active
    end

    FinishNpc = function()
        if not NpcOn then return end
        NpcOn = false
        StopNpcScan()
        SetToggleVisual(NpcToggle, false)
        Notify("NPC หายแล้ว หยุดวาร์ปไปหา NPC")
        Refresh()
    end

    local function SetFarm(value)
        if FarmOn == value then return end
        FarmOn = value
        CurrentVisual = nil

        if not value then
            -- ถ้ายังมีระบบ NPC เปิดอยู่แต่ตัวละครไม่ได้อยู่ที่ NPC ให้กลับพื้นก่อน
            if NpcOn and CurrentMode ~= "npc" then
                ReturnToGround()
            end
            DestroyPart()
        end

        Refresh()
        Notify(value and "เปิดออโต้ฟาร์มอีเว้นท์" or "ปิดออโต้ฟาร์มอีเว้นท์")
    end

    local function SetNpc(value)
        if NpcOn == value then return end
        NpcOn = value

        if value then
            StartNpcScan()
        else
            StopNpcScan()
            if FarmOn and CurrentMode == "npc" then
                CurrentMode = nil -- เฟรมถัดไปจะกลับไปฟาร์มเอง
            end
        end

        Refresh()
        Notify(value and "เปิดออโต้วาร์ปไปหา NPC อีเว้นท์" or "ปิดออโต้วาร์ปไปหา NPC อีเว้นท์")
    end

    ------------------------------------------------------------
    -- ปุ่มในฮับ
    ------------------------------------------------------------

    FarmToggle = EventTab:AddToggle({
        Name = "ออโต้ฟาร์มอีเว้นท์",
        Default = false,
        Callback = function(Value)
            SetFarm(Value and true or false)
        end,
    })

    NpcToggle = EventTab:AddToggle({
        Name = "ออโต้วาร์ปไปหา NPC อีเว้นท์",
        Default = false,
        Callback = function(Value)
            SetNpc(Value and true or false)
        end,
    })

    -- เก็บกวาดตอนรันซ้ำ
    Env.KOMAT_EventFarm_Stop = function()
        FarmOn, NpcOn = false, false
        Refresh()
        DestroyPart()
        StopNpcScan()
    end
end

--=========================================================
-- มองหาโทเทม + มองหา NPC อีเว้นท์ (ESP กล่องสีฟ้า + เส้น + ชื่อ + ระยะ)
-- ใช้ FarmTab และ Window ที่ประกาศไว้แล้ว
--=========================================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")
    local Env = (getgenv and getgenv()) or _G
    local lp = Players.LocalPlayer
    local cam = Workspace.CurrentCamera

    -- รันซ้ำ = เก็บกวาดของเก่าก่อน
    if Env.KRYVEX_EventESP_Stop then pcall(Env.KRYVEX_EventESP_Stop) end

    -- ===== ตั้งค่า =====
    local BLUE = Color3.fromRGB(60, 140, 255)
    local BOX_TRANSPARENCY = 0.5
    local LINE_THICKNESS = 2
    local VISUAL_NAME = "Visual"    -- โทเทม = workspace.Effects.Tickets.Visual
    local NPC_WORDS = {"cat"}       -- ทั้งคำ (Cat, CatNPC, Event_Cat)
    local POLL_VISUAL = 0.25        -- วินาที ความถี่เช็ก Visual ใหม่
    local RESCAN_EVERY = 5          -- วินาที สแกนซ้ำหา NPC
    -- ===================

    local function Notify(text)
        pcall(function()
            Window:Notify({Title = "HelloHub", Content = text, Duration = 3})
        end)
    end

    local function getParent()
        if gethui then
            local ok, h = pcall(gethui)
            if ok and h then return h end
        end
        if pcall(function() return CoreGui.Name end) then return CoreGui end
        return lp:WaitForChild("PlayerGui")
    end

    local parent = getParent()
    local old = parent:FindFirstChild("KRYVEX_EventESP")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "KRYVEX_EventESP"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.Parent = parent

    local lineHolder = Instance.new("Folder", gui)
    local boxHolder = Instance.new("Folder", gui)
    local labelHolder = Instance.new("Folder", gui)

    local function drawLine(line, top, target)
        local diff = target - top
        line.Size = UDim2.fromOffset(diff.Magnitude, LINE_THICKNESS)
        line.Position = UDim2.fromOffset((top.X + target.X) / 2, (top.Y + target.Y) / 2)
        line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
        line.Visible = true
    end

    ------------------------------------------------------------
    -- ตัวสร้าง ESP
    -- opts.finder = ฟังก์ชันคืนลิสต์วัตถุ (โหมดโพลล์)
    -- opts.words  = คำที่ต้องมีในชื่อโมเดล (โหมดสแกนทั้งแมพ)
    ------------------------------------------------------------
    local function newESP(opts)
        local M = {enabled = false, items = {}, lastScan = 0, scanning = false, addConn = nil}

        local wordSet = {}
        for _, w in ipairs(opts.words or {}) do
            wordSet[string.lower(w)] = true
            wordSet[string.lower(w) .. "s"] = true
        end

        local function nameHasWord(name)
            local spaced = string.gsub(name, "(%l)(%u)", "%1 %2")
            spaced = string.gsub(spaced, "(%u)(%u%l)", "%1 %2")
            spaced = string.gsub(spaced, "[^%a]", " ")
            for word in string.gmatch(spaced, "%S+") do
                if wordSet[string.lower(word)] then return true end
            end
            return false
        end

        local function isMatch(inst)
            if not inst:IsA("Model") then return false end
            if not nameHasWord(inst.Name) then return false end
            if Players:GetPlayerFromCharacter(inst) then return false end
            if lp.Character and inst:IsDescendantOf(lp.Character) then return false end
            return inst:FindFirstChildWhichIsA("BasePart", true) ~= nil
        end

        local function removeObj(m)
            local it = M.items[m]
            if it then
                it.box:Destroy()
                it.line:Destroy()
                it.label:Destroy()
                M.items[m] = nil
            end
        end

        local function addObj(m)
            if M.items[m] then return end

            local p = m.Parent
            while p and p ~= Workspace do
                if M.items[p] then return end
                p = p.Parent
            end
            for other in pairs(M.items) do
                if other:IsDescendantOf(m) then removeObj(other) end
            end

            local box = Instance.new("BoxHandleAdornment")
            box.Color3 = BLUE
            box.Transparency = BOX_TRANSPARENCY
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Visible = false
            box.Parent = boxHolder

            local line = Instance.new("Frame")
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.BackgroundColor3 = BLUE
            line.BorderSizePixel = 0
            line.Visible = false
            line.Parent = lineHolder

            local label = Instance.new("TextLabel")
            label.AnchorPoint = Vector2.new(0.5, 1)
            label.Size = UDim2.fromOffset(220, 36)
            label.BackgroundTransparency = 1
            label.TextColor3 = BLUE
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.new(0, 0, 0)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextYAlignment = Enum.TextYAlignment.Bottom
            label.Visible = false
            label.Parent = labelHolder

            M.items[m] = {box = box, line = line, label = label, adornee = nil}
        end

        local function scan()
            if M.scanning then return end
            M.scanning = true
            M.lastScan = os.clock()
            task.spawn(function()
                local list = Workspace:GetDescendants()
                for i, d in ipairs(list) do
                    if not M.enabled then break end
                    if isMatch(d) then addObj(d) end
                    if i % 3000 == 0 then task.wait() end
                end
                M.scanning = false
            end)
        end

        function M.start()
            if M.enabled then return end
            M.enabled = true
            if opts.finder then
                M.lastScan = 0
            else
                scan()
                M.addConn = Workspace.DescendantAdded:Connect(function(d)
                    if isMatch(d) then addObj(d) end
                end)
            end
        end

        function M.stop()
            M.enabled = false
            if M.addConn then M.addConn:Disconnect() M.addConn = nil end
            for m in pairs(M.items) do removeObj(m) end
        end

        function M.render(top, myPos)
            if not M.enabled then return end

            local now = os.clock()
            if opts.finder then
                if now - M.lastScan >= POLL_VISUAL then
                    M.lastScan = now
                    for _, inst in ipairs(opts.finder()) do addObj(inst) end
                end
            elseif now - M.lastScan > RESCAN_EVERY then
                scan()
            end

            for obj, it in pairs(M.items) do
                if not obj.Parent or not obj:IsDescendantOf(Workspace) then
                    removeObj(obj)
                else
                    local ok, cf, size, ad
                    if obj:IsA("Model") then
                        ok, cf, size = pcall(obj.GetBoundingBox, obj)
                        if not it.adornee or not it.adornee:IsDescendantOf(obj) then
                            it.adornee = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                        end
                        ad = it.adornee
                    else
                        ok, cf, size = true, obj.CFrame, obj.Size
                        ad = obj
                    end

                    if ok and ad then
                        it.box.Adornee = ad
                        it.box.Size = size
                        it.box.CFrame = ad.CFrame:ToObjectSpace(cf)
                        it.box.Visible = true

                        local pos, onScreen = cam:WorldToViewportPoint(cf.Position)
                        if onScreen and pos.Z > 0 then
                            drawLine(it.line, top, Vector2.new(pos.X, pos.Y))

                            local above = cam:WorldToViewportPoint(cf.Position + Vector3.new(0, size.Y / 2 + 1, 0))
                            local dist = myPos and math.floor((cf.Position - myPos).Magnitude) or nil
                            it.label.Text = obj.Name .. "\n" .. (dist and (dist .. " studs") or "?")
                            it.label.Position = UDim2.fromOffset(above.X, above.Y)
                            it.label.Visible = true
                        else
                            it.line.Visible = false
                            it.label.Visible = false
                        end
                    end
                end
            end
        end

        return M
    end

    -- โทเทม = workspace.Effects.Tickets.Visual
    local function findVisuals()
        local out = {}
        local effects = Workspace:FindFirstChild("Effects")
        local tickets = effects and effects:FindFirstChild("Tickets")
        if tickets then
            for _, c in ipairs(tickets:GetChildren()) do
                if c.Name == VISUAL_NAME and (c:IsA("Model") or c:IsA("BasePart")) then
                    out[#out + 1] = c
                end
            end
        end
        return out
    end

    local totemESP = newESP({finder = findVisuals})
    local npcESP = newESP({words = NPC_WORDS})

    -- ลูปวาด
    local conn = RunService.RenderStepped:Connect(function()
        if not (totemESP.enabled or npcESP.enabled) then return end
        cam = Workspace.CurrentCamera
        if not cam then return end

        local top = Vector2.new(cam.ViewportSize.X / 2, 0)
        local char = lp.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        local myPos = myRoot and myRoot.Position

        totemESP.render(top, myPos)
        npcESP.render(top, myPos)
    end)

    ------------------------------------------------------------
    -- สวิตช์ในฮับ
    ------------------------------------------------------------

    EventTab:AddToggle({
        Name = "มองหาโทเทม",
        Default = false,
        Callback = function(Value)
            if Value then totemESP.start() else totemESP.stop() end
            Notify(Value and "เปิดมองหาโทเทม" or "ปิดมองหาโทเทม")
        end,
    })

    EventTab:AddToggle({
        Name = "มองหา NPC อีเว้นท์",
        Default = false,
        Callback = function(Value)
            if Value then npcESP.start() else npcESP.stop() end
            Notify(Value and "เปิดมองหา NPC อีเว้นท์" or "ปิดมองหา NPC อีเว้นท์")
        end,
    })

    -- เก็บกวาดตอนรันซ้ำ
    Env.KRYVEX_EventESP_Stop = function()
        pcall(totemESP.stop)
        pcall(npcESP.stop)
        pcall(function() conn:Disconnect() end)
        pcall(function() gui:Destroy() end)
    end
end



--=====================================================
-- HelloHub | AUTO EMOTE CLICKER
-- WITH CROUCH BUTTON
--=====================================================

do

    local EmoteNames = {
        "Emote1",
        "Emote2",
        "Emote3",
        "Emote4",
        "Emote5",
        "Emote6"
    }

    local SelectedEmote = "Emote1"
    local EmoteFloatingHandle = nil
    local EmoteBusy = false

    --=================================================
    -- GET CROUCH BUTTON
    --=================================================

    local function GetCrouchButton()

        local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not PlayerGui then return nil end

        local Game = PlayerGui:FindFirstChild("Game")
        local HUD = Game and Game:FindFirstChild("HUD")
        local Mobile = HUD and HUD:FindFirstChild("Mobile")
        local Right = Mobile and Mobile:FindFirstChild("Right")
        local MobileButtons = Right and Right:FindFirstChild("Mobile")

        local Button = MobileButtons
            and MobileButtons:FindFirstChild("CrouchButton")

        if Button and Button:IsA("GuiButton") then
            return Button
        end

        return nil
    end

    --=================================================
    -- GET SELECTED EMOTE BUTTON
    --=================================================

    local function GetSelectedEmoteButton()

        local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not PlayerGui then return nil end

        local Game = PlayerGui:FindFirstChild("Game")
        local HUD = Game and Game:FindFirstChild("HUD")
        local Interactors = HUD and HUD:FindFirstChild("Interactors")
        local Popups = Interactors and Interactors:FindFirstChild("Popups")
        local Emote = Popups and Popups:FindFirstChild("Emote")
        local Wheel = Emote and Emote:FindFirstChild("Wheel")
        local Slot = Wheel and Wheel:FindFirstChild(SelectedEmote)

        local Button = Slot and Slot:FindFirstChild("Button")

        if Button and Button:IsA("GuiButton") then
            return Button
        end

        return nil
    end

    --=================================================
    -- FIRE GUI BUTTON
    --=================================================

    local function FireButton(Button)

        if not Button or not Button:IsA("GuiButton") then
            return false
        end

        local Success = pcall(function()
            firesignal(Button.Activated)
        end)

        if Success then
            return true
        end

        Success = pcall(function()
            firesignal(Button.MouseButton1Click)
        end)

        return Success
    end

    --=================================================
    -- AUTO EMOTE FUNCTION
    --=================================================

    local function ClickSelectedEmote()

        if EmoteBusy then
            return
        end

        EmoteBusy = true

        task.spawn(function()

            -- STEP 1 : CROUCH

            local CrouchButton = GetCrouchButton()

            if not CrouchButton then

                Window:Notify({
                    Title = "HelloHub",
                    Content = "ไม่พบ CrouchButton",
                    Duration = 3
                })

                EmoteBusy = false
                return
            end

            local CrouchSuccess = FireButton(CrouchButton)

            if not CrouchSuccess then

                Window:Notify({
                    Title = "HelloHub",
                    Content = "ไม่สามารถกด CrouchButton ได้",
                    Duration = 3
                })

                EmoteBusy = false
                return
            end

            -- STEP 2 : WAIT

            task.wait(0.15)

            -- STEP 3 : EMOTE

            local EmoteButton = GetSelectedEmoteButton()

            if not EmoteButton then

                Window:Notify({
                    Title = "HelloHub",
                    Content = SelectedEmote .. " ไม่พบปุ่มอีโมท",
                    Duration = 3
                })

                EmoteBusy = false
                return
            end

            local EmoteSuccess = FireButton(EmoteButton)

            if EmoteSuccess then

                Window:Notify({
                    Title = "HelloHub",
                    Content = "กด " .. SelectedEmote .. " สำเร็จ",
                    Duration = 2
                })

            else

                Window:Notify({
                    Title = "HelloHub",
                    Content = "ไม่สามารถกดอีโมทได้",
                    Duration = 3
                })

            end

            EmoteBusy = false

        end)

    end

    --=================================================
    -- EMOTE DROPDOWN
    --=================================================

    MainTab:AddDropdown({

        Name = "เลือกช่องอีโมท",

        Options = EmoteNames,

        Default = "Emote1",

        Callback = function(Value)

            local Option = Value

            if typeof(Value) == "table" then
                Option = Value[1]
            end

            if typeof(Option) ~= "string" then
                return
            end

            if not table.find(EmoteNames, Option) then
                return
            end

            SelectedEmote = Option

            Window:Notify({
                Title = "HelloHub",
                Content = "เลือก " .. Option .. " แล้ว",
                Duration = 2
            })

        end

    })

    --=================================================
    -- MAIN EMOTE BUTTON
    --=================================================

    MainTab:AddButton({

        Name = "กดอีโมทอัตโนมัติ",

        Callback = function()

            ClickSelectedEmote()

        end

    })

    --=================================================
    -- FLOATING EMOTE BUTTON TOGGLE
    --=================================================

    MainTab:AddToggle({

        Name = "กดอีโมทอัตโนมัติ(ปุ่มลอย)",

        Default = false,

        Callback = function(Value)

            if Value then

                if EmoteFloatingHandle then
                    EmoteFloatingHandle:Destroy()
                    EmoteFloatingHandle = nil
                end

                EmoteFloatingHandle = CreateFloatingButton({

                    Name = "กดอีโมท",

                    Mode = "Button",

                    Callback = function()

                        ClickSelectedEmote()

                    end

                })

                Window:Notify({
                    Title = "HelloHub",
                    Content = "เปิดปุ่มลอยกดอีโมทแล้ว",
                    Duration = 3
                })

            else

                if EmoteFloatingHandle then
                    EmoteFloatingHandle:Destroy()
                    EmoteFloatingHandle = nil
                end

                RemoveFloatingButton("กดอีโมท")

                Window:Notify({
                    Title = "HelloHub",
                    Content = "ปิดปุ่มลอยกดอีโมทแล้ว",
                    Duration = 3
                })

            end

        end

    })

end

--=====================================================
-- END HelloHub AUTO EMOTE CLICKER
--=====================================================

--=====================================================
-- HelloHub | ปรับความเร็วอีโมท (SpeedMult) เริ่มต้น 100
-- วางต่อท้ายสุดของสคริปต์ (หลังปุ่ม "ปุ่มใหม่")
--=====================================================

do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Env = getgenv()

    local EmoteSpeed = 100
    local EMOTE_MULT = 0.005
    local EmoteModules = {}
    local EmoteSeen = {}

    -- รันซ้ำ = loop เก่าหยุดเอง
    Env.KRYVEX_EmoteSpeedGen = (Env.KRYVEX_EmoteSpeedGen or 0) + 1
    local MyGen = Env.KRYVEX_EmoteSpeedGen

    local function checkModule(mod)
        local ok, data = pcall(require, mod)
        if not ok or type(data) ~= "table" then return end

        local has = type(data.SpeedMult) == "number"
            or (type(data.EmoteInfo) == "table"
                and type(data.EmoteInfo.SpeedMult) == "number")

        if has then
            table.insert(EmoteModules, data)
        end
    end

    local function scanEmoteModules()
        local containers = {
            ReplicatedStorage,
            LocalPlayer:FindFirstChild("PlayerGui"),
            LocalPlayer:FindFirstChild("Backpack"),
        }

        for _, container in ipairs(containers) do
            if container then
                for _, d in ipairs(container:GetDescendants()) do
                    if d:IsA("ModuleScript") and not EmoteSeen[d] then
                        EmoteSeen[d] = true
                        task.spawn(checkModule, d)
                    end
                end
            end
        end
    end

    local function applyEmoteSpeed()
        local target = safe(EmoteSpeed) * EMOTE_MULT

        for _, data in ipairs(EmoteModules) do
            pcall(function()
                if type(data.SpeedMult) == "number"
                    and data.SpeedMult ~= target then
                    data.SpeedMult = target
                end

                if type(data.EmoteInfo) == "table"
                    and type(data.EmoteInfo.SpeedMult) == "number"
                    and data.EmoteInfo.SpeedMult ~= target then
                    data.EmoteInfo.SpeedMult = target
                end
            end)
        end
    end

    SettingsTab:AddInput({
        Name = "ปรับความเร็วอีโมท",
        Placeholder = "ใส่ตัวเลข",
        Default = tostring(EmoteSpeed),

        Callback = function(Value)
            local Number = tonumber(Value)

            if Number then
                EmoteSpeed = safe(Number)
                scanEmoteModules()
                applyEmoteSpeed()
            end
        end
    })

    -- สแกนหาโมดูลอีโมท (ครั้งแรก + ทุก 5 วิ)
    task.spawn(function()
        while Env.KRYVEX_EmoteSpeedGen == MyGen do
            scanEmoteModules()
            task.wait(5)
        end
    end)

    -- ปรับค่าซ้ำทุก 1 วิ ตามสวิตช์ "ปรับค่าอัตโนมัติ"
    task.spawn(function()
        while Env.KRYVEX_EmoteSpeedGen == MyGen do
            if Env.AutoApplySettings then
                applyEmoteSpeed()
            end
            task.wait(1)
        end
    end)
end

--=================================================
-- HelloHub | EMPTY BUTTON
--========================================

SettingsTab:AddButton({
    Name = "ปุ่มใหม่",
    Callback = function()
        -- ไม่มีการทำงาน
    end
})

do
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local LocalPlayer = Players.LocalPlayer

    local CARRY_RANGE = 8
    local SCAN_INTERVAL = 0.25
    local CARRY_COOLDOWN = 1.5

    local AutoCarryEnabled = false
    local CarryGeneration = 0
    local LastCarryTime = 0
    local AutoCarryFloatingHandle = nil
    local RescueFloatingHandle = nil

    -- ใช้ล็อกร่วมกันทั้ง 5 คอนโทรล
    local AttemptedTargets = setmetatable({}, { __mode = "k" })

    -- ค้นหาแบบไม่รอค้าง ถ้าเกมเปลี่ยน path UI ก็ยังสร้างต่อได้
    local function GetInteractRemote()
        local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local CharacterRemotes = Remotes and Remotes:FindFirstChild("Character")
        local Interact = CharacterRemotes and CharacterRemotes:FindFirstChild("Interact")

        if Interact and Interact:IsA("RemoteEvent") then
            return Interact
        end

        return nil
    end

    local function GetRoot(Model)
        return Model:FindFirstChild("HumanoidRootPart", true)
            or Model.PrimaryPart
    end

    local function GetHumanoid(Model)
        return Model:FindFirstChildWhichIsA("Humanoid", true)
    end

    local function GetTag(Model)
        local Tag = Model:GetAttribute("Tag")
            or Model:GetAttribute("ID")
            or Model.Name

        return tonumber(Tag) or Tag
    end

    local function CleanupAttemptedTargets()
        for Model in pairs(AttemptedTargets) do
            if not Model.Parent then
                AttemptedTargets[Model] = nil
            else
                local Humanoid = GetHumanoid(Model)
                if Humanoid and Humanoid.Health > 0 then
                    AttemptedTargets[Model] = nil
                end
            end
        end
    end

    local function TryCarryOnce(Target, Tag)
        CleanupAttemptedTargets()

        if not Target or AttemptedTargets[Target] then
            return false, "already-attempted"
        end

        local Humanoid = GetHumanoid(Target)
        if not Humanoid or Humanoid.Health > 0 then
            return false, "not-downed"
        end

        local Remote = GetInteractRemote()
        if not Remote then
            return false, "remote-not-found"
        end

        Tag = Tag or GetTag(Target)
        if Tag == nil or Tag == "" then
            return false, "missing-tag"
        end

        -- ล็อกก่อนส่ง ป้องกันคำสั่งซ้ำที่อาจกลายเป็นปล่อย
        AttemptedTargets[Target] = true

        local Sent, ErrorMessage = pcall(function()
            Remote:FireServer("Carry", Tag)
        end)

        if not Sent then
            AttemptedTargets[Target] = nil
            warn("[HelloHub Carry]", ErrorMessage)
            return false, "send-failed"
        end

        return true, "sent"
    end

    local function FindDownedTargets(MaxDistance, Origin)
        CleanupAttemptedTargets()

        local Folder = workspace:FindFirstChild("Players")
        local Character = LocalPlayer.Character
        local MyRoot = Origin or (Character and GetRoot(Character))

        if not Folder or not MyRoot then
            return {}
        end

        local Targets = {}

        for _, Model in ipairs(Folder:GetChildren()) do
            if Model:IsA("Model")
                and Model ~= Character
                and Model.Name ~= LocalPlayer.Name
                and not AttemptedTargets[Model] then

                local Humanoid = GetHumanoid(Model)
                local Root = GetRoot(Model)
                local Tag = GetTag(Model)

                if Humanoid and Root and Tag and Humanoid.Health <= 0 then
                    local Distance = (MyRoot.Position - Root.Position).Magnitude

                    if not MaxDistance or Distance <= MaxDistance then
                        table.insert(Targets, {
                            Model = Model,
                            Humanoid = Humanoid,
                            Root = Root,
                            Tag = Tag,
                            Distance = Distance,
                        })
                    end
                end
            end
        end

        table.sort(Targets, function(A, B)
            return A.Distance < B.Distance
        end)

        return Targets
    end

    local function SetAutoCarry(Value)
        if AutoCarryEnabled == Value then
            return
        end

        AutoCarryEnabled = Value
        CarryGeneration += 1
        local MyGeneration = CarryGeneration

        if not Value then
            return
        end

        task.spawn(function()
            while AutoCarryEnabled and MyGeneration == CarryGeneration do
                if os.clock() - LastCarryTime >= CARRY_COOLDOWN then
                    local Targets = FindDownedTargets(CARRY_RANGE)
                    local Target = Targets[1]

                    if Target then
                        LastCarryTime = os.clock()
                        TryCarryOnce(Target.Model, Target.Tag)
                    end
                end

                task.wait(SCAN_INTERVAL)
            end
        end)
    end

    local function TeleportToNearestDowned()
        local Character = LocalPlayer.Character
        local Root = Character and GetRoot(Character)

        if not Character or not Root then
            return
        end

        local Targets = FindDownedTargets(nil, Root)
        local Target = Targets[1]

        if not Target then
            Window:Notify({
                Title = "HelloHub",
                Content = "ไม่พบเป้าหมายใหม่ที่ยังไม่ได้สั่งอุ้ม",
                Duration = 3,
            })
            return
        end

        local OriginalCFrame = Root.CFrame
        Root.CFrame = Target.Root.CFrame
        task.wait(0.2)

        TryCarryOnce(Target.Model, Target.Tag)
        task.wait(1)

        if LocalPlayer.Character == Character and Root.Parent then
            Root.CFrame = OriginalCFrame
        end
    end

    local function RescueDownedPlayers()
        local Character = LocalPlayer.Character
        local Root = Character and GetRoot(Character)

        if not Character or not Root then
            return
        end

        local OriginalCFrame = Root.CFrame
        local Targets = FindDownedTargets(nil, Root)

        if #Targets == 0 then
            Window:Notify({
                Title = "HelloHub",
                Content = "ไม่พบเป้าหมายใหม่ที่ยังไม่ได้สั่งอุ้ม",
                Duration = 3,
            })
            return
        end

        for _, Info in ipairs(Targets) do
            if LocalPlayer.Character ~= Character then
                break
            end

            if Info.Model.Parent
                and Info.Humanoid.Parent
                and Info.Humanoid.Health <= 0
                and not AttemptedTargets[Info.Model] then

                Root.CFrame = Info.Root.CFrame * CFrame.new(0, 0, 3)
                task.wait(0.2)

                local Sent = TryCarryOnce(Info.Model, Info.Tag)
                if Sent then
                    break
                end
            end
        end

        if LocalPlayer.Character == Character and Root.Parent then
            Root.CFrame = OriginalCFrame
        end
    end

    -- 1) ออโต้อุ้มในเมนู
    MainTab:AddToggle({
        Name = "ออโต้อุ้ม",
        Default = false,
        Callback = function(Value)
            SetAutoCarry(Value)
        end,
    })

    -- 2) ตัวเลือกเปิดปุ่มลอยออโต้อุ้ม
    MainTab:AddToggle({
        Name = "ออโต้อุ้ม (ปุ่มลอย)",
        Default = false,
        Callback = function(Value)
            if Value then
                if AutoCarryFloatingHandle then
                    AutoCarryFloatingHandle:Destroy()
                end

                AutoCarryFloatingHandle = CreateFloatingButton({
                    Name = "ออโต้อุ้ม",
                    Mode = "Toggle",
                    OnText = "เปิด",
                    OffText = "ปิด",
                    Callback = function(Active)
                        SetAutoCarry(Active)
                    end,
                })
            else
                if AutoCarryFloatingHandle then
                    AutoCarryFloatingHandle:Destroy()
                    AutoCarryFloatingHandle = nil
                end

                if RemoveFloatingButton then
                    RemoveFloatingButton("ออโต้อุ้ม")
                end

                SetAutoCarry(false)
            end
        end,
    })

    -- 3) วาร์ปไปหาผู้เล่นล้ม 1 วินาที
    TeleportTab:AddButton({
        Name = "วาร์ปไปหาผู้เล่นล้ม 1s",
        Callback = TeleportToNearestDowned,
    })

    -- 4) วาร์ปไปเก็บผู้เล่นที่ล้ม
    TeleportTab:AddButton({
        Name = "วาร์ปไปเก็บผู้เล่นที่ล้ม",
        Callback = RescueDownedPlayers,
    })

    -- 5) ตัวเลือกเปิดปุ่มลอยช่วยผู้เล่นที่ล้ม
    TeleportTab:AddToggle({
        Name = "ช่วยผู้เล่นที่ล้ม (ปุ่มลอย)",
        Default = false,
        Callback = function(Value)
            if Value then
                if RescueFloatingHandle then
                    RescueFloatingHandle:Destroy()
                end

                RescueFloatingHandle = CreateFloatingButton({
                    Name = "ช่วยคนล้ม",
                    Mode = "Button",
                    OnText = "ช่วยคนล้ม",
                    OffText = "ช่วยคนล้ม",
                    Callback = RescueDownedPlayers,
                })
            else
                if RescueFloatingHandle then
                    RescueFloatingHandle:Destroy()
                    RescueFloatingHandle = nil
                end

                if RemoveFloatingButton then
                    RemoveFloatingButton("ช่วยคนล้ม")
                end
            end
        end,
    })
end

do
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Player = Players.LocalPlayer
    local AutoRespawnEnabled = false
    local RespawnMode = "สปาวปกติ"
    local RespawnDelay = 3
    local SavedRespawnCFrame = nil
    local PendingExternalRestoreCFrame = nil

    local RespawnToken = 0
    local ProcessedCharacters = setmetatable({}, { __mode = "k" })
    local CharacterConnections = setmetatable({}, { __mode = "k" })

    -- ส่งคำสั่งเกิดใหม่ตามตัวอย่างที่มึงให้
    local function SendRespawnRequest()
        local Success, ErrorMessage = pcall(function()
            local args = {
                true
            }

            HelloHubUtil.RemoteProxy(
                ReplicatedStorage,
                { "Remotes", "Session", "SetPlayerMode" },
                3
            ):FireServer(unpack(args))
        end)

        if not Success then
            return false, ErrorMessage
        end

        return true
    end

    local function IsMenuVisible()
        local PlayerGui = Player:FindFirstChildOfClass("PlayerGui")

        return PlayerGui == nil
            or PlayerGui:FindFirstChild("Game") == nil
    end

    -- ส่ง Ragdoll signal ถ้า Remote นี้มีอยู่
    local function SendRagdollSignal()
        local Events = ReplicatedStorage:FindFirstChild("Events")
        local Remote = Events
            and Events:FindFirstChild("UpdateCharacterDataRegistry")

        if not Remote then
            return
        end

        pcall(function()
            local args = {
                {
                    buffer.fromstring("\015\000"),
                    "Ragdolling"
                }
            }

            Remote:FireServer(unpack(args))
        end)
    end

    local function RestoreSavedPosition(Character)
        local ExternalTargetCFrame = PendingExternalRestoreCFrame
        local IsExternalRestore = ExternalTargetCFrame ~= nil

        if not IsExternalRestore
            and (not AutoRespawnEnabled
                or RespawnMode ~= "สปาวจุดเดิม"
                or not SavedRespawnCFrame) then
            return
        end

        local TargetCFrame = ExternalTargetCFrame or SavedRespawnCFrame
        if IsExternalRestore then
            PendingExternalRestoreCFrame = nil
        end

        RespawnToken += 1
        local MyToken = RespawnToken

        task.spawn(function()
            local Humanoid = Character:WaitForChild("Humanoid", 10)
            local Root = Character:WaitForChild("HumanoidRootPart", 10)

            if not Humanoid or not Root then
                return
            end

            local function IsCancelled()
                if MyToken ~= RespawnToken or Character ~= Player.Character then
                    return true
                end
                if not IsExternalRestore
                    and (not AutoRespawnEnabled or RespawnMode ~= "สปาวจุดเดิม") then
                    return true
                end
                return false
            end

            local Deadline = os.clock() + 10
            while os.clock() < Deadline do
                if IsCancelled() then
                    return
                end

                if Humanoid.Health > 0 and not IsMenuVisible() then
                    break
                end

                task.wait(0.1)
            end

            if IsCancelled()
                or Humanoid.Health <= 0
                or IsMenuVisible() then
                return
            end

            for _ = 1, 10 do
                if IsCancelled() or Humanoid.Health <= 0 then
                    break
                end

                Root.CFrame = TargetCFrame
                task.wait(0.15)

                if (Root.Position - TargetCFrame.Position).Magnitude < 5 then
                    break
                end
            end
        end)
    end

    local function SendSpeedModeWithReturnPosition()
        local Character = Player.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        if not Root then
            return false, "ไม่พบ HumanoidRootPart สำหรับบันทึกจุดเดิม"
        end

        SavedRespawnCFrame = Root.CFrame
        PendingExternalRestoreCFrame = SavedRespawnCFrame

        local Success, ErrorMessage = SendRespawnRequest()
        if not Success then
            PendingExternalRestoreCFrame = nil
            return false, ErrorMessage
        end

        return true
    end

    getgenv().KRYVEX_SendSpeedModeWithReturnPosition = SendSpeedModeWithReturnPosition

    local function HandleDeath(Character, Humanoid)
        if not AutoRespawnEnabled
            or ProcessedCharacters[Character]
            or Humanoid.Health > 0 then
            return
        end

        ProcessedCharacters[Character] = true

        if RespawnMode == "สปาวจุดเดิม" then
            local Root = Character:FindFirstChild("HumanoidRootPart")

            if Root then
                SavedRespawnCFrame = Root.CFrame
            end
        end

        SendRagdollSignal()

        task.delay(RespawnDelay, function()
            if not AutoRespawnEnabled
                or Player.Character ~= Character
                or not Humanoid.Parent
                or Humanoid.Health > 0
                or IsMenuVisible() then
                return
            end

            local Success, ErrorMessage = SendRespawnRequest()

            if not Success then
                warn("[HelloHub Auto Respawn]", ErrorMessage)

                Window:Notify({
                    Title = "HelloHub",
                    Content = "ส่งสัญญาณเกิดใหม่ไม่สำเร็จ",
                    Duration = 3,
                })
            end
        end)
    end

    local function WatchCharacter(Character)
        task.spawn(function()
            local Humanoid = Character:WaitForChild("Humanoid", 10)

            if not Humanoid then
                return
            end

            local OldConnection = CharacterConnections[Character]

            if OldConnection then
                OldConnection:Disconnect()
            end

            CharacterConnections[Character] =
                Humanoid.HealthChanged:Connect(function(Health)
                    if Health <= 0 then
                        HandleDeath(Character, Humanoid)
                    end
                end)

            if Humanoid.Health <= 0 then
                HandleDeath(Character, Humanoid)
            end
        end)
    end

    Player.CharacterAdded:Connect(function(Character)
        WatchCharacter(Character)
        RestoreSavedPosition(Character)
    end)

    if Player.Character then
        WatchCharacter(Player.Character)
    end

    MainTab:AddDropdown({
        Name = "เลือกการสปาว",
        Options = {
            "สปาวปกติ",
            "สปาวจุดเดิม",
        },
        Default = "สปาวปกติ",

        Callback = function(Value)
            if typeof(Value) == "table" then
                Value = Value[1]
            end

            if typeof(Value) == "string" then
                RespawnMode = Value
            end
        end,
    })

    MainTab:AddToggle({
        Name = "ออโต้รีสปาว",
        Default = false,

        Callback = function(Value)
            AutoRespawnEnabled = Value

            if not Value then
                RespawnToken += 1
            else
                local Character = Player.Character
                local Humanoid = Character
                    and Character:FindFirstChildOfClass("Humanoid")

                if Humanoid and Humanoid.Health <= 0 then
                    HandleDeath(Character, Humanoid)
                end
            end

            Window:Notify({
                Title = "HelloHub",
                Content = Value
                    and ("เปิดออโต้รีสปาว | " .. RespawnMode)
                    or "ปิดออโต้รีสปาว",
                Duration = 3,
            })
        end,
    })

    MainTab:AddButton({
        Name = "เกิดใหม่",
        Description = "ส่งคำสั่งเกิดใหม่",

        Callback = function()
            local Success, ErrorMessage = SendRespawnRequest()

            if Success then
                Window:Notify({
                    Title = "HelloHub",
                    Content = "ส่งคำสั่งเกิดใหม่แล้ว",
                    Duration = 3,
                })
            else
                warn("[HelloHub Respawn]", ErrorMessage)

                Window:Notify({
                    Title = "HelloHub",
                    Content = "ส่งคำสั่งไม่สำเร็จ ตรวจสอบ Console",
                    Duration = 3,
                })
            end
        end,
    })
end

do
    local WallSlideEnv = getgenv()

    if type(WallSlideEnv.KRYVEX_WallSlideCleanup) == "function" then
        pcall(WallSlideEnv.KRYVEX_WallSlideCleanup)
    end

    if _G.__WallSlideConn then
        pcall(function()
            _G.__WallSlideConn:Disconnect()
        end)
        _G.__WallSlideConn = nil
    end

    pcall(function()
        local guiRoot = (gethui and gethui()) or game:GetService("CoreGui")
        local oldWallGui = guiRoot:FindFirstChild("WallSlideGui")
        if oldWallGui then
            oldWallGui:Destroy()
        end
    end)

    local ATTACH_DIST = 2.8
    local HOLD_DIST = 1.6
    local MAX_SLOPE = 0.3
    local SPEED_MULT = 1
    local JUMP_OFF = 40
    local RECOVER_T = 0.35

    local Enabled = false
    local Stuck = false
    local WallNormal = Vector3.new(0, 0, 1)
    local LastTangent = Vector3.new(1, 0, 0)

    local Character
    local Humanoid
    local RootPart

    local RecoverConnection
    local HeartbeatConnection
    local JumpConnection
    local CharacterAddedConnection
    local Alive = true
    local CharacterGeneration = 0

    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.IgnoreWater = true

    local function DisconnectRecover()
        if RecoverConnection then
            pcall(function()
                RecoverConnection:Disconnect()
            end)
            RecoverConnection = nil
        end
    end

    local function CameraFlat()
        local camera = workspace.CurrentCamera
        local look = camera and camera.CFrame.LookVector

        if look then
            local flat = Vector3.new(look.X, 0, look.Z)
            if flat.Magnitude > 0.01 then
                return flat.Unit
            end
        end

        if RootPart then
            local look = RootPart.CFrame.LookVector
            local flat = Vector3.new(look.X, 0, look.Z)

            if flat.Magnitude > 0.01 then
                return flat.Unit
            end
        end

        return Vector3.new(0, 0, -1)
    end

    local function IsFirstPerson()
        if LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
            return true
        end

        local camera = workspace.CurrentCamera
        local head = Character and Character:FindFirstChild("Head")

        if camera and head then
            return (camera.CFrame.Position - head.Position).Magnitude < 4
        end

        return false
    end

    local function FixCamera()
        local camera = workspace.CurrentCamera

        if Humanoid and camera and camera.CameraSubject ~= Humanoid then
            camera.CameraSubject = Humanoid
        end
    end

    local function SetUpright()
        if not RootPart or not RootPart.Parent then
            return
        end

        RootPart.CFrame = CFrame.lookAt(
            RootPart.Position,
            RootPart.Position + CameraFlat()
        )
        RootPart.AssemblyAngularVelocity = Vector3.zero
    end

    local function Detach(push, recover)
        if not Stuck then
            return
        end

        Stuck = false

        local root = RootPart
        local humanoid = Humanoid

        if humanoid and humanoid.Parent then
            humanoid.PlatformStand = false
            humanoid.Sit = false
        end

        if root and root.Parent then
            SetUpright()

            if humanoid then
                pcall(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end

            root.AssemblyLinearVelocity = push
                and (WallNormal * JUMP_OFF + Vector3.new(0, 25, 0))
                or (WallNormal * 8)
        end

        FixCamera()
        DisconnectRecover()

        if recover == false then
            return
        end

        local startedAt = os.clock()

        RecoverConnection = RunService.Heartbeat:Connect(function()
            if Stuck
                or not root
                or not root.Parent
                or os.clock() - startedAt > RECOVER_T then

                DisconnectRecover()
                return
            end

            root.AssemblyAngularVelocity = Vector3.zero

            local position = root.Position
            root.CFrame = CFrame.lookAt(
                position,
                position + CameraFlat()
            )

            FixCamera()
        end)
    end

    local function IsWall(result)
        return result and math.abs(result.Normal.Y) < MAX_SLOPE
    end

    local function FlatUnit(vector)
        local flat = Vector3.new(vector.X, 0, vector.Z)
        return flat.Magnitude > 0.01 and flat.Unit or nil
    end

    local function Step(deltaTime)
        if not Alive
            or not Enabled
            or not (Character and Humanoid and RootPart)
            or not Humanoid.Parent
            or Humanoid.Health <= 0 then
            return
        end

        RayParams.FilterDescendantsInstances = { Character }

        local moveDirection = Humanoid.MoveDirection
        local flatMove = Vector3.new(
            moveDirection.X,
            0,
            moveDirection.Z
        )

        if not Stuck then
            if flatMove.Magnitude < 0.1 then
                return
            end

            local result = workspace:Raycast(
                RootPart.Position,
                flatMove.Unit * ATTACH_DIST,
                RayParams
            )

            if IsWall(result) then
                local normal = FlatUnit(result.Normal)

                if normal then
                    DisconnectRecover()
                    Stuck = true
                    WallNormal = normal
                    Humanoid.PlatformStand = true
                end
            end

            return
        end

        if flatMove.Magnitude > 0.1
            and flatMove.Unit:Dot(WallNormal) > 0.5 then
            Detach(false)
            return
        end

        local position = RootPart.Position
        local result = workspace:Raycast(
            position,
            -WallNormal * (HOLD_DIST + 2),
            RayParams
        )

        if not IsWall(result) then
            local probe = workspace:Raycast(
                position + LastTangent * 3 - WallNormal * 3,
                -LastTangent * 6,
                RayParams
            )

            if IsWall(probe) then
                result = probe
            else
                Detach(false)
                return
            end
        end

        WallNormal = FlatUnit(result.Normal) or WallNormal

        local tangent = flatMove - WallNormal * flatMove:Dot(WallNormal)
        local slideVelocity = Vector3.zero

        if tangent.Magnitude > 0.05 then
            local tangentUnit = tangent.Unit
            LastTangent = tangentUnit

            local ahead = workspace:Raycast(
                position,
                tangentUnit * (HOLD_DIST + 1.2),
                RayParams
            )

            if IsWall(ahead) and FlatUnit(ahead.Normal) then
                WallNormal = FlatUnit(ahead.Normal)
                result = ahead

                tangent = flatMove - WallNormal * flatMove:Dot(WallNormal)
                tangentUnit = tangent.Magnitude > 0.05
                    and tangent.Unit
                    or tangentUnit

                LastTangent = tangentUnit
            end

            slideVelocity = tangentUnit
                * Humanoid.WalkSpeed
                * SPEED_MULT
                * math.min(tangent.Magnitude * 3, 1)
        end

        local distance = (position - result.Position):Dot(WallNormal)
        local pull = math.clamp((HOLD_DIST - distance) * 12, -25, 25)

        RootPart.AssemblyLinearVelocity = Vector3.new(
            slideVelocity.X + WallNormal.X * pull,
            0,
            slideVelocity.Z + WallNormal.Z * pull
        )
        RootPart.AssemblyAngularVelocity = Vector3.zero

        if IsFirstPerson() then
            RootPart.CFrame = CFrame.lookAt(
                RootPart.Position,
                RootPart.Position + CameraFlat()
            )
        elseif slideVelocity.Magnitude > 1 then
            local target = CFrame.lookAt(
                RootPart.Position,
                RootPart.Position + slideVelocity.Unit
            )

            RootPart.CFrame = RootPart.CFrame:Lerp(
                target,
                math.clamp(deltaTime * 12, 0, 1)
            )
        else
            local lookFlat = FlatUnit(RootPart.CFrame.LookVector) or CameraFlat()

            RootPart.CFrame = CFrame.lookAt(
                RootPart.Position,
                RootPart.Position + lookFlat
            )
        end
    end

    local function OnCharacterAdded(newCharacter)
        CharacterGeneration += 1
        local generation = CharacterGeneration

        if LocalPlayer.Character ~= newCharacter then
            return
        end

        if Stuck then
            Detach(false, false)
        end

        DisconnectRecover()
        Stuck = false
        Character = nil
        Humanoid = nil
        RootPart = nil

        local newHumanoid = newCharacter:WaitForChild("Humanoid", 10)
        local newRootPart = newCharacter:WaitForChild("HumanoidRootPart", 10)

        if not Alive
            or generation ~= CharacterGeneration
            or LocalPlayer.Character ~= newCharacter
            or not newHumanoid
            or not newRootPart then
            return
        end

        Character = newCharacter
        Humanoid = newHumanoid
        RootPart = newRootPart
    end

    local function SetEnabled(value)
        if not Alive then
            return
        end

        local newValue = value and true or false
        if Enabled == newValue then
            return
        end

        Enabled = newValue

        if Enabled then
            if not Character or not Humanoid or not RootPart then
                local currentCharacter = LocalPlayer.Character
                if currentCharacter then
                    OnCharacterAdded(currentCharacter)
                end
            end

            if not HeartbeatConnection then
                HeartbeatConnection = RunService.Heartbeat:Connect(Step)
            end

            if not JumpConnection then
                JumpConnection = UserInputService.JumpRequest:Connect(function()
                    if Enabled and Stuck then
                        Detach(true)
                    end
                end)
            end
        else
            if HeartbeatConnection then
                HeartbeatConnection:Disconnect()
                HeartbeatConnection = nil
            end

            if JumpConnection then
                JumpConnection:Disconnect()
                JumpConnection = nil
            end

            if Stuck then
                Detach(false, false)
            elseif Humanoid and Humanoid.Parent then
                Humanoid.PlatformStand = false
            end

            DisconnectRecover()
        end
    end

    CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

    if LocalPlayer.Character then
        task.spawn(OnCharacterAdded, LocalPlayer.Character)
    end

    MainTab:AddToggle({
        Name = "สไลด์บนกำแพง",
        Default = false,
        Callback = SetEnabled,
    })

    local function CleanupWallSlide()
        if not Alive then
            return
        end

        Alive = false
        Enabled = false

        if Stuck then
            Detach(false, false)
        end

        if Humanoid and Humanoid.Parent then
            Humanoid.PlatformStand = false
        end

        DisconnectRecover()

        if HeartbeatConnection then
            pcall(function()
                HeartbeatConnection:Disconnect()
            end)
        end

        if JumpConnection then
            pcall(function()
                JumpConnection:Disconnect()
            end)
        end

        if CharacterAddedConnection then
            pcall(function()
                CharacterAddedConnection:Disconnect()
            end)
        end

        HeartbeatConnection = nil
        JumpConnection = nil
        CharacterAddedConnection = nil

        if WallSlideEnv.KRYVEX_WallSlideCleanup == CleanupWallSlide then
            WallSlideEnv.KRYVEX_WallSlideCleanup = nil
        end
    end

    WallSlideEnv.KRYVEX_WallSlideCleanup = CleanupWallSlide
end
