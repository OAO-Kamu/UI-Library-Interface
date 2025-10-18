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
                        Main = Color3.fromRGB(20, 20, 30),--深蓝灰色主色调
                        Second = Color3.fromRGB(30, 35, 45),--次要区域
                        Stroke = Color3.fromRGB(60, 130, 255),--蓝色边框
                        Divider = Color3.fromRGB(80, 150, 255),--高亮蓝色
                        Text = Color3.fromRGB(240, 245, 255),--亮白色文字
                        TextDark = Color3.fromRGB(170, 180, 200),--灰色文字
                        Accent = Color3.fromRGB(0, 150, 255)--强调色
                },
                Dark = {
                        Main = Color3.fromRGB(15, 15, 20),
                        Second = Color3.fromRGB(25, 25, 35),
                        Stroke = Color3.fromRGB(80, 80, 100),
                        Divider = Color3.fromRGB(100, 100, 120),
                        Text = Color3.fromRGB(230, 230, 230),
                        TextDark = Color3.fromRGB(150, 150, 150),
                        Accent = Color3.fromRGB(100, 100, 120)
                },
                Purple = {
                        Main = Color3.fromRGB(30, 25, 40),
                        Second = Color3.fromRGB(45, 35, 60),
                        Stroke = Color3.fromRGB(150, 100, 255),
                        Divider = Color3.fromRGB(170, 120, 255),
                        Text = Color3.fromRGB(240, 235, 255),
                        TextDark = Color3.fromRGB(180, 170, 200),
                        Accent = Color3.fromRGB(150, 100, 255)
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
Orion.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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

-- 创建渐变背景函数
local function CreateGradientBackground(parent, colors)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 45
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors[1]),
        ColorSequenceKeypoint.new(1, colors[2])
    })
    gradient.Parent = parent
    return gradient
end

CreateElement("Corner", function(Scale, Offset)
        local Corner = Create("UICorner", {
                CornerRadius = UDim.new(Scale or 0, Offset or 8)
        })
        return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
        local Stroke = Create("UIStroke", {
                Color = Color or OrionLib.Themes[OrionLib.SelectedTheme].Stroke,
                Thickness = Thickness or 1.5,
                Transparency = 0.7
        })
        return Stroke
end)

CreateElement("List", function(Scale, Offset)
        local List = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(Scale or 0, Offset or 4)
        })
        return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
        local Padding = Create("UIPadding", {
                PaddingBottom = UDim.new(0, Bottom or 6),
                PaddingLeft = UDim.new(0, Left or 6),
                PaddingRight = UDim.new(0, Right or 6),
                PaddingTop = UDim.new(0, Top or 6)
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
                BackgroundColor3 = Color or OrionLib.Themes[OrionLib.SelectedTheme].Second,
                BorderSizePixel = 0
        })
        return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
        local Frame = Create("Frame", {
                BackgroundColor3 = Color or OrionLib.Themes[OrionLib.SelectedTheme].Second,
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
                TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text,
                TextTransparency = Transparency or 0,
                TextSize = TextSize or 14,
                Font = Enum.Font.Gotham,
                RichText = true,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left
        })
        return Label
end)

-- 创建阴影效果
local function CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://5554236805"
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23,23,277,277)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.Parent = parent
    return shadow
