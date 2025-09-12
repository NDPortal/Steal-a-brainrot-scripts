-- SERVICES
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ProximityPromptService = game:GetService("ProximityPromptService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ControlTable = {HideMethod = false}

local function GetBodyClass(Name)
    if Player.Character and Player.Character:FindFirstChildWhichIsA(Name, true) then
        return Player.Character:FindFirstChildWhichIsA(Name, true)
    end
    return nil
end

local function GetBodyChild(Name)
    if Player.Character and Player.Character:FindFirstChild(Name, true) then
        return Player.Character:FindFirstChild(Name, true)
    end
    return nil
end

local function SafeDestroy(TargetDelete)
    Debris:AddItem(TargetDelete, 0)
end

local function SafeReplicateSignal(Signal, ...)
    if replicatesignal then
        replicatesignal(Signal, ...)
    end
end

-- ==========================
-- SPACE UI THEME FUNCTIONS
-- ==========================
local function CreateSpaceGradient(parent)
    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 25, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
    })
    MainGradient.Rotation = 90
    MainGradient.Parent = parent
    return MainGradient
end

local function CreateSpaceStroke(parent)
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(120, 100, 255)
    MainStroke.Thickness = 1
    MainStroke.Parent = parent
    return MainStroke
end

local function CreateSpaceCorners(parent, radius)
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, radius or 8)
    MainCorner.Parent = parent
    return MainCorner
end

local function CreateMovingStars(parent, count)
    local stars = {}
    for i = 1, count or 20 do
        local star = Instance.new("Frame")
        star.Size = UDim2.new(0, math.random(1, 2), 0, math.random(1, 2))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(220, 220, 255)
        star.BorderSizePixel = 0
        star.Parent = parent
        star.ZIndex = 0
        
        table.insert(stars, {instance = star, ySpeed = (math.random(10, 30) / 1000)})
    end
    
    task.spawn(function()
        while task.wait(0.03) do
            if not parent or not parent.Parent then break end
            for _, starData in ipairs(stars) do
                local star = starData.instance
                local newY = star.Position.Y.Scale + starData.ySpeed
                if newY > 1 then
                    star.Position = UDim2.new(math.random(), 0, -0.05, 0)
                else
                    star.Position = UDim2.new(star.Position.X.Scale, 0, newY, 0)
                end
            end
        end
    end)
    
    return stars
end

-- ==========================
-- MAIN GUI SETUP
-- ==========================
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "LowkeyLostSpaceGUI"
ScreenGui.ResetOnSpawn = false

local UtilFrame = Instance.new("Frame", ScreenGui)
UtilFrame.Size = UDim2.new(0, 320, 0, 300)
UtilFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
UtilFrame.BackgroundTransparency = 1
UtilFrame.Visible = false
UtilFrame.Active = true
UtilFrame.Draggable = true
UtilFrame.ClipsDescendants = false
UtilFrame.ZIndex = 99998

local BackgroundFrame = Instance.new("Frame", UtilFrame)
BackgroundFrame.Size = UDim2.new(1, 0, 1, 0)
BackgroundFrame.Position = UDim2.new(0, 0, 0, 0)
BackgroundFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
BackgroundFrame.BorderSizePixel = 0
BackgroundFrame.ZIndex = 0
CreateSpaceCorners(BackgroundFrame, 12)
CreateSpaceStroke(BackgroundFrame)
CreateSpaceGradient(BackgroundFrame)
CreateMovingStars(BackgroundFrame, 15)

local UtilTitle = Instance.new("TextLabel", UtilFrame)
UtilTitle.Size = UDim2.new(1, 0, 0, 35)
UtilTitle.Position = UDim2.new(0, 0, 0, 0)
UtilTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
UtilTitle.RichText = true
UtilTitle.Text = "<font face='SciFi' size='16' color='#DCDCFE'>⚡ Space Utilities</font>"
UtilTitle.TextYAlignment = Enum.TextYAlignment.Center
UtilTitle.ZIndex = 99999
CreateSpaceCorners(UtilTitle, 12)

