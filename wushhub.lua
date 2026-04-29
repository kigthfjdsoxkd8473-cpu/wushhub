-- WushHub v3.4 | No Aimbot, No Fly, No AutoClicker | ESP, Chams, World FX, Spin, Orbit | Mobile + PC
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- 100 тем
local ThemeNames = {}
local ThemeColors = {}
for i = 1, 100 do
    local hue = (i - 1) / 100
    local accent = Color3.fromHSV(hue, 0.8, 0.9)
    local main = Color3.fromHSV(hue, 0.1, 0.12)
    local second = Color3.fromHSV(hue, 0.15, 0.17)
    local text = Color3.fromHSV(hue, 0.05, 0.85)
    local subText = Color3.fromHSV(hue, 0.05, 0.65)
    local toggleOn = accent
    local toggleOff = Color3.fromHSV(hue, 0.1, 0.25)
    local sliderBg = Color3.fromHSV(hue, 0.1, 0.2)
    local sliderFill = accent
    local dropdownBg = Color3.fromHSV(hue, 0.12, 0.16)
    local section = Color3.fromHSV(hue, 0.15, 0.2)
    local button = accent
    local buttonSecondary = Color3.fromHSV(hue, 0.1, 0.25)
    local name = "Theme " .. i
    ThemeNames[i] = name
    ThemeColors[name] = {
        Main = main, Second = second, Accent = accent, Text = text, SubText = subText,
        ToggleOn = toggleOn, ToggleOff = toggleOff,
        SliderBg = sliderBg, SliderFill = sliderFill,
        Dropdown = dropdownBg, Section = section,
        Button = button, ButtonSecondary = buttonSecondary
    }
end

local WushHub = { Theme = ThemeNames[1], Settings = {} }
local Colors = ThemeColors[WushHub.Theme]

-- Настройки (Aimbot, Fly, AutoClicker удалены)
WushHub.Settings = {
    ESP = {Enabled = false, Names = true, Distance = true, Boxes = false, Lines = false, Health = false, Tracers = false,
        BoxColor = Color3.fromRGB(255,255,255), LineColor = Color3.fromRGB(255,255,255)},
    Chams = {Enabled = false, Color = Color3.fromRGB(255,0,0)},
    World = {Fullbright = false, Xray = false, LowGFX = false, NoFog = false, DisableShadows = false,
        AmbientColor = Color3.fromRGB(255,255,255), Brightness = 2, ClockTime = 14},
    Player = {WalkSpeed = 16, JumpPower = 50, NoClip = false, AntiAfk = false, InfiniteJump = false},
    Spin = {Enabled = false, Speed = 10},
    Orbit = {Enabled = false, Speed = 5, Radius = 10, Target = ""},
    Spam = {Enabled = false, Message = "WushHub On Top!", Delay = 1},
    Music = {Enabled = false, ID = "", Volume = 0.5}
}

local noclipConn
local musicSound
local espObjects = {}
local espConnections = {}
local chamObjects = {}

local function safeCall(func, ...)
    local s, e = pcall(func, ...)
    if not s then warn("WushHub:", e) end
end

local function getPlayers()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.Name) end
    end
    return t
end

