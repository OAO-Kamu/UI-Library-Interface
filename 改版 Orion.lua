local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local OrionLib = {
        Elements = {},
        ThemeObjects = {},
        Connections = {},
        Flags = {},
        Themes = {
                Default = {
                        Main = Color3.fromRGB(0, 0, 0),--黑色主要区域
                        Second = Color3.fromRGB(0, 0, 0),--红色选项栏和功能
                        Stroke = Color3.fromRGB(192, 192, 192),--绿色周围边框
                        Divider = Color3.fromRGB(255, 255, 255),--玩家蓝色圈圈颜色
                        Text = Color3.fromRGB(255, 255, 255),--字颜色
                        TextDark = Color3.fromRGB(0, 255, 0)--不知道
                }
        },
        SelectedTheme = "Default",
        Folder = nil,
        SaveCfg = false
}

--Feather Icons https://github.com/evoincorp/lucideblox/tree/master/src/modules/util - Created by 7kayoh
local Icons = {}

local Success, Response = pcall(function()
        Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)

if not Success then
        warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. Response .. "\n")
end        

local function GetIcon(IconName)
        if Icons[IconName] ~= nil then
                return Icons[IconName]
        else
                return nil
        end
end   

local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
if syn then
        syn.protect_gui(Orion)
        Orion.Parent = game.CoreGui
else
        Orion.Parent = gethui() or game.CoreGui
end

function OrionLib:IsRunning()
        if gethui then
                return Orion.Parent == gethui()
        else
                return Orion.Parent == game:GetService("CoreGui")
        end

end

local function AddConnection(Signal, Function)
        if (not OrionLib:IsRunning()) then
                return
        end
        local SignalConnect = Signal:Connect(Function)
        table.insert(OrionLib.Connections, SignalConnect)
        return SignalConnect
end

task.spawn(function()
        while (OrionLib:IsRunning()) do
                wait()
        end

        for _, Connection in next, OrionLib.Connections do
                Connection:Disconnect()
        end
end)

-- 创建动态渐变边框函数
local function CreateAnimatedBorder(parent, thickness, animationSpeed)
    local borderContainer = Instance.new("Frame")
    borderContainer.Name = "AnimatedBorder"
    borderContainer.BackgroundTransparency = 1
    borderContainer.Size = UDim2.new(1, 0, 1, 0)
    borderContainer.Position = UDim2.new(0, 0, 0, 0)
    borderContainer.ZIndex = 0
    borderContainer.Parent = parent
    
    -- 创建四个边的边框
    local borders = {}
    
    -- 上边框
    borders.top = Instance.new("Frame")
    borders.top.Name = "TopBorder"
    borders.top.Size = UDim2.new(1, 0, 0, thickness)
    borders.top.Position = UDim2.new(0, 0, 0, 0)
    borders.top.BackgroundTransparency = 1
    borders.top.ZIndex = 1
    borders.top.Parent = borderContainer
    
    -- 下边框
    borders.bottom = Instance.new("Frame")
    borders.bottom.Name = "BottomBorder"
    borders.bottom.Size = UDim2.new(1, 0, 0, thickness)
    borders.bottom.Position = UDim2.new(0, 0, 1, -thickness)
    borders.bottom.BackgroundTransparency = 1
    borders.bottom.ZIndex = 1
    borders.bottom.Parent = borderContainer
    
    -- 左边框
    borders.left = Instance.new("Frame")
    borders.left.Name = "LeftBorder"
    borders.left.Size = UDim2.new(0, thickness, 1, 0)
    borders.left.Position = UDim2.new(0, 0, 0, 0)
    borders.left.BackgroundTransparency = 1
    borders.left.ZIndex = 1
    borders.left.Parent = borderContainer
    
    -- 右边框
    borders.right = Instance.new("Frame")
    borders.right.Name = "RightBorder"
    borders.right.Size = UDim2.new(0, thickness, 1, 0)
    borders.right.Position = UDim2.new(1, -thickness, 0, 0)
    borders.right.BackgroundTransparency = 1
    borders.right.ZIndex = 1
    borders.right.Parent = borderContainer
    
    -- 为每个边框创建渐变和动画
    for _, border in pairs(borders) do
        -- 创建UIGradient
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 0
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 0.3)
        })
        
        -- 创建黑白颜色序列
        local colorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),  -- 白色
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(128, 128, 128)), -- 灰色
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))   -- 白色
        })
        
        gradient.Color = colorSequence
        gradient.Parent = border
        
        -- 创建圆角
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 2)
        corner.Parent = border
    end
    
    -- 动画循环
    local connection
    local animationTime = 0
    
    local function animateBorder()
        animationTime = animationTime + (1/60)
        local offset = (animationTime * animationSpeed) % 1
        
        for _, border in pairs(borders) do
            local gradient = border:FindFirstChildOfClass("UIGradient")
            if gradient then
                gradient.Offset = Vector2.new(-offset, 0)
            end
        end
    end
    
    connection = RunService.RenderStepped:Connect(animateBorder)
    
    -- 存储连接以便后续清理
    table.insert(OrionLib.Connections, connection)
    
    return borderContainer
end

local function MakeDraggable(DragPoint, Main)
        pcall(function()
                local Dragging, DragInput, MousePos, FramePos = false
                AddConnection(DragPoint.InputBegan, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                Dragging = true
                                MousePos = Input.Position
                                FramePos = Main.Position

                                Input.Changed:Connect(function()
                                        if Input.UserInputState == Enum.UserInputState.End then
                                                Dragging = false
                                        end
                                end)
                        end
                end)
                AddConnection(DragPoint.InputChanged, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                                DragInput = Input
                        end
                end)
                AddConnection(UserInputService.InputChanged, function(Input)
                        if Input == DragInput and Dragging then
                                local Delta = Input.Position - MousePos
                                TweenService:Create(Main, TweenInfo.new(0.05, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
                                Main.Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
                        end
                end)
        end)
end    

local function Create(Name, Properties, Children)
        local Object = Instance.new(Name)
        for i, v in next, Properties or {} do
                Object[i] = v
        end
        for i, v in next, Children or {} do
                v.Parent = Object
        end
        return Object
end

local function CreateElement(ElementName, ElementFunction)
        OrionLib.Elements[ElementName] = function(...)
                return ElementFunction(...)
        end
end

local function MakeElement(ElementName, ...)
        local NewElement = OrionLib.Elements[ElementName](...)
        return NewElement
end

local function SetProps(Element, Props)
        table.foreach(Props, function(Property, Value)
                Element[Property] = Value
        end)
        return Element
end

local function SetChildren(Element, Children)
        table.foreach(Children, function(_, Child)
                Child.Parent = Element
        end)
        return Element
end

local function Round(Number, Factor)
        local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
        if Result < 0 then Result = Result + Factor end
        return Result
end

local function ReturnProperty(Object)
        if Object:IsA("Frame") or Object:IsA("TextButton") then
                return "BackgroundColor3"
        end 
        if Object:IsA("ScrollingFrame") then
                return "ScrollBarImageColor3"
        end 
        if Object:IsA("UIStroke") then
                return "Color"
        end 
        if Object:IsA("TextLabel") or Object:IsA("TextBox") then
                return "TextColor3"
        end   
        if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
                return "ImageColor3"
        end   
end

local function AddThemeObject(Object, Type)
        if not OrionLib.ThemeObjects[Type] then
                OrionLib.ThemeObjects[Type] = {}
        end    
        table.insert(OrionLib.ThemeObjects[Type], Object)
        Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
        return Object
end    

local function SetTheme()
        for Name, Type in pairs(OrionLib.ThemeObjects) do
                for _, Object in pairs(Type) do
                        Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Name]
                end    
        end    
end

local function PackColor(Color)
        return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
        return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
        local Data = HttpService:JSONDecode(Config)
        table.foreach(Data, function(a,b)
                if OrionLib.Flags[a] then
                        spawn(function() 
                                if OrionLib.Flags[a].Type == "Colorpicker" then
                                        OrionLib.Flags[a]:Set(UnpackColor(b))
                                else
                                        OrionLib.Flags[a]:Set(b)
                                end    
                        end)
                else
                        warn("Orion Library Config Loader - Could not find ", a ,b)
                end
        end)
end

local function SaveCfg(Name)
        local Data = {}
        for i,v in pairs(OrionLib.Flags) do
                if v.Save then
                        if v.Type == "Colorpicker" then
                                Data[i] = PackColor(v.Value)
                        else
                                Data[i] = v.Value
                        end
                end        
        end
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3,Enum.UserInputType.Touch}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
        for _, v in next, Table do
                if v == Key then
                        return true
                end
        end
