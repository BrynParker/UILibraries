local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self:SDockPadding(15, 15, 15, 15)

    self.hasText = false
    self.hasTitle = false
    self.textFont = "VoidUI.B24"
    self.text = "PANEL"
    self.wrappedText = self.text
    self.strSlightFont = "VoidUI.R14"

    self.textColor = VoidUI.Colors.White
    self.slightColor = VoidUI.Colors.LightGray
    self.wrapped = false
end

function PANEL:SetText(text)
    self.hasText = true
    self.text = text
    self:CalcWrap()
end

function PANEL:SetTitle(title, strDesc)
    self.hasTitle = true
    self.title = title
    self.textFont = "VoidUI.R24"
    self.strDesc = strDesc

end

function PANEL:WrapText()
    self.wrapped = true
    self:CalcWrap()
end

function PANEL:CalcWrap()
    if (!self.wrapped) then return end

    self:InvalidateLayout(true)
end

function PANEL:PerformLayout(w, h)
    if (!self.wrapped) then return end

    local width = w - sc(40)
    self.wrappedText = VoidUI.TextWrap(self.text, self.textFont, width)
end

function PANEL:SetTextColor(col)
    self.textColor = col
end

function PANEL:SetFont(font)
    self.textFont = font
    self:CalcWrap()
end

function PANEL:Paint(w, h)
    draw.RoundedBox(12, 0, 0, w, h, VoidUI.Colors.Primary)

    if (self.hasText) then
        if (self.wrapped) then
            draw.DrawText(self.wrappedText, self.textFont, sc(20), sc(15), self.textColor, TEXT_ALIGN_LEFT)
        else
            draw.SimpleText(self.text, self.textFont, w/2, h/2, self.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if (self.hasTitle) then
        if (!self.strDesc) then
            draw.SimpleText(self.title, self.textFont, sc(15), sc(15), self.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        else
            draw.SimpleText(self.title, self.textFont, sc(15), sc(15), self.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(self.strDesc, self.strSlightFont, sc(15), sc(51), self.slightColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end
    end
end

vgui.Register("VoidUI.BackgroundPanel", PANEL, "Panel")