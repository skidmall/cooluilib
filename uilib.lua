-- CoolUILib: Enhanced UI library for Roblox with splash screen
-- Place in a ModuleScript under ReplicatedStorage
local CoolUILib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Modern theme with glassmorphism
local theme = {
    PrimaryColor = Color3.fromRGB(20, 20, 30), -- Dark translucent background
    SecondaryColor = Color3.fromRGB(50, 50, 70), -- Button background
    AccentColor = Color3.fromRGB(0, 200, 255), -- Vibrant cyan accent
    TextColor = Color3.fromRGB(240, 240, 255), -- Soft white text
    Gradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 255))
    },
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.7
}

-- Show splash screen with "MyLib" animation
function CoolUILib.ShowSplash(parent)
    local splash = Instance.new("Frame")
    splash.Name = "SplashScreen"
    splash.Size = UDim2.new(1, 0, 1, 0)
    splash.Position = UDim2.new(0, 0, 0, 0)
    splash.BackgroundColor3 = theme.PrimaryColor
    splash.BackgroundTransparency = 1
    splash.Parent = parent

    local gradient = Instance.new("UIGradient")
    gradient.Color = theme.Gradient
    gradient.Parent = splash

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.2, 0)
    label.Position = UDim2.new(0.25, 0, 0.4, 0)
    label.BackgroundTransparency = 1
    label.Text = "MyLib"
    label.TextColor3 = theme.TextColor
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.TextTransparency = 1
    label.Parent = splash

    -- Fade-in animation
    TweenService:Create(splash, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.2}):Play()
    TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()

    -- Wait 2 seconds, then fade out
    task.wait(2)
    TweenService:Create(splash, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()

    -- Destroy splash after animation
    task.wait(0.5)
    splash:Destroy()
end

-- Create a frame with glassmorphism and shadow
function CoolUILib.CreateFrame(parent, size, position, name)
    local frame = Instance.new("Frame")
    frame.Name = name or "CoolFrame"
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = theme.PrimaryColor
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = parent

    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = theme.ShadowColor
    shadow.ImageTransparency = theme.ShadowTransparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = frame

    -- Gradient title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = theme.Gradient
    gradient.Parent = titleBar

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
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
    label.Font = Enum.Font.GothamBold
    label.TextTransparency = 0.1
    label.Parent = parent
    return label
end

-- Create a button with animations
function CoolUILib.CreateButton(parent, size, position, text, name, callback)
    local button = Instance.new("TextButton")
    button.Name = name or "CoolButton"
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = theme.SecondaryColor
    button.BackgroundTransparency = 0.2
    button.Text = text
    button.TextColor3 = theme.TextColor
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    -- Hover animation
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = theme.AccentColor,
            BackgroundTransparency = 0,
            Size = UDim2.new(size.X.Scale * 1.05, 0, size.Y.Scale * 1.05, 0)
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = theme.SecondaryColor,
            BackgroundTransparency = 0.2,
            Size = size
        }):Play()
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

-- Create a scrolling frame
function CoolUILib.CreateScrollingFrame(parent, size, position, name)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = name or "CoolScrollFrame"
    scrollFrame.Size = size
    scrollFrame.Position = position
    scrollFrame.BackgroundColor3 = theme.PrimaryColor
    scrollFrame.BackgroundTransparency = 0.3
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = theme.AccentColor
    scrollFrame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = scrollFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    return scrollFrame
end

-- Fade-in animation
function CoolUILib.FadeIn(element)
    element.BackgroundTransparency = 1
    TweenService:Create(element, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.2}):Play()
    for _, child in pairs(element:GetDescendants()) do
        if child:IsA("GuiObject") then
            local targetTransparency = child:IsA("Frame") and 0.2 or 0
            child.BackgroundTransparency = 1
            TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = targetTransparency}):Play()
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                child.TextTransparency = 1
                TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
            end
        end
    end
end

return CoolUILib
