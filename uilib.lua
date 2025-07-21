-- CoolUILib: Enhanced UI library for Roblox with splash screen
-- Place this script in a ModuleScript under ReplicatedStorage (Name it: CoolUILib)

local CoolUILib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Modern theme with glassmorphism and subtle gradients
local theme = {
    PrimaryColor = Color3.fromRGB(20, 20, 30),        -- Dark translucent background for main frames
    SecondaryColor = Color3.fromRGB(40, 40, 60),      -- Background for panels within frames
    AccentColor = Color3.fromRGB(0, 180, 255),        -- Vibrant cyan for active elements/highlights
    TextColor = Color3.fromRGB(230, 230, 255),        -- Soft white for general text
    PlaceholderColor = Color3.fromRGB(150, 150, 150), -- Placeholder text color
    ErrorColor = Color3.fromRGB(200, 50, 50),         -- Error/warning color
    SuccessColor = Color3.fromRGB(50, 200, 50),       -- Success/confirmation color
    ButtonHoverColor = Color3.fromRGB(0, 210, 255),   -- Button hover color
    ButtonActiveColor = Color3.fromRGB(0, 150, 200),  -- Button click color

    Gradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 255))
    },
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.7,
    ShadowOffset = UDim2.new(0, 10, 0, 10), -- Offset for the shadow effect

    Font = Enum.Font.GothamBold,
    ButtonFont = Enum.Font.Gotham,
    TitleFont = Enum.Font.GothamBlack,

    CornerRadius = UDim.new(0, 12), -- General corner radius for frames
    ButtonCornerRadius = UDim.new(0, 8), -- Corner radius for buttons
    Padding = 10, -- Default padding for layout
    ScrollbarThickness = 6,
}

-- Utility function for creating common UI elements
local function createUIElement(instanceType, properties)
    local element = Instance.new(instanceType)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

-- --- ANIMATION UTILITIES ---
-- General tween information for various effects
local tweenInfo = {
    Default = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Fast = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

-- Function to apply rounded corners
local function applyCorner(guiObject, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or theme.CornerRadius
    corner.Parent = guiObject
end

-- Function to apply drop shadow (requires a sliced ImageLabel asset ID)
local function applyShadow(guiObject, offset, transparency)
    local shadow = createUIElement("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, offset.X.Offset * 2, 1, offset.Y.Offset * 2),
        Position = UDim2.new(0, -offset.X.Offset, 0, -offset.Y.Offset),
        BackgroundTransparency = 1,
        -- IMPORTANT: Replace with a valid Roblox Asset ID for a sliced shadow image (e.g., a simple square with soft edges)
        Image = "rbxassetid://1316045217", -- This is a common placeholder, find or create a proper one
        ImageColor3 = theme.ShadowColor,
        ImageTransparency = transparency or theme.ShadowTransparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118), -- Adjust based on your shadow image
        ZIndex = guiObject.ZIndex - 1 -- Ensure shadow is behind
    })
    shadow.Parent = guiObject
end

--- ANIMATED SPLASH SCREEN ---
function CoolUILib.ShowSplash(parent)
    local splash = createUIElement("Frame", {
        Name = "SplashScreen",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.PrimaryColor,
        BackgroundTransparency = 1, -- Start transparent
        Parent = parent,
        ZIndex = 10 -- Ensure it's on top
    })

    -- Background Gradient (Subtle)
    local bgGradient = createUIElement("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 40))
        },
        Parent = splash
    })

    -- Splash Label
    local label = createUIElement("TextLabel", {
        Size = UDim2.new(0.5, 0, 0.2, 0),
        Position = UDim2.new(0.25, 0, 0.4, 0),
        BackgroundTransparency = 1,
        Text = "CoolUILib", -- Or your desired name
        TextColor3 = theme.TextColor,
        TextScaled = true,
        Font = theme.TitleFont,
        TextTransparency = 1, -- Start transparent
        Parent = splash
    })

    -- Fade-in animation for splash background and text
    TweenService:Create(splash, tweenInfo.Slow, {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(label, tweenInfo.Slow, {TextTransparency = 0}):Play()

    -- Scale and fade-in animation for the text
    local initialScale = UDim2.new(0.4, 0, 0.15, 0)
    label.Size = initialScale
    label.Position = UDim2.new(0.3, 0, 0.425, 0)
    TweenService:Create(label, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.5, 0, 0.2, 0),
        Position = UDim2.new(0.25, 0, 0.4, 0)
    }):Play()

    task.wait(2) -- Display duration

    -- Fade-out animation
    TweenService:Create(splash, tweenInfo.Default, {BackgroundTransparency = 1}):Play()
    TweenService:Create(label, tweenInfo.Default, {TextTransparency = 1}):Play()

    task.wait(tweenInfo.Default.Time)
    splash:Destroy()
