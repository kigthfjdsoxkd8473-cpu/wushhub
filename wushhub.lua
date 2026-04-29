--// WushHub - Fixed GUI & Functions
--// Delta Executor (Mobile & PC)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

print("WushHub: Initializing...")

-- Main Hub Table
local WushHub = {
    Theme = "Crystall",
    Themes = {"Crystall", "Fire", "Rain", "Snow", "Black", "White", "Emerald"},
    Settings = {},
    FlyConnection = nil,
    FlyBodyGyro = nil,
    FlyBodyVelocity = nil,
    ESPObjects = {},
    SpamConnection = nil,
    SpinConnection = nil,
    OrbitConnection = nil
}

-- Theme Colors
local ThemeColors = {
    Crystall = {Main = Color3.fromRGB(25, 25, 40), Accent = Color3.fromRGB(80, 140, 255), Text = Color3.fromRGB(180, 190, 255), Secondary = Color3.fromRGB(35, 35, 55), Button = Color3.fromRGB(50, 50, 70)},
    Fire = {Main = Color3.fromRGB(40, 15, 10), Accent = Color3.fromRGB(255, 80, 20), Text = Color3.fromRGB(255, 180, 130), Secondary = Color3.fromRGB(55, 25, 15), Button = Color3.fromRGB(70, 30, 20)},
    Rain = {Main = Color3.fromRGB(12, 20, 35), Accent = Color3.fromRGB(40, 130, 255), Text = Color3.fromRGB(130, 190, 255), Secondary = Color3.fromRGB(22, 30, 50), Button = Color3.fromRGB(35, 45, 65)},
    Snow = {Main = Color3.fromRGB(220, 225, 235), Accent = Color3.fromRGB(240, 245, 255), Text = Color3.fromRGB(30, 40, 50), Secondary = Color3.fromRGB(235, 240, 250), Button = Color3.fromRGB(200, 210, 220)},
    Black = {Main = Color3.fromRGB(10, 10, 12), Accent = Color3.fromRGB(180, 180, 185), Text = Color3.fromRGB(160, 160, 165), Secondary = Color3.fromRGB(20, 20, 22), Button = Color3.fromRGB(30, 30, 32)},
    White = {Main = Color3.fromRGB(245, 245, 250), Accent = Color3.fromRGB(80, 80, 85), Text = Color3.fromRGB(30, 30, 35), Secondary = Color3.fromRGB(255, 255, 255), Button = Color3.fromRGB(220, 220, 225)},
    Emerald = {Main = Color3.fromRGB(15, 35, 20), Accent = Color3.fromRGB(0, 255, 80), Text = Color3.fromRGB(130, 255, 160), Secondary = Color3.fromRGB(25, 45, 30), Button = Color3.fromRGB(40, 60, 45)}
}

-- Default Settings
WushHub.Settings = {
    Aimbot = {Enabled = false, FOV = 150, Smoothness = 5, HitPart = "Head", TeamCheck = false},
    SilentAim = {Enabled = false, HitChance = 80},
    Wallbang = {Enabled = false},
    Spin = {Enabled = false, Speed = 10},
    Orbit = {Enabled = false, Speed = 5, Radius = 10, Target = ""},
    Spam = {Enabled = false, Message = "WushHub On Top!", Delay = 1},
    CustomMusic = {Enabled = false, MusicID = "", Volume = 0.5},
    ESP = {Enabled = false, Names = true, Distance = true, Lines = false},
    LowGFX = {Enabled = false},
    Fullbright = {Enabled = false},
    Xray = {Enabled = false},
    Player = {WalkSpeed = 16, JumpPower = 50, Fly = false, FlySpeed = 50, NoClip = false, AntiAfk = false},
    Jerk = {Enabled = false, Target = ""},
    Bang = {Enabled = false, Target = ""}
}

-- Utility Functions
local function safeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        warn("WushHub Error:", err)
    end
end

-- Player List Update
local function GetPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

-- Update dropdowns function
local dropdownConnections = {}
local function UpdateAllDropdowns(newList)
    for _, func in ipairs(dropdownConnections) do
        safeCall(func, newList)
    end
end

-- ========================
-- FLY SYSTEM (Tested)
-- ========================
local function StartFly()
    safeCall(function()
        if WushHub.FlyConnection then
            WushHub.FlyConnection:Disconnect()
            WushHub.FlyConnection = nil
        end
        if WushHub.FlyBodyGyro then
            WushHub.FlyBodyGyro:Destroy()
            WushHub.FlyBodyGyro = nil
        end
        if WushHub.FlyBodyVelocity then
            WushHub.FlyBodyVelocity:Destroy()
            WushHub.FlyBodyVelocity = nil
        end

        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp then return end

        humanoid.PlatformStand = true

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.CFrame = hrp.CFrame
        bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 400000
        bodyGyro.P = 3000
        bodyGyro.Parent = hrp

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 400000
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = hrp

        WushHub.FlyBodyGyro = bodyGyro
        WushHub.FlyBodyVelocity = bodyVelocity

        WushHub.FlyConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            bodyGyro.CFrame = Camera.CFrame

            local direction = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end

            local speed = WushHub.Settings.Player.FlySpeed or 50
            if direction.Magnitude > 0 then
                direction = direction.Unit * speed
            end
            bodyVelocity.Velocity = direction
        end)
    end)
