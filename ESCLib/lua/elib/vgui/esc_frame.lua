local x = esclib.scrw
local y = esclib.scrh

local PANEL={}

AccessorFunc( PANEL, "m_bDraggable",		"Draggable",		FORCE_BOOL )
AccessorFunc( PANEL, "m_bScreenLock",		"ScreenLock",		FORCE_BOOL )
AccessorFunc( PANEL, "m_bSizable",			"Sizable",			FORCE_BOOL )

AccessorFunc( PANEL, "m_iMinWidth",			"MinWidth",			FORCE_NUMBER )
AccessorFunc( PANEL, "m_iMinHeight",		"MinHeight",		FORCE_NUMBER )

function PANEL:Init()

	self.skin = esclib.addon:GetCurrentSkin()
	self.colors = self.skin.colors 

	self:SetSize(400,400)
	self.color = self.colors.frame.bg or Color(13,13,13)
	self.roundsize = self.skin.roundsize

	self.title = "Window"
	self.titlexoffset = 5
	self.titlecolor = self.colors.frame.accent or Color(255,255,255)
	self.titlealignx = TEXT_ALIGN_LEFT
	self.titlealigny = TEXT_ALIGN_CENTER
	self.titlefont = "es_esclib_24_500"
	self.paintbg = true
	self.titlepaint = true

	self.titlecolor_def = esclib.util:TextOnBG(self.titlecolor, self.colors.default.white, self.colors.default.black)

	--CONTENT
	if not IsValid(self.content) then
		self.content = vgui.Create( "EditablePanel", self )
	end 
	self.content.Paint = function(self, w, h)
		--for override
	end

	self:PerformLayout()

	if IsValid(self.titlepanel) then self.titlepanel:Remove() end
	self.titlepanel = vgui.Create("DDragBase",self)
	self.titlepanel:SetMouseInputEnabled(false)
	self.titlepanel:SetSize(self:GetWide(), self.titlesize.height)

	--closebutton
	self.closebutton = vgui.Create("DButton",self)
	self.closebutton:SetText( "" )
	function self.closebutton.Paint(_,w,h)
		local hover = self.closebutton:IsHovered()
		local color = hover and (self.colors.default.red) or self.titlecolor_def
		draw.SimpleText("r",
			"Marlett",
			w*0.5,
			h*0.5,
			color, 
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end
	function self.closebutton.DoClick() self:Close() end

	self:SetDraggable( true )
	self:SetSizable( false )
	self:SetMinWidth( 100 )
	self:SetMinHeight( 50 )
	self:SetScreenLock( false )
end

function PANEL:EnableCloseButton(bool)
	self.closebutton:SetVisible(bool)
end

-- USER INPUT
function PANEL:SetTitle(title,color,font,alignx,aligny)
	if color then
		if IsColor(color) then self.titletextcolor = color end
	end
	if font then
		self.titlefont = font
	end
	if alignx then
		self.titlealignx = alignx
	end
	if aligny then
		self.titlealigny = aligny
	end
	if title then
		self.title = title
	end
	self:PerformLayout()
end

function PANEL:SetIcon(icon)
	self.icon = icon
	self.titlexoffset = self.titlepanel:GetTall()+6
end

function PANEL:GetTitle() return self.title end

function PANEL:SetBackgroundColor(col) 
	if IsColor(col) then self.color = col end 
end

function PANEL:GetColor() return self.color end


function PANEL:SetTitleColor(col)
	if IsColor(col) then self.titlecolor = col end
end

function PANEL:GetTitleColor() return self.titlecolor end

function PANEL:GetContent() return self.content end
function PANEL:GetTitlePanel() return self.titlepanel end

function PANEL:SetRoundSize(size)
	self.roundsize = size
	self:PerformLayout()
end

function PANEL:Close(callback)
	self:OnClose(callback)
end

function PANEL:OnClose(callback)
	--
end

function PANEL:PerformLayout()
	surface.SetFont(self.titlefont)
	local wide, height = surface.GetTextSize(self.title)

	self.titlesize = {
		wide = wide+2,
		height = height+10
	}

	self.content:SetSize(self:GetWide(),self:GetTall()-self.titlesize.height)
	self.content:SetPos(0,self.titlesize.height)
	if IsValid(self.titlepanel) then
		self.titlecolor_def = esclib.util:TextOnBG(self.titlecolor, self.colors.default.black, self.colors.default.white)
		self.titlepanel:SetSize(self:GetWide(), self.titlesize.height)

		self.closebutton:SetSize(30,self.titlepanel:GetTall())
		local ost = self:GetWide()-self.closebutton:GetWide()
		self.closebutton:SetPos(ost,0)
	end

	self:DockPadding(0, self.titlesize.height, 0, 0)
end



--MOUSE DRAGGING
function PANEL:OnMousePressed()
	self:OnPress()
	local screenX, screenY = self:LocalToScreen( 0, 0 )
	if ( self.m_bSizable && gui.MouseX() > ( screenX + self:GetWide() - 20 ) && gui.MouseY() > ( screenY + self:GetTall() - 20 ) ) then
		self.Sizing = { gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall() }
		self:MouseCapture( true )
		return
	end

	if ( self:GetDraggable() && gui.MouseY() < ( screenY + 24 ) ) then
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
		self:MouseCapture( true )
		self:OnStartDragging(self:GetX(),self:GetY())
		return
	end
end

function PANEL:OnMouseReleased()
	self:OnUnpress()
	if self.Dragging then
		self.Dragging = nil
		self:OnEndDragging(self:GetX(),self:GetY())
	end
	if self.Sizing then
		self.Sizing = nil
		self:InvalidateChildren(true)
	end
	self:MouseCapture( false )
end

function PANEL:OnDragging(newx,newy)
	--for override
end

function PANEL:OnStartDragging(x,y)
	--for override
end

function PANEL:OnEndDragging(newx,newy)
	--for override
end

function PANEL:OnPress()
	--for override
end

function PANEL:OnUnpress()
	--for override
end

function PANEL:Think()

	local mousex = math.Clamp( gui.MouseX(), 1, esclib.scrw - 1 )
	local mousey = math.Clamp( gui.MouseY(), 1, esclib.scrh - 1 )

	if ( self.Dragging ) then

		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]

		-- Lock to screen bounds if screenlock is enabled
		if ( self:GetScreenLock() ) then

			x = math.Clamp( x, 0, esclib.scrw - self:GetWide() )
			y = math.Clamp( y, 0, esclib.scrh - self:GetTall() )

		end

		self:OnDragging(newx,newy)
		self:SetPos( x, y )

	end

	if ( self.Sizing ) then

		local x = mousex - self.Sizing[1]
		local y = mousey - self.Sizing[2]
		local px, py = self:GetPos()

		if ( x < self.m_iMinWidth ) then x = self.m_iMinWidth elseif ( x > esclib.scrw - px && self:GetScreenLock() ) then x = esclib.scrw - px end
		if ( y < self.m_iMinHeight ) then y = self.m_iMinHeight elseif ( y > esclib.scrh - py && self:GetScreenLock() ) then y = esclib.scrh - py end

		self:SetSize( x, y )
		return

	end

	local screenX, screenY = self:LocalToScreen( 0, 0 )
	if ( self.Hovered && self.m_bSizable && mousex > ( screenX + self:GetWide() - 20 ) && mousey > ( screenY + self:GetTall() - 20 ) ) then
		self:SetCursor( "sizenwse" )
		return
	end

	if ( self.Hovered && self:GetDraggable() && mousey < ( screenY + 24 ) ) then
		self:SetCursor( "sizeall" )
		return
	end

	self:SetCursor( "arrow" )

	if ( self.y < 0 ) then
		self:SetPos( self.x, 0 )
	end

