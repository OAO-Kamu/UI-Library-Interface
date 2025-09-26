local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Player = game:GetService("Players").LocalPlayer

local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "AkaliNotif"
NotifGui.Parent = RunService:IsStudio() and Player.PlayerGui or game:GetService("CoreGui")

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Position = UDim2.new(0, 20, 0.5, -20)
Container.Size = UDim2.new(0, 300, 0.5, 0)
Container.BackgroundTransparency = 1
Container.Parent = NotifGui

local function CreateFrostedGlass(parent)
    local GlassFrame = Instance.new("Frame")
    GlassFrame.Size = UDim2.new(1, 0, 1, 0)
    GlassFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    GlassFrame.BackgroundTransparency = 0.2
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = GlassFrame
    
    local Noise = Instance.new("ImageLabel")
    Noise.Image = "rbxassetid://834965658"
    Noise.Size = UDim2.new(1, 0, 1, 0)
    Noise.BackgroundTransparency = 1
    Noise.ImageTransparency = 0.85
    Noise.ScaleType = Enum.ScaleType.Tile
    Noise.TileSize = UDim2.new(0, 50, 0, 50)
    Noise.Parent = GlassFrame
    
    return GlassFrame
end

local function Shadow2px()
    local NewImage = Instance.new("ImageLabel")
    NewImage.Image = "http://www.roblox.com/asset/?id=5761498316"
    NewImage.ScaleType = Enum.ScaleType.Slice
    NewImage.SliceCenter = Rect.new(17, 17, 283, 283)
    NewImage.Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30)
    NewImage.Position = -UDim2.fromOffset(15, 15)
    NewImage.ImageColor3 = Color3.fromRGB(15, 15, 15)
    NewImage.ImageTransparency = 0.1
    NewImage.ZIndex = -1
    return NewImage
end

local Padding = 12
local DescriptionPadding = 12
local InstructionObjects = {}
local TweenTime = 0.8
local TweenStyle = Enum.EasingStyle.Quint
local TweenDirection = Enum.EasingDirection.Out

local LastTick = tick()

local function Update()
    local DeltaTime = tick() - LastTick
    
    for i, ObjectData in ipairs(InstructionObjects) do
        local MainFrame, Delta, Done = ObjectData[1], ObjectData[2], ObjectData[3]
        
        if not Done then
            if Delta < TweenTime then
                ObjectData[2] = math.clamp(Delta + DeltaTime, 0, TweenTime)
                Delta = ObjectData[2]
            else
                ObjectData[3] = true
            end
        end
        
        local NewValue = TweenService:GetValue(Delta / TweenTime, TweenStyle, TweenDirection)
        local CurrentPos = MainFrame.Position
        
        local TotalHeight = 0
        for j = 1, i - 1 do
            local previousFrame = InstructionObjects[j][1]
            if previousFrame and previousFrame.Parent then
                TotalHeight += previousFrame.AbsoluteSize.Y + Padding
            end
        end
        
        local TargetPos = UDim2.new(0, 0, 0, TotalHeight)
        MainFrame.Position = CurrentPos:Lerp(TargetPos, NewValue)
    end
    
    LastTick = tick()
end

RunService:BindToRenderStep("UpdateList", 0, Update)

local TitleSettings = {
    Font = Enum.Font.GothamSemibold,
    Size = 15
}

local DescriptionSettings = {
    Font = Enum.Font.Gotham,
    Size = 13,
    LineHeight = 1.1
}

local MaxWidth = 280

local function Label(Text, Font, Size, Button)
    local Label = Instance.new(string.format("Text%s", Button and "Button" or "Label"))
    Label.Text = Text
    Label.Font = Font
    Label.TextSize = Size
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.RichText = true
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    return Label
end

local function TitleLabel(Text)
    local label = Label(Text, TitleSettings.Font, TitleSettings.Size)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    return label
end

local function DescriptionLabel(Text)
    local label = Label(Text, DescriptionSettings.Font, DescriptionSettings.Size)
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.LineHeight = DescriptionSettings.LineHeight
    return label
end

local PropertyTweenOut = {
    Text = "TextTransparency",
    Fram = "BackgroundTransparency",
    Imag = "ImageTransparency"
}

local function FadeProperty(Object)
    local Prop = PropertyTweenOut[string.sub(Object.ClassName, 1, 4)]
    TweenService:Create(Object, TweenInfo.new(0.3, TweenStyle, TweenDirection), {
        [Prop] = 1
    }):Play()
end

local function FadeOutAfter(MainFrame, Seconds)
    wait(Seconds)
    
    for _, child in ipairs(MainFrame:GetDescendants()) do
        if child:IsA("GuiObject") then
            FadeProperty(child)
        end
    end
    FadeProperty(MainFrame)
    
    wait(0.3)
    
    for i, ObjectData in ipairs(InstructionObjects) do
        if ObjectData[1] == MainFrame then
            table.remove(InstructionObjects, i)
            break
        end
    end
    
    for _, ObjectData in ipairs(InstructionObjects) do
        ObjectData[2] = 0
        ObjectData[3] = false
    end
    
    delay(0.1, function()
        if MainFrame then
            MainFrame:Destroy()
        end
    end)
end

return {
    Notify = function(Properties)
        local Properties = typeof(Properties) == "table" and Properties or {}
        local Title = Properties.Title or ""
        local Description = Properties.Description or ""
        local Duration = Properties.Duration or 5
        
        if Title == "" and Description == "" then return end
        
        local totalHeight = 0
        
        if Title ~= "" then
            totalHeight += 28
        end
        
        if Description ~= "" then
            local textSize = TextService:GetTextSize(
                Description, 
                DescriptionSettings.Size, 
                DescriptionSettings.Font, 
                Vector2.new(MaxWidth - DescriptionPadding * 2, 10000)
            )
            totalHeight += textSize.Y + 10
        end
        
        totalHeight = math.max(totalHeight, 40) + 16
        
        local MainFrame = Instance.new("Frame")
        MainFrame.BackgroundTransparency = 1
        MainFrame.Size = UDim2.new(0, 300, 0, totalHeight)
        MainFrame.Position = UDim2.new(-1, 20, 0, 0)
        MainFrame.Parent = Container
        
        local Glass = CreateFrostedGlass(MainFrame)
        Glass.Parent = MainFrame
        
        local shadow = Shadow2px()
        shadow.Parent = MainFrame
        
        local ContentFrame = Instance.new("Frame")
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.Parent = MainFrame
        
        local contentPosition = 8
        
        if Title ~= "" then
            local titleLabel = TitleLabel(Title)
            titleLabel.Size = UDim2.new(1, -16, 0, 24)
            titleLabel.Position = UDim2.new(0, 8, 0, contentPosition)
            titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            titleLabel.Parent = ContentFrame
            contentPosition += 24 + 4
        end
        
        if Description ~= "" then
            local descLabel = DescriptionLabel(Description)
            descLabel.TextWrapped = true
            descLabel.Size = UDim2.new(1, -16, 1, -contentPosition - 8)
            descLabel.Position = UDim2.new(0, 8, 0, contentPosition)
            descLabel.TextYAlignment = Title ~= "" and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
            descLabel.Parent = ContentFrame
        end
        
        table.insert(InstructionObjects, {MainFrame, 0, false})
        
        coroutine.wrap(FadeOutAfter)(MainFrame, Duration)
        
        return MainFrame
    end,
}
