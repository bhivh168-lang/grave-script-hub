--// GRAVE SCRIPT HUB — UI prototype (LocalScript)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local CFG = {
	PASSWORD = "zxmp",
	LOGO_ID = "",
}

local C = {
	bg      = Color3.fromHex("030305"),
	panel   = Color3.fromHex("08070D"),
	purple  = Color3.fromHex("8B2BFF"),
	neon    = Color3.fromHex("B44CFF"),
	soft    = Color3.fromHex("A98BFF"),
	text    = Color3.fromHex("FFFFFF"),
	text2   = Color3.fromHex("AAA5B8"),
	border  = Color3.fromHex("482078"),
}

local alive = true
local conns = {}
local function track(c) conns[#conns + 1] = c return c end

---------------------------------------------------------------- أدوات
local function new(class, props, children)
	local o = Instance.new(class)
	local parent = props.Parent
	props.Parent = nil
	for k, v in pairs(props) do o[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = o end
	o.Parent = parent
	return o
end
local function corner(r) return new("UICorner", {CornerRadius = UDim.new(0, r)}) end
local function stroke(color, th, tr)
	return new("UIStroke", {Color = color, Thickness = th or 1.5, Transparency = tr or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end
local function tween(o, t, goal)
	local tw = TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
	tw:Play()
	return tw
end
local function press(btn)
	local s = new("UIScale", {Parent = btn})
	btn.MouseButton1Down:Connect(function() tween(s, 0.08, {Scale = 0.94}) end)
	local function up() tween(s, 0.12, {Scale = 1}) end
	btn.MouseButton1Up:Connect(up)
	btn.MouseLeave:Connect(up)
end
local function raise(root, z)
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("GuiObject") then d.ZIndex = z end
	end
end

---------------------------------------------------------------- رسم بالخطوط
local function seg(parent, x1, y1, x2, y2, th, color, trans)
	local dx, dy = x2 - x1, y2 - y1
	local len = math.sqrt(dx * dx + dy * dy) + th * 0.6
	new("Frame", {Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
		Size = UDim2.fromOffset(len, th), Rotation = math.deg(math.atan2(dy, dx)),
		BackgroundColor3 = color, BackgroundTransparency = trans or 0, BorderSizePixel = 0},
		{new("UICorner", {CornerRadius = UDim.new(0.5, 0)})})
end
local function path(parent, pts, closed, th, color, trans)
	for i = 1, #pts - 1 do
		seg(parent, pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], th, color, trans)
	end
	if closed then
		seg(parent, pts[#pts][1], pts[#pts][2], pts[1][1], pts[1][2], th, color, trans)
	end
end
local function ring(parent, cx, cy, r, th, color)
	new("Frame", {Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx, cy),
		Size = UDim2.fromOffset(r * 2, r * 2), BackgroundTransparency = 1},
		{new("UICorner", {CornerRadius = UDim.new(0.5, 0)}),
		 new("UIStroke", {Color = color, Thickness = th})})
end
local function tint(holder, color)
	for _, d in ipairs(holder:GetDescendants()) do
		if d:IsA("UIStroke") then d.Color = color
		elseif d:IsA("Frame") and d.BackgroundTransparency < 1 then d.BackgroundColor3 = color end
	end
end

local function icon(parent, kind, S, pos, color)
	local h = new("Frame", {Parent = parent, BackgroundTransparency = 1, Size = UDim2.fromOffset(S, S), Position = pos})
	local k, th = S / 24, math.max(1.5, S * 0.085)
	local function L(list, closed)
		local o = {}
		for i, p in ipairs(list) do o[i] = {p[1] * k, p[2] * k} end
		path(h, o, closed, th, color)
	end
	local function R(cx, cy, r) ring(h, cx * k, cy * k, r * k, th, color) end
	if kind == "home" then
		L({{3, 11}, {12, 3}, {21, 11}}); L({{5, 10}, {5, 20}, {19, 20}, {19, 10}}); L({{10, 20}, {10, 14}, {14, 14}, {14, 20}})
	elseif kind == "cube" then
		L({{12, 2}, {21, 7}, {21, 17}, {12, 22}, {3, 17}, {3, 7}}, true); L({{3, 7}, {12, 12}, {21, 7}}); L({{12, 12}, {12, 22}})
	elseif kind == "star" then
		local pts = {}
		for i = 0, 9 do
			local r = (i % 2 == 0) and 10 or 4.3
			local a = math.rad(-90 + i * 36)
			pts[#pts + 1] = {12 + r * math.cos(a), 12.5 + r * math.sin(a)}
		end
		L(pts, true)
	elseif kind == "gear" then
		R(12, 12, 6); R(12, 12, 2.5)
		for i = 0, 7 do
			local a = math.rad(i * 45)
			L({{12 + 6 * math.cos(a), 12 + 6 * math.sin(a)}, {12 + 10 * math.cos(a), 12 + 10 * math.sin(a)}})
		end
	elseif kind == "search" then
		R(10, 10, 6.5); L({{14.8, 14.8}, {21, 21}})
	elseif kind == "lock" then
		L({{5, 10}, {19, 10}, {19, 21}, {5, 21}}, true); L({{8, 10}, {8, 7}, {10, 4}, {14, 4}, {16, 7}, {16, 10}})
	elseif kind == "close" then
		L({{4, 4}, {20, 20}}); L({{20, 4}, {4, 20}})
	end
	return h
end

-- التابوت (نفس الرسم دائماً)
local function coffin(parent, size, pos, anchor)
	local w, h = size.X.Offset, size.Y.Offset
	local holder = new("Frame", {Parent = parent, BackgroundTransparency = 1, Size = size,
		Position = pos or UDim2.new(), AnchorPoint = anchor or Vector2.zero})
	if CFG.LOGO_ID ~= "" then
		new("ImageLabel", {Parent = holder, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			Image = CFG.LOGO_ID, ScaleType = Enum.ScaleType.Fit})
		return holder
	end
	local kx, ky = w / 100, h / 130
	local th = math.max(1.4, w * 0.035)
	local function P(list)
		local o = {}
		for i, p in ipairs(list) do o[i] = {p[1] * kx, p[2] * ky} end
		return o
	end
	local outer = P{{38, 4}, {62, 4}, {87, 36}, {68, 122}, {32, 122}, {13, 36}}
	local inner = P{{40, 13}, {60, 13}, {78, 38}, {62, 112}, {38, 112}, {22, 38}}
	path(holder, outer, true, th * 3.4, C.purple, 0.72)
	path(holder, outer, true, th * 1.4, C.purple, 0)
	path(holder, inner, true, th, C.text, 0)
	seg(holder, 50 * kx, 34 * ky, 50 * kx, 84 * ky, th * 2.2, C.text)
	seg(holder, 37 * kx, 50 * ky, 63 * kx, 50 * ky, th * 2.2, C.text)
	return holder
end

local function wordmark(parent, size, pos, anchor, align)
	local f = new("Frame", {Parent = parent, BackgroundTransparency = 1, Size = size,
		Position = pos or UDim2.new(), AnchorPoint = anchor or Vector2.zero})
	local a = align or Enum.TextXAlignment.Center
	new("TextLabel", {Parent = f, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0.68),
		Text = "GRAVE", Font = Enum.Font.PermanentMarker, TextScaled = true,
		TextColor3 = Color3.fromHex("F3EAFF"), TextXAlignment = a, Rotation = -3},
		{stroke(C.purple, 2.2)})
	new("TextLabel", {Parent = f, BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.7),
		Size = UDim2.fromScale(1, 0.26), Text = "S C R I P T   H U B", Font = Enum.Font.GothamMedium,
		TextScaled = true, TextColor3 = Color3.fromHex("E4D4FF"), TextXAlignment = a})
	return f
end

---------------------------------------------------------------- ScreenGui
local gui = new("ScreenGui", {Name = "GraveScriptHub", ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, DisplayOrder = 50,
	Parent = player:WaitForChild("PlayerGui")})

-- حذف السكريبت كاملاً
local function destroyAll()
	alive = false
	for _, c in ipairs(conns) do c:Disconnect() end
	gui:Destroy()
	script:Destroy()
end

---------------------------------------------------------------- الدخول
local login = new("Frame", {Parent = gui, Size = UDim2.fromOffset(440, 400), AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = C.panel},
	{corner(18), stroke(C.purple, 2)})
local loginScale = new("UIScale", {Parent = login})
local function fit()
	local s = gui.AbsoluteSize
	loginScale.Scale = math.min(1, s.X * 0.94 / 440, s.Y * 0.94 / 400)
end
track(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit))
fit()

coffin(login, UDim2.fromOffset(64, 83), UDim2.new(0.5, 0, 0, 10), Vector2.new(0.5, 0))
wordmark(login, UDim2.fromOffset(300, 90), UDim2.new(0.5, 0, 0, 98), Vector2.new(0.5, 0))

local pwBox = new("TextBox", {Parent = login, Size = UDim2.fromOffset(370, 46), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 205), BackgroundColor3 = C.bg, Text = "", PlaceholderText = "Enter Password...",
	PlaceholderColor3 = C.text2, TextColor3 = C.text, TextTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false},
	{corner(12), stroke(C.purple, 1.5),
	 new("UIPadding", {PaddingLeft = UDim.new(0, 44), PaddingRight = UDim.new(0, 14)})})
icon(pwBox, "lock", 18, UDim2.fromOffset(-32, 14), C.soft)

-- طبقة النجوم فوق الحقل (النص الحقيقي مخفي)
local mask = new("TextLabel", {Parent = pwBox, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
	Text = "", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 22,
	TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 3})
track(pwBox:GetPropertyChangedSignal("Text"):Connect(function()
	mask.Text = string.rep("*", #pwBox.Text)
end))

local loginBtn = new("TextButton", {Parent = login, Size = UDim2.fromOffset(240, 46), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 268), BackgroundColor3 = C.bg, Text = "LOGIN", TextColor3 = C.text,
	Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false}, {corner(12), stroke(C.neon, 2)})
press(loginBtn)

local errLbl = new("TextLabel", {Parent = login, BackgroundTransparency = 1, Size = UDim2.fromOffset(300, 22),
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 8, 0, 332), Text = "",
	TextColor3 = C.text2, Font = Enum.Font.Gotham, TextSize = 13})
