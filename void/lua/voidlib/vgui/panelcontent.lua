local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self:SetVisible(false)

    self.title = "PANEL TITLE"
    self.font = "VoidUI.B30"


    self.textColor = VoidUI.Colors.Gray

    self.panelTitle = self:Add("Panel")
    self.panelTitle:Dock(TOP)
    self.panelTitle:SSetTall(40)

    self.panelTitle.Paint = function (s, w, h)
        draw.RoundedBox(10, 0, 0, w, h, VoidUI.Colors.Primary)

        draw.SimpleText(self.title, self.font, w/2, h/2, self.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.panelTitle:SetVisible(false)
end

function PANEL:SetTitle(title, ignoreMargin)
    self.title = title

    if (!ignoreMargin) then
        self.panelTitle:MarginSides(45)
        self.panelTitle:MarginTop(25)
        self.panelTitle:MarginBottom(10)
    end

    self.panelTitle:SetVisible(true)

    return self.panelTitle
end

function PANEL:SetTitleFont(font)
    self.font = font
end

function PANEL:SetTitleColor(color)
    self.textColor = color
end

function PANEL:SetCompact()
    self:SetTitleFont("VoidUI.R26")
    self:SetVisible(true)
end

vgui.Register("VoidUI.PanelContent", PANEL, "Panel")