-- Universal v8
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/RealT1k/Universal11118/refs/heads/main/Universal.lua?t="..tick()))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TOUCH = UIS.TouchEnabled
local RAW = "https://raw.githubusercontent.com/RealT1k/Universal11118/refs/heads/main/"

local S = {
	Fly = false, FlySpeed = 80, FlyMode = "Look", FlyFace = "Yaw", FlyUp = false, FlyDown = false,
	Noclip = false, InfJump = false, Speed = 16, SpeedBypass = false,
	ESP = false, ESPName = true, ESPHP = true, ESPDist = true, ESPBox = true, ESPBar = true,
	ESPTracer = false, ESPRainbow = false, ESPMax = 600, ESPText = 13,
	ESPFill = 0.72, ESPOutline = 0, ESPColor = Color3.fromRGB(90, 200, 255),
	Fullbright = false, Xray = false, God = false, Aimbot = false, AimbotSmooth = 0.35,
	ClickTP = false, FOV = 70, WalkFling = false,
}

local function char() return LP.Character end
local function hum(c) c = c or char() return c and c:FindFirstChildOfClass("Humanoid") end
local function hrp(c) c = c or char() return c and c:FindFirstChild("HumanoidRootPart") end

task.spawn(function()
	pcall(function()
		local VU = game:GetService("VirtualUser")
		LP.Idled:Connect(function()
			pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
		end)
	end)
end)

local function guiParent()
	local ok, r = pcall(function() if gethui then return gethui() end end)
	if ok and r then return r end
	local o, c = pcall(function() return game:GetService("CoreGui") end)
	if o and c then return c end
	return LP:WaitForChild("PlayerGui")
end

local parent = guiParent()
for _, n in ipairs({"UniversalV6","UniversalV7","UniversalV8","UniversalFlyPad"}) do
	local o = parent:FindFirstChild(n)
	if o then o:Destroy() end
end

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64dec(data)
	data = (data or ""):gsub("[^"..B64.."=]", "")
	return (data:gsub(".", function(x)
		if x == "=" then return "" end
		local r, f = "", (B64:find(x, 1, true) - 1)
		for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i - 1) > 0 and "1" or "0") end
		return r
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
		if #x ~= 8 then return "" end
		local c = 0
		for i = 1, 8 do c = c + (x:sub(i, i) == "1" and 2^(8 - i) or 0) end
		return string.char(c)
	end))
end
local function decodeB64(s)
	for _, fn in ipairs({
		function() return crypt.base64decode(s) end,
		function() return crypt.base64_decode(s) end,
		function() return crypt.base64.decode(s) end,
		function() return base64.decode(s) end,
	}) do
		local ok, r = pcall(fn)
		if ok and type(r) == "string" and #r > 200 then return r end
	end
	return b64dec(s)
end

local ACCENT = Color3.fromRGB(90, 170, 255)
local TXT = Color3.fromRGB(245, 245, 250)
local MUTED = Color3.fromRGB(190, 198, 214)

local Gui = Instance.new("ScreenGui")
Gui.Name = "UniversalV8"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = parent

local Scale = Instance.new("UIScale")
Scale.Parent = Gui
local function fit()
	local vs = Camera.ViewportSize
	Scale.Scale = math.clamp(math.min(vs.X, vs.Y) / 740, 0.68, 1.05)
end
fit()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

local function corner(i, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = i
	return c
end
local function stroke(i, t)
	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(255, 255, 255)
	s.Transparency = t or 0.82
	s.Thickness = 1
	s.Parent = i
	return s
end

local MW, MH = TOUCH and 348 or 520, TOUCH and 430 or 390
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, MW, 0, MH)
Main.Position = UDim2.new(0.5, -MW / 2, 0.5, -MH / 2)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = Gui
corner(Main, 14)
stroke(Main, 0.7)

local Bg = Instance.new("ImageLabel")
Bg.Name = "Bg"
Bg.BackgroundTransparency = 1
Bg.Size = UDim2.new(1, 0, 1, 0)
Bg.ScaleType = Enum.ScaleType.Crop
Bg.ImageTransparency = 0.08
Bg.ZIndex = 0
Bg.Parent = Main
local Dim = Instance.new("Frame")
Dim.Size = UDim2.new(1, 0, 1, 0)
Dim.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Dim.BackgroundTransparency = 0.28
Dim.BorderSizePixel = 0
Dim.ZIndex = 1
Dim.Parent = Main

