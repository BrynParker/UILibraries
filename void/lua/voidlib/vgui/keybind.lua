local sc = VoidUI.Scale

local focusedKeybind = nil

local PANEL = {}

function PANEL:Init()
    self:SetText("")

    self.text = "Click to add"
    self.focusText = "Press any key"

    self.keyText = nil
    self.value = nil

    self.isActive = false

    self.color = VoidUI.Colors.InputDark
end

function PANEL:SetLight()
    self.color = VoidUI.Colors.InputLight
end

function PANEL:Select(key)
    if (key != nil) then
        local keyName = language.GetPhrase(input.GetKeyName(key))
        self.keyText = keyName
    else
        self.keyText = nil
    end
    self.value = key
end

function PANEL:OnSelect(key)

end

hook.Add("VGUIMousePressed", "VoidUI.KeybindKeypress", function (pnl, key)
    if (IsValid(focusedKeybind)) then
        focusedKeybind:KillFocus()
        focusedKeybind:FocusNext()
    end
end)

function PANEL:DoClick()
    if (!self:HasFocus()) then
        self:RequestFocus()
        self.isActive = true

        focusedKeybind = self
    else
        self:KillFocus()
        self:FocusNext()
        self.isActive = false

        focusedKeybind = nil
    end
    
end

function PANEL:DoRightClick()
    self.keyText = nil
    self.value = nil

    self:OnSelect(nil)

    self:KillFocus()
    self:FocusNext()
end

function PANEL:OnKeyCodePressed(key)
    self:Select(key)
    self:OnSelect(key)

    self:KillFocus()
    self:FocusNext()
end


function PANEL:Paint(w, h)
    local color = self:IsHovered() and VoidUI.Colors.Hover or self.color
    draw.RoundedBox(8, 0, 0, w, h, color)

    local text = self:HasFocus() and self.focusText or (self.keyText or self.text)

    local textColor = self.keyText and VoidUI.Colors.White or VoidUI.Colors.TextGray
    draw.SimpleText(text, "VoidUI.R26", sc(15), h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("VoidUI.KeybindButton", PANEL, "DButton")