local PANEL = {}

TLib.Font("Header.Upper", 50, "Bauhaus Md BT")
TLib.Font("Header.Lower", 25)


function PANEL:Init()
    self:SetTall(100)
    self:Dock(TOP)

    self.title = self:Add("TLib.Label")
    self.title:SetFont("TLib.Font.Header.Upper")

    self.subtitle = self:Add("TLib.Label")
    self.subtitle:SetFont("TLib.Font.Header.Lower")
end

function PANEL:PerformLayout(w, h)
    self.title:Dock(TOP)
    self.title:SetTall(55)
    self.title:SetContentAlignment(5)
    self.title:SetTextInset(0, 4)

    self.subtitle:Dock(BOTTOM)
    self.subtitle:SetTall(55)
    self.subtitle:SetContentAlignment(5)
    self.subtitle:SetTextInset(0, 0)

end

function PANEL:SetupText(hText, sText, hColor)
    self.title:SetText(hText)
    self.title:SetTextColor(hColor or TLib.Theme.accent)

    self.subtitle:SetText(sText)
    self.subtitle:SetTextColor(sColor or TLib.Theme.text.h2)
end

vgui.Register("TLib.HeaderPanel", PANEL, "TLib.Panel")