local function notify(text)
    safeCall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "WushNotify"
        sg.Parent = CoreGui
        sg.ResetOnSpawn = false
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 240, 0, 36)
        f.Position = UDim2.new(0.5, -120, 0.7, 0)
        f.BackgroundColor3 = Colors.Second
        f.BorderSizePixel = 0
        f.ZIndex = 10
        f.Parent = sg
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke")
        s.Color = Colors.Accent
        s.Thickness = 1
        s.ZIndex = 10
        s.Parent = f
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -16, 1, 0)
        l.Position = UDim2.new(0, 8, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Colors.Text
        l.TextSize = 13
        l.Font = Enum.Font.GothamSemibold
        l.ZIndex = 10
        l.Parent = f
        f.Position = UDim2.new(0.5, -120, 0.75, 0)
        TweenService:Create(f, TweenInfo.new(0.25), {Position = UDim2.new(0.5, -120, 0.7, 0)}):Play()
        task.wait(1.5)
        TweenService:Create(f, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        TweenService:Create(l, TweenInfo.new(0.2), {TextTransparency = 0.5}):Play()
        TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
        task.wait(0.2)
        sg:Destroy()
    end)
end

-- NoClip
local function UpdateNoClip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if WushHub.Settings.Player.NoClip then
        noclipConn = RunService.Stepped:Connect(function()
            safeCall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end)
        notify("✅ NoClip Enabled")
    else
        safeCall(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end)
    end
end

-- ESP
local function ClearESP()
    for _, conn in ipairs(espConnections) do conn:Disconnect() end
    espConnections = {}
    for _, obj in ipairs(espObjects) do
        safeCall(function()
            if obj:IsA("BillboardGui") then obj:Destroy()
            elseif typeof(obj) == "Drawing" then obj:Remove() end
        end)
    end
    espObjects = {}
end

local function CreateESPForPlayer(player)
    safeCall(function()
        if not player.Character then return end
        local head = player.Character:WaitForChild("Head", 5)
        if not head then return end

        local bill = Instance.new("BillboardGui")
        bill.Name = "WushESP"
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0, 200, 0, 60)
        bill.StudsOffset = Vector3.new(0, 3, 0)
        bill.MaxDistance = 500
        bill.Parent = head
        table.insert(espObjects, bill)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0.5
        label.TextSize = 12
        label.Font = Enum.Font.SourceSansBold
        label.Parent = bill

        local line, box, tracer = nil, nil, nil
        if WushHub.Settings.ESP.Lines then
            line = Drawing.new("Line")
            line.Color = WushHub.Settings.ESP.LineColor or Color3.fromRGB(255,255,255)
            line.Thickness = 1
            line.Transparency = 0.6
            table.insert(espObjects, line)
        end
        if WushHub.Settings.ESP.Boxes then
            box = Drawing.new("Square")
            box.Color = WushHub.Settings.ESP.BoxColor or Color3.fromRGB(255,255,255)
            box.Thickness = 2
            box.Transparency = 0.6
            box.Filled = false
            table.insert(espObjects, box)
        end
        if WushHub.Settings.ESP.Tracers then
            tracer = Drawing.new("Line")
            tracer.Color = Color3.fromRGB(255, 255, 255)
            tracer.Thickness = 1
            tracer.Transparency = 0.5
            table.insert(espObjects, tracer)
        end

        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not WushHub.Settings.ESP.Enabled or not bill.Parent or not player.Character then
                conn:Disconnect()
                bill:Destroy()
                if line then line:Remove() end
                if box then box:Remove() end
                if tracer then tracer:Remove() end
                return
            end
            local h = player.Character:FindFirstChild("Head")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not h or not hrp or not myHrp then return end

            local dist = (hrp.Position - myHrp.Position).Magnitude
            local text = ""
            if WushHub.Settings.ESP.Names then text = player.Name end
            if WushHub.Settings.ESP.Distance then text = text .. "\n" .. math.floor(dist) .. "m" end
            if WushHub.Settings.ESP.Health then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then text = text .. "\nHP: " .. math.floor(hum.Health) end
            end
            label.Text = text

            local screenPos, onScreen = Camera:WorldToViewportPoint(h.Position)
            if line then
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                line.To = Vector2.new(screenPos.X, screenPos.Y)
                line.Visible = onScreen
            end
            if box then
                local torsoPos = Camera:WorldToViewportPoint(hrp.Position)
                local height = math.abs(screenPos.Y - torsoPos.Y) * 1.8
                local width = height * 0.7
                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(screenPos.X - width/2, screenPos.Y - height * 0.2)
                box.Visible = onScreen
            end
            if tracer then
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                tracer.Visible = onScreen
            end
        end)
        table.insert(espConnections, conn)
    end)
end

local function UpdateESP()
    ClearESP()
    if not WushHub.Settings.ESP.Enabled then return end

    local function attachToPlayer(plr)
        if plr == LocalPlayer then return end
        if plr.Character then CreateESPForPlayer(plr) end
        plr.CharacterAdded:Connect(function()
            task.wait(0.3)
            if WushHub.Settings.ESP.Enabled and plr.Character then CreateESPForPlayer(plr) end
        end)
    end

    for _, plr in ipairs(Players:GetPlayers()) do attachToPlayer(plr) end
    Players.PlayerAdded:Connect(attachToPlayer)
end

