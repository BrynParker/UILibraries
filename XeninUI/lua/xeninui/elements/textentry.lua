XeninUI:CreateFont("XeninUI.TextEntry", 18)

local PANEL = {}

AccessorFunc(PANEL, "m_backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "m_rounded", "Rounded")
AccessorFunc(PANEL, "m_placeholder", "Placeholder")
AccessorFunc(PANEL, "m_textColor", "TextColor")
AccessorFunc(PANEL, "m_placeholderColor", "PlaceholderColor")
AccessorFunc(PANEL, "m_iconColor", "IconColor")

function PANEL:Init()
	self:SetBackgroundColor(XeninUI.Theme.Navbar)
	self:SetRounded(6)
	self:SetPlaceholder("")
	self:SetTextColor(Color(205, 205, 205))
	self:SetPlaceholderColor(Color(120, 120, 120))
	self:SetIconColor(self:GetTextColor())

	self.textentry = vgui.Create("DTextEntry", self)
	self.textentry:Dock(FILL)
	self.textentry:DockMargin(8, 8, 8, 8)
	self.textentry:SetFont("XeninUI.TextEntry")
	self.textentry:SetDrawLanguageID(false)
	self.textentry.Paint = function(pnl, w, h)
		local col = self:GetTextColor()

		pnl:DrawTextEntryText(col, col, col)

		if (#pnl:GetText() == 0) then
			draw.SimpleText(self:GetPlaceholder() or "", pnl:GetFont(), 3, pnl:IsMultiline() and 8 or h / 2, self:GetPlaceholderColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
	self.textentry.OnValueChange = function(pnl, text)
		self:OnValueChange(text)
	end
end

function PANEL:SetNumeric(bool)
	self.textentry:SetNumeric(true)end
function PANEL:GetNumeric()
	return self.textentry:GetNumeric()end
function PANEL:SetUpdateOnType(bool)
	self.textentry:SetUpdateOnType(true)end
function PANEL:GetUpdateOnType()
	return self.textentry:GetUpdateOnType()end
function PANEL:OnValueChanged() end

function PANEL:SetFont(str)
	self.textentry:SetFont(str)
end

function PANEL:GetFont()
	return self.textentry:GetFont()
end

function PANEL:GetText()
	return self.textentry:GetText()
end

function PANEL:SetText(str)
	self.textentry:SetText(str)
end

function PANEL:SetMultiLine(state)
	self:SetMultiline(state)
	self.textentry:SetMultiline(state)
end

function PANEL:SetLabel(label, left, textColor, offset)
	if offset == nil then offset = 0
	end
	if IsValid(self.label) then self.label:Remove()end

	self.label = self:Add("DLabel")
	self.label:Dock(left and LEFT or RIGHT)
	self.label:DockMargin(left and 10 or -5, 10, (left and -9 or 8) - offset, 10)
	self.label:SetText(label)
	self.label:SetTextColor(textColor or ColorAlpha(self:GetTextColor(), 175))
	self.label:SetFont(self.textentry:GetFont())
	self.label:SizeToContentsX()
end

function PANEL:SetIcon(icon, left)
	if (!IsValid(self.icon)) then
		self.icon = vgui.Create("DButton", self)
		self.icon:SetText("")
		self.icon:Dock(left and LEFT or RIGHT)
		self.icon:DockMargin(left and 10 or -5, 10, left and 0 or 10, 10)
		self.icon.Paint = function(pnl, w, h)
			surface.SetDrawColor(self:GetIconColor())
			surface.SetMaterial(pnl.mat)
			surface.DrawTexturedRect(0, 0, w, h)
		end
		self.icon.DoClick = function(pnl)
			self.textentry:RequestFocus()
		end
	end

	self.icon.mat = icon
end

function PANEL:PerformLayout(w, h)
	if IsValid(self.icon) then
		self.icon:SetWide(self.icon:GetTall())
	end
end

function PANEL:OnMousePressed()
	self.textentry:RequestFocus()
end

function PANEL:Paint(w, h)
	draw.RoundedBox(self:GetRounded(), 0, 0, w, h, self:GetBackgroundColor())
end

vgui.Register("XeninUI.TextEntry", PANEL)