local errIcon = icon(login, "lock", 14, UDim2.new(0.5, -118, 0, 336), C.text2)
errIcon.Visible = false

---------------------------------------------------------------- النافذة
local hub = new("Frame", {Parent = gui, Visible = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)})

local win = new("CanvasGroup", {Parent = hub, Size = UDim2.fromScale(0.9, 0.86), AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = C.panel, GroupTransparency = 1},
	{corner(18), new("UISizeConstraint", {MaxSize = Vector2.new(780, 460), MinSize = Vector2.new(300, 220)})})
local winStroke = stroke(C.purple, 2); winStroke.Parent = win
local winScale = new("UIScale", {Parent = win, Scale = 0.92})

task.spawn(function()
	while alive do
		tween(winStroke, 2, {Transparency = 0.45})
		task.wait(2)
		if not alive then break end
		tween(winStroke, 2, {Transparency = 0})
		task.wait(2)
	end
end)

local header = new("Frame", {Parent = win, Size = UDim2.new(1, 0, 0, 62), BackgroundTransparency = 1})
coffin(header, UDim2.fromOffset(40, 52), UDim2.fromOffset(14, 5))
wordmark(header, UDim2.fromOffset(120, 50), UDim2.fromOffset(62, 6), nil, Enum.TextXAlignment.Left)
local closeBtn = new("TextButton", {Parent = header, Size = UDim2.fromOffset(46, 46), AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -8, 0.5, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false})
icon(closeBtn, "close", 22, UDim2.fromOffset(12, 12), C.text)
press(closeBtn)
new("Frame", {Parent = win, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, 62),
	BackgroundColor3 = C.border, BorderSizePixel = 0})

