local PANEL = {}

XeninUI:CreateFont("XeninUI.Sidebar.Name", 22)

AccessorFunc(PANEL, "m_body", "Body")

function PANEL:Init()
	self:SetZPos(20)

	self.Width = 88
	self._Alpha = 0

	self.Buttons = {}
	self.Panels = {}
end

function PANEL:AddTab(name, icon, panelClass)
	local button = self:Add("DButton")
	button:SetText("")
	button.Color = color_white
	button.Desc = name
	button.Paint = function(pnl, w, h)
		surface.SetDrawColor(pnl.Color)
		surface.SetMaterial(icon)
		surface.DrawTexturedRect(27, 17, 30, 30)

		draw.SimpleText(pnl.Desc, "XeninUI.Sidebar.Name", 27 + 30 + 16, h / 2, ColorAlpha(pnl.Color, self._Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	button.OnCursorEntered = function(pnl)
		self:OnCursorEntered()

		pnl:LerpColor("Color", XeninUI.Theme.Accent)
	end
	button.OnCursorExited = function(pnl)
		self:OnCursorExited()

		if (pnl.Id == self.Active) then return end

		pnl:LerpColor("Color", color_white)
	end
	button.DoClick = function(pnl)
		self:SetActive(pnl.Id)
	end

	local id = table.insert(self.Buttons, button)
	button.Id = id

	local pnl = self:GetBody():Add(panelClass or "DPanel")
	pnl:Dock(FILL)
	pnl:SetVisible(false)

	table.insert(self.Panels, pnl)
end

function PANEL:PerformLayout(w, h)
	local y = 0

	for i, v in pairs(self.Buttons) do
		v:SetSize(w, 68)
		v:SetPos(0, y)

		y = y + v:GetTall()
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Navbar, false, false, true, false)
end

function PANEL:Think()
	if self._InvalidateParent then
		self:InvalidateParent()
	end
end

function PANEL:SetActive(id)
	if (self.Active == id) then return end

	if self.Active then
		local btn = self.Buttons[self.Active]
		local pnl = self.Panels[self.Active]
		if IsValid(btn) then
			btn:LerpColor("Color", color_white)
		end
		if IsValid(pnl) then
			pnl.DrawAlpha = pnl.DrawAlpha or 0
			pnl.PaintOver = function(pnl, w, h)
				draw.RoundedBoxEx(6, 0, 0, w, h, ColorAlpha(XeninUI.Theme.Background, pnl.DrawAlpha), false, false, true, true)
			end
			pnl:Lerp("DrawAlpha", 255, 0.15, function()
				pnl.PaintOver = nil
				pnl:SetVisible(false)
			end)
		end

		self.Active = id

		if self.OnActiveChanged then
			self:OnActiveChanged(id)
		end

		local btn = self.Buttons[id]
		local pnl = self.Panels[id]

		timer.Simple(0.15, function()
			if (!IsValid(self)) then return end

			btn:LerpColor("Color", XeninUI.Theme.Accent)
			pnl.DrawAlpha = pnl.DrawAlpha or 255
			pnl:SetVisible(true)
			if pnl.OnSwitchedTo then
				pnl:OnSwitchedTo(btn.Desc)
			end
			pnl.PaintOver = function(pnl, w, h)
				draw.RoundedBoxEx(6, 0, 0, w, h, ColorAlpha(XeninUI.Theme.Background, pnl.DrawAlpha), false, false, true, true)
			end
			pnl:Lerp("DrawAlpha", 0, 0.15, function()
				pnl.PaintOver = nil
			end)
		end)
	else

		self.Active = id

		local btn = self.Buttons[id]
		local pnl = self.Panels[id]

		btn.Color = XeninUI.Theme.Accent
		pnl:SetVisible(true)
		if pnl.OnSwitchedTo then
			pnl:OnSwitchedTo(btn.Desc)
		end
	end
end

function PANEL:OnCursorEntered()
	self._InvalidateParent = true

	local width = 0
	surface.SetFont("XeninUI.Sidebar.Name")
	for i, v in pairs(self.Buttons) do
		local tw = surface.GetTextSize(v.Desc)
		tw = tw + 88

		if (tw > width) then
			width = tw
		end
	end
	self:Lerp("Width", width, nil, function()
		self._InvalidateParent = nil
	end)
	self:Lerp("_Alpha", 255)
end

function PANEL:OnCursorExited()
	self._InvalidateParent = true

	self:Lerp("Width", 88, nil, function()
		self._InvalidateParent = nil
	end)
	self:Lerp("_Alpha", 0)
end

vgui.Register("XeninUI.Sidebar.Animated", PANEL)