end

--- UI ELEMENTS CREATION ---

-- Base frame with glassmorphism, shadow, and draggable title bar
function CoolUILib.CreateFrame(parent, size, position, name)
    local frame = createUIElement("Frame", {
        Name = name or "CoolFrame",
        Size = size,
        Position = position,
        BackgroundColor3 = theme.PrimaryColor,
        BackgroundTransparency = 0.2, -- Glassmorphism effect
        BorderSizePixel = 0,
        Parent = parent,
        ClipsDescendants = true -- Important for rounded corners and overflow
    })
    applyCorner(frame)
    applyShadow(frame, theme.ShadowOffset, theme.ShadowTransparency)

    -- Title Bar for dragging
    local titleBar = createUIElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40), -- Fixed height title bar
        BackgroundColor3 = theme.PrimaryColor,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 2
    })
    local titleBarGradient = createUIElement("UIGradient", {
        Color = theme.Gradient,
        Transparency = NumberSequence.new(0.8, 0.95), -- Subtle gradient
        Rotation = 90,
        Parent = titleBar
    })
    applyCorner(titleBar, UDim.new(0, theme.CornerRadius.Offset)) -- Only top corners if desired, or use frame's corner

    -- Make frame draggable by its title bar
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging = false
        end
    end)

    -- You can add a title label to this titleBar separately using CoolUILib.CreateLabel
    -- Example: CoolUILib.CreateLabel(titleBar, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), "My Hub", "FrameTitle")

    return frame
end

-- Create a text label
function CoolUILib.CreateLabel(parent, size, position, text, name, font, textScaled, textColor)
    local label = createUIElement("TextLabel", {
        Name = name or "CoolLabel",
        Size = size,
        Position = position,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = textColor or theme.TextColor,
        TextScaled = textScaled ~= nil and textScaled or true, -- Default to true
        Font = font or theme.Font,
        TextTransparency = 0,
        Parent = parent,
        ZIndex = 2
    })
    return label
end

-- Create a button with hover, click, and text animations
function CoolUILib.CreateButton(parent, size, position, text, name, callback)
    local button = createUIElement("TextButton", {
        Name = name or "CoolButton",
        Size = size,
        Position = position,
        BackgroundColor3 = theme.SecondaryColor,
        BackgroundTransparency = 0.15,
        Text = text,
        TextColor3 = theme.TextColor,
        TextScaled = true,
        Font = theme.ButtonFont,
        Parent = parent,
        ZIndex = 2
    })
    applyCorner(button, theme.ButtonCornerRadius)

    -- Hover animation
    local hoverTween = TweenService:Create(button, tweenInfo.Default, {
        BackgroundColor3 = theme.ButtonHoverColor,
        BackgroundTransparency = 0
    })
    local leaveTween = TweenService:Create(button, tweenInfo.Default, {
        BackgroundColor3 = theme.SecondaryColor,
        BackgroundTransparency = 0.15
    })
    local textLeaveTween = TweenService:Create(button, tweenInfo.Default, {
        TextTransparency = 0
    })

    button.MouseEnter:Connect(function()
        hoverTween:Play()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(size.X.Scale * 1.05, 0, size.Y.Scale * 1.05, 0)}):Play()
        TweenService:Create(button, tweenInfo.Fast, {TextTransparency = 0.05}):Play() -- Subtle text fade
    end)
    button.MouseLeave:Connect(function()
        leaveTween:Play()
        TweenService:Create(button, tweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = size}):Play()
        textLeaveTween:Play()
    end)

    -- Click animation
    local clickDownTween = TweenService:Create(button, tweenInfo.Fast, {
        Size = UDim2.new(size.X.Scale * 0.95, 0, size.Y.Scale * 0.95, 0),
        BackgroundColor3 = theme.ButtonActiveColor
    })
    local clickUpTween = TweenService:Create(button, tweenInfo.Fast, {
        Size = size,
        BackgroundColor3 = theme.ButtonHoverColor -- Return to hover color if still hovering
    })

    button.MouseButton1Down:Connect(function()
        clickDownTween:Play()
    end)
    button.MouseButton1Up:Connect(function()
        clickUpTween:Play()
    end)

    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
        -- Add a subtle visual feedback after click
        local feedbackTween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.5 -- Flash
        })
        feedbackTween:Play()
        feedbackTween.Completed:Wait()
        -- Return to normal state (or hover state if mouse is still over)
        if button.AbsolutePosition.X <= UserInputService:GetMouseLocation().X and
           UserInputService:GetMouseLocation().X <= button.AbsolutePosition.X + button.AbsoluteSize.X and
           button.AbsolutePosition.Y <= UserInputService:GetMouseLocation().Y and
           UserInputService:GetMouseLocation().Y <= button.AbsolutePosition.Y + button.AbsoluteSize.Y then
            hoverTween:Play()
        else
            leaveTween:Play()
        end
    end)
    return button
