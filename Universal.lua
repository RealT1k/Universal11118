-- Universal v6
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/RealT1k/Universal11118/refs/heads/main/Universal.lua?t="..tick()))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local IS_TOUCH = UIS.TouchEnabled

local S = {
	Fly = false, FlySpeed = 70, FlyUp = false, FlyDown = false,
	Noclip = false, InfJump = false, Speed = 16, SpeedBypass = false,
	ESP = false, ESPName = true, ESPHP = true, ESPDist = true, ESPBox = true, ESPMax = 800,
	Fullbright = false, Xray = false, God = false, Aimbot = false, ClickTP = false, FOV = 70,
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
local old = parent:FindFirstChild("UniversalV6")
if old then old:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "UniversalV6"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = parent

local Scale = Instance.new("UIScale")
Scale.Parent = Gui
local function fitScale()
	local vs = Camera.ViewportSize
	Scale.Scale = math.clamp(math.min(vs.X, vs.Y) / 720, 0.62, 1.05)
end
fitScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale)

local ACCENT = Color3.fromRGB(90, 170, 255)
local BG = Color3.fromRGB(14, 14, 18)
local HEAD = Color3.fromRGB(22, 22, 30)
local BTN = Color3.fromRGB(32, 32, 44)
local ON = Color3.fromRGB(42, 130, 78)
local TXT = Color3.fromRGB(235, 235, 242)

local function corner(i, r)
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 8) c.Parent = i
end
local function stroke(i)
	local s = Instance.new("UIStroke") s.Color = Color3.fromRGB(50, 50, 68) s.Thickness = 1 s.Transparency = 0.35 s.Parent = i
end

local Float = Instance.new("TextButton")
Float.Name = "Open"
Float.Size = UDim2.new(0, 52, 0, 52)
Float.Position = UDim2.new(1, -70, 1, -120)
Float.BackgroundColor3 = ACCENT
Float.Text = "U"
Float.TextColor3 = Color3.new(1, 1, 1)
Float.Font = Enum.Font.GothamBold
Float.TextSize = 20
Float.Visible = false
Float.Parent = Gui
corner(Float, 14) stroke(Float)

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, IS_TOUCH and 300 or 280, 0, IS_TOUCH and 420 or 400)
Main.Position = UDim2.new(0.5, IS_TOUCH and -150 or -140, 0.5, IS_TOUCH and -210 or -200)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui
corner(Main, 12) stroke(Main)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = HEAD
Header.BorderSizePixel = 0
Header.Parent = Main
corner(Header, 12)
local HeaderCover = Instance.new("Frame")
HeaderCover.Size = UDim2.new(1, 0, 0, 14)
HeaderCover.Position = UDim2.new(0, 0, 1, -14)
HeaderCover.BackgroundColor3 = HEAD
HeaderCover.BorderSizePixel = 0
HeaderCover.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.Text = "UNIVERSAL  v6"
Title.TextColor3 = TXT
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local function iconBtn(text, x, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 32, 0, 32)
	b.Position = UDim2.new(1, x, 0.5, -16)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.Parent = Header
	corner(b, 8)
	return b
end
local HideBtn = iconBtn("-", -74, Color3.fromRGB(50, 50, 70))
local CloseBtn = iconBtn("x", -38, Color3.fromRGB(170, 50, 55))

local function setOpen(v) Main.Visible = v Float.Visible = not v end
HideBtn.MouseButton1Click:Connect(function() setOpen(false) end)
Float.MouseButton1Click:Connect(function() setOpen(true) end)
CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)
UIS.InputBegan:Connect(function(inp, gpe)
	if gpe then return end
	if inp.KeyCode == Enum.KeyCode.RightShift then setOpen(not Main.Visible) end
end)

do
	local drag, start, startPos
	Header.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		drag = true start = input.Position startPos = Main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then drag = false end
		end)
	end)
	UIS.InputChanged:Connect(function(input)
		if not drag then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local d = input.Position - start
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end)
end

local Tabs = Instance.new("Frame")
Tabs.BackgroundTransparency = 1
Tabs.Size = UDim2.new(1, -12, 0, 34)
Tabs.Position = UDim2.new(0, 6, 0, 48)
Tabs.Parent = Main
local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.Padding = UDim.new(0, 6)
TabList.Parent = Tabs