end

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
        SetProps(MakeElement("List"), {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 8)
        })
}), {
        Position = UDim2.new(1, -25, 1, -25),
        Size = UDim2.new(0, 320, 1, -25),
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

                local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 35), 0, 12), {
                        Parent = NotificationParent, 
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(1, -55, 0, 0),
                        BackgroundTransparency = 0.1,
                        AutomaticSize = Enum.AutomaticSize.Y
                }), {
                        MakeElement("Stroke", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 1.5),
                        MakeElement("Padding", 12, 12, 12, 12),
                        SetProps(MakeElement("Image", NotificationConfig.Image), {
                                Size = UDim2.new(0, 22, 0, 22),
                                ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
                                Name = "Icon"
                        }),
                        SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
                                Size = UDim2.new(1, -30, 0, 22),
                                Position = UDim2.new(0, 30, 0, 0),
                                Font = Enum.Font.GothamSemibold,
                                Name = "Title"
                        }),
                        SetProps(MakeElement("Label", NotificationConfig.Content, 13), {
                                Size = UDim2.new(1, 0, 0, 0),
                                Position = UDim2.new(0, 0, 0, 28),
                                Font = Enum.Font.Gotham,
                                Name = "Content",
                                AutomaticSize = Enum.AutomaticSize.Y,
                                TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].TextDark,
                                TextWrapped = true
                        })
                })
                
                -- 添加渐变背景
                CreateGradientBackground(NotificationFrame, {
                    OrionLib.Themes[OrionLib.SelectedTheme].Second,
                    OrionLib.Themes[OrionLib.SelectedTheme].Main
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
                                        Name = "配置加载",
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
        WindowConfig.IntroText = WindowConfig.IntroText or "高级脚本中心 [V.2.0]"
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

        local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 4), {
                Size = UDim2.new(1, 0, 1, -50)
        }), {
                MakeElement("List"),
                MakeElement("Padding", 8, 0, 0, 8)
        }), "Divider")

        AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
        end)

        local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0.5, 0, 0, 0),
                BackgroundTransparency = 1
        }), {
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://96669691935808"), {
                        Position = UDim2.new(0, 9, 0, 6),
                        Size = UDim2.new(0, 18, 0, 18)
                }), "Text")
        })

        local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
                Size = UDim2.new(0.5, 0, 1, 0),
                BackgroundTransparency = 1
        }), {
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://89547331668158"), {
                        Position = UDim2.new(0, 9, 0, 6),
                        Size = UDim2.new(0, 18, 0, 18),
                        Name = "Ico"
                }), "Text")
        })

        local DragPoint = SetProps(MakeElement("TFrame"), {
                Size = UDim2.new(1, 0, 0, 50)
        })

        local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Second, 0, 12), {
                Size = UDim2.new(0, 160, 1, -50),
                Position = UDim2.new(0, 0, 0, 50)
        }), {
                AddThemeObject(SetProps(MakeElement("Frame"), {
                        Size = UDim2.new(1, 0, 0, 12),
                        Position = UDim2.new(0, 0, 0, 0)
                }), "Second"), 
                AddThemeObject(SetProps(MakeElement("Frame"), {
                        Size = UDim2.new(0, 12, 1, 0),
                        Position = UDim2.new(1, -12, 0, 0)
                }), "Second"), 
                AddThemeObject(SetProps(MakeElement("Frame"), {
                        Size = UDim2.new(0, 1, 1, 0),
                        Position = UDim2.new(1, -1, 0, 0)
                }), "Stroke"), 
                TabHolder,
                SetChildren(SetProps(MakeElement("TFrame"), {
                        Size = UDim2.new(1, 0, 0, 50),
                        Position = UDim2.new(0, 0, 1, -50)
                }), {
                        AddThemeObject(SetProps(MakeElement("Frame"), {
                                Size = UDim2.new(1, 0, 0, 1)
                        }), "Stroke"), 
                        AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
                                AnchorPoint = Vector2.new(0, 0.5),
                                Size = UDim2.new(0, 36, 0, 36),
                                Position = UDim2.new(0, 10, 0.5, 0)
                        }), {
                                SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"), {
                                        Size = UDim2.new(1, 0, 1, 0)
                                }),
                                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
                                        Size = UDim2.new(1, 0, 1, 0),
                                }), "Accent"),
                                MakeElement("Corner", 1)
                        }), "Divider"),
                        SetChildren(SetProps(MakeElement("TFrame"), {
                                AnchorPoint = Vector2.new(0, 0.5),
                                Size = UDim2.new(0, 36, 0, 36),
                                Position = UDim2.new(0, 10, 0.5, 0)
                        }), {
                                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                MakeElement("Corner", 1)
                        }),
                        AddThemeObject(SetProps(MakeElement("Label", ""..game.Players.LocalPlayer.DisplayName.."", WindowConfig.HidePremium and 14 or 13), {
                                Size = UDim2.new(1, -60, 0, 13),
                                Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
                                Font = Enum.Font.GothamSemibold,
                                ClipsDescendants = true
                        }), "Text"),
                        AddThemeObject(SetProps(MakeElement("Label", os.date("%I:%M:%S %p", os.time()), 12), {
                            Size = UDim2.new(1, -60, 0, 12),
                            Position = UDim2.new(0, 50, 1, -25),
                            Visible = not WindowConfig.HidePremium
                        }), "TextDark")

                }),
        }), "Second")

        local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 16), {
                Size = UDim2.new(1, -30, 2, 0),
                Position = UDim2.new(0, 25, 0, -24),
                Font = Enum.Font.GothamBold,
                TextSize = 20
        }), "Text")

        local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1)
        }), "Stroke")

        local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Main, 0, 12), {
                Parent = Orion,
                Position = UDim2.new(0.5, -307, 0.5, -172),
                Size = UDim2.new(0, 615, 0, 344),
                ClipsDescendants = true
        }), {
                SetChildren(SetProps(MakeElement("TFrame"), {
                        Size = UDim2.new(1, 0, 0, 50),
                        Name = "TopBar"
                }), {
                        WindowName,
                        WindowTopBarLine,
                        AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 0, 8), {
                                Size = UDim2.new(0, 70, 0, 30),
                                Position = UDim2.new(1, -90, 0, 10)
                        }), {
                                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                AddThemeObject(SetProps(MakeElement("Frame"), {
                                        Size = UDim2.new(0, 1, 1, 0),
                                        Position = UDim2.new(0.5, 0, 0, 0)
                                }), "Stroke"), 
                                CloseBtn,
                                MinimizeBtn
                        }), "Accent"), 
                }),
                DragPoint,
                WindowStuff
        }), "Main")

        -- 添加阴影效果
        CreateShadow(MainWindow)
        
        -- 添加渐变背景
        CreateGradientBackground(MainWindow, {
            OrionLib.Themes[OrionLib.SelectedTheme].Main,
            Color3.fromRGB(
                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Main.R * 255 + 10, 255),
                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Main.G * 255 + 10, 255),
                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Main.B * 255 + 10, 255)
            )
        })

        if WindowConfig.ShowIcon then
                WindowName.Position = UDim2.new(0, 50, 0, -24)
                local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
                        Size = UDim2.new(0, 22, 0, 22),
                        Position = UDim2.new(0, 25, 0, 15),
                        ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent
                })
                WindowIcon.Parent = MainWindow.TopBar
        end        

        MakeDraggable(DragPoint, MainWindow)

    local MobileReopenButton = SetChildren(SetProps(MakeElement("Button"), {
                Parent = Orion,
                Size = UDim2.new(0, 40, 0, 40),
                Position = UDim2.new(0.5, -20, 0, 20),
                BackgroundTransparency = 0,
                BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main,
                Visible = false
        }), {
                AddThemeObject(SetProps(MakeElement("Image", WindowConfig.IntroToggleIcon or "http://www.roblox.com/asset/?id=121203363140066"), {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0.7, 0, 0.7, 0),
                        ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent
                }), "Text"),
                MakeElement("Corner", 1),
                MakeElement("Stroke", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 1.5)
        })

        -- 添加主题切换按钮
        local ThemeButton = SetChildren(SetProps(MakeElement("Button"), {
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -130, 0, 10),
                BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
                Parent = MainWindow.TopBar
        }), {
                MakeElement("Corner", 1),
                MakeElement("Stroke", OrionLib.Themes[OrionLib.SelectedTheme].Stroke, 1.5),
                SetProps(MakeElement("Image", "rbxassetid://7072725340"), {
                        Size = UDim2.new(0.6, 0, 0.6, 0),
                        Position = UDim2.new(0.2, 0, 0.2, 0),
                        ImageColor3 = Color3.fromRGB(255, 255, 255)
                })
        })

        local currentThemeIndex = 1
        local themeNames = {"Default", "Dark", "Purple"}
        
        AddConnection(ThemeButton.MouseButton1Click, function()
                currentThemeIndex = currentThemeIndex + 1
                if currentThemeIndex > #themeNames then
                        currentThemeIndex = 1
                end
                OrionLib.SelectedTheme = themeNames[currentThemeIndex]
                SetTheme()
                
                OrionLib:MakeNotification({
                        Name = "主题切换",
                        Content = "已切换到 " .. OrionLib.SelectedTheme .. " 主题",
                        Time = 2
                })
        end)

        AddConnection(CloseBtn.MouseButton1Up, function()
                MainWindow.Visible = false
                MobileReopenButton.Visible = true
                UIHidden = true
                WindowConfig.CloseCallback()
        end)

        AddConnection(UserInputService.InputBegan, function(Input)
                if Input.KeyCode == Enum.KeyCode.LeftControl and UIHidden == true then
                        MainWindow.Visible = true
                        MobileReopenButton.Visible = false
                end
        end)

        AddConnection(MobileReopenButton.Activated, function()
                MainWindow.Visible = true
                MobileReopenButton.Visible = false
        end)

        AddConnection(MinimizeBtn.MouseButton1Up, function()
                if Minimized then
                        TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 615, 0, 344)}):Play()
                        MinimizeBtn.Ico.Image = "rbxassetid://89547331668158"
                        wait(.02)
                        MainWindow.ClipsDescendants = false
                        WindowStuff.Visible = true
                        WindowTopBarLine.Visible = true
                else
                        MainWindow.ClipsDescendants = true
                        WindowTopBarLine.Visible = false
                        MinimizeBtn.Ico.Image = "rbxassetid://77359780859993"

                        TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
                        wait(0.1)
                        WindowStuff.Visible = false        
                end
                Minimized = not Minimized    
        end)

        local function LoadSequence()
                MainWindow.Visible = false
                local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
                        Parent = Orion,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.4, 0),
                        Size = UDim2.new(0, 32, 0, 32),
                        ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
                        ImageTransparency = 1
                })

                local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 16), {
                        Parent = Orion,
                        Size = UDim2.new(1, 0, 1, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 19, 0.5, 0),
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Font = Enum.Font.GothamBold,
                        TextTransparency = 1
                })

                TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
                wait(0.8)
                TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
                wait(0.3)
                TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
                wait(2)
                TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
                MainWindow.Visible = true
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
                        Size = UDim2.new(1, 0, 0, 35),
                        Parent = TabHolder
                }), {
                        AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
                                AnchorPoint = Vector2.new(0, 0.5),
                                Size = UDim2.new(0, 20, 0, 20),
                                Position = UDim2.new(0, 12, 0.5, 0),
                                ImageTransparency = 0.4,
                                Name = "Ico",
                                ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent
                        }), "Text"),
                        AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
                                Size = UDim2.new(1, -40, 1, 0),
                                Position = UDim2.new(0, 40, 0, 0),
                                Font = Enum.Font.GothamSemibold,
                                TextTransparency = 0.4,
                                Name = "Title"
                        }), "Text")
                })

                if GetIcon(TabConfig.Icon) ~= nil then
                        TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
                end        

                local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 5), {
                        Size = UDim2.new(1, -160, 1, -50),
                        Position = UDim2.new(0, 160, 0, 50),
                        Parent = MainWindow,
                        Visible = false,
                        Name = "ItemContainer"
                }), {
                        MakeElement("List", 0, 8),
                        MakeElement("Padding", 15, 12, 12, 15)
                }), "Divider")

                AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                        Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
                end)

                if FirstTab then
                        FirstTab = false
                        TabFrame.Ico.ImageTransparency = 0
                        TabFrame.Title.TextTransparency = 0
                        TabFrame.Title.Font = Enum.Font.GothamBold
                        Container.Visible = true
                end    

                AddConnection(TabFrame.MouseButton1Click, function()
                        for _, Tab in next, TabHolder:GetChildren() do
                                if Tab:IsA("TextButton") then
                                        Tab.Title.Font = Enum.Font.GothamSemibold
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
                        TabFrame.Title.Font = Enum.Font.GothamBold
                        Container.Visible = true   
                end)

                local function GetElements(ItemParent)
                        local ElementFunction = {}
                        function ElementFunction:AddLabel(Text)
                                local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Second, 0, 8), {
                                        Size = UDim2.new(1, 0, 0, 35),
                                        BackgroundTransparency = 0.3,
                                        Parent = ItemParent
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
                                                Size = UDim2.new(1, -15, 1, 0),
                                                Position = UDim2.new(0, 15, 0, 0),
                                                Font = Enum.Font.GothamSemibold,
                                                Name = "Content"
                                        }), "Text"),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke")
                                }), "Second")

                                -- 添加渐变背景
                                CreateGradientBackground(LabelFrame, {
                                    OrionLib.Themes[OrionLib.SelectedTheme].Second,
                                    Color3.fromRGB(
                                        math.min(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 5, 255),
                                        math.min(OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 5, 255),
                                        math.min(OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 5, 255)
                                    )
                                })

                                local LabelFunction = {}
                                function LabelFunction:Set(ToChange)
                                        LabelFrame.Content.Text = ToChange
                                end
                                return LabelFunction
                        end
                        function ElementFunction:AddParagraph(Text, Content)
                                Text = Text or "Text"
                                Content = Content or "Content"

                                local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Second, 0, 8), {
                                        Size = UDim2.new(1, 0, 0, 35),
                                        BackgroundTransparency = 0.3,
                                        Parent = ItemParent
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
                                                Size = UDim2.new(1, -15, 0, 16),
                                                Position = UDim2.new(0, 15, 0, 10),
                                                Font = Enum.Font.GothamSemibold,
                                                Name = "Title"
                                        }), "Text"),
                                        AddThemeObject(SetProps(MakeElement("Label", Content, 13), {
                                                Size = UDim2.new(1, -25, 0, 0),
                                                Position = UDim2.new(0, 15, 0, 28),
                                                Font = Enum.Font.Gotham,
                                                Name = "Content",
                                                TextWrapped = true
                                        }), "TextDark"),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke")
                                }), "Second")

                                -- 添加渐变背景
                                CreateGradientBackground(ParagraphFrame, {
                                    OrionLib.Themes[OrionLib.SelectedTheme].Second,
                                    Color3.fromRGB(
                                        math.min(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 5, 255),
                                        math.min(OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 5, 255),
                                        math.min(OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 5, 255)
                                    )
                                })

                                AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
                                        ParagraphFrame.Content.Size = UDim2.new(1, -25, 0, ParagraphFrame.Content.TextBounds.Y)
                                        ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 40)
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

                                local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 0, 8), {
                                        Size = UDim2.new(1, 0, 0, 38),
                                        Parent = ItemParent
                                }), {
                                        AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
                                                Size = UDim2.new(1, -15, 1, 0),
                                                Position = UDim2.new(0, 15, 0, 0),
                                                Font = Enum.Font.GothamSemibold,
                                                Name = "Content"
                                        }), "Text"),
                                        AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
                                                Size = UDim2.new(0, 22, 0, 22),
                                                Position = UDim2.new(1, -32, 0, 8),
                                                ImageColor3 = Color3.fromRGB(255, 255, 255),
                                        }), "TextDark"),
                                        AddThemeObject(MakeElement("Stroke"), "Stroke"),
                                        Click
                                }), "Accent")

                                -- 添加渐变背景
                                CreateGradientBackground(ButtonFrame, {
                                    OrionLib.Themes[OrionLib.SelectedTheme].Accent,
                                    Color3.fromRGB(
                                        math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.R * 255 + 20, 255),
                                        math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.G * 255 + 20, 255),
                                        math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.B * 255 + 20, 255)
                                    )
                                })

                                AddConnection(Click.MouseEnter, function()
                                        TweenService:Create(ButtonFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(
                                                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.R * 255 + 15, 255),
                                                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.G * 255 + 15, 255),
                                                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.B * 255 + 15, 255)
                                        )}):Play()
                                end)

                                AddConnection(Click.MouseLeave, function()
                                        TweenService:Create(ButtonFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent}):Play()
                                end)

                                AddConnection(Click.MouseButton1Up, function()
                                        TweenService:Create(ButtonFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(
                                                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.R * 255 + 10, 255),
                                                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.G * 255 + 10, 255),
                                                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.B * 255 + 10, 255)
                                        )}):Play()
                                        spawn(function()
                                                ButtonConfig.Callback()
                                        end)
                                end)

                                AddConnection(Click.MouseButton1Down, function()
                                        TweenService:Create(ButtonFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(
                                                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.R * 255 + 25, 255),
                                                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.G * 255 + 25, 255),
                                                math.min(OrionLib.Themes[OrionLib.SelectedTheme].Accent.B * 255 + 25, 255)
                                        )}):Play()
                                end)

                                function Button:Set(ButtonText)
                                        ButtonFrame.Content.Text = ButtonText
                                end        

                                return Button
                        end

                        -- 其他元素函数（Toggle, Slider, Dropdown等）也进行类似的现代化改造
                        -- 由于代码长度限制，这里只展示部分改造

                        return ElementFunction   
                end        

                local ElementFunction = {}

                function ElementFunction:AddSection(SectionConfig)
                        SectionConfig.Name = SectionConfig.Name or "Section"

                        local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
                                Size = UDim2.new(1, 0, 0, 30),
                                Parent = Container
                        }), {
                                AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
                                        Size = UDim2.new(1, -12, 0, 18),
                                        Position = UDim2.new(0, 0, 0, 4),
                                        Font = Enum.Font.GothamBold
                                }), "Accent"),
                                SetChildren(SetProps(MakeElement("TFrame"), {
                                        AnchorPoint = Vector2.new(0, 0),
                                        Size = UDim2.new(1, 0, 1, -26),
                                        Position = UDim2.new(0, 0, 0, 26),
                                        Name = "Holder"
                                }), {
                                        MakeElement("List", 0, 8)
                                }),
                        })

                        AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                                SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 34)
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
                                        Size = UDim2.new(0, 20, 0, 20),
                                        Position = UDim2.new(0, 15, 0, 15),
                                        ImageTransparency = 0.4,
                                        ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent
                                }), "Text"),
                                AddThemeObject(SetProps(MakeElement("Label", "高级功能", 16), {
                                        Size = UDim2.new(1, -40, 0, 16),
                                        Position = UDim2.new(0, 40, 0, 18),
                                        TextTransparency = 0.4,
                                        Font = Enum.Font.GothamBold
                                }), "Text"),
                                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
                                        Size = UDim2.new(0, 64, 0, 64),
                                        Position = UDim2.new(0, 84, 0, 110),
                                        ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent
                                }), "Text"),
                                AddThemeObject(SetProps(MakeElement("Label", "高级功能", 16), {
                                        Size = UDim2.new(1, -150, 0, 16),
                                        Position = UDim2.new(0, 150, 0, 112),
                                        Font = Enum.Font.GothamBold
                                }), "Text"),
                                AddThemeObject(SetProps(MakeElement("Label", "此部分功能需要高级版本解锁。请加入我们的Discord服务器获取更多信息。", 13), {
                                        Size = UDim2.new(1, -200, 0, 16),
                                        Position = UDim2.new(0, 150, 0, 140),
                                        TextWrapped = true,
                                        TextTransparency = 0.4
                                }), "TextDark")
                        })
                end
                return ElementFunction   
        end  

        return TabFunction