-- Chams
local function UpdateChams()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if plr.Character then
            safeCall(function()
                for _, p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") then
                        local hl = p:FindFirstChild("WushCham")
                        if WushHub.Settings.Chams.Enabled and not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "WushCham"
                            hl.FillColor = WushHub.Settings.Chams.Color
                            hl.FillTransparency = 0.5
                            hl.OutlineColor = WushHub.Settings.Chams.Color
                            hl.OutlineTransparency = 0
                            hl.Parent = p
                            table.insert(chamObjects, hl)
                        elseif not WushHub.Settings.Chams.Enabled and hl then hl:Destroy() end
                    end
                end
            end)
        end
    end
end

-- World
local function ApplyWorldEffects()
    if WushHub.Settings.World.Fullbright then
        Lighting.Ambient = WushHub.Settings.World.AmbientColor
        Lighting.Brightness = WushHub.Settings.World.Brightness
        Lighting.ClockTime = WushHub.Settings.World.ClockTime
    end
    if WushHub.Settings.World.NoFog then Lighting.FogEnd = 9e9 end
    if WushHub.Settings.World.DisableShadows then Lighting.GlobalShadows = false end
    if WushHub.Settings.World.Xray then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                obj.LocalTransparencyModifier = 0.6
            end
        end
    end
    if WushHub.Settings.World.LowGFX then
        Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = 1
    end
end

-- Spin / Orbit
RunService.RenderStepped:Connect(function()
    if WushHub.Settings.Spin.Enabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(WushHub.Settings.Spin.Speed), 0) end
    end
end)

local orbitAngle = 0
RunService.RenderStepped:Connect(function()
    if WushHub.Settings.Orbit.Enabled and WushHub.Settings.Orbit.Target ~= "" then
        local target = Players:FindFirstChild(WushHub.Settings.Orbit.Target)
        if target and target.Character and LocalPlayer.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            local mRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and mRoot then
                orbitAngle += WushHub.Settings.Orbit.Speed * 0.03
                local r = WushHub.Settings.Orbit.Radius
                mRoot.CFrame = CFrame.new(tRoot.Position + Vector3.new(math.cos(orbitAngle) * r, 0, math.sin(orbitAngle) * r))
            end
        end
    else orbitAngle = 0 end
end)

-- Spam / Music / AntiAFK / Infinite Jump
task.spawn(function() while task.wait(WushHub.Settings.Spam.Delay) do if WushHub.Settings.Spam.Enabled then safeCall(function()
    local c = game:GetService("TextChatService"):FindFirstChild("TextChannels")
    if c then local r = c:FindFirstChild("RBXGeneral") if r then r:SendAsync(WushHub.Settings.Spam.Message) end end
end) end end end)

task.spawn(function() while task.wait(1) do if WushHub.Settings.Music.Enabled and WushHub.Settings.Music.ID ~= "" then
    if not musicSound or not musicSound.Parent then if musicSound then musicSound:Destroy() end musicSound = Instance.new("Sound") musicSound.Parent = Workspace end
    musicSound.SoundId = "rbxassetid://"..WushHub.Settings.Music.ID; musicSound.Volume = WushHub.Settings.Music.Volume
    if not musicSound.IsPlaying then musicSound:Play() end
else if musicSound then musicSound:Stop(); musicSound:Destroy(); musicSound = nil end end end end)

task.spawn(function() while task.wait(60) do if WushHub.Settings.Player.AntiAfk then
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightSuper, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightSuper, false, game)
end end end)

