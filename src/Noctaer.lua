-- by noctaer

local Noctaer = {}
Noctaer.__index = Noctaer
Noctaer.Flags = {}

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

local Theme = {
	Background    = Color3.fromRGB(12, 12, 14),
	Surface       = Color3.fromRGB(18, 18, 21),
	SurfaceHover  = Color3.fromRGB(24, 24, 28),
	Border        = Color3.fromRGB(32, 32, 38),
	BorderAccent  = Color3.fromRGB(50, 50, 60),
	Accent        = Color3.fromRGB(99, 102, 241),
	AccentDim     = Color3.fromRGB(60, 62, 150),
	TextPrimary   = Color3.fromRGB(220, 220, 228),
	TextSecondary = Color3.fromRGB(110, 110, 125),
	TextMuted     = Color3.fromRGB(65, 65, 78),
	ToggleOn      = Color3.fromRGB(99, 102, 241),
	ToggleOff     = Color3.fromRGB(38, 38, 46),
	SliderTrack   = Color3.fromRGB(28, 28, 34),
	SliderFill    = Color3.fromRGB(99, 102, 241),
	NotifBg       = Color3.fromRGB(16, 16, 20),
}

local C = {
	WindowW  = 520,
	WindowH  = 440,
	TopbarH  = 42,
	TabListW = 128,
	ElH      = 38,
	ElPad    = 12,
	Gap      = 4,
	R        = 8,
	Rs       = 5,
	TF       = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	TM       = TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}

local function Tw(o, ti, p) TweenService:Create(o, ti, p):Play() end

local function Corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or C.R)
	c.Parent = p
	return c
end

local function Stroke(p, col, thick)
	local s = Instance.new("UIStroke")
	s.Color           = col or Theme.Border
	s.Thickness       = thick or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function Pad(p, t, b, l, r)
	local u = Instance.new("UIPadding")
	u.PaddingTop    = UDim.new(0, t or 0)
	u.PaddingBottom = UDim.new(0, b or 0)
	u.PaddingLeft   = UDim.new(0, l or 0)
	u.PaddingRight  = UDim.new(0, r or 0)
	u.Parent = p
end

local function ListLayout(p, gap)
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding   = UDim.new(0, gap or 0)
	l.Parent    = p
	return l
end

local function Frame(p, col, sz, pos, zi)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = col or Theme.Surface
	f.BorderSizePixel  = 0
	f.Size             = sz  or UDim2.new(1, 0, 0, C.ElH)
	f.Position         = pos or UDim2.new(0, 0, 0, 0)
	if zi then f.ZIndex = zi end
	f.Parent = p
	return f
end

local function Btn(p, sz, pos, zi)
	local b = Instance.new("TextButton")
	b.BackgroundTransparency = 1
	b.BorderSizePixel        = 0
	b.Size                   = sz  or UDim2.new(1, 0, 1, 0)
	b.Position               = pos or UDim2.new(0, 0, 0, 0)
	b.Text                   = ""
	b.AutoButtonColor        = false
	if zi then b.ZIndex = zi end
	b.Parent = p
	return b
end

local function Label(p, txt, tsz, col, xa, zi)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text           = txt or ""
	l.TextSize       = tsz or 13
	l.TextColor3     = col or Theme.TextPrimary
	l.Font           = Enum.Font.Gotham
	l.TextXAlignment = xa  or Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.Size           = UDim2.new(1, 0, 1, 0)
	if zi then l.ZIndex = zi end
	l.Parent = p
	return l
end

local function GetGuiParent()
	if gethui then
		return gethui()
	end
	local sg = Instance.new("ScreenGui")
	sg.ResetOnSpawn = false
	if syn and syn.protect_gui then
		pcall(syn.protect_gui, sg)
	end
	sg.Parent = CoreGui
	return sg
end

local function SetupDrag(handle, target)
	local active = false
	local origin = Vector3.new()
	local base   = UDim2.new()

	handle.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		active = true
		origin = i.Position
		base   = target.Position
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then
				active = false
			end
		end)
	end)

	UserInputService.InputChanged:Connect(function(i)
		if not active then return end
		if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local d = i.Position - origin
		target.Position = UDim2.new(
			base.X.Scale, base.X.Offset + d.X,
			base.Y.Scale, base.Y.Offset + d.Y
		)
	end)
end

