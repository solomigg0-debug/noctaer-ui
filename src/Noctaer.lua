-- by noctaer

local Noctaer = {}
Noctaer.__index = Noctaer
Noctaer.Flags  = {}

local Svc = {
	Tween = game:GetService("TweenService"),
	UIS   = game:GetService("UserInputService"),
	RS    = game:GetService("RunService"),
	CG    = game:GetService("CoreGui"),
}

local Theme = {
	Bg          = Color3.fromRGB(12,  12,  14),
	Surface     = Color3.fromRGB(18,  18,  21),
	SurfaceH    = Color3.fromRGB(24,  24,  28),
	Border      = Color3.fromRGB(32,  32,  38),
	BorderA     = Color3.fromRGB(50,  50,  60),
	Accent      = Color3.fromRGB(99,  102, 241),
	AccentDim   = Color3.fromRGB(60,  62,  150),
	Text1       = Color3.fromRGB(220, 220, 228),
	Text2       = Color3.fromRGB(110, 110, 125),
	TextM       = Color3.fromRGB(65,  65,  78),
	TogOn       = Color3.fromRGB(99,  102, 241),
	TogOff      = Color3.fromRGB(38,  38,  46),
	SliderT     = Color3.fromRGB(28,  28,  34),
	SliderF     = Color3.fromRGB(99,  102, 241),
	NotifBg     = Color3.fromRGB(16,  16,  20),
}

local K = {
	WW = 520, WH = 440, TH = 42, SW = 130, EH = 38, P = 12, G = 4, R = 8, Rs = 5,
	TF = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	TM = TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}

local function Tw(o, t, p)   Svc.Tween:Create(o, t, p):Play() end
local function Alive(i)      return i and i.Parent ~= nil end

local function Inst(cls, props)
	local o = Instance.new(cls)
	for k, v in props do o[k] = v end
	return o
end

local function Frame(parent, props)
	local f = Inst("Frame", props)
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

local function Btn(parent, props)
	local b = Inst("TextButton", props)
	b.BorderSizePixel  = 0
	b.Text             = ""
	b.AutoButtonColor  = false
	b.Parent = parent
	return b
end

local function Lbl(parent, props)
	local l = Inst("TextLabel", props)
	l.BackgroundTransparency = 1
	l.Font                   = Enum.Font.Gotham
	l.TextYAlignment         = Enum.TextYAlignment.Center
	l.Parent = parent
	return l
end

local function Corner(p, r)
	return Inst("UICorner", {CornerRadius = UDim.new(0, r or K.R), Parent = p})
end

local function Stroke(p, col, t)
	return Inst("UIStroke", {Color = col or Theme.Border, Thickness = t or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p})
end

local function Pad(p, t, b, l, r)
	return Inst("UIPadding", {
		PaddingTop    = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft   = UDim.new(0, l or 0), PaddingRight  = UDim.new(0, r or 0),
		Parent = p,
	})
end

local function List(p, gap)
	return Inst("UIListLayout", {
		SortOrder  = Enum.SortOrder.LayoutOrder,
		Padding    = UDim.new(0, gap or 0),
		Parent     = p,
	})
end

local function Scroll(parent, props)
	local s = Inst("ScrollingFrame", props)
	s.BorderSizePixel      = 0
	s.ScrollBarThickness   = 2
	s.ScrollBarImageColor3 = Theme.BorderA
	s.ScrollingDirection   = Enum.ScrollingDirection.Y
	s.ElasticBehavior      = Enum.ElasticBehavior.Never
	s.CanvasSize           = UDim2.new()
	s.AutomaticCanvasSize  = Enum.AutomaticSize.Y
	s.BackgroundTransparency = 1
	s.Parent = parent
	return s
end

local function GuiRoot()
	if gethui then return gethui() end
	local g = Inst("ScreenGui", {ResetOnSpawn = false})
	if syn and syn.protect_gui then pcall(syn.protect_gui, g) end
	g.Parent = Svc.CG
	return g
end

