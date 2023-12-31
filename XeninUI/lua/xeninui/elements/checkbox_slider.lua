local PANEL = {}

XeninUI:CreateFont("XeninUI.Checkbox.Slider", 14)

AccessorFunc(PANEL, "m_state", "State")
AccessorFunc(PANEL, "m_offColor", "OffColor")
AccessorFunc(PANEL, "m_onColor", "OnColor")
AccessorFunc(PANEL, "m_btnOffColor", "ButtonOffColor")
AccessorFunc(PANEL, "m_btnOnColor", "ButtonOnColor")

function PANEL:Init()
  self:SetText("")
  self:SetState(false)

  self:SetOffColor(XeninUI.Theme.Primary)
  self:SetOnColor(XeninUI.Theme.GreenDark)

  self:SetButtonOffColor(Color(72, 72, 72))
  self:SetButtonOnColor(color_white)

  self.Color = self:GetOffColor()
  self.Pos = 0
  self.ButtonColor = self:GetButtonOffColor()
end

function PANEL:Paint(w, h)
  XeninUI:DrawRoundedBox(h / 2, 0, 0, w, h, self.Color)

  local size = h / 2
  local frac = self.Pos
  local x = frac * (w - (size * 2))





  XeninUI:DrawCircle(size + x, size, size - 3, 30, self.ButtonColor)
end


function PANEL:OnStateChanged(state) end

function PANEL:SetState(state)
  self.m_state = state
  self:OnStateChanged(state)
end

function PANEL:UpdateState(instant)
  local state = self:GetState()
  local col = state and self:GetOnColor() or self:GetOffColor()
  local btnCol = state and self:GetButtonOnColor() or self:GetButtonOffColor()
  local pos = state and 1 or 0

  if instant then
    self.Color = col
    self.ButtonColor = btnCol
    self.Pos = pos
  else
    self:EndAnimations()
    self:LerpColor("Color", col)
    self:LerpColor("ButtonColor", btnCol)
    self:Lerp("Pos", pos)
  end
end

function PANEL:DoClick()
  self:SetState(!self:GetState())
  self:UpdateState()
end

vgui.Register("XeninUI.Checkbox.Slider", PANEL, "DButton")
