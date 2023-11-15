local sc = VoidUI.Scale

local PANEL = {}

AccessorFunc(PANEL, "maxHeight", "MaxHeight", FORCE_NUMBER)

function PANEL:Init()
    self.space = 10
    self.horizontalMargin = 0

    self.rowHeight = 30

    self.totalRowHeight = 0
end

function PANEL:AddRow(panel, height)
    panel:Dock(TOP)
    panel:SDockMargin(self.horizontalMargin, 0, self.horizontalMargin, self.space)
    panel:SSetTall(height or self.rowHeight)

    self.totalRowHeight = self.totalRowHeight + (height or self.rowHeight) + self.space
end


function PANEL:AutoSize()
    local totalHeight = self.totalRowHeight

    if (self:GetMaxHeight() and self:GetMaxHeight() != 0) then
		totalHeight = math.min(totalHeight, self:GetMaxHeight())
	end

    if (self:GetParent():GetName() == "VoidUI.PanelContent") then
		self:GetParent():SetTall(totalHeight + self:GetTopMargin())
	end


    self:SSetTall(totalHeight)

    return totalHeight
end

function PANEL:SetRowHeight(rowHeight)
    self.rowHeight = rowHeight
end

function PANEL:SetSpacing(space)
    self.space = space
end

function PANEL:SetVerticalMargin(margin)
    self:SetSpacing(margin)
end

function PANEL:SetHorizontalMargin(margin)
    self.horizontalMargin = margin
end

vgui.Register("VoidUI.RowPanel", PANEL, "VoidUI.ScrollPanel")