local side = new("Frame", {Parent = win, Position = UDim2.fromOffset(0, 63), Size = UDim2.new(0.26, 0, 1, -63),
	BackgroundColor3 = Color3.fromHex("050409"), BorderSizePixel = 0},
	{new("UISizeConstraint", {MinSize = Vector2.new(110, 0), MaxSize = Vector2.new(170, math.huge)}),
	 new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}),
	 new("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})})

local pages = {}

local content = new("Frame", {Parent = win, BackgroundTransparency = 1, Position = UDim2.new(0.26, 8, 0, 74),
	Size = UDim2.new(0.74, -20, 1, -86)})
new("TextBox", {Parent = content, Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = C.bg, Text = "",
	PlaceholderText = "Search...", PlaceholderColor3 = C.text2, TextColor3 = C.text, Font = Enum.Font.GothamMedium,
	TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false},
	{corner(12), stroke(C.purple, 1.5), new("UIPadding", {PaddingLeft = UDim.new(0, 42), PaddingRight = UDim.new(0, 12)})})
icon(content, "search", 20, UDim2.fromOffset(11, 12), C.soft)

local pageHolder = new("Frame", {Parent = content, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 1, -52)})

-- Page 1: Home
local homePage = new("Frame", {Parent = pageHolder, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = true})
local card = new("Frame", {Parent = homePage, Size = UDim2.fromOffset(130, 130), Position = UDim2.fromOffset(0, 4),
	BackgroundColor3 = C.bg}, {corner(14), stroke(C.purple, 1.5)})
