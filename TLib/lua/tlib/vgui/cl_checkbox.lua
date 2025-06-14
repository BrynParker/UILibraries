-- ┏┳┓┓ •┓               
--  ┃ ┃ ┓┣┓              
--  ┻ ┗┛┗┗┛  
local PANEL = {}

AccessorFunc( PANEL, "m_bChecked", "Checked", FORCE_BOOL )

Derma_Hook( PANEL, "Paint", "Paint", "CheckBox" )
Derma_Hook( PANEL, "ApplySchemeSettings", "Scheme", "CheckBox" )
Derma_Hook( PANEL, "PerformLayout", "Layout", "CheckBox" )

Derma_Install_Convar_Functions( PANEL )

function PANEL:Init()
	self:SetSize( 15, 15 )
	self:SetText( "" )
end

function PANEL:SetupDock(pos, left, top, right, bottom)
	self:Dock(pos)
	self:DockMargin(left or 0, top or 0, right or 0, bottom or 0)
end

function PANEL:IsEditing()
	return self.Depressed
end

function PANEL:SetValue( val )

	if ( tonumber( val ) == 0 ) then val = 0 end // Tobool bugs out with "0.00"
	val = tobool( val )

	self:SetChecked( val )
	self.m_bValue = val

	self:OnChange( val )

	if ( val ) then val = "1" else val = "0" end
	self:ConVarChanged( val )

end

function PANEL:DoClick()

	self:Toggle()

end

function PANEL:Toggle()

	self:SetValue( !self:GetChecked() )

end

function PANEL:OnChange( bVal )

	-- For override

end

function PANEL:Paint()
    local w, h = self:GetSize()

	TLib.DrawOutlinedBox(nil, 0, 0, w, h, TLib.Theme.outline, TLib.Theme.background)


    if self:GetChecked() then
		TLib.DrawOutlinedBox(nil, 0, 0, w, h, TLib.Theme.outline, TLib.Theme.accent)
	else 
    end

    if self:IsHovered() then
		TLib.DrawOutlinedBox(nil, 0, 0, w, h, TLib.Theme.accentalpha, self:GetChecked() and TLib.Theme.accent or TLib.Theme.outline)
    end
    

                
        
end

function PANEL:SetupFunction(func1, func2)
	self.OnChange = func1
	self.OnChange2 = func2
end

function PANEL:Think()

	self:ConVarStringThink()

end

vgui.Register("TLib.CheckBox", PANEL, "DButton")

--[[---------------------------------------------------------
	DCheckBoxLabel
-----------------------------------------------------------]]

local PANEL = {}

AccessorFunc( PANEL, "m_iIndent", "Indent" )

function PANEL:Init()
	self:SetTall( 16 )

	self.Button = vgui.Create( "TLib.CheckBox", self )
	self.Button.OnChange = function( _, val ) self:OnChange( val ) end

	self.Label = vgui.Create( "TLib.Label_internal", self )
	self.Label:SetMouseInputEnabled( true )
	self.Label.DoClick = function() self:Toggle() end
end

function PANEL:SetDark( b )
	self.Label:SetDark( b )
end

function PANEL:SetBright( b )
	self.Label:SetBright( b )
end

function PANEL:SetConVar( cvar )
	self.Button:SetConVar( cvar )
end

function PANEL:SetValue( val )
	self.Button:SetValue( val )
end

function PANEL:SetChecked( val )
	self.Button:SetChecked( val )
end

function PANEL:GetChecked( val )
	return self.Button:GetChecked()
end

function PANEL:Toggle()
	self.Button:Toggle()
end

function PANEL:PerformLayout()

	local x = self.m_iIndent || 0

	self.Button:SetSize( 15, 15 )
	self.Button:SetPos( x, math.floor( ( self:GetTall() - self.Button:GetTall() ) / 2 ) )

	self.Label:SizeToContents()
	self.Label:SetPos( x + self.Button:GetWide() + 9, math.floor( ( self:GetTall() - self.Label:GetTall() ) / 2 ) )

end

function PANEL:SetTextColor( color )
	self.Label:SetTextColor( color )
end

function PANEL:SizeToContents()
	self:InvalidateLayout( true ) -- Update the size of the DLabel and the X offset
	self:SetWide( self.Label.x + self.Label:GetWide() )
	self:SetTall( math.max( self.Button:GetTall(), self.Label:GetTall() ) )
	self:InvalidateLayout() -- Update the positions of all children
end

function PANEL:SetText( text )
	self.Label:SetText( text )
	self:SizeToContents()
end

function PANEL:SetFont( font )
	self.Label:SetFont( font )
	self:SizeToContents()
end

function PANEL:GetText()
	return self.Label:GetText()
end

-- function PANEL:Paint()
-- end

function PANEL:OnChange( bVal )
end

function PANEL:GetDock()
	return self.m_iDock
end

function PANEL:SetupDock(pos, left, top, right, bottom)
	self:Dock(pos)
	self:DockMargin(left or 0, top or 0, right or 0, bottom or 0)
end

function PANEL:SetupTooltip(text)
	self:SetTooltip(text)
	self:SetTooltipPanelOverride("TLib.Tooltip")
end

vgui.Register("TLib.CheckBoxLabel", PANEL, "DPanel")