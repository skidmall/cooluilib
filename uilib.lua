-- CoolUILib: A modern, modular, and animated UI library for Roblox.
-- Place this script in a ModuleScript under ReplicatedStorage.

local CoolUILib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- region -- THEME & CONFIGURATION --

-- Define the visual theme of the UI library
CoolUILib.Theme = {
    -- Colors
    Primary = Color3.fromRGB(20, 20, 35),       -- Main background, dark with a subtle blue tint
    Secondary = Color3.fromRGB(40, 40, 60),     -- Panel/section backgrounds
    Accent = Color3.fromRGB(0, 160, 255),       -- Highlight, active states, main accent color
    AccentDark = Color3.fromRGB(0, 120, 200),   -- Darker accent for active/pressed states
    Text = Color3.fromRGB(230, 230, 245),       -- General text color
    TextMuted = Color3.fromRGB(150, 150, 170),  -- Placeholder text, muted labels
    Error = Color3.fromRGB(200, 50, 50),        -- Error messages
    Success = Color3.fromRGB(50, 200, 50),      -- Success messages
    Border = Color3.fromRGB(70, 70, 90),        -- Subtle borders

    -- Gradients
    GradientMain = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 255))
    },

    -- Transparency (for glassmorphism effect)
    FrameTransparency = 0.2,
    ButtonTransparency = 0.15,
    InputTransparency = 0.15,
    PanelTransparency = 0.1, -- For scroll frames, etc.

    -- Fonts
    FontMain = Enum.Font.GothamBold,
    FontTitle = Enum.Font.GothamBlack,
    FontButton = Enum.Font.Gotham,
    FontSizeDefault = 16,

    -- Corner Radius
    CornerRadiusSmall = UDim.new(0, 6),   -- For buttons, inputs
    CornerRadiusMedium = UDim.new(0, 10), -- For panels, scroll frames
    CornerRadiusLarge = UDim.new(0, 14),  -- For main frames

    -- Spacing & Padding
    Padding = 10,
    Spacing = 8,

    -- Shadow (requires a sliced square image asset ID with soft edges)
    ShadowImageId = "rbxassetid://1316045217", -- ! IMPORTANT: Replace with a proper shadow image ID
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.7,
    ShadowOffset = UDim2.new(0, 10, 0, 10), -- How far the shadow extends

    -- Animation Info
    TweenInfoDefault = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TweenInfoFast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TweenInfoBounce = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

-- endregion

-- region -- UTILITIES & HELPERS --

-- Function to create a new UI instance with default properties
local function createUIElement<T extends GuiObject>(instanceType: string, properties: {[string]: any}): T
    local element = Instance.new(instanceType) :: T
    for prop, value in pairs(properties) do
        if element[prop] ~= nil then -- Only set existing properties
            element[prop] = value
        end
    end
    return element
end

-- Applies UICorner to a GuiObject
local function applyCorner(guiObject: GuiObject, radius: UDim?): ()
    local corner = createUIElement("UICorner", {
        CornerRadius = radius or CoolUILib.Theme.CornerRadiusSmall
    })
    corner.Parent = guiObject
end

-- Applies a drop shadow to a GuiObject
local function applyShadow(guiObject: GuiObject, offset: UDim2?, transparency: number?, imageId: string?): ()
    local shadowOffset = offset or CoolUILib.Theme.ShadowOffset
    local shadowTransparency = transparency or CoolUILib.Theme.ShadowTransparency
    local shadowImage = imageId or CoolUILib.Theme.ShadowImageId

    local shadow = createUIElement("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, shadowOffset.X.Offset * 2, 1, shadowOffset.Y.Offset * 2),
        Position = UDim2.new(0, -shadowOffset.X.Offset, 0, -shadowOffset.Y.Offset),
        BackgroundTransparency = 1,
        Image = shadowImage,
        ImageColor3 = CoolUILib.Theme.ShadowColor,
        ImageTransparency = shadowTransparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118), -- Adjust based on your shadow image
        ZIndex = guiObject.ZIndex - 1 -- Ensure shadow is behind the main element
    })
    shadow.Parent = guiObject
