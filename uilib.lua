-- MyLib: A modern, modular, and animated UI library for Roblox.
-- This script can be used in any executor environment or directly in a LocalScript.

local MyLib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- region -- THEME & CONFIGURATION --

MyLib.Theme = {
    Primary = Color3.fromRGB(20, 20, 35),
    Secondary = Color3.fromRGB(40, 40, 60),
    Accent = Color3.fromRGB(0, 160, 255),
    AccentDark = Color3.fromRGB(0, 120, 200),
    Text = Color3.fromRGB(230, 230, 245),
    TextMuted = Color3.fromRGB(150, 150, 170),
    Error = Color3.fromRGB(200, 50, 50),
    Success = Color3.fromRGB(50, 200, 50),
    Border = Color3.fromRGB(70, 70, 90),
    GradientMain = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 255))
    },
    FrameTransparency = 0.2,
    ButtonTransparency = 0.15,
    InputTransparency = 0.15,
    PanelTransparency = 0.1,
    FontMain = Enum.Font.GothamBold,
    FontTitle = Enum.Font.GothamBlack,
    FontButton = Enum.Font.Gotham,
    FontSizeDefault = 16,
    CornerRadiusSmall = UDim.new(0, 6),
    CornerRadiusMedium = UDim.new(0, 10),
    CornerRadiusLarge = UDim.new(0, 14),
    Padding = 10,
    Spacing = 8,
    ShadowImageId = "rbxassetid://1316045217",
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.7,
    ShadowOffset = UDim2.new(0, 10, 0, 10),
    TweenInfoDefault = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TweenInfoFast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TweenInfoBounce = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

-- endregion

-- region -- UTILITIES & HELPERS --

local function createUIElement(instanceType, properties)
    local element = Instance.new(instanceType)
    for prop, value in pairs(properties) do
        if element[prop] ~= nil then
            element[prop] = value
        end
    end
    return element
end

local function applyCorner(guiObject, radius)
    local corner = createUIElement("UICorner", {
        CornerRadius = radius or MyLib.Theme.CornerRadiusSmall
    })
    corner.Parent = guiObject
end

local function applyShadow(guiObject, offset, transparency, imageId)
    local shadowOffset = offset or MyLib.Theme.ShadowOffset
    local shadowTransparency = transparency or MyLib.Theme.ShadowTransparency
    local shadowImage = imageId or MyLib.Theme.ShadowImageId
    local shadow = createUIElement("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, shadowOffset.X.Offset * 2, 1, shadowOffset.Y.Offset * 2),
        Position = UDim2.new(0, -shadowOffset.X.Offset, 0, -shadowOffset.Y.Offset),
        BackgroundTransparency = 1,
        Image = shadowImage,
        ImageColor3 = MyLib.Theme.ShadowColor,
        ImageTransparency = shadowTransparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = guiObject.ZIndex - 1
    })
    shadow.Parent = guiObject
end

function MyLib.FadeIn(guiObject, duration)
    if not guiObject:IsA("GuiObject") then return end
    local dur = duration or MyLib.Theme.TweenInfoDefault.Time
    guiObject.Visible = true
    local currentBgTransparency = guiObject.BackgroundTransparency
    local currentTextTransparency = guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") and guiObject.TextTransparency or nil
    local currentImageTransparency = guiObject:IsA("ImageLabel") and guiObject.ImageTransparency or nil
    guiObject.BackgroundTransparency = 1
    if currentTextTransparency ~= nil then guiObject.TextTransparency = 1 end
    if currentImageTransparency ~= nil then guiObject.ImageTransparency = 1 end
    local tweenProps = {
        BackgroundTransparency = currentBgTransparency,
        TextTransparency = currentTextTransparency,
        ImageTransparency = currentImageTransparency
    }
    TweenService:Create(guiObject, TweenInfo.new(dur, MyLib.Theme.TweenInfoDefault.EasingStyle, MyLib.Theme.TweenInfoDefault.EasingDirection), tweenProps):Play()
    for _, child in guiObject:GetChildren() do
        if child:IsA("GuiObject") and child.Name ~= "Shadow" then
            MyLib.FadeIn(child, dur * 0.8)
        end
    end
end

function MyLib.FadeOut(guiObject, duration)
    if not guiObject:IsA("GuiObject") then return end
    local dur = duration or MyLib.Theme.TweenInfoDefault.Time
    local targets = { BackgroundTransparency = 1 }
    if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
        targets.TextTransparency = 1
    elseif guiObject:IsA("ImageLabel") then
        targets.ImageTransparency = 1
    end
    local tween = TweenService:Create(guiObject, TweenInfo.new(dur, MyLib.Theme.TweenInfoDefault.EasingStyle, MyLib.Theme.TweenInfoDefault.EasingDirection), targets)
    tween:Play()
    for _, child in guiObject:GetChildren() do
        if child:IsA("GuiObject") and child.Name ~= "Shadow" then
            MyLib.FadeOut(child, dur * 0.8)
        end
    end
    tween.Completed:Connect(function()
        guiObject.Visible = false
    end)
end

-- endregion

-- region -- CORE UI ELEMENTS --

