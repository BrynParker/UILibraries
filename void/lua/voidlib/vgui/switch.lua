local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self.lerpTime = 0.15
    self.lerpStart = nil
end

-- dropdown compatibility
function PANEL:ChooseOptionID(id)
    self:SetValue(id == 1)
end

function PANEL:OnChange(val)
    self.lerpStart = CurTime()

    if (self.OnSelect) then
        self:OnSelect(val and 1 or 2)
    end
end

function PANEL:DropdownCompat()
    self:SDockMargin(0, 35, 170, 30)
    self:SSetTall(35)
end

function PANEL:Paint(w, h)
    local color = self:GetChecked() and VoidUI.Colors.Green or VoidUI.Colors.Red
    draw.RoundedBox(32, 0, 0, w, h, color)

    local circRad = h*0.4
    local circPos = 0

    local circStart = circRad + 5
    local circEnd = w - circRad - 5

    if (self.lerpStart) then
        local startTime = self.lerpStart
        local endTime = self.lerpStart + self.lerpTime

        local lerpProgress = (CurTime() - startTime) / self.lerpTime

        if (!self:GetChecked()) then
            lerpProgress = 1 - lerpProgress
        end

        if (lerpProgress >= 1 and self:GetChecked()) then
            self.lerpStart = nil
        end

        if (lerpProgress <= 0 and !self:GetChecked()) then
            self.lerpStart = nil
        end
        
        circPos = Lerp(lerpProgress, circStart, circEnd)
    else
        circPos = self:GetChecked() and circEnd or circStart
    end

    surface.SetDrawColor(VoidUI.Colors.White)
    VoidUI.DrawCircle(circPos, h/2, circRad, 1)
end

vgui.Register("VoidUI.Switch", PANEL, "DCheckBox")