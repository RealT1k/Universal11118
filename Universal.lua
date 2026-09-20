-- Universal v7
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/RealT1k/Universal11118/refs/heads/main/Universal.lua?t="..tick()))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TOUCH = UIS.TouchEnabled

local S = {
	Fly = false, FlySpeed = 80, FlyMode = "Look", FlyFace = "Yaw",
	FlyUp = false, FlyDown = false, Noclip = false, InfJump = false,
	Speed = 16, SpeedBypass = false, ESP = false, ESPName = true, ESPHP = true,
	ESPDist = true, ESPBox = true, ESPMax = 600, ESPColor = Color3.fromRGB(90, 200, 255),
	Fullbright = false, Xray = false, God = false, Aimbot = false, AimbotSmooth = 0.35,
	ClickTP = false, FOV = 70,
}

local function char() return LP.Character end
local function hum(c) c = c or char() return c and c:FindFirstChildOfClass("Humanoid") end
local function hrp(c) c = c or char() return c and c:FindFirstChild("HumanoidRootPart") end

task.spawn(function()
	local ok, VU = pcall(function() return game:GetService("VirtualUser") end)
	if ok and VU then
		LP.Idled:Connect(function()
			pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
		end)
	end
end)

local function guiParent()
	local ok, r = pcall(function() if type(gethui) == "function" then return gethui() end end)
	if ok and r then return r end
	local cOk, core = pcall(function() return game:GetService("CoreGui") end)
	if cOk and core then return core end
	return LP:WaitForChild("PlayerGui")
end

local parent = guiParent()
for _, n in ipairs({"UniversalV6","UniversalV7","UniversalFlyPad"}) do
	local o = parent:FindFirstChild(n) if o then o:Destroy() end
end

local PadGui = Instance.new("ScreenGui")
PadGui.Name = "UniversalFlyPad"
PadGui.ResetOnSpawn = false
PadGui.IgnoreGuiInset = true
PadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
PadGui.Parent = parent

local function holdBtn(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 56, 0, 56)
	b.Position = UDim2.new(1, -72, 1, y)
	b.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
	b.BackgroundTransparency = 0.15
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 18
	b.Visible = false
	b.Parent = PadGui
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 16)
	return b
end
local UpBtn = holdBtn("UP", -200)
local DnBtn = holdBtn("DN", -136)
local function bindHold(b, set)
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			set(true) b.BackgroundColor3 = Color3.fromRGB(70, 140, 255)
		end
	end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			set(false) b.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
		end
	end)
end
bindHold(UpBtn, function(v) S.FlyUp = v end)
bindHold(DnBtn, function(v) S.FlyDown = v end)
local function showPad(v) UpBtn.Visible = v DnBtn.Visible = v end

local function setFlyState(v)
	S.Fly = v showPad(v)
	local h = hum()
	if h then
		h.PlatformStand = v
		pcall(function()
			h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v)
			h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not v)
		end)
		if not v then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
	end
end

local oldLight = {}
local function setFullbright(v)
	S.Fullbright = v
	if v then
		oldLight.A, oldLight.B, oldLight.C, oldLight.F = Lighting.Ambient, Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd
		Lighting.Ambient = Color3.new(1,1,1) Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 9e9
	else
		if oldLight.A then Lighting.Ambient = oldLight.A end
		if oldLight.B then Lighting.Brightness = oldLight.B end
		if oldLight.C then Lighting.ClockTime = oldLight.C end
		if oldLight.F then Lighting.FogEnd = oldLight.F end
	end
end

local function closestHead()
	local my = hrp() if not my then return end
	local best, bd = nil, 1e9
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then
			local hd = p.Character:FindFirstChild("Head")
			local hh = p.Character:FindFirstChildOfClass("Humanoid")
			if hd and hh and hh.Health > 0 then
				local d = (my.Position - hd.Position).Magnitude
				if d < bd then bd, best = d, hd end
			end
		end
	end
	return best
end