end

-- Global Fade In animation
function CoolUILib.FadeIn(guiObject: GuiObject, duration: number?): ()
    if not guiObject:IsA("GuiObject") then return end
    local dur = duration or CoolUILib.Theme.TweenInfoDefault.Time

    guiObject.Visible = true -- Ensure it's visible before fading in

    local targets = { BackgroundTransparency = guiObject.BackgroundTransparency }
    if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
        targets.TextTransparency = 0
    elseif guiObject:IsA("ImageLabel") then
        targets.ImageTransparency = 0
    end
    
    -- Fade in the element itself
    local currentBgTransparency = guiObject.BackgroundTransparency
    local currentTextTransparency = if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then guiObject.TextTransparency else nil
    local currentImageTransparency = if guiObject:IsA("ImageLabel") then guiObject.ImageTransparency else nil

    guiObject.BackgroundTransparency = 1
    if currentTextTransparency ~= nil then guiObject.TextTransparency = 1 end
    if currentImageTransparency ~= nil then guiObject.ImageTransparency = 1 end

    local tweenProps = {
        BackgroundTransparency = currentBgTransparency,
        TextTransparency = currentTextTransparency,
        ImageTransparency = currentImageTransparency
    }
    
    TweenService:Create(guiObject, TweenInfo.new(dur, CoolUILib.Theme.TweenInfoDefault.EasingStyle, CoolUILib.Theme.TweenInfoDefault.EasingDirection), tweenProps):Play()

    -- Recursively fade in children
    for _, child in guiObject:GetChildren() do
        if child:IsA("GuiObject") and child.Name ~= "Shadow" then -- Don't fade shadow explicitly
            CoolUILib.FadeIn(child, dur * 0.8) -- Slightly faster for children
        end
    end
end

-- Global Fade Out animation
function CoolUILib.FadeOut(guiObject: GuiObject, duration: number?): ()
    if not guiObject:IsA("GuiObject") then return end
    local dur = duration or CoolUILib.Theme.TweenInfoDefault.Time

    local targets = { BackgroundTransparency = 1 }
    if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
        targets.TextTransparency = 1
    elseif guiObject:IsA("ImageLabel") then
        targets.ImageTransparency = 1
    end

    local tween = TweenService:Create(guiObject, TweenInfo.new(dur, CoolUILib.Theme.TweenInfoDefault.EasingStyle, CoolUILib.Theme.TweenInfoDefault.EasingDirection), targets)
    tween:Play()
    
    -- Recursively fade out children
    for _, child in guiObject:GetChildren() do
        if child:IsA("GuiObject") and child.Name ~= "Shadow" then
            CoolUILib.FadeOut(child, dur * 0.8)
        end
    end

    tween.Completed:Connect(function()
        guiObject.Visible = false
    end)
end

-- endregion

-- region -- CORE UI ELEMENTS --

