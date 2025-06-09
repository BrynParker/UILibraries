
local PANEL = {}

local strAllowedNumericCharacters = "1234567890.-"

AccessorFunc( PANEL, "m_bAllowEnter", "EnterAllowed", FORCE_BOOL )
AccessorFunc( PANEL, "m_bUpdateOnType", "UpdateOnType", FORCE_BOOL ) -- Update the convar as we type
AccessorFunc( PANEL, "m_bNumeric", "Numeric", FORCE_BOOL )
AccessorFunc( PANEL, "m_bHistory", "HistoryEnabled", FORCE_BOOL )
AccessorFunc( PANEL, "m_bDisableTabbing", "TabbingDisabled", FORCE_BOOL )

AccessorFunc( PANEL, "m_FontName", "Font" )
AccessorFunc( PANEL, "m_bBorder", "DrawBorder" )
AccessorFunc( PANEL, "m_bBackground", "PaintBackground" )
AccessorFunc( PANEL, "m_bBackground", "DrawBackground" ) -- Deprecated

AccessorFunc( PANEL, "m_colText", "TextColor" )
AccessorFunc( PANEL, "m_colHighlight", "HighlightColor" )
AccessorFunc( PANEL, "m_colCursor", "CursorColor" )

AccessorFunc( PANEL, "m_colPlaceholder", "PlaceholderColor" )
AccessorFunc( PANEL, "m_txtPlaceholder", "PlaceholderText" )

Derma_Install_Convar_Functions( PANEL )

TLib.Font("TextEntry", 20)

function PANEL:Init()

	self:SetHistoryEnabled( false )
	self.History = {}
	self.HistoryPos = 0
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackgroundEnabled( false )
	self:SetDrawBorder( true )
	self:SetPaintBackground( true )
	self:SetEnterAllowed( true )
	self:SetUpdateOnType( false )
	self:SetNumeric( false )
	self:SetAllowNonAsciiCharacters( true )
	self:SetTall( 20 )
	self.m_bLoseFocusOnClickAway = true
	self:SetCursor( "beam" )
	self:SetFont( "TLib.Font.TextEntry" )
	self:SetDrawLanguageID( false )

end

function PANEL:IsEditing()
	return self == vgui.GetKeyboardFocus()
end

function PANEL:OnKeyCodeTyped( code )

	self:OnKeyCode( code )

	if ( code == KEY_ENTER && !self:IsMultiline() && self:GetEnterAllowed() ) then

		if ( IsValid( self.Menu ) ) then
			self.Menu:Remove()
		end

		self:FocusNext()
		self:OnEnter( self:GetText() )
		self.HistoryPos = 0

	end

	if ( self.m_bHistory || IsValid( self.Menu ) ) then

		if ( code == KEY_UP ) then
			self.HistoryPos = self.HistoryPos - 1
			self:UpdateFromHistory()
		end

		if ( code == KEY_DOWN || code == KEY_TAB ) then
			self.HistoryPos = self.HistoryPos + 1
			self:UpdateFromHistory()
		end

	end

end

function PANEL:OnKeyCode( code )
end

function PANEL:ApplySchemeSettings()
	self:SetFontInternal( self.m_FontName )
	derma.SkinHook( "Scheme", "TextEntry", self )
end

function PANEL:GetTextColor()
	return self.m_colText || self:GetSkin().colTextEntryText
end

function PANEL:GetPlaceholderColor()
	return self.m_colPlaceholder || self:GetSkin().colTextEntryTextPlaceholder
end

function PANEL:GetHighlightColor()
	return self.m_colHighlight || self:GetSkin().colTextEntryTextHighlight
end

function PANEL:GetCursorColor()
	return self.m_colCursor || self:GetSkin().colTextEntryTextCursor
end

