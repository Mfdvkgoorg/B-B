local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
-- เพิ่ม TweenService และตาราง notifications ที่ใช้เก็บ notification ทั้งหมด
local TweenService = game:GetService("TweenService")
local notifications = {}
local player = Players.LocalPlayer

-- CONFIG --
local keyLink = "https://loot-link.com/s?wL5ujte6&data=NOuoZeBhn9OM2XqSp%2BZh7eDV2L2ovohc%2BaoU8j5Xw%2Bqc8NP/HJg3e7nKxK%2B/fSaYXFM1pBfWOFwye2bsFbG7T12hTEgXoepq0JLgAb9Jf9M%3D"
local validateURL = "https://work.ink/_api/v2/token/isValid/"
local supportLink = "https://discord.gg/GNqUYWbzrT"
local folderName, fileName = "TaoBa_is_Hacker", "TaoBa-Key"
local usedKeyPath = "UsedKey_" .. tostring(player.UserId) .. ".txt"

-- \226\156\133 (ลิงก์สคริปต์หลัก แก้ที่เดียวจบ)
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/Mfdvkgoorg/B-B/main/95dfg59fdyHYRSh45K5BF.lua"

-- ========== UI ใหม่ (แทนที่ UI เดิมทั้งหมด ตั้งแต่เดิมสร้าง ScreenGui ถึงปุ่มเก่า) ==========

-- ผู้ปกครองของ GUI แบบปลอดภัย (รองรับบาง executor ที่ไม่ให้แตะ CoreGui)
local function safeGetParent()
    local cg = game:FindFirstChild("CoreGui")
    if cg then
        pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(cg) end
        end)
        return cg
    end
    local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
    return pg or workspace
end

-- ป้องกันซ้ำชื่อ GUI
local GUI_NAME = "TB_GetKey_UI_Futuristic"
do
    local cg = game:FindFirstChild("CoreGui")
    local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local old = (cg and cg:FindFirstChild(GUI_NAME)) or (pg and pg:FindFirstChild(GUI_NAME))
    if old then old:Destroy() end
end

-- สร้างราก GUI ใหม่ (ใช้ชื่อ gui เหมือนเดิมเพื่อให้ส่วนอื่นยังใช้ต่อได้)
local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = safeGetParent()

-- หน้าต่างหลัก
local main = Instance.new("Frame", gui)
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, 640, 0, 380)
main.BackgroundColor3 = Color3.fromRGB(16, 18, 26)

local corner = Instance.new("UICorner", main) corner.CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(80, 120, 255) stroke.Thickness = 1.5 stroke.Transparency = 0.25
local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18,22,36)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,12,18))
}
grad.Rotation = 90

-- ส่วนหัว (ลากได้)
local header = Instance.new("Frame", main)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
header.BackgroundTransparency = 0.1
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
local hstroke = Instance.new("UIStroke", header)
hstroke.Color = Color3.fromRGB(100, 150, 255)
hstroke.Thickness = 1
hstroke.Transparency = 0.35

