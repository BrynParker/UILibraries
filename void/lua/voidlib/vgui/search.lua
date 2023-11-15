local PANEL = {}

function PANEL:Init()
    self:SetColorScheme(VoidUI.Colors.White, VoidUI.Colors.White, VoidUI.Colors.BackgroundTransparent, VoidUI.Colors.BackgroundTransparent)
    self:SetFont("VoidUI.R20")
    self.entry:SetPlaceholderText("Search by name...")

    self.dockL = 35

    self.OnValueChange = function (s, str)
        self:OnSearch(str)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, self.borderColor)
	draw.RoundedBox(8, 1, 1, w-2, h-2, self.backgroundColor)

    local iconSize = h * 0.6

    surface.SetDrawColor(VoidUI.Colors.Gray)
    surface.SetMaterial(VoidUI.Icons.Search)
    surface.DrawTexturedRect(10, h/2 - iconSize / 2, iconSize, iconSize)
end

function PANEL:OnSearch(str)

end

vgui.Register("VoidUI.Search", PANEL, "VoidUI.TextInput")