end

CreateElement("Corner", function(Scale, Offset)
        local Corner = Create("UICorner", {
                CornerRadius = UDim.new(Scale or 0, Offset or 6) -- 减小圆角
        })
        return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
        local Stroke = Create("UIStroke", {
                Color = Color or Color3.fromRGB(255, 255, 255),
                Thickness = Thickness or 1
        })
        return Stroke
end)

CreateElement("List", function(Scale, Offset)
        local List = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(Scale or 0, Offset or 2) -- 减小间距
        })
        return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
        local Padding = Create("UIPadding", {
                PaddingBottom = UDim.new(0, Bottom or 3), -- 减小内边距
                PaddingLeft = UDim.new(0, Left or 3),
                PaddingRight = UDim.new(0, Right or 3),
                PaddingTop = UDim.new(0, Top or 3)
        })
        return Padding
end)

CreateElement("TFrame", function()
        local TFrame = Create("Frame", {
                BackgroundTransparency = 1
        })
        return TFrame
end)

CreateElement("Frame", function(Color)
        local Frame = Create("Frame", {
                BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0
        })
        return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
        local Frame = Create("Frame", {
                BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0
        }, {
                Create("UICorner", {
                        CornerRadius = UDim.new(Scale, Offset)
                })
        })
        return Frame
end)

CreateElement("Button", function()
        local Button = Create("TextButton", {
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                BorderSizePixel = 0
        })
        return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
        local ScrollFrame = Create("ScrollingFrame", {
                BackgroundTransparency = 1,
                MidImage = "rbxassetid://7445543667",
                BottomImage = "rbxassetid://7445543667",
                TopImage = "rbxassetid://7445543667",
                ScrollBarImageColor3 = Color,
                BorderSizePixel = 0,
                ScrollBarThickness = Width,
                CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        return ScrollFrame
end)

CreateElement("Image", function(ImageID)
        local ImageNew = Create("ImageLabel", {
                Image = ImageID,
                BackgroundTransparency = 1
        })

        if GetIcon(ImageID) ~= nil then
                ImageNew.Image = GetIcon(ImageID)
        end        

        return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
        local Image = Create("ImageButton", {
                Image = ImageID,
                BackgroundTransparency = 1
        })
        return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
        local Label = Create("TextLabel", {
                Text = Text or "",
                TextColor3 = Color3.fromRGB(240, 240, 240),
                TextTransparency = Transparency or 0,
                TextSize = TextSize or 13, -- 减小字体大小
                Font = Enum.Font.FredokaOne,
                RichText = true,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left
        })
        return Label
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
        SetProps(MakeElement("List"), {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 3) -- 减小通知间距
        })
}), {
        Position = UDim2.new(1, -20, 1, -20), -- 调整位置
        Size = UDim2.new(0, 250, 1, -20), -- 减小通知宽度
        AnchorPoint = Vector2.new(1, 1),
        Parent = Orion
})

function OrionLib:MakeNotification(NotificationConfig)
        spawn(function()
                NotificationConfig.Name = NotificationConfig.Name or "Notification"
                NotificationConfig.Content = NotificationConfig.Content or "Test"
                NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
                NotificationConfig.Time = NotificationConfig.Time or 15

                local NotificationParent = SetProps(MakeElement("TFrame"), {
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = NotificationHolder
                })

                local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 8), { -- 减小圆角
                        Parent = NotificationParent, 
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(1, -45, 0, 0), -- 调整位置
                        BackgroundTransparency = 0.4,
                        AutomaticSize = Enum.AutomaticSize.Y
                }), {
                        MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
                        MakeElement("Padding", 8, 8, 8, 8), -- 减小内边距
                        SetProps(MakeElement("Image", NotificationConfig.Image), {
                                Size = UDim2.new(0, 16, 0, 16), -- 减小图标大小
                                ImageColor3 = Color3.fromRGB(240, 240, 240),
                                Name = "Icon"
                        }),
                        SetProps(MakeElement("Label", NotificationConfig.Name, 13), { -- 减小字体
                                Size = UDim2.new(1, -26, 0, 16), -- 调整大小
                                Position = UDim2.new(0, 26, 0, 0),
                                Font = Enum.Font.FredokaOne,
                                Name = "Title"
                        }),
                        SetProps(MakeElement("Label", NotificationConfig.Content, 12), { -- 减小字体
                                Size = UDim2.new(1, 0, 0, 0),
                                Position = UDim2.new(0, 0, 0, 20), -- 调整位置
                                Font = Enum.Font.FredokaOne,
                                Name = "Content",
                                AutomaticSize = Enum.AutomaticSize.Y,
                                TextColor3 = Color3.fromRGB(200, 200, 200),
                                TextWrapped = true
                        })
                })
                TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
                wait(NotificationConfig.Time - 0.88)
                TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 0.6}):Play()
                TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.4}):Play()
                wait(0.3)
                TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
                TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.2}):Play()
                TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.2}):Play()
                wait(0.05)
                NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0),'In','Quint',0.8,true)
                wait(1.35)
                NotificationFrame:Destroy()
        end)
end    

function OrionLib:Init()
        if OrionLib.SaveCfg then        
                pcall(function()
                        if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
                                LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
                                OrionLib:MakeNotification({
                                        Name = "配置",
                                        Content = "游戏的自动加载配置 " .. game.GameId .. ".",
                                        Time = 5
                                })
                        end
                end)                
        end        
end        