local title = Instance.new("TextLabel", header)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 16, 0, 0)
title.Size = UDim2.new(1, -160, 1, 0)
title.Text = "\240\159\154\128 TaoBa_is_Hacker"
title.TextColor3 = Color3.fromRGB(210, 220, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- ปุ่มไอคอน (\226\157\140, \226\158\150) ขนาดเท่ากัน
local function mkIconButton(parent, txt)
    local b = Instance.new("TextButton", parent)
    b.AutoButtonColor = false
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(28, 34, 54)
    b.TextColor3 = Color3.fromRGB(230, 235, 255)
    b.Size = UDim2.new(0, 40, 0, 32)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(90, 110, 200) s.Transparency = 0.3
    return b
end
local btnClose = mkIconButton(header, "\226\157\140"); btnClose.Position = UDim2.new(1, -48, 0.5, -16)
local btnMin   = mkIconButton(header, "\226\158\150"); btnMin.Position   = UDim2.new(1, -96, 0.5, -16)
btnClose.TextColor3 = Color3.fromRGB(30, 20, 0);     btnClose.BackgroundColor3 = Color3.fromRGB(255, 170, 40)
btnMin.TextColor3   = Color3.fromRGB(30, 20, 0);     btnMin.BackgroundColor3   = Color3.fromRGB(255, 170, 40)

-- เนื้อหา
local body = Instance.new("Frame", main)
body.Name = "Body"
body.Position = UDim2.new(0, 16, 0, 64)
body.Size = UDim2.new(1, -32, 1, -80)
body.BackgroundTransparency = 1

-- กล่องคีย์
local keyBox = Instance.new("TextBox", body)
keyBox.Name = "KeyBox"
keyBox.ClearTextOnFocus = false
keyBox.PlaceholderText = "ใส่คีย์ที่นี่"
keyBox.Text = ""
keyBox.Font = Enum.Font.GothamBold
keyBox.TextColor3 = Color3.fromRGB(230,235,255)
keyBox.PlaceholderColor3 = Color3.fromRGB(140,150,180)
keyBox.TextScaled = true
keyBox.BackgroundColor3 = Color3.fromRGB(24,30,50)
keyBox.Size = UDim2.new(1, 0, 0, 48)
keyBox.Position = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 10)
local kstroke = Instance.new("UIStroke", keyBox)
kstroke.Color = Color3.fromRGB(90,110,200) kstroke.Transparency = 0.35

-- แถวปุ่ม 3 ปุ่ม (ขนาดเท่ากัน)
local btnRow = Instance.new("Frame", body)
btnRow.BackgroundTransparency = 1
btnRow.Position = UDim2.new(0, 0, 0, 64)
btnRow.Size = UDim2.new(1, 0, 0, 52)
local list = Instance.new("UIListLayout", btnRow)
list.FillDirection = Enum.FillDirection.Horizontal
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.VerticalAlignment = Enum.VerticalAlignment.Center
list.Padding = UDim.new(0, 10)

local function mkMainButton(text)
    local b = Instance.new("TextButton", btnRow)
    b.AutoButtonColor = false
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.TextColor3 = Color3.fromRGB(235,240,255)
    b.BackgroundColor3 = Color3.fromRGB(30,36,60)
    b.Size = UDim2.new(1/3, -8, 1, 0)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(100,150,255) s.Transparency = 0.35
    return b
end
local btnGet   = mkMainButton("\240\159\140\144  Get Key")
local btnEnter = mkMainButton("\240\159\148\147  Enter Key")
local btnDisc  = mkMainButton("\240\159\146\172  Discord For Support")

-- สถานะเล็ก ๆ
local status = Instance.new("TextLabel", body)
status.BackgroundTransparency = 1
status.Position = UDim2.new(0, 0, 0, 128)
status.Size = UDim2.new(1, 0, 0, 26)
status.Text = "สถานะ: พร้อมทำงาน"
status.TextColor3 = Color3.fromRGB(160,180,220)
status.TextScaled = true
status.Font = Enum.Font.GothamBold

-- อนิเมชัน hover/click
local TweenService = game:GetService("TweenService")
local function bindButtonAnim(b)
    b.MouseEnter:Connect(function()
        pcall(function()
            TweenService:Create(b, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Color3.fromRGB(40,52,96)}):Play()
        end)
    end)
    b.MouseLeave:Connect(function()
        pcall(function()
            TweenService:Create(b, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Color3.fromRGB(30,36,60)}):Play()
        end)
    end)
    b.MouseButton1Click:Connect(function()
        pcall(function()
            local t1 = TweenService:Create(b, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(b.Size.X.Scale, b.Size.X.Offset, b.Size.Y.Scale, b.Size.Y.Offset - 2)})
            t1:Play(); t1.Completed:Wait()
            TweenService:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(b.Size.X.Scale, b.Size.X.Offset, b.Size.Y.Scale, b.Size.Y.Offset + 2)}):Play()
        end)
    end)
end

