local PANEL = {}

AccessorFunc( PANEL, "m_HideButtons", "HideButtons" )

function PANEL:Init()

	self.Offset = 0
	self.Scroll = 0
	self.CanvasSize = 1
	self.BarSize = 1

	self.btnUp = vgui.Create( "DButton", self )
	self.btnUp:SetText( "" )
	self.btnUp.DoClick = function( s ) s:GetParent():AddScroll( -1 ) end
	self.btnUp.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "ButtonUp", panel, w, h ) end

	self.btnDown = vgui.Create( "DButton", self )
	self.btnDown:SetText( "" )
	self.btnDown.DoClick = function( s ) s:GetParent():AddScroll( 1 ) end
	self.btnDown.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "ButtonDown", panel, w, h ) end

	self.btnGrip = vgui.Create( "DScrollBarGrip", self )

	self:SetSize( 6, 15 )
	self:SetHideButtons( true )

	self.btnGrip.Paint = function(panel, w,h)
		draw.RoundedBox(TLib.Config.cornerradius, 0, 0, w, h, TLib.Theme.accentalpha)
	end

end

function PANEL:SetEnabled( b )

	if ( !b ) then

		self.Offset = 0
		self:SetScroll( 0 )
		self.HasChanged = true

	end

	self:SetMouseInputEnabled( b )
	self:SetVisible( b )

	-- We're probably changing the width of something in our parent
	-- by appearing or hiding, so tell them to re-do their layout.
	if ( self.Enabled != b ) then

		self:GetParent():InvalidateLayout()

		if ( self:GetParent().OnScrollbarAppear ) then
			self:GetParent():OnScrollbarAppear()
		end

	end

	self.Enabled = b

end

function PANEL:BarScale()

	if ( self.BarSize == 0 ) then return 1 end

	return self.BarSize / ( self.CanvasSize + self.BarSize )

end

function PANEL:SetUp( _barsize_, _canvassize_ )

	self.BarSize = _barsize_
	self.CanvasSize = math.max( _canvassize_ - _barsize_, 1 )

	self:SetEnabled( _canvassize_ > _barsize_ )

	self:InvalidateLayout()

end

function PANEL:OnMouseWheeled( dlta )

	if ( !self:IsVisible() ) then return false end

	-- We return true if the scrollbar changed.
	-- If it didn't, we feed the mousehweeling to the parent panel

	return self:AddScroll( dlta * -2 )

end

function PANEL:AddScroll( dlta )

	local OldScroll = self:GetScroll()

	dlta = dlta * 25
	self:SetScroll( self:GetScroll() + dlta )

	return OldScroll != self:GetScroll()

end

function PANEL:SetScroll( scrll )

	if ( !self.Enabled ) then self.Scroll = 0 return end

	self.Scroll = math.Clamp( scrll, 0, self.CanvasSize )

	self:InvalidateLayout()

	-- If our parent has a OnVScroll function use that, if
	-- not then invalidate layout (which can be pretty slow)

	local func = self:GetParent().OnVScroll
	if ( func ) then

		func( self:GetParent(), self:GetOffset() )

	else

		self:GetParent():InvalidateLayout()

	end

end

function PANEL:AnimateTo( scrll, length, delay, ease )

	local anim = self:NewAnimation( length, delay, ease )
	anim.StartPos = self.Scroll
	anim.TargetPos = scrll
	anim.Think = function( anm, pnl, fraction )

		pnl:SetScroll( Lerp( fraction, anm.StartPos, anm.TargetPos ) )

	end

end

function PANEL:GetScroll()

	if ( !self.Enabled ) then self.Scroll = 0 end
	return self.Scroll

end

function PANEL:GetOffset()

	if ( !self.Enabled ) then return 0 end
	return self.Scroll * -1

end

function PANEL:Think()
end

function PANEL:Paint( w, h )

	draw.RoundedBox(TLib.Config.cornerradius, 0, 0, w, h, Color( 0, 0, 0, 33 ))

end

function PANEL:OnMousePressed()

	local x, y = self:CursorPos()

	local PageSize = self.BarSize

	if ( y > self.btnGrip.y ) then
		self:SetScroll( self:GetScroll() + PageSize )
	else
		self:SetScroll( self:GetScroll() - PageSize )
	end

end

function PANEL:OnMouseReleased()

	self.Dragging = false
	self.DraggingCanvas = nil
	self:MouseCapture( false )

	self.btnGrip.Depressed = false

end

function PANEL:OnCursorMoved( lx, ly )

	if ( !self.Enabled ) then return end
	if ( !self.Dragging ) then return end

	local x, y = self:ScreenToLocal( 0, gui.MouseY() )

	-- Uck.
	y = y - self.btnUp:GetTall()
	y = y - self.HoldPos

	local BtnHeight = self:GetWide()
	if ( self:GetHideButtons() ) then BtnHeight = 0 end

	local TrackSize = self:GetTall() - BtnHeight * 2 - self.btnGrip:GetTall()

	y = y / TrackSize

	self:SetScroll( y * self.CanvasSize )

end

function PANEL:Grip()

	if ( !self.Enabled ) then return end
	if ( self.BarSize == 0 ) then return end

	self:MouseCapture( true )
	self.Dragging = true

	local x, y = self.btnGrip:ScreenToLocal( 0, gui.MouseY() )
	self.HoldPos = y

	self.btnGrip.Depressed = true

end

function PANEL:PerformLayout()

	local Wide = self:GetWide()
	local BtnHeight = Wide
	if ( self:GetHideButtons() ) then BtnHeight = 0 end
	local Scroll = self:GetScroll() / self.CanvasSize
	local BarSize = math.max( self:BarScale() * ( self:GetTall() - ( BtnHeight * 2 ) ), 10 )
	local Track = self:GetTall() - ( BtnHeight * 2 ) - BarSize
	Track = Track + 1

	Scroll = Scroll * Track

	self.btnGrip:SetPos( 0, BtnHeight + Scroll )
	self.btnGrip:SetSize( Wide, BarSize )

	if ( BtnHeight > 0 ) then
		self.btnUp:SetPos( 0, 0, Wide, Wide )
		self.btnUp:SetSize( Wide, BtnHeight )

		self.btnDown:SetPos( 0, self:GetTall() - BtnHeight )
		self.btnDown:SetSize( Wide, BtnHeight )

		self.btnUp:SetVisible( true )
		self.btnDown:SetVisible( true )
	else
		self.btnUp:SetVisible( false )
		self.btnDown:SetVisible( false )
		self.btnDown:SetSize( Wide, BtnHeight )
		self.btnUp:SetSize( Wide, BtnHeight )
	end

end

derma.DefineControl( "TLib.VScrollBar", "A Scrollbar", PANEL, "Panel" )