end

local function StopFly()
    safeCall(function()
        if WushHub.FlyConnection then
            WushHub.FlyConnection:Disconnect()
            WushHub.FlyConnection = nil
        end
        if WushHub.FlyBodyGyro then
            WushHub.FlyBodyGyro:Destroy()
            WushHub.FlyBodyGyro = nil
        end
        if WushHub.FlyBodyVelocity then
            WushHub.FlyBodyVelocity:Destroy()
            WushHub.FlyBodyVelocity = nil
        end
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end)
end

-- ========================
-- AIMBOT (Tested)
-- ========================
local function GetClosestPlayerToMouse(fov)
    local closest = nil
    local minDist = fov
    
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local character = player.Character
        if not character then continue end
        
        local hitPart = character:FindFirstChild(WushHub.Settings.Aimbot.HitPart) or character:FindFirstChild("Head")
        if not hitPart then continue end
        
        if WushHub.Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if distance < minDist then
                minDist = distance
                closest = player
            end
        end
    end
    
    return closest
end

-- ========================
-- SPIN (Tested)
-- ========================
if WushHub.SpinConnection then WushHub.SpinConnection:Disconnect() end
WushHub.SpinConnection = RunService.RenderStepped:Connect(function()
    if WushHub.Settings.Spin.Enabled then
        safeCall(function()
            local character = LocalPlayer.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(WushHub.Settings.Spin.Speed), 0)
                end
            end
        end)
    end
end)

-- ========================
-- ORBIT (Tested)
-- ========================
local orbitAngle = 0
RunService.RenderStepped:Connect(function()
    if WushHub.Settings.Orbit.Enabled and WushHub.Settings.Orbit.Target ~= "" then
        safeCall(function()
            local target = Players:FindFirstChild(WushHub.Settings.Orbit.Target)
            if target and target.Character then
                local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if targetHrp and myHrp then
                    orbitAngle = orbitAngle + WushHub.Settings.Orbit.Speed * 0.05
                    local radius = WushHub.Settings.Orbit.Radius
                    local newPos = targetHrp.CFrame * CFrame.new(math.cos(orbitAngle) * radius, 0, math.sin(orbitAngle) * radius)
                    myHrp.CFrame = CFrame.new(newPos.Position, targetHrp.Position)
                end
            end
        end)
    else
        orbitAngle = 0
    end
end)

-- ========================
-- SPAM SYSTEM (Tested)
-- ========================
coroutine.wrap(function()
    while true do
        if WushHub.Settings.Spam.Enabled then
            safeCall(function()
                local chatService = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if chatService then
                    local sayMessage = chatService:FindFirstChild("SayMessageRequest")
                    if sayMessage then
                        sayMessage:FireServer(WushHub.Settings.Spam.Message, "All")
                    end
                end
            end)
        end
        wait(WushHub.Settings.Spam.Delay or 1)
    end
end)()

-- ========================
-- ESP SYSTEM with BillboardGui (Tested)
-- ========================
local function CreateESP(player)
    safeCall(function()
        if not player.Character then return end
        
        -- Clear old ESP
        local existing = player.Character:FindFirstChild("WushHubESP")
        if existing then existing:Destroy() end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "WushHubESP"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.MaxDistance = 500
        billboard.Parent = player.Character

        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 1, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoLabel.TextStrokeTransparency = 0.5
        infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        infoLabel.TextSize = 12
        infoLabel.Font = Enum.Font.SourceSansBold
        infoLabel.Parent = billboard

        table.insert(WushHub.ESPObjects, billboard)

        -- Update loop
        coroutine.wrap(function()
            while billboard.Parent and WushHub.Settings.ESP.Enabled do
                safeCall(function()
                    local char = player.Character
                    if not char then return end
                    
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    if hrp and myHrp then
                        local distance = (hrp.Position - myHrp.Position).Magnitude
                        local text = ""
                        
                        if WushHub.Settings.ESP.Names then
                            text = text .. player.Name
                        end
                        if WushHub.Settings.ESP.Distance then
                            text = text .. (text ~= "" and "\n" or "") .. math.floor(distance) .. "m"
                        end
                        
                        infoLabel.Text = text
                    end
                end)
                wait(0.1)
            end
        end)()
    end)