function PANEL:UpdateFromHistory()

	if ( IsValid( self.Menu ) ) then
		return self:UpdateFromMenu()
	end

	local pos = self.HistoryPos
	if ( pos < 0 ) then pos = #self.History end
	if ( pos > #self.History ) then pos = 0 end

	local text = self.History[ pos ]
	if ( !text ) then text = "" end

	self:SetText( text )
	self:SetCaretPos( text:len() )
	self:OnTextChanged()
	self.HistoryPos = pos
end

function PANEL:UpdateFromMenu()

	local pos = self.HistoryPos
	local num = self.Menu:ChildCount()

	self.Menu:ClearHighlights()

	if ( pos < 0 ) then pos = num end
	if ( pos > num ) then pos = 0 end

	local item = self.Menu:GetChild( pos )
	if ( !item ) then
		self:SetText( "" )
		self.HistoryPos = pos
		return
	end

	self.Menu:HighlightItem( item )

	local txt = item:GetText()
	self:SetText( txt )
	self:SetCaretPos( txt:len() )

	self:OnTextChanged( true )
	self.HistoryPos = pos
end

function PANEL:OnTextChanged( noMenuRemoval )
	self.HistoryPos = 0

	if ( self:GetUpdateOnType() ) then
		self:UpdateConvarValue()
		self:OnValueChange( self:GetText() )
	end

	if ( IsValid( self.Menu ) && !noMenuRemoval ) then
		self.Menu:Remove()
	end

	local tab = self:GetAutoComplete( self:GetText() )
	if ( tab ) then
		self:OpenAutoComplete( tab )
	end

	self:OnChange()
end

function PANEL:OnChange()
end

function PANEL:OpenAutoComplete( tab )
	if ( !tab ) then return end
	if ( #tab == 0 ) then return end

	self.Menu = TLib.ContextMenu()

	for k, v in pairs( tab ) do
		self.Menu:AddOption( v, function() self:SetText( v ) self:SetCaretPos( v:len() ) self:RequestFocus() end )
	end

	local x, y = self:LocalToScreen( 0, self:GetTall() )
	self.Menu:SetMinimumWidth( self:GetWide() )
	self.Menu:Open( x, y, true, self )
	self.Menu:SetPos( x, y )
	self.Menu:SetMaxHeight( ( ScrH() - y ) - 10 )
end

function PANEL:Think()
	self:ConVarStringThink()
end

function PANEL:OnRemove()
	if ( IsValid( self.Menu ) ) then
		self.Menu:Remove()
	end
end

function PANEL:OnEnter( val )
	self:UpdateConvarValue()
	self:OnValueChange( self:GetText() )
end

function PANEL:UpdateConvarValue()
	self:ConVarChanged( self:GetValue() )
end

function PANEL:PerformLayout()
	derma.SkinHook( "Layout", "TextEntry", self )
end

function PANEL:SetValue( strValue )
	if ( vgui.GetKeyboardFocus() == self ) then return end

	local CaretPos = self:GetCaretPos()

	self:SetText( strValue )
	self:OnValueChange( strValue )

	self:SetCaretPos( CaretPos )

end

function PANEL:OnValueChange( strValue )
end

function PANEL:CheckNumeric( strValue )
	if ( !self:GetNumeric() ) then return false end

	if ( !string.find( strAllowedNumericCharacters, strValue, 1, true ) ) then
		return true
	end

	return false
end

function PANEL:SetDisabled( bDisabled )
	self:SetEnabled( !bDisabled )
end

function PANEL:GetDisabled( bDisabled )
	return !self:IsEnabled()
end

function PANEL:AllowInput( strValue )
	if ( self:CheckNumeric( strValue ) ) then return true end
end

function PANEL:SetEditable( b )
	self:SetKeyboardInputEnabled( b )
	self:SetMouseInputEnabled( b )
end

function PANEL:GetEditable()
	return self:IsKeyboardInputEnabled()
end

function PANEL:OnGetFocus()
	hook.Run( "OnTextEntryGetFocus", self )
end

function PANEL:OnLoseFocus()
	self:UpdateConvarValue()

	hook.Call( "OnTextEntryLoseFocus", nil, self )
end

function PANEL:OnMousePressed( mcode )
	if ( mcode == MOUSE_LEFT ) then
		self:OnGetFocus()
	end
end

function PANEL:AddHistory( txt )
	if ( !txt || txt == "" ) then return end

	table.RemoveByValue( self.History, txt )
	table.insert( self.History, txt )

end

function PANEL:GetAutoComplete( txt )
end

function PANEL:GetInt()
	local num = tonumber( self:GetText() )
	if ( !num ) then return nil end

	return math.Round( num )
end

function PANEL:GetFloat()
	return tonumber( self:GetText() )
end

function PANEL:SetupDock(pos, left, top, right, bottom)
	self:Dock(pos)
	self:DockMargin(left or 0, top or 0, right or 0, bottom or 0)
end

function PANEL:SetupTooltip(text)
	self:SetTooltip(text)
	self:SetTooltipPanelOverride("TLib.Tooltip")
end

function PANEL:SetPlaceholder(text)
	self:SetPlaceholderText(text)
end

function PANEL:CenterText()
	self:SetContentAlignment(5)
end

function PANEL:Paint( w, h )
	x,y = 0,0

	if (!self:IsKeyboardInputEnabled()) then
		TLib.DrawOutlinedBox(nil, 0,0, w, h, TLib.Theme.red, TLib.Theme.outline)
	else 
		TLib.DrawOutlinedBox(nil, 0,0, w, h, self:IsHovered() and TLib.Theme.accentalpha or TLib.Theme.outline, TLib.Theme.panel)
	end



	if ( self:GetText() == "" and self:GetPlaceholderText() != "" ) then
		draw.SimpleText( self:GetPlaceholderText(), "TLib.Font.TextEntry", 5, h/2, TLib.Theme.text.h2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	self:DrawTextEntryText( TLib.Theme.text.h1, TLib.Theme.accentalpha, TLib.Theme.text.h1 )


	-- if ( !self:IsEnabled() ) then
	-- 	-- draw.RoundedBox( TLib.Config.cornerradius, 0, 0, w, h, TLib.Theme.outline)
	-- 	TLib.DrawOutlinedBox(nil, 0, 0, w, h, TLib.Theme.red, TLib.Theme.outline)
	-- 	-- draw.DrawText( 'Sorry, Disabled (ツ)', self:GetFont(), 10, 10, TLib.Theme.text.h1, TEXT_ALIGN_LEFT )
	-- end
end


vgui.Register( "TLib.TextEntry", PANEL, "DTextEntry" )
