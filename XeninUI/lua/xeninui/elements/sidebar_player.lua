local PANEL = {}

XeninUI:CreateFont("XeninUI.Sidebar.Player.Name", 20)
XeninUI:CreateFont("XeninUI.Sidebar.Player.Job", 16)

function PANEL:Init()
  self:SetColors({
    startColor = Color(208, 62, 106),
    endColor = Color(200, 60, 123)
  }, {
    startColor = Color(251, 211, 50),
    endColor = Color(69, 198, 103)
  })

  self.Avatar = self:Add("XeninUI.Avatar")
  self.Avatar:SetPlayer(LocalPlayer(), 64)
  self.Avatar:SetVertices(30)

  self.Text = self:Add("DPanel")
  self.Text:SetMouseInputEnabled(false)
  self.Text.TextHeight = 0
  self.Text.Paint = function(pnl, w, h)
    local ply = LocalPlayer()

    pnl.TextHeight = 0
    for i, v in pairs(pnl.Rows) do
      XeninUI:DrawShadowText(v.text, v.font, 0, pnl.TextHeight, v.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 255)

      pnl.TextHeight = pnl.TextHeight + draw.GetFontHeight(v.font) - 2
    end
  end

  local ply = LocalPlayer()
  self:SetRows({
    {
      font = "XeninUI.Sidebar.Player.Name",
      text = ply:Nick(),
      color = color_white
    },
    {
      font = "XeninUI.Sidebar.Player.Job",
      text = ply:GetUserGroup():gsub("^%l", string.upper),
      color = XeninUI.Theme.Green
    }
  })
end

function PANEL:SetColors(startGradient, endGradient)
  self.startGradient = startGradient
  self.endGradient = endGradient
end

function PANEL:SetRows(rows)
  self.Text.Rows = rows
end

function PANEL:Paint(w, h)
  local aX, aY = self:LocalToScreen()
  draw.SimpleLinearGradient(aX, aY, w, h, self.startGradient.startColor, self.startGradient.endColor)

  XeninUI:Mask(function()
    XeninUI:DrawRoundedBox((h - 24) / 2, 12, 12, h - 24, h - 24, color_white)
  end, function()
    draw.SimpleLinearGradient(aX + 12, aY + 12, h - 24, h - 24, self.endGradient.startColor, self.endGradient.endColor, true)
  end)
end

function PANEL:PerformLayout(w, h)
  self.Avatar:SetPos(14, 14)
  self.Avatar:SetSize(h - 28, h - 28)

  self.Text:MoveRightOf(self.Avatar, 10)
  local textH = 1
  for i, v in pairs(self.Text.Rows) do
    textH = textH + draw.GetFontHeight(v.font)
  end
  self.Text:SetTall(textH)
  self.Text:CenterVertical()
  self.Text:SetWide(w - self.Text.x)
end

vgui.Register("XeninUI.Sidebar.Player", PANEL)