function OrionLib:MakeWindow(WindowConfig)
        local FirstTab = true
        local Minimized = false
        local Loaded = false
        local UIHidden = false

        WindowConfig = WindowConfig or {}
        WindowConfig.Name = WindowConfig.Name or "Orion Library"
        WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
        WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
        WindowConfig.HidePremium = WindowConfig.HidePremium or false
        if WindowConfig.IntroEnabled == nil then
                WindowConfig.IntroEnabled = true
        end
        WindowConfig.IntroToggleIcon = WindowConfig.IntroToggleIcon or "rbxassetid://4483345998"
        WindowConfig.IntroText = WindowConfig.IntroText or "缝合脚本中心 [V.1.6]"
        WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
        WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
        WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://4483345998"
        WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://4483345998"
        OrionLib.Folder = WindowConfig.ConfigFolder
        OrionLib.SaveCfg = WindowConfig.SaveConfig

        if WindowConfig.SaveConfig then
                if not isfolder(WindowConfig.ConfigFolder) then
                        makefolder(WindowConfig.ConfigFolder)
                end        
        end

        local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 3), { -- 减小滚动条宽度
                Size = UDim2.new(1, 0, 1, -40) -- 调整高度
        }), {
                MakeElement("List"),
                MakeElement("Padding", 6, 0, 0, 6) -- 减小内边距
        }), "Divider")

        AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 12) -- 调整画布大小
        end)

        local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0.5, 0, 0, 0),
                BackgroundTransparency = 1
        }), {
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://96669691935808"), {
                        Position = UDim2.new(0, 7, 0, 5), -- 调整位置
                        Size = UDim2.new(0, 14, 0, 14) -- 减小图标大小
                }), "Text")
        })

        local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
                Size = UDim2.new(0.5, 0, 1, 0),
                BackgroundTransparency = 1
        }), {
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://89547331668158"), {
                        Position = UDim2.new(0, 7, 0, 5), -- 调整位置
                        Size = UDim2.new(0, 14, 0, 14), -- 减小图标大小
                        Name = "Ico"
                }), "Text")
        })

        local DragPoint = SetProps(MakeElement("TFrame"), {
                Size = UDim2.new(1, 0, 0, 40) -- 减小拖动区域高度
        })

        local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), { -- 减小圆角
                Size = UDim2.new(0, 120, 1, -40), -- 减小宽度和调整高度
                Position = UDim2.new(0, 0, 0, 40) -- 调整位置
        }), {
                AddThemeObject(SetProps(MakeElement("Frame"), {
                        Size = UDim2.new(1, 0, 0, 8), -- 减小高度
                        Position = UDim2.new(0, 0, 0, 0)
                }), "Second"), 
                AddThemeObject(SetProps(MakeElement("Frame"), {
                        Size = UDim2.new(0, 8, 1, 0), -- 减小宽度
                        Position = UDim2.new(1, -8, 0, 0) -- 调整位置
                }), "Second"), 
                AddThemeObject(SetProps(MakeElement("Frame"), {
                        Size = UDim2.new(0, 1, 1, 0),
                        Position = UDim2.new(1, -1, 0, 0)
                }), "Stroke"), 
                TabHolder,
                SetChildren(SetProps(MakeElement("TFrame"), {
                        Size = UDim2.new(1, 0, 0, 40), -- 减小高度
                        Position = UDim2.new(0, 0, 1, -40) -- 调整位置
                }), {
                        AddThemeObject(SetProps(MakeElement("Frame"), {
                                Size = UDim2.new(1, 0, 0, 1)
                        }), "Stroke"), 
                        AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
                                AnchorPoint = Vector2.new(0, 0.5),
                                Size = UDim2.new(0, 28, 0, 28), -- 减小头像大小
                                Position = UDim2.new(0, 8, 0.5, 0) -- 调整位置
                        }), {
                                SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"), {
                                        Size = UDim2.new(1, 0, 1, 0)
                                }),
                                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
                                        Size = UDim2.new(1, 0, 1, 0),
                                }), "Second"),
                                MakeElement("Corner", 1)
                        }), "Divider"),
                        SetChildren(SetProps(MakeElement("TFrame"), {
                                AnchorPoint = Vector2.new(0, 0.5),
                                Size = UDim2.new(0, 28, 0, 28), -- 减小边框大小
                                Position = UDim2.new(0, 8, 0.5, 0) -- 调整位置
                        }), {
                                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                MakeElement("Corner", 1)
                        }),
                        AddThemeObject(SetProps(MakeElement("Label", ""..game.Players.LocalPlayer.DisplayName.."", WindowConfig.HidePremium and 12 or 11), { -- 减小字体
                                Size = UDim2.new(1, -50, 0, 11), -- 调整大小
                                Position = WindowConfig.HidePremium and UDim2.new(0, 45, 0, 15) or UDim2.new(0, 45, 0, 10), -- 调整位置
                                Font = Enum.Font.FredokaOne,
                                ClipsDescendants = true
                        }), "Text"),
                        AddThemeObject(SetProps(MakeElement("Label", os.date("%Y/%m/%d", os.time()), 12), {
                            Size = UDim2.new(1, -60, 0, 12),
                            Position = UDim2.new(0, 50, 1, -25),
                            Visible = not WindowConfig.HidePremium
                        }), "TextDark")
                }),
        }), "Second")

        local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 12), { -- 减小字体
                Size = UDim2.new(1, -25, 2, 0), -- 调整大小
                    Position = UDim2.new(0, 20, 0, -19), -- 调整位置
                Font = Enum.Font.FredokaOne,
                TextSize = 16 -- 减小标题字体
        }), "Text")

        local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1)
        }), "Stroke")

        -- 创建主窗口容器，用于容纳动态边框
        local MainWindowContainer = Create("Frame", {
            Parent = Orion,
            Position = UDim2.new(0.5, -250, 0.5, -140),
            Size = UDim2.new(0, 500, 0, 280),
            BackgroundTransparency = 1,
            ClipsDescendants = true
        })

        -- 添加动态渐变边框到主窗口容器
        CreateAnimatedBorder(MainWindowContainer, 3, 2) -- 边框厚度3，动画速度2

        local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), { -- 减小圆角
                Parent = MainWindowContainer,
                Size = UDim2.new(1, -6, 1, -6), -- 为边框留出空间
                Position = UDim2.new(0, 3, 0, 3), -- 居中显示
                ClipsDescendants = true
        }), {
                SetChildren(SetProps(MakeElement("TFrame"), {
                        Size = UDim2.new(1, 0, 0, 40), -- 减小顶部栏高度
                        Name = "TopBar"
                }), {
                        WindowName,
                        WindowTopBarLine,
                        AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), { -- 减小圆角
                                Size = UDim2.new(0, 60, 0, 25), -- 减小按钮区域大小
                                Position = UDim2.new(1, -70, 0, 8) -- 调整位置
                        }), {
                                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                AddThemeObject(SetProps(MakeElement("Frame"), {
                                        Size = UDim2.new(0, 1, 1, 0),
                                        Position = UDim2.new(0.5, 0, 0, 0)
                                }), "Stroke"), 
                                CloseBtn,
                                MinimizeBtn
                        }), "Second"), 
                }),
                DragPoint,
                WindowStuff
        }), "Main")

        -- 更新拖动功能以拖动整个容器
        MakeDraggable(DragPoint, MainWindowContainer)

        if WindowConfig.ShowIcon then
                WindowName.Position = UDim2.new(0, 40, 0, -19) -- 调整位置
                local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
                        Size = UDim2.new(0, 16, 0, 16), -- 减小图标大小
                        Position = UDim2.new(0, 20, 0, 12) -- 调整位置
                })
                WindowIcon.Parent = MainWindow.TopBar
        end        

    local MobileReopenButton = SetChildren(SetProps(MakeElement("Button"), {
                Parent = Orion,
                Size = UDim2.new(0, 32, 0, 32), -- 减小按钮大小
                Position = UDim2.new(0.5, -16, 0, 16), -- 调整位置
                BackgroundTransparency = 0,
                BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main,
                Visible = false
        }), {
                AddThemeObject(SetProps(MakeElement("Image", WindowConfig.IntroToggleIcon or "http://www.roblox.com/asset/?id=121203363140066"), {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0.6, 0, 0.6, 0), -- 减小图标大小
                }), "Text"),
                MakeElement("Corner", 1)
        })

        AddConnection(CloseBtn.MouseButton1Up, function() --关闭 UI
                MainWindowContainer.Visible = false
                MobileReopenButton.Visible = true
                UIHidden = true
                WindowConfig.CloseCallback()
        end)

        AddConnection(UserInputService.InputBegan, function(Input)
                if Input.KeyCode == Enum.KeyCode.LeftControl and UIHidden == true then
                        MainWindowContainer.Visible = true
                        MobileReopenButton.Visible = false
                end
        end)

        AddConnection(MobileReopenButton.Activated, function()
                MainWindowContainer.Visible = true
                MobileReopenButton.Visible = false
        end)

        AddConnection(MinimizeBtn.MouseButton1Up, function()
                if Minimized then
                        TweenService:Create(MainWindowContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 280)}):Play() -- 调整大小
                        MinimizeBtn.Ico.Image = "rbxassetid://89547331668158"
                        wait(.02)
                        MainWindow.ClipsDescendants = false
                        WindowStuff.Visible = true
                        WindowTopBarLine.Visible = true
                else
                        MainWindow.ClipsDescendants = true
                        WindowTopBarLine.Visible = false
                        MinimizeBtn.Ico.Image = "rbxassetid://77359780859993"

                        TweenService:Create(MainWindowContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 120, 0, 40)}):Play() -- 调整大小
                        wait(0.1)
                        WindowStuff.Visible = false        
                end
                Minimized = not Minimized    
        end)

        local function LoadSequence()
                MainWindowContainer.Visible = false
                local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
                        Parent = Orion,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.4, 0),
                        Size = UDim2.new(0, 24, 0, 24), -- 减小Logo大小
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        ImageTransparency = 1
                })

                local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 12), { -- 减小字体
                        Parent = Orion,
                        Size = UDim2.new(1, 0, 1, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 15, 0.5, 0), -- 调整位置
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Font = Enum.Font.FredokaOne,
                        TextTransparency = 1
                })

                TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
                wait(0.8)
                TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
                wait(0.3)
                TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
                wait(2)
                TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
                MainWindowContainer.Visible = true
                LoadSequenceLogo:Destroy()
                LoadSequenceText:Destroy()
        end 

        if WindowConfig.IntroEnabled then
                LoadSequence()
        end        

        local TabFunction = {}
        function TabFunction:MakeTab(TabConfig)
                TabConfig = TabConfig or {}
                TabConfig.Name = TabConfig.Name or "Tab"
                TabConfig.Icon = TabConfig.Icon or ""
                TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

                local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
                        Size = UDim2.new(1, 0, 0, 25), -- 减小标签高度
                        Parent = TabHolder
                }), {
                        AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
                                AnchorPoint = Vector2.new(0, 0.5),
                                Size = UDim2.new(0, 14, 0, 14), -- 减小图标大小
                                Position = UDim2.new(0, 8, 0.5, 0), -- 调整位置
                                ImageTransparency = 0.4,
                                Name = "Ico"
                        }), "Text"),
                        AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 12), { -- 减小字体
                                Size = UDim2.new(1, -30, 1, 0), -- 调整大小
                                Position = UDim2.new(0, 30, 0, 0), -- 调整位置
                                Font = Enum.Font.FredokaOne,
                                TextTransparency = 0.4,
                                Name = "Title"
                        }), "Text")
                })

                if GetIcon(TabConfig.Icon) ~= nil then
                        TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
                end        

                local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), { -- 减小滚动条宽度
                        Size = UDim2.new(1, -120, 1, -40), -- 调整大小
                        Position = UDim2.new(0, 120, 0, 40), -- 调整位置
                        Parent = MainWindow,
                        Visible = false,
                        Name = "ItemContainer"
                }), {
                        MakeElement("List", 0, 4), -- 减小间距
                        MakeElement("Padding", 12, 8, 8, 12) -- 减小内边距
                }), "Divider")

                AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                        Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 24) -- 调整画布大小
                end)

                if FirstTab then
                        FirstTab = false
                        TabFrame.Ico.ImageTransparency = 0
                        TabFrame.Title.TextTransparency = 0
                        TabFrame.Title.Font = Enum.Font.FredokaOne
                        Container.Visible = true
                end    

                AddConnection(TabFrame.MouseButton1Click, function()
                        for _, Tab in next, TabHolder:GetChildren() do
                                if Tab:IsA("TextButton") then
                                        Tab.Title.Font = Enum.Font.FredokaOne
                                        TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
                                        TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
                                end    
                        end
                        for _, ItemContainer in next, MainWindow:GetChildren() do
                                if ItemContainer.Name == "ItemContainer" then
                                        ItemContainer.Visible = false
                                end    
                        end  
                        TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
                        TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
                        TabFrame.Title.Font = Enum.Font.FredokaOne
                        Container.Visible = true   
                end)

                local function GetElements(ItemParent)
                        local ElementFunction = {}
                        function ElementFunction:AddLabel(Text)
                                local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), { -- 减小圆角
                                        Size = UDim2.new(1, 0, 0, 25), -- 减小高度
                                        BackgroundTransparency = 0.7,
                                        Parent = ItemParent
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", Text, 13), { -- 减小字体
                                                Size = UDim2.new(1, -10, 1, 0), -- 调整大小
                                                Position = UDim2.new(0, 10, 0, 0), -- 调整位置
                                                Font = Enum.Font.FredokaOne,
                                                Name = "Content"
                                        }), "Text"),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke")
                                }), "Second")

                                local LabelFunction = {}
                                function LabelFunction:Set(ToChange)
                                        LabelFrame.Content.Text = ToChange
                                end
                                return LabelFunction
                        end
                        function ElementFunction:AddParagraph(Text, Content)
                                Text = Text or "Text"
                                Content = Content or "Content"

                                local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), { -- 减小圆角
                                        Size = UDim2.new(1, 0, 0, 25), -- 减小高度
                                        BackgroundTransparency = 0.7,
                                        Parent = ItemParent
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", Text, 13), { -- 减小字体
                                                Size = UDim2.new(1, -10, 0, 12), -- 调整大小
                                                Position = UDim2.new(0, 10, 0, 8), -- 调整位置
                                                Font = Enum.Font.FredokaOne,
                                                Name = "Title"
                                        }), "Text"),
                                        AddThemeObject(SetProps(MakeElement("Label", "Ez Ez Ez", 12), { -- 减小字体
                                                Size = UDim2.new(1, -20, 0, 0), -- 调整大小
                                                Position = UDim2.new(0, 10, 0, 22), -- 调整位置
                                                Font = Enum.Font.FredokaOne,
                                                Name = "Content",
                                                TextWrapped = true
                                        }), "TextDark"),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke")
                                }), "Second")

                                AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
                                        ParagraphFrame.Content.Size = UDim2.new(1, -20, 0, ParagraphFrame.Content.TextBounds.Y)
                                        ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 30) -- 调整高度
                                end)

                                ParagraphFrame.Content.Text = Content

                                local ParagraphFunction = {}
                                function ParagraphFunction:Set(ToChange)
                                        ParagraphFrame.Content.Text = ToChange
                                end
                                return ParagraphFunction
                        end    
                        function ElementFunction:AddButton(ButtonConfig)
                                ButtonConfig = ButtonConfig or {}
                                ButtonConfig.Name = ButtonConfig.Name or "Button"
                                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                                ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"

                                local Button = {}

                                local Click = SetProps(MakeElement("Button"), {
                                        Size = UDim2.new(1, 0, 1, 0)
                                })

                                local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), { -- 减小圆角
                                        Size = UDim2.new(1, 0, 0, 28), -- 减小高度
                                        Parent = ItemParent
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 13), { -- 减小字体
                                                Size = UDim2.new(1, -10, 1, 0), -- 调整大小
                                                Position = UDim2.new(0, 10, 0, 0), -- 调整位置
                                                Font = Enum.Font.FredokaOne,
                                                Name = "Content"
                                        }), "Text"),
                                        AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
                                                Size = UDim2.new(0, 16, 0, 16), -- 减小图标大小
                                                Position = UDim2.new(1, -25, 0, 6), -- 调整位置
                                        }), "TextDark"),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                        Click
                                }), "Second")

                                AddConnection(Click.MouseEnter, function()
                                        TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                                end)

                                AddConnection(Click.MouseLeave, function()
                                        TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
                                end)

                                AddConnection(Click.MouseButton1Up, function()
                                        TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                                        spawn(function()
                                                ButtonConfig.Callback()
                                        end)
                                end)

                                AddConnection(Click.MouseButton1Down, function()
                                        TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
                                end)

                                function Button:Set(ButtonText)
                                        ButtonFrame.Content.Text = ButtonText
                                end        

                                return Button
                        end    
                        function ElementFunction:AddToggle(ToggleConfig)
                                ToggleConfig = ToggleConfig or {}
                                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                                ToggleConfig.Default = ToggleConfig.Default or false
                                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                                ToggleConfig.Color = ToggleConfig.Color or Color3.fromRGB(9, 99, 195)
                                ToggleConfig.Flag = ToggleConfig.Flag or nil
                                ToggleConfig.Save = ToggleConfig.Save or false

                                local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}

                                local Click = SetProps(MakeElement("Button"), {
                                        Size = UDim2.new(1, 0, 1, 0)
                                })

                                local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 3), { -- 减小圆角
                                        Size = UDim2.new(0, 20, 0, 20), -- 减小大小
                                        Position = UDim2.new(1, -20, 0.5, 0), -- 调整位置
                                        AnchorPoint = Vector2.new(0.5, 0.5)
                                }), {
                                        SetProps(MakeElement("Stroke"), {
                                                Color = ToggleConfig.Color,
                                                Name = "Stroke",
                                                Transparency = 0.5
                                        }),
                                        SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
                                                Size = UDim2.new(0, 16, 0, 16), -- 减小图标大小
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                Position = UDim2.new(0.5, 0, 0.5, 0),
                                                ImageColor3 = Color3.fromRGB(255, 255, 255),
                                                Name = "Ico"
                                        }),
                                })

                                local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), { -- 减小圆角
                                        Size = UDim2.new(1, 0, 0, 32), -- 减小高度
                                        Parent = ItemParent
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 13), { -- 减小字体
                                                Size = UDim2.new(1, -10, 1, 0), -- 调整大小
                                                Position = UDim2.new(0, 10, 0, 0), -- 调整位置
                                                Font = Enum.Font.FredokaOne,
                                                Name = "Content"
                                        }), "Text"),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                        ToggleBox,
                                        Click
                                }), "Second")

                                function Toggle:Set(Value)
                                        Toggle.Value = Value
                                        TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Divider}):Play()
                                        TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Stroke}):Play()
                                        TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 16, 0, 16) or UDim2.new(0, 6, 0, 6)}):Play() -- 调整大小
                                end    

                                Toggle:Set(Toggle.Value)

                                AddConnection(Click.MouseEnter, function()
                                        TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                                end)

                                AddConnection(Click.MouseLeave, function()
                                        TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
                                end)

                                AddConnection(Click.MouseButton1Up, function()
                                        TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                                        SaveCfg(game.GameId)
                                        Toggle:Set(not Toggle.Value)
                                end)

                                AddConnection(Click.MouseButton1Down, function()
                                        TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
                                end)

                                if ToggleConfig.Flag then
                                        OrionLib.Flags[ToggleConfig.Flag] = Toggle
                                end        
                                return Toggle
                        end  
                        function ElementFunction:AddSlider(SliderConfig)
                                SliderConfig = SliderConfig or {}
                                SliderConfig.Name = SliderConfig.Name or "Slider"
                                SliderConfig.Min = SliderConfig.Min or 0
                                SliderConfig.Max = SliderConfig.Max or 100
                                SliderConfig.Increment = SliderConfig.Increment or 1
                                SliderConfig.Default = SliderConfig.Default or 50
                                SliderConfig.Callback = SliderConfig.Callback or function() end
                                SliderConfig.ValueName = SliderConfig.ValueName or ""
                                SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(9, 149, 98)
                                SliderConfig.Flag = SliderConfig.Flag or nil
                                SliderConfig.Save = SliderConfig.Save or false

                                local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
                                local Dragging = false

                                local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 4), { -- 减小圆角
                                        Size = UDim2.new(0, 0, 1, 0),
                                        BackgroundTransparency = 0.3,
                                        ClipsDescendants = true
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", "value", 12), { -- 减小字体
                                                Size = UDim2.new(1, -10, 0, 12), -- 调整大小
                                                Position = UDim2.new(0, 10, 0, 5), -- 调整位置
                                                Font = Enum.Font.FredokaOne,
                                                Name = "Value",
                                                TextTransparency = 0
                                        }), "Text")
                                })

                                local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 4), { -- 减小圆角
                                        Size = UDim2.new(1, -20, 0, 22), -- 调整大小
                                        Position = UDim2.new(0, 10, 0, 25), -- 调整位置
                                        BackgroundTransparency = 0.9
                                }), {
                                        SetProps(MakeElement("Stroke"), {
                                                Color = SliderConfig.Color
                                        }),
                                        AddThemeObject(SetProps(MakeElement("Label", "value", 12), { -- 减小字体
                                                Size = UDim2.new(1, -10, 0, 12), -- 调整大小
                                                Position = UDim2.new(0, 10, 0, 5), -- 调整位置
                                                Font = Enum.Font.FredokaOne,
                                                Name = "Value",
                                                TextTransparency = 0.8
                                        }), "Text"),
                                        SliderDrag
                                })

                                local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), { -- 减小圆角
                                        Size = UDim2.new(1, 0, 0, 55), -- 减小高度
                                        Parent = ItemParent
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 13), { -- 减小字体
                                                Size = UDim2.new(1, -10, 0, 12), -- 调整大小
                                                Position = UDim2.new(0, 10, 0, 8), -- 调整位置
                                                Font = Enum.Font.FredokaOne,
                                                Name = "Content"
                                        }), "Text"),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                        SliderBar
                                }), "Second")

                                SliderBar.InputBegan:Connect(function(Input)
                                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                                                Dragging = true 
                                        end 
                                end)
                                SliderBar.InputEnded:Connect(function(Input) 
                                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                                                Dragging = false 
                                        end 
                                end)

                                UserInputService.InputChanged:Connect(function(Input)
                                        if Dragging then 
                                                local SizeScale = math.clamp((Mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                                                Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale)) 
                                                SaveCfg(game.GameId)
                                        end
                                end)

                                function Slider:Set(Value)
                                        self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                                        TweenService:Create(SliderDrag,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
                                        SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
                                        SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
                                        SliderConfig.Callback(self.Value)
                                end      

                                Slider:Set(Slider.Value)
                                if SliderConfig.Flag then                                
                                        OrionLib.Flags[SliderConfig.Flag] = Slider
                                end
                                return Slider
                        end  
                        function ElementFunction:AddDropdown(DropdownConfig)
                                DropdownConfig = DropdownConfig or {}
                                DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
                                DropdownConfig.Options = DropdownConfig.Options or {}
                                DropdownConfig.Default = DropdownConfig.Default or ""
                                DropdownConfig.Callback = DropdownConfig.Callback or function() end
                                DropdownConfig.Flag = DropdownConfig.Flag or nil
                                DropdownConfig.Save = DropdownConfig.Save or false

                                local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
                                local MaxElements = 5

                                if not table.find(Dropdown.Options, Dropdown.Value) then
                                        Dropdown.Value = "..."
                                end

                                local DropdownList = MakeElement("List")

                                local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 3), { -- 减小滚动条宽度
                                        DropdownList
                                }), {
                                        Parent = ItemParent,
                                        Position = UDim2.new(0, 0, 0, 32), -- 调整位置
                                        Size = UDim2.new(1, 0, 1, -32), -- 调整大小
                                        ClipsDescendants = true
                                }), "Divider")

                                local Click = SetProps(MakeElement("Button"), {
                                        Size = UDim2.new(1, 0, 1, 0)
                                })

                                local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), { -- 减小圆角
                                        Size = UDim2.new(1, 0, 0, 32), -- 减小高度
                                        Parent = ItemParent,
                                        ClipsDescendants = true
                                }), {
                                        DropdownContainer,
                                        SetProps(SetChildren(MakeElement("TFrame"), {
                                                AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 13), { -- 减小字体
                                                        Size = UDim2.new(1, -10, 1, 0), -- 调整大小
                                                        Position = UDim2.new(0, 10, 0, 0), -- 调整位置
                                                        Font = Enum.Font.FredokaOne,
                                                        Name = "Content"
                                                }), "Text"),
                                                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
                                                        Size = UDim2.new(0, 16, 0, 16), -- 减小图标大小
                                                        AnchorPoint = Vector2.new(0, 0.5),
                                                        Position = UDim2.new(1, -25, 0.5, 0), -- 调整位置
                                                        ImageColor3 = Color3.fromRGB(240, 240, 240),
                                                        Name = "Ico"
                                                }), "TextDark"),
                                                AddThemeObject(SetProps(MakeElement("Label", "Selected", 12), { -- 减小字体
                                                        Size = UDim2.new(1, -35, 1, 0), -- 调整大小
                                                        Font = Enum.Font.FredokaOne,
                                                        Name = "Selected",
                                                        TextXAlignment = Enum.TextXAlignment.Right
                                                }), "TextDark"),
                                                AddThemeObject(SetProps(MakeElement("Frame"), {
                                                        Size = UDim2.new(1, 0, 0, 1),
                                                        Position = UDim2.new(0, 0, 1, -1),
                                                        Name = "Line",
                                                        Visible = false
                                                }), "Stroke"), 
                                                Click
                                        }), {
                                                Size = UDim2.new(1, 0, 0, 32), -- 调整高度
                                                ClipsDescendants = true,
                                                Name = "F"
                                        }),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                        MakeElement("Corner")
                                }), "Second")

                                AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                                        DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
                                end)  

                                local function AddOptions(Options)
                                        for _, Option in pairs(Options) do
                                                local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
                                                        MakeElement("Corner", 0, 5), -- 减小圆角
                                                        AddThemeObject(SetProps(MakeElement("Label", Option, 12, 0.4), { -- 减小字体
                                                                Position = UDim2.new(0, 6, 0, 0), -- 调整位置
                                                                Size = UDim2.new(1, -6, 1, 0), -- 调整大小
                                                                Name = "Title"
                                                        }), "Text")
                                                }), {
                                                        Parent = DropdownContainer,
                                                        Size = UDim2.new(1, 0, 0, 24), -- 减小高度
                                                        BackgroundTransparency = 1,
                                                        ClipsDescendants = true
                                                }), "Divider")

                                                AddConnection(OptionBtn.MouseButton1Click, function()
                                                        Dropdown:Set(Option)
                                                        SaveCfg(game.GameId)
                                                end)

                                                Dropdown.Buttons[Option] = OptionBtn
                                        end
                                end        

                                function Dropdown:Refresh(Options, Delete)
                                        if Delete then
                                                for _,v in pairs(Dropdown.Buttons) do
                                                        v:Destroy()
                                                end    
                                                table.clear(Dropdown.Options)
                                                table.clear(Dropdown.Buttons)
                                        end
                                        Dropdown.Options = Options
                                        AddOptions(Dropdown.Options)
                                end  

                                function Dropdown:Set(Value)
                                        if not table.find(Dropdown.Options, Value) then
                                                Dropdown.Value = "..."
                                                DropdownFrame.F.Selected.Text = Dropdown.Value
                                                for _, v in pairs(Dropdown.Buttons) do
                                                        TweenService:Create(v,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 1}):Play()
                                                        TweenService:Create(v.Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0.4}):Play()
                                                end        
                                                return
                                        end

                                        Dropdown.Value = Value
                                        DropdownFrame.F.Selected.Text = Dropdown.Value

                                        for _, v in pairs(Dropdown.Buttons) do
                                                TweenService:Create(v,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 1}):Play()
                                                TweenService:Create(v.Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0.4}):Play()
                                        end        
                                        TweenService:Create(Dropdown.Buttons[Value],TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 0}):Play()
                                        TweenService:Create(Dropdown.Buttons[Value].Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0}):Play()
                                        return DropdownConfig.Callback(Dropdown.Value)
                                end

                                AddConnection(Click.MouseButton1Click, function()
                                        Dropdown.Toggled = not Dropdown.Toggled
                                        DropdownFrame.F.Line.Visible = Dropdown.Toggled
                                        TweenService:Create(DropdownFrame.F.Ico,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Rotation = Dropdown.Toggled and 180 or 0}):Play()
                                        if #Dropdown.Options > MaxElements then
                                                TweenService:Create(DropdownFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Dropdown.Toggled and UDim2.new(1, 0, 0, 32 + (MaxElements * 24)) or UDim2.new(1, 0, 0, 32)}):Play() -- 调整大小
                                        else
                                                TweenService:Create(DropdownFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Dropdown.Toggled and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 32) or UDim2.new(1, 0, 0, 32)}):Play() -- 调整大小
                                        end
                                end)

                                Dropdown:Refresh(Dropdown.Options, false)
                                Dropdown:Set(Dropdown.Value)
                                if DropdownConfig.Flag then                                
                                        OrionLib.Flags[DropdownConfig.Flag] = Dropdown
                                end
                                return Dropdown
                        end
                        function ElementFunction:AddBind(BindConfig)
                                BindConfig.Name = BindConfig.Name or "Bind"
                                BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
                                BindConfig.Hold = BindConfig.Hold or false
                                BindConfig.Callback = BindConfig.Callback or function() end
                                BindConfig.Flag = BindConfig.Flag or nil
                                BindConfig.Save = BindConfig.Save or false

                                local Bind = {Value, Binding = false, Type = "Bind", Save = BindConfig.Save}
                                local Holding = false

                                local Click = SetProps(MakeElement("Button"), {
                                        Size = UDim2.new(1, 0, 1, 0)
                                })

                                local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 3), { -- 减小圆角
                                        Size = UDim2.new(0, 20, 0, 20), -- 减小大小
                                        Position = UDim2.new(1, -10, 0.5, 0), -- 调整位置
                                        AnchorPoint = Vector2.new(1, 0.5)
                                }), {
                                        AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                        AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 12), { -- 减小字体
                                                Size = UDim2.new(1, 0, 1, 0),
                                                Font = Enum.Font.FredokaOne,
                                                TextXAlignment = Enum.TextXAlignment.Center,
                                                Name = "Value"
                                        }), "Text")
                                }), "Main")

                                local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), { -- 减小圆角
                                        Size = UDim2.new(1, 0, 0, 32), -- 减小高度
                                        Parent = ItemParent
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 13), { -- 减小字体
                                                Size = UDim2.new(1, -10, 1, 0), -- 调整大小
                                                Position = UDim2.new(0, 10, 0, 0), -- 调整位置
                                                Font = Enum.Font.FredokaOne,
                                                Name = "Content"
                                        }), "Text"),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                        BindBox,
                                        Click
                                }), "Second")

                                AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
                                        TweenService:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 12, 0, 20)}):Play() -- 调整大小
                                end)

                                AddConnection(Click.InputEnded, function(Input)
                                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                                if Bind.Binding then return end
                                                Bind.Binding = true
                                                BindBox.Value.Text = ""
                                        end
                                end)

                                AddConnection(UserInputService.InputBegan, function(Input)
                                        if UserInputService:GetFocusedTextBox() then return end
                                        if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
                                                if BindConfig.Hold then
                                                        Holding = true
                                                        BindConfig.Callback(Holding)
                                                else
                                                        BindConfig.Callback()
                                                end
                                        elseif Bind.Binding then
                                                local Key
                                                pcall(function()
                                                        if not CheckKey(BlacklistedKeys, Input.KeyCode) then
                                                                Key = Input.KeyCode
                                                        end
                                                end)
                                                pcall(function()
                                                        if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then
                                                                Key = Input.UserInputType
                                                        end
                                                end)
                                                Key = Key or Bind.Value
                                                Bind:Set(Key)
                                                SaveCfg(game.GameId)
                                        end
                                end)

                                AddConnection(UserInputService.InputEnded, function(Input)
                                        if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
                                                if BindConfig.Hold and Holding then
                                                        Holding = false
                                                        BindConfig.Callback(Holding)
                                                end
                                        end
                                end)

                                AddConnection(Click.MouseEnter, function()
                                        TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                                end)

                                AddConnection(Click.MouseLeave, function()
                                        TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
                                end)

                                AddConnection(Click.MouseButton1Up, function()
                                        TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                                end)

                                AddConnection(Click.MouseButton1Down, function()
                                        TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
                                end)

                                function Bind:Set(Key)
                                        Bind.Binding = false
                                        Bind.Value = Key or Bind.Value
                                        Bind.Value = Bind.Value.Name or Bind.Value
                                        BindBox.Value.Text = Bind.Value
                                end

                                Bind:Set(BindConfig.Default)
                                if BindConfig.Flag then                                
                                        OrionLib.Flags[BindConfig.Flag] = Bind
                                end
                                return Bind
                        end  
                        function ElementFunction:AddTextbox(TextboxConfig)
                                TextboxConfig = TextboxConfig or {}
                                TextboxConfig.Name = TextboxConfig.Name or "Textbox"
                                TextboxConfig.Default = TextboxConfig.Default or ""
                                TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
                                TextboxConfig.Callback = TextboxConfig.Callback or function() end

                                local Click = SetProps(MakeElement("Button"), {
                                        Size = UDim2.new(1, 0, 1, 0)
                                })

                                local TextboxActual = AddThemeObject(Create("TextBox", {
                                        Size = UDim2.new(1, 0, 1, 0),
                                        BackgroundTransparency = 1,
                                        TextColor3 = Color3.fromRGB(255, 255, 255),
                                        PlaceholderColor3 = Color3.fromRGB(210,210,210),
                                        PlaceholderText = "Input",
                                        Font = Enum.Font.FredokaOne,
                                        TextXAlignment = Enum.TextXAlignment.Center,
                                        TextSize = 12, -- 减小字体
                                        ClearTextOnFocus = false
                                }), "Text")

                                local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 3), { -- 减小圆角
                                        Size = UDim2.new(0, 20, 0, 20), -- 减小大小
                                        Position = UDim2.new(1, -10, 0.5, 0), -- 调整位置
                                        AnchorPoint = Vector2.new(1, 0.5)
                                }), {
                                        AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                        TextboxActual
                                }), "Main")


                                local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), { -- 减小圆角
                                        Size = UDim2.new(1, 0, 0, 32), -- 减小高度
                                        Parent = ItemParent
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 13), { -- 减小字体
                                                Size = UDim2.new(1, -10, 1, 0), -- 调整大小
                                                Position = UDim2.new(0, 10, 0, 0), -- 调整位置
                                                Font = Enum.Font.FredokaOne,
                                                Name = "Content"
                                        }), "Text"),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                        TextContainer,
                                        Click
                                }), "Second")

                                AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
                                        TweenService:Create(TextContainer, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, TextboxActual.TextBounds.X + 12, 0, 20)}):Play() -- 调整大小
                                end)

                                AddConnection(TextboxActual.FocusLost, function()
                                        TextboxConfig.Callback(TextboxActual.Text)
                                        if TextboxConfig.TextDisappear then
                                                TextboxActual.Text = ""
                                        end        
                                end)

                                TextboxActual.Text = TextboxConfig.Default

                                AddConnection(Click.MouseEnter, function()
                                        TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                                end)

                                AddConnection(Click.MouseLeave, function()
                                        TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
                                end)

                                AddConnection(Click.MouseButton1Up, function()
                                        TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                                        TextboxActual:CaptureFocus()
                                end)

                                AddConnection(Click.MouseButton1Down, function()
                                        TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
                                end)
                        end 
                        function ElementFunction:AddColorpicker(ColorpickerConfig)
                                ColorpickerConfig = ColorpickerConfig or {}
                                ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
                                ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255,255,255)
                                ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
                                ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
                                ColorpickerConfig.Save = ColorpickerConfig.Save or false

                                local ColorH, ColorS, ColorV = 1, 1, 1
                                local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}

                                local ColorSelection = Create("ImageLabel", {
                                        Size = UDim2.new(0, 14, 0, 14), -- 减小选择器大小
                                        Position = UDim2.new(select(3, Color3.toHSV(Colorpicker.Value))),
                                        ScaleType = Enum.ScaleType.Fit,
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundTransparency = 1,
                                        Image = "http://www.roblox.com/asset/?id=4805639000"
                                })

                                local HueSelection = Create("ImageLabel", {
                                        Size = UDim2.new(0, 14, 0, 14), -- 减小选择器大小
                                        Position = UDim2.new(0.5, 0, 1 - select(1, Color3.toHSV(Colorpicker.Value))),
                                        ScaleType = Enum.ScaleType.Fit,
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundTransparency = 1,
                                        Image = "http://www.roblox.com/asset/?id=4805639000"
                                })

                                local Color = Create("ImageLabel", {
                                        Size = UDim2.new(1, -20, 1, 0), -- 调整大小
                                        Visible = false,
                                        Image = "rbxassetid://4155801252"
                                }, {
                                        Create("UICorner", {CornerRadius = UDim.new(0, 4)}), -- 减小圆角
                                        ColorSelection
                                })

                                local Hue = Create("Frame", {
                                        Size = UDim2.new(0, 16, 1, 0), -- 减小宽度
                                        Position = UDim2.new(1, -16, 0, 0), -- 调整位置
                                        Visible = false
                                }, {
                                        Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))},}),
                                        Create("UICorner", {CornerRadius = UDim.new(0, 4)}), -- 减小圆角
                                        HueSelection
                                })

                                local ColorpickerContainer = Create("Frame", {
                                        Position = UDim2.new(0, 0, 0, 26), -- 调整位置
                                        Size = UDim2.new(1, 0, 1, -26), -- 调整大小
                                        BackgroundTransparency = 1,
                                        ClipsDescendants = true
                                }, {
                                        Hue,
                                        Color,
                                        Create("UIPadding", {
                                                PaddingLeft = UDim.new(0, 30), -- 调整内边距
                                                PaddingRight = UDim.new(0, 30),
                                                PaddingBottom = UDim.new(0, 8),
                                                PaddingTop = UDim.new(0, 14)
                                        })
                                })

                                local Click = SetProps(MakeElement("Button"), {
                                        Size = UDim2.new(1, 0, 1, 0)
                                })

                                local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 3), { -- 减小圆角
                                        Size = UDim2.new(0, 20, 0, 20), -- 减小大小
                                        Position = UDim2.new(1, -10, 0.5, 0), -- 调整位置
                                        AnchorPoint = Vector2.new(1, 0.5)
                                }), {
                                        AddThemeObject(MakeElement("Stroke"), "Stroke")
                                }), "Main")

                                local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), { -- 减小圆角
                                        Size = UDim2.new(1, 0, 0, 32), -- 减小高度
                                        Parent = ItemParent
                                }), {
                                        SetProps(SetChildren(MakeElement("TFrame"), {
                                                AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 13), { -- 减小字体
                                                        Size = UDim2.new(1, -10, 1, 0), -- 调整大小
                                                        Position = UDim2.new(0, 10, 0, 0), -- 调整位置
                                                        Font = Enum.Font.FredokaOne,
                                                        Name = "Content"
                                                }), "Text"),
                                                ColorpickerBox,
                                                Click,
                                                AddThemeObject(SetProps(MakeElement("Frame"), {
                                                        Size = UDim2.new(1, 0, 0, 1),
                                                        Position = UDim2.new(0, 0, 1, -1),
                                                        Name = "Line",
                                                        Visible = false
                                                }), "Stroke"), 
                                        }), {
                                                Size = UDim2.new(1, 0, 0, 32), -- 调整高度
                                                ClipsDescendants = true,
                                                Name = "F"
                                        }),
                                        ColorpickerContainer,
                                        AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                }), "Second")

                                AddConnection(Click.MouseButton1Click, function()
                                        Colorpicker.Toggled = not Colorpicker.Toggled
                                        TweenService:Create(ColorpickerFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 120) or UDim2.new(1, 0, 0, 32)}):Play() -- 调整大小
                                        Color.Visible = Colorpicker.Toggled
                                        Hue.Visible = Colorpicker.Toggled
                                        ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
                                end)

                                local function UpdateColorPicker()
                                        ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
                                        Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
                                        Colorpicker:Set(ColorpickerBox.BackgroundColor3)
                                        ColorpickerConfig.Callback(ColorpickerBox.BackgroundColor3)
                                        SaveCfg(game.GameId)
                                end

                                ColorH = 1 - (math.clamp(HueSelection.AbsolutePosition.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
                                ColorS = (math.clamp(ColorSelection.AbsolutePosition.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
                                ColorV = 1 - (math.clamp(ColorSelection.AbsolutePosition.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)

                                AddConnection(Color.InputBegan, function(input)
                                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                                if ColorInput then
                                                        ColorInput:Disconnect()
                                                end
                                                ColorInput = AddConnection(RunService.RenderStepped, function()
                                                        local ColorX = (math.clamp(Mouse.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
                                                        local ColorY = (math.clamp(Mouse.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)
                                                        ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
                                                        ColorS = ColorX
                                                        ColorV = 1 - ColorY
                                                        UpdateColorPicker()
                                                end)
                                        end
                                end)

                                AddConnection(Color.InputEnded, function(input)
                                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                                if ColorInput then
                                                        ColorInput:Disconnect()
                                                end
                                        end
                                end)

                                AddConnection(Hue.InputBegan, function(input)
                                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                                if HueInput then
                                                        HueInput:Disconnect()
                                                end;

                                                HueInput = AddConnection(RunService.RenderStepped, function()
                                                        local HueY = (math.clamp(Mouse.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)

                                                        HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
                                                        ColorH = 1 - HueY

                                                        UpdateColorPicker()
                                                end)
                                        end
                                end)

                                AddConnection(Hue.InputEnded, function(input)
                                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                                if HueInput then
                                                        HueInput:Disconnect()
                                                end
                                        end
                                end)

                                function Colorpicker:Set(Value)
                                        Colorpicker.Value = Value
                                        ColorpickerBox.BackgroundColor3 = Colorpicker.Value
                                        ColorpickerConfig.Callback(Colorpicker.Value)
                                end

                                Colorpicker:Set(Colorpicker.Value)
                                if ColorpickerConfig.Flag then                                
                                        OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker
                                end
                                return Colorpicker
                        end  
                        return ElementFunction   
                end        

                local ElementFunction = {}

                function ElementFunction:AddSection(SectionConfig)
                        SectionConfig.Name = SectionConfig.Name or "Section"

                        local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
                                Size = UDim2.new(1, 0, 0, 22), -- 减小高度
                                Parent = Container
                        }), {
                                AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 12), { -- 减小字体
                                        Size = UDim2.new(1, -10, 0, 14), -- 调整大小
                                        Position = UDim2.new(0, 0, 0, 2), -- 调整位置
                                        Font = Enum.Font.FredokaOne
                                }), "TextDark"),
                                SetChildren(SetProps(MakeElement("TFrame"), {
                                        AnchorPoint = Vector2.new(0, 0),
                                        Size = UDim2.new(1, 0, 1, -20), -- 调整大小
                                        Position = UDim2.new(0, 0, 0, 19), -- 调整位置
                                        Name = "Holder"
                                }), {
                                        MakeElement("List", 0, 4) -- 减小间距
                                }),
                        })

                        AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                                SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 26) -- 调整高度
                                SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
                        end)

                        local SectionFunction = {}
                        for i, v in next, GetElements(SectionFrame.Holder) do
                                SectionFunction[i] = v 
                        end
                        return SectionFunction
                end        

                for i, v in next, GetElements(Container) do
                        ElementFunction[i] = v 
                end

                if TabConfig.PremiumOnly then
                        for i, v in next, ElementFunction do
                                ElementFunction[i] = function() end
                        end    
                        Container:FindFirstChild("UIListLayout"):Destroy()
                        Container:FindFirstChild("UIPadding"):Destroy()
                        SetChildren(SetProps(MakeElement("TFrame"), {
                                Size = UDim2.new(1, 0, 1, 0),
                                Parent = ItemParent
                        }), {
                                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
                                        Size = UDim2.new(0, 14, 0, 14), -- 减小图标大小
                                        Position = UDim2.new(0, 12, 0, 12), -- 调整位置
                                        ImageTransparency = 0.4
                                }), "Text"),
                                AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 12), { -- 减小字体
                                        Size = UDim2.new(1, -32, 0, 12), -- 调整大小
                                        Position = UDim2.new(0, 32, 0, 14), -- 调整位置
                                        TextTransparency = 0.4
                                }), "Text"),
                                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
                                        Size = UDim2.new(0, 48, 0, 48), -- 减小图标大小
                                        Position = UDim2.new(0, 70, 0, 90), -- 调整位置
                                }), "Text"),
                                AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 12), { -- 减小字体
                                        Size = UDim2.new(1, -130, 0, 12), -- 调整大小
                                        Position = UDim2.new(0, 130, 0, 92), -- 调整位置
                                        Font = Enum.Font.FredokaOne
                                }), "Text"),
                                AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to Sirius Premium users. Purchase Premium in the Discord server (discord.gg/sirius)", 11), { -- 减小字体
                                        Size = UDim2.new(1, -170, 0, 12), -- 调整大小
                                        Position = UDim2.new(0, 130, 0, 112), -- 调整位置
                                        TextWrapped = true,
                                        TextTransparency = 0.4
                                }), "Text")
                        })
                end
                return ElementFunction   
        end  

        return TabFunction
