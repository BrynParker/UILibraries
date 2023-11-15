local PANEL = {}

function PANEL:Init()
	self.hoveredFactor = 20

	self.color = VoidUI.Colors.Green
	self.bgColor = VoidUI.Colors.Primary

	self.textColor = VoidUI.Colors.White
	self.text = "SELECT"
	self.font = "VoidUI.R28"
	
	self.rounding = 16
	self.thickness = 2

	self:SetText("")
	self.SetText = function (self, text)
		self.text = string.upper(text)
		surface.SetFont(self.font)
		local sizeX = surface.GetTextSize(self.text)
		if (sizeX > 180) then
			self.font = "VoidUI.R22"
		end
	end

end


function PANEL:SetColor(col, bgCol)
	self.color = col
	if (bgCol) then
		self.bgColor = bgCol
	end
end

function PANEL:SetSmaller()
	self.rounding = 16
	self.thickness = 1
	self:SetFont("VoidUI.R18")
end

function PANEL:SetMedium()
	self.rounding = 16
	self.thickness = 1
	self:SetFont("VoidUI.R22")
end

function PANEL:SetSmallerMedium()
	self.rounding = 14
	self.thickness = 1
	self:SetFont("VoidUI.R20")
end

function PANEL:SetCompact()
	self.font = "VoidUI.R18"
	self.rounding = 8
	self.thickness = 1

	self.text = string.upper(self.text)
end


function PANEL:SetSelected(bool)
	self.isSelected = bool
	self:SetEnabled(!bool)
end

function PANEL:SetTextColor(col)
	self.textColor = col
end

function PANEL:SetFont(font)
	self.font = font
end


function PANEL:Paint(w, h)
	local isHovered = self:IsHovered() or self.isSelected

	local color = self.color
	local textColor = self.textColor
	local bgColor = self.bgColor

	if (!self:IsEnabled() and !self.enableShow) then
		color = VoidUI.Colors.TextGray
		textColor = VoidUI.Colors.TextGray
		isHovered = false
		self:SetCursor("no")
	else
		self:SetCursor("hand")
	end
	
	local sizeX = surface.GetTextSize(self.text)
	local space = 5

	if (sizeX - space > w) then
		local i = 28

		while (sizeX + space > w) do
			i = i - 2
			if (i < 14) then break end
			self:SetFont("VoidUI.R"..i)
			surface.SetFont("VoidUI.R"..i)
			sizeX = surface.GetTextSize(self.text)
		end
	end

	draw.RoundedBox(self.rounding, 0, 0, w, h, color)
	draw.RoundedBox(self.rounding, self.thickness, self.thickness, w-self.thickness*2, h-self.thickness*2, isHovered and color or bgColor)

	
	draw.SimpleText(self.isSelected and (!self.selectStr and "SELECTED" or self.selectStr) or self.text, self.font, w/2, h/2-1, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("VoidUI.Button", PANEL, "DButton")