end

-- Create a scrolling frame with improved styling
function CoolUILib.CreateScrollingFrame(parent, size, position, name, contentPadding)
    local scrollFrame = createUIElement("ScrollingFrame", {
        Name = name or "CoolScrollFrame",
        Size = size,
        Position = position,
        BackgroundColor3 = theme.SecondaryColor,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), -- Will be adjusted by UIListLayout
        ScrollBarThickness = theme.ScrollbarThickness,
        ScrollBarImageColor3 = theme.AccentColor,
        -- Set ScrollBarImage or ScrollBarInset for custom scrollbar visuals if desired
        Parent = parent,
        ZIndex = 1
    })
    applyCorner(scrollFrame, theme.ButtonCornerRadius) -- Slightly smaller corners for content

    -- Content layout
    local layout = createUIElement("UIListLayout", {
        Padding = UDim.new(0, contentPadding or theme.Padding),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scrollFrame
    })

    -- Add padding inside the scroll frame
    local uiPadding = createUIElement("UIPadding", {
        PaddingLeft = UDim.new(0, theme.Padding),
        PaddingRight = UDim.new(0, theme.Padding),
        PaddingTop = UDim.new(0, theme.Padding),
        PaddingBottom = UDim.new(0, theme.Padding),
        Parent = scrollFrame
    })

    -- Auto-adjust CanvasSize
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (theme.Padding * 2)) -- Add vertical padding
    end)

    return scrollFrame, layout -- Return layout so external code can add items with LayoutOrder
end