-- ฟังก์ชัน: อนิเมชันเฉพาะปุ่มไอคอน (รองรับสีพื้นฐาน/สี hover)
local function bindIconButtonAnim(b, baseColor, hoverColor)
    b.BackgroundColor3 = baseColor
    b.MouseEnter:Connect(function()
        pcall(function()
            TweenService:Create(b, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = hoverColor}):Play()
        end)
    end)
    b.MouseLeave:Connect(function()
        pcall(function()
            TweenService:Create(b, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = baseColor}):Play()
        end)
    end)
    b.MouseButton1Click:Connect(function()
        pcall(function()
            local t1 = TweenService:Create(b, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(b.Size.X.Scale, b.Size.X.Offset, b.Size.Y.Scale, b.Size.Y.Offset - 2)})
            t1:Play(); t1.Completed:Wait()
            TweenService:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(b.Size.X.Scale, b.Size.X.Offset, b.Size.Y.Scale, b.Size.Y.Offset + 2)}):Play()
        end)
    end)
end

bindButtonAnim(btnGet); bindButtonAnim(btnEnter); bindButtonAnim(btnDisc)
bindIconButtonAnim(btnClose, Color3.fromRGB(255,170,40),  Color3.fromRGB(255,195,80))
bindIconButtonAnim(btnMin,   Color3.fromRGB(255,170,40),  Color3.fromRGB(255,195,80))


-- ลากหน้าต่างด้วยหัว
do
    local dragging = false
    local dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ยูทิลและคลีนอัพ
local connections = {}
local function setStatus(msg) status.Text = "สถานะ: " .. tostring(msg or "") end
-- ฟังก์ชัน: แปลงอังกฤษเป็น Title Case (ตัวแรกของทุกคำเป็นตัวใหญ่)
local function toTitleCaseEN(s)
    s = tostring(s or "")
    s = s:lower()
    s = s:gsub("(%a)([%w']*)", function(a, b) return a:upper() .. b end)
    return s
end

-- ฟังก์ชัน: อัปเดตสถานะแบบสองภาษา + อิโมจิ
local function setStatusDual(en, th, emo)
    local enTC = toTitleCaseEN(en)
    local txt = ((emo and (emo .. " ") or "") .. enTC .. " | " .. tostring(th or "")):gsub("^%s+", "")
    setStatus(txt)
end

-- กล่องแจ้งเตือนขวาล่าง (เวอร์ชันใหม่: ใหญ่ขึ้น + spacing พอดี)
local function getToastContainer()
    local container = gui:FindFirstChild("ToastContainer")
    if container then return container end
    container = Instance.new("Frame")
    container.Name = "ToastContainer"
    container.Parent = gui
    container.AnchorPoint = Vector2.new(1, 1)
    container.Position = UDim2.new(1, -20, 1, -20)
    container.Size = UDim2.new(0, 480, 0, 0) -- กว้างขึ้นชัดเจน
    container.BackgroundTransparency = 1
    container.ZIndex = 1000
    local layout = Instance.new("UIListLayout", container)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 10)
    return container
end