task.spawn(function()
	pcall(function()
		local raw = game:HttpGet(RAW.."gui_bg.b64?t="..tostring(tick()))
		local bin = decodeB64(raw)
		if not bin or #bin < 200 then return end
		if writefile then writefile("U11118_bg.jpg", bin) end
		local asset
		if getcustomasset then asset = getcustomasset("U11118_bg.jpg")
		elseif getsynasset then asset = getsynasset("U11118_bg.jpg") end
		if asset then Bg.Image = asset end
	end)
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Header.BackgroundTransparency = 0.45
Header.BorderSizePixel = 0
Header.ZIndex = 3
Header.Parent = Main
local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Text = "UNIVERSAL  v8"
Title.TextColor3 = TXT
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4
Title.Parent = Header
local function iconBtn(txt, x, col)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 30, 0, 26)
	b.Position = UDim2.new(1, x, 0.5, -13)
	b.BackgroundColor3 = col
	b.Text = txt
	b.TextColor3 = TXT
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.ZIndex = 4
	b.Parent = Header
	corner(b, 7)
	return b
end
local HideBtn = iconBtn("-", -72, Color3.fromRGB(40, 44, 62))
local CloseBtn = iconBtn("x", -38, Color3.fromRGB(150, 48, 52))

local Float = Instance.new("TextButton")
Float.Size = UDim2.new(0, 50, 0, 50)
Float.Position = UDim2.new(1, -66, 1, -118)
Float.BackgroundColor3 = ACCENT
Float.Text = "U"
Float.TextColor3 = Color3.new(1, 1, 1)
Float.Font = Enum.Font.GothamBold
Float.TextSize = 20
Float.Visible = false
Float.Parent = Gui
corner(Float, 14)
stroke(Float, 0.5)

local function setOpen(v)
	Main.Visible = v
	Float.Visible = not v
end
HideBtn.MouseButton1Click:Connect(function() setOpen(false) end)
Float.MouseButton1Click:Connect(function() setOpen(true) end)
CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)
UIS.InputBegan:Connect(function(inp, gpe)
	if not gpe and inp.KeyCode == Enum.KeyCode.RightShift then setOpen(not Main.Visible) end
end)
do
	local drag, start, startPos
	Header.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		drag, start, startPos = true, input.Position, Main.Position
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

local Body = Instance.new("Frame")
Body.BackgroundTransparency = 1
Body.Size = UDim2.new(1, -10, 1, -50)
Body.Position = UDim2.new(0, 5, 0, 46)
Body.ZIndex = 3
Body.Parent = Main

local SideW = TOUCH and 70 or 78
local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, SideW, 1, 0)
Side.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Side.BackgroundTransparency = 0.42
Side.BorderSizePixel = 0
Side.ZIndex = 3
Side.Parent = Body
corner(Side, 10)
local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 5)
SideList.Parent = Side
local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 6)
SidePad.PaddingLeft = UDim.new(0, 6)
SidePad.PaddingRight = UDim.new(0, 6)
SidePad.Parent = Side

local Pages = Instance.new("Frame")
Pages.BackgroundTransparency = 1
Pages.Size = UDim2.new(1, -(SideW + 8), 1, 0)
Pages.Position = UDim2.new(0, SideW + 8, 0, 0)
Pages.ZIndex = 3
Pages.ClipsDescendants = true
Pages.Parent = Body

local pageF, tabBtns, currentPage = {}, {}, nil
local function showPage(name)
	currentPage = name
	for n, p in pairs(pageF) do p.Visible = n == name end
	for n, b in pairs(tabBtns) do
		b.BackgroundColor3 = n == name and ACCENT or Color3.fromRGB(22, 24, 34)
		b.BackgroundTransparency = n == name and 0.05 or 0.25
	end
end
local function addTab(name)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
	b.BackgroundTransparency = 0.25
	b.Text = name
	b.TextColor3 = TXT
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.ZIndex = 4
	b.Parent = Side
	corner(b, 8)
	tabBtns[name] = b
	local sc = Instance.new("ScrollingFrame")
	sc.Name = name
	sc.Size = UDim2.new(1, 0, 1, 0)
	sc.BackgroundTransparency = 1
	sc.BorderSizePixel = 0
	sc.ScrollBarThickness = 3
	sc.ScrollBarImageColor3 = ACCENT
	sc.CanvasSize = UDim2.new(0, 0, 0, 0)
	sc.Visible = false
	sc.ZIndex = 3
	sc.Parent = Pages
	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 6)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Parent = sc
	lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		sc.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 10)
	end)
	pageF[name] = sc
	b.MouseButton1Click:Connect(function() showPage(name) end)
	return sc