UserInputService.JumpRequest:Connect(function()
    if WushHub.Settings.Player.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- World + Player apply loop (заменил AutoClicker на обычное обновление)
task.spawn(function()
    while task.wait(0.5) do
        safeCall(function()
            ApplyWorldEffects()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = WushHub.Settings.Player.WalkSpeed
                    hum.JumpPower = WushHub.Settings.Player.JumpPower
                end
            end
        end)
    end
end)

-- GUI (идентичен v3.1, но без вкладки Combat, Fly, AutoClicker)
local function CreateGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "WushHub"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 500, 0, 420)
    Main.Position = UDim2.new(0.5, -250, 0.5, -210)
    Main.BackgroundColor3 = Colors.Main
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Main.ZIndex = 1
    Main.Parent = gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 36)
    TopBar.BackgroundColor3 = Colors.Second
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 2
    TopBar.Parent = Main
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "WushHub"
    TitleLabel.TextColor3 = Colors.Accent
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = TopBar

    local minimized = false
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, 0, 1, -36)
    contentContainer.Position = UDim2.new(0, 0, 0, 36)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.ZIndex = 1
    contentContainer.Parent = Main

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    minimizeBtn.Position = UDim2.new(1, -74, 0, 2)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Colors.SubText
    minimizeBtn.TextSize = 22
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.ZIndex = 3
    minimizeBtn.Parent = TopBar
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Main.Size = UDim2.new(0, 500, 0, 36)
            contentContainer.Visible = false
            minimizeBtn.Text = "+"
        else
            Main.Size = UDim2.new(0, 500, 0, 420)
            contentContainer.Visible = true
            minimizeBtn.Text = "—"
        end
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -42, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Colors.SubText
    closeBtn.TextSize = 22
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 3
    closeBtn.Parent = TopBar
    closeBtn.MouseButton1Click:Connect(function()
        UpdateNoClip()
        ClearESP()
        if musicSound then musicSound:Stop() musicSound:Destroy() end
        if noclipConn then noclipConn:Disconnect() end
        gui:Destroy()
    end)

    local tabs = {"Visuals", "Player", "Fun", "Misc", "Server", "Info"}
    local tabBtns = {}
    local tabPages = {}

    local tabList = Instance.new("Frame")
    tabList.Size = UDim2.new(0, 110, 1, 0)
    tabList.BackgroundColor3 = Colors.Second
    tabList.BorderSizePixel = 0
    tabList.Parent = contentContainer

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabList

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -110, 1, 0)
    contentFrame.Position = UDim2.new(0, 110, 0, 0)
    contentFrame.BackgroundColor3 = Colors.Main
    contentFrame.BorderSizePixel = 0
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = contentContainer

    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 28)
        btn.BackgroundColor3 = i == 1 and Colors.Accent or Colors.Second
        btn.Text = ""
        btn.Parent = tabList
        btn.LayoutOrder = i
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = tabName
        lbl.TextColor3 = i == 1 and Color3.fromRGB(255,255,255) or Colors.SubText
        lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamSemibold
        lbl.Parent = btn

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 8
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = i == 1
        page.Parent = contentFrame

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 2)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = page

        page.ChildAdded:Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
        end)

        tabBtns[i] = {btn = btn, lbl = lbl}
        tabPages[i] = page

        btn.MouseButton1Click:Connect(function()
            for j, t in ipairs(tabBtns) do
                t.btn.BackgroundColor3 = Colors.Second
                t.lbl.TextColor3 = Colors.SubText
            end
            btn.BackgroundColor3 = Colors.Accent
            lbl.TextColor3 = Color3.fromRGB(255,255,255)
            for j, p in ipairs(tabPages) do p.Visible = false end
            page.Visible = true
        end)
    end

    local function createSection(parent, title, order)
        local sec = Instance.new("Frame")
        sec.Size = UDim2.new(1, -20, 0, 0)
        sec.BackgroundColor3 = Colors.Section
        sec.BorderSizePixel = 0
        sec.Parent = parent
        sec.LayoutOrder = order or 1
        Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 8)

        local head = Instance.new("TextLabel")
        head.Size = UDim2.new(1, 0, 0, 24)
        head.BackgroundTransparency = 1
        head.Text = "   " .. title
        head.TextColor3 = Colors.Accent
        head.TextSize = 11
        head.Font = Enum.Font.GothamBold
        head.TextXAlignment = Enum.TextXAlignment.Left
        head.Parent = sec

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, -20, 0, 0)
        content.Position = UDim2.new(0, 10, 0, 28)
        content.BackgroundTransparency = 1
        content.Parent = sec

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 4)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = content

        local pad = Instance.new("Frame")
        pad.Size = UDim2.new(1, 0, 0, 8)
        pad.BackgroundTransparency = 1
        pad.LayoutOrder = 999
        pad.Parent = content

        content.ChildAdded:Connect(function()
            local h = 32
            for _, c in ipairs(content:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextButton") then h += c.AbsoluteSize.Y + 4 end
            end
            sec.Size = UDim2.new(1, -20, 0, h + 16)
        end)

        return content
    end

    local function createToggle(parent, text, default, callback, order)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 26)
        frame.BackgroundTransparency = 1
        frame.LayoutOrder = order or 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -44, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Colors.Text
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 36, 0, 18)
        toggle.Position = UDim2.new(1, -38, 0.5, -9)
        toggle.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
        toggle.BorderSizePixel = 0
        toggle.AutoButtonColor = false
        toggle.Text = ""
        toggle.Parent = frame
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 9)

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 14, 0, 14)
        circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
        circle.BorderSizePixel = 0
        circle.Parent = toggle
        Instance.new("UICorner", circle).CornerRadius = UDim.new(0, 7)

        local enabled = default
        local function flip()
            enabled = not enabled
            TweenService:Create(toggle, TweenInfo.new(0.15), {BackgroundColor3 = enabled and Colors.ToggleOn or Colors.ToggleOff}):Play()
            TweenService:Create(circle, TweenInfo.new(0.15), {Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
            callback(enabled)
        end
        toggle.MouseButton1Click:Connect(flip)
        toggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then flip() end
        end)
    end

    local function createSlider(parent, text, min, max, default, callback, order)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 44)
        frame.BackgroundTransparency = 1
        frame.LayoutOrder = order or 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 16)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default
        label.TextColor3 = Colors.SubText
        label.TextSize = 10
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 0, 6)
        bg.Position = UDim2.new(0, 0, 0, 22)
        bg.BackgroundColor3 = Colors.SliderBg
        bg.BorderSizePixel = 0
        bg.Parent = frame
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)

        local fill = Instance.new("Frame")
        local perc = (default - min) / (max - min)
        fill.Size = UDim2.new(perc, 0, 1, 0)
        fill.BackgroundColor3 = Colors.SliderFill
        fill.BorderSizePixel = 0
        fill.Parent = bg
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

        local thumb = Instance.new("TextButton")
        thumb.Size = UDim2.new(0, 14, 0, 14)
        thumb.Position = UDim2.new(perc, -7, 0.5, -7)
        thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
        thumb.BorderSizePixel = 0
        thumb.AutoButtonColor = false
        thumb.Text = ""
        thumb.Parent = bg
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 7)

        local dragging = false
        local val = default

        local function update(x)
            local rel = math.clamp((x - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            val = math.round((min + (max - min) * rel) * 100) / 100
            fill.Size = UDim2.new(rel, 0, 1, 0)
            thumb.Position = UDim2.new(rel, -7, 0.5, -7)
            label.Text = text .. ": " .. val
            callback(val)
        end

        local function onBegin(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input.Position.X)
            end
        end
        thumb.InputBegan:Connect(onBegin)
        bg.InputBegan:Connect(onBegin)

        local function onEnd(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end
        UserInputService.InputEnded:Connect(onEnd)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input.Position.X)
            end
        end)
    end

    local function createDropdown(parent, label, options, callback, order)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 28)
        frame.BackgroundTransparency = 1
        frame.LayoutOrder = order or 1
        frame.Parent = parent

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 24)
        btn.BackgroundColor3 = Colors.Dropdown
        btn.BorderSizePixel = 0
        btn.Text = "  " .. label .. ": Select..."
        btn.TextColor3 = Colors.SubText
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local list = Instance.new("ScrollingFrame")
        list.Size = UDim2.new(1, 0, 0, 100)
        list.Position = UDim2.new(0, 0, 0, 26)
        list.BackgroundColor3 = Colors.Dropdown
        list.BorderSizePixel = 0
        list.ScrollBarThickness = 4
        list.CanvasSize = UDim2.new(0, 0, 0, 0)
        list.Visible = false
        list.ZIndex = 10
        list.Parent = frame
        Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 1)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = list

        local function updateOpts(newOpts)
            for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            for _, opt in ipairs(newOpts) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 20)
                optBtn.BackgroundTransparency = 1
                optBtn.Text = "  " .. opt
                optBtn.TextColor3 = Colors.Text
                optBtn.TextSize = 10
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextXAlignment = Enum.TextXAlignment.Left
                optBtn.ZIndex = 10
                optBtn.Parent = list
                optBtn.MouseButton1Click:Connect(function()
                    btn.Text = "  " .. label .. ": " .. opt
                    list.Visible = false
                    callback(opt)
                end)
            end
            list.CanvasSize = UDim2.new(0, 0, 0, #newOpts * 21)
        end

        updateOpts(options)
        btn.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)
        return {UpdateList = updateOpts}
    end

    -- Заполнение вкладок
    local visPage = tabPages[1]
    local sESP = createSection(visPage, "ESP", 1)
    createToggle(sESP, "Enabled", false, function(v) WushHub.Settings.ESP.Enabled = v; UpdateESP() end, 1)
    createToggle(sESP, "Names", true, function(v) WushHub.Settings.ESP.Names = v end, 2)
    createToggle(sESP, "Distance", true, function(v) WushHub.Settings.ESP.Distance = v end, 3)
    createToggle(sESP, "Boxes", false, function(v) WushHub.Settings.ESP.Boxes = v end, 4)
    createToggle(sESP, "Lines", false, function(v) WushHub.Settings.ESP.Lines = v end, 5)
    createToggle(sESP, "Health", false, function(v) WushHub.Settings.ESP.Health = v end, 6)
    createToggle(sESP, "Tracers", false, function(v) WushHub.Settings.ESP.Tracers = v end, 7)

    local sChams = createSection(visPage, "Chams", 2)
    createToggle(sChams, "Enabled", false, function(v) WushHub.Settings.Chams.Enabled = v; UpdateChams() end, 1)

    local sWorld = createSection(visPage, "World", 3)
    createToggle(sWorld, "Fullbright", false, function(v) WushHub.Settings.World.Fullbright = v end, 1)
    createToggle(sWorld, "Xray", false, function(v) WushHub.Settings.World.Xray = v end, 2)
    createToggle(sWorld, "Low GFX", false, function(v) WushHub.Settings.World.LowGFX = v end, 3)
    createToggle(sWorld, "No Fog", false, function(v) WushHub.Settings.World.NoFog = v end, 4)
    createToggle(sWorld, "Disable Shadows", false, function(v) WushHub.Settings.World.DisableShadows = v end, 5)

    -- Player
    local plrPage = tabPages[2]
    local sMove = createSection(plrPage, "Movement", 1)
    createSlider(sMove, "WalkSpeed", 1, 200, 16, function(v) WushHub.Settings.Player.WalkSpeed = v end, 1)
    createSlider(sMove, "JumpPower", 1, 200, 50, function(v) WushHub.Settings.Player.JumpPower = v end, 2)
    createToggle(sMove, "Infinite Jump", false, function(v) WushHub.Settings.Player.InfiniteJump = v end, 3)

    local sNoClip = createSection(plrPage, "NoClip", 2)
    createToggle(sNoClip, "Enabled", false, function(v) WushHub.Settings.Player.NoClip = v; UpdateNoClip() end, 1)

    local sOther = createSection(plrPage, "Other", 3)
    createToggle(sOther, "Anti AFK", false, function(v) WushHub.Settings.Player.AntiAfk = v end, 1)

    -- Fun
    local funPage = tabPages[3]
    local sSpin = createSection(funPage, "Spin", 1)
    createToggle(sSpin, "Enabled", false, function(v) WushHub.Settings.Spin.Enabled = v end, 1)
    createSlider(sSpin, "Speed", 1, 50, 10, function(v) WushHub.Settings.Spin.Speed = v end, 2)

    local sOrbit = createSection(funPage, "Orbit", 2)
    createToggle(sOrbit, "Enabled", false, function(v) WushHub.Settings.Orbit.Enabled = v end, 1)
    createSlider(sOrbit, "Speed", 1, 20, 5, function(v) WushHub.Settings.Orbit.Speed = v end, 2)
    createSlider(sOrbit, "Radius", 0.5, 50, 10, function(v) WushHub.Settings.Orbit.Radius = v end, 3)
    createDropdown(sOrbit, "Target", getPlayers(), function(v) WushHub.Settings.Orbit.Target = v end, 4)

    local sSpam = createSection(funPage, "Chat Spam", 3)
    createToggle(sSpam, "Enabled", false, function(v) WushHub.Settings.Spam.Enabled = v end, 1)
    createSlider(sSpam, "Delay", 0.1, 5, 1, function(v) WushHub.Settings.Spam.Delay = v end, 2)

    local sMusic = createSection(funPage, "Music", 4)
    createToggle(sMusic, "Enabled", false, function(v) WushHub.Settings.Music.Enabled = v end, 1)
    createSlider(sMusic, "Volume", 0, 1, 0.5, function(v) WushHub.Settings.Music.Volume = v end, 2)

    -- Misc (Theme)
    local miscPage = tabPages[4]
    local sTheme = createSection(miscPage, "Theme", 1)
    createDropdown(sTheme, "Select Theme", ThemeNames, function(name)
        WushHub.Theme = name
        Colors = ThemeColors[name]
        local size = Main.AbsoluteSize
        local pos = Main.Position
        gui:Destroy()
        local newGui = CreateGUI()
        newGui.MainFrame.Size = UDim2.new(0, size.X, 0, size.Y)
        newGui.MainFrame.Position = pos
    end, 1)

    -- Server
    local serverPage = tabPages[5]
    local sHop = createSection(serverPage, "Server", 1)
    local btnHop = Instance.new("TextButton")
    btnHop.Size = UDim2.new(1, 0, 0, 30)
    btnHop.BackgroundColor3 = Colors.Button
    btnHop.Text = "🚀 Best Server"
    btnHop.TextColor3 = Color3.fromRGB(255,255,255)
    btnHop.Font = Enum.Font.GothamSemibold
    btnHop.TextSize = 11
    btnHop.Parent = sHop
    btnHop.LayoutOrder = 1
    Instance.new("UICorner", btnHop).CornerRadius = UDim.new(0, 6)
    btnHop.MouseButton1Click:Connect(function()
        safeCall(function()
            notify("Searching...")
            local d = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")
            local j = HttpService:JSONDecode(d)
            local s = {}
            for _, v in ipairs(j.data) do if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(s, v) end end
            table.sort(s, function(a,b) return a.playing < b.playing end)
            if #s > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, s[1].id, LocalPlayer) end
        end)
    end)

    -- Info
    local infoPage = tabPages[6]
    local sInfo = createSection(infoPage, "Info", 1)
    local infos = {
        {text = "🔧 WushHub v3.4", size = 14, bold = true, col = Colors.Accent},
        {text = "No Aimbot, Fly, AutoClicker", size = 11, col = Colors.Text},
        {text = "Made by wushfall", size = 11, col = Colors.Text},
        {text = "Discord: discord.gg/RHx2zkctT", size = 11, bold = true, col = Colors.Accent}
    }
    for i, info in ipairs(infos) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = info.text
        lbl.TextColor3 = info.col
        lbl.TextSize = info.size
        lbl.Font = info.bold and Enum.Font.GothamBold or Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = sInfo
        lbl.LayoutOrder = i
    end
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(1, 0, 0, 30)
    copyBtn.BackgroundColor3 = Colors.Button
    copyBtn.Text = "📎 Copy Discord"
    copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    copyBtn.Font = Enum.Font.GothamSemibold
    copyBtn.TextSize = 11
    copyBtn.Parent = sInfo
    copyBtn.LayoutOrder = 10
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/RHx2zkctT")
        notify("Copied!")
    end)

    -- Resize Triangle
    local resizeBtn = Instance.new("TextButton")
    resizeBtn.Size = UDim2.new(0, 32, 0, 32)
    resizeBtn.Position = UDim2.new(1, -32, 1, -32)
    resizeBtn.BackgroundColor3 = Colors.Accent
    resizeBtn.Text = "◢"
    resizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    resizeBtn.TextSize = 20
    resizeBtn.Font = Enum.Font.GothamBold
    resizeBtn.ZIndex = 5
    resizeBtn.Parent = Main
    Instance.new("UICorner", resizeBtn).CornerRadius = UDim.new(0, 0)

    local resizing = false
    local minSize = Vector2.new(300, 250)
    resizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
            resizeBtn.BackgroundColor3 = Colors.Accent
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position
            local newX = math.max(minSize.X, mousePos.X - Main.AbsolutePosition.X)
            local newY = math.max(minSize.Y, mousePos.Y - Main.AbsolutePosition.Y)
            Main.Size = UDim2.new(0, newX, 0, newY)
        end
    end)

    gui.MainFrame = Main
    return gui
end

local gui = CreateGUI()

LocalPlayer.OnTeleport:Connect(function()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    ClearESP()
    if musicSound then musicSound:Stop(); musicSound:Destroy(); musicSound = nil end
    if gui then gui:Destroy() end
end)

task.spawn(function()
    task.wait(1)
    local wm = Instance.new("ScreenGui")
    wm.Name = "WushWM"
    wm.Parent = CoreGui
    wm.ResetOnSpawn = false
    local wml = Instance.new("TextLabel")
    wml.Size = UDim2.new(0, 120, 0, 18)
    wml.Position = UDim2.new(1, -125, 1, -22)
    wml.BackgroundTransparency = 1
    wml.Text = "WushHub Loaded"
    wml.TextColor3 = Colors.Accent
    wml.TextTransparency = 0.5
    wml.TextSize = 10
    wml.Font = Enum.Font.GothamBold
    wml.TextXAlignment = Enum.TextXAlignment.Right
    wml.Parent = wm
end)

notify("WushHub v3.4 Ready ✅")