end   

local Configs_HUB = {
  Cor_Hub = Color3.fromRGB(15, 15, 15),
  Cor_Options = Color3.fromRGB(15, 15, 15),
  Cor_Stroke = Color3.fromRGB(60, 60, 60),
  Cor_Text = Color3.fromRGB(240, 240, 240),
  Cor_DarkText = Color3.fromRGB(140, 140, 140),
  Corner_Radius = UDim.new(0, 3), -- 减小圆角
  Text_Font = Enum.Font.FredokaOne
}

local TweenService = game:GetService("TweenService")

local function Create(instance, parent, props)
  local new = Instance.new(instance, parent)
  if props then
    table.foreach(props, function(prop, value)
      new[prop] = value
    end)
  end
  return new
end

local function SetProps(instance, props)
  if instance and props then
    table.foreach(props, function(prop, value)
      instance[prop] = value
    end)
  end
  return instance
end

local function Corner(parent, props)
  local new = Create("UICorner", parent)
  new.CornerRadius = Configs_HUB.Corner_Radius
  if props then
    SetProps(new, props)
  end
  return new
end

local function Stroke(parent, props)
  local new = Create("UIStroke", parent)
  new.Color = Configs_HUB.Cor_Stroke
  new.ApplyStrokeMode = "Border"
  if props then
    SetProps(new, props)
  end
  return new
