local PANEL = {}

XeninUI:CreateFont("XeninUI.Query.Text", 18)
XeninUI:CreateFont("XeninUI.Query.Button", 18)

function PANEL:Init()
  self.onAccept = function() end
  self.onDecline = function() end

  self.background.text = self.background:Add("DLabel")
  self.background.text:SetText("XD")
  self.background.text:SetFont("XeninUI.Query.Text")
  self.background.text:SetContentAlignment(8)
  self.background.text:SetTextColor(Color(200, 200, 200))

  self.background.accept = self.background:Add("DButton")
  self.background.accept:SetText("Accept")
  self.background.accept:SetFont("XeninUI.Query.Button")
  self.background.accept:SetTextColor(Color(21, 21, 21))
  self.background.accept.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, self.acceptBtnColor or XeninUI.Theme.Green)
  end
  self.background.accept.DoClick = function(pnl)
    self:onAccept(pnl)
    self:Remove()
  end
end

function PANEL:PerformLayout(w, h)
  surface.SetFont(self.background.text:GetFont())
  local tw = surface.GetTextSize(self.background.text:GetText())
  self:SetBackgroundWidth(tw + 32)

  self.BaseClass.PerformLayout(self, w, h)

  self.background.text:SetWide(self.background:GetWide())
  self.background.text:SizeToContentsY()
  self.background.text:SetPos(0, 56)

  self.background.accept:SizeToContentsX(32)
  self.background.accept:SizeToContentsY(16)

  local y = self.background:GetTall() - self.background.accept:GetTall() - 16

  self.background.accept:SetPos(self.background:GetWide() / 2 - self.background.accept:GetWide() / 2, y)
end

function PANEL:SetText(text)
  self.background.text:SetText(text)
end

function PANEL:SetAccept(text, func)
  self.background.accept:SetText(text)
  self.onAccept = func
end

vgui.Register("XeninUI.QuerySingleButton", PANEL, "XeninUI.Popup")

function XeninUI:SimpleQuerySingle(title, text, yesText, yesFunc)
  local queryMenu = vgui.Create("XeninUI.QuerySingleButton")
  queryMenu:SetSize(ScrW(), ScrH())
  queryMenu:SetBackgroundHeight(140)

  queryMenu:SetTitle(title or "Title")
  queryMenu:SetText(text or "Text")

  queryMenu:SetAccept(yesText or "Yes", yesFunc or (function() end))

  queryMenu:MakePopup()

  return queryMenu
end