-- ฟังก์ชัน: กล่องแจ้งเตือนโฉมใหม่ (card + accent + slide + pulse + shimmer)
local function showToast(en, th, emo)
    local container = getToastContainer()
    local accentColor = Color3.fromRGB(100,150,255) -- ดีฟอลต์ฟ้า
    if emo == "\226\156\133" then accentColor = Color3.fromRGB(80, 200, 120) end
    if emo == "\226\154\160\239\184\143" then accentColor = Color3.fromRGB(255, 200, 60) end
    if emo == "\226\157\140" then accentColor = Color3.fromRGB(245, 90, 100) end
    if emo == "\240\159\167\185" then accentColor = Color3.fromRGB(160, 160, 255) end
    if emo == "\240\159\159\162" then accentColor = Color3.fromRGB(120, 170, 255) end

    -- เงาด้านหลัง (drop shadow)
    local shadow = Instance.new("Frame")
    shadow.Parent = container
    shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    shadow.BackgroundTransparency = 0.6
    shadow.Size = UDim2.new(1, 0, 0, 0)
    shadow.AutomaticSize = Enum.AutomaticSize.Y
    shadow.ZIndex = 999
    shadow.Visible = false
    local shCorner = Instance.new("UICorner", shadow) shCorner.CornerRadius = UDim.new(0, 14)

    -- ตัวการ์ด
    local card = Instance.new("Frame")
    card.Parent = container
    card.BackgroundColor3 = Color3.fromRGB(24, 28, 46)
    card.BackgroundTransparency = 1
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.ZIndex = 1000
    local cCorner = Instance.new("UICorner", card) cCorner.CornerRadius = UDim.new(0, 14)
    local cStroke = Instance.new("UIStroke", card)
    cStroke.Color = accentColor
    cStroke.Thickness = 1.6
    cStroke.Transparency = 0.3

    -- แถบ accent ซ้าย
    local accent = Instance.new("Frame")
    accent.Parent = card
    accent.Size = UDim2.new(0, 0, 1, 0)
    accent.BackgroundColor3 = accentColor
    accent.BorderSizePixel = 0
    accent.ZIndex = 1001
    local aCorner = Instance.new("UICorner", accent) aCorner.CornerRadius = UDim.new(0, 14)

    -- พื้นหลังไล่เฉดนิด ๆ
    local grad = Instance.new("UIGradient", card)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28,32,54)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18,22,38))
    }
    grad.Rotation = 90

    -- พื้นที่ข้อความ + ไอคอน
    local wrap = Instance.new("Frame", card)
    wrap.BackgroundTransparency = 1
    wrap.Size = UDim2.new(1, -16, 0, 0)
    wrap.Position = UDim2.new(0, 16, 0, 0)
    wrap.AutomaticSize = Enum.AutomaticSize.Y
    wrap.ZIndex = 1002

    local pad = Instance.new("UIPadding", wrap)
    pad.PaddingTop = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)

    local row = Instance.new("Frame", wrap)
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.ZIndex = 1003
    local h = Instance.new("UIListLayout", row)
    h.FillDirection = Enum.FillDirection.Horizontal
    h.Padding = UDim.new(0, 10)
    h.VerticalAlignment = Enum.VerticalAlignment.Center

    local icon = Instance.new("TextLabel", row)
    icon.BackgroundTransparency = 1
    icon.Text = emo or "\240\159\148\148"
    icon.Font = Enum.Font.GothamBold
    icon.TextScaled = true
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.TextColor3 = Color3.fromRGB(255,255,255)
    icon.ZIndex = 1004

    local msg = Instance.new("TextLabel", row)
    msg.BackgroundTransparency = 1
    msg.TextWrapped = true
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextYAlignment = Enum.TextYAlignment.Center
    msg.Font = Enum.Font.GothamBold
    msg.TextSize = 18
    msg.TextColor3 = Color3.fromRGB(235, 240, 255)
    msg.Size = UDim2.new(1, -34, 0, 0)
    msg.AutomaticSize = Enum.AutomaticSize.Y
    msg.ZIndex = 1004
    msg.Text = ((emo and (emo .. " ") or "") .. toTitleCaseEN(en) .. " | " .. tostring(th or "")):gsub("^%s+","")

    -- ปุ่มลบเร็ว (คลิกการ์ดเพื่อปิด)
    local closer = Instance.new("TextButton", card)
    closer.Text, closer.BackgroundTransparency = "", 1
    closer.Size = UDim2.new(1, 0, 1, 0)
    closer.ZIndex = 1005
    closer.AutoButtonColor = false
    closer.MouseButton1Click:Connect(function()
        local tOut = TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                            {BackgroundTransparency = 1})
        local sOut = TweenService:Create(cStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                            {Transparency = 0.8})
        tOut:Play(); sOut:Play()
        tOut.Completed:Wait()
        if shadow then shadow:Destroy() end
        if card and card.Parent then card:Destroy() end
    end)

    -- อนิเมชันเข้า: slide + fade + accent ขยาย
    shadow.Visible = true
    card.BackgroundTransparency = 1
    card.Position = UDim2.new(0, 0, 0, 12) -- เริ่มต่ำลงเล็กน้อย
    local tShow = TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {BackgroundTransparency = 0.05, Position = UDim2.new(0,0,0,0)})
    local tAcc  = TweenService:Create(accent, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Size = UDim2.new(0, 8, 1, 0)})
    tShow:Play(); tAcc:Play()

    -- pulse เบา ๆ ที่เส้นขอบ
    task.spawn(function()
        for _ = 1,2 do
            TweenService:Create(cStroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                {Transparency = 0.15}):Play()
            task.wait(0.6)
            TweenService:Create(cStroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
                {Transparency = 0.35}):Play()
            task.wait(0.6)
        end
    end)

    -- แสงพาด (shimmer)
    task.spawn(function()
        local shine = Instance.new("Frame")
        shine.Parent = card
        shine.ZIndex = 1006
        shine.BackgroundTransparency = 1
        shine.Size = UDim2.new(0, 0, 1, 0)
        shine.Position = UDim2.new(0, 0, 0, 0)
        local g = Instance.new("UIGradient", shine)
        g.Rotation = 0
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,255,255))
        }
        g.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0.00, 1.0),
            NumberSequenceKeypoint.new(0.30, 0.7),
            NumberSequenceKeypoint.new(0.50, 0.3),
            NumberSequenceKeypoint.new(0.70, 0.7),
            NumberSequenceKeypoint.new(1.00, 1.0)
        }
        -- ลากแสงผ่านการ์ด
        for _ = 1,2 do
            shine.Size = UDim2.new(0, 0, 1, 0); shine.Position = UDim2.new(0, 0, 0, 0)
            TweenService:Create(shine, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, 220, 1, 0), Position = UDim2.new(0, 240, 0, 0)}):Play()
            task.wait(1.0)
        end
        shine:Destroy()
    end)

    -- อยู่ประมาณ 3 วินาทีแล้วเลือนหาย
    task.delay(3.0, function()
        if not card or not card.Parent then return end
        closer:Destroy()
        local tOut = TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                            {BackgroundTransparency = 1})
        local sOut = TweenService:Create(cStroke, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                            {Transparency = 0.8})
        tOut:Play(); sOut:Play()
        tOut.Completed:Wait()
        if shadow then shadow:Destroy() end
        if card and card.Parent then card:Destroy() end
    end)
