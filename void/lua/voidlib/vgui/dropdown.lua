local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self:SetFont("VoidUI.R26")
	self:SetTextColor(VoidUI.Colors.Gray)

	-- self.DropButton.Paint = function (self, w, h)
	--     -- Dropdown arrow goes here
	-- end

	self.color = VoidUI.Colors.InputDark
	self.isCentered = false


	local prevAddChoice = self.AddChoice

	self.AddChoice = function (s, val, data, select, icon)
		prevAddChoice(s, val, data, select, icon)

		surface.SetFont("VoidUI.R26")
		if (#val > 13) then
			self:SetFont("VoidUI.R22")
		end

		return #self.Choices
	end

end


function PANEL:ChooseOption( value, index )

	if (self.Menu and !self.multiple) then
		self.Menu:Remove()
		self.Menu = nil
	end

	if (!self.multiple and value) then
		self:SetText( value )
	end

	self.selected = index
	self:OnSelect(index, value, self.Data[index])

	self.textCol = VoidUI.Colors.TextGray

	if (self.isChoice) then
		self.value = self:GetSelectedID() == 1
	end

end

function PANEL:Center()
	self:SetContentAlignment(5)
end

function PANEL:SetupChoice(yes, no, default)
	self:AddChoice(yes)
	self:AddChoice(no)

	self:ChooseOptionID(default and 1 or 2)

	self.isChoice = true

	self.value = self:GetSelectedID() == 1
end

function PANEL:OpenMenu(pControlOpener)

	if (pControlOpener && pControlOpener == self.TextEntry) then
		return
	end

	if (#self.Choices == 0) then return end
	if (IsValid(self.Menu)) then
		self.Menu:Remove()
		self.Menu = nil
	end

	local this = self

	self.Menu = DermaMenu(false, self)

	function self.Menu:AddOption(strText, funcFunction)

        local pnl = vgui.Create("DMenuOption", self)
        pnl:SetMenu(self)
        pnl:SetIsCheckable(true)
		if (funcFunction) then pnl.DoClick = funcFunction end


        function pnl:OnMouseReleased(mousecode)
            DButton.OnMouseReleased(self, mousecode)
            if (self.m_MenuClicking && mousecode == MOUSE_LEFT) then
                self.m_MenuClicking = false
            end
        end

        self:AddPanel(pnl)

        return pnl
    end

	for k, v in pairs(self.Choices) do
		local option = self.Menu:AddOption( v, function() self:ChooseOption(v, k) end )

		function option:PerformLayout(w, h)
			self:SetTall(40)
		end

		local this = self
		

		option.Paint = function (self, w, h)
			local col = (self:IsHovered() and VoidUI.Colors.Primary) or VoidUI.Colors.InputLight
			local dropdownParent = self:GetParent():GetParent():GetParent()
			if (dropdownParent.multiple and dropdownParent.selectedItems[v]) then
				col = VoidUI.Colors.Blue
			end

			if (k == #this.Choices) then
				draw.RoundedBoxEx(12, 0, 0, w, h, col, false, false, true, true)
			else
				surface.SetDrawColor(col)
				surface.DrawRect(0,0,w,h)
			end

			draw.SimpleText(v, "VoidUI.R20", sc(10), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
			return true
		end
	end

	local x, y = self:LocalToScreen(5, self:GetTall())

	self.Menu:SetMinimumWidth(self:GetWide() - 10)
	self.Menu:Open(x, y, false, self)
	self.Menu.Paint = nil

end

function PANEL:SetLight()
	self.color = VoidUI.Colors.InputLight
end


function PANEL:Paint(w, h)
	draw.RoundedBox(8, 0, 0, w, h, self.color)
end

vgui.Register("VoidUI.Dropdown", PANEL, "DComboBox")