end

local function CreateTween(instance, prop, value, time, tweenWait)
  local tween = TweenService:Create(instance,
  TweenInfo.new(time, Enum.EasingStyle.Linear),
  {[prop] = value})
  tween:Play()
  if tweenWait then
    tween.Completed:Wait()
  end
end

local ScreenGui = Create("ScreenGui", Orion)

local Menu_Notifi = Create("Frame", ScreenGui, {
  Size = UDim2.new(0, 250, 1, 0), -- 减小宽度
  Position = UDim2.new(1, 0, 0, 0),
  AnchorPoint = Vector2.new(1, 0),
  BackgroundTransparency = 1
})

local Padding = Create("UIPadding", Menu_Notifi, {
  PaddingLeft = UDim.new(0, 20), -- 减小内边距
  PaddingTop = UDim.new(0, 20),
  PaddingBottom = UDim.new(0, 40)
})

local ListLayout = Create("UIListLayout", Menu_Notifi, {
  Padding = UDim.new(0, 12), -- 减小间距
  VerticalAlignment = "Bottom"
})

function OrionLib:MakeNotifi(Configs)
  local Title = Configs.Title or "Title!"
  local text = Configs.Text or "Notification content... what will it say??"
  local timewait = Configs.Time or 5

  local Frame1 = Create("Frame", Menu_Notifi, {
    Size = UDim2.new(2, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = "Y",
    Name = "Title"
  })

  local Frame2 = Create("Frame", Frame1, {
    Size = UDim2.new(0, Menu_Notifi.Size.X.Offset - 40, 0, 0), -- 调整大小
    BackgroundColor3 = Configs_HUB.Cor_Hub,
    Position = UDim2.new(0, Menu_Notifi.Size.X.Offset, 0, 0),
    AutomaticSize = "Y"
  })Corner(Frame2)

  local TextLabel = Create("TextLabel", Frame2, {
    Size = UDim2.new(1, 0, 0, 20), -- 减小高度
    Font = Configs_HUB.Text_Font,
    BackgroundTransparency = 1,
    Text = Title,
    TextSize = 16, -- 减小字体
    Position = UDim2.new(0, 16, 0, 4), -- 调整位置
    TextXAlignment = "Left",
    TextColor3 = Configs_HUB.Cor_Text
  })

  local TextButton = Create("TextButton", Frame2, {
    Text = "X",
    Font = Configs_HUB.Text_Font,
    TextSize = 16, -- 减小字体
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(200, 200, 200),
    Position = UDim2.new(1, -4, 0, 4), -- 调整位置
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 20, 0, 20) -- 减小大小
  })

  local TextLabel = Create("TextLabel", Frame2, {
    Size = UDim2.new(1, -25, 0, 0), -- 调整大小
    Position = UDim2.new(0, 16, 0, TextButton.Size.Y.Offset + 8), -- 调整位置
    TextSize = 13, -- 减小字体
    TextColor3 = Configs_HUB.Cor_DarkText,
    TextXAlignment = "Left",
    TextYAlignment = "Top",
    AutomaticSize = "Y",
    Text = text,
    Font = Configs_HUB.Text_Font,
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    TextWrapped = true
  })

  local FrameSize = Create("Frame", Frame2, {
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = Configs_HUB.Cor_Stroke,
    Position = UDim2.new(0, 2, 0, 24), -- 调整位置
    BorderSizePixel = 0
  })Corner(FrameSize)Create("Frame", Frame2, {
    Size = UDim2.new(0, 0, 0, 4), -- 调整大小
    Position = UDim2.new(0, 0, 1, 4), -- 调整位置
    BackgroundTransparency = 1
  })

  task.spawn(function()
    CreateTween(FrameSize, "Size", UDim2.new(0, 0, 0, 2), timewait, true)
  end)

  TextButton.MouseButton1Click:Connect(function()
    CreateTween(Frame2, "Position", UDim2.new(0, -16, 0, 0), 0.1, true) -- 调整位置
    CreateTween(Frame2, "Position", UDim2.new(0, Menu_Notifi.Size.X.Offset, 0, 0), 0.5, true)
    Frame1:Destroy()
  end)

  task.spawn(function()
    CreateTween(Frame2, "Position", UDim2.new(0, -16, 0, 0), 0.5, true) -- 调整位置
    CreateTween(Frame2, "Position", UDim2.new(), 0.1, true)task.wait(timewait)
    if Frame2 then
      CreateTween(Frame2, "Position", UDim2.new(0, -16, 0, 0), 0.1, true) -- 调整位置
      CreateTween(Frame2, "Position", UDim2.new(0, Menu_Notifi.Size.X.Offset, 0, 0), 0.5, true)
      Frame1:Destroy()
    end
  end)
end

function OrionLib:Destroy()
        Orion:Destroy() --[[可以删除,删了没事没事的]]--
end

return OrionLib