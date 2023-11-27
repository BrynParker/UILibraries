local PANEL = {}

AccessorFunc(PANEL, "m_sliderColor", "Color")
AccessorFunc(PANEL, "m_max", "Max")
AccessorFunc(PANEL, "m_min", "Min")
AccessorFunc(PANEL, "m_sliderHeight", "Height")

function PANEL:Init()
  self:SetText("")

  self:SetMin(0)
  self:SetMax(10)
  self:SetHeight(2)
  self:SetColor(XeninUI.Theme.Accent)
  self.fraction = 0

  self.grip = vgui.Create("DButton", self)
  self.grip:SetText("")
  self.grip:NoClipping(true)
  self.grip.xOffset = 0
  self.grip.startSize = self:GetHeight() * 4
  self.grip.size = self.grip.startSize
  self.grip.outlineSize = self.grip.startSize
  self.grip.Paint = function(pnl, w, h)
    XeninUI:DrawCircle(pnl.startSize, h / 2, pnl.outlineSize, 45, ColorAlpha(self:GetColor(), 30), 0)

    XeninUI:DrawCircle(pnl.startSize, h / 2, pnl.size, 45, self:GetColor(), 0)
  end
  self.grip.OnCursorEntered = function(pnl)
    pnl:Lerp("outlineSize", pnl.startSize * 2)
  end
  self.grip.OnCursorExited = function(pnl)
    pnl:Lerp("outlineSize", pnl.startSize)
  end
  self.grip.OnMousePressed = function(pnl)
    pnl.Depressed = true

    pnl:MouseCapture(true)

    pnl:LerpWidth(pnl:GetTall() * 2)
  end
  self.grip.OnMouseReleased = function(pnl)
    pnl.Depressed = nil



    pnl:LerpWidth(pnl.startSize * 2)
    pnl:MouseCapture(false)
  end
  self.grip.OnCursorMoved = function(pnl, x, y)
    if (!pnl.Depressed) then return end

    local x, y = pnl:LocalToScreen(x, y)
    x, y = self:ScreenToLocal(x, y)

    local w = self:GetWide()
    local newX = math.Clamp(x / w, 0, 1)
    self.fraction = newX

    self:OnValueChanged(self.fraction)
    self:InvalidateLayout()
  end
  self.grip:SetWide(self.grip.startSize * 2)
end

function PANEL:OnMousePressed()
  local x, y = self:CursorPos()
  local w = self:GetWide() + (self:GetHeight() * 2)
  local newX = math.Clamp(x / w, 0, 1)

  self.fraction = newX
  self:OnValueChanged(self.fraction)
  self:InvalidateLayout()
end

function PANEL:OnValueChanged(fraction) end

function PANEL:Paint(w, h)
  local height = self:GetHeight()
  local y = h / 2 - height / 2

  surface.SetDrawColor(ColorAlpha(self:GetColor(), 50))
  surface.DrawRect(height, y, w - (height * 2), height)

  local width = self.fraction * (w - (self:GetHeight() / 2))
  surface.SetDrawColor(self:GetColor())
  surface.DrawRect(height, y, width, height)
end

function PANEL:PerformLayout(w, h)
  self.grip:SetTall(h)
  self.grip:SetPos(self.fraction * (w - self.grip.size - (self:GetHeight() / 2)))
end

vgui.Register("XeninUI.Slider", PANEL, "DButton")