-- Create a customizable Slider
function CoolUILib.CreateSlider(parent, size, position, name, minVal, maxVal, initialVal, step, onValueChangedCallback)
    local sliderFrame = createUIElement("Frame", {
        Name = name or "CoolSlider",
        Size = size,
        Position = position,
        BackgroundColor3 = theme.SecondaryColor,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 2
    })
    applyCorner(sliderFrame, theme.ButtonCornerRadius)

    -- Track
    local track = createUIElement("Frame", {
        Name = "Track",
        Size = UDim2.new(0.9, 0, 0.2, 0), -- Horizontal track
        Position = UDim2.new(0.05, 0, 0.6, 0),
        BackgroundColor3 = Color3.fromRGB(80, 80, 100),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = sliderFrame
    })
    applyCorner(track, UDim.new(0, 4))

    -- Fill
    local fill = createUIElement("Frame", {
        Name = "Fill",
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.AccentColor,
        BorderSizePixel = 0,
        Parent = track
    })
    applyCorner(fill, UDim.new(0, 4))

    -- Thumb
    local thumb = createUIElement("ImageLabel", {
        Name = "Thumb",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, -10, 0.5, -10), -- Initial position, adjusted dynamically
        BackgroundColor3 = theme.AccentColor,
        BackgroundTransparency = 0,
        Image = "rbxassetid://6233159954", -- Circle image for thumb (or use a Frame with UICorner)
        ImageColor3 = theme.AccentColor,
        Parent = track,
        ZIndex = 3
    })
    applyCorner(thumb, UDim.new(0, 10)) -- Makes it circular if size is square

    -- Value Label
    local valueLabel = CoolUILib.CreateLabel(sliderFrame,
        UDim2.new(0.9, 0, 0.3, 0), UDim2.new(0.05, 0, 0.1, 0),
        tostring(initialVal or minVal), name .. "ValueLabel", theme.Font, false, theme.TextColor) -- TextScaled=false

    minVal = minVal or 0
    maxVal = maxVal or 100
    initialVal = initialVal or minVal
    step = step or 1

    local currentValue = math.clamp(initialVal, minVal, maxVal)

    local function updateSlider(value)
        value = math.clamp(value, minVal, maxVal)
        value = math.round(value / step) * step -- Apply step
        currentValue = value

        local percentage = (currentValue - minVal) / (maxVal - minVal)
        local thumbX = percentage * track.AbsoluteSize.X
        local thumbPos = UDim2.new(0, thumbX - thumb.AbsoluteSize.X / 2, 0.5, -thumb.AbsoluteSize.Y / 2)

        TweenService:Create(thumb, tweenInfo.Fast, {Position = thumbPos}):Play()
        TweenService:Create(fill, tweenInfo.Fast, {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
        valueLabel.Text = tostring(currentValue)
        if onValueChangedCallback then
            onValueChangedCallback(currentValue)
        end
    end

    -- Initial update
    updateSlider(currentValue)

    -- Dragging logic
    local isDragging = false
    local startThumbPos
    local startMousePos

    thumb.MouseButton1Down:Connect(function(x, y, input)
        isDragging = true
        startThumbPos = thumb.Position.X.Offset
        startMousePos = input.Position
        thumb:CaptureFocus() -- Keep focus while dragging
        TweenService:Create(thumb, tweenInfo.Fast, {Size = UDim2.new(0, 24, 0, 24)}):Play() -- Enlarge thumb on drag
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
            local deltaX = input.Position.X - startMousePos.X
            local newThumbX = startThumbPos + deltaX
            local newPercentage = math.clamp(newThumbX / track.AbsoluteSize.X, 0, 1)
            local newValue = minVal + newPercentage * (maxVal - minVal)
            updateSlider(newValue)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            thumb:ReleaseFocus()
            TweenService:Create(thumb, tweenInfo.Fast, {Size = UDim2.new(0, 20, 0, 20)}):Play() -- Return thumb to normal size
        end
    end)
    
    track.MouseButton1Click:Connect(function(x, y, input)
        local mousePosInTrack = input.Position.X - track.AbsolutePosition.X
        local newPercentage = math.clamp(mousePosInTrack / track.AbsoluteSize.X, 0, 1)
        local newValue = minVal + newPercentage * (maxVal - minVal)
        updateSlider(newValue)
    end)

    return sliderFrame, updateSlider -- Return updateSlider for external control
end


-- Create a Toggle switch
function CoolUILib.CreateToggle(parent, size, position, name, initialValue, onToggledCallback)
    local toggleFrame = createUIElement("Frame", {
        Name = name or "CoolToggle",
        Size = size,
        Position = position,
        BackgroundColor3 = theme.SecondaryColor,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Parent = parent,
        ClipsDescendants = true, -- For smooth thumb movement
        ZIndex = 2
    })
    applyCorner(toggleFrame, UDim.new(0, size.Y.Offset / 2)) -- Make it pill-shaped

    local toggleEnabled = initialValue or false

    local background = createUIElement("Frame", {
        Name = "Background",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = (toggleEnabled and theme.AccentColor or Color3.fromRGB(100, 100, 100)),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = toggleFrame
    })
    applyCorner(background, UDim.new(0, size.Y.Offset / 2))

    local thumb = createUIElement("Frame", {
        Name = "Thumb",
        Size = UDim2.new(0, size.Y.Offset - 8, 0, size.Y.Offset - 8), -- Slightly smaller than height
        Position = UDim2.new(0, (toggleEnabled and (size.X.Offset - size.Y.Offset + 4) or 4), 0, 4), -- 4px padding
        BackgroundColor3 = theme.TextColor,
        BorderSizePixel = 0,
        Parent = toggleFrame,
        ZIndex = 3
    })
    applyCorner(thumb, UDim.new(0, (size.Y.Offset - 8) / 2)) -- Make thumb circular

    local function updateToggle(value)
        toggleEnabled = value
        local targetX = (toggleEnabled and (size.X.Offset - size.Y.Offset + 4) or 4)
        local targetColor = (toggleEnabled and theme.AccentColor or Color3.fromRGB(100, 100, 100))

        TweenService:Create(thumb, tweenInfo.Default, {Position = UDim2.new(0, targetX, 0, 4)}):Play()
        TweenService:Create(background, tweenInfo.Default, {BackgroundColor3 = targetColor}):Play()

        if onToggledCallback then
            onToggledCallback(toggleEnabled)
        end
    end

    toggleFrame.MouseButton1Click:Connect(function()
        updateToggle(not toggleEnabled)
    end)

    return toggleFrame, updateToggle -- Return updateToggle for external control
end

-- Create a Dropdown menu
function CoolUILib.CreateDropdown(parent, size, position, name, options, initialOption, onOptionSelectedCallback)
    local dropdownFrame = createUIElement("Frame", {
        Name = name or "CoolDropdown",
        Size = size,
        Position = position,
        BackgroundColor3 = theme.SecondaryColor,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 2
    })
    applyCorner(dropdownFrame, theme.ButtonCornerRadius)

    local currentOption = initialOption or (options and options[1]) or "Select Option"
    local isOpen = false

    local mainButton = CoolUILib.CreateButton(dropdownFrame,
        UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), currentOption, name .. "Button")
    
    -- Change button text
    mainButton.TextScaled = false
    mainButton.TextXAlignment = Enum.TextXAlignment.Left
    mainButton.TextWrapped = false
    mainButton.Text = currentOption
    mainButton.Size = UDim2.new(1,0,1,0) -- Ensure button fills the frame
    
    -- Dropdown arrow
    local arrow = createUIElement("ImageLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://492061099", -- Roblox arrow icon (down) - Find a good one
        ImageColor3 = theme.TextColor,
        Parent = mainButton,
        ZIndex = 3
    })

    local optionsFrame = createUIElement("Frame", {
        Name = "OptionsFrame",
        Size = UDim2.new(1, 0, 0, 0), -- Height will be dynamic
        Position = UDim2.new(0, 0, 1, 0), -- Below the main button
        BackgroundColor3 = theme.SecondaryColor,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Parent = dropdownFrame,
        Visible = false,
        ZIndex = 4 -- Make sure options are above other UI elements
    })
    applyCorner(optionsFrame, theme.ButtonCornerRadius)
    applyShadow(optionsFrame, UDim2.new(0,5,0,5), theme.ShadowTransparency * 0.5) -- Lighter shadow for dropdown options

    local optionsLayout = createUIElement("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionsFrame
    })
    
    local optionsUIPadding = createUIElement("UIPadding", {
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = optionsFrame
    })

    local optionButtons = {}

    local function closeDropdown()
        isOpen = false
        TweenService:Create(optionsFrame, tweenInfo.Default, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 0.05
        }):Play()
        TweenService:Create(arrow, tweenInfo.Default, {Rotation = 0}):Play()
        task.wait(tweenInfo.Default.Time)
        optionsFrame.Visible = false
    end

    local function openDropdown()
        isOpen = true
        optionsFrame.Visible = true
        local targetHeight = #options * (size.Y.Offset - 5) + optionsLayout.Padding.Offset * (#options -1) + optionsUIPadding.PaddingTop.Offset + optionsUIPadding.PaddingBottom.Offset -- Calculate height based on number of options and padding
        TweenService:Create(optionsFrame, tweenInfo.Default, {
            Size = UDim2.new(1, 0, 0, targetHeight),
            BackgroundTransparency = 0.25
        }):Play()
        TweenService:Create(arrow, tweenInfo.Default, {Rotation = 180}):Play()
    end

    for i, optionText in ipairs(options) do
        local optionButton = CoolUILib.CreateButton(optionsFrame,
            UDim2.new(1, 0, 0, size.Y.Offset - 5), UDim2.new(0, 0, 0, 0),
            optionText, name .. "Option" .. i)
        optionButton.LayoutOrder = i -- For UIListLayout
        optionButton.TextScaled = false
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.Text = optionText

        optionButton.MouseButton1Click:Connect(function()
            currentOption = optionText
            mainButton.Text = currentOption
            closeDropdown()
            if onOptionSelectedCallback then
                onOptionSelectedCallback(currentOption, i)
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
            
            local isClickInsideDropdown = (
                mousePos.X >= dropdownAbsolutePos.X and mousePos.X <= dropdownAbsolutePos.X + dropdownAbsoluteSize.X and
                mousePos.Y >= dropdownAbsolutePos.Y and mousePos.Y <= dropdownAbsolutePos.Y + dropdownAbsoluteSize.Y
            )
            
            if not isClickInsideDropdown then
                closeDropdown()
            end
        end
    end)


    local function getSelectedOption()
        return currentOption
    end

    local function setSelectedOption(option)
        if table.find(options, option) then
            currentOption = option
            mainButton.Text = currentOption
            -- Optionally trigger callback here too
        end
    end

    return dropdownFrame, getSelectedOption, setSelectedOption
