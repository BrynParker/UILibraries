local PANEL = {}

function PANEL:Init()

	self.vertices = 360
	self.offset = 0
	self.circle = esclib.draw:GenCircle(self:GetWide()*0.5, self:GetTall()*0.5, self:GetTall()*0.5-self.offset, self.vertices)
	self.clr = Color(60,60,60,200)


	self.avatar = self:Add("AvatarImage")
	local avatar = self.avatar
	avatar:SetSize(self:GetWide(), self:GetTall())
	avatar:SetPlayer(LocalPlayer(), 128)
end

function PANEL:Paint(w,h)
	esclib.draw:Circle(w*0.5,h*0.5, h*0.5, self.clr)

	esclib.draw:Mask(function()
	    draw.NoTexture()
	    surface.SetDrawColor(color_white)
	    surface.DrawPoly(self.circle)
	end,
	function()
		self.avatar:SetPaintedManually(false)
	    self.avatar:PaintManual()
	    self.avatar:SetPaintedManually(true)
	end)
end

function PANEL:SetPlayer(ply)
	self.avatar:SetPlayer(ply, 128)
end

function PANEL:RegenCircle()
	self.circle = esclib.draw:GenCircle(self:GetWide()*0.5, self:GetTall()*0.5, self:GetTall()*0.5-self.offset, self.vertices)
end

function PANEL:OnSizeChanged(w,h)
	self.avatar:SetSize(w,h)
	self:RegenCircle()
end

function PANEL:SetVertices(n)
	self.vertices = n
	self:RegenCircle()
end

derma.DefineControl( "esclib.circle_avatar", "", PANEL, "DPanel" )