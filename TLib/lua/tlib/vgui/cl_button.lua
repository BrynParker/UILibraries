local PANEL = {}

AccessorFunc( PANEL, "m_bBorder", "DrawBorder", FORCE_BOOL )
AccessorFunc(PANEL, "m_settext", "BackgroundColor")
AccessorFunc(PANEL, "m_setTall", "Tall")
AccessorFunc(PANEL, "m_placeholder", "Placeholder")
AccessorFunc(PANEL, "m_textColor", "TextColor")
AccessorFunc(PANEL, "m_placeholderColor", "PlaceholderColor")
AccessorFunc(PANEL, "m_sethovercolor", "HoverColor")

AccessorFunc(PANEL, "m_setBackgroundColor", "BackgroundColor")

AccessorFunc(PANEL, "m_setRoundness", "Roundness")

AccessorFunc(PANEL, "m_setOutline", "OutlineColor")
AccessorFunc(PANEL, "m_roundedEx", "RoundedEx")

AccessorFunc(PANEL, "rc_TopLeft", "TopLeft")
AccessorFunc(PANEL, "rc_TopRight", "TopRight")
AccessorFunc(PANEL, "rc_BottomLeft", "BottomLeft")
AccessorFunc(PANEL, "rc_BottomRight", "BottomRight")

TLib.Font("Button", 20)

function PANEL:Init()

	self:SetContentAlignment( 5 )

	self:SetTall( 40 )
	self:SetWide( 40 )
	self:SetFont( "TLib.Font.Button" )
	self:SetTextColor( TLib.Theme.text.h1 )

	self:RoundCorners( true, true, true, true )

end

function PANEL:Disabled(disabledText) 
	self:SetEnabled( false )
	self:SetText(disabledText)
end

function PANEL:RoundCorners(tl, tr, bl, br)
	self.rc_TopLeft = tl
	self.rc_TopRight = tr
	self.rc_BottomLeft = bl
	self.rc_BottomRight = br

	return self
end

function PANEL:GetRoundCorners()
	return self.rc_TopLeft, self.rc_TopRight, self.rc_BottomLeft, self.rc_BottomRight
end


function PANEL:Paint( w, h )

	if self.Hovered then 
		self.NextColor1 = self.OutlineColor or TLib.Theme.accent
		self.NextColor2 = self.BackgroundColor or TLib.Theme.accentalpha
	else
		self.NextColor1 = TLib.Theme.button.default
		self.NextColor2 = TLib.Theme.button.default
	end


	TLib.DrawOutlinedBox(nil, 0, 0, w, h, self.OutlineColor or TLib.Theme.outline, self.BackgroundColor or TLib.Theme.button.default, self:GetRoundCorners() )

	if self:IsHovered() then
		local x, y = self:LocalToScreen()
		BSHADOWS.BeginShadow()
			TLib.DrawOutlinedBox(nil, x, y, w, h, self.Color1, self.Color2, self:GetRoundCorners())
		BSHADOWS.EndShadow(1, 2, 2)
	end

	self.Color1 = lerpColor(FrameTime() * 8, self.Color1 or TLib.Theme.button.default, self.NextColor1)
	self.Color2 = lerpColor(FrameTime() * 8, self.Color2 or TLib.Theme.button.default, self.NextColor2)


	-- TLib.DrawOutlinedBox(nil, 0, 0, w, h, self.OutlineColor or TLib.Theme.outline, TLib.Theme.button.default,self:GetRoundCorners() )

	
	-- if self:IsHovered() then
	-- 	local x, y = self:LocalToScreen()
	-- 	BSHADOWS.BeginShadow()
	-- 		TLib.DrawOutlinedBox(nil, x, y, w, h, self.OutlineColor or TLib.Theme.accent, self.BackgroundColor or TLib.Theme.accentalpha, self:GetRoundCorners())
	-- 	BSHADOWS.EndShadow(1, 2, 2)
	-- end

	-- if self:IsDown() then
	-- 	local x, y = self:LocalToScreen()
	-- 	TLib.DrawOutlinedBox(nil, x, y, w, h, TLib.Theme.accent, TLib.Theme.button.outline, self:GetRoundCorners())
	-- end

	-- if !self:IsEnabled() then
	-- 	local x, y = self:LocalToScreen()
	-- 	TLib.DrawOutlinedBox(nil, 0,0, w, h, TLib.Theme.text.h2, TLib.Theme.button.default, self:GetRoundCorners())
	-- end

end

function PANEL:UpdateColours( skin )
	if (!self:IsEnabled()) then return self:SetTextColor( TLib.Theme.text.h2 ) end
	if ( self:IsDown() ) then return self:SetTextColor( TLib.Theme.accentalpha ) end
	if ( self:IsHovered() ) then return self:SetTextColor( self.OutlineColor or TLib.Theme.accent ) end

	return self:SetTextColor( TLib.Theme.text.h1 )
end

function PANEL:PerformLayout( w, h )

	if ( IsValid( self.m_Image ) ) then
		self.m_Image:SetPos( 4, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
		self:SetTextInset( self.m_Image:GetWide() + 16, 0 )
	end

	DLabel.PerformLayout( self, w, h )
end

function PANEL:SetConsoleCommand( strName, strArgs )
	self.DoClick = function( self, val )
		RunConsoleCommand( strName, strArgs )
	end
end

function PANEL:SizeToContents()
	local w, h = self:GetContentSize()
	
	self:SetSize( self:GetParent():GetWide() + 20, h + 20 )
end

function PANEL:SetupDock(pos, left, top, right, bottom)
	self:Dock(pos)
	self:DockMargin(left or 0, top or 0, right or 0, bottom or 0)
	-- self.Color = TLib.Theme.button.default
	-- self.NextColor = TLib.Theme.accent
end

function PANEL:SetupTooltip(text)
	self:SetTooltip(text)
	self:SetTooltipPanelOverride("TLib.Tooltip")
end

function PANEL:SetupButton(text, func)
	self:SetText(text)
	self:SetFont("TLib.Font.Button")
	self.DoClick = func
end

function PANEL:SetupFunction(func)
	self.DoClick = func
end

function PANEL:SetOutline(color)
	self.OutlineColor = color
end

function PANEL:SetBackgroundColor(color)
	self.BackgroundColor = color
end

function PANEL:GetBackgroundColor()
	return self.BackgroundColor
end

function PANEL:SetAccentColor(color)
	self:SetOutline(color)
	self:SetBackgroundColor(ColorAlpha(color, 33))
end

function PANEL:Text(text, font, align)
	self:SetText(text)
	self:SetFont(font or "TLib.Font.Button")
	self:SetContentAlignment(align or 5)
end

function PANEL:SetupButton(text, func,  color, font, align)
	self:SetText(text)
	self:SetFont(font or "TLib.Font.Button")
	self.DoClick = func
	self:SetContentAlignment(align or 5)
	if color then
		self:SetAccentColor(color)
	end
end



vgui.Register("TLib.Button", PANEL, "DButton")