end

-- Create a TextBox for user input
function CoolUILib.CreateTextBox(parent, size, position, name, placeholderText, initialText, onTextChangedCallback, onFocusLostCallback)
    local textBox = createUIElement("TextBox", {
        Name = name or "CoolTextBox",
        Size = size,
        Position = position,
        BackgroundColor3 = theme.SecondaryColor,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = initialText or "",
        PlaceholderText = placeholderText or "",
        PlaceholderColor3 = theme.PlaceholderColor,
        TextColor3 = theme.TextColor,
        Font = theme.Font,
        TextScaled = false, -- TextBoxes usually don't scale text
        TextSize = 16, -- Default text size, can be overridden
        ClearTextOnFocus = false,
        Parent = parent,
        ZIndex = 2
    })
    applyCorner(textBox, theme.ButtonCornerRadius)

    textBox.TextTransparency = (textBox.Text == "" and 0.5 or 0) -- Start transparent if empty

    textBox.Focused:Connect(function()
        TweenService:Create(textBox, tweenInfo.Fast, {BackgroundTransparency = 0.05}):Play()
        TweenService:Create(textBox, tweenInfo.Fast, {TextTransparency = 0}):Play()
    end)

    textBox.FocusLost:Connect(function()
        TweenService:Create(textBox, tweenInfo.Fast, {BackgroundTransparency = 0.2}):Play()
        if textBox.Text == "" then
            TweenService:Create(textBox, tweenInfo.Fast, {TextTransparency = 0.5}):Play()
        end
        if onFocusLostCallback then
            onFocusLostCallback(textBox.Text, textBox.FocusLostCause)
        end
    end)

    textBox.Changed:Connect(function(property)
        if property == "Text" then
            if onTextChangedCallback then
                onTextChangedCallback(textBox.Text)
            end
            TweenService:Create(textBox, tweenInfo.Fast, {TextTransparency = (textBox.Text == "" and 0.5 or 0)}):Play()
        end
    end)

    return textBox
