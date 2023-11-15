local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self:SetText("")

    self.text = "Click to add"
    self.selection = nil
    self.value = nil

    self.selectionString = ""
end

function PANEL:Select(k, v)
    self.value = k

    if (istable(v)) then
        self.selection = table.concat(v, ", ")
        if (#self.selection > 27) then
            self.selection = string.sub(self.selection, 1, 27) .. "..."
        end
    else
        self.selection = v
    end
end

function PANEL:Paint(w, h)
    local color = self:IsHovered() and VoidUI.Colors.Hover or VoidUI.Colors.InputDark
    draw.RoundedBox(8, 0, 0, w, h, color)

    local textColor = self.selection and VoidUI.Colors.White or VoidUI.Colors.TextGray
    draw.SimpleText(self.selection or self.text, "VoidUI.R26", sc(15), h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("VoidUI.SelectorButton", PANEL, "DButton")