-- Function to show an animated splash screen
function CoolUILib.ShowSplash(parent: GuiObject, text: string?, duration: number?)
    local splashDuration = duration or 2.5
    local splashText = text or "CoolUILib"

    local splashFrame = createUIElement("Frame", {
        Name = "SplashScreen",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = CoolUILib.Theme.Primary,
        BackgroundTransparency = 1, -- Starts invisible
        Parent = parent,
        ZIndex = 100 -- Ensure it's on top of everything
    })

    local gradient = createUIElement("UIGradient", {
        Color = CoolUILib.Theme.GradientMain,
        Transparency = NumberSequence.new(0.8, 0.95),
        Rotation = 90,
        Parent = splashFrame
    })

    local splashLabel = createUIElement("TextLabel", {
        Size = UDim2.new(0.5, 0, 0.2, 0),
        Position = UDim2.new(0.25, 0, 0.4, 0),
        BackgroundTransparency = 1,
        Text = splashText,
        TextColor3 = CoolUILib.Theme.Text,
        TextScaled = true,
        Font = CoolUILib.Theme.FontTitle,
        TextTransparency = 1, -- Starts invisible
        Parent = splashFrame
    })

    -- Fade in background and text
    TweenService:Create(splashFrame, CoolUILib.Theme.TweenInfoDefault, {BackgroundTransparency = 0.05}):Play()
    local textTween = TweenService:Create(splashLabel, CoolUILib.Theme.TweenInfoDefault, {TextTransparency = 0})
    textTween:Play()

    -- Text scaling bounce animation
    splashLabel.Size = UDim2.new(0.4, 0, 0.15, 0)
    splashLabel.Position = UDim2.new(0.3, 0, 0.425, 0)
    TweenService:Create(splashLabel, CoolUILib.Theme.TweenInfoBounce, {
        Size = UDim2.new(0.5, 0, 0.2, 0),
        Position = UDim2.new(0.25, 0, 0.4, 0)
    }):Play()

    task.wait(splashDuration)

    -- Fade out
    TweenService:Create(splashFrame, CoolUILib.Theme.TweenInfoDefault, {BackgroundTransparency = 1}):Play()
    TweenService:Create(splashLabel, CoolUILib.Theme.TweenInfoDefault, {TextTransparency = 1}):Play()

    task.wait(CoolUILib.Theme.TweenInfoDefault.Time)
    splashFrame:Destroy()
end

-- Creates a draggable main UI frame with title bar and shadow
function CoolUILib.CreateFrame(parent: GuiObject, size: UDim2, position: UDim2, name: string?, titleText: string?): Frame
    local frame = createUIElement("Frame", {
        Name = name or "CoolFrame",
        Size = size,
        Position = position,
        BackgroundColor3 = CoolUILib.Theme.Primary,
        BackgroundTransparency = CoolUILib.Theme.FrameTransparency,
        BorderSizePixel = 0,
        Parent = parent,
        ClipsDescendants = true,
        ZIndex = 1
    })
    applyCorner(frame, CoolUILib.Theme.CornerRadiusLarge)
    applyShadow(frame)

    -- Title Bar
    local titleBar = createUIElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = CoolUILib.Theme.Primary,
        BackgroundTransparency = CoolUILib.Theme.PanelTransparency,
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 2
    })
    local titleGradient = createUIElement("UIGradient", {
        Color = CoolUILib.Theme.GradientMain,
        Transparency = NumberSequence.new(0.8, 0.95),
        Rotation = 90,
        Parent = titleBar
    })
    -- Apply corners only to top of title bar if it's supposed to match frame
    applyCorner(titleBar, UDim.new(0, CoolUILib.Theme.CornerRadiusLarge.Offset))


    -- Title Label
    local titleLabel = CoolUILib.CreateLabel(
        titleBar,
        UDim2.new(1, -2 * CoolUILib.Theme.Padding, 1, 0),
        UDim2.new(0, CoolUILib.Theme.Padding, 0, 0),
        titleText or name or "Cool UI",
        "FrameTitle",
        CoolUILib.Theme.FontTitle,
        false, -- No text scaled for title, use explicit size
        CoolUILib.Theme.Text
    )
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Draggable functionality
    local isDragging = false
    local dragStartPos: Vector2
    local initialFramePos: UDim2

    titleBar.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPos = input.Position
            initialFramePos = frame.Position
            input:CaptureFocus() -- Keep focus even if mouse leaves button area
        end
    end)

    UserInputService.InputChanged:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
            local delta = input.Position - dragStartPos
            frame.Position = UDim2.new(initialFramePos.X.Scale, initialFramePos.X.Offset + delta.X,
                                        initialFramePos.Y.Scale, initialFramePos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            input:ReleaseFocus()
        end
    end)

    -- Attach titleBar as a property for easy access
    frame.TitleBar = titleBar
    frame.TitleLabel = titleLabel

    return frame
end

