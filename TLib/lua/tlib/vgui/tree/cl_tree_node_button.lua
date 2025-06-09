
local PANEL = {}

TLib.Font( "Tree_node", 16)

function PANEL:Init()

	self:SetTextInset( 32, 0 )
	self:SetContentAlignment( 4 )
    self:SetFont( "TLib.Font.Tree_node" )

end

function PANEL:Paint( w, h )
    if (self:IsHovered()) then
        draw.RoundedBox(0, 0, 0, w, h, TLib.Theme.accentalpha)
    end
end

function PANEL:UpdateColours( skin )

	if ( self:IsSelected() ) then return self:SetTextStyleColor( TLib.Theme.accentalpha ) end
	if ( self.Hovered ) then return self:SetTextStyleColor( TLib.Theme.accent ) end

	return self:SetTextStyleColor( TLib.Theme.text.h1 )

end

function PANEL:GenerateExample()

	-- Do nothing!

end

derma.DefineControl( "TLib.Tree_Node_Button", "Tree Node Button", PANEL, "TLib.Button" )