-- Function to show an animated splash screen
function MyLib.ShowSplash(parent, text, duration)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local splashDuration = duration or 2.5
    local splashText = text or "MyLib"

    local splashFrame = createUIElement("Frame", {
        Name = "SplashScreen",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = MyLib.Theme.Primary,
        BackgroundTransparency = 1, -- Starts invisible
        Parent = parent,
        ZIndex = 100 -- Ensure it's on top of everything
    })

    local gradient = createUIElement("UIGradient", {
        Color = MyLib.Theme.GradientMain,
        Transparency = NumberSequence.new(0.8, 0.95),
        Rotation = 90,
        Parent = splashFrame
    })

    local splashLabel = createUIElement("TextLabel", {
        Size = UDim2.new(0.5, 0, 0.2, 0),
        Position = UDim2.new(0.25, 0, 0.4, 0),
        BackgroundTransparency = 1,
        Text = splashText,
        TextColor3 = MyLib.Theme.Text,
        TextScaled = true,
        Font = MyLib.Theme.FontTitle,
        TextTransparency = 1, -- Starts invisible
        Parent = splashFrame
    })

    -- Fade in background and text
    TweenService:Create(splashFrame, MyLib.Theme.TweenInfoDefault, {BackgroundTransparency = 0.05}):Play()
    local textTween = TweenService:Create(splashLabel, MyLib.Theme.TweenInfoDefault, {TextTransparency = 0})
    textTween:Play()

    -- Text scaling bounce animation
    splashLabel.Size = UDim2.new(0.4, 0, 0.15, 0)
    splashLabel.Position = UDim2.new(0.3, 0, 0.425, 0)
    TweenService:Create(splashLabel, MyLib.Theme.TweenInfoBounce, {
        Size = UDim2.new(0.5, 0, 0.2, 0),
        Position = UDim2.new(0.25, 0, 0.4, 0)
    }):Play()

    task.wait(splashDuration)

    -- Fade out
    TweenService:Create(splashFrame, MyLib.Theme.TweenInfoDefault, {BackgroundTransparency = 1}):Play()
    TweenService:Create(splashLabel, MyLib.Theme.TweenInfoDefault, {TextTransparency = 1}):Play()

    task.wait(MyLib.Theme.TweenInfoDefault.Time)
    splashFrame:Destroy()
end

-- Creates a draggable main UI frame with title bar and shadow
function MyLib.CreateFrame(parent, size, position, name, titleText)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local frame = createUIElement("Frame", {
        Name = name or "CoolFrame",
        Size = size,
        Position = position,
        BackgroundColor3 = MyLib.Theme.Primary,
        BackgroundTransparency = MyLib.Theme.FrameTransparency,
        BorderSizePixel = 0,
        Parent = parent,
        ClipsDescendants = true,
        ZIndex = 1,
        Visible = true
    })
    applyCorner(frame, MyLib.Theme.CornerRadiusLarge)
    applyShadow(frame)
    -- Title Bar
    local titleBar = createUIElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = MyLib.Theme.Primary,
        BackgroundTransparency = MyLib.Theme.PanelTransparency,
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 2
    })
    local titleGradient = createUIElement("UIGradient", {
        Color = MyLib.Theme.GradientMain,
        Transparency = NumberSequence.new(0.8, 0.95),
        Rotation = 90,
        Parent = titleBar
    })
    applyCorner(titleBar, UDim.new(0, MyLib.Theme.CornerRadiusLarge.Offset))
    local titleLabel = MyLib.CreateLabel(
        titleBar,
        UDim2.new(1, -2 * MyLib.Theme.Padding, 1, 0),
        UDim2.new(0, MyLib.Theme.Padding, 0, 0),
        titleText or name or "Cool UI",
        "FrameTitle",
        MyLib.Theme.FontTitle,
        false,
        MyLib.Theme.Text
    )
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    -- Draggable functionality
    local isDragging = false
    local dragStartPos
    local initialFramePos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPos = input.Position
            initialFramePos = frame.Position
            input:CaptureFocus()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
            local delta = input.Position - dragStartPos
            frame.Position = UDim2.new(initialFramePos.X.Scale, initialFramePos.X.Offset + delta.X,
                                        initialFramePos.Y.Scale, initialFramePos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            input:ReleaseFocus()
        end
    end)
    frame.TitleBar = titleBar
    frame.TitleLabel = titleLabel
    return frame
end

-- Creates a customizable text label
function MyLib.CreateLabel(parent, size, position, text, name, font, textScaled, textColor)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local label = createUIElement("TextLabel", {
        Name = name or "CoolLabel",
        Size = size,
        Position = position,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = textColor or MyLib.Theme.Text,
        TextScaled = textScaled or false, -- Default to false for more control
        Font = font or MyLib.Theme.FontMain,
        TextSize = MyLib.Theme.FontSizeDefault,
        TextTransparency = 0,
        Parent = parent,
        ZIndex = 2,
        Visible = true
    })
    return label
end

