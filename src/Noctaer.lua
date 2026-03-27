-- by noctaer

local Noctaer = {}
Noctaer.__index = Noctaer
Noctaer.Flags = {}

local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local HttpService     = game:GetService("HttpService")
local Players         = game:GetService("Players")

local Theme = {
	Background        = Color3.fromRGB(12, 12, 14),
	Surface           = Color3.fromRGB(18, 18, 21),
	SurfaceHover      = Color3.fromRGB(24, 24, 28),
	Border            = Color3.fromRGB(32, 32, 38),
	BorderAccent      = Color3.fromRGB(50, 50, 60),
	Accent            = Color3.fromRGB(99, 102, 241),
	AccentDim         = Color3.fromRGB(60, 62, 150),
	TextPrimary       = Color3.fromRGB(220, 220, 228),
	TextSecondary     = Color3.fromRGB(110, 110, 125),
	TextMuted         = Color3.fromRGB(65, 65, 78),
	ToggleOn          = Color3.fromRGB(99, 102, 241),
	ToggleOff         = Color3.fromRGB(38, 38, 46),
	SliderTrack       = Color3.fromRGB(28, 28, 34),
	SliderFill        = Color3.fromRGB(99, 102, 241),
	Danger            = Color3.fromRGB(180, 60, 60),
	NotifBg           = Color3.fromRGB(16, 16, 20),
}