end

local PFly = addTab("Fly")
local PMove = addTab("Move")
local PESP = addTab("ESP")
local PPrev = addTab("Preview")
local PFling = addTab("Fling")
local PVis = addTab("Visual")
local PMisc = addTab("Misc")
showPage("Fly")

local order = 0
local function nextOrder()
	order += 1
	return order
end
local function row(page, h)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -4, 0, h)
	f.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
	f.BackgroundTransparency = 0.28
	f.BorderSizePixel = 0
	f.ZIndex = 4
	f.LayoutOrder = nextOrder()
	f.Parent = page
	corner(f, 8)
	return f
end
local function lbl(parent, text, x, y, w, h, size, color)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = UDim2.new(0, x, 0, y)
	t.Size = UDim2.new(w or 1, w and 0 or -x, 0, h)
	t.Font = Enum.Font.GothamBold
	t.TextSize = size or 13
	t.Text = text
	t.TextColor3 = color or TXT
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextTruncate = Enum.TextTruncate.AtEnd
	t.ZIndex = 5
	t.Parent = parent
	return t
end
local function mkToggle(page, text, get, set)
	local f = row(page, 36)
	lbl(f, text, 10, 0, nil, 36, 13)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 54, 0, 22)
	b.Position = UDim2.new(1, -64, 0.5, -11)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = TXT
	b.ZIndex = 5
	b.Parent = f
	corner(b, 11)
	local function paint()
		local on = get()
		b.Text = on and "ON" or "OFF"
		b.BackgroundColor3 = on and Color3.fromRGB(42, 140, 80) or Color3.fromRGB(50, 54, 70)
	end
	paint()
	b.MouseButton1Click:Connect(function() set(not get()) paint() end)
	return paint
end
local function mkSlider(page, text, min, max, get, set, digits)
	digits = digits or 0
	local f = row(page, 50)
	local t = lbl(f, text, 10, 2, 0.7, 18, 12)
	local val = lbl(f, "", 0, 2, nil, 18, 12, ACCENT)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Size = UDim2.new(1, -12, 0, 18)
	local bar = Instance.new("TextButton")
	bar.AutoButtonColor = false
	bar.Text = ""
	bar.Size = UDim2.new(1, -20, 0, 10)
	bar.Position = UDim2.new(0, 10, 0, 30)
	bar.BackgroundColor3 = Color3.fromRGB(40, 44, 60)
	bar.ZIndex = 5
	bar.Parent = f
	corner(bar, 5)
	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.BackgroundColor3 = ACCENT
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.ZIndex = 6
	fill.Parent = bar
	corner(fill, 5)
	local function paint()
		local v = get()
		local a = (v - min) / (max - min)
		fill.Size = UDim2.new(math.clamp(a, 0, 1), 0, 1, 0)
		val.Text = (digits == 0) and tostring(math.floor(v + 0.5)) or string.format("%."..digits.."f", v)
	end
	local function fromx(x)
		local a = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local v = min + (max - min) * a
		if digits == 0 then v = math.floor(v + 0.5) else v = math.floor(v * 10^digits + 0.5) / 10^digits end
		set(v) paint()
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
		fromx(i.Position.X)
		local m; m = UIS.InputChanged:Connect(function(ch)
			if ch.UserInputType == Enum.UserInputType.MouseMovement or ch.UserInputType == Enum.UserInputType.Touch then fromx(ch.Position.X) end
		end)
		local e; e = UIS.InputEnded:Connect(function(en)
			if en.UserInputType == i.UserInputType then if m then m:Disconnect() end if e then e:Disconnect() end end
		end)
	end)
	paint()
	return paint
end
local function mkBtn(page, text, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, 34)
	b.BackgroundColor3 = Color3.fromRGB(18, 22, 36)
	b.BackgroundTransparency = 0.15
	b.Text = text
	b.TextColor3 = TXT
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.ZIndex = 4
	b.LayoutOrder = nextOrder()
	b.Parent = page
	corner(b, 8)
	b.MouseButton1Click:Connect(cb)
	return b