-- ==========================
-- HYPERDRIVE / SPEED BUTTON
-- ==========================
local SpeedBtn = Instance.new("TextButton", UtilFrame)
SpeedBtn.Size = UDim2.new(0, 140, 0, 40)
SpeedBtn.Position = UDim2.new(0, 15, 0, 50)
SpeedBtn.Text = "🚀 Hyperdrive: OFF"
SpeedBtn.TextScaled = true
SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 70)
SpeedBtn.TextColor3 = Color3.fromRGB(255, 80, 120)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.ZIndex = 99999
CreateSpaceCorners(SpeedBtn, 8)
CreateSpaceStroke(SpeedBtn)

local speedRunning = false
local speedConnection

local SPEED_HIGH = 42
local JUMP_HIGH = 70
local SPEED_LOW = 42
local JUMP_LOW = 50

SpeedBtn.MouseButton1Click:Connect(function()
    speedRunning = not speedRunning
    SpeedBtn.TextColor3 = speedRunning and Color3.fromRGB(80, 255, 150) or Color3.fromRGB(255, 80, 120)
    SpeedBtn.Text = speedRunning and "🚀 Hyperdrive: ON" or "🚀 Hyperdrive: OFF"

    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if speedConnection then speedConnection:Disconnect(); speedConnection = nil end

    if speedRunning and humanoid then
        speedConnection = RunService.RenderStepped:Connect(function()
            if humanoid and humanoid.RootPart then
                local dir = humanoid.MoveDirection
                if dir.Magnitude > 0 then
                    local speed, jumpPower
                    if humanoid.WalkSpeed > 25 then
                        speed = SPEED_HIGH
                        jumpPower = JUMP_HIGH
                    else
                        speed = SPEED_LOW
                        jumpPower = JUMP_LOW
                    end
                    humanoid.JumpPower = jumpPower
                    humanoid.RootPart.Velocity = Vector3.new(dir.X * speed, humanoid.RootPart.Velocity.Y, dir.Z * speed)
                end
            end
        end)
    end
end)

-- ==========================
-- LOCK BUTTON
-- ==========================
local LockBtn = Instance.new("TextButton", UtilFrame)
LockBtn.Size = UDim2.new(0, 140, 0, 40)
LockBtn.Position = UDim2.new(0, 165, 0, 50)
LockBtn.Text = "🔒 Anchor: OFF"
LockBtn.TextScaled = true
LockBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 70)
LockBtn.TextColor3 = Color3.fromRGB(255, 80, 120)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.ZIndex = 99999
CreateSpaceCorners(LockBtn, 8)
CreateSpaceStroke(LockBtn)

local locked = false
local function lockChar()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
end
local function unlockChar()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = false end
end

LockBtn.MouseButton1Click:Connect(function()
    locked = not locked
    LockBtn.TextColor3 = locked and Color3.fromRGB(80, 255, 150) or Color3.fromRGB(255, 80, 120)
    LockBtn.Text = locked and "🔒 Anchor: ON" or "🔒 Anchor: OFF"
    if locked then lockChar() else unlockChar() end
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, plr)
    if plr == Player and prompt.ActionText:lower():find("steal") and locked then
        unlockChar()
        locked = false
        LockBtn.TextColor3 = Color3.fromRGB(255, 80, 120)
        LockBtn.Text = "🔒 Anchor: OFF"
        StarterGui:SetCore("SendNotification", {Title = "Space Alert", Text = "Anchor disengaged", Duration = 5})
    end
end)

-- ==========================
-- PLATFORM BUTTON
-- ==========================
local PlatformButton = Instance.new("TextButton", UtilFrame)
PlatformButton.Size = UDim2.new(0, 140, 0, 40)
PlatformButton.Position = UDim2.new(0, 15, 0, 100)
PlatformButton.Text = "🛸 Space Platform: OFF"
PlatformButton.TextScaled = true
PlatformButton.BackgroundColor3 = Color3.fromRGB(40, 35, 70)
PlatformButton.TextColor3 = Color3.fromRGB(255, 80, 120)
PlatformButton.Font = Enum.Font.GothamBold
PlatformButton.ZIndex = 99999
CreateSpaceCorners(PlatformButton, 8)
CreateSpaceStroke(PlatformButton)

local char = Player.Character or Player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local platformRunning = false
local riseSpeed = 0.9
local platform = nil

Player.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
    if platform then
        platform.Position = root.Position - Vector3.new(0, 3, 0)
    end
