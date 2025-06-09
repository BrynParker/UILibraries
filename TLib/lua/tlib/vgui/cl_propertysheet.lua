
local PANEL = {}

AccessorFunc( PANEL, "m_pPropertySheet", "PropertySheet" )
AccessorFunc( PANEL, "m_pPanel", "Panel" )

-- Derma_Hook( PANEL, "Paint", "Paint", "Tab" )

TLib.Font("PropertySheet", 14)

function PANEL:Init()

	self:SetMouseInputEnabled( true )
	self:SetContentAlignment( 7 )
	self:SetTextInset( 0, 25 )
	-- self:SetFont("TLib.Font.PropertySheet")

end

function PANEL:Setup( label, pPropertySheet, pPanel)

	self:SetText( label )
	self:SetPropertySheet( pPropertySheet )
	self:SetPanel( pPanel )

	self:SetWide( self:GetContentSize() + 10 )
end

function PANEL:IsActive()
	return self:GetPropertySheet():GetActiveTab() == self
end

function PANEL:DoClick()

	self:GetPropertySheet():SetActiveTab( self )

end

function PANEL:PerformLayout()

	self:ApplySchemeSettings()

	if ( !self.Image ) then return end

	self.Image:SetPos( 7, 3 )

	if ( !self:IsActive() ) then
		self.Image:SetImageColor( Color( 255, 255, 255, 155 ) )
	else
		self.Image:SetImageColor( color_white )
	end

end

function PANEL:UpdateColours( skin )

	if ( self:IsActive() ) then

		if ( self:GetDisabled() ) then return self:SetTextStyleColor( skin.Colours.Tab.Active.Disabled ) end
		if ( self:IsDown() ) then return self:SetTextStyleColor( skin.Colours.Tab.Active.Down ) end
		if ( self.Hovered ) then return self:SetTextStyleColor( skin.Colours.Tab.Active.Hover ) end

		return self:SetTextStyleColor( skin.Colours.Tab.Active.Normal )

	end

	if ( self:GetDisabled() ) then return self:SetTextStyleColor( skin.Colours.Tab.Inactive.Disabled ) end
	if ( self:IsDown() ) then return self:SetTextStyleColor( skin.Colours.Tab.Inactive.Down ) end
	if ( self.Hovered ) then return self:SetTextStyleColor( skin.Colours.Tab.Inactive.Hover ) end

	return self:SetTextStyleColor( skin.Colours.Tab.Inactive.Normal )

end

function PANEL:GetTabHeight()
		return 28
end

function PANEL:ApplySchemeSettings()

	local ExtraInset = 10

	if ( self.Image ) then
		ExtraInset = ExtraInset + self.Image:GetWide()
	end

	self:SetTextInset( ExtraInset, 4 )
	local w, h = self:GetContentSize()
	h = self:GetTabHeight()

	self:SetSize( w + 10, h + 10)

	DLabel.ApplySchemeSettings( self )

end

--
-- DragHoverClick
--
function PANEL:DragHoverClick( HoverTime )

	self:DoClick()

end

function PANEL:DoRightClick()

	if not IsValid(self:GetPropertySheet()) then return end

	local tabs = vgui.Create("TLib.ContextMenu", self)

	for k, v in pairs(self:GetPropertySheet().Items) do
		if not v or not IsValid(v.Tab) or not v.Tab:IsVisible() then continue end

		tabs:AddOption(v.Tab:GetText(), function()
			if not v or not IsValid(v.Tab) or not IsValid(self:GetPropertySheet()) or not IsValid(self:GetPropertySheet().tabScroller) then return end
			v.Tab:DoClick()
			self:GetPropertySheet().tabScroller:ScrollToChild(v.Tab)
		end)
	end

	tabs:Open()

end

