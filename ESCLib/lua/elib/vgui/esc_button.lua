local PANEL = {}


AccessorFunc( PANEL, "m_nBorderRadius", "BorderRadius", FORCE_NUMBER )

AccessorFunc( PANEL, "m_sButtonText", "ButtonText", FORCE_STRING )

AccessorFunc( PANEL, "m_cTextAlignX", "TextAlignX", FORCE_NUMBER )
AccessorFunc( PANEL, "m_cTextAlignY", "TextAlignY", FORCE_NUMBER )

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetEnabled(true)

	self.skin = esclib.addon:GetCurrentSkin()
	self.colors = self.skin.colors
	self.maskcol = Color(13,13,13,220)

	self:SetTextAlignX(TEXT_ALIGN_CENTER)
	self:SetTextAlignY(TEXT_ALIGN_CENTER)

	self:SetText("")

	self:SetBorderRadius(0)
	self:SetButtonText("SetButtonText")

	self:SetCursor( "hand" )
	self:SetFont( "es_esclib_24_500" )
end

function PANEL:IsDown()
	return self.Depressed
end

function PANEL:Paint( w, h )
	self:SetCursor( "hand" )
	local active = self:IsEnabled()
	local hovered = self:IsHovered() and active 
	draw.RoundedBox(self:GetBorderRadius(),1,1,w-2,h-2,hovered and self.colors.button.hover or self.colors.button.main)
	local tax = self:GetTextAlignX()
	if tax == TEXT_ALIGN_LEFT then
		draw.SimpleText(self.m_sButtonText,self:GetFont(),15,h*0.5,hovered and self.colors.button.text_hover or self.colors.button.text, tax, self.m_cTextAlignY)
	elseif tax == TEXT_ALIGN_RIGHT then
		draw.SimpleText(self.m_sButtonText,self:GetFont(),w-15,h*0.5,hovered and self.colors.button.text_hover or self.colors.button.text, tax, self.m_cTextAlignY)
	else 
		draw.SimpleText(self.m_sButtonText,self:GetFont(),w*0.5,h*0.5,hovered and self.colors.button.text_hover or self.colors.button.text, tax, self.m_cTextAlignY)
	end 

	if not active then 
		self:SetCursor( "no" )
		draw.RoundedBox(self.m_nBorderRadius,0,0,w,h,self.maskcol)
	end
end

derma.DefineControl( "esclib.button", "A button for esclib", PANEL, "DLabel" )