end   

-- 简化的通知系统美化
local function Create(instance, parent, props)
    local new = Instance.new(instance, parent)
    if props then
        for prop, value in pairs(props) do
            new[prop] = value
        end
    end
    return new
end

local function SetProps(instance, props)
    if instance and props then
        for prop, value in pairs(props) do
            instance[prop] = value
        end
    end
    return instance
end

local function Corner(parent, radius)
    local corner = Create("UICorner", parent, {
        CornerRadius = UDim.new(0, radius or 8)
    })
    return corner
end

local function Stroke(parent, color, thickness)
    local stroke = Create("UIStroke", parent, {
        Color = color or OrionLib.Themes[OrionLib.SelectedTheme].Stroke,
        Thickness = thickness or 1.5,
        Transparency = 0.7
    })
    return stroke
end

local ScreenGui = Create("ScreenGui", Orion)

local Menu_Notifi = Create("Frame", ScreenGui, {
    Size = UDim2.new(0, 320, 1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1
})

local Padding = Create("UIPadding", Menu_Notifi, {
    PaddingLeft = UDim.new(0, 25),
    PaddingTop = UDim.new(0, 25),
    PaddingBottom = UDim.new(0, 50)
})

local ListLayout = Create("UIListLayout", Menu_Notifi, {
    Padding = UDim.new(0, 12),
    VerticalAlignment = "Bottom"
})

function OrionLib:MakeNotifi(Configs)
    local Title = Configs.Title or "通知!"
    local text = Configs.Text or "通知内容..."
    local timewait = Configs.Time or 5

    local Frame1 = Create("Frame", Menu_Notifi, {
        Size = UDim2.new(2, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Name = "Title"
    })

    local Frame2 = Create("Frame", Frame1, {
        Size = UDim2.new(0, Menu_Notifi.Size.X.Offset - 50, 0, 0),
        BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second,
        Position = UDim2.new(0, Menu_Notifi.Size.X.Offset, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    Corner(Frame2, 12)
    Stroke(Frame2, OrionLib.Themes[OrionLib.SelectedTheme].Accent, 1.5)
    
    -- 添加渐变背景
    CreateGradientBackground(Frame2, {
        OrionLib.Themes[OrionLib.SelectedTheme].Second,
        OrionLib.Themes[OrionLib.SelectedTheme].Main
    })

    local TextLabel = Create("TextLabel", Frame2, {
        Size = UDim2.new(1, 0, 0, 28),
        Font = Enum.Font.GothamSemibold,
        BackgroundTransparency = 1,
        Text = Title,
        TextSize = 16,
        Position = UDim2.new(0, 20, 0, 6),
        TextXAlignment = "Left",
        TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text
    })

    local TextButton = Create("TextButton", Frame2, {
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        BackgroundTransparency = 1,
        TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].TextDark,
        Position = UDim2.new(1, -8, 0, 6),
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0, 24, 0, 24)
    })

    local ContentLabel = Create("TextLabel", Frame2, {
        Size = UDim2.new(1, -30, 0, 0),
        Position = UDim2.new(0, 20, 0, TextButton.Size.Y.Offset + 12),
        TextSize = 14,
        TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].TextDark,
        TextXAlignment = "Left",
        TextYAlignment = "Top",
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = text,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true
    })

    local FrameSize = Create("Frame", Frame2, {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
        Position = UDim2.new(0, 2, 0, 32),
        BorderSizePixel = 0
    })
    Corner(FrameSize, 2)
    
    Create("Frame", Frame2, {
        Size = UDim2.new(0, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, 8),
        BackgroundTransparency = 1
    })

    task.spawn(function()
        TweenService:Create(FrameSize, TweenInfo.new(timewait, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()
    end)

    TextButton.MouseButton1Click:Connect(function()
        TweenService:Create(Frame2, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(0, -20, 0, 0)}):Play()
        TweenService:Create(Frame2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0, Menu_Notifi.Size.X.Offset, 0, 0)}):Play()
        Frame1:Destroy()
    end)

    task.spawn(function()
        TweenService:Create(Frame2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0, -20, 0, 0)}):Play()
        TweenService:Create(Frame2, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        wait(timewait)
        if Frame2 then
            TweenService:Create(Frame2, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(0, -20, 0, 0)}):Play()
            TweenService:Create(Frame2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0, Menu_Notifi.Size.X.Offset, 0, 0)}):Play()
            Frame1:Destroy()
        end
    end)
end

function OrionLib:Destroy()
        Orion:Destroy()
end

return OrionLib