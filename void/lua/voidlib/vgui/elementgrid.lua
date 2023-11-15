local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self:InvalidateParent(true)

    self:SetColumns(2)
    self:SetHorizontalMargin(sc(45))
    self:SetVerticalMargin(sc(20))
end

function PANEL:AddElement(title, element, height, nocell)
    local entry = vgui.Create("Panel")
    entry:SSetTall(height and height + 30 or 75)
    entry.Paint = function (self, w, h)
        draw.SimpleText(string.upper(title), "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    entry.input = entry:Add(element)
    entry.input:Dock(TOP)
    entry.input:SDockMargin(0, sc(30), 0, 0)
    entry.input:SSetTall(height or 45)

    if (!nocell) then
        self:AddCell(entry, nil)
    end

    return entry.input, entry
end

vgui.Register("VoidUI.ElementGrid", PANEL, "VoidUI.Grid")