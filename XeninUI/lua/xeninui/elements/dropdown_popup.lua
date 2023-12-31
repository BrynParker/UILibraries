XeninUI:CreateFont("XeninUI.DropdownPopup", 19)

local PANEL = {}

AccessorFunc(PANEL, "m_backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "m_textColor", "TextColor")
AccessorFunc(PANEL, "m_accentColor", "AccentColor")
AccessorFunc(PANEL, "m_iconColor", "IconColor")

function PANEL:Init()
  self.choices = {}

  self.Alpha = 0
  self:LerpAlpha(255, 0.15)
  self:SetBackgroundColor(XeninUI.Theme.Primary)
  self:SetTextColor(color_white)
  self:SetAccentColor(XeninUI.Theme.Accent)
  self:SetIconColor(color_white)
  self:DockPadding(0, 8, 0, 8)
end

function PANEL:Paint(w, h)
  local aX, aY = self:LocalToScreen()

  BSHADOWS.BeginShadow()
  draw.RoundedBox(6, aX, aY, w, h, self:GetBackgroundColor())
  BSHADOWS.EndShadow(1, 2, 2)
end

function PANEL:AddChoice(name, onClick, textColor, accentColor, icon, iconColor)
  onClick = onClick or function()
    return true end

  local panel = vgui.Create("DButton", self)
  panel:Dock(TOP)
  panel:SetTall(48)
  panel:SetText(name)
  panel:SetFont("XeninUI.DropdownPopup")
  panel:SetTextInset(icon and 64 or 16, 0)
  panel:SetContentAlignment(4)
  panel:SetTextColor(textColor or self:GetTextColor())
  panel.alpha = 0
  panel.Paint = function(pnl, w, h)
    surface.SetDrawColor(ColorAlpha(accentColor or self:GetAccentColor(), pnl.alpha))
    surface.DrawRect(0, 0, w, h)
  end
  panel.OnCursorEntered = function(pnl)
    pnl:Lerp("alpha", 200)
  end
  panel.OnCursorExited = function(pnl)
    pnl:Lerp("alpha", 0)
  end
  panel.DoClick = function(pnl)
    onClick(pnl)

    self:Remove()
  end

  if icon then
    panel.icon = panel:Add("Panel")
    panel.icon:SetMouseInputEnabled(false)
    panel.icon.icon = icon
    panel.icon.CalculatePoly = function(self, w, h, vertices)
      local poly = {}

      local x = w / 2
      local y = h / 2
      local radius = h / 2

      table.insert(poly, {
        x = x,
        y = y
      })

      for i = 0, vertices do
        local a = math.rad((i / vertices) * -360)
        table.insert(poly, {
          x = x + math.sin(a) * radius,
          y = y + math.cos(a) * radius
        })
      end

      local a = math.rad(0)
      table.insert(poly, {
        x = x + math.sin(a) * radius,
        y = y + math.cos(a) * radius
      })
      self.data = poly
    end
    panel.icon.DrawPoly = function(self, w, h, vertices)
      if (!self.data) then
        self:CalculatePoly(w, h, vertices)
      end

      surface.DrawPoly(self.data)
    end
    panel.icon.Paint = function(pnl, w, h)
      render.ClearStencil()
      render.SetStencilEnable(true)

      render.SetStencilWriteMask(1)
      render.SetStencilTestMask(1)

      render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
      render.SetStencilPassOperation(STENCILOPERATION_ZERO)
      render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
      render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
      render.SetStencilReferenceValue(1)

      draw.NoTexture()
      surface.SetDrawColor(color_white)
      pnl:DrawPoly(w, h, 90)

      render.SetStencilFailOperation(STENCILOPERATION_ZERO)
      render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
      render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
      render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
      render.SetStencilReferenceValue(1)

      if pnl.icon then
        surface.SetDrawColor(iconColor or self:GetIconColor())
        surface.SetMaterial(pnl.icon)
        surface.DrawTexturedRect(0, 0, w, h)
      end

      render.SetStencilEnable(false)
      render.ClearStencil()
    end
    panel.PerformLayout = function(pnl, w, h)
      pnl.icon:SetPos(16, 6)
      pnl.icon:SetSize(h - 12, h - 12)
    end
  end

  local i = table.insert(self.choices, {
    panel = panel,
    str = name
  })

  self:InvalidateLayout()

  return panel
end

function PANEL:PerformLayout(w, h)
  local longest = 0

  surface.SetFont("XeninUI.DropdownPopup")
  for i, v in pairs(self.choices) do
    local tw = surface.GetTextSize(v.str)
    tw = tw + 16
    tw = tw + 16
    if v.panel.icon then
      tw = tw + 48
    end

    if (tw > longest) then
      longest = math.max(112, tw)
    end
  end

  self:SetWide(longest)
  self:SetTall(8 + #self.choices * 48 + 8)
end

function PANEL:OnFocusChanged(gained)
  if (!IsValid(self)) then return end
  if gained then return end
  if self.ignore then return end

  self:Remove()
end

function PANEL:Think()
  local w, h = self:GetSize()
  local x, y = self.x, self.y
  x = math.Clamp(x, 0, ScrW() - w)
  y = math.Clamp(y, 0, ScrH() - h)

  self:SetPos(x, y)
end

vgui.Register("XeninUI.DropdownPopup", PANEL, "EditablePanel")

function XeninUI:DropdownPopup(x, y)
  local panel = vgui.Create("XeninUI.DropdownPopup", vgui.GetWorldPanel())
  panel:SetDrawOnTop(true)
  panel:SetPos(x + 12, y + 12)
  panel:MakePopup()

  return panel
end

XeninUI:CreateFont("XeninUI.QueryPopup.Title", 19, 800)
XeninUI:CreateFont("XeninUI.QueryPopup.Subtitle", 16, 800)
XeninUI:CreateFont("XeninUI.QueryPopup.Button", 18, 800)

local PANEL = {}

AccessorFunc(PANEL, "m_title", "Title")
AccessorFunc(PANEL, "m_subtitle", "Subtitle")
AccessorFunc(PANEL, "m_subtitleColor", "SubtitleColor")

function PANEL:Init()
  self:DockPadding(8, 8, 8, 8)
  self:SetTall(96)

  self.onCancel = function() end
  self.onAccept = function() end

  self.title = vgui.Create("DLabel", self)
  self.title:Dock(TOP)
  self.title:SetText("Equip this booster?")
  self.title:SetFont("XeninUI.QueryPopup.Title")
  self.title:SetTextColor(color_black)

  self.subtitle = vgui.Create("DLabel", self)
  self.subtitle:Dock(TOP)
  self.subtitle:DockMargin(0, -2, 0, 0)
  self.subtitle:SetTextColor(Color(75, 75, 75))
  self.subtitle:SetFont("XeninUI.QueryPopup.Subtitle")

  self.bottom = vgui.Create("Panel", self)
  self.bottom:Dock(BOTTOM)
  self.bottom:SetTall(32)

  self.cancel = vgui.Create("DButton", self.bottom)
  self.cancel:Dock(RIGHT)
  self.cancel:DockMargin(8, 0, 0, 0)
  self.cancel:SetText("Cancel")
  self.cancel:SetTextColor(XeninUI.Theme.Red)
  self.cancel:SetFont("XeninUI.QueryPopup.Button")
  self.cancel.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, Color(220, 220, 220))
  end
  self.cancel.DoClick = function(pnl)
    self:onCancel()

    self:Remove()
  end
  local tw, th = surface.GetTextSize(self.cancel:GetText())
  self.cancel:SetWide(tw + 24)

  self.unlock = vgui.Create("DButton", self.bottom)
  self.unlock:Dock(RIGHT)
  self.unlock:SetText("Accept")
  self.unlock:SetTextColor(XeninUI.Theme.Green)
  self.unlock:SetFont("XeninUI.QueryPopup.Button")
  self.unlock.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, Color(220, 220, 220))
  end
  self.unlock.DoClick = function(pnl)
    self:onAccept()

    self:Remove()
  end
  surface.SetFont(self.unlock:GetFont())
  local tw, th = surface.GetTextSize(self.unlock:GetText())
  self.unlock:SetWide(tw + 16)

  surface.SetFont(self.title:GetFont())
  local tw, th = surface.GetTextSize(self.title:GetText())
  self:SetWide(tw + 16)
