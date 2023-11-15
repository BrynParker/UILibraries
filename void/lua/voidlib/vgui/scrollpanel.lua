local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self.defaultColor = VoidUI.Colors.TextGray
	self.hoverColor = VoidUI.Colors.GrayTransparent

	local this = self
	local sbar = self:GetVBar()

	sbar.Paint = function (self, w, h)
		draw.RoundedBox(24, sc(8), 0, w-sc(8), h, VoidUI.Colors.Background)
	end

	sbar.btnGrip.Paint = function (self, w, h)
		local color = self:IsHovered() and this.hoverColor or this.defaultColor
		draw.RoundedBox(24, sc(8), 0, w-sc(8), h, color)
	end

	sbar:SetHideButtons(true)
end


vgui.Register("VoidUI.ScrollPanel", PANEL, "DScrollPanel")