local function tpNearest()
	local t, best, my = nil, 1e9, hrp() if not my then return end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local d = (my.Position - p.Character.HumanoidRootPart.Position).Magnitude
			if d < best then best, t = d, p end
		end
	end
	if t then hrp().CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
end

local espFolder = Instance.new("Folder") espFolder.Name = "ESP" espFolder.Parent = PadGui
local espMap = {}
local function clearESP()
	for _, v in pairs(espMap) do if v.bb then v.bb:Destroy() end if v.hl then v.hl:Destroy() end end
	table.clear(espMap) espFolder:ClearAllChildren()
end
local function ensureESP(plr)
	local e = espMap[plr] if e then return e end
	e = {}
	local bb = Instance.new("BillboardGui") bb.Size = UDim2.new(0, 150, 0, 38) bb.StudsOffset = Vector3.new(0, 3.1, 0) bb.AlwaysOnTop = true bb.Parent = espFolder
	local tl = Instance.new("TextLabel") tl.BackgroundTransparency = 1 tl.Size = UDim2.new(1, 0, 1, 0)
	tl.Font = Enum.Font.GothamBold tl.TextSize = 12 tl.TextStrokeTransparency = 0.4 tl.Parent = bb
	e.bb, e.tl = bb, tl espMap[plr] = e return e
end

local function flyStep(dt, r, h)
	h.PlatformStand = true
	local cam = Camera.CFrame
	local look, right = cam.LookVector, cam.RightVector
	local dir = Vector3.zero
	if UIS:IsKeyDown(Enum.KeyCode.W) then dir += look end
	if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= look end
	if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= right end
	if UIS:IsKeyDown(Enum.KeyCode.D) then dir += right end
	local md = h.MoveDirection
	if md.Magnitude > 0.05 then
		local flat = Vector3.new(look.X, 0, look.Z)
		flat = flat.Magnitude < 0.05 and Vector3.new(0, 0, -1) or flat.Unit
		local rt = Vector3.new(right.X, 0, right.Z)
		if rt.Magnitude > 0.05 then rt = rt.Unit end
		local fwdAmt, rtAmt = md:Dot(flat), md:Dot(rt)
		if S.FlyMode == "Look" then dir += look * fwdAmt + right * rtAmt else dir += Vector3.new(md.X, 0, md.Z) end
	end
	local y = 0
	if S.FlyUp or UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then y += 1 end
	if S.FlyDown or UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then y -= 1 end
	if S.FlyMode == "Horiz" then dir = Vector3.new(dir.X, 0, dir.Z) end
	if dir.Magnitude > 1 then dir = dir.Unit end
	local vel = dir * S.FlySpeed + Vector3.new(0, y * S.FlySpeed, 0)
	local newPos = r.Position + vel * dt
	r.AssemblyLinearVelocity = Vector3.zero
	r.AssemblyAngularVelocity = Vector3.zero
	if S.FlyFace == "Look" then
		r.CFrame = CFrame.lookAt(newPos, newPos + look)
	elseif S.FlyFace == "Off" then
		r.CFrame = CFrame.new(newPos) * (r.CFrame - r.CFrame.Position)
	else
		local _, yaw = cam:ToEulerAnglesYXZ()
		r.CFrame = CFrame.new(newPos) * CFrame.Angles(0, yaw, 0)
	end
end