local CONFIG = {
	WindowW     = 520,
	WindowH     = 440,
	TopbarH     = 42,
	TabListW    = 130,
	ElementH    = 38,
	Padding     = 10,
	Radius      = 8,
	SmallRadius = 5,
	TweenFast   = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	TweenMed    = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	TweenSlow   = TweenInfo.new(0.52, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}

local function Tween(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

local function MakeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or CONFIG.Radius)
	c.Parent = parent
	return c
end

local function MakeStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Border
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function MakePadding(parent, top, bottom, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop    = UDim.new(0, top    or CONFIG.Padding)
	p.PaddingBottom = UDim.new(0, bottom or CONFIG.Padding)
	p.PaddingLeft   = UDim.new(0, left   or CONFIG.Padding)
	p.PaddingRight  = UDim.new(0, right  or CONFIG.Padding)
	p.Parent = parent
	return p
end

local function MakeLabel(parent, text, size, color, xalign)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text or ""
	l.TextSize = size or 13
	l.TextColor3 = color or Theme.TextPrimary
	l.Font = Enum.Font.Gotham
	l.TextXAlignment = xalign or Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.Size = UDim2.new(1, 0, 1, 0)
	l.Parent = parent
	return l
end

local function MakeFrame(parent, bg, size, pos)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = bg or Theme.Surface
	f.BorderSizePixel = 0
	f.Size = size or UDim2.new(1, 0, 0, CONFIG.ElementH)
	f.Position = pos or UDim2.new(0, 0, 0, 0)
	f.Parent = parent
	return f
end

local function MakeButton(parent, bg, size, pos)
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = bg or Theme.Surface
	b.BorderSizePixel = 0
	b.Size = size or UDim2.new(1, 0, 0, CONFIG.ElementH)
	b.Position = pos or UDim2.new(0, 0, 0, 0)
	b.Text = ""
	b.AutoButtonColor = false
	b.Parent = parent
	return b
end

local function GetGui()
	if gethui then
		return gethui()
	elseif syn and syn.protect_gui then
		local sg = Instance.new("ScreenGui")
		syn.protect_gui(sg)
		sg.Parent = game:GetService("CoreGui")
		return sg
	else
		local sg = Instance.new("ScreenGui")
		sg.Parent = game:GetService("CoreGui")
		return sg
	end
end

local function SetupDrag(dragRegion, targetFrame)
	local dragging, dragStart, startPos = false, nil, nil

	dragRegion.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		dragging = true
		dragStart = input.Position
		startPos = targetFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local delta = input.Position - dragStart
		targetFrame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end)
end

local NotifQueue = {}
local NotifActive = 0
local NotifContainer

local function InitNotifContainer(screenGui)
	NotifContainer = Instance.new("Frame")
	NotifContainer.Name = "Notifs"
	NotifContainer.BackgroundTransparency = 1
	NotifContainer.Size = UDim2.new(0, 300, 1, 0)
	NotifContainer.Position = UDim2.new(1, -310, 0, 0)
	NotifContainer.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.Padding = UDim.new(0, 6)
	layout.Parent = NotifContainer

	MakePadding(NotifContainer, 10, 10, 0, 0)
end

function Noctaer:Notify(opts)
	local title    = opts.Title or "Notification"
	local content  = opts.Content or ""
	local duration = opts.Duration or 5

	local card = MakeFrame(NotifContainer, Theme.NotifBg, UDim2.new(1, 0, 0, 64))
	card.ClipsDescendants = true
	card.LayoutOrder = NotifActive
	NotifActive = NotifActive + 1
	MakeCorner(card, CONFIG.SmallRadius)
	MakeStroke(card, Theme.Border)

	local accent = MakeFrame(card, Theme.Accent, UDim2.new(0, 3, 1, 0), UDim2.new(0, 0, 0, 0))
	MakeCorner(accent, 2)

	local titleL = Instance.new("TextLabel")
	titleL.BackgroundTransparency = 1
	titleL.Text = title
	titleL.TextSize = 13
	titleL.Font = Enum.Font.GothamBold
	titleL.TextColor3 = Theme.TextPrimary
	titleL.TextXAlignment = Enum.TextXAlignment.Left
	titleL.Size = UDim2.new(1, -18, 0, 20)
	titleL.Position = UDim2.new(0, 14, 0, 10)
	titleL.Parent = card

	local contentL = Instance.new("TextLabel")
	contentL.BackgroundTransparency = 1
	contentL.Text = content
	contentL.TextSize = 11
	contentL.Font = Enum.Font.Gotham
	contentL.TextColor3 = Theme.TextSecondary
	contentL.TextXAlignment = Enum.TextXAlignment.Left
	contentL.TextWrapped = true
	contentL.Size = UDim2.new(1, -18, 0, 28)
	contentL.Position = UDim2.new(0, 14, 0, 30)
	contentL.Parent = card

	card.BackgroundTransparency = 1
	titleL.TextTransparency = 1
	contentL.TextTransparency = 1

	Tween(card, CONFIG.TweenMed, {BackgroundTransparency = 0})
	Tween(titleL, CONFIG.TweenMed, {TextTransparency = 0})
	Tween(contentL, CONFIG.TweenMed, {TextTransparency = 0.2})

	task.delay(duration, function()
		Tween(card, CONFIG.TweenMed, {BackgroundTransparency = 1})
		Tween(titleL, CONFIG.TweenMed, {TextTransparency = 1})
		Tween(contentL, CONFIG.TweenMed, {TextTransparency = 1})
		task.delay(0.35, function()
			Tween(card, CONFIG.TweenFast, {Size = UDim2.new(1, 0, 0, 0)})
			task.delay(0.2, function() card:Destroy() end)
		end)
	end)
end

function Noctaer:CreateWindow(opts)
	local windowTitle    = opts.Title or "Noctaer"
	local windowSubtitle = opts.Subtitle or ""
	local hideKey        = opts.HideKey or Enum.KeyCode.RightControl

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Noctaer_" .. HttpService:GenerateGUID(false):sub(1, 6)
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999

	local guiParent = GetGui()
	if guiParent:IsA("ScreenGui") then
		screenGui.Parent = guiParent.Parent
	else
		screenGui.Parent = guiParent
	end

	for _, existing in ipairs(guiParent:GetChildren()) do
		if existing ~= screenGui and existing.Name:find("Noctaer") then
			existing:Destroy()
		end
	end

	InitNotifContainer(screenGui)

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Size = UDim2.new(0, CONFIG.WindowW + 40, 0, CONFIG.WindowH + 40)
	shadow.Position = UDim2.new(0.5, -(CONFIG.WindowW / 2) - 20, 0.5, -(CONFIG.WindowH / 2) - 20)
	shadow.ZIndex = 0
	shadow.Parent = screenGui

	local win = MakeFrame(screenGui, Theme.Background,
		UDim2.new(0, CONFIG.WindowW, 0, CONFIG.WindowH),
		UDim2.new(0.5, -CONFIG.WindowW / 2, 0.5, -CONFIG.WindowH / 2)
	)
	win.Name = "Window"
	win.ClipsDescendants = false
	MakeCorner(win, CONFIG.Radius)
	MakeStroke(win, Theme.Border)

	local topbar = MakeFrame(win, Theme.Surface,
		UDim2.new(1, 0, 0, CONFIG.TopbarH),
		UDim2.new(0, 0, 0, 0)
	)
	MakeCorner(topbar, CONFIG.Radius)

	local topbarFix = MakeFrame(topbar, Theme.Surface,
		UDim2.new(1, 0, 0, CONFIG.Radius),
		UDim2.new(0, 0, 1, -CONFIG.Radius)
	)

	local divider = MakeFrame(win, Theme.Border,
		UDim2.new(1, 0, 0, 1),
		UDim2.new(0, 0, 0, CONFIG.TopbarH)
	)

	local accentBar = MakeFrame(win, Theme.Accent,
		UDim2.new(0, 0, 0, 1),
		UDim2.new(0, 0, 0, CONFIG.TopbarH)
	)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = windowTitle
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextColor3 = Theme.TextPrimary
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Size = UDim2.new(0, 200, 1, 0)
	titleLabel.Position = UDim2.new(0, 14, 0, 0)
	titleLabel.Parent = topbar

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Text = windowSubtitle
	subtitleLabel.TextSize = 11
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextColor3 = Theme.TextMuted
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.Size = UDim2.new(0, 200, 0, 14)
	subtitleLabel.Position = UDim2.new(0, 14, 0.5, 2)
	subtitleLabel.Parent = topbar

	if windowSubtitle == "" then
		titleLabel.AnchorPoint = Vector2.new(0, 0.5)
		titleLabel.Position = UDim2.new(0, 14, 0.5, 0)
		subtitleLabel.Visible = false
	end

	local closeBtn = MakeButton(topbar, Color3.fromRGB(0,0,0),
		UDim2.new(0, 28, 0, 28),
		UDim2.new(1, -36, 0.5, -14)
	)
	closeBtn.BackgroundTransparency = 1
	MakeCorner(closeBtn, 4)

	local closeIcon = Instance.new("TextLabel")
	closeIcon.BackgroundTransparency = 1
	closeIcon.Text = "✕"
	closeIcon.TextSize = 12
	closeIcon.Font = Enum.Font.GothamBold
	closeIcon.TextColor3 = Theme.TextMuted
	closeIcon.Size = UDim2.new(1, 0, 1, 0)
	closeIcon.Parent = closeBtn

	closeBtn.MouseEnter:Connect(function()
		Tween(closeIcon, CONFIG.TweenFast, {TextColor3 = Theme.TextPrimary})
		Tween(closeBtn, CONFIG.TweenFast, {BackgroundTransparency = 0.85})
	end)
	closeBtn.MouseLeave:Connect(function()
		Tween(closeIcon, CONFIG.TweenFast, {TextColor3 = Theme.TextMuted})
		Tween(closeBtn, CONFIG.TweenFast, {BackgroundTransparency = 1})
	end)
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	local minimizeBtn = MakeButton(topbar, Color3.fromRGB(0,0,0),
		UDim2.new(0, 28, 0, 28),
		UDim2.new(1, -70, 0.5, -14)
	)
	minimizeBtn.BackgroundTransparency = 1
	MakeCorner(minimizeBtn, 4)

	local minimizeIcon = Instance.new("TextLabel")
	minimizeIcon.BackgroundTransparency = 1
	minimizeIcon.Text = "─"
	minimizeIcon.TextSize = 12
	minimizeIcon.Font = Enum.Font.GothamBold
	minimizeIcon.TextColor3 = Theme.TextMuted
	minimizeIcon.Size = UDim2.new(1, 0, 1, 0)
	minimizeIcon.Parent = minimizeBtn

	minimizeBtn.MouseEnter:Connect(function()
		Tween(minimizeIcon, CONFIG.TweenFast, {TextColor3 = Theme.TextPrimary})
		Tween(minimizeBtn, CONFIG.TweenFast, {BackgroundTransparency = 0.85})
	end)
	minimizeBtn.MouseLeave:Connect(function()
		Tween(minimizeIcon, CONFIG.TweenFast, {TextColor3 = Theme.TextMuted})
		Tween(minimizeBtn, CONFIG.TweenFast, {BackgroundTransparency = 1})
	end)

	local minimized = false
	local body = MakeFrame(win, Color3.fromRGB(0,0,0),
		UDim2.new(1, 0, 1, -CONFIG.TopbarH),
		UDim2.new(0, 0, 0, CONFIG.TopbarH)
	)
	body.BackgroundTransparency = 1

	minimizeBtn.MouseButton1Click:Connect(function()
		if minimized then
			minimized = false
			Tween(win, CONFIG.TweenMed, {Size = UDim2.new(0, CONFIG.WindowW, 0, CONFIG.WindowH)})
			Tween(shadow, CONFIG.TweenMed, {Size = UDim2.new(0, CONFIG.WindowW + 40, 0, CONFIG.WindowH + 40)})
			task.delay(0.1, function() body.Visible = true end)
		else
			minimized = true
			body.Visible = false
			Tween(win, CONFIG.TweenMed, {Size = UDim2.new(0, CONFIG.WindowW, 0, CONFIG.TopbarH)})
			Tween(shadow, CONFIG.TweenMed, {Size = UDim2.new(0, CONFIG.WindowW + 40, 0, CONFIG.TopbarH + 40)})
		end
	end)

	SetupDrag(topbar, win)

	local hidden = false
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == hideKey then
			hidden = not hidden
			Tween(screenGui, CONFIG.TweenMed, {})
			win.Visible = not hidden
			shadow.Visible = not hidden
		end
	end)

	local tabList = MakeFrame(body, Theme.Surface,
		UDim2.new(0, CONFIG.TabListW, 1, 0),
		UDim2.new(0, 0, 0, 0)
	)
	MakeStroke(tabList, Theme.Border)
	local tabListCorner = Instance.new("UICorner")
	tabListCorner.CornerRadius = UDim.new(0, CONFIG.Radius)
	tabListCorner.Parent = tabList

	local tabListFix = MakeFrame(tabList, Theme.Surface,
		UDim2.new(0, CONFIG.Radius, 1, 0),
		UDim2.new(1, -CONFIG.Radius, 0, 0)
	)

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Padding = UDim.new(0, 2)
	tabListLayout.Parent = tabList
	MakePadding(tabList, 8, 8, 6, 6)

	local contentArea = MakeFrame(body, Color3.fromRGB(0,0,0),
		UDim2.new(1, -CONFIG.TabListW, 1, 0),
		UDim2.new(0, CONFIG.TabListW, 0, 0)
	)
	contentArea.BackgroundTransparency = 1
	contentArea.ClipsDescendants = true

	local tabPages = {}
	local activeTab = nil
	local tabButtons = {}

	local Window = {}

	function Window:CreateTab(name, icon)
		local tabBtn = MakeButton(tabList, Color3.fromRGB(0,0,0),
			UDim2.new(1, 0, 0, 32)
		)
		tabBtn.BackgroundColor3 = Theme.SurfaceHover
		tabBtn.BackgroundTransparency = 1
		MakeCorner(tabBtn, CONFIG.SmallRadius)

		local btnLabel = Instance.new("TextLabel")
		btnLabel.BackgroundTransparency = 1
		btnLabel.Text = (icon and icon .. "  " or "") .. name
		btnLabel.TextSize = 12
		btnLabel.Font = Enum.Font.Gotham
		btnLabel.TextColor3 = Theme.TextSecondary
		btnLabel.TextXAlignment = Enum.TextXAlignment.Left
		btnLabel.Size = UDim2.new(1, -10, 1, 0)
		btnLabel.Position = UDim2.new(0, 10, 0, 0)
		btnLabel.Parent = tabBtn

		local activePill = MakeFrame(tabBtn, Theme.Accent,
			UDim2.new(0, 3, 0, 16),
			UDim2.new(0, 0, 0.5, -8)
		)
		MakeCorner(activePill, 2)
		activePill.BackgroundTransparency = 1

		local page = MakeFrame(contentArea, Color3.fromRGB(0,0,0),
			UDim2.new(1, 0, 1, 0)
		)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.ClipsDescendants = true

		local pageScroll = Instance.new("ScrollingFrame")
		pageScroll.BackgroundTransparency = 1
		pageScroll.BorderSizePixel = 0
		pageScroll.Size = UDim2.new(1, 0, 1, 0)
		pageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		pageScroll.ScrollBarThickness = 2
		pageScroll.ScrollBarImageColor3 = Theme.BorderAccent
		pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		pageScroll.Parent = page

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Padding = UDim.new(0, 4)
		pageLayout.Parent = pageScroll
		MakePadding(pageScroll, 10, 10, 10, 14)

		tabPages[name] = page

		local function SelectTab()
			if activeTab == name then return end

			if activeTab then
				local prevBtn = tabButtons[activeTab]
				if prevBtn then
					Tween(prevBtn.btn, CONFIG.TweenFast, {BackgroundTransparency = 1})
					Tween(prevBtn.label, CONFIG.TweenFast, {TextColor3 = Theme.TextSecondary, Font = Enum.Font.Gotham})
					Tween(prevBtn.pill, CONFIG.TweenFast, {BackgroundTransparency = 1})
					tabPages[activeTab].Visible = false
				end
			end

			activeTab = name
			page.Visible = true
			page.BackgroundTransparency = 1
			Tween(tabBtn, CONFIG.TweenFast, {BackgroundTransparency = 0.6})
			Tween(btnLabel, CONFIG.TweenFast, {TextColor3 = Theme.TextPrimary, Font = Enum.Font.GothamBold})
			Tween(activePill, CONFIG.TweenFast, {BackgroundTransparency = 0})
		end

		tabButtons[name] = {btn = tabBtn, label = btnLabel, pill = activePill}

		tabBtn.MouseButton1Click:Connect(SelectTab)

		tabBtn.MouseEnter:Connect(function()
			if activeTab == name then return end
			Tween(tabBtn, CONFIG.TweenFast, {BackgroundTransparency = 0.8})
			Tween(btnLabel, CONFIG.TweenFast, {TextColor3 = Color3.fromRGB(160, 160, 175)})
		end)
		tabBtn.MouseLeave:Connect(function()
			if activeTab == name then return end
			Tween(tabBtn, CONFIG.TweenFast, {BackgroundTransparency = 1})
			Tween(btnLabel, CONFIG.TweenFast, {TextColor3 = Theme.TextSecondary})
		end)

		if not activeTab then
			SelectTab()
		end

		local Tab = {}

		local function MakeElement(height)
			local el = MakeFrame(pageScroll, Theme.Surface,
				UDim2.new(1, 0, 0, height or CONFIG.ElementH)
			)
			MakeCorner(el, CONFIG.SmallRadius)
			MakeStroke(el, Theme.Border)
			return el
		end

		function Tab:CreateSection(title)
			local sec = Instance.new("Frame")
			sec.BackgroundTransparency = 1
			sec.Size = UDim2.new(1, 0, 0, 24)
			sec.Parent = pageScroll

			local lbl = Instance.new("TextLabel")
			lbl.BackgroundTransparency = 1
			lbl.Text = title:upper()
			lbl.TextSize = 10
			lbl.Font = Enum.Font.GothamBold
			lbl.TextColor3 = Theme.TextMuted
			lbl.LetterSpacing = 2
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Size = UDim2.new(1, 0, 1, 0)
			lbl.Parent = sec

			local line = MakeFrame(sec, Theme.Border, UDim2.new(1, -80, 0, 1), UDim2.new(0, 80, 0.5, 0))
		end

		function Tab:CreateButton(opts)
			local label   = opts.Name or "Button"
			local desc    = opts.Description or ""
			local cb      = opts.Callback or function() end

			local el = MakeElement(desc ~= "" and 50 or CONFIG.ElementH)

			local nameL = Instance.new("TextLabel")
			nameL.BackgroundTransparency = 1
			nameL.Text = label
			nameL.TextSize = 13
			nameL.Font = Enum.Font.Gotham
			nameL.TextColor3 = Theme.TextPrimary
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.Size = UDim2.new(1, -80, 0, 18)
			nameL.Position = UDim2.new(0, 12, desc ~= "" and 0 or 0.5, desc ~= "" and 8 or -9)
			nameL.Parent = el

			if desc ~= "" then
				local descL = Instance.new("TextLabel")
				descL.BackgroundTransparency = 1
				descL.Text = desc
				descL.TextSize = 11
				descL.Font = Enum.Font.Gotham
				descL.TextColor3 = Theme.TextSecondary
				descL.TextXAlignment = Enum.TextXAlignment.Left
				descL.Size = UDim2.new(1, -80, 0, 14)
				descL.Position = UDim2.new(0, 12, 0, 28)
				descL.Parent = el
			end

			local execBtn = MakeButton(el, Theme.Accent,
				UDim2.new(0, 56, 0, 24),
				UDim2.new(1, -66, 0.5, -12)
			)
			MakeCorner(execBtn, 4)

			local execLabel = Instance.new("TextLabel")
			execLabel.BackgroundTransparency = 1
			execLabel.Text = "Run"
			execLabel.TextSize = 11
			execLabel.Font = Enum.Font.GothamBold
			execLabel.TextColor3 = Theme.TextPrimary
			execLabel.Size = UDim2.new(1, 0, 1, 0)
			execLabel.Parent = execBtn

			local interact = MakeButton(el, Color3.fromRGB(0,0,0),
				UDim2.new(1, 0, 1, 0)
			)
			interact.BackgroundTransparency = 1
			interact.ZIndex = 5

			interact.MouseEnter:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.SurfaceHover})
				Tween(execBtn, CONFIG.TweenFast, {BackgroundColor3 = Theme.AccentDim})
			end)
			interact.MouseLeave:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.Surface})
				Tween(execBtn, CONFIG.TweenFast, {BackgroundColor3 = Theme.Accent})
			end)
			interact.MouseButton1Click:Connect(function()
				Tween(execBtn, CONFIG.TweenFast, {BackgroundColor3 = Color3.fromRGB(70, 72, 180)})
				task.delay(0.15, function()
					Tween(execBtn, CONFIG.TweenFast, {BackgroundColor3 = Theme.Accent})
				end)
				task.spawn(function()
					local ok, err = pcall(cb)
					if not ok then
						Noctaer:Notify({Title = "Error", Content = tostring(err), Duration = 4})
					end
				end)
			end)

			local BtnObj = {}
			function BtnObj:SetLabel(s) nameL.Text = s end
			return BtnObj
		end

		function Tab:CreateToggle(opts)
			local label   = opts.Name or "Toggle"
			local desc    = opts.Description or ""
			local default = opts.CurrentValue or false
			local flag    = opts.Flag
			local cb      = opts.Callback or function() end

			local el = MakeElement(desc ~= "" and 50 or CONFIG.ElementH)

			local nameL = Instance.new("TextLabel")
			nameL.BackgroundTransparency = 1
			nameL.Text = label
			nameL.TextSize = 13
			nameL.Font = Enum.Font.Gotham
			nameL.TextColor3 = Theme.TextPrimary
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.Size = UDim2.new(1, -70, 0, 18)
			nameL.Position = UDim2.new(0, 12, desc ~= "" and 0 or 0.5, desc ~= "" and 8 or -9)
			nameL.Parent = el

			if desc ~= "" then
				local descL = Instance.new("TextLabel")
				descL.BackgroundTransparency = 1
				descL.Text = desc
				descL.TextSize = 11
				descL.Font = Enum.Font.Gotham
				descL.TextColor3 = Theme.TextSecondary
				descL.TextXAlignment = Enum.TextXAlignment.Left
				descL.Size = UDim2.new(1, -70, 0, 14)
				descL.Position = UDim2.new(0, 12, 0, 28)
				descL.Parent = el
			end

			local track = MakeFrame(el, Theme.ToggleOff,
				UDim2.new(0, 36, 0, 20),
				UDim2.new(1, -48, 0.5, -10)
			)
			MakeCorner(track, 10)
			MakeStroke(track, Theme.Border)

			local knob = MakeFrame(track, Theme.TextPrimary,
				UDim2.new(0, 14, 0, 14),
				UDim2.new(0, 3, 0.5, -7)
			)
			MakeCorner(knob, 7)

			local value = default

			local function SetToggle(v, fireCallback)
				value = v
				if v then
					Tween(track, CONFIG.TweenFast, {BackgroundColor3 = Theme.ToggleOn})
					Tween(knob, CONFIG.TweenFast, {Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
					Tween(track, CONFIG.TweenFast, {})
				else
					Tween(track, CONFIG.TweenFast, {BackgroundColor3 = Theme.ToggleOff})
					Tween(knob, CONFIG.TweenFast, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.TextSecondary})
				end
				if fireCallback then
					task.spawn(function()
						local ok, err = pcall(cb, value)
						if not ok then Noctaer:Notify({Title="Error", Content=tostring(err), Duration=4}) end
					end)
				end
				if flag then Noctaer.Flags[flag] = {CurrentValue = value, Set = function(_, nv) SetToggle(nv, true) end} end
			end

			SetToggle(default, false)

			local interact = MakeButton(el, Color3.fromRGB(0,0,0), UDim2.new(1,0,1,0))
			interact.BackgroundTransparency = 1
			interact.ZIndex = 5

			interact.MouseEnter:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.SurfaceHover})
			end)
			interact.MouseLeave:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.Surface})
			end)
			interact.MouseButton1Click:Connect(function()
				SetToggle(not value, true)
			end)

			local TogObj = {}
			function TogObj:Set(v) SetToggle(v, true) end
			function TogObj:Get() return value end
			if flag then Noctaer.Flags[flag] = TogObj end
			return TogObj
		end

		function Tab:CreateSlider(opts)
			local label   = opts.Name or "Slider"
			local min     = opts.Range and opts.Range[1] or 0
			local max     = opts.Range and opts.Range[2] or 100
			local inc     = opts.Increment or 1
			local suffix  = opts.Suffix or ""
			local default = opts.CurrentValue or min
			local flag    = opts.Flag
			local cb      = opts.Callback or function() end

			local el = MakeElement(54)

			local nameL = Instance.new("TextLabel")
			nameL.BackgroundTransparency = 1
			nameL.Text = label
			nameL.TextSize = 13
			nameL.Font = Enum.Font.Gotham
			nameL.TextColor3 = Theme.TextPrimary
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.Size = UDim2.new(0.6, 0, 0, 18)
			nameL.Position = UDim2.new(0, 12, 0, 8)
			nameL.Parent = el

			local valL = Instance.new("TextLabel")
			valL.BackgroundTransparency = 1
			valL.TextSize = 12
			valL.Font = Enum.Font.GothamBold
			valL.TextColor3 = Theme.Accent
			valL.TextXAlignment = Enum.TextXAlignment.Right
			valL.Size = UDim2.new(0.35, 0, 0, 18)
			valL.Position = UDim2.new(0.65, -12, 0, 8)
			valL.Parent = el

			local track = MakeFrame(el, Theme.SliderTrack,
				UDim2.new(1, -24, 0, 4),
				UDim2.new(0, 12, 0, 34)
			)
			MakeCorner(track, 2)
			MakeStroke(track, Theme.Border)

			local fill = MakeFrame(track, Theme.SliderFill,
				UDim2.new(0, 0, 1, 0)
			)
			MakeCorner(fill, 2)

			local thumb = MakeFrame(track, Theme.TextPrimary,
				UDim2.new(0, 12, 0, 12),
				UDim2.new(0, -6, 0.5, -6)
			)
			MakeCorner(thumb, 6)
			MakeStroke(thumb, Theme.Accent)

			local value = default
			local dragging = false

			local function SetSlider(v, fireCallback)
				v = math.clamp(v, min, max)
				v = math.floor(v / inc + 0.5) * inc
				value = v
				local pct = (v - min) / (max - min)
				Tween(fill, CONFIG.TweenFast, {Size = UDim2.new(pct, 0, 1, 0)})
				Tween(thumb, CONFIG.TweenFast, {Position = UDim2.new(pct, -6, 0.5, -6)})
				valL.Text = tostring(v) .. (suffix ~= "" and " " .. suffix or "")
				if fireCallback then
					task.spawn(function()
						local ok, err = pcall(cb, value)
						if not ok then Noctaer:Notify({Title="Error", Content=tostring(err), Duration=4}) end
					end)
				end
				if flag then Noctaer.Flags[flag] = {CurrentValue = value, Set = function(_, nv) SetSlider(nv, true) end} end
			end

			SetSlider(default, false)

			local interact = MakeButton(track, Color3.fromRGB(0,0,0), UDim2.new(1, 12, 1, 12), UDim2.new(0, -6, 0, -6))
			interact.BackgroundTransparency = 1
			interact.ZIndex = 5

			interact.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)
			interact.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			local conn
			interact.MouseButton1Down:Connect(function()
				dragging = true
				conn = RunService.Heartbeat:Connect(function()
					if not dragging then
						conn:Disconnect()
						return
					end
					local mouseX = UserInputService:GetMouseLocation().X
					local trackX = track.AbsolutePosition.X
					local trackW = track.AbsoluteSize.X
					local pct = math.clamp((mouseX - trackX) / trackW, 0, 1)
					local newVal = min + pct * (max - min)
					SetSlider(newVal, true)
				end)
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			el.MouseEnter:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.SurfaceHover})
			end)
			el.MouseLeave:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.Surface})
			end)

			local SliderObj = {}
			function SliderObj:Set(v) SetSlider(v, true) end
			function SliderObj:Get() return value end
			if flag then Noctaer.Flags[flag] = SliderObj end
			return SliderObj
		end

		function Tab:CreateDropdown(opts)
			local label   = opts.Name or "Dropdown"
			local options = opts.Options or {}
			local multi   = opts.MultipleOptions or false
			local default = opts.CurrentOption or (multi and {} or (options[1] or ""))
			local flag    = opts.Flag
			local cb      = opts.Callback or function() end

			if type(default) == "string" then default = {default} end

			local collapsed = true
			local selected  = {table.unpack(default)}

			local el = MakeElement(CONFIG.ElementH)
			el.ClipsDescendants = false

			local nameL = Instance.new("TextLabel")
			nameL.BackgroundTransparency = 1
			nameL.Text = label
			nameL.TextSize = 13
			nameL.Font = Enum.Font.Gotham
			nameL.TextColor3 = Theme.TextPrimary
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.Size = UDim2.new(0.5, 0, 1, 0)
			nameL.Position = UDim2.new(0, 12, 0, 0)
			nameL.Parent = el

			local selL = Instance.new("TextLabel")
			selL.BackgroundTransparency = 1
			selL.TextSize = 12
			selL.Font = Enum.Font.Gotham
			selL.TextColor3 = Theme.TextSecondary
			selL.TextXAlignment = Enum.TextXAlignment.Right
			selL.Size = UDim2.new(0.4, 0, 1, 0)
			selL.Position = UDim2.new(0.5, 0, 0, 0)
			selL.Parent = el

			local arrow = Instance.new("TextLabel")
			arrow.BackgroundTransparency = 1
			arrow.Text = "›"
			arrow.TextSize = 16
			arrow.Font = Enum.Font.GothamBold
			arrow.TextColor3 = Theme.TextMuted
			arrow.Rotation = 90
			arrow.Size = UDim2.new(0, 16, 1, 0)
			arrow.Position = UDim2.new(1, -22, 0, 0)
			arrow.Parent = el

			local dropList = MakeFrame(el, Theme.Surface,
				UDim2.new(1, 0, 0, 0),
				UDim2.new(0, 0, 1, 2)
			)
			dropList.ClipsDescendants = true
			dropList.ZIndex = 10
			MakeCorner(dropList, CONFIG.SmallRadius)
			MakeStroke(dropList, Theme.Border)

			local listLayout = Instance.new("UIListLayout")
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Parent = dropList
			MakePadding(dropList, 4, 4, 4, 4)

			local function UpdateLabel()
				if #selected == 0 then
					selL.Text = "None"
				elseif #selected == 1 then
					selL.Text = selected[1]
				else
					selL.Text = selected[1] .. " +" .. (#selected - 1)
				end
			end

			UpdateLabel()

			local optBtns = {}

			local function RefreshOptionColors()
				for _, entry in ipairs(optBtns) do
					local isSelected = table.find(selected, entry.name) ~= nil
					Tween(entry.frame, CONFIG.TweenFast, {
						BackgroundColor3 = isSelected and Theme.AccentDim or Color3.fromRGB(0,0,0),
						BackgroundTransparency = isSelected and 0 or 1
					})
					Tween(entry.label, CONFIG.TweenFast, {
						TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary
					})
				end
			end

			for _, opt in ipairs(options) do
				local optFrame = MakeFrame(dropList, Color3.fromRGB(0,0,0),
					UDim2.new(1, 0, 0, 28)
				)
				optFrame.BackgroundTransparency = 1
				MakeCorner(optFrame, 4)
				optFrame.ZIndex = 11

				local optLabel = Instance.new("TextLabel")
				optLabel.BackgroundTransparency = 1
				optLabel.Text = opt
				optLabel.TextSize = 12
				optLabel.Font = Enum.Font.Gotham
				optLabel.TextColor3 = Theme.TextSecondary
				optLabel.TextXAlignment = Enum.TextXAlignment.Left
				optLabel.Size = UDim2.new(1, -16, 1, 0)
				optLabel.Position = UDim2.new(0, 8, 0, 0)
				optLabel.ZIndex = 11
				optLabel.Parent = optFrame

				local optBtn = MakeButton(optFrame, Color3.fromRGB(0,0,0), UDim2.new(1,0,1,0))
				optBtn.BackgroundTransparency = 1
				optBtn.ZIndex = 12

				table.insert(optBtns, {name = opt, frame = optFrame, label = optLabel})

				optBtn.MouseButton1Click:Connect(function()
					if multi then
						local idx = table.find(selected, opt)
						if idx then
							table.remove(selected, idx)
						else
							table.insert(selected, opt)
						end
					else
						selected = {opt}
						collapsed = true
						Tween(dropList, CONFIG.TweenMed, {Size = UDim2.new(1, 0, 0, 0)})
						Tween(arrow, CONFIG.TweenFast, {Rotation = 90})
					end
					UpdateLabel()
					RefreshOptionColors()
					task.spawn(function()
						local ok, err = pcall(cb, multi and selected or selected[1])
						if not ok then Noctaer:Notify({Title="Error", Content=tostring(err), Duration=4}) end
					end)
					if flag then Noctaer.Flags[flag] = {CurrentOption = selected} end
				end)
			end

			RefreshOptionColors()

			local optH = math.min(#options, 5) * 30 + 8
			local interact = MakeButton(el, Color3.fromRGB(0,0,0), UDim2.new(1,0,1,0))
			interact.BackgroundTransparency = 1
			interact.ZIndex = 5

			interact.MouseEnter:Connect(function()
				if collapsed then Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.SurfaceHover}) end
			end)
			interact.MouseLeave:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.Surface})
			end)

			interact.MouseButton1Click:Connect(function()
				collapsed = not collapsed
				if not collapsed then
					Tween(dropList, CONFIG.TweenMed, {Size = UDim2.new(1, 0, 0, optH)})
					Tween(arrow, CONFIG.TweenFast, {Rotation = -90})
				else
					Tween(dropList, CONFIG.TweenMed, {Size = UDim2.new(1, 0, 0, 0)})
					Tween(arrow, CONFIG.TweenFast, {Rotation = 90})
				end
			end)

			local DropObj = {}
			function DropObj:Set(v)
				if type(v) == "string" then v = {v} end
				selected = v
				UpdateLabel()
				RefreshOptionColors()
				task.spawn(pcall, cb, multi and selected or selected[1])
			end
			function DropObj:Get() return multi and selected or selected[1] end
			if flag then Noctaer.Flags[flag] = DropObj end
			return DropObj
		end

		function Tab:CreateInput(opts)
			local label  = opts.Name or "Input"
			local ph     = opts.PlaceholderText or ""
			local flag   = opts.Flag
			local cb     = opts.Callback or function() end
			local clear  = opts.RemoveTextAfterFocusLost or false

			local el = MakeElement(CONFIG.ElementH)

			local nameL = Instance.new("TextLabel")
			nameL.BackgroundTransparency = 1
			nameL.Text = label
			nameL.TextSize = 13
			nameL.Font = Enum.Font.Gotham
			nameL.TextColor3 = Theme.TextPrimary
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.Size = UDim2.new(0.4, 0, 1, 0)
			nameL.Position = UDim2.new(0, 12, 0, 0)
			nameL.Parent = el

			local inputFrame = MakeFrame(el, Theme.Background,
				UDim2.new(0.5, -14, 0, 24),
				UDim2.new(0.5, 0, 0.5, -12)
			)
			MakeCorner(inputFrame, 4)
			MakeStroke(inputFrame, Theme.Border)

			local inputBox = Instance.new("TextBox")
			inputBox.BackgroundTransparency = 1
			inputBox.PlaceholderText = ph
			inputBox.PlaceholderColor3 = Theme.TextMuted
			inputBox.Text = ""
			inputBox.TextSize = 12
			inputBox.Font = Enum.Font.Gotham
			inputBox.TextColor3 = Theme.TextPrimary
			inputBox.TextXAlignment = Enum.TextXAlignment.Left
			inputBox.ClearTextOnFocus = false
			inputBox.Size = UDim2.new(1, -12, 1, 0)
			inputBox.Position = UDim2.new(0, 6, 0, 0)
			inputBox.Parent = inputFrame

			inputBox.Focused:Connect(function()
				Tween(inputFrame, CONFIG.TweenFast, {})
				Tween(inputFrame, CONFIG.TweenFast, {BackgroundColor3 = Theme.SurfaceHover})
				local s = MakeStroke(inputFrame, Theme.Accent)
			end)
			inputBox.FocusLost:Connect(function(enter)
				Tween(inputFrame, CONFIG.TweenFast, {BackgroundColor3 = Theme.Background})
				task.spawn(function()
					local ok, err = pcall(cb, inputBox.Text)
					if not ok then Noctaer:Notify({Title="Error", Content=tostring(err), Duration=4}) end
				end)
				if clear then inputBox.Text = "" end
			end)

			el.MouseEnter:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.SurfaceHover})
			end)
			el.MouseLeave:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.Surface})
			end)

			local InputObj = {}
			function InputObj:Set(v) inputBox.Text = tostring(v) end
			function InputObj:Get() return inputBox.Text end
			if flag then Noctaer.Flags[flag] = InputObj end
			return InputObj
		end

		function Tab:CreateKeybind(opts)
			local label   = opts.Name or "Keybind"
			local default = opts.CurrentKeybind or "F"
			local flag    = opts.Flag
			local cb      = opts.Callback or function() end
			local hold    = opts.HoldToInteract or false

			local el = MakeElement(CONFIG.ElementH)
			local currentKey = default
			local listening = false

			local nameL = Instance.new("TextLabel")
			nameL.BackgroundTransparency = 1
			nameL.Text = label
			nameL.TextSize = 13
			nameL.Font = Enum.Font.Gotham
			nameL.TextColor3 = Theme.TextPrimary
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.Size = UDim2.new(0.6, 0, 1, 0)
			nameL.Position = UDim2.new(0, 12, 0, 0)
			nameL.Parent = el

			local keyFrame = MakeFrame(el, Theme.Background,
				UDim2.new(0, 58, 0, 24),
				UDim2.new(1, -68, 0.5, -12)
			)
			MakeCorner(keyFrame, 4)
			MakeStroke(keyFrame, Theme.Border)

			local keyLabel = Instance.new("TextLabel")
			keyLabel.BackgroundTransparency = 1
			keyLabel.Text = currentKey
			keyLabel.TextSize = 11
			keyLabel.Font = Enum.Font.GothamBold
			keyLabel.TextColor3 = Theme.Accent
			keyLabel.Size = UDim2.new(1, 0, 1, 0)
			keyLabel.Parent = keyFrame

			local keyBtn = MakeButton(keyFrame, Color3.fromRGB(0,0,0), UDim2.new(1,0,1,0))
			keyBtn.BackgroundTransparency = 1
			keyBtn.ZIndex = 5

			keyBtn.MouseButton1Click:Connect(function()
				listening = true
				keyLabel.Text = "..."
				Tween(keyFrame, CONFIG.TweenFast, {BackgroundColor3 = Theme.SurfaceHover})
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if listening then
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						local split = string.split(tostring(input.KeyCode), ".")
						currentKey = split[3]
						keyLabel.Text = currentKey
						listening = false
						Tween(keyFrame, CONFIG.TweenFast, {BackgroundColor3 = Theme.Background})
						if flag then Noctaer.Flags[flag] = {CurrentKeybind = currentKey} end
					end
				elseif not processed and input.KeyCode == Enum.KeyCode[currentKey] then
					task.spawn(pcall, cb)
				end
			end)

			el.MouseEnter:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.SurfaceHover})
			end)
			el.MouseLeave:Connect(function()
				Tween(el, CONFIG.TweenFast, {BackgroundColor3 = Theme.Surface})
			end)

			local KbObj = {}
			function KbObj:Set(k)
				currentKey = tostring(k)
				keyLabel.Text = currentKey
			end
			function KbObj:Get() return currentKey end
			if flag then Noctaer.Flags[flag] = KbObj end
			return KbObj
		end

		function Tab:CreateLabel(text)
			local el = MakeFrame(pageScroll, Theme.Surface, UDim2.new(1, 0, 0, 30))
			MakeCorner(el, CONFIG.SmallRadius)
			local lbl = MakeLabel(el, text, 12, Theme.TextSecondary)
			lbl.Position = UDim2.new(0, 12, 0, 0)
			local LblObj = {}
			function LblObj:Set(s) lbl.Text = s end
			return LblObj
		end

		return Tab
	end

	win.BackgroundTransparency = 1
	shadow.ImageTransparency = 1
	Tween(win, CONFIG.TweenMed, {BackgroundTransparency = 0})
	Tween(shadow, CONFIG.TweenMed, {ImageTransparency = 0.5})

	return Window
end

function Noctaer:Destroy()
	for _, sg in ipairs(GetGui():GetChildren()) do
		if sg.Name:find("Noctaer") then sg:Destroy() end
	end
end

return Noctaer
