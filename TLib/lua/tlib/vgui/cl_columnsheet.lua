local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

function PANEL:Init()

	self.Navigation = vgui.Create( "DScrollPanel", self )
	self.Navigation:Dock( LEFT )
	self.Navigation:SetWidth( 150 )
	self.Navigation:DockMargin( 10, 5, 10, 0 )

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}

end

function PANEL:UseButtonOnlyStyle()
	self.ButtonOnly = true
end

function PANEL:AddSheet( label, panel, material, color)

	if ( !IsValid( panel ) ) then return end

	local Sheet = {}


	Sheet.Button = vgui.Create( "TLib.Button", self.Navigation )
	Sheet.Button.Target = panel
	Sheet.Button:SetSize(325, 32)
	Sheet.Button:Dock( TOP )
	Sheet.Button:SetText( label )
	Sheet.Button:DockMargin( 0, 5, 0, 0 )
	Sheet.Button:SetOutline(outline or TLib.Theme.outline)
	
	Sheet.Button.OnCursorEntered = function(me)
		me.hovered = true
	end
	
	Sheet.Button.OnCursorExited = function(me)
		me.hovered = false
	end
	
	Sheet.Button.DoClick = function()
		self:SetActiveButton( Sheet.Button )
	end

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetVisible( false )
	
	if ( self.ButtonOnly ) then
		Sheet.Button:SizeToContents()
	end
	
	table.insert( self.Items, Sheet )

	if ( !IsValid( self.ActiveButton ) ) then
		self:SetActiveButton( Sheet.Button )
	end
end

function PANEL:SetActiveButton( active )

	if ( self.ActiveButton == active ) then return end

	if ( self.ActiveButton && self.ActiveButton.Target ) then
		self.ActiveButton.Target:SetVisible( false )
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
	active:SetSelected( true )
	active:SetToggle( true )
	active:SetOutline(TLib.Theme.accent)
	active.active = true

	self.Content:InvalidateLayout()
end


function PANEL:SetupDock(pos, left, top, right, bottom)
	self:Dock(pos)
	self:DockMargin(left or 0, top or 0, right or 0, bottom or 0)
end

function PANEL:SetupTooltip(text)
	self:SetTooltip(text)
	self:SetTooltipPanelOverride("TLib.Tooltip")
end

vgui.Register("TLib.ColumnSheet", PANEL, "Panel" )