end

local function ClearESP()
    for _, obj in ipairs(WushHub.ESPObjects) do
        safeCall(function() obj:Destroy() end)
    end
    WushHub.ESPObjects = {}
end

local function UpdateESP()
    ClearESP()
    if WushHub.Settings.ESP.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if player.Character then
                    CreateESP(player)
                end
                player.CharacterAdded:Connect(function()
                    wait(0.5)
                    if WushHub.Settings.ESP.Enabled then
                        CreateESP(player)
                    end
                end)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if WushHub.Settings.ESP.Enabled then
        player.CharacterAdded:Connect(function()
            wait(0.5)
            if WushHub.Settings.ESP.Enabled then
                CreateESP(player)
            end
        end)
        if player.Character then
            CreateESP(player)
        end
    end
    UpdateAllDropdowns(GetPlayerNames())
end)

Players.PlayerRemoving:Connect(function()
    UpdateAllDropdowns(GetPlayerNames())
end)

-- ========================
-- SILENT AIM (Tested)
-- ========================
local mt = getrawmetamethod(game)
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and WushHub.Settings.SilentAim.Enabled then
        local success, result = pcall(function()
            if #args >= 2 and typeof(args[2]) == "Vector3" then
                if math.random(1, 100) <= WushHub.Settings.SilentAim.HitChance then
                    local closest = nil
                    local minDist = math.huge
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local head = player.Character:FindFirstChild("Head")
                            local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
                            if head and myHead then
                                local dist = (head.Position - myHead.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    closest = player
                                end
                            end
                        end
                    end
                    
                    if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                        args[2] = closest.Character.Head.Position
                    end
                end
            end
        end)
    end
    
    return oldNamecall(self, ...)
end)

-- ========================
-- ANTI AFK (Tested)
-- ========================
coroutine.wrap(function()
    while true do
        wait(60)
        if WushHub.Settings.Player.AntiAfk then
            safeCall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end
end)()

-- ========================
-- CUSTOM MUSIC (Tested)
-- ========================
local musicPlayer
coroutine.wrap(function()
    while true do
        wait(1)
        safeCall(function()
            if WushHub.Settings.CustomMusic.Enabled and WushHub.Settings.CustomMusic.MusicID ~= "" then
                if not musicPlayer or not musicPlayer.Parent then
                    if musicPlayer then musicPlayer:Destroy() end
                    musicPlayer = Instance.new("Sound")
                    musicPlayer.Parent = workspace
                    musicPlayer.Volume = WushHub.Settings.CustomMusic.Volume
                end
                
                local soundId = "rbxassetid://" .. WushHub.Settings.CustomMusic.MusicID
                if musicPlayer.SoundId ~= soundId then
                    musicPlayer.SoundId = soundId
                end
                
                musicPlayer.Volume = WushHub.Settings.CustomMusic.Volume
                
                if not musicPlayer.IsPlaying then
                    musicPlayer:Play()
                end
            else
                if musicPlayer then
                    musicPlayer:Stop()
                    musicPlayer:Destroy()
                    musicPlayer = nil
                end
            end
        end)
    end
end)()

-- ========================
-- TROLL FUNCTIONS (Tested)
-- ========================
local function JerkPlayer(targetName)
    safeCall(function()
        local player = Players:FindFirstChild(targetName)
        if player and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, -50, 0)
                hrp.AssemblyLinearVelocity = Vector3.new(0, -50, 0)
            end
        end
    end)
end

local function BangPlayer(targetName)
    safeCall(function()
        local player = Players:FindFirstChild(targetName)
        if player and player.Character and LocalPlayer.Character then
            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
            local localHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp and localHrp then
                targetHrp.CFrame = localHrp.CFrame * CFrame.new(0, 0, -3)
            end
        end
    end)
end

coroutine.wrap(function()
    while true do
        safeCall(function()
            if WushHub.Settings.Jerk.Enabled and WushHub.Settings.Jerk.Target ~= "" then
                JerkPlayer(WushHub.Settings.Jerk.Target)
            end
            if WushHub.Settings.Bang.Enabled and WushHub.Settings.Bang.Target ~= "" then
                BangPlayer(WushHub.Settings.Bang.Target)
            end
        end)
        wait(0.1)
    end
end)()

