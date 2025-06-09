local PANEL = {}

AccessorFunc( PANEL, "m_bBackground",		"PaintBackground",	FORCE_BOOL )
AccessorFunc( PANEL, "m_bBackground",		"DrawBackground",	FORCE_BOOL ) -- deprecated
AccessorFunc( PANEL, "m_bIsMenuComponent",	"IsMenu",			FORCE_BOOL )

-- Derma_Hook( PANEL, "Paint", "Paint", "MenuBar" )

function PANEL:Init()

	self:Dock( TOP )
	self:SetTall( 35 )

	self.Menus = {}

end

function PANEL:GetOpenMenu()

	for k, v in pairs( self.Menus ) do
		if ( v:IsVisible() ) then return v end
	end

	return nil

end

function PANEL:AddOrGetMenu( label )

	if ( self.Menus[ label ] ) then return self.Menus[ label ] end
	return self:AddMenu( label )

end

function PANEL:AddMenu( label )

	local m = TLib.ContextMenu()
	m:SetDeleteSelf( false )
	m:SetDrawColumn( true )
	m:Hide()
	self.Menus[ label ] = m

	local b = self:Add( "TLib.Button" )
	b:SetText( label )
	b:Dock( LEFT )
	b:DockMargin( 5, 5, 5, 5 )
	b:SetIsMenu( true )
	b:SetPaintBackground( false )
	b:SizeToContentsX( 20 )
	b.DoClick = function()

		if ( m:IsVisible() ) then
			m:Hide()
			return
		end

		local x, y = b:LocalToScreen( 0, 0 )
		m:Open( x, y + b:GetTall(), false, b )
	end

	b.OnCursorEntered = function()
		local opened = self:GetOpenMenu()
		if ( !IsValid( opened ) || opened == m ) then return end
		opened:Hide()
		b:DoClick()
	end

	return m

end

function PANEL:OnRemove()
	for id, pnl in pairs( self.Menus ) do
		pnl:Remove()
	end
end

function PANEL:Paint( w, h )
	TLib.DrawOutlinedBox(nil, 0, 0, w, h, TLib.Theme.outline, TLib.Theme.outline, true, true, false, false )
end

vgui.Register( "TLib.MenuBar", PANEL, "TLib.Panel" )