-- Creates a customizable text label
function CoolUILib.CreateLabel(parent: GuiObject, size: UDim2, position: UDim2, text: string, name: string?, font: Enum.Font?, textScaled: boolean?, textColor: Color3?): TextLabel
    local label = createUIElement("TextLabel", {
        Name = name or "CoolLabel",
        Size = size,
        Position = position,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = textColor or CoolUILib.Theme.Text,
        TextScaled = textScaled or false, -- Default to false for more control
        Font = font or CoolUILib.Theme.FontMain,
        TextSize = CoolUILib.Theme.FontSizeDefault,
        TextTransparency = 0,
        Parent = parent,
        ZIndex = 2
    })
    return label
end

-- Creates an interactive button with hover/click animations
function CoolUILib.CreateButton(parent: GuiObject, size: UDim2, position: UDim2, text: string, name: string?, callback: (() -> ())?): TextButton
    local button = createUIElement("TextButton", {
        Name = name or "CoolButton",
        Size = size,
        Position = position,
        BackgroundColor3 = CoolUILib.Theme.Secondary,
        BackgroundTransparency = CoolUILib.Theme.ButtonTransparency,
        Text = text,
        TextColor3 = CoolUILib.Theme.Text,
        TextScaled = true,
        Font = CoolUILib.Theme.FontButton,
        Parent = parent,
        ZIndex = 2
    })
    applyCorner(button, CoolUILib.Theme.CornerRadiusSmall)

    local initialSize = size
    local initialBgColor = CoolUILib.Theme.Secondary
    local initialBgTransparency = CoolUILib.Theme.ButtonTransparency

    -- Hover animation
    button.MouseEnter:Connect(function()
        TweenService:Create(button, CoolUILib.Theme.TweenInfoDefault, {
            BackgroundColor3 = CoolUILib.Theme.Accent,
            BackgroundTransparency = 0,
            Size = UDim2.new(initialSize.X.Scale * 1.03, initialSize.X.Offset, initialSize.Y.Scale * 1.03, initialSize.Y.Offset)
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, CoolUILib.Theme.TweenInfoDefault, {
            BackgroundColor3 = initialBgColor,
            BackgroundTransparency = initialBgTransparency,
            Size = initialSize
        }):Play()
    end)

    -- Click animation
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, CoolUILib.Theme.TweenInfoFast, {
            Size = UDim2.new(initialSize.X.Scale * 0.97, initialSize.X.Offset, initialSize.Y.Scale * 0.97, initialSize.Y.Offset),
            BackgroundColor3 = CoolUILib.Theme.AccentDark
        }):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, CoolUILib.Theme.TweenInfoFast, {
            Size = initialSize, -- Will be overridden by MouseLeave if mouse is gone
            BackgroundColor3 = button.MouseEnter:IsConnected() and CoolUILib.Theme.Accent or initialBgColor -- Return to hover or normal
        }):Play()
    end)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    return button
end

-- Creates a scrolling frame with auto-sizing canvas and layout
function CoolUILib.CreateScrollingFrame(parent: GuiObject, size: UDim2, position: UDim2, name: string?, contentPadding: number?): ScrollingFrame
    local scrollFrame = createUIElement("ScrollingFrame", {
        Name = name or "CoolScrollFrame",
        Size = size,
        Position = position,
        BackgroundColor3 = CoolUILib.Theme.Secondary,
        BackgroundTransparency = CoolUILib.Theme.PanelTransparency,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), -- Will be adjusted dynamically
        ScrollBarThickness = CoolUILib.Theme.Spacing,
        ScrollBarImageColor3 = CoolUILib.Theme.Accent,
        Parent = parent,
        ZIndex = 1
    })
    applyCorner(scrollFrame, CoolUILib.Theme.CornerRadiusMedium)

    local layout = createUIElement("UIListLayout", {
        Padding = UDim.new(0, contentPadding or CoolUILib.Theme.Spacing),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scrollFrame
    })

    -- Add internal padding to the scrolling content
    local uiPadding = createUIElement("UIPadding", {
        PaddingLeft = UDim.new(0, CoolUILib.Theme.Padding),
        PaddingRight = UDim.new(0, CoolUILib.Theme.Padding),
        PaddingTop = UDim.new(0, CoolUILib.Theme.Padding),
        PaddingBottom = UDim.new(0, CoolUILib.Theme.Padding),
        Parent = scrollFrame
    })

    -- Auto-adjust CanvasSize based on content
    local function updateCanvasSize()
        local contentHeight = layout.AbsoluteContentSize.Y
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + (CoolUILib.Theme.Padding * 2))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    -- Initial update in case items are added before layout is fully rendered
    RunService.Stepped:Wait() -- Give layout a frame to calculate
    updateCanvasSize()

    return scrollFrame
