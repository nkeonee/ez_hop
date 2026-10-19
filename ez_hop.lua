--[[
    EZ HOP — Custom UI (ТЕЛЕПОРТ ЧЕРЕЗ ВЫПАДАЮЩИЙ СПИСОК)
]]

local EZHOP = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

local Theme = {
    Accent = Color3.fromRGB(138, 116, 255),
    AccentDark = Color3.fromRGB(96, 76, 214),
    Bg = Color3.fromRGB(14, 14, 20),
    Panel = Color3.fromRGB(22, 24, 32),
    Item = Color3.fromRGB(30, 33, 43),
    Stroke = Color3.fromRGB(50, 55, 70),
    Text = Color3.fromRGB(240, 240, 250),
    SubText = Color3.fromRGB(150, 150, 165),
}

local function Create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(radius, parent)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function Stroke(color, transparency, parent)
    return Create("UIStroke", { Color = color, Transparency = transparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, parent)
end

local function Tween(obj, props, time, style, dir)
    TweenService:Create(obj, TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

-- ====== УВЕДОМЛЕНИЯ ======
local notifGui = Create("ScreenGui", { Name = "EZHOP_Notifs", IgnoreGuiInset = true, ResetOnSpawn = false, Parent = CoreGui })
local notifContainer = Create("Frame", { Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(1, -320, 0, 20), BackgroundTransparency = 1, Parent = notifGui })
Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top, HorizontalAlignment = Enum.HorizontalAlignment.Right }, notifContainer)

function EZHOP:Notify(title, text, duration)
    if not notifGui or not notifGui.Parent then return end
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.1,
        BorderSizePixel = 0, Parent = notifContainer
    })
    Corner(8, frame)
    Stroke(Theme.Accent, 0.3, frame)
    local bar = Create("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = frame })
    Corner(8, bar)
    Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -20, 0, 16), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = title or "EZ HOP", Parent = frame })
    Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 28), Size = UDim2.new(1, -20, 0, 20), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Text = text or "", Parent = frame })
    frame.Position = UDim2.new(1, 50, 0, 0)
    Tween(frame, { Position = UDim2.new(0, 0, 0, 0) }, 0.25)
    task.delay(duration or 3, function()
        if frame and frame.Parent then
            Tween(frame, { Position = UDim2.new(1, 50, 0, 0) }, 0.25)
            task.wait(0.3)
            if frame and frame.Parent then frame:Destroy() end
        end
    end)
end

-- ====== КОМПОНЕНТЫ ======
local UIComponents = {}

function UIComponents.Toggle(parent, cfg)
    local row = Create("Frame", { Size = UDim2.new(1, -16, 0, 26), BackgroundTransparency = 1, Parent = parent })
    Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -50, 1, 0), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Name or "Toggle", Parent = row })
    local bg = Create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(36, 20), BackgroundColor3 = Theme.Item, BorderSizePixel = 0, Parent = row })
    Corner(10, bg)
    local dot = Create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.3, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Theme.SubText, BorderSizePixel = 0, Parent = bg })
    Corner(7, dot)
    local state = cfg.Default or false
    local function render()
        Tween(bg, { BackgroundColor3 = state and Theme.Accent or Theme.Item })
        Tween(dot, { Position = state and UDim2.new(0.7, 0, 0.5, 0) or UDim2.new(0.3, 0, 0.5, 0), BackgroundColor3 = state and Theme.Text or Theme.SubText })
    end
    render()
    Create("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", Parent = row }).MouseButton1Click:Connect(function()
        state = not state
        render()
        if cfg.Callback then task.spawn(cfg.Callback, state) end
    end)
    return { Set = function(v) state = v; render() end }
end