local Pages = {}
local PageFrame = Instance.new("Frame")
PageFrame.BackgroundTransparency = 1
PageFrame.Size = UDim2.new(1, -12, 1, -92)
PageFrame.Position = UDim2.new(0, 6, 0, 86)
PageFrame.Parent = Main

local function makePage(name)
	local sc = Instance.new("ScrollingFrame")
	sc.Name = name sc.Size = UDim2.new(1, 0, 1, 0) sc.BackgroundTransparency = 1
	sc.BorderSizePixel = 0 sc.ScrollBarThickness = 4 sc.ScrollBarImageColor3 = ACCENT
	sc.CanvasSize = UDim2.new(0, 0, 0, 0) sc.Visible = false sc.Parent = PageFrame
	local lay = Instance.new("UIListLayout") lay.Padding = UDim.new(0, 6) lay.Parent = sc
	lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		sc.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 10)
	end)
	Pages[name] = sc
end
local function showPage(name) for n, p in pairs(Pages) do p.Visible = n == name end end
local tabBtns = {}
local function addTab(name)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, IS_TOUCH and 70 or 64, 1, 0)
	b.BackgroundColor3 = BTN b.Text = name b.TextColor3 = TXT
	b.Font = Enum.Font.GothamBold b.TextSize = 12 b.Parent = Tabs
	corner(b, 8) tabBtns[name] = b
	b.MouseButton1Click:Connect(function()
		for _, o in pairs(tabBtns) do o.BackgroundColor3 = BTN o.TextColor3 = TXT end
		b.BackgroundColor3 = ACCENT b.TextColor3 = Color3.new(1, 1, 1)
		showPage(name)
	end)
	makePage(name)
end
addTab("Move") addTab("ESP") addTab("Visual") addTab("Misc")
tabBtns["Move"].BackgroundColor3 = ACCENT
showPage("Move")

local function section(page, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 18) l.BackgroundTransparency = 1 l.Text = text
	l.TextColor3 = Color3.fromRGB(140, 150, 170) l.Font = Enum.Font.GothamBold
	l.TextSize = 11 l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = Pages[page]
end
local function mkBtn(page, text, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, IS_TOUCH and 36 or 32)
	b.BackgroundColor3 = BTN b.Text = text b.TextColor3 = TXT
	b.Font = Enum.Font.Gotham b.TextSize = 13 b.Parent = Pages[page]
	corner(b, 8) b.MouseButton1Click:Connect(cb) return b
end
local function mkToggle(page, text, get, set)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, IS_TOUCH and 36 or 32)
	b.Font = Enum.Font.Gotham b.TextSize = 13 b.TextColor3 = TXT b.Parent = Pages[page]
	corner(b, 8)
	local function paint()
		local on = get() b.Text = text .. (on and "  ON" or "  OFF") b.BackgroundColor3 = on and ON or BTN
	end
	paint()
	b.MouseButton1Click:Connect(function() set(not get()) paint() end)
end
local function mkHold(page, text, on, off)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 40)
	b.BackgroundColor3 = Color3.fromRGB(40, 70, 120) b.Text = text b.TextColor3 = TXT
	b.Font = Enum.Font.GothamBold b.TextSize = 14 b.Parent = Pages[page] corner(b, 8)
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then on() b.BackgroundColor3 = ACCENT end
	end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then off() b.BackgroundColor3 = Color3.fromRGB(40, 70, 120) end
	end)
end

section("Move", "FLY  (thumbstick / WASD + HOLD UP/DOWN)")
mkToggle("Move", "Fly", function() return S.Fly end, function(v)
	S.Fly = v
	local h = hum()
	if h then
		h.PlatformStand = v
		pcall(function()
			h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v)
			h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not v)
		end)
		if not v then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
	end
