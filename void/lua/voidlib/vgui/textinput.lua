local PANEL = {}

function PANEL:Init()

    self.dockL = 10
    self.dockR = 10

	self.entry = self:Add("DTextEntry")
	self.entry:Dock(FILL)
	self.entry:SDockMargin(self.dockL, 0, self.dockR, 0)

    self.textColor = VoidUI.Colors.Black
    self.cursorColor = VoidUI.Colors.Black

    self.backgroundColor = VoidUI.Colors.White
    self.borderColor = VoidUI.Colors.Gray

	self.entry:SetFont("VoidUI.R26")
	self.entry:SetTextColor(self.textColor)
	self.entry:SetCursorColor(self.cursorColor)

	self.entry:SetPaintBackground(false)

	self.entry:SetUpdateOnType(true)

    function self.entry:OnValueChange(val)
        self:GetParent():OnValueChange(val)
    end

    self:SetDark()
	
    self:SetAllowNonAsciiCharacters(true)

end

function PANEL:SetPlaceholder(text)
    self.entry:SetPlaceholderText(text)
end

function PANEL:SetFont(font)
    self.entry:SetFont(font)
end

function PANEL:SetNumeric(bool)
    self.entry:SetNumeric(bool)
end

function PANEL:SetMultiline(bool)
    self.entry:SetMultiline(bool)
end

function PANEL:OnValueChange(value)
    -- override
end

function PANEL:GetValue()
    return self.entry:GetValue()
end

function PANEL:SetValue(val)
    self.entry:SetValue(val)
end

function PANEL:PerformLayout(w, h)
	self.entry:Dock(FILL)
	self.entry:SDockMargin(self.dockL, 0, self.dockR, 0)
end

function PANEL:SetColorScheme(textColor, cursorColor, bgColor, borderColor)

    self.textColor = textColor
    self.cursorColor = cursorColor

    self.backgroundColor = bgColor
    self.borderColor = borderColor

    self.entry:SetTextColor(self.textColor)
	self.entry:SetCursorColor(self.cursorColor)
end

function PANEL:SetDark()
    self:SetColorScheme(VoidUI.Colors.White, VoidUI.Colors.White, VoidUI.Colors.InputDark, VoidUI.Colors.Black)
end

function PANEL:SetLight()
    self:SetColorScheme(VoidUI.Colors.White, VoidUI.Colors.White, VoidUI.Colors.InputLight, VoidUI.Colors.Black)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, self.borderColor)
	draw.RoundedBox(8, 1, 1, w-2, h-2, self.backgroundColor)
end

vgui.Register("VoidUI.TextInput", PANEL, "Panel")
