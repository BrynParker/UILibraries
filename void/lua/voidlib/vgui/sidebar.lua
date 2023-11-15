local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self:Dock(LEFT)
	self:DockMargin(0, 0, 0, 0)
	self:SSetWide(100)
	
	self.selectedBtn = nil
	self.selectedPanel = nil

	self.tabCount = 0
	self.fadeSpeed = 0.1

	self.loadedPanels = {}
	self.tabs = {}

	self.accentColor = nil
end

function PANEL:SetAccentColor(color)
	self.accentColor = color
end

function PANEL:SetFadeSpeed(speed)
	self.fadeSpeed = speed
end

function PANEL:SetActive(bool)
	for tab, panel in pairs(self.tabs) do
		tab:SetEnabled(bool)
		tab:SetCursor(bool and "none" or "no")
	end
end

function PANEL:SelectTab(tab)
	local panel = self.tabs[tab]
	self:SwitchTab(tab, panel)
end

function PANEL:SwitchTab(tab, panel)

	if (!self.loadedPanels[panel]) then
		local pStr = panel

		panel = self:GetParent():Add(panel)
		panel:Dock(FILL)

		self.loadedPanels[pStr] = panel

	else
		panel = self.loadedPanels[panel]
	end


	self.selectedBtn = tab

	if (self.selectedPanel == panel) then return end

	if (self.tabCount == 0) then
		panel:SetVisible(true)
	else
		local prevPanel = self.selectedPanel
		if (IsValid(prevPanel)) then
			prevPanel:FadeOutPanel(self.fadeSpeed, function ()
				panel:FadeInPanel(self.fadeSpeed)
			end)
		end
	end


	self.selectedPanel = panel
end

function PANEL:AddTab(text, icon, panel, bottomAlign, _iconSize)
	local tab = self:Add("DButton")
	tab:Dock((bottomAlign and BOTTOM) or TOP)
	tab:SetTall(sc(100))
	tab:SetText("")

	tab.text = text
	tab.icon = icon

	if (self.tabCount == 0) then
		self:SwitchTab(tab, panel)
	end

	local iconSize = _iconSize or {40,40}

	tab.Paint = function (self, w, h)
		local col = (self:IsHovered() and VoidUI.Colors.Hover) or VoidUI.Colors.Primary
		local textCol = VoidUI.Colors.GrayDarker
		local iconCol = VoidUI.Colors.GrayDarker
		if (self:GetParent().selectedBtn == tab) then
			col = self:GetParent().accentColor or VoidUI.Colors.Blue
			textCol = VoidUI.Colors.White
			iconCol = VoidUI.Colors.White
		end

		local icoX = sc(iconSize[1])
		local icoY = sc(iconSize[2])


		surface.SetDrawColor(col)
		surface.DrawRect(0,0,w,h)

		if (icon) then
			surface.SetDrawColor(iconCol)
			surface.SetMaterial(icon)

			surface.DrawTexturedRect(w/2-icoX/2,sc(23),icoX,icoY)
		end

		draw.SimpleText(text, "VoidUI.S20", w/2, icoY+sc(35), textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	tab.DoClick = function ()
		self:SwitchTab(tab, panel)
	end

	self.tabCount = self.tabCount + 1
	self.tabs[tab] = panel

	return tab
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(VoidUI.Colors.Primary)
	surface.DrawRect(0,0,w,h)
end

vgui.Register("VoidUI.Sidebar", PANEL, "DPanel")
