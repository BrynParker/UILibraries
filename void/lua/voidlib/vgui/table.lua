local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self:SetHeaderHeight(25)
    self:SetDataHeight(30)
    self:SetMultiSelect(false)

    self.fAddColumn = self.AddColumn

    self.AddColumn = function(self, strColumn)
        local pColumn = self:fAddColumn(strColumn)
        local tblChildren = pColumn:GetChildren()
        
        tblChildren[1]:SetTextColor(VoidUI.Colors.Gray)
        tblChildren[1]:SetFont("VoidUI.R20")
        tblChildren[1].Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, VoidUI.Colors.BackgroundTransparent)
        end

        return pColumn
    end

    self.fAddLine = self.AddLine

    self.AddLine = function(self, ...)
        local pLine = self:fAddLine(...)
        local tblChildren = pLine:GetChildren()
        
        for k, pLabel in ipairs(tblChildren) do
            pLabel:SetTextColor(VoidUI.Colors.Gray)
            pLabel:SetFont("VoidUI.R18")
            pLabel:SetContentAlignment(5)
        end

        return pLine
    end
    

    local sbar = self.VBar

    sbar.Paint = function(self, w, h)
	draw.RoundedBox(24, sc(8), 0, w - sc(8), h, VoidUI.Colors.Background)
    end

    sbar.btnGrip.Paint = function(self, w, h)
	local color = self:IsHovered() and VoidUI.Colors.GrayTransparent or VoidUI.Colors.TextGray
	draw.RoundedBox(24, sc(8), 0, w-sc(8), h, color)
    end

    sbar:SetHideButtons(true)
end

function PANEL:Paint(w, h)
end


vgui.Register("VoidUI.Table", PANEL, "DListView")