function UIComponents.Slider(parent, cfg)
    local val = cfg.Default or cfg.Min or 0
    local row = Create("Frame", { Size = UDim2.new(1, -16, 0, 36), BackgroundTransparency = 1, Parent = parent })
    Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -60, 0, 16), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Name or "Slider", Parent = row })
    local valLabel = Create("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 0), Size = UDim2.fromOffset(50, 16), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right, Text = tostring(val) .. (cfg.Type or ""), Parent = row })
    local bar = Create("Frame", { Position = UDim2.fromOffset(6, 24), Size = UDim2.new(1, -12, 0, 6), BackgroundColor3 = Theme.Item, BorderSizePixel = 0, Parent = row })
    Corner(3, bar)
    local fill = Create("Frame", { Size = UDim2.fromScale((val - cfg.Min) / (cfg.Max - cfg.Min), 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = bar })
    Corner(3, fill)
    local dragging = false
    local btn = Create("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", Parent = bar })
    local function update(x)
        local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        val = cfg.Min + ((cfg.Max - cfg.Min) * a)
        if cfg.Rounding then val = math.floor(val * 10^cfg.Rounding + 0.5) / 10^cfg.Rounding end
        fill.Size = UDim2.fromScale((val - cfg.Min) / (cfg.Max - cfg.Min), 1)
        valLabel.Text = tostring(val) .. (cfg.Type or "")
        if cfg.Callback then cfg.Callback(val) end
    end
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; update(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

function UIComponents.Button(parent, cfg)
    local btn = Create("TextButton", { Size = UDim2.new(1, -16, 0, 28), BackgroundColor3 = Theme.Item, BorderSizePixel = 0, Text = "", Parent = parent })
    Corner(6, btn)
    Stroke(Theme.Stroke, 0.5, btn)
    local lbl = Create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text, Text = cfg.Name or "Button", Parent = btn })
    btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = Theme.AccentDark }) end)
    btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = Theme.Item }) end)
    btn.MouseButton1Click:Connect(function() if cfg.Callback then task.spawn(cfg.Callback) end end)
    return { SetText = function(t) lbl.Text = t end }
end

