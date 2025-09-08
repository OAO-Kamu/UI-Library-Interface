local DeltaUILib = {}

DeltaUILib.Themes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 40),
        Primary = Color3.fromRGB(100, 150, 255),
        Secondary = Color3.fromRGB(80, 200, 120),
        Text = Color3.fromRGB(240, 240, 240),
        Border = Color3.fromRGB(60, 60, 70),
        Subtitle = Color3.fromRGB(180, 180, 200),
        Warning = Color3.fromRGB(255, 193, 7),
        Danger = Color3.fromRGB(244, 67, 54),
        Success = Color3.fromRGB(102, 187, 106)
    },
    Cyberpunk = {
        Background = Color3.fromRGB(20, 20, 40),
        Primary = Color3.fromRGB(0, 255, 255),
        Secondary = Color3.fromRGB(255, 0, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(80, 0, 80),
        Subtitle = Color3.fromRGB(200, 200, 255),
        Warning = Color3.fromRGB(255, 215, 0),
        Danger = Color3.fromRGB(255, 50, 50),
        Success = Color3.fromRGB(0, 255, 150)
    }
}

DeltaUILib.CurrentTheme = "Dark"

function DeltaUILib:CreateElement(elementType, properties)
    local element = Instance.new(elementType)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            element[property] = value
        end
    end
    if properties.Parent then
        element.Parent = properties.Parent
    end
    return element
end

function DeltaUILib:ApplyCorner(element, radius)
    local corner = self:CreateElement("UICorner", {
        CornerRadius = UDim.new(radius or 0.2, 0),
        Parent = element
    })
    return corner
end

function DeltaUILib:ApplyPadding(element, padding)
    local padding = self:CreateElement("UIPadding", {
        PaddingLeft = UDim.new(0, padding or 10),
        PaddingRight = UDim.new(0, padding or 10),
        PaddingTop = UDim.new(0, padding or 10),
        PaddingBottom = UDim.new(0, padding or 10),
        Parent = element
    })
    return padding
end