end)
mkHold("Move", "HOLD  UP", function() S.FlyUp = true end, function() S.FlyUp = false end)
mkHold("Move", "HOLD  DOWN", function() S.FlyDown = true end, function() S.FlyDown = false end)
mkBtn("Move", "Fly speed 40", function() S.FlySpeed = 40 end)
mkBtn("Move", "Fly speed 70", function() S.FlySpeed = 70 end)
mkBtn("Move", "Fly speed 120", function() S.FlySpeed = 120 end)
section("Move", "SPEED / NOCLIP")
mkToggle("Move", "Noclip", function() return S.Noclip end, function(v) S.Noclip = v end)
mkToggle("Move", "Infinite Jump", function() return S.InfJump end, function(v) S.InfJump = v end)
mkToggle("Move", "Speed bypass (CFrame)", function() return S.SpeedBypass end, function(v) S.SpeedBypass = v end)
mkBtn("Move", "Walk 16", function() S.Speed = 16 end)
mkBtn("Move", "Walk 32", function() S.Speed = 32 end)
mkBtn("Move", "Walk 64", function() S.Speed = 64 end)
mkBtn("Move", "Walk 100", function() S.Speed = 100 end)

section("ESP", "TOGGLES")
mkToggle("ESP", "ESP master", function() return S.ESP end, function(v) S.ESP = v end)
mkToggle("ESP", "Names", function() return S.ESPName end, function(v) S.ESPName = v end)
mkToggle("ESP", "Health", function() return S.ESPHP end, function(v) S.ESPHP = v end)
mkToggle("ESP", "Distance", function() return S.ESPDist end, function(v) S.ESPDist = v end)
mkToggle("ESP", "Box (Highlight)", function() return S.ESPBox end, function(v) S.ESPBox = v end)
mkBtn("ESP", "Range 200", function() S.ESPMax = 200 end)
mkBtn("ESP", "Range 400", function() S.ESPMax = 400 end)
mkBtn("ESP", "Range 800", function() S.ESPMax = 800 end)
mkBtn("ESP", "Range inf", function() S.ESPMax = 1e9 end)

section("Visual", "WORLD")
local oldLight = {}
mkToggle("Visual", "Fullbright", function() return S.Fullbright end, function(v)
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
end)
mkToggle("Visual", "Xray", function() return S.Xray end, function(v)
	S.Xray = v
	if not v then
		for _, p in ipairs(workspace:GetDescendants()) do
			if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
		end
	end
end)
mkBtn("Visual", "FOV 70", function() S.FOV = 70 Camera.FieldOfView = 70 end)
mkBtn("Visual", "FOV 90", function() S.FOV = 90 Camera.FieldOfView = 90 end)
mkBtn("Visual", "FOV 120", function() S.FOV = 120 Camera.FieldOfView = 120 end)

section("Misc", "PLAYER")
mkToggle("Misc", "God (client)", function() return S.God end, function(v) S.God = v end)
mkToggle("Misc", "Aimbot (hold RMB)", function() return S.Aimbot end, function(v) S.Aimbot = v end)
mkToggle("Misc", "Click / tap TP", function() return S.ClickTP end, function(v) S.ClickTP = v end)
mkBtn("Misc", "TP to nearest", function()
	local t, best, my = nil, 1e9, hrp() if not my then return end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local d = (my.Position - p.Character.HumanoidRootPart.Position).Magnitude
			if d < best then best = d t = p end
		end
	end
	if t then hrp().CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
end)
mkBtn("Misc", "Reset character", function() local h = hum() if h then h.Health = 0 end end)
mkBtn("Misc", "Rejoin", function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end)