RunService.RenderStepped:Connect(function(dt)
	local c, h, r = char(), hum(), hrp()
	Camera.FieldOfView = S.FOV
	if S.Fly and r and h then flyStep(dt, r, h) end
	if S.SpeedBypass and r and h and not S.Fly then
		local md = h.MoveDirection
		if md.Magnitude > 0.05 then r.CFrame = r.CFrame + md.Unit * math.max(S.Speed - 16, 0) * dt end
	end
	if h then h.WalkSpeed = S.Speed if S.God then h.Health = h.MaxHealth end end
	if S.Noclip and c then
		for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
	end
	if S.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local hd = closestHead()
		if hd then Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, hd.Position), S.AimbotSmooth) end
	end
	if S.ESP and r then
		local seen = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character then
				local hd = plr.Character:FindFirstChild("Head")
				local hh = plr.Character:FindFirstChildOfClass("Humanoid")
				local pr = plr.Character:FindFirstChild("HumanoidRootPart")
				if hd and hh and pr then
					local dist = (r.Position - pr.Position).Magnitude
					if dist <= S.ESPMax then
						seen[plr] = true
						local e = ensureESP(plr)
						e.bb.Adornee = hd e.bb.Enabled = S.ESPName or S.ESPHP or S.ESPDist
						e.tl.TextColor3 = S.ESPColor
						local bits = {}
						if S.ESPName then table.insert(bits, plr.Name) end
						if S.ESPHP then table.insert(bits, math.floor(hh.Health).."hp") end
						if S.ESPDist then table.insert(bits, math.floor(dist).."m") end
						e.tl.Text = table.concat(bits, "  |  ")
						if S.ESPBox then
							if not e.hl or not e.hl.Parent then
								local hl = Instance.new("Highlight")
								hl.FillTransparency = 0.72 hl.OutlineTransparency = 0 hl.Parent = plr.Character e.hl = hl
							end
							e.hl.FillColor = S.ESPColor e.hl.OutlineColor = Color3.new(1,1,1) e.hl.Enabled = true
						elseif e.hl then e.hl.Enabled = false end
					end
				end
			end
		end
		for plr, e in pairs(espMap) do
			if not seen[plr] then if e.bb then e.bb:Destroy() end if e.hl then e.hl:Destroy() end espMap[plr] = nil end
		end
	elseif next(espMap) then clearESP() end
end)

RunService.Heartbeat:Connect(function()
	if not S.Xray then return end
	local mine = char()
	for _, p in ipairs(workspace:GetDescendants()) do
		if p:IsA("BasePart") and (not mine or not p:IsDescendantOf(mine)) then p.LocalTransparencyModifier = 0.65 end
	end
end)

UIS.JumpRequest:Connect(function()
	if S.InfJump then local h = hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe or not S.ClickTP then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local pos = input.Position
	local ray = Camera:ViewportPointToRay(pos.X, pos.Y)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {char()}
	params.FilterType = Enum.RaycastFilterType.Exclude
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 1200, params)
	local r = hrp() if hit and r then r.CFrame = CFrame.new(hit.Position + Vector3.new(0, 4, 0)) end
end)

LP.CharacterAdded:Connect(function()
	task.wait(0.6) local h = hum()
	if h then h.WalkSpeed = S.Speed if S.Fly then h.PlatformStand = true end end
end)

local Fluent
do
	local urls = {
		"https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
		"https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua",
	}
	for _, u in ipairs(urls) do
		local ok, lib = pcall(function() return loadstring(game:HttpGet(u))() end)
		if ok and type(lib) == "table" and lib.CreateWindow then Fluent = lib break end
	end
end