-- Creates an interactive button with hover/click animations
function MyLib.CreateButton(parent, size, position, text, name, callback)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local button = createUIElement("TextButton", {
        Name = name or "CoolButton",
        Size = size,
        Position = position,
        BackgroundColor3 = MyLib.Theme.Secondary,
        BackgroundTransparency = MyLib.Theme.ButtonTransparency,
        Text = text,
        TextColor3 = MyLib.Theme.Text,
        TextScaled = true,
        Font = MyLib.Theme.FontButton,
        Parent = parent,
        ZIndex = 2,
        Visible = true
    })
    applyCorner(button, MyLib.Theme.CornerRadiusSmall)

    local initialSize = size
    local initialBgColor = MyLib.Theme.Secondary
    local initialBgTransparency = MyLib.Theme.ButtonTransparency

    -- Hover animation
    button.MouseEnter:Connect(function()
        TweenService:Create(button, MyLib.Theme.TweenInfoDefault, {
            BackgroundColor3 = MyLib.Theme.Accent,
            BackgroundTransparency = 0,
            Size = UDim2.new(initialSize.X.Scale * 1.03, initialSize.X.Offset, initialSize.Y.Scale * 1.03, initialSize.Y.Offset)
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, MyLib.Theme.TweenInfoDefault, {
            BackgroundColor3 = initialBgColor,
            BackgroundTransparency = initialBgTransparency,
            Size = initialSize
        }):Play()
    end)

    -- Click animation
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, MyLib.Theme.TweenInfoFast, {
            Size = UDim2.new(initialSize.X.Scale * 0.97, initialSize.X.Offset, initialSize.Y.Scale * 0.97, initialSize.Y.Offset),
            BackgroundColor3 = MyLib.Theme.AccentDark
        }):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, MyLib.Theme.TweenInfoFast, {
            Size = initialSize, -- Will be overridden by MouseLeave if mouse is gone
            BackgroundColor3 = button.MouseEnter:IsConnected() and MyLib.Theme.Accent or initialBgColor -- Return to hover or normal
        }):Play()
    end)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    return button
end

-- Creates a scrolling frame with auto-sizing canvas and layout
function MyLib.CreateScrollingFrame(parent, size, position, name, contentPadding)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local scrollFrame = createUIElement("ScrollingFrame", {
        Name = name or "CoolScrollFrame",
        Size = size,
        Position = position,
        BackgroundColor3 = MyLib.Theme.Secondary,
        BackgroundTransparency = MyLib.Theme.PanelTransparency,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = MyLib.Theme.Spacing,
        ScrollBarImageColor3 = MyLib.Theme.Accent,
        Parent = parent,
        ZIndex = 1,
        Visible = true
    })
    applyCorner(scrollFrame, MyLib.Theme.CornerRadiusMedium)

    local layout = createUIElement("UIListLayout", {
        Padding = UDim.new(0, contentPadding or MyLib.Theme.Spacing),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scrollFrame
    })

    -- Add internal padding to the scrolling content
    local uiPadding = createUIElement("UIPadding", {
        PaddingLeft = UDim.new(0, MyLib.Theme.Padding),
        PaddingRight = UDim.new(0, MyLib.Theme.Padding),
        PaddingTop = UDim.new(0, MyLib.Theme.Padding),
        PaddingBottom = UDim.new(0, MyLib.Theme.Padding),
        Parent = scrollFrame
    })

    -- Auto-adjust CanvasSize based on content
    local function updateCanvasSize()
        local contentHeight = layout.AbsoluteContentSize.Y
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + (MyLib.Theme.Padding * 2))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    -- Initial update in case items are added before layout is fully rendered
    RunService.Stepped:Wait() -- Give layout a frame to calculate
    updateCanvasSize()

    return scrollFrame
end

