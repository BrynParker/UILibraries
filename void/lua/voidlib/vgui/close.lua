local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self:SetSize(sc(30),sc(30))
    self:SetText("")
    self:SetDrawOnTop(true)
end

function PANEL:CloseFunction()
    self:GetParent():GetParent():Remove()
end

function PANEL:DoClick()
    self:CloseFunction()
end

function PANEL:Paint(w, h) end

function PANEL:PaintOver(w, h)

    local drawColor = (self:IsHovered() and VoidUI.Colors.Red) or VoidUI.Colors.White

    surface.SetDrawColor(drawColor)
    surface.SetMaterial(VoidUI.Icons.Close)
    surface.DrawTexturedRect(0, 0, w, h)

end

vgui.Register("VoidUI.Close", PANEL, "DButton")