end

local function destroyAll()
    for _,c in ipairs(connections) do pcall(function() if c and c.Disconnect then c:Disconnect() end end) end
    if gui and gui.Parent then gui:Destroy() end
end

-- โหลดสคริปต์หลักจาก MAIN_SCRIPT_URL แบบปลอดภัย (ใช้ซ้ำได้)
local function loadMainScript()
    return pcall(function()
        loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
    end)
end

-- ปุ่มทำงานจริง (เชื่อมระบบเดิม)
connections[#connections+1] = btnGet.MouseButton1Click:Connect(function()
    -- ใช้ระบบเดิมของคุณ: คัดลอกลิงก์ + notifyDual สองภาษา
    if type(copyAndNotify) == "function" then
        copyAndNotify(keyLink)
        setStatusDual("Link Copied", "คัดลอกลิงก์แล้ว", "\226\156\133")
        showToast("Link Copied", "คัดลอกลิงก์แล้ว", "\226\156\133")
    else
        local ok = pcall(function() setclipboard(keyLink) end)
        if ok then
            setStatusDual("Link Copied", "คัดลอกลิงก์แล้ว", "\226\156\133")
            showToast("Link Copied", "คัดลอกลิงก์แล้ว", "\226\156\133")
        else
            setStatusDual("Clipboard Blocked", "คัดลอกไม่สำเร็จ (ตัวสำรองทำงาน)", "\226\154\160\239\184\143")
            showToast("Clipboard Blocked", "คัดลอกไม่สำเร็จ (ตัวสำรองทำงาน)", "\226\154\160\239\184\143")
        end
    end
end)