end
local function mkHold(page, text, on, off)
	local b = mkBtn(page, text, function() end)
	b.BackgroundColor3 = Color3.fromRGB(32, 58, 110)
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			on() b.BackgroundColor3 = ACCENT
		end
	end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			off() b.BackgroundColor3 = Color3.fromRGB(32, 58, 110)
		end
	end)
end
local function section(page, text)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, -4, 0, 16)
	t.Font = Enum.Font.GothamBold
	t.TextSize = 11
	t.Text = text
	t.TextColor3 = MUTED
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.ZIndex = 4
	t.LayoutOrder = nextOrder()
	t.Parent = page
end

-- fly pad
local UpBtn, DnBtn
do
	local function pad(text, y)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 54, 0, 54)
		b.Position = UDim2.new(1, -70, 1, y)
		b.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
		b.BackgroundTransparency = 0.1
		b.Text, b.TextColor3, b.Font, b.TextSize = text, TXT, Enum.Font.GothamBold, 16
		b.Visible = false
		b.Parent = Gui
		corner(b, 16)
		return b
	end
	UpBtn, DnBtn = pad("UP", -196), pad("DN", -134)
	local function bind(b, set)
		b.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				set(true) b.BackgroundColor3 = ACCENT
			end
		end)
		b.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				set(false) b.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
			end
		end)
	end
	bind(UpBtn, function(v) S.FlyUp = v end)
	bind(DnBtn, function(v) S.FlyDown = v end)
end
local function setFly(v)
	S.Fly = v
	UpBtn.Visible = v
	DnBtn.Visible = v
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
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 9e9
	else
		if oldLight.A then Lighting.Ambient = oldLight.A end
		if oldLight.B then Lighting.Brightness = oldLight.B end
		if oldLight.C then Lighting.ClockTime = oldLight.C end
		if oldLight.F then Lighting.FogEnd = oldLight.F end
	end
end

local function closestHead()
	local my = hrp()
	if not my then return end
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
	local t, best, my = nil, 1e9, hrp()
	if not my then return end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local d = (my.Position - p.Character.HumanoidRootPart.Position).Magnitude
			if d < best then best, t = d, p end
		end
	end
	if t then hrp().CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
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

-- ESP objects
local espMap = {}
local function wipeESP(e)
	if e.bb then e.bb:Destroy() end
	if e.bar then e.bar:Destroy() end
	if e.hl then e.hl:Destroy() end
	if e.beam then e.beam:Destroy() end
	if e.a0 then e.a0:Destroy() end
	if e.a1 then e.a1:Destroy() end
end
local function clearESP()
	for _, e in pairs(espMap) do wipeESP(e) end
	table.clear(espMap)
end
local function ensureESP(plr)
	local e = espMap[plr]
	if e then return e end
	e = {}
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 180, 0, 28)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.AlwaysOnTop = true
	bb.Parent = Gui
	local tl = Instance.new("TextLabel")
	tl.BackgroundTransparency = 1
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.Font = Enum.Font.GothamBold
	tl.TextStrokeTransparency = 0.4
	tl.Parent = bb
	local bar = Instance.new("BillboardGui")
	bar.Size = UDim2.new(0, 70, 0, 6)
	bar.StudsOffset = Vector3.new(0, 2.5, 0)
	bar.AlwaysOnTop = true
	bar.Parent = Gui
	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	bg.BorderSizePixel = 0
	bg.Parent = bar
	corner(bg, 3)
	local fill = Instance.new("Frame")
	fill.Name = "F"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(80, 220, 110)
	fill.BorderSizePixel = 0
	fill.Parent = bg
	corner(fill, 3)
	e.bb, e.tl, e.bar, e.fill = bb, tl, bar, fill
	espMap[plr] = e
	return e
end
local function espColor()
	if S.ESPRainbow then return Color3.fromHSV((tick() * 0.18) % 1, 0.75, 1) end
	return S.ESPColor
end

