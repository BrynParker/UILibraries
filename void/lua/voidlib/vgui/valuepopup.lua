local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()

    self:SSetTall(210)

    local textInput = self:Add("VoidUI.TextInput")
    textInput:Dock(BOTTOM)
    textInput:MarginSides(50)
    textInput:SSetTall(30)
    textInput:MarginTops(20)

    self.continueButton.DoClick = function ()
        self.continueFunc(textInput.entry:GetValue())
        self:Remove()
    end

    self.textInput = textInput
end

function PANEL:SetNumeric()
    self.textInput.entry:SetNumeric(true)
end

function PANEL:Continue(text, func)
    self.continueButton:SetText(text)
    self.continueFunc = func
end


vgui.Register("VoidUI.ValuePopup", PANEL, "VoidUI.Popup")