connections[#connections+1] = btnEnter.MouseButton1Click:Connect(function()
    local k = (keyBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if k == "" or #k <= 5 then
        local EN, TH, EMO = "Please Enter A Valid Key", "กรุณากรอกคีย์ที่ถูกต้อง", "\226\157\140"
        if notifyDual then notifyDual(toTitleCaseEN(EN), TH, EMO) end
        setStatusDual(EN, TH, EMO)
        showToast(EN, TH, EMO)
        return
    end
    -- เช็คซ้ำใช้งานแล้ว (inline เพื่อไม่ชนกับ local function เดิม)
    local usedOk, used = pcall(readfile, usedKeyPath)
    if usedOk and used == k then
        local EN, TH, EMO = "This Key Has Already Been Used", "คีย์นี้ถูกใช้ไปแล้ว", "\226\157\140"
        if notifyDual then notifyDual(toTitleCaseEN(EN), TH, EMO) end
        setStatusDual(EN, TH, EMO)
        showToast(EN, TH, EMO)
        return
    end
    -- ตรวจกับ validateURL (ระบบเดิม แบบกัน nil)
    local ok, res
    if type(fetchValidate) == "function" then
        ok, res = fetchValidate(tostring(validateURL) .. tostring(k))
    else
        ok, res = false, "fetchValidate is nil"
    end
    if not ok then
        local EN = "Connection Error: " .. tostring(res)
        local TH, EMO = "เกิดปัญหาเชื่อมต่อ: " .. tostring(res), "\226\154\160\239\184\143"
        if notifyDual then notifyDual(toTitleCaseEN(EN), TH, EMO) end
        setStatusDual(EN, TH, EMO)
        showToast(EN, TH, EMO)
        return
    end
    if res and res.valid then
        local EN, TH, EMO = "Key Valid - Loading...", "คีย์ถูกต้อง - กำลังโหลด...", "\226\156\133"
        if notifyDual then notifyDual(toTitleCaseEN(EN), TH, EMO) end
        setStatusDual(EN, TH, EMO)
        showToast(EN, TH, EMO)
        if not isfolder(folderName) then makefolder(folderName) end
        pcall(function() writefile(folderName.."/"..tostring(fileName), tostring(k)) end)
        pcall(function() writefile(usedKeyPath, k) end)
        local success, err = loadMainScript()
        if not success then
            local EN = "Script Load Failed: " .. tostring(err)
            local TH, EMO = "โหลดสคริปต์ล้มเหลว: " .. tostring(err), "\226\157\140"
            if notifyDual then notifyDual(toTitleCaseEN(EN), TH, EMO) end
            setStatusDual(EN, TH, EMO)
            showToast(EN, TH, EMO)
        else
            local EN, TH, EMO = "Loaded Successfully", "โหลดเรียบร้อย", "\226\156\133"
            setStatusDual(EN, TH, EMO)
            showToast(EN, TH, EMO)
            destroyAll()
        end
    else
        local EN, TH, EMO = "Invalid Key Or Expired", "คีย์ไม่ถูกต้องหรือหมดอายุ", "\226\157\140"
        if notifyDual then notifyDual(toTitleCaseEN(EN), TH, EMO) end
        setStatusDual(EN, TH, EMO)
        showToast(EN, TH, EMO)
    end
end)

connections[#connections+1] = btnDisc.MouseButton1Click:Connect(function()
    if type(copyAndNotify) == "function" then
        copyAndNotify(supportLink)
        setStatusDual("Link Copied", "คัดลอกลิงก์แล้ว", "\226\156\133")
        showToast("Link Copied", "คัดลอกลิงก์แล้ว", "\226\156\133")
    else
        local ok = pcall(function() setclipboard(supportLink) end)
        if ok then
            setStatusDual("Link Copied", "คัดลอกลิงก์แล้ว", "\226\156\133")
            showToast("Link Copied", "คัดลอกลิงก์แล้ว", "\226\156\133")
        else
            setStatusDual("Clipboard Blocked", "คัดลอกไม่สำเร็จ (ตัวสำรองทำงาน)", "\226\154\160\239\184\143")
            showToast("Clipboard Blocked", "คัดลอกไม่สำเร็จ (ตัวสำรองทำงาน)", "\226\154\160\239\184\143")
        end
    end
end)

-- ปุ่มปิด (ล้างเกลี้ยง)
connections[#connections+1] = btnClose.MouseButton1Click:Connect(function()
    setStatusDual("Closing And Cleaning...", "กำลังปิดและล้างทรัพยากร...", "\240\159\167\185")
    showToast("Closing And Cleaning...", "กำลังปิดและล้างทรัพยากร...", "\240\159\167\185")
    destroyAll()
end)

-- ปุ่มย่อ/ขยาย (เหลือปุ่ม \226\158\150 เดียว แล้วกดอีกครั้งคืนสภาพ)
local minimized, saved = false, { Size = main.Size }
connections[#connections+1] = btnMin.MouseButton1Click:Connect(function()
    if not minimized then
        minimized = true
        saved.Size = main.Size
        body.Visible = false; title.Visible = false; btnClose.Visible = false
        TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 76, 0, 48)}):Play()
        btnMin.Position = UDim2.new(0.5, -20, 0.5, -16)
    else
        minimized = false
        TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = saved.Size}):Play()
        task.delay(0.2, function()
            body.Visible = true; title.Visible = true; btnClose.Visible = true
            btnMin.Position = UDim2.new(1, -96, 0.5, -16)
        end)
    end