-- 3D ESP preview
PPrev.ScrollBarThickness = 0
local PrevHost = Instance.new("Frame")
PrevHost.Size = UDim2.new(1, -4, 0, TOUCH and 300 or 280)
PrevHost.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
PrevHost.BackgroundTransparency = 0.2
PrevHost.BorderSizePixel = 0
PrevHost.LayoutOrder = 1
PrevHost.ZIndex = 4
PrevHost.Parent = PPrev
corner(PrevHost, 10)
local VP = Instance.new("ViewportFrame")
VP.Size = UDim2.new(1, -8, 1, -36)
VP.Position = UDim2.new(0, 4, 0, 4)
VP.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
VP.BorderSizePixel = 0
VP.ZIndex = 5
VP.Parent = PrevHost
corner(VP, 8)
local World = Instance.new("WorldModel")
World.Parent = VP
local VCam = Instance.new("Camera")
VCam.CFrame = CFrame.new(Vector3.new(4.2, 3.4, 7.2), Vector3.new(0, 2.8, 0))
VCam.Parent = VP
VP.CurrentCamera = VCam
local Dummy = Instance.new("Model")
Dummy.Name = "Dummy"
Dummy.Parent = World
local function dpart(name, size, cf, col)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Anchored, p.CanCollide = true, false
	p.Color, p.Material = col, Enum.Material.SmoothPlastic
	p.Parent = Dummy
	return p
end
local skin, shirt, pants = Color3.fromRGB(232, 201, 168), Color3.fromRGB(70, 140, 210), Color3.fromRGB(40, 48, 70)
local Torso = dpart("Torso", Vector3.new(2, 2, 1), CFrame.new(0, 3, 0), shirt)
local Head = dpart("Head", Vector3.new(1.15, 1.15, 1.15), CFrame.new(0, 4.55, 0), skin)
dpart("LA", Vector3.new(1, 2, 1), CFrame.new(-1.5, 3, 0), skin)
dpart("RA", Vector3.new(1, 2, 1), CFrame.new(1.5, 3, 0), skin)
dpart("LL", Vector3.new(1, 2, 1), CFrame.new(-0.5, 1, 0), pants)
dpart("RL", Vector3.new(1, 2, 1), CFrame.new(0.5, 1, 0), pants)
Dummy.PrimaryPart = Torso
local Outlines = {}
for _, p in ipairs(Dummy:GetChildren()) do
	if p:IsA("BasePart") then
		local o = p:Clone()
		o.Name = p.Name.."_o"
		o.Size = p.Size + Vector3.new(0.12, 0.12, 0.12)
		o.Material = Enum.Material.Neon
		o.Transparency = 0.35
		o.CanCollide = false
		o.Anchored = true
		o.Parent = Dummy
		Outlines[p] = o
	end
end
local Tag = Instance.new("TextLabel")
Tag.BackgroundTransparency = 1
Tag.Size = UDim2.new(1, 0, 0, 22)
Tag.Position = UDim2.new(0, 0, 0, 8)
Tag.Font = Enum.Font.GothamBold
Tag.TextStrokeTransparency = 0.4
Tag.ZIndex = 6
Tag.Parent = VP
local BarHold = Instance.new("Frame")
BarHold.Size = UDim2.new(0, 90, 0, 7)
BarHold.Position = UDim2.new(0.5, -45, 0, 32)
BarHold.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BarHold.BorderSizePixel = 0
BarHold.ZIndex = 6
BarHold.Parent = VP
corner(BarHold, 3)
local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0.72, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(80, 220, 110)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 7
BarFill.Parent = BarHold
corner(BarFill, 3)
local Tracer = Instance.new("Frame")
Tracer.AnchorPoint = Vector2.new(0.5, 1)
Tracer.Position = UDim2.new(0.5, 0, 1, -4)
Tracer.Size = UDim2.new(0, 2, 0, 70)
Tracer.BackgroundColor3 = ACCENT
Tracer.BorderSizePixel = 0
Tracer.ZIndex = 6
Tracer.Parent = VP
local PrevHint = Instance.new("TextLabel")
PrevHint.BackgroundTransparency = 1
PrevHint.Size = UDim2.new(1, -8, 0, 24)
PrevHint.Position = UDim2.new(0, 4, 1, -28)
PrevHint.Font = Enum.Font.Gotham
PrevHint.TextSize = 11
PrevHint.Text = "live preview  ·  rotate dummy"
PrevHint.TextColor3 = MUTED
PrevHint.ZIndex = 6
PrevHint.Parent = PrevHost