-- Creates a numerical slider with a thumb and value display
function MyLib.CreateSlider(parent, size, position, name, minVal, maxVal, initialVal, step, onValueChangedCallback)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local sliderFrame = createUIElement("Frame", {
        Name = name or "CoolSlider",
        Size = size,
        Position = position,
        BackgroundColor3 = MyLib.Theme.Secondary,
        BackgroundTransparency = MyLib.Theme.InputTransparency,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 2,
        Visible = true
    })
    applyCorner(sliderFrame, MyLib.Theme.CornerRadiusSmall)

    -- Value Label at the top
    local valueLabel = MyLib.CreateLabel(
        sliderFrame,
        UDim2.new(1, -2 * MyLib.Theme.Padding, 0, 20),
        UDim2.new(0, MyLib.Theme.Padding, 0, MyLib.Theme.Padding),
        tostring(initialVal), name .. "ValueLabel", MyLib.Theme.FontMain, false, MyLib.Theme.Text
    )
    valueLabel.TextSize = 16
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Track for the slider
    local trackHeight = 8
    local track = createUIElement("Frame", {
        Name = "Track",
        Size = UDim2.new(1, -2 * MyLib.Theme.Padding, 0, trackHeight),
        Position = UDim2.new(0, MyLib.Theme.Padding, 0, size.Y.Offset - MyLib.Theme.Padding - trackHeight),
        BackgroundColor3 = MyLib.Theme.Primary,
        BackgroundTransparency = MyLib.Theme.PanelTransparency,
        BorderSizePixel = 0,
        Parent = track -- Track'ı sliderFrame yerine Track olarak yapıyoruz, bu bir hata olabilir mi? Hayır, bu doğru.
    })
    applyCorner(track, UDim.new(0, trackHeight / 2))

    -- Fill for the slider (accent color)
    local fill = createUIElement("Frame", {
        Name = "Fill",
        Size = UDim2.new(0, 0, 1, 0), -- Width set dynamically
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = MyLib.Theme.Accent,
        BorderSizePixel = 0,
        Parent = track
    })
    applyCorner(fill, UDim.new(0, trackHeight / 2))

    -- Thumb that the user drags
    local thumbSize = 20
    local thumb = createUIElement("Frame", {
        Name = "Thumb",
        Size = UDim2.new(0, thumbSize, 0, thumbSize),
        Position = UDim2.new(0, -thumbSize / 2, 0.5, -thumbSize / 2),
        BackgroundColor3 = MyLib.Theme.Text,
        BorderSizePixel = 0,
        Parent = track, -- Thumb'ı track'ın çocuğu yapıyoruz
        ZIndex = 3
    })
    applyCorner(thumb, UDim.new(0, thumbSize / 2)) -- Make it circular

    local currentValue = math.clamp(initialVal, minVal, maxVal)

    local function updateSlider(value)
        value = math.clamp(value, minVal, maxVal)
        value = math.round(value / step) * step -- Apply snapping to step
        currentValue = value

        local percentage = (currentValue - minVal) / (maxVal - minVal)
        local thumbX = percentage * track.AbsoluteSize.X

        -- Tween thumb position and fill width
        TweenService:Create(thumb, MyLib.Theme.TweenInfoFast, {Position = UDim2.new(0, thumbX - thumbSize / 2, 0.5, -thumbSize / 2)}):Play()
        TweenService:Create(fill, MyLib.Theme.TweenInfoFast, {Size = UDim2.new(percentage, 0, 1, 0)}):Play()

        valueLabel.Text = tostring(currentValue)
        if onValueChangedCallback then
            onValueChangedCallback(currentValue)
        end
    end

    -- Initial setup
    updateSlider(currentValue)

    -- Dragging logic for the thumb
    local isDragging = false
    local lastMouseX = 0

    local function onThumbInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            lastMouseX = input.Position.X
            thumb:CaptureFocus()
            TweenService:Create(thumb, MyLib.Theme.TweenInfoFast, {Size = UDim2.new(0, thumbSize * 1.2, 0, thumbSize * 1.2)}):Play() -- Enlarge on drag
        end
    end

    local function onThumbInputChanged(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
            local mouseDeltaX = input.Position.X - lastMouseX
            local currentThumbX = thumb.Position.X.Offset + thumbSize / 2 -- Center of thumb
            local newThumbX = currentThumbX + mouseDeltaX

            local newPercentage = math.clamp(newThumbX / track.AbsoluteSize.X, 0, 1)
            local newValue = minVal + newPercentage * (maxVal - minVal)
            updateSlider(newValue)

            lastMouseX = input.Position.X
        end
    end

    local function onThumbInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            thumb:ReleaseFocus()
            TweenService:Create(thumb, MyLib.Theme.TweenInfoFast, {Size = UDim2.new(0, thumbSize, 0, thumbSize)}):Play() -- Shrink back
        end
    end

    thumb.InputBegan:Connect(onThumbInputBegan)
    UserInputService.InputChanged:Connect(onThumbInputChanged)
    UserInputService.InputEnded:Connect(onThumbInputEnded)

    -- Clicking on the track also moves the thumb
    track.MouseButton1Click:Connect(function(x, y, input)
        local mousePosInTrackX = input.Position.X - track.AbsolutePosition.X
        local newPercentage = math.clamp(mousePosInTrackX / track.AbsoluteSize.X, 0, 1)
        local newValue = minVal + newPercentage * (maxVal - minVal)
        updateSlider(newValue)
    end)

    return sliderFrame, updateSlider -- Return update function for external control
end

-- Creates a toggle switch (on/off)
function MyLib.CreateToggle(parent, size, position, name, initialValue, onToggledCallback)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local toggleFrame = createUIElement("Frame", {
        Name = name or "CoolToggle",
        Size = size,
        Position = position,
        BackgroundColor3 = MyLib.Theme.Secondary,
        BackgroundTransparency = MyLib.Theme.InputTransparency,
        BorderSizePixel = 0,
        Parent = parent,
        ClipsDescendants = true,
        ZIndex = 2,
        Visible = true
    })
    applyCorner(toggleFrame, UDim.new(0, size.Y.Offset / 2)) -- Makes it pill-shaped

    local currentToggleValue = initialValue or false
    local padding = 4 -- Internal padding for the thumb

    local background = createUIElement("Frame", {
        Name = "Background",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = (currentToggleValue and MyLib.Theme.Accent or MyLib.Theme.TextMuted),
        BackgroundTransparency = MyLib.Theme.PanelTransparency,
        BorderSizePixel = 0,
        Parent = toggleFrame
    })
    applyCorner(background, UDim.new(0, size.Y.Offset / 2))

    local thumbSize = size.Y.Offset - 2 * padding
    local thumb = createUIElement("Frame", {
        Name = "Thumb",
        Size = UDim2.new(0, thumbSize, 0, thumbSize),
        Position = UDim2.new(0, (currentToggleValue and (size.X.Offset - thumbSize - padding) or padding), 0, padding),
        BackgroundColor3 = MyLib.Theme.Text,
        BorderSizePixel = 0,
        Parent = toggleFrame,
        ZIndex = 3
    })
    applyCorner(thumb, UDim.new(0, thumbSize / 2)) -- Make thumb circular

    local function updateToggle(value)
        currentToggleValue = value
        local targetX = (currentToggleValue and (size.X.Offset - thumbSize - padding) or padding)
        local targetBgColor = (currentToggleValue and MyLib.Theme.Accent or MyLib.Theme.TextMuted)

        TweenService:Create(thumb, MyLib.Theme.TweenInfoDefault, {Position = UDim2.new(0, targetX, 0, padding)}):Play()
        TweenService:Create(background, MyLib.Theme.TweenInfoDefault, {BackgroundColor3 = targetBgColor}):Play()

        if onToggledCallback then
            onToggledCallback(currentToggleValue)
        end
    end

    -- Initial state update
    updateToggle(currentToggleValue)

    toggleFrame.MouseButton1Click:Connect(function()
        updateToggle(not currentToggleValue)
    end)

    return toggleFrame, updateToggle
end

-- Creates a dropdown menu with a list of selectable options
function MyLib.CreateDropdown(parent, size, position, name, options, initialOption, onOptionSelectedCallback)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local dropdownFrame = createUIElement("Frame", {
        Name = name or "CoolDropdown",
        Size = size,
        Position = position,
        BackgroundColor3 = MyLib.Theme.Secondary,
        BackgroundTransparency = MyLib.Theme.InputTransparency,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 2,
        Visible = true
    })
    applyCorner(dropdownFrame, MyLib.Theme.CornerRadiusSmall)

    local currentSelectedOption = initialOption or (options and options[1]) or "Select Option"
    local isOpen = false

    local mainButton = MyLib.CreateButton(
        dropdownFrame,
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        currentSelectedOption,
        name .. "Button"
    )
    mainButton.TextScaled = false
    mainButton.TextSize = MyLib.Theme.FontSizeDefault
    mainButton.TextXAlignment = Enum.TextXAlignment.Left
    mainButton.TextWrapped = false
    mainButton.Text = currentSelectedOption -- Set initial text

    -- Dropdown arrow icon
    local arrowIcon = createUIElement("ImageLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -2 * MyLib.Theme.Padding - 20, 0.5, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://492061099", -- Down arrow icon (or any suitable icon)
        ImageColor3 = MyLib.Theme.Text,
        Parent = mainButton,
        ZIndex = 3
    })

    local optionsFrame = createUIElement("Frame", {
        Name = "OptionsFrame",
        Size = UDim2.new(1, 0, 0, 0), -- Height will be dynamic, starts at 0
        Position = UDim2.new(0, 0, 1, 0), -- Below the main button
        BackgroundColor3 = MyLib.Theme.Secondary,
        BackgroundTransparency = MyLib.Theme.InputTransparency,
        BorderSizePixel = 0,
        Parent = dropdownFrame,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 4 -- Ensure options appear above other UI
    })
    applyCorner(optionsFrame, MyLib.Theme.CornerRadiusSmall)
    applyShadow(optionsFrame, UDim2.new(0, 5, 0, 5), MyLib.Theme.ShadowTransparency * 0.5)

    local optionsLayout = createUIElement("UIListLayout", {
        Padding = UDim.new(0, MyLib.Theme.Spacing / 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionsFrame
    })
    local optionsPadding = createUIElement("UIPadding", {
        PaddingLeft = UDim.new(0, MyLib.Theme.Padding / 2),
        PaddingRight = UDim.new(0, MyLib.Theme.Padding / 2),
        PaddingTop = UDim.new(0, MyLib.Theme.Padding / 2),
        PaddingBottom = UDim.new(0, MyLib.Theme.Padding / 2),
        Parent = optionsFrame
    })

    local optionButtons = {}

    local function closeDropdown()
        if not isOpen then return end
        isOpen = false
        TweenService:Create(optionsFrame, MyLib.Theme.TweenInfoDefault, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = MyLib.Theme.InputTransparency
        }):Play()
        TweenService:Create(arrowIcon, MyLib.Theme.TweenInfoDefault, {Rotation = 0}):Play()
        task.delay(MyLib.Theme.TweenInfoDefault.Time, function()
            optionsFrame.Visible = false
        end)
    end

    local function openDropdown()
        if isOpen then return end
        isOpen = true
        optionsFrame.Visible = true
        
        -- Calculate total height needed for options
        local singleOptionHeight = size.Y.Offset
        local totalOptionsHeight = (#options * singleOptionHeight) + (#options - 1) * optionsLayout.Padding.Offset + optionsPadding.PaddingTop.Offset + optionsPadding.PaddingBottom.Offset
        
        TweenService:Create(optionsFrame, MyLib.Theme.TweenInfoDefault, {
            Size = UDim2.new(1, 0, 0, totalOptionsHeight),
            BackgroundTransparency = MyLib.Theme.PanelTransparency
        }):Play()
        TweenService:Create(arrowIcon, MyLib.Theme.TweenInfoDefault, {Rotation = 180}):Play()
    end

    for i, optionText in ipairs(options) do
        local optionButton = MyLib.CreateButton(
            optionsFrame,
            UDim2.new(1, 0, 0, size.Y.Offset), -- Each option takes full width, fixed height
            UDim2.new(0, 0, 0, 0),
            optionText,
            name .. "Option" .. i
        )
        optionButton.LayoutOrder = i
        optionButton.TextScaled = false
        optionButton.TextSize = MyLib.Theme.FontSizeDefault
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.Text = optionText

        optionButton.MouseButton1Click:Connect(function()
            currentSelectedOption = optionText
            mainButton.Text = currentSelectedOption
            closeDropdown()
            if onOptionSelectedCallback then
                onOptionSelectedCallback(currentSelectedOption, i)
            end
        end)
        table.insert(optionButtons, optionButton)
    end

    mainButton.MouseButton1Click:Connect(function()
        if isOpen then
            closeDropdown()
        else
            openDropdown()
        end
    end)
    
    -- Close dropdown if clicked outside
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
            local mousePos = input.Position
            local dropdownAbsolutePos = dropdownFrame.AbsolutePosition
            local dropdownAbsoluteSize = dropdownFrame.AbsoluteSize
            
            -- Check if click is outside the entire dropdown area (including options)
            local optionsFrameAbsoluteSize = optionsFrame.AbsoluteSize
            local totalHeight = dropdownAbsoluteSize.Y + optionsFrameAbsoluteSize.Y
            
            local isClickInsideDropdown = (
                mousePos.X >= dropdownAbsolutePos.X and
                mousePos.X <= dropdownAbsolutePos.X + dropdownAbsoluteSize.X and
                mousePos.Y >= dropdownAbsolutePos.Y and
                mousePos.Y <= dropdownAbsolutePos.Y + totalHeight
            )
            
            if not isClickInsideDropdown then
                closeDropdown()
            end
        end
    end)

    local function getSelectedOption()
        return currentSelectedOption
    end

    local function setSelectedOption(option)
        local found = false
        for i, optText in ipairs(options) do
            if optText == option then
                currentSelectedOption = optText
                mainButton.Text = currentSelectedOption
                if onOptionSelectedCallback then
                    onOptionSelectedCallback(currentSelectedOption, i)
                end
                found = true
                break
            end
            end
        if not found then
            warn("Attempted to set dropdown option to '" .. option .. "' but it does not exist in the options list.")
        end
    end

    return dropdownFrame, getSelectedOption, setSelectedOption
