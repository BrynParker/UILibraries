local PANEL = {}

function PANEL:Init()
    self.sliders = vgui.Create("Panel", self)
    self.sliders:Dock(LEFT)
    self.sliders:DockMargin(0, 0, 10, 0)

    self.red = vgui.Create("Panel", self.sliders)
    self.red:Dock(TOP)

    self.rInput = vgui.Create("XeninUI.TextEntry", self.red)
    self.rInput:Dock(LEFT)
    self.rInput:DockMargin(0, 0, 0, 5)
    self.rInput:SetText(0)
    self.rInput.textentry:SetUpdateOnType(true)

    self.Input.textentry.OnValueChange = function(pnl, value)
        local numValue = tonumber(value)
        if not numValue then return pnl:SetText("255")end

        if numValue < 0 or numValue > 255 then return pnl:SetText("255")end

        self.rSlider.fraction = (numValue / 255)
        self.rSlider:InvalidateLayout()
    end

    self.rSlider = vgui.Create("XeninUI.Slider", self.red)
    self.rSlider:Dock(RIGHT)
    self.rSlider:SetMin(0)
    self.rSlider:SetMax(255)
    self.rSlider:SetColor(Color(231, 76, 60))

    self.rSlider.OnValueChanged = function(pnl, frac)
        self.rInput:SetText(math.floor(frac * 255))
    end

    self.green = vgui.Create("Panel", self.sliders)
    self.green:Dock(TOP)

    self.gInput = vgui.Create("XeninUI.TextEntry", self.green)
    self.gInput:Dock(LEFT)
    self.gInput:DockMargin(0, 0, 0, 5)
    self.gInput:SetText(0)
    self.gInput.textentry:SetUpdateOnType(true)

    self.gInput.textentry.OnValueChange = function(pnl, value)
        local numValue = tonumber(value)
        if not numValue then return pnl:SetText("0")end

        if numValue < 0 or numValue > 255 then return pnl:SetText("255")end

        self.gSlider.fraction = (numValue / 255)
        self.gSlider:InvalidateLayout()
    end

    self.gSlider = vgui.Create("XeninUI.Slider", self.green)
    self.gSlider:Dock(RIGHT)
    self.gSlider:SetMin(0)
    self.gSlider:SetMax(255)
    self.gSlider:SetColor(Color(46, 204, 113))

    self.gSlider.OnValueChanged = function(pnl, frac)
        self.gInput:SetText(math.floor(frac * 255))
    end

    self.blue = vgui.Create("Panel", self.sliders)
    self.blue:Dock(TOP)

    self.bInput = vgui.Create("XeninUI.TextEntry", self.blue)
    self.bInput:Dock(LEFT)
    self.bInput:DockMargin(0, 5, 0, 0)
    self.bInput:SetText(0)
    self.bInput.textentry:SetUpdateOnType(true)

    self.bInput.textentry.OnValueChange = function(pnl, value)
        local numValue = tonumber(value)
        if not numValue then return pnl:SetText("0")end

        if numValue < 0 or numValue > 255 then return pnl:SetText("255")end

        self.bSlider.fraction = (numValue / 255)
        self.bSlider:InvalidateLayout()
    end

    self.bSlider = vgui.Create("XeninUI.Slider", self.blue)
    self.bSlider:Dock(RIGHT)
    self.bSlider:SetMin(0)
    self.bSlider:SetMax(255)
    self.bSlider:SetColor(Color(52, 152, 219))

    self.bSlider.OnValueChanged = function(pnl, frac)
        self.bInput:SetText(math.floor(frac * 255))
    end

    self.preview = vgui.Create("Panel", self)
    self.preview:Dock(FILL)
    self.preview:DockMargin(5, 5, 5, 5)

    self.preview.Paint = function(pnl, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:GetValue())
    end
end

function PANEL:SetValue(color)
    self.rSlider.fraction = color.r / 255
    self.rInput:SetText(color.r)
    self.gSlider.fraction = color.g / 255
    self.gInput:SetText(color.g)
    self.bSlider.fraction = color.b / 255
    self.bInput:SetText(color.b)
end

function PANEL:GetValue()
    return Color(math.floor(self.rSlider.fraction * 255), math.floor(self.gSlider.fraction * 255), math.floor(self.bSlider.fraction * 255))
end

function PANEL:PerformLayout(w, h)
    self.sliders:SetWide(w * .8)

    self.red:SetTall(h / 3)
    self.rInput:SetWide(self.red:GetWide() * .11)
    self.rSlider:SetWide(self.red:GetWide() * .88)

    self.green:SetTall(h / 3)
    self.gInput:SetWide(self.green:GetWide() * .11)
    self.gSlider:SetWide(self.green:GetWide() * .88)

    self.blue:SetTall(h / 3)
    self.bInput:SetWide(self.blue:GetWide() * .11)
    self.bSlider:SetWide(self.blue:GetWide() * .88)
end

vgui.Register("XeninUI.ColorMixer", PANEL)
