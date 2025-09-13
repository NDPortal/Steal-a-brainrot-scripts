local function executeScript(url)
    local success, err = pcall(function()
        local scriptContent = game:HttpGet(url)
        local scriptFunction = loadstring(scriptContent)
        scriptFunction()
        print("Successfully loaded and executed script from: " .. url)
    end)

    if not success then
        warn("Failed to load or execute script from URL: " .. url .. "\nError: " .. tostring(err))
    end
end

local function showMessageBox(title, message)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameMessage"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Name = "MessageBox"
    frame.Size = UDim2.new(0.25, 0, 0.1, 0)
    frame.Position = UDim2.new(0.7, 0, 0.05, 0)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 2
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = title
    titleLabel.TextSize = 18
    titleLabel.Parent = frame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "MessageLabel"
    messageLabel.Size = UDim2.new(1, 0, 0.7, 0)
    messageLabel.Position = UDim2.new(0, 0, 0.3, 0)
    messageLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.Text = message
    messageLabel.TextSize = 16
    messageLabel.TextWrapped = true
    messageLabel.Parent = frame

    task.spawn(function()
        task.wait(3)
        screenGui:Destroy()
    end)
end

local currentPlaceId = game.PlaceId

print("Current Game ID: " .. tostring(currentPlaceId))

if currentPlaceId == 118915549367482 then
    print("Detected 'dontwakethebrainrots' game. Executing its script and showing message.")
    executeScript("https://raw.githubusercontent.com/NDPortal/Steal-a-brainrot-scripts/refs/heads/main/dontwakethebrainrots.lua")
    showMessageBox("Game Detected", "Dont Wake The Brainrots")
elseif currentPlaceId == 109983668079237 or currentPlaceId == 96342491571673 then
    print("Detected 'infjumpandgravity' game. Executing its script and showing message.")
    executeScript("https://raw.githubusercontent.com/NDPortal/Steal-a-brainrot-scripts/refs/heads/main/infjumpandgravity.lua")
    showMessageBox("Game Detected", "Steal A Brainrot")
elseif currentPlaceId == 17625359962 then
    print("Detected 'rivals' game. Executing its script and showing message.")
    executeScript("https://raw.githubusercontent.com/NDPortal/Steal-a-brainrot-scripts/refs/heads/main/rivals.lua")
    showMessageBox("Game Detected", "Rivals")
else
    print("The current game ID does not match any of the specified scripts.")
end