end)

local function movePlatform()
    while platformRunning and platform and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") do
        local currentRoot = Player.Character.HumanoidRootPart
        local newY = platform.Position.Y + riseSpeed
        if newY > 48 then
            newY = 48
        end
        platform.Position = Vector3.new(currentRoot.Position.X, newY, currentRoot.Position.Z)
        task.wait(0.05)
    end
end

PlatformButton.MouseButton1Click:Connect(function()
    platformRunning = not platformRunning
    PlatformButton.TextColor3 = platformRunning and Color3.fromRGB(80, 255, 150) or Color3.fromRGB(255, 80, 120)
    PlatformButton.Text = platformRunning and "🛸 Space Platform: ON" or "🛸 Space Platform: OFF"

    if platformRunning then
        if not platform then
            platform = Instance.new("Part")
            platform.Size = Vector3.new(7.5, 0.5, 7.5)
            platform.Anchored = true
            platform.CanCollide = true
            platform.Position = root.Position - Vector3.new(0, 3, 0)
            platform.Name = "SkyPlatform"
            platform.Parent = workspace
        end
        task.spawn(movePlatform)
    else
        if platform then
            platform:Destroy()
            platform = nil
        end
    end
end)

-- ==========================
-- NEW LOCATION BUTTONS
-- ==========================
local savedLocation = nil

local SetLocationBtn = Instance.new("TextButton", UtilFrame)
SetLocationBtn.Size = UDim2.new(0, 140, 0, 40)
SetLocationBtn.Position = UDim2.new(0, 15, 0, 150)
SetLocationBtn.Text = "Set Location"
SetLocationBtn.TextScaled = true
SetLocationBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 70)
SetLocationBtn.TextColor3 = Color3.fromRGB(120, 255, 200)
SetLocationBtn.Font = Enum.Font.GothamBold
SetLocationBtn.ZIndex = 99999
CreateSpaceCorners(SetLocationBtn, 8)
CreateSpaceStroke(SetLocationBtn)

SetLocationBtn.MouseButton1Click:Connect(function()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        savedLocation = root.Position
        StarterGui:SetCore("SendNotification", {Title = "Space Alert", Text = "Location saved!", Duration = 3})
    else
        StarterGui:SetCore("SendNotification", {Title = "Space Alert", Text = "Character not found.", Duration = 3})
    end
end)

local TeleportBtn = Instance.new("TextButton", UtilFrame)
TeleportBtn.Size = UDim2.new(0, 140, 0, 40)
TeleportBtn.Position = UDim2.new(0, 165, 0, 150)
TeleportBtn.Text = "Teleport to Location"
TeleportBtn.TextScaled = true
TeleportBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 70)
TeleportBtn.TextColor3 = Color3.fromRGB(120, 255, 200)
TeleportBtn.Font = Enum.Font.GothamBold
TeleportBtn.ZIndex = 99999
CreateSpaceCorners(TeleportBtn, 8)
CreateSpaceStroke(TeleportBtn)

TeleportBtn.MouseButton1Click:Connect(function()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root and savedLocation then
        root.CFrame = CFrame.new(savedLocation)
        StarterGui:SetCore("SendNotification", {Title = "Space Alert", Text = "Teleporting...", Duration = 3})
    else
        StarterGui:SetCore("SendNotification", {Title = "Space Alert", Text = "No location saved or character not found.", Duration = 3})
    end
end)

-- ==========================
-- TOGGLE MENU
-- ==========================
local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Size = UDim2.new(0, 60, 0, 60)
MainToggle.Position = UDim2.new(0.95, -60, 0.75, -30)
MainToggle.AnchorPoint = Vector2.new(0, 0)
MainToggle.Text = "⚡"
MainToggle.TextScaled = true
MainToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainToggle.TextColor3 = Color3.fromRGB(220, 220, 255)
MainToggle.ZIndex = 99999
MainToggle.Active = true
MainToggle.Draggable = true

CreateSpaceCorners(MainToggle, 12)
CreateSpaceStroke(MainToggle)
CreateSpaceGradient(MainToggle)

MainToggle.MouseButton1Click:Connect(function()
    UtilFrame.Visible = not UtilFrame.Visible
end)
