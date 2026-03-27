-- by noctaer

local Noctaer = {}
Noctaer.__index = Noctaer
Noctaer.Flags  = {}

local Svc = {
	TweenService     = game:GetService("TweenService"),
	UserInputService = game:GetService("UserInputService"),
	RunService       = game:GetService("RunService"),
	CoreGui          = game:GetService("CoreGui"),
}

local Theme = {
	Background    = Color3.fromRGB(12,  12,  14),
	Surface       = Color3.fromRGB(18,  18,  21),
	SurfaceHover  = Color3.fromRGB(24,  24,  28),
	Border        = Color3.fromRGB(32,  32,  38),
	BorderAccent  = Color3.fromRGB(50,  50,  60),
	Accent        = Color3.fromRGB(99,  102, 241),
	AccentDim     = Color3.fromRGB(60,  62,  150),
	TextPrimary   = Color3.fromRGB(220, 220, 228),
	TextSecondary = Color3.fromRGB(110, 110, 125),
	TextMuted     = Color3.fromRGB(65,  65,  78),
	ToggleOn      = Color3.fromRGB(99,  102, 241),
	ToggleOff     = Color3.fromRGB(38,  38,  46),
	SliderTrack   = Color3.fromRGB(28,  28,  34),
	SliderFill    = Color3.fromRGB(99,  102, 241),
	NotifBg       = Color3.fromRGB(16,  16,  20),
}

local K = {
	WinW    = 520,
	WinH    = 440,
	TopH    = 42,
	SideW   = 128,
	ElH     = 38,
	Pad     = 12,
	Gap     = 4,
	R       = 8,
	Rs      = 5,
	TF      = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	TM      = TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}

local function Tw(o, t, p)  Svc.TweenService:Create(o, t, p):Play() end
local function IsAlive(i)   return i and i.Parent ~= nil end

local function New(class, props, children)
	local i = Instance.new(class)
	for k, v in props do i[k] = v end
	if children then
		for _, c in children do c.Parent = i end
	end
	return i
end

local function MkCorner(p, r)
	return New("UICorner", {CornerRadius = UDim.new(0, r or K.R), Parent = p})
end

local function MkStroke(p, col, thick)
	return New("UIStroke", {
		Color           = col or Theme.Border,
		Thickness       = thick or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent          = p,
	})
end

local function MkPad(p, t, b, l, r)
	return New("UIPadding", {
		PaddingTop    = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft   = UDim.new(0, l or 0),
		PaddingRight  = UDim.new(0, r or 0),
		Parent        = p,
	})
end

local function MkList(p, gap, dir)
	return New("UIListLayout", {
		SortOrder        = Enum.SortOrder.LayoutOrder,
		Padding          = UDim.new(0, gap or 0),
		FillDirection    = dir or Enum.FillDirection.Vertical,
		Parent           = p,
	})
end

local function MkFrame(p, props)
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	for k, v in props do f[k] = v end
	f.Parent = p
	return f
end

local function MkBtn(p, props)
	local b = Instance.new("TextButton")
	b.BackgroundTransparency = 1
	b.BorderSizePixel        = 0
	b.Text                   = ""
	b.AutoButtonColor        = false
	for k, v in props do b[k] = v end
	b.Parent = p
	return b
end