end

function PANEL:PaintTitle(w,h)
	if not self.titlepaint then return end
	--Title bg
	draw.RoundedBoxEx(self.roundsize,0,0,w,self.titlesize.height, self.titlecolor, true,true,false,false)

	if self.icon then
		esclib.draw:MaterialCentered(h*0.35+10,h*0.5,h*0.35,self.titlecolor_def,self.icon)
	end

	draw.SimpleText(self.title,
		self.titlefont,
		(self.titlealignx == TEXT_ALIGN_CENTER) and (w*0.5) or self.titlexoffset+5,
		(self.titlealigny == TEXT_ALIGN_CENTER) and (self.titlesize.height*0.5) or 0,
		self.titlecolor_def,
		self.titlealignx,
		self.titlealigny)
end

--BACKGROUND
function PANEL:PaintBG(w,h)
	if not self.titlepanel then return end
	local sizey = self.titlepanel:GetTall()
	draw.RoundedBoxEx(self.roundsize,0,sizey,w,h-sizey,self.color,false,false,true,true)
end

function PANEL:Paint(w,h)
	--background
	if self.PaintBG then self:PaintBG(w,h) end
	function self.titlepanel.Paint(_,w,h) 
		self:PaintTitle(w,h) 
	end 

	local posx,posy = self:GetPos()
	local mx,my = input.GetCursorPos()
	if (mx >= posx) and (mx <= posx+w) then
		if (my >= posy) and (my <= posy+h) then
			self.Hovered = true
		else
			self.Hovered = false
		end
	else
		self.Hovered = false
	end

 	
	return true
end

vgui.Register( "esclib.frame", PANEL );