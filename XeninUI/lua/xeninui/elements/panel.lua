local PANEL = {}

function PANEL:Init()
  self.notifications = {}
end

function PANEL:Notification(title, backgroundCol, textCol)
  local pnl = self:Add("DPanel")
  pnl:SetAlpha(0)
  pnl:AlphaTo(255, 0.1)
  pnl:SetZPos(2)
  pnl.uniqueID = SysTime()
  pnl.Paint = function(pnl, w, h)
    local x, y = pnl:LocalToScreen(0, 0)

    BSHADOWS.BeginShadow()
    draw.RoundedBox(6, x, y, w, h, backgroundCol or XeninUI.Theme.Primary)
    draw.SimpleText(title, "XeninUI.Notification", x + 8, y + 8, textCol or XeninUI:GetContrastColor(backgroundCol, color_white, color_black))
    BSHADOWS.EndShadow(1, 2, 2, 200, 0, 0)
  end

  surface.SetFont("XeninUI.Notification")
  local tw, th = surface.GetTextSize(title)
  pnl:SetSize(tw + 16, th + 16)

  local offset = 16
  for i, v in pairs(self.notifications) do
    offset = offset + v:GetTall() + 8
  end

  pnl:SetPos(self:GetWide() - 16 - pnl:GetWide(), offset)

  table.insert(self.notifications, pnl)

  timer.Simple(3, function()
    if (!IsValid(pnl)) then return end

    pnl:AlphaTo(0, 0.2)

    timer.Simple(0.2, function()
      if (!IsValid(pnl)) then return end

      for i, v in pairs(self.notifications) do
        if (v.uniqueID != pnl.uniqueID) then continue end

        table.remove(self.notifications, i)

        pnl:Remove()
      end
    end)
  end)
end

vgui.Register("XeninUI.Panel", PANEL)
