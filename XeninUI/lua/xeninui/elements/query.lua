local PANEL = {}

AccessorFunc(PANEL, "custom_width", "CustomWidth", FORCE_NUMBER)

XeninUI:CreateFont("XeninUI.Query.Text", 18)
XeninUI:CreateFont("XeninUI.Query.Button", 18)
XeninUI:CreateFont("XeninUI.Query.Option", 20)

function PANEL:Init()
  self.onAccept = function() end
  self.onDecline = function() end

  self.background.text = self.background:Add("DLabel")
  self.background.text:SetText("XD")
  self.background.text:SetFont("XeninUI.Query.Text")
  self.background.text:SetContentAlignment(8)
  self.background.text:SetTextColor(Color(200, 200, 200))

  self.background.input = self.background:Add("XeninUI.TextEntry")
  self.background.input:SetVisible(false)

  self.background.option = self.background:Add("DButton")
  self.background.option:SetVisible(false)
  self.background.option:SetText("")
  self.background.option.Paint = function(pnl, w, h)
    XeninUI:DrawRoundedBox(6, 0, 0, w, h, XeninUI.Theme.Navbar)

    local text = pnl.Text or "None Selected"
    XeninUI:DrawShadowText(text, "XeninUI.Query.Option", w / 2, h / 2, Color(184, 184, 184), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, 150)
  end
  self.background.option.DoClick = function(pnl)
    if IsValid(pnl.Dropdown) then return end

    pnl.Dropdown = vgui.Create("XeninUI.PlayerDropdown")
    pnl.Dropdown:SetParentPanel(pnl)
    pnl.Dropdown:SetData(self.optionData)
    pnl.Dropdown:SetDrawOnTop(true)
    local x, y = pnl:LocalToScreen()
    pnl.Dropdown:SetPos(x, y + pnl:GetTall())
    pnl.Dropdown:MakePopup()
    pnl.Dropdown.OnSelected = function(dropdown, sid64)

      if (!sid64) then return end
      local ply = player.GetBySteamID64(sid64)
      pnl.Text = ply:Nick()

      self.background.option.sid64 = sid64
    end
  end
  self.background.option.OnRemove = function(pnl)
    if IsValid(pnl.Dropdown) then
      pnl.Dropdown:Remove()
    end
  end

  self.background.accept = self.background:Add("DButton")
  self.background.accept:SetText("Accept")
  self.background.accept:SetFont("XeninUI.Query.Button")
  self.background.accept:SetTextColor(Color(21, 21, 21))
  self.background.accept.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Green)
  end
  self.background.accept.DoClick = function(pnl)
    self:onAccept(pnl, self.background.input:GetText(), self.background.option.sid64)
    self:Remove()
  end

  self.background.decline = self.background:Add("DButton")
  self.background.decline:SetText("Decline")
  self.background.decline:SetFont("XeninUI.Query.Button")
  self.background.decline:SetTextColor(Color(145, 145, 145))
  self.background.decline.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Navbar)
    draw.RoundedBox(6, 2, 2, w - 4, h - 4, XeninUI.Theme.Background)
  end
  self.background.decline.DoClick = function(pnl)
    self:onDecline(pnl, self.background.input:GetText(), self.background.option.sid64)
    self:Remove()
  end
end

function PANEL:PerformLayout(w, h)
  if (!self:GetCustomWidth()) then
    surface.SetFont(self.background.text:GetFont())
    local tw = surface.GetTextSize(self.background.text:GetText())
    self:SetBackgroundWidth(tw + 32)
  else
    self:SetBackgroundWidth(self:GetCustomWidth())
  end

  self.BaseClass.PerformLayout(self, w, h)

  self.background.text:SetWide(self.background:GetWide())
  self.background.text:SizeToContentsY()
  self.background.text:SetPos(0, 56)

  self.background.accept:SizeToContentsX(32)
  self.background.accept:SizeToContentsY(16)
  self.background.decline:SizeToContentsX(32)
  self.background.decline:SizeToContentsY(16)

  if self.background.input:IsVisible() then
    self.background.input:SetSize(math.max(self.background.accept:GetWide() + self.background.decline:GetWide() + 8, self.background:GetWide() * 0.75), 32)
    self.background.input:SetPos(0, 88)
    self.background.input:CenterHorizontal()
  end

  if self.background.option:IsVisible() then
    self.background.option:SetSize(math.max(self.background.accept:GetWide() + self.background.decline:GetWide() + 8, self.background:GetWide() * 0.75), 32)

    local inputVisible = self.background.input:IsVisible()
    self.background.option:SetPos(0, 88 + (inputVisible and 44 or 0))
    self.background.option:CenterHorizontal()
  end

  local y = self.background:GetTall() - self.background.accept:GetTall() - 16
  self.background.accept:SetPos(self.background:GetWide() / 2 - self.background.accept:GetWide() / 2 - self.background.decline:GetWide() / 2 - 4, y)
  self.background.decline:SetPos(self.background:GetWide() / 2 + self.background.accept:GetWide() / 2 - self.background.decline:GetWide() / 2 + 4, y)
end

function PANEL:SetInput(str, placeholder, numeric)
  self.background.input:SetVisible(true)
  self.background.input:SetText(str)
  self.background.input:SetPlaceholder(placeholder)
  self.background.input.textentry:SetNumeric(numeric)
end

function PANEL:SetOption(tbl)
  self.background.option:SetVisible(true)
  self.optionData = tbl
end

function PANEL:SetText(text)
  self.background.text:SetText(text)
end

function PANEL:SetAccept(text, func)
  self.background.accept:SetText(text)
  self.onAccept = func
end

function PANEL:SetDecline(text, func)
  self.background.decline:SetText(text)
  self.onDecline = func
end

vgui.Register("XeninUI.Query", PANEL, "XeninUI.Popup")

function XeninUI:SimpleQuery(title, text, yesText, yesFunc, noText, noFunc)
  local queryMenu = vgui.Create("XeninUI.Query")
  queryMenu:SetSize(ScrW(), ScrH())
  queryMenu:SetBackgroundHeight(140)

  queryMenu:SetTitle(title or "Title")
  queryMenu:SetText(text or "Text")

  queryMenu:SetAccept(yesText or "Yes", yesFunc or (function() end))
  queryMenu:SetDecline(noText or "No", noFunc or (function() end))

  queryMenu:MakePopup()

  return queryMenu
end