UIS.JumpRequest:Connect(function()
	if S.InfJump then local h = hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

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

local espFolder = Instance.new("Folder") espFolder.Name = "ESP" espFolder.Parent = Gui
local espMap = {}
local function clearESP()
	for _, v in pairs(espMap) do if v.bb then v.bb:Destroy() end if v.hl then v.hl:Destroy() end end
	table.clear(espMap) espFolder:ClearAllChildren()
end
local function ensureESP(plr)
	local e = espMap[plr] if e then return e end
	e = {}
	local bb = Instance.new("BillboardGui") bb.Size = UDim2.new(0, 140, 0, 36) bb.StudsOffset = Vector3.new(0, 3, 0) bb.AlwaysOnTop = true bb.Parent = espFolder
	local tl = Instance.new("TextLabel") tl.BackgroundTransparency = 1 tl.Size = UDim2.new(1, 0, 1, 0)
	tl.Font = Enum.Font.GothamBold tl.TextSize = 12 tl.TextColor3 = Color3.fromRGB(80, 255, 140) tl.TextStrokeTransparency = 0.4 tl.Parent = bb
	e.bb, e.tl = bb, tl espMap[plr] = e return e
end

RunService.RenderStepped:Connect(function(dt)
	local c = char() local h = hum(c) local r = hrp(c)
	Camera.FieldOfView = S.FOV
	if S.Fly and r and h then
		h.PlatformStand = true
		local cam = Camera.CFrame local dir = Vector3.zero
		local md = h.MoveDirection
		if md.Magnitude > 0.05 then dir = Vector3.new(md.X, 0, md.Z) end
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z) end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z) end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z) end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z) end
		local y = 0
		if S.FlyUp or UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then y += 1 end
		if S.FlyDown or UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then y -= 1 end
		if dir.Magnitude > 1 then dir = dir.Unit end
		local vel = Vector3.new(dir.X, 0, dir.Z)
		if vel.Magnitude > 0 then vel = vel.Unit * S.FlySpeed end
		vel = Vector3.new(vel.X, y * S.FlySpeed, vel.Z)
		r.AssemblyLinearVelocity = Vector3.zero
		r.CFrame = CFrame.new(r.Position + vel * dt)
	end
	if S.SpeedBypass and r and h and not S.Fly then
		local md = h.MoveDirection
		if md.Magnitude > 0.05 then r.CFrame = r.CFrame + md.Unit * math.max(S.Speed - 16, 0) * dt end
	end
	if h then h.WalkSpeed = S.Speed if S.God then h.Health = h.MaxHealth end end
	if S.Noclip and c then
		for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
	end
	if S.Aimbot then
		local holding = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
			or (IS_TOUCH and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not Main.Visible)
		if holding then local hd = closestHead() if hd then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, hd.Position) end end
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
						seen[plr] = true local e = ensureESP(plr)
						e.bb.Adornee = hd e.bb.Enabled = S.ESPName or S.ESPHP or S.ESPDist
						local bits = {}
						if S.ESPName then table.insert(bits, plr.Name) end
						if S.ESPHP then table.insert(bits, math.floor(hh.Health).."hp") end
						if S.ESPDist then table.insert(bits, math.floor(dist).."m") end
						e.tl.Text = table.concat(bits, "  |  ")
						if S.ESPBox then
							if not e.hl or not e.hl.Parent then
								local hl = Instance.new("Highlight")
								hl.FillColor = Color3.fromRGB(80, 255, 140) hl.OutlineColor = Color3.fromRGB(255, 255, 255)
								hl.FillTransparency = 0.72 hl.OutlineTransparency = 0 hl.Parent = plr.Character e.hl = hl
							end
							e.hl.Enabled = true
						elseif e.hl then e.hl.Enabled = false end
					end
				end
			end
		end
		for plr, e in pairs(espMap) do
			if not seen[plr] then if e.bb then e.bb:Destroy() end if e.hl then e.hl:Destroy() end espMap[plr] = nil end
		end
	else
		if next(espMap) then clearESP() end
	end
end)

RunService.Heartbeat:Connect(function()
	if not S.Xray then return end
	local mine = char()
	for _, p in ipairs(workspace:GetDescendants()) do
		if p:IsA("BasePart") and (not mine or not p:IsDescendantOf(mine)) then p.LocalTransparencyModifier = 0.65 end
	end
end)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe or not S.ClickTP then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local pos = input.Position
	local ray = Camera:ViewportPointToRay(pos.X, pos.Y)
	local params = RaycastParams.new() params.FilterDescendantsInstances = {char()} params.FilterType = Enum.RaycastFilterType.Exclude
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 1200, params)
	local r = hrp() if hit and r then r.CFrame = CFrame.new(hit.Position + Vector3.new(0, 4, 0)) end
end)

LP.CharacterAdded:Connect(function()
	task.wait(0.6) local h = hum()
	if h then h.WalkSpeed = S.Speed if S.Fly then h.PlatformStand = true end end
end)

print("Universal v6 loaded | hide: RightShift or U button")