coffin(card, UDim2.fromOffset(38, 50), UDim2.new(0.5, 0, 0, 10), Vector2.new(0.5, 0))
new("TextLabel", {Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.fromOffset(0, 72), Text = "Test Item", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 14})
new("TextLabel", {Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.fromOffset(0, 94), Text = "Interface Preview", TextColor3 = C.text2, Font = Enum.Font.Gotham, TextSize = 11})

-- Page 2: Items
local itemsPage = new("ScrollingFrame", {Parent = pageHolder, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
	CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = C.purple, Visible = false},
	{new("UIGridLayout", {CellSize = UDim2.fromOffset(140, 160), CellPadding = UDim2.fromOffset(12, 12)}),
	 new("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 10)})})

-- DisasterDancer Card
local ddCard = new("Frame", {Parent = itemsPage, BackgroundColor3 = C.bg}, {corner(14), stroke(C.purple, 1.5)})
coffin(ddCard, UDim2.fromOffset(38, 48), UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
new("TextLabel", {Parent = ddCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 62), Text = "DisasterDancer", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 13})
new("TextLabel", {Parent = ddCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
	Position = UDim2.fromOffset(0, 82), Text = "Script", TextColor3 = C.text2, Font = Enum.Font.Gotham, TextSize = 11})

local execBtn = new("TextButton", {Parent = ddCard, Size = UDim2.fromOffset(116, 32), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 114), BackgroundColor3 = C.panel, Text = "EXECUTE", TextColor3 = C.text,
	Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false}, {corner(8), stroke(C.neon, 1.5)})
press(execBtn)
execBtn.Activated:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SaikiWithTheBanHammer/ScriptBlox/refs/heads/main/DisasterDancer"))()
end)

-- Gaze Emotes V1 Card
local geCard = new("Frame", {Parent = itemsPage, BackgroundColor3 = C.bg}, {corner(14), stroke(C.purple, 1.5)})
coffin(geCard, UDim2.fromOffset(38, 48), UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
new("TextLabel", {Parent = geCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 62), Text = "Gaze Emotes V1", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 13})
new("TextLabel", {Parent = geCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
	Position = UDim2.fromOffset(0, 82), Text = "Script", TextColor3 = C.text2, Font = Enum.Font.Gotham, TextSize = 11})

local geExecBtn = new("TextButton", {Parent = geCard, Size = UDim2.fromOffset(116, 32), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 114), BackgroundColor3 = C.panel, Text = "EXECUTE", TextColor3 = C.text,
	Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false}, {corner(8), stroke(C.neon, 1.5)})
press(geExecBtn)
geExecBtn.Activated:Connect(function()
	loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Gaze-emotes-V1-54374"))()
end)

-- TySh Client Card
local tyCard = new("Frame", {Parent = itemsPage, BackgroundColor3 = C.bg}, {corner(14), stroke(C.purple, 1.5)})
coffin(tyCard, UDim2.fromOffset(38, 48), UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
new("TextLabel", {Parent = tyCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 62), Text = "TySh Client", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 13})
new("TextLabel", {Parent = tyCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
	Position = UDim2.fromOffset(0, 82), Text = "Script", TextColor3 = C.text2, Font = Enum.Font.Gotham, TextSize = 11})

local tyExecBtn = new("TextButton", {Parent = tyCard, Size = UDim2.fromOffset(116, 32), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 114), BackgroundColor3 = C.panel, Text = "EXECUTE", TextColor3 = C.text,
	Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false}, {corner(8), stroke(C.neon, 1.5)})
press(tyExecBtn)
tyExecBtn.Activated:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Letmechn/TySh-Loader/main/TySh-client"))()
end)

-- FH7 Script Card
local fhCard = new("Frame", {Parent = itemsPage, BackgroundColor3 = C.bg}, {corner(14), stroke(C.purple, 1.5)})
coffin(fhCard, UDim2.fromOffset(38, 48), UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
new("TextLabel", {Parent = fhCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 62), Text = "FH7 Script", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 13})
new("TextLabel", {Parent = fhCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
	Position = UDim2.fromOffset(0, 82), Text = "Script", TextColor3 = C.text2, Font = Enum.Font.Gotham, TextSize = 11})