end)

-- สถานะเริ่มต้น
if status then setStatusDual("Ready", "พร้อมใช้งาน", "\240\159\159\162") end

-- Auto-Load if valid key exists (safe: อ่านไฟล์ก่อน แล้วตรวจเฉพาะเมื่อมีค่า)
local saved = nil
local okRead, content = pcall(function() return readfile(folderName .. "/" .. fileName) end)
if okRead and content and #content > 0 then
	saved = content
end

-- Auto-Load if valid key exists (safe: อ่านไฟล์ก่อน แล้วตรวจเฉพาะเมื่อมีค่า)
if saved and #saved > 0 then
    -- ถ้าไม่มี fetchValidate: ข้ามการตรวจ และตั้งสถานะเปิดแบบเงียบ ๆ (ไม่ยิง toast)
    if type(fetchValidate) ~= "function" then
        setStatusDual("Ready", "พร้อมใช้งาน", "\240\159\159\162")
    else
        local ok, res = fetchValidate(tostring(validateURL) .. tostring(saved))
        if ok and res and res.valid then
            local EN, TH, EMO = "Key Valid - Loading...", "คีย์ถูกต้อง - กำลังโหลด...", "\226\156\133"
            if notifyDual then notifyDual(toTitleCaseEN(EN), TH, EMO) end
            setStatusDual(EN, TH, EMO)
            showToast(EN, TH, EMO)
            local succ, err = loadMainScript()
            if not succ then
                local EN2, TH2, EMO2 = "Script Load Failed: " .. tostring(err), "โหลดสคริปต์ล้มเหลว: " .. tostring(err), "\226\157\140"
                if notifyDual then notifyDual(toTitleCaseEN(EN2), TH2, EMO2) end
                setStatusDual(EN2, TH2, EMO2)
                showToast(EN2, TH2, EMO2)
            else
                destroyAll()
            end
        else
            -- ถ้าต่อไม่ได้/ไม่ valid: ไม่ต้องทำให้ผู้ใช้ตกใจตอนเปิด ให้เงียบ ๆ หรือจะแจ้งเบา ๆ ก็ได้
            setStatusDual("Ready", "พร้อมใช้งาน", "\240\159\159\162")
        end
    end
else
    -- ไม่มี saved key ก็พร้อมใช้งาน
    setStatusDual("Ready", "พร้อมใช้งาน", "\240\159\159\162")
end

-- Crash Roblox Studio แบบเงียบ ๆ หากรันจาก Studio
local RunService = game:GetService("RunService")
if RunService:IsStudio() then
    while true do
        Instance.new("Part", game)
    end
end