function PANEL:Paint()
	TLib.DrawOutlinedBox(nil, 0, 0, self:GetWide(), self:GetTall(), (self:IsHovered() and TLib.Theme.accentalpha or TLib.Theme.outline), TLib.Theme.outline)

	if (self:IsActive()) then 
		TLib.DrawOutlinedBox(nil, 0, 0, self:GetWide(), self:GetTall(), TLib.Theme.accent, TLib.Theme.outline)
	end

	-- draw.SimpleText(self:GetText(), "TLib.Font.PropertySheet", self:GetWide() / 2, self:GetTall() / 2, TLib.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

derma.DefineControl( "TLib.Tab", "A Tab for use on the PropertySheet", PANEL, "TLib.Button" )

--[[---------------------------------------------------------
	DPropertySheet
-----------------------------------------------------------]]

local PANEL = {}

AccessorFunc( PANEL, "m_pActiveTab", "ActiveTab" )
AccessorFunc( PANEL, "m_iPadding", "Padding" )
AccessorFunc( PANEL, "m_fFadeTime", "FadeTime" )

AccessorFunc( PANEL, "m_bShowIcons", "ShowIcons" )

function PANEL:Init()

	self:SetShowIcons( true )

	self.tabScroller = vgui.Create( "DHorizontalScroller", self )
	self.tabScroller:SetOverlap( 0 )
	self.tabScroller:Dock( TOP )
	self.tabScroller:DockMargin( 0,0,0,0 )
	self.tabScroller.Paint = function() 
		
		-- TLib.DrawRoundedOutline( 0, 0, self.tabScroller:GetWide(), self.tabScroller:GetTall(), TLib.Theme.outline, TLib.Theme.outline)
		-- TLib.DrawOutlinedBox(nil, 0, 0, self.tabScroller:GetWide(), self.tabScroller:GetTall(), TLib.Theme.background, TLib.Theme.outline)

	end
	self.tabScroller.btnLeft.Paint = function() end
	self.tabScroller.btnRight.Paint = function() end

	self:SetFadeTime( 0.1 )
	self:SetPadding( 5 )

	self.animFade = Derma_Anim( "Fade", self, self.CrossFade )

	self.Items = {}

end

function PANEL:AddSheet( label, panel, material, NoStretchX, NoStretchY, Tooltip )

	if ( !IsValid( panel ) ) then
		ErrorNoHalt( "DPropertySheet:AddSheet tried to add invalid panel!" )
		debug.Trace()
		return
	end

	local Sheet = {}

	Sheet.Name = label

	Sheet.Tab = vgui.Create( "TLib.Tab", self )
	Sheet.Tab:SetTooltip( Tooltip )
	Sheet.Tab:Setup( label, self, panel, material )
	

	Sheet.Panel = panel
	Sheet.Panel.NoStretchX = NoStretchX
	Sheet.Panel.NoStretchY = NoStretchY
	Sheet.Panel:SetPos( self:GetPadding(), 20 + self:GetPadding() )
	Sheet.Panel:SetVisible( false )

	panel:SetParent( self )

	table.insert( self.Items, Sheet )

	if ( !self:GetActiveTab() ) then
		self:SetActiveTab( Sheet.Tab )
		Sheet.Panel:SetVisible( true )
	end

	self.tabScroller:AddPanel( Sheet.Tab )

	return Sheet

end

function PANEL:SetActiveTab( active )

	if ( !IsValid( active ) || self.m_pActiveTab == active ) then return end

	if ( IsValid( self.m_pActiveTab ) ) then

		-- Only run this callback when we actually switch a tab, not when a tab is initially set active
		self:OnActiveTabChanged( self.m_pActiveTab, active )

		if ( self:GetFadeTime() > 0 ) then

			self.animFade:Start( self:GetFadeTime(), { OldTab = self.m_pActiveTab, NewTab = active } )

		else

			self.m_pActiveTab:GetPanel():SetVisible( false )

		end

	end

	self.m_pActiveTab = active
	self:InvalidateLayout()

end

function PANEL:OnActiveTabChanged( old, new )
	-- For override
end

function PANEL:Think()

	self.animFade:Run()

end

function PANEL:GetItems()

	return self.Items

end

function PANEL:CrossFade( anim, delta, data )

	if ( !data || !IsValid( data.OldTab ) || !IsValid( data.NewTab ) ) then return end

	local old = data.OldTab:GetPanel()
	local new = data.NewTab:GetPanel()

	if ( !IsValid( old ) && !IsValid( new ) ) then return end

	if ( anim.Finished ) then
		if ( IsValid( old ) ) then
			old:SetAlpha( 255 )
			old:SetZPos( 0 )
			old:SetVisible( false )
		end

		if ( IsValid( new ) ) then
			new:SetAlpha( 255 )
			new:SetZPos( 0 )
			new:SetVisible( true ) // In case new == old
		end

		return
	end

	if ( anim.Started ) then
		if ( IsValid( old ) ) then
			old:SetAlpha( 255 )
			old:SetZPos( 0 )
		end

		if ( IsValid( new ) ) then
			new:SetAlpha( 0 )
			new:SetZPos( 1 )
		end

	end

	if ( IsValid( old ) ) then
		old:SetVisible( true )
		if ( !IsValid( new ) ) then old:SetAlpha( 255 * ( 1 - delta ) ) end
	end

	if ( IsValid( new ) ) then
		new:SetVisible( true )
		new:SetAlpha( 255 * delta )
	end

end

function PANEL:PerformLayout()
	local activeTab = self:GetActiveTab()
	local padding = self:GetPadding()

	if not IsValid(activeTab) then return end

	activeTab:InvalidateLayout(true)

	self.tabScroller:SetTall(activeTab:GetTall())

	local activePanel = activeTab:GetPanel()

	for k, v in pairs(self.Items) do
		if v.Tab:GetPanel() == activePanel then
			if IsValid(v.Tab:GetPanel()) then v.Tab:GetPanel():SetVisible(true) end
			v.Tab:SetZPos(100)
		else
			if IsValid(v.Tab:GetPanel()) then v.Tab:GetPanel():SetVisible(false) end
			v.Tab:SetZPos(1)
		end
	end

	if IsValid(activePanel) then
		if not activePanel.NoStretchX then
			activePanel:SetWide(self:GetWide() - padding * 2)
		else
			activePanel:CenterHorizontal()
		end

		if not activePanel.NoStretchY then
			local _, y = activePanel:GetPos()
			activePanel:SetTall(self:GetTall() - y - padding)
		else
			activePanel:CenterVertical()
		end

		activePanel:InvalidateLayout()
	end

	self.animFade:Run()

end

function PANEL:SizeToContentWidth()
	local wide = 0

	for k, v in pairs(self.Items) do
		if IsValid(v.Panel) then
			v.Panel:InvalidateLayout(true)
			wide = math.max(wide, v.Panel:GetWide() + self:GetPadding() * 2)
		end
	end

	self:SetWide(wide)
end

function PANEL:SwitchToName( name )

	for k, v in pairs( self.Items ) do

		if ( v.Name == name ) then
			v.Tab:DoClick()
			return true
		end

	end

	return false
end

function PANEL:CloseTab( tab, bRemovePanelToo )
	for k, v in pairs( self.Items ) do
		if ( v.Tab != tab ) then continue end

		table.remove( self.Items, k )
	end

	for k, v in pairs( self.tabScroller.Panels ) do
		if ( v != tab ) then continue end

		table.remove( self.tabScroller.Panels, k )
	end

	self.tabScroller:InvalidateLayout( true )

	if ( tab == self:GetActiveTab() ) then
		self.m_pActiveTab = self.Items[ #self.Items ].Tab
	end

	local pnl = tab:GetPanel()

	if ( bRemovePanelToo ) then
		pnl:Remove()
	end

	tab:Remove()

	self:InvalidateLayout( true )

	return pnl
end

function PANEL:Paint(w,h)
    local x, y = self:LocalToScreen()

	BSHADOWS.BeginShadow()
    -- TLib.DrawRoundedOutline(x, y, w, h, TLib.Theme.outline, TLib.Theme.background)
	TLib.DrawOutlinedBox(nil, x, y, w, h, TLib.Theme.background, TLib.Theme.outline)
    BSHADOWS.EndShadow(1, 2, 2)
end

function PANEL:SetupDock(pos, left, top, right, bottom)
	self:Dock(pos)
	self:DockMargin(left or 0, top or 0, right or 0, bottom or 0)
end

function PANEL:SetupTooltip(text)
	self:SetTooltip(text)
	self:SetTooltipPanelOverride("TLib.Tooltip")
end

vgui.Register("TLib.PropertySheet", PANEL, "Panel" )
