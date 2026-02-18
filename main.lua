local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ✅ Esperar a que el jugador cargue
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local char = player.Character or player.CharacterAdded:Wait()

local config = {
    leftArm  = 5,
    rightArm = 5,
    leftLeg  = 5,
    rightLeg = 5,
    transparency = true,
    toggleKey = Enum.KeyCode.F1
}

local function applyHitbox(c)
    local parts = {
        ["Left Arm"]  = Vector3.new(config.leftArm,  2, config.leftArm),
        ["Right Arm"] = Vector3.new(config.rightArm, 2, config.rightArm),
        ["Left Leg"]  = Vector3.new(config.leftLeg,  2, config.leftLeg),
        ["Right Leg"] = Vector3.new(config.rightLeg, 2, config.rightLeg),
    }
    for name, size in pairs(parts) do
        local p = c:FindFirstChild(name)
        if p then
            p.Size = size
            p.Transparency = config.transparency and 1 or 0
            p.Massless = true
            p.CanCollide = true
        end
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HolocaustoNuclear"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 340)
main.Position = UDim2.new(0.5, -160, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(8, 4, 18)
main.BorderSizePixel = 0
main.Parent = screenGui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(160, 80, 255)
stroke.Thickness = 1
stroke.Transparency = 0.5
stroke.Parent = main

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(20, 8, 40)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 6)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✦ HOLOCAUSTO NUCLEAR"
title.TextColor3 = Color3.fromRGB(200, 140, 255)
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local line = Instance.new("Frame")
line.Size = UDim2.new(1, 0, 0, 1)
line.Position = UDim2.new(0, 0, 0, 38)
line.BackgroundColor3 = Color3.fromRGB(160, 80, 255)
line.BackgroundTransparency = 0.6
line.BorderSizePixel = 0
line.Parent = main

local function createSlider(parent, labelText, yPos, minVal, maxVal, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 40)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 170, 255)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 16)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Color3.fromRGB(180, 100, 255)
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 3)
    track.Position = UDim2.new(0, 0, 0, 24)
    track.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
    track.BorderSizePixel = 0
    track.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -6, 0.5, -6)
    thumb.BackgroundColor3 = Color3.fromRGB(220, 160, 255)
    thumb.BorderSizePixel = 0
    thumb.Parent = track

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    local dragging = false
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local trackPos = track.AbsolutePosition.X
            local trackWidth = track.AbsoluteSize.X
            local rel = math.clamp((input.Position.X - trackPos) / trackWidth, 0, 1)
            local val = math.floor(minVal + rel * (maxVal - minVal))
            fill.Size = UDim2.new(rel, 0, 1, 0)
            thumb.Position = UDim2.new(rel, -6, 0.5, -6)
            valueLabel.Text = tostring(val)
            callback(val)
        end
    end)
end

local function createToggle(parent, labelText, yPos, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 28)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.75, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 170, 255)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 34, 0, 18)
    toggleBtn.Position = UDim2.new(1, -34, 0.5, -9)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(120, 40, 200) or Color3.fromRGB(40, 20, 60)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleBtn

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = default and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = default and Color3.fromRGB(220, 160, 255) or Color3.fromRGB(150, 100, 200)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBtn

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = default
    local detector = Instance.new("TextButton")
    detector.Size = UDim2.new(1, 0, 1, 0)
    detector.BackgroundTransparency = 1
    detector.Text = ""
    detector.Parent = toggleBtn

    detector.MouseButton1Click:Connect(function()
        state = not state
        local tween = TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = state and Color3.fromRGB(220, 160, 255) or Color3.fromRGB(150, 100, 200)
        })
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(120, 40, 200) or Color3.fromRGB(40, 20, 60)
        tween:Play()
        callback(state)
    end)
end

local function createSeparator(parent, yPos)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -20, 0, 1)
    sep.Position = UDim2.new(0, 10, 0, yPos)
    sep.BackgroundColor3 = Color3.fromRGB(160, 80, 255)
    sep.BackgroundTransparency = 0.75
    sep.BorderSizePixel = 0
    sep.Parent = parent
end

local sectionLabel1 = Instance.new("TextLabel")
sectionLabel1.Size = UDim2.new(1, -20, 0, 16)
sectionLabel1.Position = UDim2.new(0, 10, 0, 46)
sectionLabel1.BackgroundTransparency = 1
sectionLabel1.Text = "LIMB SIZE"
sectionLabel1.TextColor3 = Color3.fromRGB(160, 80, 255)
sectionLabel1.TextSize = 9
sectionLabel1.Font = Enum.Font.GothamBold
sectionLabel1.TextXAlignment = Enum.TextXAlignment.Left
sectionLabel1.Parent = main

createSlider(main, "Left Arm", 62, 1, 10, 5, function(v)
    config.leftArm = v
    applyHitbox(char)
end)

createSlider(main, "Right Arm", 104, 1, 10, 5, function(v)
    config.rightArm = v
    applyHitbox(char)
end)

createSeparator(main, 148)

createSlider(main, "Left Leg", 152, 1, 10, 5, function(v)
    config.leftLeg = v
    applyHitbox(char)
end)

createSlider(main, "Right Leg", 194, 1, 10, 5, function(v)
    config.rightLeg = v
    applyHitbox(char)
end)

createSeparator(main, 238)

local sectionLabel2 = Instance.new("TextLabel")
sectionLabel2.Size = UDim2.new(1, -20, 0, 16)
sectionLabel2.Position = UDim2.new(0, 10, 0, 242)
sectionLabel2.BackgroundTransparency = 1
sectionLabel2.Text = "SETTINGS"
sectionLabel2.TextColor3 = Color3.fromRGB(160, 80, 255)
sectionLabel2.TextSize = 9
sectionLabel2.Font = Enum.Font.GothamBold
sectionLabel2.TextXAlignment = Enum.TextXAlignment.Left
sectionLabel2.Parent = main

createToggle(main, "Transparency", 260, true, function(v)
    config.transparency = v
    applyHitbox(char)
end)

createToggle(main, "Auto Apply on Spawn", 290, true, function(v) end)

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 20)
footer.Position = UDim2.new(0, 0, 1, -22)
footer.BackgroundColor3 = Color3.fromRGB(10, 5, 22)
footer.BorderSizePixel = 0
footer.Text = "F1 = Ocultar/Mostrar   •   v1.0 R6"
footer.TextColor3 = Color3.fromRGB(120, 60, 180)
footer.TextSize = 9
footer.Font = Enum.Font.Gotham
footer.Parent = main

local draggingGui = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingGui = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingGui = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingGui and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == config.toggleKey then
        main.Visible = not main.Visible
    end
end)

applyHitbox(char)
player.CharacterAdded:Connect(function(c)
    char = c
    task.wait(0.5)
    applyHitbox(c)
end)

RunService.Heartbeat:Connect(function()
    if char then
        local parts = {
            ["Left Arm"]  = Vector3.new(config.leftArm,  2, config.leftArm),
            ["Right Arm"] = Vector3.new(config.rightArm, 2, config.rightArm),
            ["Left Leg"]  = Vector3.new(config.leftLeg,  2, config.leftLeg),
            ["Right Leg"] = Vector3.new(config.rightLeg, 2, config.rightLeg),
        }
        for name, size in pairs(parts) do
            local p = char:FindFirstChild(name)
            if p and p.Size ~= size then
                p.Size = size
                p.Transparency = config.transparency and 1 or 0
            end
        end
    end
end)

print("✦ Holocausto Nuclear cargado — F1 para ocultar/mostrar")