end

function PANEL:Paint(w, h)
  draw.RoundedBox(6, 0, 0, w, h, color_white)
end

function PANEL:OnFocusChanged(gained)
  if (!IsValid(self)) then return end
  if gained then return end
  if self.ignore then return end

  self:Remove()
end

vgui.Register("XeninUI.QueryPopup", PANEL, "EditablePanel")

function XeninUI:Popup(x, y, title, subtitle, onUnlock, onCancel, hideUnlock, titleColor, subtitleColor, acceptText)
  local panel = vgui.Create("XeninUI.QueryPopup")
  panel:SetDrawOnTop(true)
  panel:SetMouseInputEnabled(true)
  panel:SetPos(x + 12, y + 12 - 12)
  panel.title:SetText(title or "Title")
  panel.subtitle:SetText(subtitle or "Subtitle")

  if subtitleColor then
    panel.subtitle:SetTextColor(subtitleColor)
  end

  if titleColor then
    panel.title:SetTextColor(titleColor)
  end

  if acceptText then
    panel.unlock:SetText(acceptText)
  end

  if onUnlock then
    panel.onAccept = onUnlock

    local tw, th = surface.GetTextSize(panel.unlock:GetText())
    panel.unlock:SetWide(tw + 16)
  end
  if onCancel then
    panel.onCancel = onCancel

    local tw, th = surface.GetTextSize(panel.cancel:GetText())
    panel.cancel:SetWide(tw + 24)
  end
  if hideUnlock then
    panel.unlock:Remove()
    panel:InvalidateLayout()
  end

  surface.SetFont(panel.unlock:GetFont())
  local tw, th = surface.GetTextSize(panel.unlock:GetText())
  panel.unlock:SetWide(tw + 16)

  surface.SetFont(panel.title:GetFont())
  local tw, th = surface.GetTextSize(panel.title:GetText())
  panel:SetWide(math.max(192, tw + 16))

  return panel
end