end

-- Create an ImageLabel
function CoolUILib.CreateImage(parent, size, position, name, imageId, imageColor)
    local image = createUIElement("ImageLabel", {
        Name = name or "CoolImage",
        Size = size,
        Position = position,
        BackgroundTransparency = 1, -- Usually images don't have backgrounds
        Image = imageId,
        ImageColor3 = imageColor or Color3.fromRGB(255, 255, 255),
        Parent = parent,
        ZIndex = 2
    })
    applyCorner(image, theme.ButtonCornerRadius) -- Apply rounded corners to images too if desired
    return image
end


-- Global Fade In/Out for any GuiObject
function CoolUILib.FadeIn(guiObject, duration, targetTransparency)
    if not guiObject:IsA("GuiObject") then return end
    duration = duration or tweenInfo.Default.Time
    targetTransparency = targetTransparency or 0.1 -- Default for frames, text will be 0

    local properties = {BackgroundTransparency = targetTransparency}
    if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
        properties.TextTransparency = 0
    end

    guiObject.Visible = true -- Ensure it's visible before fading in
    TweenService:Create(guiObject, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()

    -- Recursively fade in children
    for _, child in pairs(guiObject:GetChildren()) do
        if child:IsA("GuiObject") then
            -- Determine appropriate target transparency for children based on their type
            local childTargetTransparency = (child:IsA("Frame") or child:IsA("ScrollingFrame") or child:IsA("ImageLabel")) and 0.2 or 0
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                 childTargetTransparency = 0
            end
            TweenService:Create(child, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = childTargetTransparency,
                TextTransparency = (child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox")) and 0 or nil,
                ImageTransparency = child:IsA("ImageLabel") and 0 or nil
            }):Play()
        end
    end
end

function CoolUILib.FadeOut(guiObject, duration)
    if not guiObject:IsA("GuiObject") then return end
    duration = duration or tweenInfo.Default.Time

    local properties = {BackgroundTransparency = 1}
    if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
        properties.TextTransparency = 1
    end

    local tween = TweenService:Create(guiObject, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    
    -- Recursively fade out children
    for _, child in pairs(guiObject:GetChildren()) do
        if child:IsA("GuiObject") then
            TweenService:Create(child, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1,
                TextTransparency = (child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox")) and 1 or nil,
                ImageTransparency = child:IsA("ImageLabel") and 1 or nil
            }):Play()
        end
    end

    -- Hide element after fading out
    tween.Completed:Connect(function()
        guiObject.Visible = false
    end)
end


return CoolUILib