end

-- Creates a text input box
function MyLib.CreateTextBox(parent, size, position, name, placeholderText, initialText, onTextChangedCallback, onFocusLostCallback)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local textBox = createUIElement("TextBox", {
        Name = name or "CoolTextBox",
        Size = size,
        Position = position,
        BackgroundColor3 = MyLib.Theme.Secondary,
        BackgroundTransparency = MyLib.Theme.InputTransparency,
        PlaceholderText = placeholderText or "",
        Text = initialText or "",
        TextColor3 = MyLib.Theme.Text,
        PlaceholderColor3 = MyLib.Theme.TextMuted,
        TextScaled = false, -- Input boxes usually aren't text scaled
        TextSize = MyLib.Theme.FontSizeDefault,
        Font = MyLib.Theme.FontMain,
        ClearTextOnFocus = false,
        Parent = parent,
        ZIndex = 2,
        Visible = true
    })
    applyCorner(textBox, MyLib.Theme.CornerRadiusSmall)

    -- Add padding inside the textbox for text
    local textPadding = createUIElement("UIPadding", {
        PaddingLeft = UDim.new(0, MyLib.Theme.Padding),
        PaddingRight = UDim.new(0, MyLib.Theme.Padding),
        PaddingTop = UDim.new(0, MyLib.Theme.Padding / 2),
        PaddingBottom = UDim.new(0, MyLib.Theme.Padding / 2),
        Parent = textBox
    })

    -- Change appearance on focus
    textBox.Focused:Connect(function()
        TweenService:Create(textBox, MyLib.Theme.TweenInfoFast, {
            BackgroundColor3 = MyLib.Theme.AccentDark,
            BackgroundTransparency = 0
        }):Play()
    end)

    textBox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(textBox, MyLib.Theme.TweenInfoFast, {
            BackgroundColor3 = MyLib.Theme.Secondary,
            BackgroundTransparency = MyLib.Theme.InputTransparency
        }):Play()
        if onFocusLostCallback then
            onFocusLostCallback(textBox.Text, enterPressed)
        end
    end)

    if onTextChangedCallback then
        textBox.Changed:Connect(function(property)
            if property == "Text" then
                onTextChangedCallback(textBox.Text)
            end
        end)
    end
    
    return textBox