function Noctaer:CreateWindow(opts)
	local wTitle  = opts.Title    or "Noctaer"
	local wSub    = opts.Subtitle or ""
	local hideKey = opts.HideKey  or Enum.KeyCode.RightControl

	local sg = Instance.new("ScreenGui")
	sg.Name           = "Noctaer"
	sg.ResetOnSpawn   = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
	sg.DisplayOrder   = 999

	local guiParent = GetGuiParent()
	local dest      = guiParent:IsA("ScreenGui") and guiParent.Parent or guiParent

	for _, v in ipairs(dest:GetChildren()) do
		if v ~= sg and v.Name == "Noctaer" then v:Destroy() end
	end
	sg.Parent = dest

	-- notification state scoped to this window
	local notifIdx       = 0
	local notifContainer = Instance.new("Frame")
	notifContainer.Name                 = "Notifs"
	notifContainer.BackgroundTransparency = 1
	notifContainer.Size                 = UDim2.new(0, 296, 1, -20)
	notifContainer.Position             = UDim2.new(1, -304, 0, 10)
	notifContainer.ZIndex               = 200
	notifContainer.Parent               = sg
	local notifLayout = ListLayout(notifContainer, 6)
	notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	local Window = {}

	function Window:Notify(o)
		local title    = o.Title    or "Notification"
		local content  = o.Content  or ""
		local duration = o.Duration or 5

		notifIdx += 1

		local card = Frame(notifContainer, Theme.NotifBg, UDim2.new(1, 0, 0, 62))
		card.ClipsDescendants   = true
		card.LayoutOrder        = notifIdx
		card.ZIndex             = 200
		card.BackgroundTransparency = 1
		Corner(card, C.Rs)
		Stroke(card, Theme.Border)

		local bar = Frame(card, Theme.Accent, UDim2.new(0, 3, 1, -8), UDim2.new(0, 0, 0, 4))
		bar.ZIndex = 201
		Corner(bar, 2)

		local tl = Instance.new("TextLabel")
		tl.BackgroundTransparency = 1
		tl.Text             = title
		tl.TextSize         = 13
		tl.Font             = Enum.Font.GothamBold
		tl.TextColor3       = Theme.TextPrimary
		tl.TextXAlignment   = Enum.TextXAlignment.Left
		tl.TextYAlignment   = Enum.TextYAlignment.Center
		tl.TextTransparency = 1
		tl.Size             = UDim2.new(1, -20, 0, 18)
		tl.Position         = UDim2.new(0, 14, 0, 9)
		tl.ZIndex           = 201
		tl.Parent           = card

		local cl = Instance.new("TextLabel")
		cl.BackgroundTransparency = 1
		cl.Text             = content
		cl.TextSize         = 11
		cl.Font             = Enum.Font.Gotham
		cl.TextColor3       = Theme.TextSecondary
		cl.TextXAlignment   = Enum.TextXAlignment.Left
		cl.TextYAlignment   = Enum.TextYAlignment.Top
		cl.TextWrapped      = true
		cl.TextTransparency = 1
		cl.Size             = UDim2.new(1, -20, 0, 26)
		cl.Position         = UDim2.new(0, 14, 0, 30)
		cl.ZIndex           = 201
		cl.Parent           = card

		Tw(card, C.TM, {BackgroundTransparency = 0})
		Tw(tl,   C.TM, {TextTransparency = 0})
		Tw(cl,   C.TM, {TextTransparency = 0.15})

		task.delay(duration, function()
			if not card or not card.Parent then return end
			Tw(card, C.TM, {BackgroundTransparency = 1})
			Tw(tl,   C.TM, {TextTransparency = 1})
			Tw(cl,   C.TM, {TextTransparency = 1})
			task.delay(0.35, function()
				if not card or not card.Parent then return end
				Tw(card, C.TF, {Size = UDim2.new(1, 0, 0, 0)})
				task.delay(0.2, function()
					if card and card.Parent then card:Destroy() end
				end)
			end)
		end)
	end

	-- keep Noctaer:Notify working by forwarding to Window:Notify
	Noctaer.Notify = function(_, o) Window:Notify(o) end

	-- drop shadow
	local shadow = Instance.new("ImageLabel")
	shadow.BackgroundTransparency = 1
	shadow.Image             = "rbxassetid://6014261993"
	shadow.ImageColor3       = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 1
	shadow.ScaleType         = Enum.ScaleType.Slice
	shadow.SliceCenter       = Rect.new(49, 49, 450, 450)
	shadow.AnchorPoint       = Vector2.new(0.5, 0.5)
	shadow.Size              = UDim2.new(0, C.WindowW + 48, 0, C.WindowH + 48)
	shadow.Position          = UDim2.new(0.5, 0, 0.5, 0)
	shadow.ZIndex            = 1
	shadow.Parent            = sg

	local win = Frame(sg, Theme.Background,
		UDim2.new(0, C.WindowW, 0, C.WindowH),
		UDim2.new(0.5, -C.WindowW / 2, 0.5, -C.WindowH / 2),
		2
	)
	win.ClipsDescendants = false
	Corner(win, C.R)
	Stroke(win, Theme.Border)

	local topbar = Frame(win, Theme.Surface,
		UDim2.new(1, 0, 0, C.TopbarH),
		UDim2.new(0, 0, 0, 0),
		3
	)
	Corner(topbar, C.R)
	Frame(topbar, Theme.Surface, UDim2.new(1, 0, 0, C.R), UDim2.new(0, 0, 1, -C.R), 3)
	Frame(win, Theme.Accent, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, C.TopbarH), 3)

	if wSub ~= "" then
		local tl = Instance.new("TextLabel")
		tl.BackgroundTransparency = 1
		tl.Text           = wTitle
		tl.TextSize       = 13
		tl.Font           = Enum.Font.GothamBold
		tl.TextColor3     = Theme.TextPrimary
		tl.TextXAlignment = Enum.TextXAlignment.Left
		tl.TextYAlignment = Enum.TextYAlignment.Center
		tl.Size           = UDim2.new(0, 240, 0, 18)
		tl.Position       = UDim2.new(0, C.ElPad, 0, 6)
		tl.ZIndex         = 4
		tl.Parent         = topbar

		local sl = Instance.new("TextLabel")
		sl.BackgroundTransparency = 1
		sl.Text           = wSub
		sl.TextSize       = 11
		sl.Font           = Enum.Font.Gotham
		sl.TextColor3     = Theme.TextMuted
		sl.TextXAlignment = Enum.TextXAlignment.Left
		sl.TextYAlignment = Enum.TextYAlignment.Center
		sl.Size           = UDim2.new(0, 240, 0, 14)
		sl.Position       = UDim2.new(0, C.ElPad, 0, 24)
		sl.ZIndex         = 4
		sl.Parent         = topbar
	else
		local tl = Label(topbar, wTitle, 13, Theme.TextPrimary, Enum.TextXAlignment.Left, 4)
		tl.Font     = Enum.Font.GothamBold
		tl.Size     = UDim2.new(0, 240, 1, 0)
		tl.Position = UDim2.new(0, C.ElPad, 0, 0)
	end

	local function MakeTopBtn(offsetR, glyph)
		local b = Btn(topbar,
			UDim2.new(0, 28, 0, 28),
			UDim2.new(1, -offsetR, 0.5, -14),
			5
		)
		Corner(b, 4)
		local ic = Label(b, glyph, 12, Theme.TextMuted, Enum.TextXAlignment.Center, 5)
		ic.Font = Enum.Font.GothamBold
		b.MouseEnter:Connect(function()
			b.BackgroundTransparency = 0.82
			Tw(ic, C.TF, {TextColor3 = Theme.TextPrimary})
		end)
		b.MouseLeave:Connect(function()
			b.BackgroundTransparency = 1
			Tw(ic, C.TF, {TextColor3 = Theme.TextMuted})
		end)
		return b
	end

	local closeBtn = MakeTopBtn(8,  "✕")
	local minBtn   = MakeTopBtn(42, "─")
	closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

	local body = Frame(win, Theme.Background,
		UDim2.new(1, 0, 1, -C.TopbarH),
		UDim2.new(0, 0, 0, C.TopbarH),
		2
	)
	body.ClipsDescendants = true

	local sidebar = Frame(body, Theme.Surface,
		UDim2.new(0, C.TabListW, 1, 0),
		UDim2.new(0, 0, 0, 0),
		3
	)
	Corner(sidebar, C.Rs)
	Stroke(sidebar, Theme.Border)
	Frame(sidebar, Theme.Surface, UDim2.new(0, C.Rs, 1, 0), UDim2.new(1, -C.Rs, 0, 0), 3)
	ListLayout(sidebar, C.Gap)
	Pad(sidebar, 8, 8, 6, 6)

	local content = Frame(body, Theme.Background,
		UDim2.new(1, -C.TabListW, 1, 0),
		UDim2.new(0, C.TabListW, 0, 0),
		2
	)
	content.ClipsDescendants = false

	SetupDrag(topbar, win)

	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		if minimized then
			minimized    = false
			body.Visible = true
			Tw(win,    C.TM, {Size = UDim2.new(0, C.WindowW, 0, C.WindowH)})
			Tw(shadow, C.TM, {Size = UDim2.new(0, C.WindowW + 48, 0, C.WindowH + 48)})
		else
			minimized = true
			Tw(win,    C.TM, {Size = UDim2.new(0, C.WindowW, 0, C.TopbarH)})
			Tw(shadow, C.TM, {Size = UDim2.new(0, C.WindowW + 48, 0, C.TopbarH + 48)})
			task.delay(0.3, function()
				if minimized then body.Visible = false end
			end)
		end
	end)

	local hidden = false
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == hideKey then
			hidden         = not hidden
			win.Visible    = not hidden
			shadow.Visible = not hidden
		end
	end)

	local activeTab = nil
	local tabBtns   = {}
	local tabPages  = {}

	function Window:CreateTab(name)
		local btn = Btn(sidebar, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), 4)
		btn.BackgroundTransparency = 1
		Corner(btn, C.Rs)

		local pill = Frame(btn, Theme.Accent,
			UDim2.new(0, 3, 0, 14),
			UDim2.new(0, 0, 0.5, -7),
			4
		)
		pill.BackgroundTransparency = 1
		Corner(pill, 2)

		local btnLbl = Label(btn, name, 12, Theme.TextSecondary, Enum.TextXAlignment.Left, 4)
		btnLbl.Size     = UDim2.new(1, -14, 1, 0)
		btnLbl.Position = UDim2.new(0, 10, 0, 0)

		local page = Frame(content, Theme.Background,
			UDim2.new(1, 0, 1, 0),
			UDim2.new(0, 0, 0, 0),
			2
		)
		page.Visible          = false
		page.ClipsDescendants = false

		local scroll = Instance.new("ScrollingFrame")
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel        = 0
		scroll.Size                   = UDim2.new(1, 0, 1, 0)
		scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
		scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
		scroll.ScrollBarThickness     = 2
		scroll.ScrollBarImageColor3   = Theme.BorderAccent
		scroll.ScrollingDirection     = Enum.ScrollingDirection.Y
		scroll.ElasticBehavior        = Enum.ElasticBehavior.Never
		scroll.ZIndex                 = 2
		scroll.Parent                 = page
		ListLayout(scroll, C.Gap)
		Pad(scroll, 10, 10, 10, 10)

		tabBtns[name]  = {btn = btn, lbl = btnLbl, pill = pill}
		tabPages[name] = {page = page, scroll = scroll}

		local function Activate()
			if activeTab == name then return end
			if activeTab and tabBtns[activeTab] then
				local prev = tabBtns[activeTab]
				Tw(prev.btn,  C.TF, {BackgroundTransparency = 1})
				Tw(prev.lbl,  C.TF, {TextColor3 = Theme.TextSecondary})
				Tw(prev.pill, C.TF, {BackgroundTransparency = 1})
				tabPages[activeTab].page.Visible = false
			end
			activeTab        = name
			page.Visible     = true
			Tw(btn,    C.TF, {BackgroundTransparency = 0.65})
			Tw(btnLbl, C.TF, {TextColor3 = Theme.TextPrimary})
			Tw(pill,   C.TF, {BackgroundTransparency = 0})
		end

		btn.MouseButton1Click:Connect(Activate)
		btn.MouseEnter:Connect(function()
			if activeTab == name then return end
			Tw(btn,    C.TF, {BackgroundTransparency = 0.82})
			Tw(btnLbl, C.TF, {TextColor3 = Color3.fromRGB(155, 155, 170)})
		end)
		btn.MouseLeave:Connect(function()
			if activeTab == name then return end
			Tw(btn,    C.TF, {BackgroundTransparency = 1})
			Tw(btnLbl, C.TF, {TextColor3 = Theme.TextSecondary})
		end)

		if not activeTab then Activate() end

		local sc = scroll

		local function El(h)
			local f = Frame(sc, Theme.Surface, UDim2.new(1, 0, 0, h or C.ElH))
			Corner(f, C.Rs)
			Stroke(f, Theme.Border)
			return f
		end

		local Tab = {}

		function Tab:CreateSection(title)
			local sec = Frame(sc, Color3.new(), UDim2.new(1, 0, 0, 26))
			sec.BackgroundTransparency = 1

			local lbl = Instance.new("TextLabel")
			lbl.BackgroundTransparency = 1
			lbl.Text           = title:upper()
			lbl.TextSize       = 10
			lbl.Font           = Enum.Font.GothamBold
			lbl.TextColor3     = Theme.TextMuted
			lbl.LetterSpacing  = 2
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextYAlignment = Enum.TextYAlignment.Center
			lbl.Size           = UDim2.new(0, 80, 1, 0)
			lbl.Position       = UDim2.new(0, 2, 0, 0)
			lbl.Parent         = sec

			Frame(sec, Theme.Border, UDim2.new(1, -88, 0, 1), UDim2.new(0, 84, 0.5, 0))
		end

		function Tab:CreateButton(opts)
			local label = opts.Name        or "Button"
			local desc  = opts.Description or ""
			local cb    = opts.Callback    or function() end
			local h     = desc ~= "" and 50 or C.ElH

			local el = El(h)

			local nameL = Instance.new("TextLabel")
			nameL.BackgroundTransparency = 1
			nameL.Text           = label
			nameL.TextSize       = 13
			nameL.Font           = Enum.Font.Gotham
			nameL.TextColor3     = Theme.TextPrimary
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.TextYAlignment = Enum.TextYAlignment.Center
			nameL.Size           = UDim2.new(1, -(52 + C.ElPad * 3), 0, 18)
			nameL.Position       = UDim2.new(0, C.ElPad, 0, desc ~= "" and 8 or (math.floor(h / 2) - 9))
			nameL.Parent         = el

			if desc ~= "" then
				local dl = Instance.new("TextLabel")
				dl.BackgroundTransparency = 1
				dl.Text           = desc
				dl.TextSize       = 11
				dl.Font           = Enum.Font.Gotham
				dl.TextColor3     = Theme.TextSecondary
				dl.TextXAlignment = Enum.TextXAlignment.Left
				dl.TextYAlignment = Enum.TextYAlignment.Center
				dl.Size           = UDim2.new(1, -(52 + C.ElPad * 3), 0, 14)
				dl.Position       = UDim2.new(0, C.ElPad, 0, 28)
				dl.Parent         = el
			end

			local runF = Frame(el, Theme.Accent,
				UDim2.new(0, 52, 0, 24),
				UDim2.new(1, -(52 + C.ElPad), 0.5, -12)
			)
			Corner(runF, 4)
			local runL = Label(runF, "Run", 11, Theme.TextPrimary, Enum.TextXAlignment.Center)
			runL.Font = Enum.Font.GothamBold

			local hit = Btn(el, UDim2.new(1, 0, 1, 0), nil, 5)
			hit.MouseEnter:Connect(function()
				Tw(el,   C.TF, {BackgroundColor3 = Theme.SurfaceHover})
				Tw(runF, C.TF, {BackgroundColor3 = Theme.AccentDim})
			end)
			hit.MouseLeave:Connect(function()
				Tw(el,   C.TF, {BackgroundColor3 = Theme.Surface})
				Tw(runF, C.TF, {BackgroundColor3 = Theme.Accent})
			end)
			hit.MouseButton1Click:Connect(function()
				Tw(runF, C.TF, {BackgroundColor3 = Color3.fromRGB(70, 72, 180)})
				task.delay(0.15, function()
					if runF and runF.Parent then Tw(runF, C.TF, {BackgroundColor3 = Theme.Accent}) end
				end)
				task.spawn(function()
					local ok, err = pcall(cb)
					if not ok then Window:Notify({Title = "Error", Content = tostring(err), Duration = 4}) end
				end)
			end)

			local O = {}
			function O:SetLabel(s) nameL.Text = s end
			return O
		end

		function Tab:CreateToggle(opts)
			local label   = opts.Name         or "Toggle"
			local desc    = opts.Description  or ""
			local default = opts.CurrentValue or false
			local flag    = opts.Flag
			local cb      = opts.Callback     or function() end
			local h       = desc ~= "" and 50 or C.ElH

			local el  = El(h)
			local val = default

			local nameL = Instance.new("TextLabel")
			nameL.BackgroundTransparency = 1
			nameL.Text           = label
			nameL.TextSize       = 13
			nameL.Font           = Enum.Font.Gotham
			nameL.TextColor3     = Theme.TextPrimary
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.TextYAlignment = Enum.TextYAlignment.Center
			nameL.Size           = UDim2.new(1, -(36 + C.ElPad * 3), 0, 18)
			nameL.Position       = UDim2.new(0, C.ElPad, 0, desc ~= "" and 8 or (math.floor(h / 2) - 9))
			nameL.Parent         = el

			if desc ~= "" then
				local dl = Instance.new("TextLabel")
				dl.BackgroundTransparency = 1
				dl.Text           = desc
				dl.TextSize       = 11
				dl.Font           = Enum.Font.Gotham
				dl.TextColor3     = Theme.TextSecondary
				dl.TextXAlignment = Enum.TextXAlignment.Left
				dl.TextYAlignment = Enum.TextYAlignment.Center
				dl.Size           = UDim2.new(1, -(36 + C.ElPad * 3), 0, 14)
				dl.Position       = UDim2.new(0, C.ElPad, 0, 28)
				dl.Parent         = el
			end

			local track = Frame(el, Theme.ToggleOff,
				UDim2.new(0, 36, 0, 20),
				UDim2.new(1, -(36 + C.ElPad), 0.5, -10)
			)
			Corner(track, 10)
			Stroke(track, Theme.Border)

			local knob = Frame(track, Theme.TextSecondary,
				UDim2.new(0, 14, 0, 14),
				UDim2.new(0, 3, 0.5, -7)
			)
			Corner(knob, 7)

			local function SetVal(v, fire)
				val = v
				if v then
					Tw(track, C.TF, {BackgroundColor3 = Theme.ToggleOn})
					Tw(knob,  C.TF, {Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = Color3.new(1, 1, 1)})
				else
					Tw(track, C.TF, {BackgroundColor3 = Theme.ToggleOff})
					Tw(knob,  C.TF, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.TextSecondary})
				end
				if fire then
					task.spawn(function()
						local ok, err = pcall(cb, val)
						if not ok then Window:Notify({Title = "Error", Content = tostring(err), Duration = 4}) end
					end)
				end
			end

			SetVal(default, false)

			local hit = Btn(el, UDim2.new(1, 0, 1, 0), nil, 5)
			hit.MouseEnter:Connect(function() Tw(el, C.TF, {BackgroundColor3 = Theme.SurfaceHover}) end)
			hit.MouseLeave:Connect(function() Tw(el, C.TF, {BackgroundColor3 = Theme.Surface}) end)
			hit.MouseButton1Click:Connect(function() SetVal(not val, true) end)

			local O = {}
			function O:Set(v) SetVal(v, true) end
			function O:Get() return val end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateSlider(opts)
			local label   = opts.Name         or "Slider"
			local min     = (opts.Range and opts.Range[1]) or 0
			local max     = (opts.Range and opts.Range[2]) or 100
			local inc     = opts.Increment    or 1
			local suffix  = opts.Suffix       or ""
			local default = opts.CurrentValue or min
			local flag    = opts.Flag
			local cb      = opts.Callback     or function() end

			local el  = El(54)
			local val = default

			local nameL = Instance.new("TextLabel")
			nameL.BackgroundTransparency = 1
			nameL.Text           = label
			nameL.TextSize       = 13
			nameL.Font           = Enum.Font.Gotham
			nameL.TextColor3     = Theme.TextPrimary
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.TextYAlignment = Enum.TextYAlignment.Center
			nameL.Size           = UDim2.new(0.55, -C.ElPad, 0, 18)
			nameL.Position       = UDim2.new(0, C.ElPad, 0, 8)
			nameL.Parent         = el

			local valL = Instance.new("TextLabel")
			valL.BackgroundTransparency = 1
			valL.TextSize       = 12
			valL.Font           = Enum.Font.GothamBold
			valL.TextColor3     = Theme.Accent
			valL.TextXAlignment = Enum.TextXAlignment.Right
			valL.TextYAlignment = Enum.TextYAlignment.Center
			valL.Size           = UDim2.new(0.45, -C.ElPad, 0, 18)
			valL.Position       = UDim2.new(0.55, 0, 0, 8)
			valL.Parent         = el

			local track = Frame(el, Theme.SliderTrack,
				UDim2.new(1, -(C.ElPad * 2), 0, 4),
				UDim2.new(0, C.ElPad, 0, 36)
			)
			Corner(track, 2)
			Stroke(track, Theme.Border)

			local fill = Frame(track, Theme.SliderFill, UDim2.new(0, 0, 1, 0))
			Corner(fill, 2)

			local thumb = Frame(track, Theme.TextPrimary,
				UDim2.new(0, 12, 0, 12),
				UDim2.new(0, -6, 0.5, -6)
			)
			Corner(thumb, 6)
			Stroke(thumb, Theme.Accent)

			local dragging = false

			local function SetVal(v, fire)
				v   = math.clamp(v, min, max)
				v   = math.floor(v / inc + 0.5) * inc
				val = v
				local pct = (v - min) / (max - min)
				Tw(fill,  C.TF, {Size     = UDim2.new(pct, 0, 1, 0)})
				Tw(thumb, C.TF, {Position = UDim2.new(pct, -6, 0.5, -6)})
				valL.Text = tostring(v) .. (suffix ~= "" and (" " .. suffix) or "")
				if fire then
					task.spawn(function()
						local ok, err = pcall(cb, val)
						if not ok then Window:Notify({Title = "Error", Content = tostring(err), Duration = 4}) end
					end)
				end
			end

			SetVal(default, false)

			local hitArea = Btn(track,
				UDim2.new(1, 24, 1, 24),
				UDim2.new(0, -12, 0, -12),
				5
			)

			local conn
			hitArea.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
				dragging = true
				if conn then conn:Disconnect() end
				conn = RunService.Heartbeat:Connect(function()
					if not dragging then
						conn:Disconnect()
						conn = nil
						return
					end
					local mx  = UserInputService:GetMouseLocation().X
					local tx  = track.AbsolutePosition.X
					local tw  = track.AbsoluteSize.X
					SetVal(min + math.clamp((mx - tx) / tw, 0, 1) * (max - min), true)
				end)
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			el.MouseEnter:Connect(function() Tw(el, C.TF, {BackgroundColor3 = Theme.SurfaceHover}) end)
			el.MouseLeave:Connect(function() Tw(el, C.TF, {BackgroundColor3 = Theme.Surface}) end)

			local O = {}
			function O:Set(v) SetVal(v, true) end
			function O:Get() return val end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateDropdown(opts)
			local label   = opts.Name           or "Dropdown"
			local options = opts.Options         or {}
			local multi   = opts.MultipleOptions or false
			local default = opts.CurrentOption   or (multi and {} or (options[1] and {options[1]} or {}))
			local flag    = opts.Flag
			local cb      = opts.Callback        or function() end

			if type(default) == "string" then default = {default} end

			local selected  = {table.unpack(default)}
			local collapsed = true
			local ROW_H     = 28
			local optH      = math.min(#options, 5) * ROW_H + 8

			local wrapper = Frame(sc, Color3.new(), UDim2.new(1, 0, 0, C.ElH))
			wrapper.BackgroundTransparency = 1
			wrapper.ClipsDescendants       = false

			local el = Frame(wrapper, Theme.Surface,
				UDim2.new(1, 0, 0, C.ElH),
				UDim2.new(0, 0, 0, 0),
				3
			)
			Corner(el, C.Rs)
			Stroke(el, Theme.Border)

			local nameL = Label(el, label, 13, Theme.TextPrimary, Enum.TextXAlignment.Left, 4)
			nameL.Size     = UDim2.new(0.48, 0, 1, 0)
			nameL.Position = UDim2.new(0, C.ElPad, 0, 0)

			local selL = Label(el, "", 12, Theme.TextSecondary, Enum.TextXAlignment.Right, 4)
			selL.Size     = UDim2.new(0.38, -(16 + C.ElPad), 1, 0)
			selL.Position = UDim2.new(0.48, 0, 0, 0)

			local arrow = Instance.new("TextLabel")
			arrow.BackgroundTransparency = 1
			arrow.Text           = "›"
			arrow.TextSize       = 16
			arrow.Font           = Enum.Font.GothamBold
			arrow.TextColor3     = Theme.TextMuted
			arrow.TextXAlignment = Enum.TextXAlignment.Center
			arrow.TextYAlignment = Enum.TextYAlignment.Center
			arrow.Rotation       = 90
			arrow.Size           = UDim2.new(0, 16, 1, 0)
			arrow.Position       = UDim2.new(1, -(16 + 8), 0, 0)
			arrow.ZIndex         = 4
			arrow.Parent         = el

			local dropList = Frame(wrapper, Theme.Surface,
				UDim2.new(1, 0, 0, 0),
				UDim2.new(0, 0, 0, C.ElH + 2),
				20
			)
			dropList.ClipsDescendants = true
			Corner(dropList, C.Rs)
			Stroke(dropList, Theme.BorderAccent)

			local listScroll = Instance.new("ScrollingFrame")
			listScroll.BackgroundTransparency = 1
			listScroll.BorderSizePixel        = 0
			listScroll.Size                   = UDim2.new(1, 0, 1, 0)
			listScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
			listScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
			listScroll.ScrollBarThickness     = 2
			listScroll.ScrollBarImageColor3   = Theme.BorderAccent
			listScroll.ZIndex                 = 20
			listScroll.Parent                 = dropList
			ListLayout(listScroll, 0)
			Pad(listScroll, 4, 4, 4, 4)

			local optBtns = {}

			local function UpdateLabel()
				if #selected == 0 then
					selL.Text = "None"
				elseif #selected == 1 then
					selL.Text = selected[1]
				else
					selL.Text = selected[1] .. " +" .. (#selected - 1)
				end
			end

			local function RefreshColors()
				for _, e in ipairs(optBtns) do
					local on = table.find(selected, e.name) ~= nil
					Tw(e.frame, C.TF, {
						BackgroundColor3       = on and Theme.AccentDim or Color3.new(),
						BackgroundTransparency = on and 0 or 1,
					})
					Tw(e.lbl, C.TF, {TextColor3 = on and Theme.TextPrimary or Theme.TextSecondary})
				end
			end

			for _, opt in ipairs(options) do
				local row = Frame(listScroll, Color3.new(), UDim2.new(1, 0, 0, ROW_H))
				row.BackgroundTransparency = 1
				row.ZIndex = 21
				Corner(row, 4)

				local rl = Label(row, opt, 12, Theme.TextSecondary, Enum.TextXAlignment.Left, 21)
				rl.Size     = UDim2.new(1, -16, 1, 0)
				rl.Position = UDim2.new(0, 8, 0, 0)

				local rb = Btn(row, UDim2.new(1, 0, 1, 0), nil, 22)
				table.insert(optBtns, {name = opt, frame = row, lbl = rl})

				rb.MouseEnter:Connect(function()
					if table.find(selected, opt) then return end
					Tw(row, C.TF, {BackgroundTransparency = 0.8, BackgroundColor3 = Theme.SurfaceHover})
				end)
				rb.MouseLeave:Connect(function()
					if table.find(selected, opt) then return end
					Tw(row, C.TF, {BackgroundTransparency = 1})
				end)
				rb.MouseButton1Click:Connect(function()
					if multi then
						local idx = table.find(selected, opt)
						if idx then table.remove(selected, idx) else table.insert(selected, opt) end
					else
						selected  = {opt}
						collapsed = true
						Tw(dropList, C.TM, {Size = UDim2.new(1, 0, 0, 0)})
						Tw(wrapper,  C.TM, {Size = UDim2.new(1, 0, 0, C.ElH)})
						Tw(arrow,    C.TF, {Rotation = 90})
					end
					UpdateLabel()
					RefreshColors()
					task.spawn(function()
						local ok, err = pcall(cb, multi and selected or selected[1])
						if not ok then Window:Notify({Title = "Error", Content = tostring(err), Duration = 4}) end
					end)
					if flag then Noctaer.Flags[flag] = {CurrentOption = selected} end
				end)
			end

			UpdateLabel()
			RefreshColors()

			local hit = Btn(el, UDim2.new(1, 0, 1, 0), nil, 5)
			hit.MouseEnter:Connect(function() Tw(el, C.TF, {BackgroundColor3 = Theme.SurfaceHover}) end)
			hit.MouseLeave:Connect(function() Tw(el, C.TF, {BackgroundColor3 = Theme.Surface}) end)
			hit.MouseButton1Click:Connect(function()
				collapsed = not collapsed
				if not collapsed then
					Tw(dropList, C.TM, {Size = UDim2.new(1, 0, 0, optH)})
					Tw(wrapper,  C.TM, {Size = UDim2.new(1, 0, 0, C.ElH + optH + 2)})
					Tw(arrow,    C.TF, {Rotation = -90})
				else
					Tw(dropList, C.TM, {Size = UDim2.new(1, 0, 0, 0)})
					Tw(wrapper,  C.TM, {Size = UDim2.new(1, 0, 0, C.ElH)})
					Tw(arrow,    C.TF, {Rotation = 90})
				end
			end)

			local O = {}
			function O:Set(v)
				if type(v) == "string" then v = {v} end
				selected = v
				UpdateLabel()
				RefreshColors()
				task.spawn(pcall, cb, multi and selected or selected[1])
			end
			function O:Get() return multi and selected or selected[1] end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateInput(opts)
			local label = opts.Name                     or "Input"
			local ph    = opts.PlaceholderText          or ""
			local flag  = opts.Flag
			local cb    = opts.Callback                 or function() end
			local clear = opts.RemoveTextAfterFocusLost or false

			local el = El(C.ElH)

			local nameL = Label(el, label, 13, Theme.TextPrimary, Enum.TextXAlignment.Left)
			nameL.Size     = UDim2.new(0.4, -C.ElPad, 1, 0)
			nameL.Position = UDim2.new(0, C.ElPad, 0, 0)

			local iFrame = Frame(el, Theme.Background,
				UDim2.new(0.55, -C.ElPad, 0, 24),
				UDim2.new(0.45, 0, 0.5, -12)
			)
			Corner(iFrame, 4)
			local iStroke = Stroke(iFrame, Theme.Border)

			local iBox = Instance.new("TextBox")
			iBox.BackgroundTransparency = 1
			iBox.PlaceholderText        = ph
			iBox.PlaceholderColor3      = Theme.TextMuted
			iBox.Text                   = ""
			iBox.TextSize               = 12
			iBox.Font                   = Enum.Font.Gotham
			iBox.TextColor3             = Theme.TextPrimary
			iBox.TextXAlignment         = Enum.TextXAlignment.Left
			iBox.ClearTextOnFocus       = false
			iBox.Size                   = UDim2.new(1, -10, 1, 0)
			iBox.Position               = UDim2.new(0, 5, 0, 0)
			iBox.Parent                 = iFrame

			iBox.Focused:Connect(function()
				Tw(iFrame, C.TF, {BackgroundColor3 = Theme.SurfaceHover})
				iStroke.Color = Theme.Accent
			end)
			iBox.FocusLost:Connect(function()
				Tw(iFrame, C.TF, {BackgroundColor3 = Theme.Background})
				iStroke.Color = Theme.Border
				task.spawn(function()
					local ok, err = pcall(cb, iBox.Text)
					if not ok then Window:Notify({Title = "Error", Content = tostring(err), Duration = 4}) end
				end)
				if clear then iBox.Text = "" end
			end)

			el.MouseEnter:Connect(function() Tw(el, C.TF, {BackgroundColor3 = Theme.SurfaceHover}) end)
			el.MouseLeave:Connect(function() Tw(el, C.TF, {BackgroundColor3 = Theme.Surface}) end)

			local O = {}
			function O:Set(v) iBox.Text = tostring(v) end
			function O:Get() return iBox.Text end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateKeybind(opts)
			local label   = opts.Name           or "Keybind"
			local default = opts.CurrentKeybind or "F"
			local flag    = opts.Flag
			local cb      = opts.Callback       or function() end

			local el        = El(C.ElH)
			local curKey    = default
			local listening = false

			local nameL = Label(el, label, 13, Theme.TextPrimary, Enum.TextXAlignment.Left)
			nameL.Size     = UDim2.new(0.6, -C.ElPad, 1, 0)
			nameL.Position = UDim2.new(0, C.ElPad, 0, 0)

			local kFrame = Frame(el, Theme.Background,
				UDim2.new(0, 58, 0, 24),
				UDim2.new(1, -(58 + C.ElPad), 0.5, -12)
			)
			Corner(kFrame, 4)
			local kStroke = Stroke(kFrame, Theme.Border)

			local kLbl = Label(kFrame, curKey, 11, Theme.Accent, Enum.TextXAlignment.Center, 4)
			kLbl.Font = Enum.Font.GothamBold

			local kBtn = Btn(kFrame, UDim2.new(1, 0, 1, 0), nil, 5)
			kBtn.MouseButton1Click:Connect(function()
				listening     = true
				kLbl.Text     = "..."
				kStroke.Color = Theme.Accent
				Tw(kFrame, C.TF, {BackgroundColor3 = Theme.SurfaceHover})
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if listening then
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						local parts = string.split(tostring(input.KeyCode), ".")
						curKey        = parts[3]
						kLbl.Text     = curKey
						listening     = false
						kStroke.Color = Theme.Border
						Tw(kFrame, C.TF, {BackgroundColor3 = Theme.Background})
						if flag then Noctaer.Flags[flag] = {CurrentKeybind = curKey} end
					end
				elseif not processed then
					local ok, kc = pcall(function() return Enum.KeyCode[curKey] end)
					if ok and kc and input.KeyCode == kc then
						task.spawn(pcall, cb)
					end
				end
			end)

			el.MouseEnter:Connect(function() Tw(el, C.TF, {BackgroundColor3 = Theme.SurfaceHover}) end)
			el.MouseLeave:Connect(function() Tw(el, C.TF, {BackgroundColor3 = Theme.Surface}) end)

			local O = {}
			function O:Set(k) curKey = tostring(k) kLbl.Text = curKey end
			function O:Get() return curKey end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateLabel(text)
			local el = Frame(sc, Theme.Surface, UDim2.new(1, 0, 0, 30))
			Corner(el, C.Rs)
			local lbl = Label(el, text, 12, Theme.TextSecondary, Enum.TextXAlignment.Left)
			lbl.Size     = UDim2.new(1, -(C.ElPad * 2), 1, 0)
			lbl.Position = UDim2.new(0, C.ElPad, 0, 0)
			local O = {}
			function O:Set(s) lbl.Text = s end
			return O
		end

		return Tab
	end

	win.BackgroundTransparency = 1
	Tw(win,    C.TM, {BackgroundTransparency = 0})
	Tw(shadow, C.TM, {ImageTransparency = 0.55})

	return Window
end

function Noctaer:Destroy()
	for _, v in ipairs(CoreGui:GetChildren()) do
		if v.Name == "Noctaer" then v:Destroy() end
	end
end

return Noctaer