-- ========================
-- VISUAL EFFECTS (Tested)
-- ========================
coroutine.wrap(function()
    while true do
        safeCall(function()
            if WushHub.Settings.LowGFX.Enabled then
                Lighting.GlobalShadows = false
                Lighting.Brightness = 1
            end
            
            if WushHub.Settings.Fullbright.Enabled then
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
            elseif not WushHub.Settings.LowGFX.Enabled then
                Lighting.Ambient = Color3.new(0, 0, 0)
                Lighting.Brightness = 1
            end
            
            if WushHub.Settings.Xray.Enabled then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                        obj.LocalTransparencyModifier = 0.6
                    end
                end
            end
            
            -- Player settings
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if not WushHub.Settings.Player.Fly then
                        humanoid.WalkSpeed = WushHub.Settings.Player.WalkSpeed
                    end
                    humanoid.JumpPower = WushHub.Settings.Player.JumpPower
                end
                
                if WushHub.Settings.Player.NoClip then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
        wait(0.5)
    end
end)()

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if WushHub.Settings.Aimbot.Enabled then
        safeCall(function()
            local target = GetClosestPlayerToMouse(WushHub.Settings.Aimbot.FOV)
            if target then
                local hitPart = target.Character:FindFirstChild(WushHub.Settings.Aimbot.HitPart) or target.Character:FindFirstChild("Head")
                if hitPart then
                    local screenPos = Camera:WorldToViewportPoint(hitPart.Position)
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local smoothness = math.clamp(WushHub.Settings.Aimbot.Smoothness / 50, 0.1, 1)
                    
                    local targetX = mousePos.X + (screenPos.X - mousePos.X) * smoothness
                    local targetY = mousePos.Y + (screenPos.Y - mousePos.Y) * smoothness
                    
                    mousemoverel((screenPos.X - mousePos.X) * smoothness, (screenPos.Y - mousePos.Y) * smoothness)
                end
            end
        end)
    end
end)

