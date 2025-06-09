local PANEL = {}

AccessorFunc(PANEL, "m_bBorder", "DrawBorder", FORCE_BOOL )
AccessorFunc(PANEL, "m_settext", "BackgroundColor")
AccessorFunc(PANEL, "m_setTall", "Tall")
AccessorFunc(PANEL, "m_placeholder", "Placeholder")
AccessorFunc(PANEL, "m_textColor", "TextColor")
AccessorFunc(PANEL, "m_placeholderColor", "PlaceholderColor")
AccessorFunc(PANEL, "m_sethovercolor", "HoverColor")

TLib.Font("Button2", 20)


function PANEL:Init()

	self:SetContentAlignment( 5 )

	self:SetDrawBorder( true )
	self:SetPaintBackground( true )
	self:SetText("")
	self:SetTall( 40 )
	self:SetWide( 40 )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
	self:SetCursor( "hand" )
	self:SetFont( "TLib.Font.Button2" )
	self.titlebtn = ""
	self.colorbtn = TLib.Theme.button.mbutton
	self.setColor = color_white
	self:RoundCorners( true, true, true, true )
end

function PANEL:Paint( w, h )
	-- draw.SimpleText(self.titlebtn, "TLib.Font.Button2", w / 2, h / 2, TLib.Theme.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	TLib.DrawOutlinedBox(nil, 0, 0, w, h, TLib.Theme.outline, TLib.Theme.background, self.rc_TopLeft, self.rc_TopRight, self.rc_BottomLeft, self.rc_BottomRight)
end

function PANEL:UpdateColours( skin )

	if ( self:GetDisabled() ) then return self:SetTextStyleColor( skin.Colours.Button.Disabled ) end
	if ( self.Depressed or self:IsSelected() ) then return self:SetTextStyleColor( skin.Colours.Button.Down ) end
	if ( self.Hovered ) then return self:SetTextStyleColor( TLib.Theme.accent ) end

	return self:SetTextStyleColor( skin.Colours.Button.Normal )

end

vgui.Register("TLib.Button2", PANEL, "TLib.Button")

PANEL = table.Copy( PANEL )

function PANEL:SetActionFunction( func )

	self.DoClick = function( self, val ) func( self, "Command", 0, 0 ) end

end

derma.DefineControl( "2Button", "Backwards Compatibility", PANEL, "DLabel" )