if Fluent then
	local Window = Fluent:CreateWindow({
		Title = "UNIVERSAL  v7",
		SubTitle = "look-fly + fluent",
		TabWidth = TOUCH and 120 or 140,
		Size = UDim2.fromOffset(TOUCH and 360 or 500, TOUCH and 390 or 420),
		Acrylic = false,
		Theme = "Darker",
		MinimizeKey = Enum.KeyCode.RightShift,
	})
	local T = {
		Fly = Window:AddTab({ Title = "Fly", Icon = "plane" }),
		Move = Window:AddTab({ Title = "Move", Icon = "person-standing" }),
		ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
		Visual = Window:AddTab({ Title = "Visual", Icon = "sun" }),
		Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
	}
	T.Fly:AddParagraph({ Title = "Look fly", Content = "Body turns with camera. Stick/WASD = where you look. Hold UP/DN on the right." })
	T.Fly:AddToggle("Fly", { Title = "Fly", Default = false }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.Fly.Value end setFlyState(v)
	end)
	T.Fly:AddDropdown("FlyMode", { Title = "Move mode", Values = {"Look","Horiz"}, Default = "Look" }):OnChanged(function(v) S.FlyMode = v end)
	T.Fly:AddDropdown("FlyFace", { Title = "Face camera", Values = {"Yaw","Look","Off"}, Default = "Yaw" }):OnChanged(function(v) S.FlyFace = v end)
	T.Fly:AddSlider("FlySpeed", { Title = "Fly speed", Min = 20, Max = 250, Default = 80, Rounding = 0, Callback = function(v) S.FlySpeed = v end })
	T.Move:AddToggle("Noclip", { Title = "Noclip", Default = false }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.Noclip.Value end S.Noclip = v
	end)
	T.Move:AddToggle("InfJump", { Title = "Infinite jump", Default = false }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.InfJump.Value end S.InfJump = v
	end)
	T.Move:AddToggle("SpeedBypass", { Title = "Speed bypass (CFrame)", Default = false }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.SpeedBypass.Value end S.SpeedBypass = v
	end)
	T.Move:AddSlider("WalkSpeed", { Title = "Walk speed", Min = 16, Max = 200, Default = 16, Rounding = 0, Callback = function(v) S.Speed = v end })
	T.ESP:AddToggle("ESP", { Title = "ESP", Default = false }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.ESP.Value end S.ESP = v
	end)
	T.ESP:AddToggle("ESPName", { Title = "Names", Default = true }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.ESPName.Value end S.ESPName = v
	end)
	T.ESP:AddToggle("ESPHP", { Title = "Health", Default = true }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.ESPHP.Value end S.ESPHP = v
	end)
	T.ESP:AddToggle("ESPDist", { Title = "Distance", Default = true }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.ESPDist.Value end S.ESPDist = v
	end)
	T.ESP:AddToggle("ESPBox", { Title = "Highlight box", Default = true }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.ESPBox.Value end S.ESPBox = v
	end)
	T.ESP:AddSlider("ESPMax", { Title = "Range", Min = 50, Max = 2000, Default = 600, Rounding = 0, Callback = function(v) S.ESPMax = v end })
	pcall(function()
		T.ESP:AddColorpicker("ESPColor", { Title = "ESP color", Default = S.ESPColor }):OnChanged(function()
			S.ESPColor = Fluent.Options.ESPColor.Value
		end)
	end)
	T.Visual:AddToggle("Fullbright", { Title = "Fullbright", Default = false }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.Fullbright.Value end setFullbright(v)
	end)
	T.Visual:AddToggle("Xray", { Title = "Xray", Default = false }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.Xray.Value end
		S.Xray = v
		if not v then
			for _, p in ipairs(workspace:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end end
		end
	end)
	T.Visual:AddSlider("FOV", { Title = "FOV", Min = 50, Max = 120, Default = 70, Rounding = 0, Callback = function(v) S.FOV = v Camera.FieldOfView = v end })
	T.Misc:AddToggle("God", { Title = "God (client)", Default = false }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.God.Value end S.God = v
	end)
	T.Misc:AddToggle("Aimbot", { Title = "Aimbot (hold RMB)", Default = false }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.Aimbot.Value end S.Aimbot = v
	end)
	T.Misc:AddSlider("AimSmooth", { Title = "Aimbot smoothness", Min = 0.1, Max = 1, Default = 0.35, Rounding = 2, Callback = function(v) S.AimbotSmooth = v end })
	T.Misc:AddToggle("ClickTP", { Title = "Click / tap TP", Default = false }):OnChanged(function(v)
		if type(v) ~= "boolean" then v = Fluent.Options.ClickTP.Value end S.ClickTP = v
	end)
	T.Misc:AddButton({ Title = "TP nearest", Callback = tpNearest })
	T.Misc:AddButton({ Title = "Reset", Callback = function() local h = hum() if h then h.Health = 0 end end })
	T.Misc:AddButton({ Title = "Rejoin", Callback = function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end })
	Fluent:Notify({ Title = "Universal v7", Content = "Fluent loaded. RightShift hide. Fly: Look + Yaw.", Duration = 6 })
	print("Universal v7 Fluent")
else
	warn("Fluent failed, using fallback UI")
	local Gui = Instance.new("ScreenGui") Gui.Name = "UniversalV7" Gui.ResetOnSpawn = false Gui.IgnoreGuiInset = true Gui.Parent = parent
	local Main = Instance.new("Frame") Main.Size = UDim2.new(0, 280, 0, 360) Main.Position = UDim2.new(0.5, -140, 0.2, 0)
	Main.BackgroundColor3 = Color3.fromRGB(16, 16, 22) Main.Active = true Main.Parent = Gui
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	local Title = Instance.new("TextLabel") Title.Size = UDim2.new(1, -80, 0, 40) Title.BackgroundTransparency = 1
	Title.Text = "UNIVERSAL v7" Title.TextColor3 = Color3.new(1,1,1) Title.Font = Enum.Font.GothamBold Title.TextSize = 14
	Title.TextXAlignment = Enum.TextXAlignment.Left Title.Position = UDim2.new(0, 12, 0, 0) Title.Parent = Main
	local Hide = Instance.new("TextButton") Hide.Size = UDim2.new(0, 32, 0, 28) Hide.Position = UDim2.new(1, -40, 0, 6)
	Hide.Text = "-" Hide.BackgroundColor3 = Color3.fromRGB(40, 40, 55) Hide.TextColor3 = Color3.new(1,1,1) Hide.Parent = Main
	Instance.new("UICorner", Hide).CornerRadius = UDim.new(0, 6)
	local Float = Instance.new("TextButton") Float.Size = UDim2.new(0, 48, 0, 48) Float.Position = UDim2.new(1, -64, 1, -120)
	Float.Text = "U" Float.BackgroundColor3 = Color3.fromRGB(70, 140, 255) Float.TextColor3 = Color3.new(1,1,1)
	Float.Font = Enum.Font.GothamBold Float.Visible = false Float.Parent = Gui
	Instance.new("UICorner", Float).CornerRadius = UDim.new(0, 14)
	Hide.MouseButton1Click:Connect(function() Main.Visible = false Float.Visible = true end)
	Float.MouseButton1Click:Connect(function() Main.Visible = true Float.Visible = false end)
	local Sc = Instance.new("ScrollingFrame") Sc.Size = UDim2.new(1, -12, 1, -48) Sc.Position = UDim2.new(0, 6, 0, 42)
	Sc.BackgroundTransparency = 1 Sc.ScrollBarThickness = 4 Sc.Parent = Main
	local lay = Instance.new("UIListLayout") lay.Padding = UDim.new(0, 6) lay.Parent = Sc
	lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sc.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 8) end)
	local function tog(name, get, set)
		local b = Instance.new("TextButton") b.Size = UDim2.new(1, 0, 0, 34) b.Font = Enum.Font.Gotham b.TextSize = 13 b.TextColor3 = Color3.new(1,1,1) b.Parent = Sc
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
		local function paint() b.Text = name..(get() and "  ON" or "  OFF") b.BackgroundColor3 = get() and Color3.fromRGB(40, 120, 70) or Color3.fromRGB(32, 32, 44) end
		paint() b.MouseButton1Click:Connect(function() set(not get()) paint() end)
	end
	tog("Fly", function() return S.Fly end, setFlyState)
	tog("Noclip", function() return S.Noclip end, function(v) S.Noclip = v end)
	tog("InfJump", function() return S.InfJump end, function(v) S.InfJump = v end)
	tog("Speed bypass", function() return S.SpeedBypass end, function(v) S.SpeedBypass = v end)
	tog("ESP", function() return S.ESP end, function(v) S.ESP = v end)
	tog("Fullbright", function() return S.Fullbright end, setFullbright)
	print("Universal v7 fallback")
end