end

-- endregion

local function safeParent(obj, parent)
    if not parent then
        warn("[MyLib] UI element '" .. obj.Name .. "' parent is nil! UI görünmez olabilir.")
    else
        obj.Parent = parent
    end
end

-- Gelişmiş Splash Ekranı (otomatik açılış)
local function showModernSplash()
    local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local splashFrame = createUIElement("Frame", {
        Name = "MyLibSplashScreen",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = MyLib.Theme.Primary,
        BackgroundTransparency = 1,
        ZIndex = 200
    })
    safeParent(splashFrame, playerGui)
    local gradient = createUIElement("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, MyLib.Theme.Accent),
            ColorSequenceKeypoint.new(1, MyLib.Theme.Primary)
        },
        Transparency = NumberSequence.new(0.7, 0.95),
        Rotation = 45,
        Parent = splashFrame
    })
    local glow = createUIElement("ImageLabel", {
        Name = "Glow",
        Size = UDim2.new(0.6, 0, 0.25, 0),
        Position = UDim2.new(0.2, 0, 0.38, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5107168713",
        ImageColor3 = MyLib.Theme.Accent,
        ImageTransparency = 0.7,
        ZIndex = 202,
        Parent = splashFrame
    })
    local splashLabel = createUIElement("TextLabel", {
        Size = UDim2.new(0.5, 0, 0.18, 0),
        Position = UDim2.new(0.25, 0, 0.41, 0),
        BackgroundTransparency = 1,
        Text = "MyLib",
        TextColor3 = MyLib.Theme.Text,
        TextStrokeTransparency = 0.7,
        TextStrokeColor3 = MyLib.Theme.Accent,
        TextScaled = true,
        Font = MyLib.Theme.FontTitle,
        TextTransparency = 1,
        Parent = splashFrame,
        ZIndex = 203
    })
    TweenService:Create(splashFrame, MyLib.Theme.TweenInfoDefault, {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(splashLabel, MyLib.Theme.TweenInfoDefault, {TextTransparency = 0}):Play()
    TweenService:Create(glow, MyLib.Theme.TweenInfoBounce, {ImageTransparency = 0.2, Size = UDim2.new(0.7,0,0.3,0)}):Play()
    splashLabel.Size = UDim2.new(0.4, 0, 0.13, 0)
    splashLabel.Position = UDim2.new(0.3, 0, 0.44, 0)
    TweenService:Create(splashLabel, MyLib.Theme.TweenInfoBounce, {
        Size = UDim2.new(0.5, 0, 0.18, 0),
        Position = UDim2.new(0.25, 0, 0.41, 0)
    }):Play()
    task.wait(2.7)
    TweenService:Create(splashLabel, MyLib.Theme.TweenInfoDefault, {TextTransparency = 1}):Play()
    TweenService:Create(glow, MyLib.Theme.TweenInfoDefault, {ImageTransparency = 1}):Play()
    TweenService:Create(splashFrame, MyLib.Theme.TweenInfoDefault, {BackgroundTransparency = 1}):Play()
    task.wait(MyLib.Theme.TweenInfoDefault.Time)
    splashFrame:Destroy()
end

showModernSplash()

-- Tema güncellemesi (daha modern ve canlı)
MyLib.Theme.Primary = Color3.fromRGB(24, 28, 40)
MyLib.Theme.Secondary = Color3.fromRGB(38, 44, 60)
MyLib.Theme.Accent = Color3.fromRGB(0, 200, 255)
MyLib.Theme.AccentDark = Color3.fromRGB(0, 140, 200)
MyLib.Theme.Text = Color3.fromRGB(240, 245, 255)
MyLib.Theme.TextMuted = Color3.fromRGB(170, 180, 200)
MyLib.Theme.GradientMain = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 120, 255))
}
MyLib.Theme.CornerRadiusSmall = UDim.new(0, 10)
MyLib.Theme.CornerRadiusMedium = UDim.new(0, 16)
MyLib.Theme.CornerRadiusLarge = UDim.new(0, 22)
MyLib.Theme.Padding = 14
MyLib.Theme.Spacing = 12
MyLib.Theme.ShadowTransparency = 0.5
MyLib.Theme.ShadowOffset = UDim2.new(0, 16, 0, 16)