local function MkLabel(p, props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font                   = Enum.Font.Gotham
	l.TextYAlignment         = Enum.TextYAlignment.Center
	for k, v in props do l[k] = v end
	l.Parent = p
	return l
end

local function GetGuiRoot()
	if gethui then return gethui() end
	if syn and syn.protect_gui then
		local sg = New("ScreenGui", {ResetOnSpawn = false})
		pcall(syn.protect_gui, sg)
		sg.Parent = Svc.CoreGui
		return sg
	end
	return Svc.CoreGui
end

function Noctaer:CreateWindow(opts)
	assert(type(opts) == "table", "CreateWindow: opts must be a table")

	local wTitle  = tostring(opts.Title    or "Noctaer")
	local wSub    = tostring(opts.Subtitle or "")
	local hideKey = opts.HideKey or Enum.KeyCode.RightControl

	local conns     = {}
	local notifIdx  = 0
	local activeTab = nil
	local tabBtns   = {}
	local tabPages  = {}
	local tabCount  = 0

	local function TrackConn(c) conns[#conns + 1] = c end
	local function DisconnectAll()
		for _, c in conns do pcall(function() c:Disconnect() end) end
		table.clear(conns)
	end

	local sg = New("ScreenGui", {
		Name           = "Noctaer",
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder   = 999,
	})

	local root = GetGuiRoot()
	local dest = (root:IsA("ScreenGui") and root.Parent) or root
	for _, v in dest:GetChildren() do
		if v ~= sg and v.Name == "Noctaer" then v:Destroy() end
	end
	sg.Parent = dest

	local notifFrame = MkFrame(sg, {
		Name                 = "Notifs",
		BackgroundTransparency = 1,
		Size                 = UDim2.new(0, 296, 1, -20),
		Position             = UDim2.new(1, -304, 0, 10),
		ZIndex               = 200,
	})
	local notifLayout = MkList(notifFrame, 6)
	notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	local Window = {}

	function Window:Notify(o)
		assert(type(o) == "table", "Notify: opts must be a table")
		local title    = tostring(o.Title   or "Notification")
		local content  = tostring(o.Content or "")
		local duration = tonumber(o.Duration) or 5

		notifIdx += 1

		local card = MkFrame(notifFrame, {
			BackgroundColor3     = Theme.NotifBg,
			BackgroundTransparency = 1,
			ClipsDescendants     = true,
			LayoutOrder          = notifIdx,
			Size                 = UDim2.new(1, 0, 0, 62),
			ZIndex               = 200,
		})
		MkCorner(card, K.Rs)
		MkStroke(card, Theme.Border)

		MkFrame(card, {
			BackgroundColor3 = Theme.Accent,
			Size             = UDim2.new(0, 3, 1, -8),
			Position         = UDim2.new(0, 0, 0, 4),
			ZIndex           = 201,
		})

		local tl = MkLabel(card, {
			Text             = title,
			TextSize         = 13,
			Font             = Enum.Font.GothamBold,
			TextColor3       = Theme.TextPrimary,
			TextXAlignment   = Enum.TextXAlignment.Left,
			TextTransparency = 1,
			Size             = UDim2.new(1, -20, 0, 18),
			Position         = UDim2.new(0, 14, 0, 9),
			ZIndex           = 201,
		})
		local cl = MkLabel(card, {
			Text             = content,
			TextSize         = 11,
			TextColor3       = Theme.TextSecondary,
			TextXAlignment   = Enum.TextXAlignment.Left,
			TextYAlignment   = Enum.TextYAlignment.Top,
			TextWrapped      = true,
			TextTransparency = 1,
			Size             = UDim2.new(1, -20, 0, 26),
			Position         = UDim2.new(0, 14, 0, 30),
			ZIndex           = 201,
		})

		Tw(card, K.TM, {BackgroundTransparency = 0})
		Tw(tl,   K.TM, {TextTransparency = 0})
		Tw(cl,   K.TM, {TextTransparency = 0.15})

		task.delay(duration, function()
			if not IsAlive(card) then return end
			Tw(card, K.TM, {BackgroundTransparency = 1})
			Tw(tl,   K.TM, {TextTransparency = 1})
			Tw(cl,   K.TM, {TextTransparency = 1})
			task.delay(K.TM.Time + 0.05, function()
				if not IsAlive(card) then return end
				Tw(card, K.TF, {Size = UDim2.new(1, 0, 0, 0)})
				task.delay(K.TF.Time + 0.05, function()
					if IsAlive(card) then card:Destroy() end
				end)
			end)
		end)
	end

	Noctaer.Notify = function(_, o) Window:Notify(o) end

	local win = MkFrame(sg, {
		BackgroundColor3     = Theme.Background,
		BackgroundTransparency = 1,
		ClipsDescendants     = false,
		Size                 = UDim2.new(0, K.WinW, 0, K.WinH),
		Position             = UDim2.new(0.5, -K.WinW / 2, 0.5, -K.WinH / 2),
		ZIndex               = 2,
	})
	MkCorner(win, K.R)
	MkStroke(win, Theme.Border)

	local shadow = New("ImageLabel", {
		BackgroundTransparency = 1,
		Image                  = "rbxassetid://6014261993",
		ImageColor3            = Color3.new(0, 0, 0),
		ImageTransparency      = 1,
		ScaleType              = Enum.ScaleType.Slice,
		SliceCenter            = Rect.new(49, 49, 450, 450),
		AnchorPoint            = Vector2.new(0.5, 0.5),
		Size                   = UDim2.new(1, 48, 1, 48),
		Position               = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex                 = 1,
		Parent                 = win,
	})

	local topbar = MkFrame(win, {
		BackgroundColor3 = Theme.Surface,
		Size             = UDim2.new(1, 0, 0, K.TopH),
		ZIndex           = 3,
	})
	MkCorner(topbar, K.R)
	MkFrame(topbar, {
		BackgroundColor3 = Theme.Surface,
		Size             = UDim2.new(1, 0, 0, K.R),
		Position         = UDim2.new(0, 0, 1, -K.R),
		ZIndex           = 3,
	})
	MkFrame(win, {
		BackgroundColor3 = Theme.Accent,
		Size             = UDim2.new(1, 0, 0, 1),
		Position         = UDim2.new(0, 0, 0, K.TopH),
		ZIndex           = 3,
	})

	if wSub ~= "" then
		MkLabel(topbar, {
			Text           = wTitle,
			TextSize       = 13,
			Font           = Enum.Font.GothamBold,
			TextColor3     = Theme.TextPrimary,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size           = UDim2.new(0, 240, 0, 18),
			Position       = UDim2.new(0, K.Pad, 0, 6),
			ZIndex         = 4,
		})
		MkLabel(topbar, {
			Text           = wSub,
			TextSize       = 11,
			TextColor3     = Theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size           = UDim2.new(0, 240, 0, 14),
			Position       = UDim2.new(0, K.Pad, 0, 24),
			ZIndex         = 4,
		})
	else
		MkLabel(topbar, {
			Text           = wTitle,
			TextSize       = 13,
			Font           = Enum.Font.GothamBold,
			TextColor3     = Theme.TextPrimary,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size           = UDim2.new(0, 240, 1, 0),
			Position       = UDim2.new(0, K.Pad, 0, 0),
			ZIndex         = 4,
		})
	end

	local function MkTopBtn(rightOffset, glyph)
		local b = MkBtn(topbar, {
			Size     = UDim2.new(0, 28, 0, 28),
			Position = UDim2.new(1, -rightOffset, 0.5, -14),
			ZIndex   = 5,
		})
		MkCorner(b, 4)
		local ic = MkLabel(b, {
			Text           = glyph,
			TextSize       = 12,
			Font           = Enum.Font.GothamBold,
			TextColor3     = Theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex         = 5,
		})
		b.MouseEnter:Connect(function()
			b.BackgroundTransparency = 0.82
			Tw(ic, K.TF, {TextColor3 = Theme.TextPrimary})
		end)
		b.MouseLeave:Connect(function()
			b.BackgroundTransparency = 1
			Tw(ic, K.TF, {TextColor3 = Theme.TextMuted})
		end)
		return b
	end

	local closeBtn = MkTopBtn(8,  "✕")
	local minBtn   = MkTopBtn(42, "─")

	closeBtn.MouseButton1Click:Connect(function()
		DisconnectAll()
		sg:Destroy()
	end)

	local dragHandle = MkBtn(topbar, {
		Size     = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex   = 3,
	})
	do
		local dragging = false
		local origin   = Vector3.zero
		local base     = UDim2.new()
		TrackConn(dragHandle.InputBegan:Connect(function(i)
			if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			dragging = true
			origin   = i.Position
			base     = win.Position
			TrackConn(i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end))
		end))
		TrackConn(Svc.UserInputService.InputChanged:Connect(function(i)
			if not dragging or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			local d = i.Position - origin
			win.Position = UDim2.new(base.X.Scale, base.X.Offset + d.X, base.Y.Scale, base.Y.Offset + d.Y)
		end))
	end

	local body = MkFrame(win, {
		BackgroundColor3 = Theme.Background,
		ClipsDescendants = true,
		Size             = UDim2.new(1, 0, 1, -K.TopH),
		Position         = UDim2.new(0, 0, 0, K.TopH),
		ZIndex           = 2,
	})

	local sidebar = MkFrame(body, {
		BackgroundColor3 = Theme.Surface,
		Size             = UDim2.new(0, K.SideW, 1, 0),
		ZIndex           = 3,
	})
	MkCorner(sidebar, K.Rs)
	MkStroke(sidebar, Theme.Border)
	MkFrame(sidebar, {
		BackgroundColor3 = Theme.Surface,
		Size             = UDim2.new(0, K.Rs, 1, 0),
		Position         = UDim2.new(1, -K.Rs, 0, 0),
		ZIndex           = 3,
	})
	MkList(sidebar, K.Gap)
	MkPad(sidebar, 8, 8, 6, 6)

	local content = MkFrame(body, {
		BackgroundColor3 = Theme.Background,
		ClipsDescendants = false,
		Size             = UDim2.new(1, -K.SideW, 1, 0),
		Position         = UDim2.new(0, K.SideW, 0, 0),
		ZIndex           = 2,
	})

	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			body.Visible = false
			Tw(win, K.TM, {Size = UDim2.new(0, K.WinW, 0, K.TopH)})
		else
			body.Visible = true
			Tw(win, K.TM, {Size = UDim2.new(0, K.WinW, 0, K.WinH)})
		end
	end)

	local hidden = false
	TrackConn(Svc.UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == hideKey then
			hidden         = not hidden
			win.Visible    = not hidden
			shadow.Visible = not hidden
		end
	end))

	local inputBeganHandlers = {}
	local inputEndedHandlers = {}

	TrackConn(Svc.UserInputService.InputBegan:Connect(function(input, processed)
		for _, h in inputBeganHandlers do h(input, processed) end
	end))
	TrackConn(Svc.UserInputService.InputEnded:Connect(function(input)
		for _, h in inputEndedHandlers do h(input) end
	end))

	local function RegisterInputBegan(id, fn)
		inputBeganHandlers[id] = fn
	end
	local function RegisterInputEnded(id, fn)
		inputEndedHandlers[id] = fn
	end
	local function UnregisterInput(id)
		inputBeganHandlers[id] = nil
		inputEndedHandlers[id] = nil
	end

	local inputId = 0
	local function NextInputId()
		inputId += 1
		return tostring(inputId)
	end

	Tw(win,    K.TM, {BackgroundTransparency = 0})
	Tw(shadow, K.TM, {ImageTransparency = 0.55})

	function Window:CreateTab(name)
		assert(type(name) == "string" and #name > 0, "CreateTab: name must be a non-empty string")
		tabCount += 1
		local myOrder = tabCount

		local btn = MkBtn(sidebar, {
			BackgroundTransparency = 1,
			Size                   = UDim2.new(1, 0, 0, 30),
			LayoutOrder            = myOrder,
			ZIndex                 = 4,
		})
		MkCorner(btn, K.Rs)

		local pill = MkFrame(btn, {
			BackgroundColor3     = Theme.Accent,
			BackgroundTransparency = 1,
			Size                 = UDim2.new(0, 3, 0, 14),
			Position             = UDim2.new(0, 0, 0.5, -7),
			ZIndex               = 4,
		})
		MkCorner(pill, 2)

		local btnLbl = MkLabel(btn, {
			Text           = name,
			TextSize       = 12,
			TextColor3     = Theme.TextSecondary,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size           = UDim2.new(1, -14, 1, 0),
			Position       = UDim2.new(0, 10, 0, 0),
			ZIndex         = 4,
		})

		local page = MkFrame(content, {
			BackgroundColor3 = Theme.Background,
			ClipsDescendants = false,
			Size             = UDim2.new(1, 0, 1, 0),
			Visible          = false,
			ZIndex           = 2,
		})

		local scroll = New("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel        = 0,
			Size                   = UDim2.new(1, 0, 1, 0),
			CanvasSize             = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize    = Enum.AutomaticSize.Y,
			ScrollBarThickness     = 2,
			ScrollBarImageColor3   = Theme.BorderAccent,
			ScrollingDirection     = Enum.ScrollingDirection.Y,
			ElasticBehavior        = Enum.ElasticBehavior.Never,
			ZIndex                 = 2,
			Parent                 = page,
		})
		MkList(scroll, K.Gap)
		MkPad(scroll, 10, 10, 10, 10)

		tabBtns[myOrder]  = {btn = btn, lbl = btnLbl, pill = pill}
		tabPages[myOrder] = {page = page}

		local function Activate()
			if activeTab == myOrder then return end
			if activeTab then
				local prev = tabBtns[activeTab]
				if prev then
					Tw(prev.btn,  K.TF, {BackgroundTransparency = 1})
					Tw(prev.lbl,  K.TF, {TextColor3 = Theme.TextSecondary})
					Tw(prev.pill, K.TF, {BackgroundTransparency = 1})
				end
				if tabPages[activeTab] then
					tabPages[activeTab].page.Visible = false
				end
			end
			activeTab    = myOrder
			page.Visible = true
			Tw(btn,    K.TF, {BackgroundTransparency = 0.65})
			Tw(btnLbl, K.TF, {TextColor3 = Theme.TextPrimary})
			Tw(pill,   K.TF, {BackgroundTransparency = 0})
		end

		btn.MouseButton1Click:Connect(Activate)
		btn.MouseEnter:Connect(function()
			if activeTab == myOrder then return end
			Tw(btn,    K.TF, {BackgroundTransparency = 0.82})
			Tw(btnLbl, K.TF, {TextColor3 = Color3.fromRGB(155, 155, 170)})
		end)
		btn.MouseLeave:Connect(function()
			if activeTab == myOrder then return end
			Tw(btn,    K.TF, {BackgroundTransparency = 1})
			Tw(btnLbl, K.TF, {TextColor3 = Theme.TextSecondary})
		end)

		if not activeTab then Activate() end

		local sc = scroll

		local function El(h)
			local f = MkFrame(sc, {
				BackgroundColor3 = Theme.Surface,
				Size             = UDim2.new(1, 0, 0, h or K.ElH),
			})
			MkCorner(f, K.Rs)
			MkStroke(f, Theme.Border)
			return f
		end

		local function HoverEl(el)
			el.MouseEnter:Connect(function() Tw(el, K.TF, {BackgroundColor3 = Theme.SurfaceHover}) end)
			el.MouseLeave:Connect(function() Tw(el, K.TF, {BackgroundColor3 = Theme.Surface}) end)
		end

		local function FireCallback(cb, ...)
			local ok, err = pcall(cb, ...)
			if not ok then Window:Notify({Title = "Callback Error", Content = tostring(err), Duration = 4}) end
		end

		local function MkNameLabel(parent, text, h, desc)
			local yPos = desc and 8 or (math.floor(h / 2) - 9)
			return MkLabel(parent, {
				Text           = text,
				TextSize       = 13,
				TextColor3     = Theme.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size           = UDim2.new(1, -(K.Pad * 2 + 80), 0, 18),
				Position       = UDim2.new(0, K.Pad, 0, yPos),
			})
		end

		local function MkDescLabel(parent, desc)
			if desc == "" then return end
			MkLabel(parent, {
				Text           = desc,
				TextSize       = 11,
				TextColor3     = Theme.TextSecondary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size           = UDim2.new(1, -(K.Pad * 2 + 80), 0, 14),
				Position       = UDim2.new(0, K.Pad, 0, 28),
			})
		end

		local Tab = {}

		function Tab:CreateSection(title)
			assert(type(title) == "string", "CreateSection: title must be a string")
			local sec = MkFrame(sc, {
				BackgroundTransparency = 1,
				Size                   = UDim2.new(1, 0, 0, 26),
			})
			MkLabel(sec, {
				Text           = title:upper(),
				TextSize       = 10,
				Font           = Enum.Font.GothamBold,
				TextColor3     = Theme.TextMuted,
				LetterSpacing  = 2,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size           = UDim2.new(0, 80, 1, 0),
				Position       = UDim2.new(0, 2, 0, 0),
			})
			MkFrame(sec, {
				BackgroundColor3 = Theme.Border,
				Size             = UDim2.new(1, -88, 0, 1),
				Position         = UDim2.new(0, 84, 0.5, 0),
			})
		end

		function Tab:CreateButton(opts)
			assert(type(opts) == "table", "CreateButton: opts must be a table")
			local label = tostring(opts.Name        or "Button")
			local desc  = tostring(opts.Description or "")
			local cb    = opts.Callback             or function() end
			local h     = desc ~= "" and 50 or K.ElH

			local el = El(h)
			HoverEl(el)
			MkNameLabel(el, label, h, desc ~= "")
			MkDescLabel(el, desc)

			local runF = MkFrame(el, {
				BackgroundColor3 = Theme.Accent,
				Size             = UDim2.new(0, 52, 0, 24),
				Position         = UDim2.new(1, -(52 + K.Pad), 0.5, -12),
			})
			MkCorner(runF, 4)
			MkLabel(runF, {
				Text           = "Run",
				TextSize       = 11,
				Font           = Enum.Font.GothamBold,
				TextColor3     = Theme.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Center,
			})

			local hit = MkBtn(el, {Size = UDim2.new(1, 0, 1, 0), ZIndex = 5})
			hit.MouseEnter:Connect(function()
				Tw(el,   K.TF, {BackgroundColor3 = Theme.SurfaceHover})
				Tw(runF, K.TF, {BackgroundColor3 = Theme.AccentDim})
			end)
			hit.MouseLeave:Connect(function()
				Tw(el,   K.TF, {BackgroundColor3 = Theme.Surface})
				Tw(runF, K.TF, {BackgroundColor3 = Theme.Accent})
			end)
			hit.MouseButton1Click:Connect(function()
				Tw(runF, K.TF, {BackgroundColor3 = Color3.fromRGB(70, 72, 180)})
				task.delay(K.TF.Time, function()
					if IsAlive(runF) then Tw(runF, K.TF, {BackgroundColor3 = Theme.Accent}) end
				end)
				task.spawn(FireCallback, cb)
			end)

			local O = {}
			function O:SetLabel(s) el.Name = s end
			return O
		end

		function Tab:CreateToggle(opts)
			assert(type(opts) == "table", "CreateToggle: opts must be a table")
			local label   = tostring(opts.Name         or "Toggle")
			local desc    = tostring(opts.Description  or "")
			local flag    = opts.Flag
			local cb      = opts.Callback              or function() end
			local h       = desc ~= "" and 50 or K.ElH

			local default
			if opts.CurrentValue ~= nil then
				default = opts.CurrentValue
			else
				default = false
			end

			local el  = El(h)
			local val = default

			MkLabel(el, {
				Text           = label,
				TextSize       = 13,
				TextColor3     = Theme.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size           = UDim2.new(1, -(36 + K.Pad * 3), 0, 18),
				Position       = UDim2.new(0, K.Pad, 0, desc ~= "" and 8 or (math.floor(h / 2) - 9)),
			})
			MkDescLabel(el, desc)

			local track = MkFrame(el, {
				BackgroundColor3 = Theme.ToggleOff,
				Size             = UDim2.new(0, 36, 0, 20),
				Position         = UDim2.new(1, -(36 + K.Pad), 0.5, -10),
			})
			MkCorner(track, 10)
			MkStroke(track, Theme.Border)

			local knob = MkFrame(track, {
				BackgroundColor3 = Theme.TextSecondary,
				Size             = UDim2.new(0, 14, 0, 14),
				Position         = UDim2.new(0, 3, 0.5, -7),
			})
			MkCorner(knob, 7)

			local function SetVal(v, fire)
				val = v
				if v then
					Tw(track, K.TF, {BackgroundColor3 = Theme.ToggleOn})
					Tw(knob,  K.TF, {Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1)})
				else
					Tw(track, K.TF, {BackgroundColor3 = Theme.ToggleOff})
					Tw(knob,  K.TF, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.TextSecondary})
				end
				if fire then task.spawn(FireCallback, cb, val) end
			end

			SetVal(default, false)

			local hit = MkBtn(el, {Size = UDim2.new(1, 0, 1, 0), ZIndex = 5})
			HoverEl(el)
			hit.MouseButton1Click:Connect(function() SetVal(not val, true) end)

			local O = {}
			function O:Set(v) SetVal(v == true, true) end
			function O:Get() return val end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateSlider(opts)
			assert(type(opts) == "table", "CreateSlider: opts must be a table")
			local label  = tostring(opts.Name      or "Slider")
			local rng    = opts.Range              or {0, 100}
			local minV   = tonumber(rng[1])        or 0
			local maxV   = tonumber(rng[2])        or 100
			local inc    = tonumber(opts.Increment) or 1
			local suffix = tostring(opts.Suffix    or "")
			local flag   = opts.Flag
			local cb     = opts.Callback           or function() end

			assert(minV < maxV, "CreateSlider: Range[1] must be less than Range[2]")

			local default
			if opts.CurrentValue ~= nil then
				default = math.clamp(tonumber(opts.CurrentValue) or minV, minV, maxV)
			else
				default = minV
			end

			local el  = El(54)
			local val = default

			MkLabel(el, {
				Text           = label,
				TextSize       = 13,
				TextColor3     = Theme.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size           = UDim2.new(0.55, -K.Pad, 0, 18),
				Position       = UDim2.new(0, K.Pad, 0, 8),
			})
			local valL = MkLabel(el, {
				TextSize       = 12,
				Font           = Enum.Font.GothamBold,
				TextColor3     = Theme.Accent,
				TextXAlignment = Enum.TextXAlignment.Right,
				Size           = UDim2.new(0.45, -K.Pad, 0, 18),
				Position       = UDim2.new(0.55, 0, 0, 8),
			})

			local track = MkFrame(el, {
				BackgroundColor3 = Theme.SliderTrack,
				Size             = UDim2.new(1, -(K.Pad * 2), 0, 4),
				Position         = UDim2.new(0, K.Pad, 0, 36),
			})
			MkCorner(track, 2)
			MkStroke(track, Theme.Border)

			local fill = MkFrame(track, {
				BackgroundColor3 = Theme.SliderFill,
				Size             = UDim2.new(0, 0, 1, 0),
			})
			MkCorner(fill, 2)

			local thumb = MkFrame(track, {
				BackgroundColor3 = Theme.TextPrimary,
				Size             = UDim2.new(0, 12, 0, 12),
				Position         = UDim2.new(0, -6, 0.5, -6),
			})
			MkCorner(thumb, 6)
			MkStroke(thumb, Theme.Accent)

			local dragging = false
			local iid      = NextInputId()

			local function SetVal(v, fire)
				v   = math.clamp(v, minV, maxV)
				v   = math.floor(v / inc + 0.5) * inc
				val = v
				local pct = (v - minV) / (maxV - minV)
				Tw(fill,  K.TF, {Size     = UDim2.new(pct, 0, 1, 0)})
				Tw(thumb, K.TF, {Position = UDim2.new(pct, -6, 0.5, -6)})
				valL.Text = tostring(v) .. (suffix ~= "" and (" " .. suffix) or "")
				if fire then task.spawn(FireCallback, cb, val) end
			end

			SetVal(default, false)

			local hitArea = MkBtn(track, {
				Size     = UDim2.new(1, 24, 1, 24),
				Position = UDim2.new(0, -12, 0, -12),
				ZIndex   = 5,
			})

			hitArea.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
				dragging = true
			end)

			local conn
			hitArea.MouseButton1Down:Connect(function()
				dragging = true
				if conn then conn:Disconnect() end
				conn = Svc.RunService.Heartbeat:Connect(function()
					if not dragging then
						conn:Disconnect()
						conn = nil
						return
					end
					local mx = Svc.UserInputService:GetMouseLocation().X
					local tx = track.AbsolutePosition.X
					local tw = track.AbsoluteSize.X
					if tw <= 0 then return end
					SetVal(minV + math.clamp((mx - tx) / tw, 0, 1) * (maxV - minV), true)
				end)
			end)

			RegisterInputEnded(iid, function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			HoverEl(el)

			local O = {}
			function O:Set(v) SetVal(v, true) end
			function O:Get() return val end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateDropdown(opts)
			assert(type(opts) == "table", "CreateDropdown: opts must be a table")
			local label   = tostring(opts.Name           or "Dropdown")
			local options = opts.Options                 or {}
			local multi   = opts.MultipleOptions         or false
			local flag    = opts.Flag
			local cb      = opts.Callback                or function() end

			local rawDefault = opts.CurrentOption
			local default
			if rawDefault == nil then
				default = multi and {} or (options[1] and {options[1]} or {})
			elseif type(rawDefault) == "string" then
				default = {rawDefault}
			else
				default = rawDefault
			end

			local selected  = {table.unpack(default)}
			local collapsed = true
			local ROW_H     = 28
			local optH      = math.min(#options, 5) * ROW_H + 8

			local wrapper = MkFrame(sc, {
				BackgroundTransparency = 1,
				ClipsDescendants       = false,
				Size                   = UDim2.new(1, 0, 0, K.ElH),
			})

			local el = MkFrame(wrapper, {
				BackgroundColor3 = Theme.Surface,
				Size             = UDim2.new(1, 0, 0, K.ElH),
				ZIndex           = 3,
			})
			MkCorner(el, K.Rs)
			MkStroke(el, Theme.Border)

			MkLabel(el, {
				Text           = label,
				TextSize       = 13,
				TextColor3     = Theme.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size           = UDim2.new(0.48, 0, 1, 0),
				Position       = UDim2.new(0, K.Pad, 0, 0),
				ZIndex         = 4,
			})
			local selL = MkLabel(el, {
				TextSize       = 12,
				TextColor3     = Theme.TextSecondary,
				TextXAlignment = Enum.TextXAlignment.Right,
				Size           = UDim2.new(0.38, -(16 + K.Pad), 1, 0),
				Position       = UDim2.new(0.48, 0, 0, 0),
				ZIndex         = 4,
			})
			local arrow = MkLabel(el, {
				Text           = "›",
				TextSize       = 16,
				Font           = Enum.Font.GothamBold,
				TextColor3     = Theme.TextMuted,
				TextXAlignment = Enum.TextXAlignment.Center,
				Rotation       = 90,
				Size           = UDim2.new(0, 16, 1, 0),
				Position       = UDim2.new(1, -24, 0, 0),
				ZIndex         = 4,
			})

			local dropList = MkFrame(wrapper, {
				BackgroundColor3 = Theme.Surface,
				ClipsDescendants = true,
				Size             = UDim2.new(1, 0, 0, 0),
				Position         = UDim2.new(0, 0, 0, K.ElH + 2),
				ZIndex           = 20,
			})
			MkCorner(dropList, K.Rs)
			MkStroke(dropList, Theme.BorderAccent)

			local listScroll = New("ScrollingFrame", {
				BackgroundTransparency = 1,
				BorderSizePixel        = 0,
				Size                   = UDim2.new(1, 0, 1, 0),
				CanvasSize             = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize    = Enum.AutomaticSize.Y,
				ScrollBarThickness     = 2,
				ScrollBarImageColor3   = Theme.BorderAccent,
				ZIndex                 = 20,
				Parent                 = dropList,
			})
			MkList(listScroll, 0)
			MkPad(listScroll, 4, 4, 4, 4)

			local optEntries = {}

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
				for _, e in optEntries do
					local on = table.find(selected, e.name) ~= nil
					e.frame.BackgroundColor3       = on and Theme.AccentDim or Color3.new()
					e.frame.BackgroundTransparency = on and 0 or 1
					e.lbl.TextColor3               = on and Theme.TextPrimary or Theme.TextSecondary
				end
			end

			local function SetCollapsed(c)
				collapsed = c
				if c then
					Tw(dropList, K.TM, {Size = UDim2.new(1, 0, 0, 0)})
					Tw(wrapper,  K.TM, {Size = UDim2.new(1, 0, 0, K.ElH)})
					Tw(arrow,    K.TF, {Rotation = 90})
				else
					Tw(dropList, K.TM, {Size = UDim2.new(1, 0, 0, optH)})
					Tw(wrapper,  K.TM, {Size = UDim2.new(1, 0, 0, K.ElH + optH + 2)})
					Tw(arrow,    K.TF, {Rotation = -90})
				end
			end

			for _, opt in options do
				local row = MkFrame(listScroll, {
					BackgroundTransparency = 1,
					Size                   = UDim2.new(1, 0, 0, ROW_H),
					ZIndex                 = 21,
				})
				MkCorner(row, 4)
				local rl = MkLabel(row, {
					Text           = opt,
					TextSize       = 12,
					TextColor3     = Theme.TextSecondary,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size           = UDim2.new(1, -16, 1, 0),
					Position       = UDim2.new(0, 8, 0, 0),
					ZIndex         = 21,
				})
				local rb = MkBtn(row, {Size = UDim2.new(1, 0, 1, 0), ZIndex = 22})
				table.insert(optEntries, {name = opt, frame = row, lbl = rl})

				rb.MouseEnter:Connect(function()
					if table.find(selected, opt) then return end
					row.BackgroundTransparency = 0.8
					row.BackgroundColor3       = Theme.SurfaceHover
				end)
				rb.MouseLeave:Connect(function()
					if table.find(selected, opt) then return end
					row.BackgroundTransparency = 1
				end)
				rb.MouseButton1Click:Connect(function()
					if multi then
						local idx = table.find(selected, opt)
						if idx then table.remove(selected, idx) else table.insert(selected, opt) end
					else
						selected = {opt}
						SetCollapsed(true)
					end
					UpdateLabel()
					RefreshColors()
					task.spawn(FireCallback, cb, multi and selected or selected[1])
					if flag then Noctaer.Flags[flag] = {CurrentOption = selected} end
				end)
			end

			UpdateLabel()
			RefreshColors()

			local hit = MkBtn(el, {Size = UDim2.new(1, 0, 1, 0), ZIndex = 5})
			hit.MouseEnter:Connect(function() Tw(el, K.TF, {BackgroundColor3 = Theme.SurfaceHover}) end)
			hit.MouseLeave:Connect(function() Tw(el, K.TF, {BackgroundColor3 = Theme.Surface}) end)
			hit.MouseButton1Click:Connect(function() SetCollapsed(not collapsed) end)

			local O = {}
			function O:Set(v)
				if type(v) == "string" then v = {v} end
				selected = v
				UpdateLabel()
				RefreshColors()
				task.spawn(FireCallback, cb, multi and selected or selected[1])
			end
			function O:Get() return multi and selected or selected[1] end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateInput(opts)
			assert(type(opts) == "table", "CreateInput: opts must be a table")
			local label = tostring(opts.Name                     or "Input")
			local ph    = tostring(opts.PlaceholderText          or "")
			local flag  = opts.Flag
			local cb    = opts.Callback                          or function() end
			local clear = opts.RemoveTextAfterFocusLost          or false

			local el = El(K.ElH)
			HoverEl(el)
			MkLabel(el, {
				Text           = label,
				TextSize       = 13,
				TextColor3     = Theme.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size           = UDim2.new(0.4, -K.Pad, 1, 0),
				Position       = UDim2.new(0, K.Pad, 0, 0),
			})

			local iFrame = MkFrame(el, {
				BackgroundColor3 = Theme.Background,
				Size             = UDim2.new(0.55, -K.Pad, 0, 24),
				Position         = UDim2.new(0.45, 0, 0.5, -12),
			})
			MkCorner(iFrame, 4)
			local iStroke = MkStroke(iFrame, Theme.Border)

			local iBox = New("TextBox", {
				BackgroundTransparency = 1,
				PlaceholderText        = ph,
				PlaceholderColor3      = Theme.TextMuted,
				Text                   = "",
				TextSize               = 12,
				Font                   = Enum.Font.Gotham,
				TextColor3             = Theme.TextPrimary,
				TextXAlignment         = Enum.TextXAlignment.Left,
				TextYAlignment         = Enum.TextYAlignment.Center,
				ClearTextOnFocus       = false,
				Size                   = UDim2.new(1, -10, 1, 0),
				Position               = UDim2.new(0, 5, 0, 0),
				Parent                 = iFrame,
			})

			iBox.Focused:Connect(function()
				Tw(iFrame, K.TF, {BackgroundColor3 = Theme.SurfaceHover})
				iStroke.Color = Theme.Accent
			end)
			iBox.FocusLost:Connect(function()
				Tw(iFrame, K.TF, {BackgroundColor3 = Theme.Background})
				iStroke.Color = Theme.Border
				task.spawn(FireCallback, cb, iBox.Text)
				if clear then iBox.Text = "" end
			end)

			local O = {}
			function O:Set(v) iBox.Text = tostring(v) end
			function O:Get() return iBox.Text end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateKeybind(opts)
			assert(type(opts) == "table", "CreateKeybind: opts must be a table")
			local label   = tostring(opts.Name           or "Keybind")
			local flag    = opts.Flag
			local cb      = opts.Callback                or function() end
			local curKey  = tostring(opts.CurrentKeybind or "F")
			local iid     = NextInputId()
			local listening = false

			local el = El(K.ElH)
			HoverEl(el)
			MkLabel(el, {
				Text           = label,
				TextSize       = 13,
				TextColor3     = Theme.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size           = UDim2.new(0.6, -K.Pad, 1, 0),
				Position       = UDim2.new(0, K.Pad, 0, 0),
			})

			local kFrame = MkFrame(el, {
				BackgroundColor3 = Theme.Background,
				Size             = UDim2.new(0, 58, 0, 24),
				Position         = UDim2.new(1, -(58 + K.Pad), 0.5, -12),
			})
			MkCorner(kFrame, 4)
			local kStroke = MkStroke(kFrame, Theme.Border)

			local kLbl = MkLabel(kFrame, {
				Text           = curKey,
				TextSize       = 11,
				Font           = Enum.Font.GothamBold,
				TextColor3     = Theme.Accent,
				TextXAlignment = Enum.TextXAlignment.Center,
				ZIndex         = 4,
			})

			local kBtn = MkBtn(kFrame, {Size = UDim2.new(1, 0, 1, 0), ZIndex = 5})
			kBtn.MouseButton1Click:Connect(function()
				listening     = true
				kLbl.Text     = "..."
				kStroke.Color = Theme.Accent
				Tw(kFrame, K.TF, {BackgroundColor3 = Theme.SurfaceHover})
			end)

			RegisterInputBegan(iid, function(input, processed)
				if listening then
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						local parts = string.split(tostring(input.KeyCode), ".")
						curKey        = parts[3]
						kLbl.Text     = curKey
						listening     = false
						kStroke.Color = Theme.Border
						Tw(kFrame, K.TF, {BackgroundColor3 = Theme.Background})
						if flag then Noctaer.Flags[flag] = {CurrentKeybind = curKey} end
					end
				elseif not processed then
					local ok, kc = pcall(function() return Enum.KeyCode[curKey] end)
					if ok and kc and input.KeyCode == kc then
						task.spawn(FireCallback, cb)
					end
				end
			end)

			local O = {}
			function O:Set(k)
				curKey    = tostring(k)
				kLbl.Text = curKey
			end
			function O:Get() return curKey end
			function O:Destroy() UnregisterInput(iid) end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateLabel(text)
			local el = MkFrame(sc, {
				BackgroundColor3 = Theme.Surface,
				Size             = UDim2.new(1, 0, 0, 30),
			})
			MkCorner(el, K.Rs)
			local lbl = MkLabel(el, {
				Text           = tostring(text or ""),
				TextSize       = 12,
				TextColor3     = Theme.TextSecondary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size           = UDim2.new(1, -(K.Pad * 2), 1, 0),
				Position       = UDim2.new(0, K.Pad, 0, 0),
			})
			local O = {}
			function O:Set(s) lbl.Text = tostring(s) end
			return O
		end

		return Tab
	end

	function Window:Destroy()
		DisconnectAll()
		if IsAlive(sg) then sg:Destroy() end
	end

	return Window
end

function Noctaer:Destroy()
	local function sweep(parent)
		for _, v in parent:GetChildren() do
			if v.Name == "Noctaer" then v:Destroy() end
		end
	end
	sweep(Svc.CoreGui)
	if gethui then pcall(sweep, gethui()) end
end

return Noctaer
