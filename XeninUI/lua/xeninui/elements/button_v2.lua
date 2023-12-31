local PANEL = {}




AccessorFunc(PANEL, "_cStartCol", "StartColor")
AccessorFunc(PANEL, "_cEndcol", "EndColor")
AccessorFunc(PANEL, "_iRoundness", "Roundness")
AccessorFunc(PANEL, "_iOffsetX", "XOffset", FORCE_NUMBER)
AccessorFunc(PANEL, "_iOffsetY", "YOffset", FORCE_NUMBER)
AccessorFunc(PANEL, "_sIcon", "Icon")
AccessorFunc(PANEL, "_cHoverColor", "HoverColor")
AccessorFunc(PANEL, "_cSolidColor", "SolidColor")
AccessorFunc(PANEL, "_cTextColor", "TextColor")
AccessorFunc(PANEL, "_iIconSize", "IconSize", FORCE_NUMBER)


XeninUI:CreateFont("XeninUI.GradientButton.Default", 24)

function PANEL:SetSolidColor(col)
	self.SolidColorStatic = col

	self._cSolidColor = col
end

function PANEL:Init()
	self:SetText("")
	self:SetSolidColor(Color(158, 53, 210))
	self:SetStartColor(Color(158, 53, 210))
	self:SetEndColor(Color(109, 77, 213))
	self:SetFont("XeninUI.GradientButton.Default")
	self:SetRoundness(self:GetTall())
	self:SetContentAlignment(5)
	self:SetXOffset(0)
	self:SetYOffset(0)
	self:SetGradient(false)
	self:SetTextColor(color_white)

	self.ButtonAlpha = 255

	self.SetText = function(self, text)
		self._sText = text
	end
	self.GetText = function(self)
		return self._sText
	end
end

function PANEL:SizeToContentsX(padding)
	if padding == nil then padding = 0
	end
	surface.SetFont(self:GetFont())
	local tw = surface.GetTextSize(self:GetText())

	self:SetWide(tw + padding)
end

function PANEL:IsGradient()
	return self._bUniform
end

function PANEL:SetGradient(bBool)
	self._bUniform = bBool
end

function PANEL:RoundFromTallness()
	self:SetRoundness(self:GetTall())
end

function PANEL:SetContentAlignment(iInteger)
	self._iHorizontalAlignment = (iInteger - 1) % 3
	self._iVerticalAlignment = (iInteger == 5 or iInteger == 6 or iInteger == 4) and 1 or (iInteger == 1 or iInteger == 2 or iInteger == 3) and 4 or 3

	self._bTopAligned = self._iVerticalAlignment == 3
	self._bBottomAligned = self._iVerticalAlignment == 4

	self._bLeftAligned = self._iHorizontalAlignment == 0
	self._bRightAligned = self._iHorizontalAlignment == 2
end

local ShadowColor = Color(0, 0, 0, 50)
function PANEL:Paint(w, h)
	local aX, aY = self:LocalToScreen()
	local cStartColor, cEndColor, cColor = ColorAlpha(self:GetStartColor(), self.ButtonAlpha), ColorAlpha(self:GetEndColor(), self.ButtonAlpha), ColorAlpha(self:GetSolidColor(), self.ButtonAlpha)

	if self:GetRoundness() > 0 then
		XeninUI:Mask(function()
			XeninUI:DrawRoundedBox(self:GetRoundness(), 0, 0, w, h, color_white)
		end, function()
			if self:IsGradient() then
				draw.SimpleLinearGradient(aX, aY, w, h, cStartColor, cEndColor, true)
			else
				surface.SetDrawColor(cColor)
				surface.DrawRect(0, 0, w, h)
			end
		end)
	else
		if self:IsGradient() then
			draw.SimpleLinearGradient(aX, aY, w, h, cStartColor, cEndColor, true)
		else
			surface.SetDrawColor(cColor)
			surface.DrawRect(0, 0, w, h)
		end
	end

	local iconID = self:GetIcon()
	local icon = iconID and XeninUI:GetIcon(iconID) or false
	local size = 0
	if icon then
		size = self:GetIconSize() or h * 0.8
		if (icon != "Loading") then
			surface.SetMaterial(icon)

			surface.SetDrawColor(ShadowColor)
			surface.DrawTexturedRect(5 + 1, h / 2 - Size / 2 + 2, Size, Size)

			surface.SetDrawColor(iconColor or Color(235, 235, 235))
			surface.DrawTexturedRect(5, h / 2 - Size / 2 + 1, Size, Size)
		else
			XeninUI:DrawLoadingCircle(h / 2, h / 2, h - 24, XeninUI.Theme.Blue)
		end
	end
	local XOffset, YOffset = self:GetXOffset() + (self._bLeftAligned and Size or 0), self:GetYOffset()

	draw.SimpleText(self:GetText(), self:GetFont(), self._bLeftAligned and XOffset or self._bRightAligned and w + XOffset or w / 2 + XOffset, self._bTopAligned and YOffset or self._bBottomAligned and (h + YOffset) or h / 2 + YOffset, self:GetTextColor(), self._iHorizontalAlignment, self._iVerticalAlignment)
end

function PANEL:OnCursorEntered()
	if (self:GetHoverColor() and !self:IsGradient()) then
		self:LerpColor("_cSolidColor", self:GetHoverColor())
	else
		self:Lerp("ButtonAlpha", 127.5)
	end
end

function PANEL:OnCursorExited()
	if (self:GetHoverColor() and !self:IsGradient()) then
		self:LerpColor("_cSolidColor", self.SolidColorStatic)
	else
		self:Lerp("ButtonAlpha", 255)
	end
end
vgui.Register("XeninUI.ButtonV2", PANEL, "DButton")