local function refreshPreview()
	local col = espColor()
	Tag.Visible = S.ESPName or S.ESPHP or S.ESPDist
	local bits = {}
	if S.ESPName then table.insert(bits, LP.Name) end
	if S.ESPHP then table.insert(bits, "72hp") end
	if S.ESPDist then table.insert(bits, "18m") end
	Tag.Text = table.concat(bits, "  |  ")
	Tag.TextColor3 = col
	Tag.TextSize = S.ESPText
	BarHold.Visible = S.ESPBar
	BarFill.BackgroundColor3 = col
	Tracer.Visible = S.ESPTracer
	Tracer.BackgroundColor3 = col
	for p, o in pairs(Outlines) do
		o.Color = col
		o.Transparency = S.ESPBox and math.clamp(S.ESPOutline + 0.25, 0.15, 0.8) or 1
		p.Color = S.ESPBox and col:Lerp(skin, S.ESPFill) or (p.Name == "Head" and skin or p.Color)
		if p.Name == "Torso" and not S.ESPBox then p.Color = shirt end
		if (p.Name == "LL" or p.Name == "RL") and not S.ESPBox then p.Color = pants end
		if (p.Name == "LA" or p.Name == "RA") and not S.ESPBox then p.Color = skin end
	end
end

-- Fling (IY-style BodyAngularVelocity + CFrame slam)
local FlingBusy = false
local Selected = nil
local function flingOne(plr)
	if not plr or plr == LP or FlingBusy then return end
	local r, h = hrp(), hum()
	local tc = plr.Character
	local tr = tc and tc:FindFirstChild("HumanoidRootPart")
	if not (r and h and tr) then return end
	FlingBusy = true
	local saved = r.CFrame
	local cols = {}
	for _, p in ipairs(char():GetDescendants()) do
		if p:IsA("BasePart") then
			table.insert(cols, {p, p.CanCollide})
			p.CanCollide = false
		end
	end
	local bv = Instance.new("BodyAngularVelocity")
	bv.MaxTorque = Vector3.new(1, 1, 1) * math.huge
	bv.P = math.huge
	bv.AngularVelocity = Vector3.new(0, 9e5, 0)
	bv.Parent = r
	h.Sit = true
	local t0 = tick()
	while tick() - t0 < 0.85 and tr.Parent and r.Parent do
		pcall(function()
			r.CFrame = tr.CFrame
			r.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
		end)
		RunService.Heartbeat:Wait()
	end
	pcall(function() bv:Destroy() end)
	for _, c in ipairs(cols) do pcall(function() c[1].CanCollide = c[2] end) end
	pcall(function()
		r.AssemblyAngularVelocity = Vector3.zero
		r.AssemblyLinearVelocity = Vector3.zero
		r.CFrame = saved
		h.Sit = false
	end)
	FlingBusy = false
end
local function flingAll()
	task.spawn(function()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP then
				flingOne(p)
				task.wait(0.2)
			end
		end
	end)
end

local SelRow = row(PFling, 30)
local SelLbl = lbl(SelRow, "target:  none", 10, 0, nil, 30, 12, ACCENT)
mkBtn(PFling, "Fling selected", function() if Selected then task.spawn(flingOne, Selected) end end)
mkBtn(PFling, "Fling ALL", flingAll)
mkToggle(PFling, "Walk fling", function() return S.WalkFling end, function(v) S.WalkFling = v end)
local ListHost = Instance.new("Frame")
ListHost.Size = UDim2.new(1, -4, 0, TOUCH and 210 or 180)
ListHost.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
ListHost.BackgroundTransparency = 0.2
ListHost.BorderSizePixel = 0
ListHost.LayoutOrder = nextOrder()
ListHost.ZIndex = 4
ListHost.Parent = PFling
corner(ListHost, 8)
local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -6, 1, -6)
List.Position = UDim2.new(0, 3, 0, 3)
List.BackgroundTransparency = 1
List.BorderSizePixel = 0
List.ScrollBarThickness = 3
List.ZIndex = 5
List.Parent = ListHost
local LL = Instance.new("UIListLayout")
LL.Padding = UDim.new(0, 4)
LL.Parent = List
LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	List.CanvasSize = UDim2.new(0, 0, 0, LL.AbsoluteContentSize.Y + 6)
end)
local function refreshPlayers()
	for _, c in ipairs(List:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1, -4, 0, 28)
			b.BackgroundColor3 = (Selected == p) and ACCENT or Color3.fromRGB(28, 32, 48)
			b.Text = "  "..p.Name
			b.TextColor3 = TXT
			b.Font = Enum.Font.Gotham
			b.TextSize = 13
			b.TextXAlignment = Enum.TextXAlignment.Left
			b.ZIndex = 6
			b.Parent = List
			corner(b, 6)
			b.MouseButton1Click:Connect(function()
				Selected = p
				SelLbl.Text = "target:  "..p.Name
				refreshPlayers()
			end)
		end
	end