function DeltaUILib:ApplyListLayout(parent, padding)
    local layout = self:CreateElement("UIListLayout", {
        Parent = parent,
        Padding = UDim.new(0, padding or 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    return layout
end

function DeltaUILib:CreateRainbowBorder(parent)
    local rainbowColors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(238, 130, 238)
    }
    
    local borderContainer = self:CreateElement("Frame", {
        Name = "RainbowBorder",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local borderParts = {}
    
    for i = 1, 4 do
        local borderPart = self:CreateElement("Frame", {
            Name = "BorderPart"..i,
            BackgroundColor3 = rainbowColors[1],
            BorderSizePixel = 0,
            Parent = borderContainer
        })
        table.insert(borderParts, borderPart)
    end
    
    borderParts[1].Size = UDim2.new(1, 0, 0, 4)
    borderParts[1].Position = UDim2.new(0, 0, 0, 0)
    borderParts[2].Size = UDim2.new(0, 4, 1, 0)
    borderParts[2].Position = UDim2.new(1, -4, 0, 0)
    borderParts[3].Size = UDim2.new(1, 0, 0, 4)
    borderParts[3].Position = UDim2.new(0, 0, 1, -4)
    borderParts[4].Size = UDim2.new(0, 4, 1, 0)
    borderParts[4].Position = UDim2.new(0, 0, 0, 0)
    
    local colorIndex = 1
    local rainbowSpeed = 0.5
    
    game:GetService("RunService").Heartbeat:Connect(function(dt)
        colorIndex = (colorIndex + rainbowSpeed * dt) % #rainbowColors
        local startIndex = math.floor(colorIndex)
        local endIndex = (startIndex % #rainbowColors) + 1
        local lerp = colorIndex - startIndex
        
        for i, part in ipairs(borderParts) do
            local colorIndex = (startIndex + i - 1) % #rainbowColors + 1
            local nextColorIndex = (colorIndex % #rainbowColors) + 1
            part.BackgroundColor3 = rainbowColors[colorIndex]:Lerp(rainbowColors[nextColorIndex], lerp)
        end
    end)
    
    return borderContainer
end

function DeltaUILib:CreateDraggableWindow(title, subtitle)
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local window = self:CreateElement("Frame", {
        Name = "DeltaUIWindow",
        Size = UDim2.new(0.8, 0, 0.7, 0),
        Position = UDim2.new(0.1, 0, 0.15, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Background,
        Parent = playerGui
    })
    self:ApplyCorner(window, 0.1)
    self:CreateRainbowBorder(window)
    
    local titleBar = self:CreateElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0.1, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Primary,
        Parent = window
    })
    self:ApplyCorner(titleBar, 0.1)
    
    local titleLabel = self:CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0.8, 0, 0.6, 0),
        Position = UDim2.new(0.1, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "Delta UI",
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Parent = titleBar
    })
    
    local subtitleLabel = self:CreateElement("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0.8, 0, 0.4, 0),
        Position = UDim2.new(0.1, 0, 0.6, 0),
        BackgroundTransparency = 1,
        Text = subtitle or "Delta 注入器专用界面",
        TextColor3 = self.Themes[self.CurrentTheme].Subtitle,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Parent = titleBar
    })
    
    local closeButton = self:CreateElement("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0.1, 0, 1, 0),
        Position = UDim2.new(0.9, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "X",
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Parent = titleBar
    })
    
    local contentFrame = self:CreateElement("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0.9, 0),
        Position = UDim2.new(0, 0, 0.1, 0),
        BackgroundTransparency = 1,
        Parent = window
    })
    self:ApplyPadding(contentFrame, 15)
    self:ApplyListLayout(contentFrame, 15)
    
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        window:Destroy()
    end)
    
    if UserInputService.TouchEnabled then
        titleBar.Size = UDim2.new(1, 0, 0.15, 0)
        titleLabel.TextSize = 24
        subtitleLabel.TextSize = 18
        closeButton.TextSize = 24
    end
    
    return {
        Window = window,
        Content = contentFrame,
        Close = function() window:Destroy() end,
        SetTitle = function(newTitle) titleLabel.Text = newTitle end,
        SetSubtitle = function(newSubtitle) subtitleLabel.Text = newSubtitle end
    }
end

function DeltaUILib:CreateButton(parent, text, onClick, buttonType)
    local buttonType = buttonType or "primary"
    local buttonColors = {
        primary = self.Themes[self.CurrentTheme].Primary,
        secondary = self.Themes[self.CurrentTheme].Secondary,
        warning = self.Themes[self.CurrentTheme].Warning,
        danger = self.Themes[self.CurrentTheme].Danger,
        success = self.Themes[self.CurrentTheme].Success
    }
    
    local button = self:CreateElement("TextButton", {
        Name = "DeltaButton",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = buttonColors[buttonType] or buttonColors.primary,
        Text = text or "Button",
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        AutoButtonColor = false,
        Parent = parent
    })
    self:ApplyCorner(button, 0.15)
    
    local hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = button.BackgroundColor3:lerp(Color3.new(1,1,1), 0.2)})
    local normalTween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = buttonColors[buttonType] or buttonColors.primary})
    
    button.MouseEnter:Connect(function() hoverTween:Play() end)
    button.MouseLeave:Connect(function() normalTween:Play() end)
    button.MouseButton1Down:Connect(function() button.BackgroundColor3 = button.BackgroundColor3:lerp(Color3.new(0,0,0), 0.2) end)
    button.MouseButton1Up:Connect(function() hoverTween:Play() onClick() end)
    button.TouchTap:Connect(function() onClick() end)
    
    return button
end

