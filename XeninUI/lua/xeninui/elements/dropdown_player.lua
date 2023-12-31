local PANEL = {}

AccessorFunc(PANEL, "m_parentPanel", "ParentPanel")

function PANEL:Init()
  self.Choices = {}

  self.Search = self:Add("XeninUI.TextEntry")
  self.Search:Dock(TOP)
  self.Search:DockMargin(8, 0, 0, 8)
  self.Search:SetTall(36)
  self.Search:SetPlaceholder("Search by name")
  self.Search:SetIcon(XeninUI.Materials.Search, true)
  self.Search.textentry:SetUpdateOnType(true)
  self.Search.textentry.OnValueChange = function(pnl, text)
    local tbl = {}
    text = text:lower()
    for i, v in pairs(self.Data) do
      if (!IsValid(v)) then continue end
      if (!v:Nick():lower():find(text)) then continue end

      table.insert(tbl, v)
    end

    self:SetData(tbl)
  end
  self.Search.textentry.OnEnter = function(pnl, text)
    local children = self.Layout:GetChildren()
    if IsValid(children[1]) then
      children[1]:DoClick()

      return
    end

    self:Remove()
  end

  self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
  self.Scroll:Dock(FILL)

  self.Layout = self.Scroll:Add("DListLayout")
  self.Layout:Dock(TOP)

  self.Alpha = 0
  self:LerpAlpha(255, 0.15)

  self:DockPadding(0, 8, 8, 8)
end

function PANEL:OnSelected() end

XeninUI:CreateFont("XeninUI.DropdownPopup.Small", 12)

function PANEL:SetData(tbl)
  if (!self.Data) then
    self.Data = tbl
  end

  self.Layout:Clear()

  self.Choices = {}

  for i, v in ipairs(tbl) do
    if (!IsValid(v)) then return end

    local panel = self.Layout:Add("DButton")
    panel:Dock(TOP)
    panel:DockMargin(8, 0, 8, 0)
    panel:SetTall(48)
    panel:SetText("")
    panel.Text = v:Nick()
    panel.Sid64 = v:SteamID64()
    panel.Sid = v:IsBot() and "BOT" or v:SteamID()
    panel.Usergroup = v:GetUserGroup():sub(1, 1):upper() .. v:GetUserGroup():sub(2)
    panel.Background = XeninUI.Theme.Primary
    panel.TextColor = Color(222, 222, 222)
    panel.Paint = function(pnl, w, h)
      XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Background)

      XeninUI:DrawShadowText(pnl.Text, "XeninUI.DropdownPopup", h + 6, h / 2 + 1, pnl.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, 150)
      XeninUI:DrawShadowText(pnl.Sid, "XeninUI.DropdownPopup.Small", h + 6, h / 2 + 1, ColorAlpha(pnl.TextColor, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 150)
    end
    panel.OnCursorEntered = function(pnl)
      pnl:LerpColor("Background", XeninUI.Theme.Navbar)
      pnl:LerpColor("TextColor", color_white)
    end
    panel.OnCursorExited = function(pnl)
      pnl:LerpColor("Background", XeninUI.Theme.Primary)
      pnl:LerpColor("TextColor", Color(222, 222, 222))
    end
    panel.DoClick = function(pnl)
      self:OnSelected(pnl.Sid64)
      self:Remove()
    end

    panel.Avatar = panel:Add("XeninUI.Avatar")
    panel.Avatar:SetVertices(30)
    panel.Avatar:SetPlayer(v, 64)

    panel.PerformLayout = function(pnl, w, h)
      panel.Avatar:SetPos(6, 6)
      panel.Avatar:SetSize(h - 12, h - 12)
    end

    table.insert(self.Choices, panel)
  end
end

function PANEL:Paint(w, h)
  local aX, aY = self:LocalToScreen()

  BSHADOWS.BeginShadow()
  draw.RoundedBox(6, aX, aY, w, h, XeninUI.Theme.Primary)
  BSHADOWS.EndShadow(1, 1, 1, 150)
end

function PANEL:OnFocusChanged(gained)
  if gained then
    self.HasGained = true
  end
end


function PANEL:Think()
  if (!IsValid(self)) then return end
  if (!self.HasGained) then return end
  if self:HasHierarchicalFocus() then return end

  self:Remove()
end

function PANEL:PerformLayout(w, h)
  local longest = 0

  surface.SetFont("XeninUI.DropdownPopup")
  for i, v in pairs(self.Choices) do
    local tw = surface.GetTextSize(v.Text)
    tw = tw + 16
    tw = tw + 16
    tw = tw + 48

    if (tw > longest) then
      longest = math.max(112, tw)
    end
  end

  self:SetWide(math.max(self:GetParentPanel():GetWide(), longest))
  self:SetTall(math.min(#self.Choices * 48, 6 * 48) + 16 + 44)
end

vgui.Register("XeninUI.PlayerDropdown", PANEL, "EditablePanel")
