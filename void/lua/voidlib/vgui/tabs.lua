local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self:DockMargin(0, 0, 0, 0)
	
	self.nav = self:Add("Panel")
	self.nav:Dock(TOP)
	self.nav:SSetTall(44)

	self.nav.Paint = function (self, w, h)
		VoidUI.DrawBox(0, 0, w, h, VoidUI.Colors.Primary)
	end
	
	self.selectedBtn = nil
	self.selectedPanel = nil
	self.selectedIndex = 1

	self.prevPanel = nil

	self.tabCount = 0

	self.tabs = {}
	self.tabButtons = {}

	self.animSpeed = 0.4

	self.accentColor = VoidUI.Colors.Blue
end

function PANEL:SetAccentColor(color)
	self.accentColor = color
end

function PANEL:SetMoveSpeed(speed)
	self.animSpeed = speed
end

function PANEL:PerformLayout(w, h)
	for k, v in pairs(self.tabs) do
		if (!IsValid(v)) then continue end
		v:SetSize(w, h - self.nav:GetTall())

		local x, y = v:GetPos()
		v:SetPos((k - self.selectedIndex) * w + (self:GetPos()), y)
	end
end

function PANEL:AddTab(text, panel, wide)

	surface.SetFont("VoidUI.S30")
	local textSize = surface.GetTextSize(text)

	if (textSize > sc(150)) then
		wide = textSize + 25
	end

	local tab = self.nav:Add("DButton")
	tab:Dock(LEFT)
	tab:SSetWide(wide or 160)
	tab:SetText("")


	panel:Dock(NODOCK) -- disable docking to have that nice animation
	panel:SetVisible(true)

	local x, y = panel:GetPos()
	panel:SetPos(x, self.nav:GetTall())
	

	panel:InvalidateParent(true)
	panel:InvalidateLayout(true)

	tab.text = text

	if (self.tabCount == 0) then
		self.selectedPanel = panel
		self.selectedBtn = tab
	end

	local this = self

	tab.Paint = function (self, w, h)
		local col = (self:IsHovered() and VoidUI.Colors.Hover) or VoidUI.Colors.Primary
		local textCol = VoidUI.Colors.GrayDarker
		local iconCol = VoidUI.Colors.GrayDarker
		if (self:GetParent():GetParent().selectedBtn == tab) then
			col = this.accentColor
			textCol = VoidUI.Colors.White
			iconCol = VoidUI.Colors.White
		end

		VoidUI.DrawRect(0, 0, w, h, col)

		draw.SimpleText(text, "VoidUI.S30", w/2, self:GetParent():GetParent().nav:GetTall() / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local tabIndex = self.tabCount + 1

	tab.DoClick = function ()
		self:SelectTab(tabIndex)
	end

	self.tabCount = tabIndex

	self.tabs[#self.tabs + 1] = panel
	self.tabButtons[#self.tabButtons + 1] = tab

	return tab
end


function PANEL:SelectTab(tabIndex)

	self.selectedIndex = tabIndex

	local panel = self.tabs[tabIndex]
	local tab = self.tabButtons[tabIndex]

	if (self.selectedPanel == panel) then return end

	for k, _panel in pairs(self.tabs) do
		local x, y = _panel:GetPos()

		-- _panel:Stop()
		_panel:MoveTo( (k - tabIndex) * _panel:GetWide() + self:GetPos(), y, self.animSpeed, 0, -1, function ()
			self:InvalidateLayout(true)
			_panel:InvalidateChildren(true)
		end)
	end


	self.selectedPanel = panel
	self.selectedBtn = tab
end


vgui.Register("VoidUI.Tabs", PANEL, "Panel")
