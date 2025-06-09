local PANEL = {}

AccessorFunc( PANEL, "Padding", "Padding" )
AccessorFunc( PANEL, "pnlCanvas", "Canvas" )

AccessorFunc(PANEL, "tlib_drawbackground", "DrawBackground", FORCE_BOOL)

function PANEL:Init()

	self.pnlCanvas = vgui.Create( "Panel", self )
	self.pnlCanvas.OnMousePressed = function( self, code ) self:GetParent():OnMousePressed( code ) end
	self.pnlCanvas:SetMouseInputEnabled( true )
	self.pnlCanvas.PerformLayout = function( pnl )
		self:PerformLayoutInternal()
		self:InvalidateParent()
	end

	self.VBar = vgui.Create( "TLib.VScrollBar", self )
	self.VBar:Dock( RIGHT )

	self:SetPadding( 0 )
	self:SetMouseInputEnabled( true )
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackground( false )

end

function PANEL:AddItem( pnl )
	pnl:SetParent( self:GetCanvas() )
end

function PANEL:OnChildAdded( child )
	self:AddItem( child )
end

function PANEL:SizeToContents()
	self:SetSize( self.pnlCanvas:GetSize() )
end

function PANEL:GetVBar()
	return self.VBar
end

function PANEL:GetCanvas()
	return self.pnlCanvas
end

function PANEL:InnerWidth()
	return self:GetCanvas():GetWide()
end

function PANEL:Rebuild()
	self:GetCanvas():SizeToChildren( false, true )
	if ( self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall() ) then
		self:GetCanvas():SetPos( 0, ( self:GetTall() - self:GetCanvas():GetTall() ) * 0.5 )
	end
end

function PANEL:OnMouseWheeled( dlta )
	return self.VBar:OnMouseWheeled( dlta )
end

function PANEL:OnVScroll( iOffset )
	self.pnlCanvas:SetPos( 0, iOffset )
end

function PANEL:ScrollToChild( panel )

	self:InvalidateLayout( true )

	local x, y = self.pnlCanvas:GetChildPosition( panel )
	local w, h = panel:GetSize()

	y = y + h * 0.5
	y = y - self:GetTall() * 0.5

	self.VBar:AnimateTo( y, 0.5, 0, 0.5 )
end

-- Avoid an infinite loop
function PANEL:PerformLayoutInternal()
	local Tall = self.pnlCanvas:GetTall()
	local Wide = self:GetWide()
	local YPos = 0

	self:Rebuild()

	self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
	YPos = self.VBar:GetOffset()

	if ( self.VBar.Enabled ) then Wide = Wide - self.VBar:GetWide() end

	self.pnlCanvas:SetPos( 0, YPos )
	self.pnlCanvas:SetWide( Wide )

	self:Rebuild()

	if ( Tall != self.pnlCanvas:GetTall() ) then
		self.VBar:SetScroll( self.VBar:GetScroll() ) -- Make sure we are not too far down!
	end

end

function PANEL:PerformLayout()
	self:PerformLayoutInternal()
end

function PANEL:Clear()
	return self.pnlCanvas:Clear()
end

function PANEL:DrawBackground(bool)
	self.tlib_drawbackground = bool
end

function PANEL:Paint()
end

function PANEL:SetType(type, ...)
	if type == "HOLDER" then
		self:SetupDock(FILL, 10, 10,10,10)
	elseif type == "DOCK" then
		self:SetupDock(..., 8,8,8,8)
	elseif type == "ELEMENT" then
		self:SetupDock(..., 5,5,5,5)
	end
end


vgui.Register( "TLib.ScrollPanel", PANEL, "DPanel" )