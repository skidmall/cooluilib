-- CoolUILib: A custom UI library for Roblox
-- Place in a ModuleScript under ReplicatedStorage
local CoolUILib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Default theme
local theme = {
    PrimaryColor = Color3.fromRGB(30, 30, 30), -- Dark background
    SecondaryColor = Color3.fromRGB(50, 50, 50), -- Button background
    AccentColor = Color3.fromRGB(0, 170, 255), -- Blue accent
    TextColor = Color3.fromRGB(255, 255, 255), -- White text
    Gradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 200))
    }
}

-- Create a frame with a gradient title bar
function CoolUILib.CreateFrame(parent, size, position, name)
    local frame = Instance.new("Frame")
    frame.Name = name or "CoolFrame"
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = theme.PrimaryColor
    frame.BorderSizePixel = 0
    frame.Parent = parent

    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    -- Add title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = theme.Gradient
    gradient.Parent = titleBar

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    -- Make frame draggable
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return frame, titleBar
end

-- Create a text label
function CoolUILib.CreateLabel(parent, size, position, text, name)
    local label = Instance.new("TextLabel")
    label.Name = name or "CoolLabel"
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.TextColor
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = parent
    return label
end

-- Create a button with hover and click animations
function CoolUILib.CreateButton(parent, size, position, text, name, callback)
    local button = Instance.new("TextButton")
    button.Name = name or "CoolButton"
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = theme.SecondaryColor
    button.Text = text
    button.TextColor3 = theme.TextColor
    button.TextScaled = true
    button.Font = Enum.Font.SourceSans
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    -- Hover animation
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = theme.AccentColor}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = theme.SecondaryColor}):Play()
    end)

    -- Click animation
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(size.X.Scale * 0.95, 0, size.Y.Scale * 0.95, 0)}):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = size}):Play()
    end)

    button.MouseButton1Click:Connect(callback)
    return button
end

-- Fade-in animation for a UI element
function CoolUILib.FadeIn(element)
    element.BackgroundTransparency = 1
    TweenService:Create(element, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    for _, child in pairs(element:GetDescendants()) do
        if child:IsA("GuiObject") then
            child.BackgroundTransparency = 1
            TweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                child.TextTransparency = 1
                TweenService:Create(child, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
            end
        end
    end
end

return CoolUILib
