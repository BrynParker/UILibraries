--[[---------------------------------------------------------
	DListView_DraggerBar
-----------------------------------------------------------]]

local PANEL = {}

function PANEL:Init()

	self:SetCursor( "sizewe" )
	self:SetText("")

end

function PANEL:Paint()

	return true

end

function PANEL:OnCursorMoved()

	if ( self.Depressed ) then

		local x, y = self:GetParent():CursorPos()

		self:GetParent():ResizeColumn( x )
	end

end

-- No example for this control
function PANEL:GenerateExample( class, tabs, w, h )
end

derma.DefineControl( "TLib.DraggerBar", "", PANEL, "TLib.Button" )

--[[---------------------------------------------------------
	DListView_Column
-----------------------------------------------------------]]

local PANEL = {}

AccessorFunc( PANEL, "m_iMinWidth", "MinWidth" )
AccessorFunc( PANEL, "m_iMaxWidth", "MaxWidth" )

AccessorFunc( PANEL, "m_iTextAlign", "TextAlign" )

AccessorFunc( PANEL, "m_bFixedWidth", "FixedWidth" )
AccessorFunc( PANEL, "m_bDesc", "Descending" )
AccessorFunc( PANEL, "m_iColumnID", "ColumnID" )

Derma_Hook( PANEL, "Paint", "Paint", "ListViewColumn" )
Derma_Hook( PANEL, "ApplySchemeSettings", "Scheme", "ListViewColumn" )
Derma_Hook( PANEL, "PerformLayout", "Layout", "ListViewColumn" )

function PANEL:Init()

	self.Header = vgui.Create( "TLib.Button", self )
	self.Header.DoClick = function() self:DoClick() end
	self.Header.DoRightClick = function() self:DoRightClick() end

	self.DraggerBar = vgui.Create( "TLib.DraggerBar", self )
	self.DraggerBar.Paint = function(pnl, w, h)
		-- TLib.DrawOutlinedBox(nil, 0,0,w,h, TLib.Theme.outline, TLib.Theme.outline, true, true, false, false)
	end

	self:SetMinWidth( 20 )
	self:SetMaxWidth( 19200 )

	-- self.Header.Paint = function(pnl, w, h)
	-- 	-- TLib.DrawOutlinedBox(nil, 0,0,w,h, TLib.Theme.outline, TLib.Theme.outline, true, true, false, false)

	-- 	--- Make the Corner Rounded depending on the position
	-- 	-- if (self:GetColumnID() == 1) then
	-- 	-- 	TLib.DrawOutlinedBox(nil, 0,0,w,h, TLib.Theme.outline, TLib.Theme.outline, true, false, false, false)
	-- 	-- else
	-- 	-- 	TLib.DrawOutlinedBox(nil, 0,0,w,h, TLib.Theme.outline, TLib.Theme.outline, false,true, false, false)
	-- 	-- end

	-- end

end

function PANEL:SetFixedWidth( i )
	self:SetMinWidth( i )
	self:SetMaxWidth( i )
end

function PANEL:DoClick()
	self:GetParent():SortByColumn( self:GetColumnID(), self:GetDescending() )
	self:SetDescending( !self:GetDescending() )
end

function PANEL:DoRightClick()
end

function PANEL:SetName( strName )
	self.Header:SetText( strName )
end

function PANEL:PerformLayout()
	if ( self:GetTextAlign() ) then
		self.Header:SetContentAlignment( self:GetTextAlign() )
	end

	self.Header:SetPos( 0, 0 )
	self.Header:SetSize( self:GetWide(), self:GetParent():GetHeaderHeight() )

	self.DraggerBar:SetWide( 4 )
	self.DraggerBar:StretchToParent( nil, 0, nil, 0 )
	self.DraggerBar:AlignRight()
end

function PANEL:ResizeColumn( iSize )
	self:GetParent():OnRequestResize( self, iSize )
end

function PANEL:SetWidth( iSize )
	iSize = math.Clamp( iSize, self:GetMinWidth(), math.max( self:GetMaxWidth(), 0 ) )

	-- If the column changes size we need to lay the data out too
	if ( math.floor( iSize ) != self:GetWide() ) then
		self:GetParent():SetDirty( true )
	end

	self:SetWide( iSize )
	return iSize
end

-- function PANEL:GetColumnCount()
-- 	return self:GetParent():GetColumnCount()
-- end

derma.DefineControl( "TLib.Column", "Sortable DListView Column", PANEL, "Panel" )

--[[---------------------------------------------------------
	DListView_ColumnPlain
-----------------------------------------------------------]]

local PANEL = {}

function PANEL:DoClick()
end

--derma.DefineControl( "DListView_ColumnPlain", "Non sortable DListView Column", PANEL, "DListView_Column" )
vgui.Register( "TLib.ColumnPlain", PANEL, "DListView_Column" )