-- TabPanel (decorator yok, doğrudan güvenli tanım)
function MyLib.CreateTabPanel(parent, size, position, name, tabNames)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local panel = createUIElement("Frame", {
        Name = name or "TabPanel",
        Size = size,
        Position = position,
        BackgroundColor3 = MyLib.Theme.Secondary,
        BackgroundTransparency = MyLib.Theme.PanelTransparency,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 2,
        Visible = true
    })
    applyCorner(panel, MyLib.Theme.CornerRadiusLarge)
    local tabBar = createUIElement("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = panel,
        ZIndex = 3
    })
    local tabButtons = {}
    local tabPages = {}
    local selectedTab = 1
    for i, tabName in ipairs(tabNames) do
        local btn = MyLib.CreateButton(tabBar, UDim2.new(0, 120, 1, 0), UDim2.new(0, (i-1)*124, 0, 0), tabName, "TabButton"..i, function()
            for j, page in ipairs(tabPages) do
                page.Visible = (j == i)
            end
            for j, b in ipairs(tabButtons) do
                b.BackgroundColor3 = (j == i) and MyLib.Theme.Accent or MyLib.Theme.Secondary
            end
            selectedTab = i
        end)
        btn.BackgroundColor3 = (i == 1) and MyLib.Theme.Accent or MyLib.Theme.Secondary
        table.insert(tabButtons, btn)
        local page = createUIElement("Frame", {
            Name = "TabPage"..i,
            Size = UDim2.new(1, 0, 1, -40),
            Position = UDim2.new(0, 0, 0, 40),
            BackgroundTransparency = 1,
            Parent = panel,
            Visible = (i == 1),
            ZIndex = 2
        })
        page.Visible = true
        table.insert(tabPages, page)
    end
    print("[MyLib] TabPanel created:", panel.Name, "Parent:", panel.Parent, "Visible:", panel.Visible)
    return panel, tabPages, function(idx)
        for j, page in ipairs(tabPages) do
            page.Visible = (j == idx)
        end
        for j, b in ipairs(tabButtons) do
            b.BackgroundColor3 = (j == idx) and MyLib.Theme.Accent or MyLib.Theme.Secondary
        end
        selectedTab = idx
    end