function DeltaUILib:CreateToggle(parent, text, initialState, onChange)
    local toggleState = initialState or false
    local toggleFrame = self:CreateElement("Frame", {
        Name = "ToggleContainer",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local label = self:CreateElement("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text or "Toggle",
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame
    })
    
    local toggleBackground = self:CreateElement("Frame", {
        Name = "ToggleBackground",
        Size = UDim2.new(0.2, 0, 0.6, 0),
        Position = UDim2.new(0.75, 0, 0.2, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Border,
        Parent = toggleFrame
    })
    self:ApplyCorner(toggleBackground, 1)
    
    local toggleHandle = self:CreateElement("Frame", {
        Name = "ToggleHandle",
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = toggleState and self.Themes[self.CurrentTheme].Secondary or Color3.fromRGB(200, 200, 200),
        Parent = toggleBackground
    })
    self:ApplyCorner(toggleHandle, 1)
    toggleHandle.Position = toggleState and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
    
    local function toggle()
        toggleState = not toggleState
        local tween = TweenService:Create(toggleHandle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = toggleState and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = toggleState and self.Themes[self.CurrentTheme].Secondary or Color3.fromRGB(200, 200, 200)
        })
        tween:Play()
        if onChange then onChange(toggleState) end
    end
    
    toggleBackground.MouseButton1Click:Connect(toggle)
    toggleBackground.TouchTap:Connect(toggle)
    
    return {
        Frame = toggleFrame,
        SetState = function(state)
            toggleState = state
            toggleHandle.Position = toggleState and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
            toggleHandle.BackgroundColor3 = toggleState and self.Themes[self.CurrentTheme].Secondary or Color3.fromRGB(200, 200, 200)
        end,
        GetState = function() return toggleState end
    }
end

function DeltaUILib:CreateSlider(parent, text, min, max, initialValue, onChange)
    local value = initialValue or min
    local sliderFrame = self:CreateElement("Frame", {
        Name = "SliderContainer",
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local label = self:CreateElement("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text or "Slider",
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sliderFrame
    })
    
    local valueLabel = self:CreateElement("TextLabel", {
        Name = "Value",
        Size = UDim2.new(0.2, 0, 0, 20),
        Position = UDim2.new(0.8, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = sliderFrame
    })
    
    local sliderBackground = self:CreateElement("Frame", {
        Name = "SliderBackground",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Border,
        Parent = sliderFrame
    })
    self:ApplyCorner(sliderBackground, 1)
    
    local sliderFill = self:CreateElement("Frame", {
        Name = "SliderFill",
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Primary,
        Parent = sliderBackground
    })
    self:ApplyCorner(sliderFill, 1)
    
    local sliderHandle = self:CreateElement("Frame", {
        Name = "SliderHandle",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new((value - min) / (max - min), -10, 0.5, -10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Secondary,
        Parent = sliderFrame
    })
    self:ApplyCorner(sliderHandle, 1)
    
    local function updateSlider(newValue)
        value = math.clamp(newValue, min, max)
        valueLabel.Text = tostring(math.floor(value))
        local ratio = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        sliderHandle.Position = UDim2.new(ratio, -10, 0.5, -10)
        if onChange then onChange(value) end
    end
    
    local dragging = false
    
    local function updateFromInput(input)
        local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
        local newValue = min + (max - min) * math.clamp(relativeX, 0, 1)
        updateSlider(newValue)
    end
    
    sliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                         input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return {
        Frame = sliderFrame,
        SetValue = updateSlider,
        GetValue = function() return value end
    }
end

function DeltaUILib:CreateInput(parent, placeholder, onChange)
    local inputFrame = self:CreateElement("Frame", {
        Name = "InputContainer",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Background,
        Parent = parent
    })
    self:ApplyCorner(inputFrame, 0.1)
    self:ApplyPadding(inputFrame, 10)
    
    local textBox = self:CreateElement("TextBox", {
        Name = "InputField",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        PlaceholderText = placeholder or "输入内容...",
        PlaceholderColor3 = self.Themes[self.CurrentTheme].Subtitle,
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inputFrame
    })
    
    if onChange then
        textBox.FocusLost:Connect(function() onChange(textBox.Text) end)
    end
    
    return {
        Frame = inputFrame,
        GetText = function() return textBox.Text end,
        SetText = function(text) textBox.Text = text end
    }
end

function DeltaUILib:CreateDropdown(parent, text, options, onChange)
    local dropdownFrame = self:CreateElement("Frame", {
        Name = "DropdownContainer",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local label = self:CreateElement("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text or "选择选项",
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownFrame
    })
    
    local dropdownButton = self:CreateElement("TextButton", {
        Name = "DropdownButton",
        Size = UDim2.new(0.25, 0, 0.7, 0),
        Position = UDim2.new(0.75, 0, 0.15, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Primary,
        Text = "选择",
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Parent = dropdownFrame
    })
    self:ApplyCorner(dropdownButton, 0.1)
    
    local dropdownMenu = self:CreateElement("Frame", {
        Name = "DropdownMenu",
        Size = UDim2.new(0.25, 0, 0, 0),
        Position = UDim2.new(0.75, 0, 0.85, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Background,
        Visible = false,
        Parent = dropdownFrame
    })
    self:ApplyCorner(dropdownMenu, 0.1)
    self:ApplyPadding(dropdownMenu, 5)
    self:ApplyListLayout(dropdownMenu, 5)
    
    local function createOptions()
        for _, option in ipairs(options) do
            local optionButton = self:CreateElement("TextButton", {
                Name = "Option_"..option,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = self.Themes[self.CurrentTheme].Border,
                Text = option,
                TextColor3 = self.Themes[self.CurrentTheme].Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Parent = dropdownMenu
            })
            self:ApplyCorner(optionButton, 0.1)
            
            optionButton.MouseButton1Click:Connect(function()
                dropdownButton.Text = option
                dropdownMenu.Visible = false
                if onChange then onChange(option) end
            end)
        end
    end
    
    createOptions()
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownMenu.Visible = not dropdownMenu.Visible
        dropdownMenu.Size = UDim2.new(0.25, 0, 0, #options * 35)
    end)
    
    return {
        Frame = dropdownFrame,
        SetOptions = function(newOptions)
            options = newOptions
            for _, child in ipairs(dropdownMenu:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            createOptions()
        end,
        GetSelected = function() return dropdownButton.Text end,
        SetSelected = function(option)
            if table.find(options, option) then dropdownButton.Text = option end
        end
    }
end

function DeltaUILib:CreateProgressBar(parent, text, min, max, initialValue)
    local value = initialValue or min
    local progressFrame = self:CreateElement("Frame", {
        Name = "ProgressContainer",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local label = self:CreateElement("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text or "进度",
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = progressFrame
    })
    
    local valueLabel = self:CreateElement("TextLabel", {
        Name = "Value",
        Size = UDim2.new(0.2, 0, 0, 20),
        Position = UDim2.new(0.8, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(value).."/"..tostring(max),
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = progressFrame
    })
    
    local barBackground = self:CreateElement("Frame", {
        Name = "BarBackground",
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Border,
        Parent = progressFrame
    })
    self:ApplyCorner(barBackground, 1)
    
    local barFill = self:CreateElement("Frame", {
        Name = "BarFill",
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Primary,
        Parent = barBackground
    })
    self:ApplyCorner(barFill, 1)
    
    local function updateProgress(newValue)
        value = math.clamp(newValue, min, max)
        valueLabel.Text = tostring(value).."/"..tostring(max)
        local ratio = (value - min) / (max - min)
        barFill.Size = UDim2.new(ratio, 0, 1, 0)
    end
    
    return {
        Frame = progressFrame,
        SetValue = updateProgress,
        GetValue = function() return value end
    }
end

function DeltaUILib:CreateTabContainer(parent, tabs)
    local tabContainer = self:CreateElement("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local tabBar = self:CreateElement("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = tabContainer
    })
    
    local contentFrame = self:CreateElement("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = tabContainer
    })
    
    local tabButtons = {}
    local tabContents = {}
    local currentTab = 1
    
    for i, tab in ipairs(tabs) do
        local tabButton = self:CreateElement("TextButton", {
            Name = "TabButton_"..tab.name,
            Size = UDim2.new(1/#tabs, 0, 1, 0),
            Position = UDim2.new((i-1)/#tabs, 0, 0, 0),
            BackgroundColor3 = i == 1 and self.Themes[self.CurrentTheme].Primary or self.Themes[self.CurrentTheme].Border,
            Text = tab.name,
            TextColor3 = self.Themes[self.CurrentTheme].Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 16,
            Parent = tabBar
        })
        self:ApplyCorner(tabButton, 0.1)
        
        if tab.icon then
            local icon = self:CreateElement("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0.1, 0, 0.5, -10),
                BackgroundTransparency = 1,
                Image = tab.icon,
                Parent = tabButton
            })
        end
        
        local tabContent = self:CreateElement("Frame", {
            Name = "TabContent_"..tab.name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = i == 1,
            Parent = contentFrame
        })
        
        if tab.content then tab.content.Parent = tabContent end
        self:ApplyListLayout(tabContent, 15)
        
        tabButton.MouseButton1Click:Connect(function()
            if currentTab == i then return end
            for j, btn in ipairs(tabButtons) do
                btn.BackgroundColor3 = j == i and self.Themes[self.CurrentTheme].Primary or self.Themes[self.CurrentTheme].Border
            end
            for j, content in ipairs(tabContents) do
                content.Visible = j == i
            end
            currentTab = i
        end)
        
        table.insert(tabButtons, tabButton)
        table.insert(tabContents, tabContent)
    end
    
    return {
        Frame = tabContainer,
        SetActiveTab = function(index)
            if index < 1 or index > #tabs then return end
            for i, btn in ipairs(tabButtons) do
                btn.BackgroundColor3 = i == index and self.Themes[self.CurrentTheme].Primary or self.Themes[self.CurrentTheme].Border
            end
            for i, content in ipairs(tabContents) do
                content.Visible = i == index
            end
            currentTab = index
        end,
        GetActiveTab = function() return currentTab end,
        AddTab = function(name, content, icon)
            local newIndex = #tabs + 1
            for i, btn in ipairs(tabButtons) do
                btn.Size = UDim2.new(1/(newIndex), 0, 1, 0)
            end
            
            local tabButton = self:CreateElement("TextButton", {
                Name = "TabButton_"..name,
                Size = UDim2.new(1/(newIndex), 0, 1, 0),
                Position = UDim2.new((newIndex-1)/newIndex, 0, 0, 0),
                BackgroundColor3 = self.Themes[self.CurrentTheme].Border,
                Text = name,
                TextColor3 = self.Themes[self.CurrentTheme].Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 16,
                Parent = tabBar
            })
            self:ApplyCorner(tabButton, 0.1)
            
            if icon then
                local icon = self:CreateElement("ImageLabel", {
                    Name = "Icon",
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0.1, 0, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = icon,
                    Parent = tabButton
                })
            end
            
            local tabContent = self:CreateElement("Frame", {
                Name = "TabContent_"..name,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                Parent = contentFrame
            })
            
            if content then content.Parent = tabContent end
            
            tabButton.MouseButton1Click:Connect(function()
                if currentTab == newIndex then return end
                for j, btn in ipairs(tabButtons) do
                    btn.BackgroundColor3 = j == newIndex and self.Themes[self.CurrentTheme].Primary or self.Themes[self.CurrentTheme].Border
                end
                for j, content in ipairs(tabContents) do
                    content.Visible = j == newIndex
                end
                currentTab = newIndex
            end)
            
            table.insert(tabButtons, tabButton)
            table.insert(tabContents, tabContent)
            table.insert(tabs, {name = name, content = content, icon = icon})
        end,
        RemoveTab = function(index)
            if index < 1 or index > #tabs then return end
            tabButtons[index]:Destroy()
            table.remove(tabButtons, index)
            tabContents[index]:Destroy()
            table.remove(tabContents, index)
            table.remove(tabs, index)
            
            for i, btn in ipairs(tabButtons) do
                btn.Size = UDim2.new(1/#tabButtons, 0, 1, 0)
                btn.Position = UDim2.new((i-1)/#tabButtons, 0, 0, 0)
            end
            
            if currentTab == index then
                self.SetActiveTab(1)
            elseif currentTab > index then
                currentTab = currentTab - 1
            end
        end
    }
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

return DeltaUILib