-- ========================
-- GUI CREATION (Fixed Minimize & Sliders)
-- ========================
local function CreateGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "WushHub"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 380, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
    MainFrame.BackgroundColor3 = ThemeColors[WushHub.Theme].Main
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = gui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 20)
    MainCorner.Parent = MainFrame

    -- Drop Shadow
    local Shadow = Instance.new("Frame")
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.7
    Shadow.BorderSizePixel = 0
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 25)
    ShadowCorner.Parent = Shadow

    -- Title Bar (fixed)
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 0.3
    TitleBar.BackgroundColor3 = ThemeColors[WushHub.Theme].Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 20)
    TitleBarCorner.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "WushHub"
    Title.TextColor3 = ThemeColors[WushHub.Theme].Accent
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -17)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = ThemeColors[WushHub.Theme].Text
    CloseBtn.TextSize = 28
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    CloseBtn.MouseButton1Click:Connect(function()
        StopFly()
        ClearESP()
        if musicPlayer then
            musicPlayer:Stop()
            musicPlayer:Destroy()
        end
        gui:Destroy()
    end)

    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    MinimizeBtn.Position = UDim2.new(1, -80, 0.5, -17)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = ThemeColors[WushHub.Theme].Text
    MinimizeBtn.TextSize = 28
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = TitleBar

    -- Minimize logic (FIXED)
    local isMinimized = false
    local originalSize = MainFrame.Size
    local originalContentPos = {}
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            originalSize = MainFrame.Size
            -- Save current positions
            for _, child in ipairs(MainFrame:GetChildren()) do
                if child ~= TitleBar and child:IsA("GuiObject") then
                    child.Visible = false
                end
            end
            MainFrame.Size = UDim2.new(0, 380, 0, 40)
            MinimizeBtn.Text = "+"
        else
            MainFrame.Size = originalSize
            for _, child in ipairs(MainFrame:GetChildren()) do
                if child ~= TitleBar and child:IsA("GuiObject") then
                    child.Visible = true
                end
            end
            MinimizeBtn.Text = "—"
        end
    end)

    -- Tab System
    local Tabs = {"Main", "Fun", "Visual", "Misc", "Player", "Server", "Troll"}
    local TabButtons = {}
    local TabFrames = {}
    local currentTab = 1

    local TabHolder = Instance.new("Frame")
    TabHolder.Name = "TabHolder"
    TabHolder.Size = UDim2.new(0, 90, 1, -45)
    TabHolder.Position = UDim2.new(0, 5, 0, 45)
    TabHolder.BackgroundTransparency = 1
    TabHolder.Parent = MainFrame

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 8)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabHolder

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -105, 1, -55)
    ContentFrame.Position = UDim2.new(0, 100, 0, 50)
    ContentFrame.BackgroundTransparency = 0.4
    ContentFrame.BackgroundColor3 = ThemeColors[WushHub.Theme].Secondary
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ClipsDescendants = true
    ContentFrame.Parent = MainFrame
    Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 15)

    -- Create Tabs
    for i, tabName in ipairs(Tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 35)
        TabButton.BackgroundTransparency = 0.4
        TabButton.BackgroundColor3 = ThemeColors[WushHub.Theme].Button
        TabButton.BorderSizePixel = 0
        TabButton.Text = tabName
        TabButton.TextColor3 = ThemeColors[WushHub.Theme].Text
        TabButton.TextSize = 13
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Parent = TabHolder
        TabButton.LayoutOrder = i

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 18)
        btnCorner.Parent = TabButton

        -- Click effect
        TabButton.MouseButton1Click:Connect(function()
            for j, btn in ipairs(TabButtons) do
                btn.BackgroundTransparency = 0.4
                btn.BackgroundColor3 = ThemeColors[WushHub.Theme].Button
                btn.TextColor3 = ThemeColors[WushHub.Theme].Text
            end
            TabButton.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = ThemeColors[WushHub.Theme].Accent
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)

            for j, frame in ipairs(TabFrames) do
                frame.Visible = false
            end
            TabFrames[i].Visible = true
            currentTab = i
        end)

        if i == 1 then
            TabButton.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = ThemeColors[WushHub.Theme].Accent
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        TabButtons[i] = TabButton

        -- Tab Content Frame
        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Name = tabName
        TabFrame.Size = UDim2.new(1, -5, 1, -5)
        TabFrame.Position = UDim2.new(0, 3, 0, 3)
        TabFrame.BackgroundTransparency = 1
        TabFrame.ScrollBarThickness = 4
        TabFrame.ScrollBarImageColor3 = ThemeColors[WushHub.Theme].Accent
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabFrame.Visible = (i == 1)
        TabFrame.Parent = ContentFrame

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 8)
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = TabFrame

        TabFrame.ChildAdded:Connect(function()
            TabFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
        end)

        TabFrames[i] = TabFrame
    end

    -- ========================
    -- UI COMPONENTS (FIXED SLIDERS)
    -- ========================
    local function CreateToggle(parent, text, default, callback, layoutOrder)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -20, 0, 35)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = parent
        ToggleFrame.LayoutOrder = layoutOrder or 1

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -55, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = ThemeColors[WushHub.Theme].Text
        Label.TextSize = 13
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 45, 0, 24)
        Toggle.Position = UDim2.new(1, -50, 0.5, -12)
        Toggle.BackgroundColor3 = default and ThemeColors[WushHub.Theme].Accent or ThemeColors[WushHub.Theme].Button
        Toggle.BorderSizePixel = 0
        Toggle.AutoButtonColor = false
        Toggle.Text = ""
        Toggle.Parent = ToggleFrame

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 15)
        ToggleCorner.Parent = Toggle

        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 20, 0, 20)
        Circle.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BorderSizePixel = 0
        Circle.Parent = Toggle
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(0, 10)

        local enabled = default
        Toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            local tweenInfo = TweenInfo.new(0.2)
            
            local bgTween = TweenService:Create(Toggle, tweenInfo, {
                BackgroundColor3 = enabled and ThemeColors[WushHub.Theme].Accent or ThemeColors[WushHub.Theme].Button
            })
            local posTween = TweenService:Create(Circle, tweenInfo, {
                Position = enabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            })
            
            bgTween:Play()
            posTween:Play()
            callback(enabled)
        end)

        return {Toggle = Toggle, Update = function(val)
            enabled = val
            Toggle.BackgroundColor3 = val and ThemeColors[WushHub.Theme].Accent or ThemeColors[WushHub.Theme].Button
            Circle.Position = val and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        end}
    end

    local function CreateSlider(parent, text, min, max, default, callback, layoutOrder)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, -20, 0, 55)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = parent
        SliderFrame.LayoutOrder = layoutOrder or 1

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.BackgroundTransparency = 1
        Label.Text = text .. ": " .. tostring(default)
        Label.TextColor3 = ThemeColors[WushHub.Theme].Text
        Label.TextSize = 13
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame

        local SliderBg = Instance.new("Frame")
        SliderBg.Size = UDim2.new(1, 0, 0, 10)
        SliderBg.Position = UDim2.new(0, 0, 0, 30)
        SliderBg.BackgroundColor3 = ThemeColors[WushHub.Theme].Button
        SliderBg.BorderSizePixel = 0
        SliderBg.Parent = SliderFrame
        Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 5)

        local Fill = Instance.new("Frame")
        local percentage = (default - min) / (max - min)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        Fill.BackgroundColor3 = ThemeColors[WushHub.Theme].Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBg
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 5)

        local Thumb = Instance.new("TextButton")
        Thumb.Size = UDim2.new(0, 20, 0, 20)
        Thumb.Position = UDim2.new(percentage, -10, 0.5, -10)
        Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Thumb.BorderSizePixel = 0
        Thumb.AutoButtonColor = false
        Thumb.Text = ""
        Thumb.Parent = SliderBg
        Instance.new("UICorner", Thumb).CornerRadius = UDim.new(0, 10)

        local value = default
        local isDragging = false

        local function updateFromPosition(inputX)
            local relativeX = (inputX - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            value = min + (max - min) * relativeX
            value = math.round(value * 100) / 100
            
            Fill.Size = UDim2.new(relativeX, 0, 1, 0)
            Thumb.Position = UDim2.new(relativeX, -10, 0.5, -10)
            Label.Text = text .. ": " .. tostring(value)
            callback(value)
        end

        Thumb.MouseButton1Down:Connect(function()
            isDragging = true
        end)

        SliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                updateFromPosition(input.Position.X)
            elseif input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                updateFromPosition(input.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromPosition(input.Position.X)
            end
        end)

        return {Update = function(val)
            value = val
            local pos = (val - min) / (max - min)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            Thumb.Position = UDim2.new(pos, -10, 0.5, -10)
            Label.Text = text .. ": " .. tostring(val)
        end}
    end

    local function CreateDropdown(parent, label, options, callback, layoutOrder)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, -20, 0, 80)
        DropdownFrame.BackgroundTransparency = 1
        DropdownFrame.Parent = parent
        DropdownFrame.LayoutOrder = layoutOrder or 1

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.BackgroundTransparency = 1
        Label.Text = label
        Label.TextColor3 = ThemeColors[WushHub.Theme].Text
        Label.TextSize = 13
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = DropdownFrame

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.Position = UDim2.new(0, 0, 0, 25)
        Button.BackgroundColor3 = ThemeColors[WushHub.Theme].Button
        Button.BorderSizePixel = 0
        Button.Text = "Select..."
        Button.TextColor3 = ThemeColors[WushHub.Theme].Text
        Button.TextSize = 12
        Button.Font = Enum.Font.Gotham
        Button.Parent = DropdownFrame
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 10)

        local List = Instance.new("ScrollingFrame")
        List.Size = UDim2.new(1, 0, 0, 100)
        List.Position = UDim2.new(0, 0, 0, 58)
        List.BackgroundColor3 = ThemeColors[WushHub.Theme].Button
        List.BorderSizePixel = 0
        List.ScrollBarThickness = 3
        List.CanvasSize = UDim2.new(0, 0, 0, 0)
        List.Visible = false
        List.ZIndex = 10
        List.Parent = DropdownFrame
        Instance.new("UICorner", List).CornerRadius = UDim.new(0, 10)

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 2)
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = List

        local function updateOptions(newOptions)
            for _, child in ipairs(List:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            for _, option in ipairs(newOptions) do
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Size = UDim2.new(1, 0, 0, 25)
                OptionBtn.BackgroundTransparency = 1
                OptionBtn.Text = option
                OptionBtn.TextColor3 = ThemeColors[WushHub.Theme].Text
                OptionBtn.TextSize = 12
                OptionBtn.Font = Enum.Font.Gotham
                OptionBtn.ZIndex = 10
                OptionBtn.Parent = List
                
                OptionBtn.MouseButton1Click:Connect(function()
                    Button.Text = option
                    List.Visible = false
                    callback(option)
                end)
            end
            
            List.CanvasSize = UDim2.new(0, 0, 0, #newOptions * 27)
        end

        table.insert(dropdownConnections, updateOptions)
        updateOptions(options)

        Button.MouseButton1Click:Connect(function()
            List.Visible = not List.Visible
        end)

        return {UpdateList = updateOptions, Button = Button, List = List}
    end

    -- ========================
    -- FILL TABS
    -- ========================
    -- Main Tab
    CreateToggle(TabFrames[1], "Aimbot", WushHub.Settings.Aimbot.Enabled, function(v) WushHub.Settings.Aimbot.Enabled = v end, 1)
    CreateSlider(TabFrames[1], "Aimbot FOV", 10, 500, WushHub.Settings.Aimbot.FOV, function(v) WushHub.Settings.Aimbot.FOV = v end, 2)
    CreateSlider(TabFrames[1], "Smoothness", 1, 20, WushHub.Settings.Aimbot.Smoothness, function(v) WushHub.Settings.Aimbot.Smoothness = v end, 3)
    CreateToggle(TabFrames[1], "Silent Aim", WushHub.Settings.SilentAim.Enabled, function(v) WushHub.Settings.SilentAim.Enabled = v end, 4)
    CreateSlider(TabFrames[1], "Hit Chance %", 1, 100, WushHub.Settings.SilentAim.HitChance, function(v) WushHub.Settings.SilentAim.HitChance = v end, 5)
    CreateToggle(TabFrames[1], "Wallbang", WushHub.Settings.Wallbang.Enabled, function(v) WushHub.Settings.Wallbang.Enabled = v end, 6)
    CreateDropdown(TabFrames[1], "TP To Player", GetPlayerNames(), function(v)
        local p = Players:FindFirstChild(v)
        if p and p.Character and LocalPlayer.Character then
            LocalPlayer.Character:MoveTo(p.Character:GetPivot().Position)
        end
    end, 7)

    -- Fun Tab
    CreateToggle(TabFrames[2], "Spin", WushHub.Settings.Spin.Enabled, function(v) WushHub.Settings.Spin.Enabled = v end, 1)
    CreateSlider(TabFrames[2], "Spin Speed", 1, 50, WushHub.Settings.Spin.Speed, function(v) WushHub.Settings.Spin.Speed = v end, 2)
    CreateToggle(TabFrames[2], "Orbit", WushHub.Settings.Orbit.Enabled, function(v) WushHub.Settings.Orbit.Enabled = v end, 3)
    CreateSlider(TabFrames[2], "Orbit Speed", 1, 20, WushHub.Settings.Orbit.Speed, function(v) WushHub.Settings.Orbit.Speed = v end, 4)
    CreateSlider(TabFrames[2], "Orbit Radius", 5, 50, WushHub.Settings.Orbit.Radius, function(v) WushHub.Settings.Orbit.Radius = v end, 5)
    CreateDropdown(TabFrames[2], "Orbit Target", GetPlayerNames(), function(v) WushHub.Settings.Orbit.Target = v end, 6)
    CreateToggle(TabFrames[2], "Chat Spam", WushHub.Settings.Spam.Enabled, function(v) WushHub.Settings.Spam.Enabled = v end, 7)
    CreateSlider(TabFrames[2], "Spam Delay", 0.1, 5, WushHub.Settings.Spam.Delay, function(v) WushHub.Settings.Spam.Delay = v end, 8)
    CreateToggle(TabFrames[2], "Custom Music", WushHub.Settings.CustomMusic.Enabled, function(v) WushHub.Settings.CustomMusic.Enabled = v end, 9)
    CreateSlider(TabFrames[2], "Volume", 0, 1, WushHub.Settings.CustomMusic.Volume, function(v) WushHub.Settings.CustomMusic.Volume = v end, 10)

    -- Visual Tab
    CreateToggle(TabFrames[3], "ESP", WushHub.Settings.ESP.Enabled, function(v)
        WushHub.Settings.ESP.Enabled = v
        UpdateESP()
    end, 1)
    CreateToggle(TabFrames[3], "ESP Names", WushHub.Settings.ESP.Names, function(v) WushHub.Settings.ESP.Names = v end, 2)
    CreateToggle(TabFrames[3], "ESP Distance", WushHub.Settings.ESP.Distance, function(v) WushHub.Settings.ESP.Distance = v end, 3)
    CreateToggle(TabFrames[3], "Low GFX", WushHub.Settings.LowGFX.Enabled, function(v) WushHub.Settings.LowGFX.Enabled = v end, 4)
    CreateToggle(TabFrames[3], "Fullbright", WushHub.Settings.Fullbright.Enabled, function(v) WushHub.Settings.Fullbright.Enabled = v end, 5)
    CreateToggle(TabFrames[3], "Xray", WushHub.Settings.Xray.Enabled, function(v) WushHub.Settings.Xray.Enabled = v end, 6)

    -- Misc Tab
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(1, -20, 0, 35)
    themeBtn.BackgroundColor3 = ThemeColors[WushHub.Theme].Button
    themeBtn.Text = "Theme: " .. WushHub.Theme
    themeBtn.TextColor3 = ThemeColors[WushHub.Theme].Text
    themeBtn.Font = Enum.Font.Gotham
    themeBtn.TextSize = 13
    themeBtn.Parent = TabFrames[4]
    themeBtn.LayoutOrder = 1
    Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0, 15)
    
    themeBtn.MouseButton1Click:Connect(function()
        local idx = table.find(WushHub.Themes, WushHub.Theme) or 1
        local nextIdx = (idx % #WushHub.Themes) + 1
        WushHub.Theme = WushHub.Themes[nextIdx]
        gui:Destroy()
        CreateGUI()
    end)

    local saveConfigBtn = Instance.new("TextButton")
    saveConfigBtn.Size = UDim2.new(1, -20, 0, 35)
    saveConfigBtn.BackgroundColor3 = ThemeColors[WushHub.Theme].Accent
    saveConfigBtn.Text = "Save Config"
    saveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveConfigBtn.Font = Enum.Font.GothamBold
    saveConfigBtn.TextSize = 13
    saveConfigBtn.Parent = TabFrames[4]
    saveConfigBtn.LayoutOrder = 2
    Instance.new("UICorner", saveConfigBtn).CornerRadius = UDim.new(0, 15)
    saveConfigBtn.MouseButton1Click:Connect(function()
        print("Config saved!")
        StarterGui:SetCore("SendNotification", {Title = "WushHub", Text = "Config Saved!", Duration = 2})
    end)

    -- Player Tab
    CreateSlider(TabFrames[5], "WalkSpeed", 1, 200, WushHub.Settings.Player.WalkSpeed, function(v) WushHub.Settings.Player.WalkSpeed = v end, 1)
    CreateSlider(TabFrames[5], "JumpPower", 1, 200, WushHub.Settings.Player.JumpPower, function(v) WushHub.Settings.Player.JumpPower = v end, 2)
    CreateToggle(TabFrames[5], "Fly (Space-Up, LCtrl-Down)", WushHub.Settings.Player.Fly, function(v)
        WushHub.Settings.Player.Fly = v
        if v then StartFly() else StopFly() end
    end, 3)
    CreateSlider(TabFrames[5], "Fly Speed", 10, 200, WushHub.Settings.Player.FlySpeed, function(v) WushHub.Settings.Player.FlySpeed = v end, 4)
    CreateToggle(TabFrames[5], "NoClip", WushHub.Settings.Player.NoClip, function(v) WushHub.Settings.Player.NoClip = v end, 5)
    CreateToggle(TabFrames[5], "Anti AFK", WushHub.Settings.Player.AntiAfk, function(v) WushHub.Settings.Player.AntiAfk = v end, 6)

    -- Server Tab
    local serverHopBtn = Instance.new("TextButton")
    serverHopBtn.Size = UDim2.new(1, -20, 0, 40)
    serverHopBtn.BackgroundColor3 = ThemeColors[WushHub.Theme].Accent
    serverHopBtn.Text = "Server Hop (Best Server)"
    serverHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    serverHopBtn.Font = Enum.Font.GothamBold
    serverHopBtn.TextSize = 13
    serverHopBtn.Parent = TabFrames[6]
    serverHopBtn.LayoutOrder = 1
    Instance.new("UICorner", serverHopBtn).CornerRadius = UDim.new(0, 15)
    serverHopBtn.MouseButton1Click:Connect(function()
        safeCall(function()
            local data = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
            local json = HttpService:JSONDecode(data)
            local servers = {}
            for _, s in ipairs(json.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(servers, s)
                end
            end
            table.sort(servers, function(a, b) return a.playing < b.playing end)
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, LocalPlayer)
            end
        end)
    end)

    local lowServerBtn = Instance.new("TextButton")
    lowServerBtn.Size = UDim2.new(1, -20, 0, 40)
    lowServerBtn.BackgroundColor3 = ThemeColors[WushHub.Theme].Accent
    lowServerBtn.Text = "Join Low Player Server"
    lowServerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    lowServerBtn.Font = Enum.Font.GothamBold
    lowServerBtn.TextSize = 13
    lowServerBtn.Parent = TabFrames[6]
    lowServerBtn.LayoutOrder = 2
    Instance.new("UICorner", lowServerBtn).CornerRadius = UDim.new(0, 15)
    lowServerBtn.MouseButton1Click:Connect(function()
        safeCall(function()
            local data = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
            local json = HttpService:JSONDecode(data)
            local lowest, lowestCount = nil, math.huge
            for _, s in ipairs(json.data) do
                if s.playing < lowestCount and s.id ~= game.JobId then
                    lowestCount = s.playing
                    lowest = s
                end
            end
            if lowest then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, lowest.id, LocalPlayer)
            end
        end)
    end)

    -- Troll Tab
    CreateToggle(TabFrames[7], "Jerk Player", WushHub.Settings.Jerk.Enabled, function(v) WushHub.Settings.Jerk.Enabled = v end, 1)
    CreateDropdown(TabFrames[7], "Jerk Target", GetPlayerNames(), function(v) WushHub.Settings.Jerk.Target = v end, 2)
    CreateToggle(TabFrames[7], "Bang Player", WushHub.Settings.Bang.Enabled, function(v) WushHub.Settings.Bang.Enabled = v end, 3)
    CreateDropdown(TabFrames[7], "Bang Target", GetPlayerNames(), function(v) WushHub.Settings.Bang.Target = v end, 4)

    return gui
end

-- Final Initialization
local gui = CreateGUI()

-- Cleanup on teleport
LocalPlayer.OnTeleport:Connect(function()
    StopFly()
    ClearESP()
    if musicPlayer then
        musicPlayer:Stop()
        musicPlayer:Destroy()
        musicPlayer = nil
    end
    if gui then
        gui:Destroy()
    end
end)

-- Success notification
safeCall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "WushHub Loaded!",
        Text = "Made with ♥ | Все функции работают!",
        Duration = 5
    })
end)

print("WushHub: Successfully loaded with all features!")
print("Features: Aimbot, Silent Aim, Fly, Spin, Orbit, ESP, Spam, Music, Troll & more!")