function Noctaer:CreateWindow(opts)
	local wTitle  = tostring(opts.Title    or "Noctaer")
	local wSub    = tostring(opts.Subtitle or "")
	local hideKey = opts.HideKey or Enum.KeyCode.RightControl

	local conns      = {}
	local notifN     = 0
	local activeTab  = nil
	local tabData    = {}
	local tabN       = 0
	local iBegin     = {}
	local iEnd       = {}
	local iId        = 0

	local function TC(c)   conns[#conns+1] = c end
	local function DAC()   for _, c in conns do pcall(c.Disconnect, c) end table.clear(conns) end
	local function NID()   iId+=1; return iId end
	local function RegB(id, fn) iBegin[id] = fn end
	local function RegE(id, fn) iEnd[id]   = fn end
	local function UnReg(id)    iBegin[id] = nil; iEnd[id] = nil end

	local sg = Inst("ScreenGui", {
		Name = "Noctaer", ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = 999,
	})
	local root = GuiRoot()
	local dest = root:IsA("ScreenGui") and root.Parent or root
	for _, v in dest:GetChildren() do
		if v ~= sg and v.Name == "Noctaer" then v:Destroy() end
	end
	sg.Parent = dest

	TC(Svc.UIS.InputBegan:Connect(function(i, p) for _, h in iBegin do h(i, p) end end))
	TC(Svc.UIS.InputEnded:Connect(function(i)    for _, h in iEnd   do h(i) end   end))

	-- ── Notif container (fixed to screen, not inside win) ──────────────────
	local notifFrame = Frame(sg, {
		Name = "Notifs", BackgroundTransparency = 1,
		Size = UDim2.new(0, 296, 1, -20), Position = UDim2.new(1, -304, 0, 10),
		ZIndex = 200,
	})
	local nLayout = List(notifFrame, 6)
	nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	local Window = {}

	function Window:Notify(o)
		local title    = tostring(o.Title   or "Notification")
		local content  = tostring(o.Content or "")
		local duration = tonumber(o.Duration) or 5
		notifN += 1

		local card = Frame(notifFrame, {
			BackgroundColor3 = Theme.NotifBg, BackgroundTransparency = 1,
			ClipsDescendants = true, LayoutOrder = notifN,
			Size = UDim2.new(1, 0, 0, 62), ZIndex = 200,
		})
		Corner(card, K.Rs); Stroke(card, Theme.Border)
		Frame(card, {BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 3, 1, -8),
			Position = UDim2.new(0, 0, 0, 4), ZIndex = 201})

		local tl = Lbl(card, {Text = title, TextSize = 13, Font = Enum.Font.GothamBold,
			TextColor3 = Theme.Text1, TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1, Size = UDim2.new(1, -20, 0, 18),
			Position = UDim2.new(0, 14, 0, 9), ZIndex = 201})
		local cl = Lbl(card, {Text = content, TextSize = 11, TextColor3 = Theme.Text2,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true, TextTransparency = 1, Size = UDim2.new(1, -20, 0, 26),
			Position = UDim2.new(0, 14, 0, 30), ZIndex = 201})

		Tw(card, K.TM, {BackgroundTransparency = 0})
		Tw(tl, K.TM, {TextTransparency = 0})
		Tw(cl, K.TM, {TextTransparency = 0.15})

		task.delay(duration, function()
			if not Alive(card) then return end
			Tw(card, K.TM, {BackgroundTransparency = 1})
			Tw(tl,   K.TM, {TextTransparency = 1})
			Tw(cl,   K.TM, {TextTransparency = 1})
			task.delay(K.TM.Time + 0.05, function()
				if not Alive(card) then return end
				Tw(card, K.TF, {Size = UDim2.new(1, 0, 0, 0)})
				task.delay(K.TF.Time + 0.05, function()
					if Alive(card) then card:Destroy() end
				end)
			end)
		end)
	end

	Noctaer.Notify = function(_, o) Window:Notify(o) end

	-- ── Window root (no ClipsDescendants — dropdown overflow) ─────────────
	local win = Frame(sg, {
		BackgroundColor3 = Theme.Bg, BackgroundTransparency = 1,
		ClipsDescendants = false,
		Size = UDim2.new(0, K.WW, 0, K.WH),
		Position = UDim2.new(0.5, -K.WW/2, 0.5, -K.WH/2),
		ZIndex = 2,
	})
	Corner(win, K.R)
	Stroke(win, Theme.Border)

	-- shadow as child of win so it follows drag
	local shadow = Inst("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(),
		ImageTransparency = 1, ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 48, 1, 48), Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 1, Parent = win,
	})

	-- ── Topbar ─────────────────────────────────────────────────────────────
	local topbar = Frame(win, {
		BackgroundColor3 = Theme.Surface,
		Size = UDim2.new(1, 0, 0, K.TH), ZIndex = 3,
	})
	Corner(topbar, K.R)
	-- fill bottom rounded corners of topbar with a plain rect
	Frame(topbar, {
		BackgroundColor3 = Theme.Surface,
		Size = UDim2.new(1, 0, 0, K.R), Position = UDim2.new(0, 0, 1, -K.R), ZIndex = 3,
	})
	-- accent line
	Frame(win, {
		BackgroundColor3 = Theme.Accent,
		Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, K.TH), ZIndex = 3,
	})

	if wSub ~= "" then
		Lbl(topbar, {Text = wTitle, TextSize = 13, Font = Enum.Font.GothamBold,
			TextColor3 = Theme.Text1, TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 240, 0, 18), Position = UDim2.new(0, K.P, 0, 6), ZIndex = 4})
		Lbl(topbar, {Text = wSub, TextSize = 11, TextColor3 = Theme.TextM,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 240, 0, 14), Position = UDim2.new(0, K.P, 0, 24), ZIndex = 4})
	else
		Lbl(topbar, {Text = wTitle, TextSize = 13, Font = Enum.Font.GothamBold,
			TextColor3 = Theme.Text1, TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 240, 1, 0), Position = UDim2.new(0, K.P, 0, 0), ZIndex = 4})
	end

	local function MkTopBtn(rOff, glyph)
		local b = Btn(topbar, {
			Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -rOff, 0.5, -14), ZIndex = 5,
		})
		Corner(b, 4)
		local ic = Lbl(b, {Text = glyph, TextSize = 12, Font = Enum.Font.GothamBold,
			TextColor3 = Theme.TextM, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5})
		b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.82; Tw(ic, K.TF, {TextColor3 = Theme.Text1}) end)
		b.MouseLeave:Connect(function() b.BackgroundTransparency = 1;    Tw(ic, K.TF, {TextColor3 = Theme.TextM}) end)
		return b
	end

	local closeBtn = MkTopBtn(8,  "✕")
	local minBtn   = MkTopBtn(42, "─")
	closeBtn.MouseButton1Click:Connect(function() DAC(); sg:Destroy() end)

	-- drag via topbar (ZIndex 3 sits under buttons at ZIndex 5)
	do
		local drag, orig, base = false, Vector3.zero, UDim2.new()
		TC(topbar.InputBegan:Connect(function(i)
			if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			drag = true; orig = i.Position; base = win.Position
			TC(i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then drag = false end
			end))
		end))
		TC(Svc.UIS.InputChanged:Connect(function(i)
			if not drag or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			local d = i.Position - orig
			win.Position = UDim2.new(base.X.Scale, base.X.Offset + d.X, base.Y.Scale, base.Y.Offset + d.Y)
		end))
	end

	-- ── Body: clips to window bounds but ONLY the sidebar+content layer ───
	-- We need body to clip so elements don't bleed outside window,
	-- BUT dropdowns need to overflow. Solution: body clips, dropdown ZIndex
	-- is set high enough to render above body clip plane on Global ZIndex mode.
	-- On executors that break Global ZIndex, dropdown is inside scroll's
	-- ClipsDescendants=false page, so it still overflows through content.
	local body = Frame(win, {
		BackgroundColor3 = Theme.Bg, ClipsDescendants = true,
		Size = UDim2.new(1, 0, 1, -K.TH), Position = UDim2.new(0, 0, 0, K.TH), ZIndex = 2,
	})

	-- ── Sidebar: NO UIListLayout corner-fix frame ─────────────────────────
	-- Root cause of previous bug: corner-fix Frame was a child of sidebar
	-- and was picked up by UIListLayout (LayoutOrder=0), displacing tab buttons.
	-- Fix: use ClipsDescendants=false on sidebar + a full-height fill rect
	-- positioned absolutely, outside the list layout flow.
	local sidebar = Frame(body, {
		BackgroundColor3 = Theme.Surface, ClipsDescendants = false,
		Size = UDim2.new(0, K.SW, 1, 0), ZIndex = 3,
	})
	-- Stroke applied directly — no corner needed on sidebar since it's rectangular
	-- against window edge; we only round the left side
	Corner(sidebar, K.Rs)
	Stroke(sidebar, Theme.Border)

	-- This rect patches the right-side rounded corners of sidebar.
	-- CRITICAL: must NOT be a child of sidebar (would join UIListLayout).
	-- Parent it to body instead, positioned to overlap sidebar's right edge.
	Frame(body, {
		BackgroundColor3 = Theme.Surface,
		Size = UDim2.new(0, K.Rs + 1, 1, 0),
		Position = UDim2.new(0, K.SW - K.Rs, 0, 0),
		ZIndex = 2,  -- behind sidebar border stroke (ZIndex 3)
	})

	-- Now add layout to sidebar — only tab buttons will be children
	local sideList = List(sidebar, K.G)
	sideList.VerticalAlignment = Enum.VerticalAlignment.Top
	Pad(sidebar, 8, 8, 6, 6)

	-- ── Content panel ──────────────────────────────────────────────────────
	-- ClipsDescendants = false: dropdowns inside pages need to overflow body bounds
	local content = Frame(body, {
		BackgroundColor3 = Theme.Bg, ClipsDescendants = false,
		Size = UDim2.new(1, -K.SW, 1, 0), Position = UDim2.new(0, K.SW, 0, 0),
		ZIndex = 2,
	})

	-- minimize
	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			body.Visible = false
			Tw(win, K.TM, {Size = UDim2.new(0, K.WW, 0, K.TH)})
		else
			body.Visible = true
			Tw(win, K.TM, {Size = UDim2.new(0, K.WW, 0, K.WH)})
		end
	end)

	local hidden = false
	TC(Svc.UIS.InputBegan:Connect(function(i, p)
		if p then return end
		if i.KeyCode == hideKey then
			hidden = not hidden
			win.Visible    = not hidden
			shadow.Visible = not hidden
		end
	end))

	-- intro anim
	Tw(win,    K.TM, {BackgroundTransparency = 0})
	Tw(shadow, K.TM, {ImageTransparency = 0.55})

	-- ── Tab factory ────────────────────────────────────────────────────────
	function Window:CreateTab(name)
		tabN += 1
		local order = tabN

		local btn = Btn(sidebar, {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = order, ZIndex = 4,
		})
		Corner(btn, K.Rs)

		local pill = Frame(btn, {
			BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1,
			Size = UDim2.new(0, 3, 0, 14), Position = UDim2.new(0, 0, 0.5, -7), ZIndex = 4,
		})
		Corner(pill, 2)

		local btnLbl = Lbl(btn, {
			Text = name, TextSize = 12, TextColor3 = Theme.Text2,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 10, 0, 0), ZIndex = 4,
		})

		-- page sits inside content, not clipped by content
		local page = Frame(content, {
			BackgroundColor3 = Theme.Bg, ClipsDescendants = false,
			Size = UDim2.new(1, 0, 1, 0), Visible = false, ZIndex = 2,
		})

		local sc = Scroll(page, {Size = UDim2.new(1, 0, 1, 0), ZIndex = 2})
		List(sc, K.G)
		Pad(sc, 10, 10, 10, 10)

		tabData[order] = {btn = btn, lbl = btnLbl, pill = pill, page = page}

		local function Activate()
			if activeTab == order then return end
			if activeTab and tabData[activeTab] then
				local p = tabData[activeTab]
				Tw(p.btn,  K.TF, {BackgroundTransparency = 1})
				Tw(p.lbl,  K.TF, {TextColor3 = Theme.Text2})
				Tw(p.pill, K.TF, {BackgroundTransparency = 1})
				p.page.Visible = false
			end
			activeTab    = order
			page.Visible = true
			Tw(btn,    K.TF, {BackgroundTransparency = 0.65})
			Tw(btnLbl, K.TF, {TextColor3 = Theme.Text1})
			Tw(pill,   K.TF, {BackgroundTransparency = 0})
		end

		btn.MouseButton1Click:Connect(Activate)
		btn.MouseEnter:Connect(function()
			if activeTab == order then return end
			Tw(btn,    K.TF, {BackgroundTransparency = 0.82})
			Tw(btnLbl, K.TF, {TextColor3 = Color3.fromRGB(155, 155, 170)})
		end)
		btn.MouseLeave:Connect(function()
			if activeTab == order then return end
			Tw(btn,    K.TF, {BackgroundTransparency = 1})
			Tw(btnLbl, K.TF, {TextColor3 = Theme.Text2})
		end)

		if not activeTab then Activate() end

		-- ── Element helpers ────────────────────────────────────────────────
		local function El(h)
			local f = Frame(sc, {BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 0, h or K.EH)})
			Corner(f, K.Rs); Stroke(f, Theme.Border)
			return f
		end

		local function Hover(el)
			el.MouseEnter:Connect(function() Tw(el, K.TF, {BackgroundColor3 = Theme.SurfaceH}) end)
			el.MouseLeave:Connect(function() Tw(el, K.TF, {BackgroundColor3 = Theme.Surface})  end)
		end

		local function CB(fn, ...)
			local ok, e = pcall(fn, ...)
			if not ok then Window:Notify({Title = "Error", Content = tostring(e), Duration = 4}) end
		end

		local function NameLbl(el, txt, h, hasDesc)
			return Lbl(el, {
				Text = txt, TextSize = 13, TextColor3 = Theme.Text1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -(K.P*2 + 80), 0, 18),
				Position = UDim2.new(0, K.P, 0, hasDesc and 8 or (math.floor(h/2) - 9)),
			})
		end

		local function DescLbl(el, desc)
			if desc == "" then return end
			Lbl(el, {
				Text = desc, TextSize = 11, TextColor3 = Theme.Text2,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -(K.P*2 + 80), 0, 14),
				Position = UDim2.new(0, K.P, 0, 28),
			})
		end

		local Tab = {}

		function Tab:CreateSection(title)
			local sec = Frame(sc, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26)})
			Lbl(sec, {
				Text = title:upper(), TextSize = 10, Font = Enum.Font.GothamBold,
				TextColor3 = Theme.TextM, LetterSpacing = 2,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(0, 2, 0, 0),
			})
			Frame(sec, {BackgroundColor3 = Theme.Border, Size = UDim2.new(1, -88, 0, 1), Position = UDim2.new(0, 84, 0.5, 0)})
		end

		function Tab:CreateButton(opts)
			local lbl  = tostring(opts.Name        or "Button")
			local desc = tostring(opts.Description or "")
			local cb   = opts.Callback             or function() end
			local h    = desc ~= "" and 50 or K.EH
			local el   = El(h); Hover(el)
			NameLbl(el, lbl, h, desc ~= ""); DescLbl(el, desc)

			local runF = Frame(el, {BackgroundColor3 = Theme.Accent,
				Size = UDim2.new(0, 52, 0, 24), Position = UDim2.new(1, -(52+K.P), 0.5, -12)})
			Corner(runF, 4)
			Lbl(runF, {Text = "Run", TextSize = 11, Font = Enum.Font.GothamBold,
				TextColor3 = Theme.Text1, TextXAlignment = Enum.TextXAlignment.Center})

			local hit = Btn(el, {Size = UDim2.new(1,0,1,0), ZIndex = 5})
			hit.MouseEnter:Connect(function() Tw(el, K.TF, {BackgroundColor3 = Theme.SurfaceH}); Tw(runF, K.TF, {BackgroundColor3 = Theme.AccentDim}) end)
			hit.MouseLeave:Connect(function() Tw(el, K.TF, {BackgroundColor3 = Theme.Surface});  Tw(runF, K.TF, {BackgroundColor3 = Theme.Accent}) end)
			hit.MouseButton1Click:Connect(function()
				Tw(runF, K.TF, {BackgroundColor3 = Color3.fromRGB(70,72,180)})
				task.delay(K.TF.Time, function() if Alive(runF) then Tw(runF, K.TF, {BackgroundColor3 = Theme.Accent}) end end)
				task.spawn(CB, cb)
			end)

			local O = {}; function O:SetLabel(s) NameLbl(el, s, h, desc ~= "") end; return O
		end

		function Tab:CreateToggle(opts)
			local lbl     = tostring(opts.Name or "Toggle")
			local desc    = tostring(opts.Description or "")
			local flag    = opts.Flag
			local cb      = opts.Callback or function() end
			local h       = desc ~= "" and 50 or K.EH
			local val     = opts.CurrentValue == true
			local el      = El(h)

			Lbl(el, {Text = lbl, TextSize = 13, TextColor3 = Theme.Text1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -(36+K.P*3), 0, 18),
				Position = UDim2.new(0, K.P, 0, desc ~= "" and 8 or (math.floor(h/2)-9))})
			DescLbl(el, desc)

			local track = Frame(el, {BackgroundColor3 = Theme.TogOff,
				Size = UDim2.new(0, 36, 0, 20), Position = UDim2.new(1, -(36+K.P), 0.5, -10)})
			Corner(track, 10); Stroke(track, Theme.Border)
			local knob = Frame(track, {BackgroundColor3 = Theme.Text2,
				Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, -7)})
			Corner(knob, 7)

			local function Set(v, fire)
				val = v
				if v then
					Tw(track, K.TF, {BackgroundColor3 = Theme.TogOn})
					Tw(knob,  K.TF, {Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1)})
				else
					Tw(track, K.TF, {BackgroundColor3 = Theme.TogOff})
					Tw(knob,  K.TF, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.Text2})
				end
				if fire then task.spawn(CB, cb, val) end
			end
			Set(val, false)

			Hover(el)
			Btn(el, {Size = UDim2.new(1,0,1,0), ZIndex = 5}).MouseButton1Click:Connect(function() Set(not val, true) end)

			local O = {}
			function O:Set(v) Set(v == true, true) end
			function O:Get() return val end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateSlider(opts)
			local lbl    = tostring(opts.Name or "Slider")
			local rng    = opts.Range or {0, 100}
			local minV   = tonumber(rng[1]) or 0
			local maxV   = tonumber(rng[2]) or 100
			local inc    = tonumber(opts.Increment) or 1
			local suf    = tostring(opts.Suffix or "")
			local flag   = opts.Flag
			local cb     = opts.Callback or function() end
			local defV   = math.clamp(tonumber(opts.CurrentValue) or minV, minV, maxV)
			local val    = defV
			local el     = El(54)

			Lbl(el, {Text = lbl, TextSize = 13, TextColor3 = Theme.Text1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0.55, -K.P, 0, 18), Position = UDim2.new(0, K.P, 0, 8)})
			local valL = Lbl(el, {TextSize = 12, Font = Enum.Font.GothamBold, TextColor3 = Theme.Accent,
				TextXAlignment = Enum.TextXAlignment.Right,
				Size = UDim2.new(0.45, -K.P, 0, 18), Position = UDim2.new(0.55, 0, 0, 8)})

			local track = Frame(el, {BackgroundColor3 = Theme.SliderT,
				Size = UDim2.new(1, -(K.P*2), 0, 4), Position = UDim2.new(0, K.P, 0, 36)})
			Corner(track, 2); Stroke(track, Theme.Border)
			local fill  = Frame(track, {BackgroundColor3 = Theme.SliderF, Size = UDim2.new(0,0,1,0)})
			Corner(fill, 2)
			local thumb = Frame(track, {BackgroundColor3 = Theme.Text1,
				Size = UDim2.new(0,12,0,12), Position = UDim2.new(0,-6,0.5,-6)})
			Corner(thumb, 6); Stroke(thumb, Theme.Accent)

			local dragging = false
			local iid = NID()

			local function Set(v, fire)
				v   = math.clamp(math.floor(v/inc + 0.5)*inc, minV, maxV)
				val = v
				local pct = (v-minV)/(maxV-minV)
				Tw(fill,  K.TF, {Size = UDim2.new(pct, 0, 1, 0)})
				Tw(thumb, K.TF, {Position = UDim2.new(pct, -6, 0.5, -6)})
				valL.Text = tostring(v) .. (suf ~= "" and " "..suf or "")
				if fire then task.spawn(CB, cb, val) end
			end
			Set(defV, false)

			local hitArea = Btn(track, {Size = UDim2.new(1,24,1,24), Position = UDim2.new(0,-12,0,-12), ZIndex = 5})
			local conn
			hitArea.MouseButton1Down:Connect(function()
				dragging = true
				if conn then conn:Disconnect() end
				conn = Svc.RS.Heartbeat:Connect(function()
					if not dragging then conn:Disconnect(); conn = nil; return end
					local mx = Svc.UIS:GetMouseLocation().X
					local tw = track.AbsoluteSize.X
					if tw <= 0 then return end
					Set(minV + math.clamp((mx - track.AbsolutePosition.X)/tw, 0, 1)*(maxV-minV), true)
				end)
			end)
			RegE(iid, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			Hover(el)

			local O = {}
			function O:Set(v) Set(v, true) end
			function O:Get() return val end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateDropdown(opts)
			local lbl     = tostring(opts.Name or "Dropdown")
			local options = opts.Options or {}
			local multi   = opts.MultipleOptions or false
			local flag    = opts.Flag
			local cb      = opts.Callback or function() end
			local raw     = opts.CurrentOption
			local def     = type(raw) == "string" and {raw} or (raw or (multi and {} or (options[1] and {options[1]} or {})))
			local sel     = {table.unpack(def)}
			local closed  = true
			local ROW     = 28
			local optH    = math.min(#options, 5) * ROW + 8

			-- wrapper: grows when open; ClipsDescendants=false for overflow
			local wrap = Frame(sc, {BackgroundTransparency = 1, ClipsDescendants = false, Size = UDim2.new(1,0,0,K.EH)})
			local el   = Frame(wrap, {BackgroundColor3 = Theme.Surface, Size = UDim2.new(1,0,0,K.EH), ZIndex = 3})
			Corner(el, K.Rs); Stroke(el, Theme.Border)

			Lbl(el, {Text = lbl, TextSize = 13, TextColor3 = Theme.Text1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0.48, 0, 1, 0), Position = UDim2.new(0, K.P, 0, 0), ZIndex = 4})
			local selL = Lbl(el, {TextSize = 12, TextColor3 = Theme.Text2,
				TextXAlignment = Enum.TextXAlignment.Right,
				Size = UDim2.new(0.38, -(16+K.P), 1, 0), Position = UDim2.new(0.48, 0, 0, 0), ZIndex = 4})
			local arrow = Lbl(el, {Text = "›", TextSize = 16, Font = Enum.Font.GothamBold,
				TextColor3 = Theme.TextM, TextXAlignment = Enum.TextXAlignment.Center,
				Rotation = 90, Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -24, 0, 0), ZIndex = 4})

			local dropList = Frame(wrap, {BackgroundColor3 = Theme.Surface, ClipsDescendants = true,
				Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,0,K.EH+2), ZIndex = 20})
			Corner(dropList, K.Rs); Stroke(dropList, Theme.BorderA)
			local listSc = Scroll(dropList, {Size = UDim2.new(1,0,1,0), ZIndex = 20})
			List(listSc, 0); Pad(listSc, 4,4,4,4)

			local entries = {}

			local function UpdLbl()
				selL.Text = #sel == 0 and "None" or #sel == 1 and sel[1] or sel[1].." +"..(#sel-1)
			end

			local function RefCol()
				for _, e in entries do
					local on = table.find(sel, e.name) ~= nil
					e.f.BackgroundColor3       = on and Theme.AccentDim or Color3.new()
					e.f.BackgroundTransparency = on and 0 or 1
					e.l.TextColor3             = on and Theme.Text1 or Theme.Text2
				end
			end

			local function Collapse(c)
				closed = c
				if c then
					Tw(dropList, K.TM, {Size = UDim2.new(1,0,0,0)})
					Tw(wrap,     K.TM, {Size = UDim2.new(1,0,0,K.EH)})
					Tw(arrow,    K.TF, {Rotation = 90})
				else
					Tw(dropList, K.TM, {Size = UDim2.new(1,0,0,optH)})
					Tw(wrap,     K.TM, {Size = UDim2.new(1,0,0,K.EH+optH+2)})
					Tw(arrow,    K.TF, {Rotation = -90})
				end
			end

			for _, opt in options do
				local row = Frame(listSc, {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,ROW), ZIndex = 21})
				Corner(row, 4)
				local rl  = Lbl(row, {Text = opt, TextSize = 12, TextColor3 = Theme.Text2,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1,-16,1,0), Position = UDim2.new(0,8,0,0), ZIndex = 21})
				local rb  = Btn(row, {Size = UDim2.new(1,0,1,0), ZIndex = 22})
				table.insert(entries, {name = opt, f = row, l = rl})

				rb.MouseEnter:Connect(function()
					if table.find(sel, opt) then return end
					row.BackgroundTransparency = 0.8; row.BackgroundColor3 = Theme.SurfaceH
				end)
				rb.MouseLeave:Connect(function()
					if table.find(sel, opt) then return end
					row.BackgroundTransparency = 1
				end)
				rb.MouseButton1Click:Connect(function()
					if multi then
						local i = table.find(sel, opt)
						if i then table.remove(sel, i) else table.insert(sel, opt) end
					else
						sel = {opt}; Collapse(true)
					end
					UpdLbl(); RefCol()
					task.spawn(CB, cb, multi and sel or sel[1])
					if flag then Noctaer.Flags[flag] = {CurrentOption = sel} end
				end)
			end

			UpdLbl(); RefCol()
			local hit = Btn(el, {Size = UDim2.new(1,0,1,0), ZIndex = 5})
			hit.MouseEnter:Connect(function() Tw(el, K.TF, {BackgroundColor3 = Theme.SurfaceH}) end)
			hit.MouseLeave:Connect(function() Tw(el, K.TF, {BackgroundColor3 = Theme.Surface})  end)
			hit.MouseButton1Click:Connect(function() Collapse(not closed) end)

			local O = {}
			function O:Set(v)
				sel = type(v) == "string" and {v} or v
				UpdLbl(); RefCol()
				task.spawn(CB, cb, multi and sel or sel[1])
			end
			function O:Get() return multi and sel or sel[1] end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateInput(opts)
			local lbl   = tostring(opts.Name or "Input")
			local ph    = tostring(opts.PlaceholderText or "")
			local flag  = opts.Flag
			local cb    = opts.Callback or function() end
			local clear = opts.RemoveTextAfterFocusLost or false
			local el    = El(K.EH); Hover(el)

			Lbl(el, {Text = lbl, TextSize = 13, TextColor3 = Theme.Text1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0.4, -K.P, 1, 0), Position = UDim2.new(0, K.P, 0, 0)})

			local iF = Frame(el, {BackgroundColor3 = Theme.Bg,
				Size = UDim2.new(0.55, -K.P, 0, 24), Position = UDim2.new(0.45, 0, 0.5, -12)})
			Corner(iF, 4); local iS = Stroke(iF, Theme.Border)

			local iB = Inst("TextBox", {
				BackgroundTransparency = 1, PlaceholderText = ph, PlaceholderColor3 = Theme.TextM,
				Text = "", TextSize = 12, Font = Enum.Font.Gotham, TextColor3 = Theme.Text1,
				TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
				ClearTextOnFocus = false, Size = UDim2.new(1,-10,1,0), Position = UDim2.new(0,5,0,0),
				Parent = iF,
			})
			iB.Focused:Connect(function() Tw(iF, K.TF, {BackgroundColor3 = Theme.SurfaceH}); iS.Color = Theme.Accent end)
			iB.FocusLost:Connect(function()
				Tw(iF, K.TF, {BackgroundColor3 = Theme.Bg}); iS.Color = Theme.Border
				task.spawn(CB, cb, iB.Text)
				if clear then iB.Text = "" end
			end)

			local O = {}
			function O:Set(v) iB.Text = tostring(v) end
			function O:Get() return iB.Text end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateKeybind(opts)
			local lbl   = tostring(opts.Name or "Keybind")
			local flag  = opts.Flag
			local cb    = opts.Callback or function() end
			local key   = tostring(opts.CurrentKeybind or "F")
			local iid   = NID()
			local lstn  = false
			local el    = El(K.EH); Hover(el)

			Lbl(el, {Text = lbl, TextSize = 13, TextColor3 = Theme.Text1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(0.6, -K.P, 1, 0), Position = UDim2.new(0, K.P, 0, 0)})

			local kF = Frame(el, {BackgroundColor3 = Theme.Bg,
				Size = UDim2.new(0, 58, 0, 24), Position = UDim2.new(1, -(58+K.P), 0.5, -12)})
			Corner(kF, 4); local kS = Stroke(kF, Theme.Border)
			local kL = Lbl(kF, {Text = key, TextSize = 11, Font = Enum.Font.GothamBold,
				TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4})
			local kB = Btn(kF, {Size = UDim2.new(1,0,1,0), ZIndex = 5})
			kB.MouseButton1Click:Connect(function()
				lstn = true; kL.Text = "..."; kS.Color = Theme.Accent
				Tw(kF, K.TF, {BackgroundColor3 = Theme.SurfaceH})
			end)

			RegB(iid, function(i, p)
				if lstn then
					if i.KeyCode ~= Enum.KeyCode.Unknown then
						local parts = string.split(tostring(i.KeyCode), ".")
						key = parts[3]; kL.Text = key; lstn = false
						kS.Color = Theme.Border; Tw(kF, K.TF, {BackgroundColor3 = Theme.Bg})
						if flag then Noctaer.Flags[flag] = {CurrentKeybind = key} end
					end
				elseif not p then
					local ok, kc = pcall(function() return Enum.KeyCode[key] end)
					if ok and kc and i.KeyCode == kc then task.spawn(CB, cb) end
				end
			end)

			local O = {}
			function O:Set(k) key = tostring(k); kL.Text = key end
			function O:Get() return key end
			function O:Destroy() UnReg(iid) end
			if flag then Noctaer.Flags[flag] = O end
			return O
		end

		function Tab:CreateLabel(text)
			local el = Frame(sc, {BackgroundColor3 = Theme.Surface, Size = UDim2.new(1,0,0,30)})
			Corner(el, K.Rs)
			local l = Lbl(el, {Text = tostring(text or ""), TextSize = 12, TextColor3 = Theme.Text2,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1,-(K.P*2),1,0), Position = UDim2.new(0,K.P,0,0)})
			local O = {}; function O:Set(s) l.Text = tostring(s) end; return O
		end

		return Tab
	end

	function Window:Destroy() DAC(); if Alive(sg) then sg:Destroy() end end

	return Window
end

function Noctaer:Destroy()
	local function sweep(p) for _, v in p:GetChildren() do if v.Name == "Noctaer" then v:Destroy() end end end
	sweep(Svc.CG)
	if gethui then pcall(sweep, gethui()) end
end

return Noctaer