end

-- Creates a numerical slider with a thumb and value display
function CoolUILib.CreateSlider(parent: GuiObject, size: UDim2, position: UDim2, name: string?, minVal: number, maxVal: number, initialVal: number, step: number, onValueChangedCallback: ((value: number) -> ())?): (Frame, (value: number) -> ())
    local sliderFrame = createUIElement("Frame", {
        Name = name or "CoolSlider",
        Size = size,
        Position = position,
        BackgroundColor3 = CoolUILib.Theme.Secondary,
        BackgroundTransparency = CoolUILib.Theme.InputTransparency,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 2
    })
    applyCorner(sliderFrame, CoolUILib.Theme.CornerRadiusSmall)

    -- Value Label at the top
    local valueLabel = CoolUILib.CreateLabel(
        sliderFrame,
        UDim2.new(1, -2 * CoolUILib.Theme.Padding, 0, 20),
        UDim2.new(0, CoolUILib.Theme.Padding, 0, CoolUILib.Theme.Padding),
        tostring(initialVal), name .. "ValueLabel", CoolUILib.Theme.FontMain, false, CoolUILib.Theme.Text
    )
    valueLabel.TextSize = 16
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Track for the slider
    local trackHeight = 8
    local track = createUIElement("Frame", {
        Name = "Track",
        Size = UDim2.new(1, -2 * CoolUILib.Theme.Padding, 0, trackHeight),
        Position = UDim2.new(0, CoolUILib.Theme.Padding, 0, size.Y.Offset - CoolUILib.Theme.Padding - trackHeight),
        BackgroundColor3 = CoolUILib.Theme.Primary,
        BackgroundTransparency = CoolUILib.Theme.PanelTransparency,
        BorderSizePixel = 0,
        Parent = sliderFrame
    })
    applyCorner(track, UDim.new(0, trackHeight / 2))

    -- Fill for the slider (accent color)
    local fill = createUIElement("Frame", {
        Name = "Fill",
        Size = UDim2.new(0, 0, 1, 0), -- Width set dynamically
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = CoolUILib.Theme.Accent,
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
        BackgroundColor3 = CoolUILib.Theme.Text,
        BorderSizePixel = 0,
        Parent = track,
        ZIndex = 3
    })
    applyCorner(thumb, UDim.new(0, thumbSize / 2)) -- Make it circular

    local currentValue = math.clamp(initialVal, minVal, maxVal)

    local function updateSlider(value: number)
        value = math.clamp(value, minVal, maxVal)
        value = math.round(value / step) * step -- Apply snapping to step
        currentValue = value

        local percentage = (currentValue - minVal) / (maxVal - minVal)
        local thumbX = percentage * track.AbsoluteSize.X

        -- Tween thumb position and fill width
        TweenService:Create(thumb, CoolUILib.Theme.TweenInfoFast, {Position = UDim2.new(0, thumbX - thumbSize / 2, 0.5, -thumbSize / 2)}):Play()
        TweenService:Create(fill, CoolUILib.Theme.TweenInfoFast, {Size = UDim2.new(percentage, 0, 1, 0)}):Play()

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

    local function onThumbInputBegan(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            lastMouseX = input.Position.X
            thumb:CaptureFocus()
            TweenService:Create(thumb, CoolUILib.Theme.TweenInfoFast, {Size = UDim2.new(0, thumbSize * 1.2, 0, thumbSize * 1.2)}):Play() -- Enlarge on drag
        end
    end

    local function onThumbInputChanged(input: InputObject)
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

    local function onThumbInputEnded(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            thumb:ReleaseFocus()
            TweenService:Create(thumb, CoolUILib.Theme.TweenInfoFast, {Size = UDim2.new(0, thumbSize, 0, thumbSize)}):Play() -- Shrink back
        end
    end

    thumb.InputBegan:Connect(onThumbInputBegan)
    UserInputService.InputChanged:Connect(onThumbInputChanged)
    UserInputService.InputEnded:Connect(onThumbInputEnded)

    -- Clicking on the track also moves the thumb
    track.MouseButton1Click:Connect(function(x: number, y: number, input: InputObject)
        local mousePosInTrackX = input.Position.X - track.AbsolutePosition.X
        local newPercentage = math.clamp(mousePosInTrackX / track.AbsoluteSize.X, 0, 1)
        local newValue = minVal + newPercentage * (maxVal - minVal)
        updateSlider(newValue)
    end)

    return sliderFrame, updateSlider -- Return update function for external control
end

-- Creates a toggle switch (on/off)
function CoolUILib.CreateToggle(parent: GuiObject, size: UDim2, position: UDim2, name: string?, initialValue: boolean?, onToggledCallback: ((isOn: boolean) -> ())?): (Frame, (isOn: boolean) -> ())
    local toggleFrame = createUIElement("Frame", {
        Name = name or "CoolToggle",
        Size = size,
        Position = position,
        BackgroundColor3 = CoolUILib.Theme.Secondary,
        BackgroundTransparency = CoolUILib.Theme.InputTransparency,
        BorderSizePixel = 0,
        Parent = parent,
        ClipsDescendants = true,
        ZIndex = 2
    })
    applyCorner(toggleFrame, UDim.new(0, size.Y.Offset / 2)) -- Makes it pill-shaped

    local currentToggleValue = initialValue or false
    local padding = 4 -- Internal padding for the thumb

    local background = createUIElement("Frame", {
        Name = "Background",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = (currentToggleValue and CoolUILib.Theme.Accent or CoolUILib.Theme.TextMuted),
        BackgroundTransparency = CoolUILib.Theme.PanelTransparency,
        BorderSizePixel = 0,
        Parent = toggleFrame
    })
    applyCorner(background, UDim.new(0, size.Y.Offset / 2))

    local thumbSize = size.Y.Offset - 2 * padding
    local thumb = createUIElement("Frame", {
        Name = "Thumb",
        Size = UDim2.new(0, thumbSize, 0, thumbSize),
        Position = UDim2.new(0, (currentToggleValue and (size.X.Offset - thumbSize - padding) or padding), 0, padding),
        BackgroundColor3 = CoolUILib.Theme.Text,
        BorderSizePixel = 0,
        Parent = toggleFrame,
        ZIndex = 3
    })
    applyCorner(thumb, UDim.new(0, thumbSize / 2)) -- Make thumb circular

    local function updateToggle(value: boolean)
        currentToggleValue = value
        local targetX = (currentToggleValue and (size.X.Offset - thumbSize - padding) or padding)
        local targetBgColor = (currentToggleValue and CoolUILib.Theme.Accent or CoolUILib.Theme.TextMuted)

        TweenService:Create(thumb, CoolUILib.Theme.TweenInfoDefault, {Position = UDim2.new(0, targetX, 0, padding)}):Play()
        TweenService:Create(background, CoolUILib.Theme.TweenInfoDefault, {BackgroundColor3 = targetBgColor}):Play()

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
function CoolUILib.CreateDropdown(parent: GuiObject, size: UDim2, position: UDim2, name: string?, options: {string}, initialOption: string?, onOptionSelectedCallback: ((selectedOption: string, index: number) -> ())?): (Frame, (() -> string), ((option: string) -> ()))
    local dropdownFrame = createUIElement("Frame", {
        Name = name or "CoolDropdown",
        Size = size,
        Position = position,
        BackgroundColor3 = CoolUILib.Theme.Secondary,
        BackgroundTransparency = CoolUILib.Theme.InputTransparency,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 2
    })
    applyCorner(dropdownFrame, CoolUILib.Theme.CornerRadiusSmall)

    local currentSelectedOption = initialOption or (options and options[1]) or "Select Option"
    local isOpen = false

    local mainButton = CoolUILib.CreateButton(
        dropdownFrame,
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        currentSelectedOption,
        name .. "Button"
    )
    mainButton.TextScaled = false
    mainButton.TextSize = CoolUILib.Theme.FontSizeDefault
    mainButton.TextXAlignment = Enum.TextXAlignment.Left
    mainButton.TextWrapped = false
    mainButton.Text = currentSelectedOption -- Set initial text

    -- Dropdown arrow icon
    local arrowIcon = createUIElement("ImageLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -2 * CoolUILib.Theme.Padding - 20, 0.5, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://492061099", -- Down arrow icon (or any suitable icon)
        ImageColor3 = CoolUILib.Theme.Text,
        Parent = mainButton,
        ZIndex = 3
    })

    local optionsFrame = createUIElement("Frame", {
        Name = "OptionsFrame",
        Size = UDim2.new(1, 0, 0, 0), -- Height will be dynamic, starts at 0
        Position = UDim2.new(0, 0, 1, 0), -- Below the main button
        BackgroundColor3 = CoolUILib.Theme.Secondary,
        BackgroundTransparency = CoolUILib.Theme.InputTransparency,
        BorderSizePixel = 0,
        Parent = dropdownFrame,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 4 -- Ensure options appear above other UI
    })
    applyCorner(optionsFrame, CoolUILib.Theme.CornerRadiusSmall)
    applyShadow(optionsFrame, UDim2.new(0, 5, 0, 5), CoolUILib.Theme.ShadowTransparency * 0.5)

    local optionsLayout = createUIElement("UIListLayout", {
        Padding = UDim.new(0, CoolUILib.Theme.Spacing / 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionsFrame
    })
    local optionsPadding = createUIElement("UIPadding", {
        PaddingLeft = UDim.new(0, CoolUILib.Theme.Padding / 2),
        PaddingRight = UDim.new(0, CoolUILib.Theme.Padding / 2),
        PaddingTop = UDim.new(0, CoolUILib.Theme.Padding / 2),
        PaddingBottom = UDim.new(0, CoolUILib.Theme.Padding / 2),
        Parent = optionsFrame
    })

    local optionButtons: {TextButton} = {}

    local function closeDropdown()
        if not isOpen then return end
        isOpen = false
        TweenService:Create(optionsFrame, CoolUILib.Theme.TweenInfoDefault, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = CoolUILib.Theme.InputTransparency
        }):Play()
        TweenService:Create(arrowIcon, CoolUILib.Theme.TweenInfoDefault, {Rotation = 0}):Play()
        task.delay(CoolUILib.Theme.TweenInfoDefault.Time, function()
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
        
        TweenService:Create(optionsFrame, CoolUILib.Theme.TweenInfoDefault, {
            Size = UDim2.new(1, 0, 0, totalOptionsHeight),
            BackgroundTransparency = CoolUILib.Theme.PanelTransparency
        }):Play()
        TweenService:Create(arrowIcon, CoolUILib.Theme.TweenInfoDefault, {Rotation = 180}):Play()
    end

    for i, optionText in ipairs(options) do
        local optionButton = CoolUILib.CreateButton(
            optionsFrame,
            UDim2.new(1, 0, 0, size.Y.Offset), -- Each option takes full width, fixed height
            UDim2.new(0, 0, 0, 0),
            optionText,
            name .. "Option" .. i
        )
        optionButton.LayoutOrder = i
        optionButton.TextScaled = false
        optionButton.TextSize = CoolUILib.Theme.FontSizeDefault
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
    UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
            local mousePos = input.Position
            local dropdownAbsolutePos = dropdownFrame.AbsolutePosition
            local dropdownAbsoluteSize = dropdownFrame.AbsoluteSize
            
            -- Check if click is outside the entire dropdown area (including options)
            local optionsFrameAbsoluteSize = optionsFrame.AbsoluteSize
            local totalHeight = dropdownAbsoluteSize.Y + optionsFrameAbsoluteSize.Y
            
            local isClickInsideDropdown = (
                mousePos.X >= dropdownAbsolutePos.X and mousePos.X <= dropdownAbsolutePos.X + dropdownAbsoluteSize.X and
                mousePos.Y >= dropdownAbsolutePos.Y and mousePos.Y <= dropdownAbsolutePos.Y + totalHeight
            )
            
            if not isClickInsideDropdown then
                closeDropdown()
            end
        end
    end)

    local function getSelectedOption(): string
        return currentSelectedOption
    end

    local function setSelectedOption(option: string)
        if table.find(options, option) then
            currentSelectedOption = option
            mainButton.Text = currentSelectedOption
            -- Optionally trigger callback here too
        end
    end

    return dropdownFrame, getSelectedOption, setSelectedOption
end

-- Creates a TextBox for user text input
function CoolUILib.CreateTextBox(parent: GuiObject, size: UDim2, position: UDim2, name: string?, placeholderText: string?, initialText: string?, onTextChangedCallback: ((text: string) -> ())?, onFocusLostCallback: ((text: string, cause: Enum.FocusLostCause) -> ())?): TextBox
    local textBox = createUIElement("TextBox", {
        Name = name or "CoolTextBox",
        Size = size,
        Position = position,
        BackgroundColor3 = CoolUILib.Theme.Secondary,
        BackgroundTransparency = CoolUILib.Theme.InputTransparency,
        BorderSizePixel = 0,
        Text = initialText or "",
        PlaceholderText = placeholderText or "",
        PlaceholderColor3 = CoolUILib.Theme.TextMuted,
        TextColor3 = CoolUILib.Theme.Text,
        Font = CoolUILib.Theme.FontMain,
        TextSize = CoolUILib.Theme.FontSizeDefault,
        ClearTextOnFocus = false,
        Parent = parent,
        ZIndex = 2
    })
    applyCorner(textBox, CoolUILib.Theme.CornerRadiusSmall)

    -- Initial transparency for placeholder
    textBox.TextTransparency = (textBox.Text == "" and 0.5 or 0)

    textBox.Focused:Connect(function()
        TweenService:Create(textBox, CoolUILib.Theme.TweenInfoFast, {BackgroundTransparency = 0.05}):Play()
        TweenService:Create(textBox, CoolUILib.Theme.TweenInfoFast, {TextTransparency = 0}):Play()
    end)

    textBox.FocusLost:Connect(function(enterPressed: boolean, inputReason: Enum.FocusLostCause)
        TweenService:Create(textBox, CoolUILib.Theme.TweenInfoFast, {BackgroundTransparency = CoolUILib.Theme.InputTransparency}):Play()
        if textBox.Text == "" then
            TweenService:Create(textBox, CoolUILib.Theme.TweenInfoFast, {TextTransparency = 0.5}):Play()
        end
        if onFocusLostCallback then
            onFocusLostCallback(textBox.Text, inputReason)
        end
    end)

    textBox.Changed:Connect(function(property: string)
        if property == "Text" then
            if onTextChangedCallback then
                onTextChangedCallback(textBox.Text)
            end
            TweenService:Create(textBox, CoolUILib.Theme.TweenInfoFast, {TextTransparency = (textBox.Text == "" and 0.5 or 0)}):Play()
        end
    end)

    return textBox
end

-- Creates an ImageLabel
function CoolUILib.CreateImage(parent: GuiObject, size: UDim2, position: UDim2, name: string?, imageId: string, imageColor: Color3?): ImageLabel
    local image = createUIElement("ImageLabel", {
        Name = name or "CoolImage",
        Size = size,
        Position = position,
        BackgroundTransparency = 1,
        Image = imageId,
        ImageColor3 = imageColor or Color3.fromRGB(255, 255, 255),
        Parent = parent,
        ZIndex = 2
    })
    applyCorner(image, CoolUILib.Theme.CornerRadiusSmall)
    return image
end

-- endregion

return CoolUILib