local fhExecBtn = new("TextButton", {Parent = fhCard, Size = UDim2.fromOffset(116, 32), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 114), BackgroundColor3 = C.panel, Text = "EXECUTE", TextColor3 = C.text,
	Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false}, {corner(8), stroke(C.neon, 1.5)})
press(fhExecBtn)
fhExecBtn.Activated:Connect(function()
	loadstring(game:HttpGet('https://raw.githubusercontent.com/DevFHD1/FH7-Script/refs/heads/main/Q'))()
end)

-- UgiX Card
local ugiCard = new("Frame", {Parent = itemsPage, BackgroundColor3 = C.bg}, {corner(14), stroke(C.purple, 1.5)})
coffin(ugiCard, UDim2.fromOffset(38, 48), UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
new("TextLabel", {Parent = ugiCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 62), Text = "UgiX", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 13})
new("TextLabel", {Parent = ugiCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
	Position = UDim2.fromOffset(0, 82), Text = "Script", TextColor3 = C.text2, Font = Enum.Font.Gotham, TextSize = 11})

local ugiExecBtn = new("TextButton", {Parent = ugiCard, Size = UDim2.fromOffset(116, 32), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 114), BackgroundColor3 = C.panel, Text = "EXECUTE", TextColor3 = C.text,
	Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false}, {corner(8), stroke(C.neon, 1.5)})
press(ugiExecBtn)
ugiExecBtn.Activated:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Lx8Lx/UgiX1/refs/heads/main/UgiX.txt"))()
end)

-- Fly V3 Card
local flyCard = new("Frame", {Parent = itemsPage, BackgroundColor3 = C.bg}, {corner(14), stroke(C.purple, 1.5)})
coffin(flyCard, UDim2.fromOffset(38, 48), UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
new("TextLabel", {Parent = flyCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 62), Text = "Fly V3 by Hibatzzz", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 12})
new("TextLabel", {Parent = flyCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
	Position = UDim2.fromOffset(0, 82), Text = "Script", TextColor3 = C.text2, Font = Enum.Font.Gotham, TextSize = 11})

local flyExecBtn = new("TextButton", {Parent = flyCard, Size = UDim2.fromOffset(116, 32), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 114), BackgroundColor3 = C.panel, Text = "EXECUTE", TextColor3 = C.text,
	Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false}, {corner(8), stroke(C.neon, 1.5)})
press(flyExecBtn)
flyExecBtn.Activated:Connect(function()
	loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-fly-v3-by-hibatzzz-243731"))()
end)

-- FLY GUI V3/V4 (MOBILE) Card
local flyMobCard = new("Frame", {Parent = itemsPage, BackgroundColor3 = C.bg}, {corner(14), stroke(C.purple, 1.5)})
coffin(flyMobCard, UDim2.fromOffset(38, 48), UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
new("TextLabel", {Parent = flyMobCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 62), Text = "FLY GUI V3/V4", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 12})
new("TextLabel", {Parent = flyMobCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
	Position = UDim2.fromOffset(0, 82), Text = "Mobile", TextColor3 = C.text2, Font = Enum.Font.Gotham, TextSize = 11})

local flyMobExecBtn = new("TextButton", {Parent = flyMobCard, Size = UDim2.fromOffset(116, 32), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 114), BackgroundColor3 = C.panel, Text = "EXECUTE", TextColor3 = C.text,
	Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false}, {corner(8), stroke(C.neon, 1.5)})
press(flyMobExecBtn)
flyMobExecBtn.Activated:Connect(function()
	loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-FLY-GUI-V3-V4-(MOBILE)-230975"))()
end)

-- DeveloperGAME707 Script Card
local devCard = new("Frame", {Parent = itemsPage, BackgroundColor3 = C.bg}, {corner(14), stroke(C.purple, 1.5)})
coffin(devCard, UDim2.fromOffset(38, 48), UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
new("TextLabel", {Parent = devCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 62), Text = "DeveloperGAME707", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 11})
new("TextLabel", {Parent = devCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
	Position = UDim2.fromOffset(0, 82), Text = "Script", TextColor3 = C.text2, Font = Enum.Font.Gotham, TextSize = 11})

local devExecBtn = new("TextButton", {Parent = devCard, Size = UDim2.fromOffset(116, 32), AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 114), BackgroundColor3 = C.panel, Text = "EXECUTE", TextColor3 = C.text,
	Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false}, {corner(8), stroke(C.neon, 1.5)})
