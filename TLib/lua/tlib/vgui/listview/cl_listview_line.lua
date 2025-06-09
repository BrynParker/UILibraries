local PANEL = {}

function PANEL:Init()

	self:SetTextInset( 10, 0 )
	self:SetContentAlignment( 5 )

end

TLib.Font( "ListView_lbl", 18)

function PANEL:UpdateColours( skin )

	if ( self:GetParent():IsLineSelected() ) then return self:SetTextStyleColor( color_black ) end

	return self:SetTextStyleColor( color_black )

end

function PANEL:GenerateExample()

	-- Do nothing!

end

derma.DefineControl( "TLib.ListViewLabel", "", PANEL, "DLabel" )

--[[---------------------------------------------------------
	DListView_Line
-----------------------------------------------------------]]

local PANEL = {}

-- Derma_Hook( PANEL, "Paint", "Paint", "ListViewLine" )
Derma_Hook( PANEL, "ApplySchemeSettings", "Scheme", "ListViewLine" )
Derma_Hook( PANEL, "PerformLayout", "Layout", "ListViewLine" )

AccessorFunc( PANEL, "m_iID", "ID" )
AccessorFunc( PANEL, "m_pListView", "ListView" )
AccessorFunc( PANEL, "m_bAlt", "AltLine" )

function PANEL:Init()

	self:SetSelectable( true )
	self:SetMouseInputEnabled( true )
	self:SetContentAlignment( 5 )

	self.Columns = {}
	self.Data = {}

end

function PANEL:OnSelect()

	-- For override

end

function PANEL:OnRightClick()

	-- For override

end

function PANEL:OnMousePressed( mcode )

	if ( mcode == MOUSE_RIGHT ) then

		-- This is probably the expected behaviour..
		if ( !self:IsLineSelected() ) then

			self:GetListView():OnClickLine( self, true )
			self:OnSelect()

		end

		self:GetListView():OnRowRightClick( self:GetID(), self )
		self:OnRightClick()

		return

	end

	self:GetListView():OnClickLine( self, true )
	self:OnSelect()

end

function PANEL:OnCursorMoved()

	if ( input.IsMouseDown( MOUSE_LEFT ) ) then
		self:GetListView():OnClickLine( self )
	end

end

function PANEL:SetSelected( b )

	self.m_bSelected = b

	-- Update colors of the lines
	for id, column in pairs( self.Columns ) do
		column:ApplySchemeSettings()
	end

end

function PANEL:IsLineSelected()

	return self.m_bSelected

end

function PANEL:SetColumnText( i, strText )

	if ( type( strText ) == "Panel" ) then

		if ( IsValid( self.Columns[ i ] ) ) then self.Columns[ i ]:Remove() end

		strText:SetParent( self )
		self.Columns[ i ] = strText
		self.Columns[ i ].Value = strText
		return

	end

	if ( !IsValid( self.Columns[ i ] ) ) then

		self.Columns[ i ] = vgui.Create( "TLib.Label", self )
		self.Columns[ i ]:SetFont("TLib.Font.ListView_lbl")
		self.Columns[ i ]:SetMouseInputEnabled( false )
		self.Columns[ i ]:SetContentAlignment(5)
		self.Columns[ i ]:SetTextInset( 10, - 5 )

	end

	self.Columns[ i ]:SetText( tostring( strText ) )
	self.Columns[ i ].Value = strText
	return self.Columns[ i ]

end
PANEL.SetValue = PANEL.SetColumnText

function PANEL:GetColumnText( i )

	if ( !self.Columns[ i ] ) then return "" end

	return self.Columns[ i ].Value

end

PANEL.GetValue = PANEL.GetColumnText

--[[---------------------------------------------------------
	Allows you to store data per column
	Used in the SortByColumn function for incase you want to
	sort with something else than the text
-----------------------------------------------------------]]
function PANEL:SetSortValue( i, data )

	self.Data[ i ] = data

end

function PANEL:GetSortValue( i )

	return self.Data[ i ]

end

function PANEL:DataLayout( ListView )

	self:ApplySchemeSettings()

	local height = self:GetTall()

	local x = 0
	for k, Column in pairs( self.Columns ) do

		local w = ListView:ColumnWidth( k )
		Column:SetPos( x, 5 )
		Column:SetSize( w, height )
		x = x + w

	end

end

function PANEL:Paint(w,h)

	TLib.DrawOutlinedBox(nil, 0, 0, w,h, TLib.Theme.outline, self:IsHovered() and TLib.Theme.accentalpha or TLib.Theme.panel)

 	if ( self:IsLineSelected( self ) ) then
		TLib.DrawOutlinedBox(nil, 0, 0, w,h, TLib.Theme.accent, TLib.Theme.outline)
	end
	
end

vgui.Register( "TLib.ListView_Line", PANEL, "Panel" )