end
mkBtn(PFling, "Refresh list", refreshPlayers)
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(function(p)
	if Selected == p then Selected = nil SelLbl.Text = "target:  none" end
	refreshPlayers()
end)
refreshPlayers()

-- Fly tab
section(PFly, "LOOK FLY")
mkToggle(PFly, "Fly", function() return S.Fly end, setFly)
mkHold(PFly, "HOLD  UP", function() S.FlyUp = true end, function() S.FlyUp = false end)
mkHold(PFly, "HOLD  DOWN", function() S.FlyDown = true end, function() S.FlyDown = false end)
mkSlider(PFly, "Fly speed", 20, 250, function() return S.FlySpeed end, function(v) S.FlySpeed = v end)
mkBtn(PFly, "Move: Look  (where you look)", function() S.FlyMode = "Look" end)
mkBtn(PFly, "Move: Horiz  (flat)", function() S.FlyMode = "Horiz" end)
mkBtn(PFly, "Face: Yaw", function() S.FlyFace = "Yaw" end)
mkBtn(PFly, "Face: Full look", function() S.FlyFace = "Look" end)
mkBtn(PFly, "Face: Off", function() S.FlyFace = "Off" end)

section(PMove, "MOVE")
mkToggle(PMove, "Noclip", function() return S.Noclip end, function(v) S.Noclip = v end)
mkToggle(PMove, "Infinite jump", function() return S.InfJump end, function(v) S.InfJump = v end)
mkToggle(PMove, "Speed bypass", function() return S.SpeedBypass end, function(v) S.SpeedBypass = v end)
mkSlider(PMove, "Walk speed", 16, 200, function() return S.Speed end, function(v) S.Speed = v end)

section(PESP, "ESP")
mkToggle(PESP, "ESP master", function() return S.ESP end, function(v) S.ESP = v refreshPreview() end)
mkToggle(PESP, "Names", function() return S.ESPName end, function(v) S.ESPName = v refreshPreview() end)
mkToggle(PESP, "Health text", function() return S.ESPHP end, function(v) S.ESPHP = v refreshPreview() end)
mkToggle(PESP, "Distance", function() return S.ESPDist end, function(v) S.ESPDist = v refreshPreview() end)
mkToggle(PESP, "Highlight box", function() return S.ESPBox end, function(v) S.ESPBox = v refreshPreview() end)
mkToggle(PESP, "Health bar", function() return S.ESPBar end, function(v) S.ESPBar = v refreshPreview() end)
mkToggle(PESP, "Tracers", function() return S.ESPTracer end, function(v) S.ESPTracer = v refreshPreview() end)
mkToggle(PESP, "Rainbow", function() return S.ESPRainbow end, function(v) S.ESPRainbow = v refreshPreview() end)
mkSlider(PESP, "Range", 50, 2000, function() return S.ESPMax end, function(v) S.ESPMax = v end)
mkSlider(PESP, "Text size", 10, 22, function() return S.ESPText end, function(v) S.ESPText = v refreshPreview() end)
mkSlider(PESP, "Fill (0 solid)", 0, 1, function() return S.ESPFill end, function(v) S.ESPFill = v refreshPreview() end, 2)
local function setCol(c) S.ESPColor = c refreshPreview() end
mkBtn(PESP, "Color cyan", function() setCol(Color3.fromRGB(90, 200, 255)) end)
mkBtn(PESP, "Color lime", function() setCol(Color3.fromRGB(80, 255, 120)) end)
mkBtn(PESP, "Color red", function() setCol(Color3.fromRGB(255, 70, 70)) end)
mkBtn(PESP, "Color gold", function() setCol(Color3.fromRGB(255, 200, 60)) end)
mkBtn(PESP, "Color pink", function() setCol(Color3.fromRGB(255, 110, 200)) end)

section(PVis, "WORLD")
mkToggle(PVis, "Fullbright", function() return S.Fullbright end, setFullbright)
mkToggle(PVis, "Xray", function() return S.Xray end, function(v)
	S.Xray = v
	if not v then
		for _, p in ipairs(workspace:GetDescendants()) do
			if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
		end
	end
end)
mkSlider(PVis, "FOV", 50, 120, function() return S.FOV end, function(v) S.FOV = v Camera.FieldOfView = v end)

