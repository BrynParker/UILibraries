local PANEL = {}

function PANEL:Init()
    self:SetDrawOnTop(true)
    self:MakePopup()

    self.accentColor = VoidUI.Colors.Orange
    self.choices = {}
    self:DockPadding(0, 6, 0, 6)
end

function PANEL:SetAccentColor(color)
    self.accentColor = color
end

function PANEL:AddOption(name, onClick)
    local panel = vgui.Create("DButton", self)
    panel:Dock(TOP)
    panel:SSetTall(40)

    panel:SetText(name)
    panel:SetTextInset(16, 0)
    panel:SetContentAlignment(4)

    panel:SetFont("VoidUI.R20")
    panel:SetTextColor(VoidUI.Colors.Gray)
    panel.alpha = 0

    panel.Paint = function(pnl, w, h)
        surface.SetDrawColor(ColorAlpha(self.accentColor, panel.alpha))
        surface.DrawRect(0, 0, w, h)
    end

    panel.OnCursorEntered = function()
        panel.alpha = 200
    end

    panel.OnCursorExited = function()
        panel.alpha = 0
    end

    panel.DoClick = function(pnl)
        onClick(pnl)
        self:Remove()
    end

    self.choices[#self.choices + 1] = {
        panel = panel,
        str = name
    }

    self:InvalidateLayout()

    return panel
end

function PANEL:PerformLayout(w, h)
  local longest = 0

  surface.SetFont("VoidUI.R20")
  for k, v in pairs(self.choices) do
    local textSize = surface.GetTextSize(v.str)
    textSize = textSize + 32

    if (textSize > longest) then
        longest = math.max(112, textSize)
    end
  end

  self:SetWide(longest)
  self:SetTall(12 + #self.choices * 40)
end


function PANEL:OnFocusChanged(gained)
  if (!IsValid(self)) then return end
  if (gained) then return end

  self:Remove()
end

function PANEL:Paint(w, h)
  local x, y = self:LocalToScreen()

  BSHADOWS.BeginShadow()
    draw.RoundedBox(6, x, y, w, h, VoidUI.Colors.Primary)
  BSHADOWS.EndShadow(1, 2, 2)
end


vgui.Register("VoidUI.DropdownPopup", PANEL, "EditablePanel")

--

function VoidUI:CreateDropdownPopup(x, y)

    if (!x or !y) then
        x, y = input.GetCursorPos()
    end

    local panel = vgui.Create("VoidUI.DropdownPopup")
    panel:SetPos(x + 10, y + 10)

    return panel
end