function UIComponents.Dropdown(parent, cfg)
    local current = cfg.Default or (cfg.Values and cfg.Values[1]) or "None"
    local isOpen = false
    
    local row = Create("Frame", { Size = UDim2.new(1, -16, 0, 26), BackgroundTransparency = 1, Parent = parent, ClipsDescendants = true })
    
    local btn = Create("TextButton", { Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -12, 0, 26), BackgroundColor3 = Theme.Item, BorderSizePixel = 0, Text = "", Parent = row })
    Corner(6, btn)
    Stroke(Theme.Stroke, 0.5, btn)
    local btnLabel = Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -20, 1, 0), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Name .. ": " .. tostring(current), Parent = btn })
    
    local list = Create("Frame", { Position = UDim2.fromOffset(6, 30), Size = UDim2.new(1, -12, 0, 0), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, ClipsDescendants = true, Visible = false, Parent = row })
    Corner(6, list)
    Stroke(Theme.Stroke, 0.5, list)
    local listLayout = Create("UIListLayout", { Padding = UDim.new(0, 2) }, list)

    -- Специальный рендер для игроков (с аватарками)
    local function refreshPlayers()
        for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                local item = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Item, BackgroundTransparency = 0.5, BorderSizePixel = 0, Text = "", Parent = list })
                Corner(4, item)
                
                -- Аватарка (слева)
                local avatar = Create("ImageLabel", {
                    Size = UDim2.fromOffset(24, 24),
                    Position = UDim2.fromOffset(4, 4),
                    BackgroundTransparency = 1,
                    Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=48&h=48",
                    Parent = item
                })
                Corner(12, avatar)

                -- Ник + Дисплей (справа от аватарки)
                local text = plr.Name
                if plr.DisplayName ~= plr.Name then
                    text = text .. " (" .. plr.DisplayName .. ")"
                end

                Create("TextLabel", { 
                    BackgroundTransparency = 1, 
                    Position = UDim2.fromOffset(34, 0), 
                    Size = UDim2.new(1, -34, 1, 0), 
                    Font = Enum.Font.Gotham, 
                    TextSize = 12, 
                    TextColor3 = Theme.Text, 
                    TextXAlignment = Enum.TextXAlignment.Left, 
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Text = text, 
                    Parent = item 
                })
                
                item.MouseButton1Click:Connect(function()
                    local char = Players.LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local targetChar = plr.Character
                    local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                    
                    if hrp and targetHrp then
                        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3) -- Телепорт за спину на 3 стада
                        EZHOP:Notify("Teleport", "Teleported to " .. plr.Name)
                        btn.MouseButton1Click:Fire() -- Закрываем список
                    else
                        EZHOP:Notify("Teleport", "Player is dead or loading")
                    end
                end)
            end
        end
    end

    local function refreshColors()
        for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, v in ipairs(cfg.Values or {}) do
            local item = Create("TextButton", { Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = Theme.Item, BackgroundTransparency = 0.5, BorderSizePixel = 0, Text = "", Parent = list })
            Corner(4, item)
            Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = current == v and Theme.Accent or Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(v), Parent = item })
            item.MouseButton1Click:Connect(function()
                current = v
                btnLabel.Text = cfg.Name .. ": " .. tostring(current)
                if cfg.Callback then task.spawn(cfg.Callback, current) end
                btn.MouseButton1Click:Fire()
            end)
        end
    end

    if cfg.IsPlayers then
        refreshPlayers()
    else
        refreshColors()
    end

    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetHeight = 0
        
        if isOpen then
            if cfg.IsPlayers then
                -- Пересчитываем список игроков при каждом открытии
                refreshPlayers()
                targetHeight = math.min(#Players:GetPlayers() * 34 + 4, 200)
            else
                targetHeight = math.min(#(cfg.Values or {}) * 24 + 4, 120)
            end
            list.Visible = true
        end
        
        Tween(row, { Size = UDim2.new(1, -16, 0, 26 + targetHeight + 4) }, 0.2)
        Tween(list, { Size = UDim2.new(1, -12, 0, targetHeight) }, 0.2)
        
        if not isOpen then
            task.wait(0.2)
            list.Visible = false
        end
    end)
end

-- ====== ОКНО ======
function EZHOP:CreateWindow()
    local screen = Create("ScreenGui", { Name = "EZHOP_UI", IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Global, Parent = CoreGui })

    local frame = Create("Frame", {
        Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(580, 420),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Parent = screen
    })
    Corner(12, frame)
    Stroke(Theme.AccentDark, 0.4, frame)

    local header = Create("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = frame })
    Corner(12, header)
    Create("Frame", { Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = header })

    Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -60, 1, 0), Font = Enum.Font.GothamBlack, TextSize = 18, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left, Text = "EZ HOP", Parent = header })

    local close = Create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(26, 26), BackgroundColor3 = Theme.Item, BorderSizePixel = 0, Text = "X", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.SubText, Parent = header })
    Corner(6, close)

    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    local sidebar = Create("Frame", { Position = UDim2.fromOffset(0, 44), Size = UDim2.new(0, 140, 1, -44), BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = frame })
    Corner(12, sidebar)

    local tabsList = Create("ScrollingFrame", { Position = UDim2.fromOffset(0, 10), Size = UDim2.new(1, 0, 1, -20), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, Parent = sidebar })
    Create("UIListLayout", { Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center }, tabsList)

    local content = Create("Frame", { Position = UDim2.fromOffset(140, 44), Size = UDim2.new(1, -140, 1, -44), BackgroundTransparency = 1, Parent = frame })

    local window = { Screen = screen, Frame = frame, Tabs = {}, Visible = true }

    function window:Toggle()
        self.Visible = not self.Visible
        self.Screen.Enabled = self.Visible
    end

    close.MouseButton1Click:Connect(function()
        if _G.EZHOP_DestroyAll then _G.EZHOP_DestroyAll() end
        if screen then screen:Destroy() end
        if notifGui then notifGui:Destroy() end
        EZHOP.Active = false
    end)

    function window:AddTab(name)
        local btn = Create("TextButton", { Size = UDim2.new(1, -16, 0, 32), BackgroundColor3 = Theme.Item, BackgroundTransparency = 0.5, BorderSizePixel = 0, Text = "", Parent = tabsList })
        Corner(6, btn)
        local btnLabel = Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Text = name, Parent = btn })

        local page = Create("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, Visible = false, Parent = content })
        Create("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center }, page)

        local tab = { Btn = btn, Page = page, Label = btnLabel }
        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Page.Visible = false
                Tween(t.Btn, { BackgroundTransparency = 0.5 })
                t.Label.TextColor3 = Theme.SubText
            end
            page.Visible = true
            Tween(btn, { BackgroundTransparency = 0 })
            btnLabel.TextColor3 = Theme.Accent
        end)
        table.insert(self.Tabs, tab)

        function tab:AddSection(sectionName)
            local sectionFrame = Create("Frame", { Size = UDim2.new(1, -16, 0, 30), BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = page })
            Corner(8, sectionFrame)
            Create("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -20, 0, 24), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left, Text = sectionName, Parent = sectionFrame })

            local items = Create("Frame", { Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = sectionFrame })
            local layout = Create("UIListLayout", { Padding = UDim.new(0, 4) }, items)

            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                items.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
                sectionFrame.Size = UDim2.new(1, -16, 0, layout.AbsoluteContentSize.Y + 38)
            end)

            return {
                AddToggle = function(_, cfg) return UIComponents.Toggle(items, cfg) end,
                AddSlider = function(_, cfg) return UIComponents.Slider(items, cfg) end,
                AddButton = function(_, cfg) return UIComponents.Button(items, cfg) end,
                AddDropdown = function(_, cfg) return UIComponents.Dropdown(items, cfg) end,
            }
        end

        if #self.Tabs == 1 then
            page.Visible = true
            Tween(btn, { BackgroundTransparency = 0 })
            btnLabel.TextColor3 = Theme.Accent
        end
        return tab
    end

    return window
end

-- ================================================================
-- ==================== ЛОГИКА EZ HOP =============================
-- ================================================================

local CONFIG = {
    Bhop = false,
    Blur = false,
    BlurAmount = 30,
    BlurMax = 40,
    BlurSmooth = 0.35,
    JumpCircle = false,
    JR_DECAL = "rbxassetid://71544661109805",
    JR_COLOR = Color3.fromRGB(255, 255, 255),
    JR_START_SIZE = 3,
    JR_PART_SIZE = 15,
    JR_LIFETIME = 2,
    JR_COOLDOWN = 0.15,
    JR_TWEEN_TIME = 2,
}

EZHOP.Active = true

-- ---------- BLUR ----------
local motionBlur = nil
local lastVector = nil
local currentSize = 0

local function ensureBlur()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    if not motionBlur or motionBlur.Parent ~= cam then
        if motionBlur then motionBlur:Destroy() end
        motionBlur = Instance.new("BlurEffect")
        motionBlur.Name = "EzHopBlur"
        motionBlur.Size = 0
        motionBlur.Parent = cam
    end
end

-- ---------- JUMP CIRCLE ----------
local jumpConnections = {}
local lastRingTime = 0

local function createJumpRing(character)
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if tick() - lastRingTime < CONFIG.JR_COOLDOWN then return end
    lastRingTime = tick()

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { character }

    local hit = Workspace:Raycast(hrp.Position, Vector3.new(0, -20, 0), rayParams)
    if not hit then return end

    local part = Instance.new("Part")
    part.Name = "EzJumpRing"
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Transparency = 1
    part.Size = Vector3.new(CONFIG.JR_PART_SIZE, 0.05, CONFIG.JR_PART_SIZE)
    part.CFrame = CFrame.new(hit.Position + Vector3.new(0, 0.04, 0))
    part.Parent = Workspace

    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Top
    surfaceGui.AlwaysOnTop = true
    surfaceGui.LightInfluence = 0
    surfaceGui.PixelsPerStud = 50
    surfaceGui.Parent = part

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.BackgroundTransparency = 1
    imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    imageLabel.Position = UDim2.fromScale(0.5, 0.5)
    imageLabel.Size = UDim2.fromScale(CONFIG.JR_START_SIZE / CONFIG.JR_PART_SIZE, CONFIG.JR_START_SIZE / CONFIG.JR_PART_SIZE)
    imageLabel.Image = CONFIG.JR_DECAL
    imageLabel.ImageColor3 = CONFIG.JR_COLOR
    imageLabel.ImageTransparency = 0
    imageLabel.ScaleType = Enum.ScaleType.Stretch
    imageLabel.Parent = surfaceGui

    local ti = TweenInfo.new(CONFIG.JR_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    pcall(function() TweenService:Create(imageLabel, ti, { Size = UDim2.fromScale(1, 1) }):Play() end)
    pcall(function() TweenService:Create(imageLabel, ti, { ImageTransparency = 1 }):Play() end)

    Debris:AddItem(part, CONFIG.JR_LIFETIME + 0.1)
end

local function hookJumpCircle(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    table.insert(jumpConnections, humanoid.StateChanged:Connect(function(_, newState)
        if not CONFIG.JumpCircle then return end
        if newState == Enum.HumanoidStateType.Jumping then
            pcall(createJumpRing, character)
        end
    end))
end

local function setJumpCircle(on)
    CONFIG.JumpCircle = on
    for _, c in ipairs(jumpConnections) do pcall(function() c:Disconnect() end) end
    jumpConnections = {}
    if not on then return end
    hookJumpCircle(Players.LocalPlayer.Character)
    table.insert(jumpConnections, Players.LocalPlayer.CharacterAdded:Connect(function(character)
        if CONFIG.JumpCircle then
            task.wait(0.5)
            hookJumpCircle(character)
        end
    end))
end

-- ---------- SHADERS (ПОЛНОЕ УДАЛЕНИЕ) ----------
local shaderState = {
    DreamyNight = { objects = {}, saved = nil },
    PaleFrost  = { objects = {}, saved = nil },
    Tokyowami  = { objects = {}, saved = nil },
}

local PALE_KEYS = {
    "ClockTime", "GeographicLatitude", "Brightness", "Ambient", "OutdoorAmbient",
    "FogColor", "FogStart", "FogEnd", "EnvironmentDiffuseScale", "EnvironmentSpecularScale",
    "GlobalShadows", "ExposureCompensation",
}

local TOKYO_KEYS = {
    "Brightness", "ClockTime", "FogColor", "FogEnd", "FogStart", "Ambient",
    "OutdoorAmbient", "ColorShift_Top", "ColorShift_Bottom", "ExposureCompensation", "ShadowSoftness",
}

local function clearShader(name)
    local st = shaderState[name]
    for _, obj in ipairs(st.objects) do
        pcall(function() obj:Destroy() end)
    end
    st.objects = {}
    
    if st.saved then
        if name == "DreamyNight" then
            pcall(function()
                Lighting.ClockTime = st.saved.ClockTime
                Lighting.Brightness = st.saved.Brightness
            end)
        else
            for k, v in pairs(st.saved) do
                pcall(function() Lighting[k] = v end)
            end
        end
        st.saved = nil
    end
end

local function applyShader(name)
    local st = shaderState[name]
    clearShader(name)
    
    if name == "DreamyNight" then
        st.saved = { ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness }
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.5
        st.objects = {
            Create("BlurEffect", { Size = 6, Parent = Lighting }),
            Create("BloomEffect", { Intensity = 1.6, Size = 90, Threshold = 1.4, Parent = Lighting }),
            Create("ColorCorrectionEffect", { Brightness = 0.15, Contrast = -0.1, Saturation = 0.25, TintColor = Color3.fromRGB(210, 220, 255), Parent = Lighting }),
            Create("SunRaysEffect", { Intensity = 0.05, Spread = 0.6, Parent = Lighting }),
            Create("Atmosphere", { Density = 0.45, Offset = 0.1, Color = Color3.fromRGB(180, 190, 255), Decay = Color3.fromRGB(120, 130, 180), Glare = 0.2, Haze = 2, Parent = Lighting }),
        }
    elseif name == "PaleFrost" then
        st.saved = {}
        for _, k in ipairs(PALE_KEYS) do st.saved[k] = Lighting[k] end
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") or child:IsA("Atmosphere") then 
                pcall(function() child.Enabled = false end) 
            end
        end
        Lighting.ClockTime = 0
        Lighting.GeographicLatitude = 85
        Lighting.Brightness = 1.1
        Lighting.Ambient = Color3.fromRGB(150, 170, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(190, 210, 235)
        Lighting.FogColor = Color3.fromRGB(240, 245, 255)
        Lighting.FogStart = 120
        Lighting.FogEnd = 800
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
        Lighting.GlobalShadows = true
        Lighting.ExposureCompensation = 0.6
        st.objects = {
            Create("Atmosphere", { Density = 0.8, Offset = 0.9, Color = Color3.fromRGB(235, 242, 255), Decay = Color3.fromRGB(190, 205, 225), Glare = 0.05, Haze = 10, Parent = Lighting }),
            Create("ColorCorrectionEffect", { Brightness = 0.02, Contrast = 0.15, Saturation = -0.65, TintColor = Color3.fromRGB(235, 242, 255), Parent = Lighting }),
            Create("BloomEffect", { Intensity = 0.85, Size = 56, Threshold = 0.7, Parent = Lighting }),
            Create("DepthOfFieldEffect", { FarIntensity = 0.5, FocusDistance = 50, InFocusRadius = 30, NearIntensity = 0, Parent = Lighting }),
            Create("SunRaysEffect", { Intensity = 0.12, Spread = 0.85, Parent = Lighting }),
        }
    elseif name == "Tokyowami" then
        st.saved = {}
        for _, k in ipairs(TOKYO_KEYS) do st.saved[k] = Lighting[k] end
        Lighting.Brightness = 2.14
        Lighting.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
        Lighting.ColorShift_Top = Color3.fromRGB(240, 127, 14)
        Lighting.OutdoorAmbient = Color3.fromRGB(34, 0, 49)
        Lighting.ClockTime = 6.7
        Lighting.FogColor = Color3.fromRGB(94, 76, 106)
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        Lighting.ExposureCompensation = 0.24
        Lighting.ShadowSoftness = 0
        Lighting.Ambient = Color3.fromRGB(59, 33, 27)
        st.objects = {
            Create("BloomEffect", { Intensity = 0.1, Threshold = 0, Size = 100, Parent = Lighting }),
            Create("ColorCorrectionEffect", { Saturation = 0.05, TintColor = Color3.fromRGB(255, 224, 219), Parent = Lighting }),
            Create("SunRaysEffect", { Intensity = 0.05, Parent = Lighting }),
            Create("BlurEffect", { Size = 1, Parent = Lighting }),
            Create("Sky", {
                SkyboxUp = "rbxassetid://323493360", SkyboxLf = "rbxassetid://323494252",
                SkyboxBk = "rbxassetid://323494035", SkyboxFt = "rbxassetid://323494130",
                SkyboxDn = "rbxassetid://323494368", SkyboxRt = "rbxassetid://323494067",
                SunAngularSize = 14, Parent = Lighting,
            }),
        }
    end
end

-- ---------- BHOP ----------
local function getHumanoid()
    local char = Players.LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function autoBhop()
    if not CONFIG.Bhop then return end
    local humanoid = getHumanoid()
    if humanoid and humanoid.Health > 0
        and humanoid.FloorMaterial ~= Enum.Material.Air
        and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- ---------- BLUR UPDATE ----------
local function updateBlur(dt)
    if not CONFIG.Blur then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    if not motionBlur or motionBlur.Parent ~= cam then ensureBlur() end
    if not motionBlur then return end

    local look = cam.CFrame.LookVector
    if not lastVector then lastVector = look; return end

    local magnitude = (look - lastVector).Magnitude
    local target = math.abs(magnitude) * CONFIG.BlurAmount * 5 / 2
    target = math.min(target, CONFIG.BlurMax)
    currentSize = currentSize + (target - currentSize) * CONFIG.BlurSmooth
    motionBlur.Size = currentSize
    lastVector = look
end

-- ================================================================
-- ==================== ФУНКЦИЯ УНИЧТОЖЕНИЯ ========================
-- ================================================================
_G.EZHOP_DestroyAll = function()
    CONFIG.Bhop = false
    CONFIG.Blur = false
    setJumpCircle(false)
    if motionBlur then motionBlur:Destroy(); motionBlur = nil end
    clearShader("DreamyNight")
    clearShader("PaleFrost")
    clearShader("Tokyowami")
end

-- ================================================================
-- ==================== ИНТРО =====================================
-- ================================================================
local INTRO_TITLE = "EZ HOP"
local introScreen = Create("ScreenGui", { Name = "EZHOP_Intro", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 9999, ZIndexBehavior = Enum.ZIndexBehavior.Global, Parent = CoreGui })
local introBg = Create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = introScreen })
local introHolder = Create("Frame", { Size = UDim2.fromOffset(0, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Parent = introBg })
Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, introHolder)

local introLetters = {}
for i = 1, #INTRO_TITLE do
    table.insert(introLetters, Create("TextLabel", {
        Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1,
        Text = INTRO_TITLE:sub(i, i), TextColor3 = Theme.Text, TextSize = 72,
        Font = Enum.Font.GothamBlack, TextTransparency = 1, Parent = introHolder,
    }))
end

local function playIntro()
    Tween(introBg, { BackgroundTransparency = 0 }, 0.4)
    task.wait(0.35)
    for _, letter in ipairs(introLetters) do
        letter.Size = UDim2.fromOffset(70, 90)
        Tween(letter, { TextTransparency = 0 }, 0.35, Enum.EasingStyle.Back)
        task.wait(0.08)
    end
    task.wait(1.6)
    for i, letter in ipairs(introLetters) do
        local angle = math.rad((i / #introLetters) * 360 + math.random(-20, 20))
        local dist = math.random(200, 360)
        Tween(letter, {
            Position = letter.Position + UDim2.fromOffset(math.cos(angle) * dist, math.sin(angle) * dist),
            Rotation = math.random(-120, 120),
            TextTransparency = 1,
            TextSize = 30,
        }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    end
    task.wait(0.3)
    Tween(introBg, { BackgroundTransparency = 1 }, 0.5)
    task.wait(0.55)
    introScreen:Destroy()
end

-- ================================================================
-- ==================== ЗАПУСК ====================================
-- ================================================================
task.spawn(function()
    playIntro()

    local Win = EZHOP:CreateWindow()

    -- MAIN
    local tabMain = Win:AddTab("Main")
    local secMain = tabMain:AddSection("Auto Bhop")
    secMain:AddToggle({
        Name = "Auto Bhop", Default = false,
        Callback = function(v)
            CONFIG.Bhop = v
            EZHOP:Notify("Auto Bhop", v and "Enabled" or "Disabled")
        end,
    })

    -- ДОБАВЛЯЕМ ТЕЛЕПОРТ В MAIN
    local secTP = tabMain:AddSection("Teleport")
    secTP:AddDropdown({
        Name = "Player List",
        IsPlayers = true, -- Включает режим игроков (с аватарками)
    })

    -- VISUALS
    local tabVisuals = Win:AddTab("Visuals")
    local secBlur = tabVisuals:AddSection("Motion Blur")
    secBlur:AddToggle({
        Name = "Motion Blur", Default = false,
        Callback = function(v)
            CONFIG.Blur = v
            if v then ensureBlur() else
                if motionBlur then motionBlur:Destroy(); motionBlur = nil end
                currentSize = 0
            end
            EZHOP:Notify("Motion Blur", v and "Enabled" or "Disabled")
        end,
    })
    secBlur:AddSlider({ Name = "Blur Amount", Min = 1, Max = 100, Default = 30, Rounding = 0, Callback = function(v) CONFIG.BlurAmount = v end })
    secBlur:AddSlider({ Name = "Blur Max", Min = 5, Max = 100, Default = 40, Rounding = 0, Callback = function(v) CONFIG.BlurMax = v end })

    local secJump = tabVisuals:AddSection("Jump Circle")
    secJump:AddToggle({
        Name = "Jump Circle", Default = false,
        Callback = function(v)
            setJumpCircle(v)
            EZHOP:Notify("Jump Circle", v and "Enabled" or "Disabled")
        end,
    })

    local colorNames = { "White", "Cyan", "Red", "Green", "Yellow", "Purple", "Pink", "Orange" }
    local colorValues = {
        White = Color3.fromRGB(255, 255, 255), Cyan = Color3.fromRGB(120, 200, 255),
        Red = Color3.fromRGB(255, 80, 80), Green = Color3.fromRGB(80, 255, 120),
        Yellow = Color3.fromRGB(255, 200, 60), Purple = Color3.fromRGB(200, 100, 255),
        Pink = Color3.fromRGB(255, 120, 200), Orange = Color3.fromRGB(255, 140, 40),
    }
    
    secJump:AddDropdown({
        Name = "Ring Color",
        Values = colorNames,
        Default = "White",
        Callback = function(v)
            CONFIG.JR_COLOR = colorValues[v] or Color3.new(1, 1, 1)
            EZHOP:Notify("Jump Circle", "Color: " .. v)
        end,
    })

    secJump:AddSlider({ Name = "Ring Size", Min = 1, Max = 10, Default = 3, Rounding = 0, Callback = function(v) CONFIG.JR_START_SIZE = v end })
    secJump:AddSlider({ Name = "Ring Lifetime", Min = 0.5, Max = 5, Default = 2, Rounding = 1, Callback = function(v) CONFIG.JR_LIFETIME = v end })

    -- SHADERS
    local tabShaders = Win:AddTab("Shaders")
    local secShaders = tabShaders:AddSection("Visual Shaders")
    local shaderToggles = {}
    local activeShader = nil

    local function setShaderToggle(name, on)
        if activeShader and activeShader ~= name then
            local prev = shaderToggles[activeShader]
            if prev then prev.Set(false) end
            clearShader(activeShader)
        end
        if on then
            activeShader = name
            applyShader(name)
        else
            activeShader = nil
            clearShader(name)
        end
    end

    shaderToggles.DreamyNight = secShaders:AddToggle({
        Name = "Dreamy Night Shader", Default = false,
        Callback = function(v) setShaderToggle("DreamyNight", v) end,
    })

    shaderToggles.PaleFrost = secShaders:AddToggle({
        Name = "Pale Frost Shader", Default = false,
        Callback = function(v) setShaderToggle("PaleFrost", v) end,
    })

    shaderToggles.Tokyowami = secShaders:AddToggle({
        Name = "Tokyowami Shader", Default = false,
        Callback = function(v) setShaderToggle("Tokyowami", v) end,
    })

    -- SETTINGS
    local tabSettings = Win:AddTab("Settings")
    local secSettings = tabSettings:AddSection("Actions")
    secSettings:AddButton({ Name = "Hide GUI (RightCtrl)", Callback = function() Win:Toggle() end })
    secSettings:AddButton({
        Name = "Destroy All Effects",
        Callback = function()
            _G.EZHOP_DestroyAll()
            for name, data in pairs(shaderToggles) do
                data.Set(false)
            end
            activeShader = nil
            EZHOP:Notify("EZ HOP", "All effects destroyed")
        end,
    })

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            if EZHOP.Active and Win.Screen and Win.Screen.Parent then
                Win:Toggle()
            end
        end
    end)

    EZHOP:Notify("EZ HOP", "Loaded. RightCtrl to hide.", 4)
end)

RunService.RenderStepped:Connect(function(dt)
    if not EZHOP.Active then return end
    autoBhop()
    updateBlur(dt)
end)
