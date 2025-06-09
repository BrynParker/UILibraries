
local PANEL = {}

AccessorFunc( PANEL, "m_bBorder",			"DrawBorder" )
AccessorFunc( PANEL, "m_bDeleteSelf",		"DeleteSelf" )
AccessorFunc( PANEL, "m_iMinimumWidth",		"MinimumWidth" )
AccessorFunc( PANEL, "m_bDrawColumn",		"DrawColumn" )
AccessorFunc( PANEL, "m_iMaxHeight",		"MaxHeight" )

AccessorFunc( PANEL, "m_pOpenSubMenu",		"OpenSubMenu" )

TLib.Font("Context_label", 17)

function PANEL:Init()

	self:SetIsMenu( true )
	self:SetDrawBorder( true )
	self:SetPaintBackground( true )
	self:SetMinimumWidth( 100 )
	self:SetDrawOnTop( true )
	self:SetMaxHeight( ScrH() * 0.9 )
	self:SetDeleteSelf( true )

	self:SetPadding( 0 )

	-- Automatically remove this panel when menus are to be closed
	RegisterDermaMenuForClose( self )

end

function PANEL:AddPanel( pnl )

	self:AddItem( pnl )
	pnl.ParentMenu = self

end

function PANEL:AddOption( strText, funcFunction )

	local pnl = vgui.Create( "TLib.ContextOption", self )
	pnl:SetMenu( self )
	pnl:SetText( strText )
    pnl:Dock( TOP )
    pnl:DockMargin( 0, 0, 0, 0)
    pnl:SetTall( 70 )

    if ( funcFunction ) then pnl.DoClick = funcFunction end

	self:AddPanel( pnl )

	return pnl

end

function PANEL:AddSpacer( strText, funcFunction )

	local pnl = vgui.Create( "DPanel", self )
    pnl:Dock( TOP )
    pnl:DockMargin( 5, 5, 5, 5 )
	pnl.Paint = function( p, w, h )
        surface.SetDrawColor( TLib.Theme.accent)
        surface.DrawRect( 0, 0, w, h )
    end

	pnl:SetTall( 1 )
	self:AddPanel( pnl )

	return pnl

end

function PANEL:AddLabel( strText, funcFunction )

    local pnl = vgui.Create( "TLib.Label", self )
    pnl:SetText( strText )
    pnl:SetTextInset( 5, 0 )
    pnl:SetFont( "TLib.Font.Context_label" )
    pnl:Dock( TOP )
    pnl:DockMargin( 5, 5, 5, 5 )

    self:AddPanel( pnl )

    return pnl

end

function PANEL:AddSubMenu( strText, funcFunction )

	local pnl = vgui.Create( "DMenuOption", self )
	local SubMenu = pnl:AddSubMenu( strText, funcFunction )

	pnl:SetText( strText )
	if ( funcFunction ) then pnl.DoClick = funcFunction end

	self:AddPanel( pnl )

	return SubMenu, pnl

end

function PANEL:Hide()

	local openmenu = self:GetOpenSubMenu()
	if ( openmenu ) then
		openmenu:Hide()
	end

	self:SetVisible( false )
	self:SetOpenSubMenu( nil )

end

function PANEL:OpenSubMenu( item, menu )

	-- Do we already have a menu open?
	local openmenu = self:GetOpenSubMenu()
	if ( IsValid( openmenu ) && openmenu:IsVisible() ) then

		-- Don't open it again!
		if ( menu && openmenu == menu ) then return end

		-- Close it!
		self:CloseSubMenu( openmenu )

	end

	if ( !IsValid( menu ) ) then return end

	local x, y = item:LocalToScreen( self:GetWide(), 0 )
	menu:Open( x - 3, y, false, item )

	self:SetOpenSubMenu( menu )

end

function PANEL:CloseSubMenu( menu )

	menu:Hide()
	self:SetOpenSubMenu( nil )

end

function PANEL:Paint( w, h )
	local x, y = self:LocalToScreen()
    BSHADOWS.BeginShadow()
    TLib.DrawOutlinedBox(nil, x, y, w, h, TLib.Theme.accent, TLib.Theme.background)
    BSHADOWS.EndShadow(1, 2, 2)
end

function PANEL:ChildCount()
	return #self:GetCanvas():GetChildren()
end

function PANEL:GetChild( num )
	return self:GetCanvas():GetChildren()[ num ]
end

