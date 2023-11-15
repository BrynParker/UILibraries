local PANEL = {}

function PANEL:Init()
    self:MakePopup()
    self.drawShadow = true
    self.noModal = true
end

function PANEL:SetNoModal(bool)
    self.noModal = bool
end

function PANEL:Think()
    if (self.noModal and !self:HasFocus()) then
        self:MoveToFront()
    end
end

vgui.Register("VoidUI.ModalFrame", PANEL, "VoidUI.Frame")