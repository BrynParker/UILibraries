local sc = VoidUI.Scale

local PANEL = {}

AccessorFunc(PANEL, "horizontalMargin", "HorizontalMargin", FORCE_NUMBER)
AccessorFunc(PANEL, "verticalMargin", "VerticalMargin", FORCE_NUMBER)
AccessorFunc(PANEL, "columns", "Columns", FORCE_NUMBER)

AccessorFunc(PANEL, "maxHeight", "MaxHeight", FORCE_NUMBER)


function PANEL:Init()
    self.Rows = {}
	self.Cells = {}

    self:SetColumns(2)
    self:SetVerticalMargin(sc(25))
end

function PANEL:AddEntry(title, text)
    local entryPanel = vgui.Create("Panel")
    entryPanel:SetTall(50)
    entryPanel.text = text
    entryPanel.textColor = VoidUI.Colors.White
    entryPanel.Paint = function (self, w, h)
        draw.SimpleText(string.upper(title), "VoidUI.B22", 0, 0, VoidUI.Colors.Blue)

        draw.SimpleText(self.text, "VoidUI.R24", 0, sc(20), self.textColor or VoidUI.Colors.White)
    end

    self:AddCell(entryPanel)

    return entryPanel
end

vgui.Register("VoidUI.TextGrid", PANEL, "VoidUI.Grid")