section(PMisc, "MISC")
mkToggle(PMisc, "God (client)", function() return S.God end, function(v) S.God = v end)
mkToggle(PMisc, "Aimbot (hold RMB)", function() return S.Aimbot end, function(v) S.Aimbot = v end)
mkSlider(PMisc, "Aim smoothness", 0.1, 1, function() return S.AimbotSmooth end, function(v) S.AimbotSmooth = v end, 2)
mkToggle(PMisc, "Click / tap TP", function() return S.ClickTP end, function(v) S.ClickTP = v end)
mkBtn(PMisc, "TP nearest", tpNearest)
mkBtn(PMisc, "Reset", function() local h = hum() if h then h.Health = 0 end end)
mkBtn(PMisc, "Rejoin", function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end)

refreshPreview()

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
	local r = hrp()
	if hit and r then r.CFrame = CFrame.new(hit.Position + Vector3.new(0, 4, 0)) end
end)
LP.CharacterAdded:Connect(function()
	task.wait(0.6)
	local h = hum()
	if h then h.WalkSpeed = S.Speed if S.Fly then h.PlatformStand = true end end
end)

RunService.RenderStepped:Connect(function(dt)
	local c, h, r = char(), hum(), hrp()
	Camera.FieldOfView = S.FOV
	if currentPage == "Preview" then
		Dummy:PivotTo(Dummy:GetPivot() * CFrame.Angles(0, dt * 0.7, 0))
		for p, o in pairs(Outlines) do o.CFrame = p.CFrame end
		if S.ESPRainbow then refreshPreview() end
	end
	if S.Fly and r and h then flyStep(dt, r, h) end
	if S.SpeedBypass and r and h and not S.Fly then
		local md = h.MoveDirection
		if md.Magnitude > 0.05 then r.CFrame = r.CFrame + md.Unit * math.max(S.Speed - 16, 0) * dt end
	end
	if h then h.WalkSpeed = S.Speed if S.God then h.Health = h.MaxHealth end end
	if S.Noclip and c then
		for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
	end
	if S.WalkFling and r and not FlingBusy then
		r.AssemblyAngularVelocity = Vector3.new(0, 9e5, 0)
	end
	if S.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local hd = closestHead()
		if hd then Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, hd.Position), S.AimbotSmooth) end
	end
	local col = espColor()
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
						e.bb.Adornee = hd
						e.bb.Enabled = S.ESPName or S.ESPHP or S.ESPDist
						e.tl.TextColor3 = col
						e.tl.TextSize = S.ESPText
						local bits = {}
						if S.ESPName then table.insert(bits, plr.Name) end
						if S.ESPHP then table.insert(bits, math.floor(hh.Health).."hp") end
						if S.ESPDist then table.insert(bits, math.floor(dist).."m") end
						e.tl.Text = table.concat(bits, "  |  ")
						e.bar.Adornee = hd
						e.bar.Enabled = S.ESPBar
						e.fill.Size = UDim2.new(math.clamp(hh.Health / math.max(hh.MaxHealth, 1), 0, 1), 0, 1, 0)
						e.fill.BackgroundColor3 = col
						if S.ESPBox then
							if not e.hl or not e.hl.Parent then
								local hl = Instance.new("Highlight")
								hl.Parent = plr.Character
								e.hl = hl
							end
							e.hl.FillColor = col
							e.hl.OutlineColor = Color3.new(1, 1, 1)
							e.hl.FillTransparency = S.ESPFill
							e.hl.OutlineTransparency = S.ESPOutline
							e.hl.Enabled = true
						elseif e.hl then e.hl.Enabled = false end
						if S.ESPTracer then
							if not e.beam or not e.beam.Parent then
								local a0 = Instance.new("Attachment")
								a0.Parent = r
								local a1 = Instance.new("Attachment")
								a1.Parent = pr
								local bm = Instance.new("Beam")
								bm.Attachment0, bm.Attachment1 = a0, a1
								bm.Width0, bm.Width1 = 0.05, 0.05
								bm.FaceCamera = true
								bm.Parent = r
								e.a0, e.a1, e.beam = a0, a1, bm
							else
								e.a0.Parent = r
								e.a1.Parent = pr
							end
							e.beam.Color = ColorSequence.new(col)
							e.beam.Enabled = true
						elseif e.beam then e.beam.Enabled = false end
					end
				end
			end
		end
		for plr, e in pairs(espMap) do
			if not seen[plr] then wipeESP(e) espMap[plr] = nil end
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

print("Universal v8")
