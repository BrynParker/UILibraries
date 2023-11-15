local PANEL = {}

function PANEL:Init()
    self.backgroundColor = color_white
    self:SetZPos(9999)
end

function PANEL:PaintOver(w, h)
    VoidUI.StencilStart()

    surface.SetDrawColor(Color(0,0,0,1))
    VoidUI.DrawCircle(w/2, h/2, w/2, 2)

    VoidUI.StencilReplace()

    surface.SetDrawColor(self.backgroundColor:Unpack())
    surface.DrawRect(0, 0, w, h)

    VoidUI.StencilEnd()
end

function PANEL:SetBackgroundColor(color)
    self.backgroundColor = color
end

vgui.Register("VoidUI.CircleAvatar", PANEL, "AvatarImage")