function PANEL:PerformLayout( w, h )

	local w = self:GetMinimumWidth()

	-- Find the widest one
	for k, pnl in ipairs( self:GetCanvas():GetChildren() ) do

		pnl:InvalidateLayout( true )
		w = math.max( w, pnl:GetWide() )

	end

	self:SetWide( w )

	local y = 0 -- for padding

	for k, pnl in ipairs( self:GetCanvas():GetChildren() ) do

		pnl:SetWide( w )
		pnl:SetPos( 0, y )
		pnl:InvalidateLayout( true )

		y = y + pnl:GetTall()

	end

	y = math.min( y, self:GetMaxHeight() )

	self:SetTall( y + 30)

	-- derma.SkinHook( "Layout", "Menu", self )

	DScrollPanel.PerformLayout( self, w, h )
end

--[[---------------------------------------------------------
	Open - Opens the menu.
	x and y are optional, if they're not provided the menu
		will appear at the cursor.
-----------------------------------------------------------]]
function PANEL:Open( x, y, skipanimation, ownerpanel )

	RegisterDermaMenuForClose( self )

	local maunal = x && y

	x = x or gui.MouseX()
	y = y or gui.MouseY()

	local OwnerHeight = 0
	local OwnerWidth = 0

	if ( ownerpanel ) then
		OwnerWidth, OwnerHeight = ownerpanel:GetSize()
	end

	self:InvalidateLayout( true )

	local w = self:GetWide()
	local h = self:GetTall()

	self:SetSize( w + 30, h + 40 )

	if ( y + h > ScrH() ) then y = ( ( maunal && ScrH() ) or ( y + OwnerHeight ) ) - h end
	if ( x + w > ScrW() ) then x = ( ( maunal && ScrW() ) or x ) - w end
	if ( y < 1 ) then y = 1 end
	if ( x < 1 ) then x = 1 end

	local p = self:GetParent()
	if ( IsValid( p ) && p:IsModal() ) then
		-- Can't popup while we are parented to a modal panel
		-- We will end up behind the modal panel in that case

		x, y = p:ScreenToLocal( x, y )

		-- We have to reclamp the values
		if ( y + h > p:GetTall() ) then y = p:GetTall() - h end
		if ( x + w > p:GetWide() ) then x = p:GetWide() - w end
		if ( y < 1 ) then y = 1 end
		if ( x < 1 ) then x = 1 end

		self:SetPos( x, y )
	else
		self:SetPos( x, y )

		-- Popup!
		self:MakePopup()
	end

	-- Make sure it's visible!
	self:SetVisible( true )

	-- Keep the mouse active while the menu is visible.
	self:SetKeyboardInputEnabled( false )

    self:GetChild(1):DockMargin(0,5,0,0)

end

--
-- Called by DMenuOption
--
function PANEL:OptionSelectedInternal( option )

	self:OptionSelected( option, option:GetText() )

end

function PANEL:OptionSelected( option, text )

	-- For override

end

function PANEL:ClearHighlights()

	for k, pnl in ipairs( self:GetCanvas():GetChildren() ) do
		pnl.Highlight = nil
	end

end

function PANEL:HighlightItem( item )

	for k, pnl in ipairs( self:GetCanvas():GetChildren() ) do
		if ( pnl == item ) then
			pnl.Highlight = true
		end
	end

end

function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local MenuItemSelected = function()
		Derma_Message( "Choosing a menu item worked!" )
	end

	local ctrl = vgui.Create( "Button" )
	ctrl:SetText( "Test Me!" )
	ctrl.DoClick = function()
		local menu = DermaMenu()

		menu:AddOption( "Option One", MenuItemSelected )
		menu:AddOption( "Option 2", MenuItemSelected )

		local submenu = menu:AddSubMenu( "Option Free" )
		submenu:AddOption( "Submenu 1", MenuItemSelected )
		submenu:AddOption( "Submenu 2", MenuItemSelected )

		menu:AddOption( "Option For", MenuItemSelected )

		menu:Open()
	end

	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

-- derma.DefineControl( "TLib.ContextMenu", "A Menu", PANEL, "TLib.ScrollPanel" )
vgui.Register( "TLib.ContextMenu", PANEL, "DScrollPanel" )

function TLib.ContextMenu( parent )

    local menu = vgui.Create( "TLib.ContextMenu", parent )
    menu:SetVisible( false )
    menu:SetZPos( 1000 )

    return menu

end