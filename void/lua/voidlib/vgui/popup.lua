local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self.startTime = SysTime() - 0.5

    self:SetSize(sc(420), sc(170))

    self:Center()

    self:MakePopup()
    self:DoModal()

    self.titleColor = VoidUI.Colors.Blue
    self.title = "INFO"

    self.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam congue purus...."
    self:WrapText()

    self.continueFunc = nil
    self.cancelFunc = nil

    local buttonContainer = self:Add("Panel")
    buttonContainer:Dock(BOTTOM)
    buttonContainer:SSetTall(30)
    buttonContainer:MarginBottom(15)
    buttonContainer:MarginSides(50)

    local continueButton = buttonContainer:Add("VoidUI.Button")
    continueButton:Dock(LEFT)
    continueButton:SSetWide(sc(140))
    continueButton:SetColor(VoidUI.Colors.Green, VoidUI.Colors.Background)
    continueButton.rounding = 14
    continueButton.thickness = 2
    continueButton.font = "VoidUI.R24"

    continueButton.DoClick = function ()
        if (self.continueFunc) then
            self.continueFunc()
        end
        self:Remove()
    end
    
    local cancelButton = buttonContainer:Add("VoidUI.Button")
    cancelButton:Dock(RIGHT)
    cancelButton:SSetWide(sc(140))
    cancelButton:SetColor(VoidUI.Colors.Red, VoidUI.Colors.Background)
    cancelButton.rounding = 14
    cancelButton.thickness = 2
    cancelButton.font = "VoidUI.R24"

    cancelButton.DoClick = function ()
        if (self.cancelFunc) then
            self.cancelFunc()
        end
        self:Remove()
    end

    self.continueButton = continueButton
    self.cancelButton = cancelButton
end

function PANEL:WrapText()
    self.wrappedText = VoidUI.TextWrap(self.text, "VoidUI.R24", self:GetWide() * 0.9)
end

function PANEL:SetText(title, text, titleColor)
    self.title = string.upper(title)
    self.text = text

    if (titleColor) then
        self.titleColor = titleColor
    end

    self:WrapText()
end

-- Info (blue)
function PANEL:SetInfo()
    self.titleColor = VoidUI.Colors.Blue
    self.continueButton:SetColor(VoidUI.Colors.Green)
    self.cancelButton:SetColor(VoidUI.Colors.Red)
end

-- Danger (red)
function PANEL:SetDanger()
    self.titleColor = VoidUI.Colors.Red
    self.continueButton:SetColor(VoidUI.Colors.Red)
    self.cancelButton:SetColor(VoidUI.Colors.Green)
end

function PANEL:Continue(text, func)
    self.continueButton:SetText(text)
    self.continueFunc = func
end

function PANEL:Cancel(text, func)
    self.cancelButton:SetText(text)
    self.cancelFunc = func
end

function PANEL:SetTitleColor(color)
    self.titleColor = color
end

function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.startTime)

    draw.RoundedBox(16, 0, 0, w, h, VoidUI.Colors.Background)

    draw.SimpleText(self.title, "VoidUI.B30", w/2, sc(10), self.titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.DrawText(self.wrappedText, "VoidUI.R24", w/2, sc(45), VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

vgui.Register("VoidUI.Popup", PANEL, "EditablePanel")