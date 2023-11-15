
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self:SetDraggable(false)

	self:DockMargin(0,0,0,0)
	self:DockPadding(0,0,0,0)

	self.lblTitle:SetText("")
	
	self.font = "VoidUI.R38"

	self.title = "Frame"
	self.drawShadow = false

	self.navbar = self:Add("Panel")
	self.navbar:Dock(TOP)
	self.navbar:SSetTall(50)
	self.navbar:SetDrawOnTop(true)
	self.navbar.PaintOver = function (self, w, h)
		local x, y = self:LocalToScreen(0,0)

		BSHADOWS.BeginShadow()
			surface.SetDrawColor(VoidUI.Colors.Primary)
			surface.DrawRect(x,y,w,h)
		BSHADOWS.EndShadow(1, 1, 1, 150, 0, 0)

		draw.SimpleText(self:GetParent().title, self:GetParent().font, w/2, h/2 - sc(2), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.close = self.navbar:Add("VoidUI.Close")

end


function PANEL:PerformLayout(w, h)
	self.close:SetPos(w - sc(14) - self.close:GetWide(), sc(10))
end

function PANEL:StayOnTop()
	self.stayOnTop = true
end

function PANEL:Think()
	if (self.stayOnTop and !self:HasFocus()) then
		self:MoveToFront()
	end
end

function PANEL:SetTitle(title)
	self.title = title
end

function PANEL:SetFont(font)
	self.font = font	
end

function PANEL:Paint(w,h)
	if (self.drawShadow) then
		local x, y = self:LocalToScreen(0,0)

		BSHADOWS.BeginShadow()
			surface.SetDrawColor(VoidUI.Colors.Background)
			surface.DrawRect(x,y,w,h)
		BSHADOWS.EndShadow(1, 1, 1, 150, 0, 0)
	else
		surface.SetDrawColor(VoidUI.Colors.Background)
		surface.DrawRect(0,0,w,h)
	end
end


vgui.Register("VoidUI.Frame", PANEL, "DFrame")
