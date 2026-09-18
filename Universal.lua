-- Universal Script v5 (Stable)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    FlySpeed = 60,
    WalkSpeed = 16,
    ESP = false,
    Noclip = false,
    InfiniteJump = false,
    Aimbot = false,
    Fullbright = false,
    GodMode = false
}

-- Anti AFK
task.spawn(function()
    local VU = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end)

-- Parent for GUI
local function GetParent()
    local success, result = pcall(gethui)
    if success and result then return result end
    return game:GetService("CoreGui")
end

-- GUI
local parent = GetParent()
local old = parent:FindFirstChild("UniversalV5")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parent

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 390)
Main.Position = UDim2.new(0.5, -130, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 34)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
Title.Text = "Universal Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -31, 0, 3)
Close.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 13
Close.Parent = Main
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -10, 1, -42)
Container.Position = UDim2.new(0, 5, 0, 38)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 3
Container.CanvasSize = UDim2.new(0, 0, 0, 480)
Container.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 5)
List.Parent = Container

local function Toggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 29)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = name .. "  [OFF]"
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = Container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. (state and "  [ON]" or "  [OFF]")
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 100, 55) or Color3.fromRGB(35, 35, 50)
        callback(state)
    end)
end

local function Button(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 29)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = Container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

local Flying = false
local BV, BG

Toggle("Fly", function(state)
    Flying = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if state then
        BV = Instance.new("BodyVelocity")
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BV.Velocity = Vector3.zero
        BV.Parent = hrp

        BG = Instance.new("BodyGyro")
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.P = 2000
        BG.Parent = hrp

        hum.PlatformStand = true

        RunService:BindToRenderStep("FlyV5", Enum.RenderPriority.Camera.Value, function()
            if not Flying or not hrp.Parent then return end
            local cam = Camera.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

            BV.Velocity = dir.Magnitude > 0 and dir.Unit * Settings.FlySpeed or Vector3.zero
            BG.CFrame = cam
        end)
    else
        pcall(function() RunService:UnbindFromRenderStep("FlyV5") end)
        if BV then BV:Destroy() end
        if BG then BG:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end)

local NoclipConn
Toggle("Noclip", function(state)
    if state then
        NoclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConn then NoclipConn:Disconnect() end
    end
end)

local ESPFolder = Instance.new("Folder", ScreenGui)
ESPFolder.Name = "ESP"

local function ClearESP()
    ESPFolder:ClearAllChildren()
end

local function AddESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Adornee = head
    bb.Size = UDim2.new(0, 90, 0, 26)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = ESPFolder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = plr.Name
    lbl.TextColor3 = Color3.fromRGB(0, 255, 120)
    lbl.TextStrokeTransparency = 0.5
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.Parent = bb
end

Toggle("ESP", function(state)
    Settings.ESP = state
    ClearESP()
    if state then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then AddESP(plr) end
        end
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if Settings.ESP then AddESP(plr) end
    end)
end)

Toggle("Infinite Jump", function(state)
    Settings.InfiniteJump = state
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Toggle("Aimbot (RMB)", function(state)
    Settings.Aimbot = state
end)

local function GetClosest()
    local closest, dist = nil, math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (myHRP.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = plr
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

local oldLight = {}
Toggle("Fullbright", function(state)
    if state then
        oldLight.Ambient = Lighting.Ambient
        oldLight.Brightness = Lighting.Brightness
        oldLight.ClockTime = Lighting.ClockTime
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 9e9
    else
        if oldLight.Ambient then Lighting.Ambient = oldLight.Ambient end
        if oldLight.Brightness then Lighting.Brightness = oldLight.Brightness end
        if oldLight.ClockTime then Lighting.ClockTime = oldLight.ClockTime end
    end
end)

local GodConn
Toggle("God Mode", function(state)
    if state then
        GodConn = RunService.Heartbeat:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end)
    else
        if GodConn then GodConn:Disconnect() end
    end
end)

Button("Speed 50", function()
    Settings.WalkSpeed = 50
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 50 end
end)

Button("Speed 100", function()
    Settings.WalkSpeed = 100
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 100 end
end)

Button("Speed Reset", function()
    Settings.WalkSpeed = 16
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
end)

Button("Teleport to Nearest", function()
    local target = GetClosest()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            myHRP.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.7)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Settings.WalkSpeed
    end
end)

print("Universal Script v5 loaded")