end

-- ProgressBar
function MyLib.CreateProgressBar(parent, size, position, name, initialValue)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local bar = createUIElement("Frame", {
        Name = name or "ProgressBar",
        Size = size,
        Position = position,
        BackgroundColor3 = MyLib.Theme.Secondary,
        BackgroundTransparency = MyLib.Theme.PanelTransparency,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 2,
        Visible = true
    })
    applyCorner(bar, MyLib.Theme.CornerRadiusMedium)
    local fill = createUIElement("Frame", {
        Name = "Fill",
        Size = UDim2.new(initialValue or 0, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = MyLib.Theme.Accent,
        BorderSizePixel = 0,
        Parent = bar
    })
    applyCorner(fill, MyLib.Theme.CornerRadiusMedium)
    return bar, function(value)
        fill.Size = UDim2.new(math.clamp(value, 0, 1), 0, 1, 0)
    end
end

-- Tooltip
function MyLib.CreateTooltip(target, text)
    if not target then
        error("[MyLib] Target parametresi nil! UI oluşturulamaz.")
    end
    local tooltip = createUIElement("TextLabel", {
        Name = "Tooltip",
        Size = UDim2.new(0, 180, 0, 32),
        BackgroundColor3 = MyLib.Theme.Secondary,
        BackgroundTransparency = 0.1,
        Text = text,
        TextColor3 = MyLib.Theme.Text,
        TextScaled = true,
        Font = MyLib.Theme.FontMain,
        Visible = false,
        ZIndex = 1000,
        Parent = target.Parent
    })
    applyCorner(tooltip, MyLib.Theme.CornerRadiusSmall)
    target.MouseEnter:Connect(function()
        tooltip.Position = UDim2.new(0, target.AbsolutePosition.X, 0, target.AbsolutePosition.Y - 36)
        tooltip.Visible = true
        TweenService:Create(tooltip, MyLib.Theme.TweenInfoFast, {TextTransparency = 0}):Play()
    end)
    target.MouseLeave:Connect(function()
        TweenService:Create(tooltip, MyLib.Theme.TweenInfoFast, {TextTransparency = 1}):Play()
        task.wait(MyLib.Theme.TweenInfoFast.Time)
        tooltip.Visible = false
    end)
    return tooltip
end

-- IconButton
function MyLib.CreateIconButton(parent, size, position, iconId, text, name, callback)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local btn = MyLib.CreateButton(parent, size, position, text, name, callback)
    local icon = createUIElement("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 8, 0.5, -12),
        BackgroundTransparency = 1,
        Image = iconId,
        ImageColor3 = MyLib.Theme.Text,
        Parent = btn,
        ZIndex = btn.ZIndex + 1
    })
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "     " .. (text or "")
    return btn
end

-- ModalDialog
function MyLib.CreateModalDialog(parent, size, title, contentText, confirmText, cancelText, onConfirm, onCancel)
    if not parent then
        error("[MyLib] Parent parametresi nil! UI oluşturulamaz.")
    end
    local modal = createUIElement("Frame", {
        Name = "ModalDialog",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = MyLib.Theme.Primary,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 1000
    })
    applyCorner(modal, MyLib.Theme.CornerRadiusLarge)
    applyShadow(modal)
    local titleLabel = MyLib.CreateLabel(modal, UDim2.new(1, -28, 0, 36), UDim2.new(0, 14, 0, 10), title, "ModalTitle", MyLib.Theme.FontTitle, false, MyLib.Theme.Text)
    local contentLabel = MyLib.CreateLabel(modal, UDim2.new(1, -28, 0, 60), UDim2.new(0, 14, 0, 50), contentText, "ModalContent", MyLib.Theme.FontMain, false, MyLib.Theme.Text)
    local confirmBtn = MyLib.CreateButton(modal, UDim2.new(0, 120, 0, 36), UDim2.new(1, -264, 1, -50), confirmText or "OK", "ModalConfirm", function()
        if onConfirm then onConfirm() end
        modal:Destroy()
    end)
    confirmBtn.BackgroundColor3 = MyLib.Theme.Success
    local cancelBtn = MyLib.CreateButton(modal, UDim2.new(0, 120, 0, 36), UDim2.new(1, -134, 1, -50), cancelText or "Cancel", "ModalCancel", function()
        if onCancel then onCancel() end
        modal:Destroy()
    end)
    cancelBtn.BackgroundColor3 = MyLib.Theme.Error
    return modal
end

-- Transparency kontrolü
for k,v in pairs(MyLib.Theme) do
    if tostring(k):find("Transparency") and type(v) == "number" and v > 0.5 then
        warn("[MyLib] Theme '"..k.."' değeri çok yüksek ("..tostring(v).."). UI görünmez olabilir!")
    end
end

return MyLib