press(devExecBtn)
devExecBtn.Activated:Connect(function()
	loadstring(game:HttpGet("https://gist.githubusercontent.com/DeveloperGAME707/65f355ef6a4af6b2f74fbe21cad0094d/raw"))()
end)

-- Page 3 & 4
local favPage = new("Frame", {Parent = pageHolder, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false})
local setPage = new("Frame", {Parent = pageHolder, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false})

pages[1] = homePage
pages[2] = itemsPage
pages[3] = favPage
pages[4] = setPage

local navItems, selected = {}, nil
local function select(item, index)
	if selected == item then return end
	for i, it in ipairs(navItems) do
		local on = (it == item)
		tween(it.btn, 0.15, {BackgroundTransparency = on and 0.75 or 1})
		tween(it.bar, 0.15, {BackgroundTransparency = on and 0 or 1})
		it.btn.TextColor3 = on and C.text or C.text2
		tint(it.ico, on and C.text or C.soft)
		if pages[i] then
			pages[i].Visible = on
		end
	end
	selected = item
end

for i, d in ipairs({{"home", "Home"}, {"cube", "Items"}, {"star", "Favorites"}, {"gear", "Settings"}}) do
	local btn = new("TextButton", {Parent = side, LayoutOrder = i, Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = C.purple, BackgroundTransparency = 1, Text = "         " .. d[2],
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.text2,
		Font = Enum.Font.GothamMedium, TextSize = 14, AutoButtonColor = false}, {corner(10)})
	local ico = icon(btn, d[1], 22, UDim2.fromOffset(10, 12), C.soft)
	local bar = new("Frame", {Parent = btn, Size = UDim2.new(0, 4, 0.7, 0), AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -8, 0.5, 0), BackgroundColor3 = C.neon, BackgroundTransparency = 1,
		BorderSizePixel = 0}, {corner(2)})
	local item = {btn = btn, bar = bar, ico = ico}
	navItems[i] = item
	press(btn)
	btn.Activated:Connect(function() select(item, i) end)
end
select(navItems[1], 1)

---------------------------------------------------------------- فتح/إغلاق
local isOpen = false
local function setOpen(open)
	isOpen = open
	if open then
		hub.Visible = true
		tween(win, 0.22, {GroupTransparency = 0})
		tween(winScale, 0.22, {Scale = 1})
	else
		tween(win, 0.18, {GroupTransparency = 1})
		tween(winScale, 0.18, {Scale = 0.92}).Completed:Connect(function()
			if not isOpen then hub.Visible = false end
		end)
	end
end
closeBtn.Activated:Connect(destroyAll) -- X = حذف كامل

---------------------------------------------------------------- الزر العائم (أصغر + التابوت فيه)
local fab = new("TextButton", {Parent = gui, Visible = false, Size = UDim2.fromOffset(46, 46),
	Position = UDim2.new(0, 12, 0.4, 0), BackgroundColor3 = C.bg, Text = "", AutoButtonColor = false, ZIndex = 20},
	{new("UICorner", {CornerRadius = UDim.new(1, 0)}), stroke(C.neon, 1.5)})
local fabCoffin = coffin(fab, UDim2.fromOffset(25, 32), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
fabCoffin.ZIndex = 21
raise(fabCoffin, 22)

local dragging, moved, startMouse, startPos = false, false, Vector3.zero, Vector2.zero
fab.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging, moved = true, false
		startMouse = i.Position
		startPos = fab.AbsolutePosition - gui.AbsolutePosition
	end
end)
track(UIS.InputChanged:Connect(function(i)
	if not dragging then return end
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - startMouse
		if not moved and d.Magnitude < 8 then return end
		moved = true
		local max = gui.AbsoluteSize - fab.AbsoluteSize
		fab.Position = UDim2.fromOffset(math.clamp(startPos.X + d.X, 0, max.X), math.clamp(startPos.Y + d.Y, 0, max.Y))
	end
end))
track(UIS.InputEnded:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then
		dragging = false
		if not moved then setOpen(not isOpen) end
	end
end))

---------------------------------------------------------------- تسجيل الدخول
local function tryLogin()
	if pwBox.Text == CFG.PASSWORD then
		login.Visible = false
		fab.Visible = true
		setOpen(true)
	else
		errLbl.Text = "Wrong password? Try again..."
		errIcon.Visible = true
	end
end
loginBtn.Activated:Connect(tryLogin)
pwBox.FocusLost:Connect(function(enter) if enter then tryLogin() end end)
