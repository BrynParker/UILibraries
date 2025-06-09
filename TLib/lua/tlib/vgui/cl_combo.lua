TLib.Font("Combo", 18)

local PANEL = {}

function PANEL:Init()

	self:SetFont( "TLib.Font.Combo" )
	self:SetTextColor( Color( 255, 255, 255 ) )
	self:SetContentAlignment( 5 )
    self:SetText("")
end


function PANEL:ChooseOption( value, index )

	if ( self.Menu and !self.multiple ) then
		self.Menu:Remove()
		self.Menu = nil
	end

	if ( !self.multiple and value ) then
		self:SetText( value )
	end

	self.selected = index
	self:OnSelect(index, value, self.Data[index])
	self.textCol = white

	if (self.isChoice) then

		self.value = self:GetSelectedID() == 1

	end

end

function PANEL:OpenMenu(pControlOpener)

	if ( pControlOpener && pControlOpener == self.TextEntry ) then
	
		return
	end

	if (#self.Choices == 0) then return end

	if (IsValid(self.Menu)) then
		self.Menu:Remove()
		self.Menu = nil
	end

	local this = self

	self.Menu = TLib.ContextMenu( self )

	function self.Menu:AddOption( strText, funcFunction )

        local pnl = vgui.Create( "TLib.ContextOption", self )
        pnl:SetMenu( self )
        pnl:SetIsCheckable(true)
		pnl:Dock(TOP)
		pnl:DockMargin(0,0,0,0)

		if ( funcFunction ) then pnl.DoClick = funcFunction end

        function pnl:OnMouseReleased( mousecode )
            DButton.OnMouseReleased( self, mousecode )

            if ( self.m_MenuClicking && mousecode == MOUSE_LEFT ) then
                self.m_MenuClicking = false
            end

        end

        self:AddPanel(pnl)
        return pnl
    end

	for k, v in pairs( self.Choices ) do
		
		local option = self.Menu:AddOption( v, function() self:ChooseOption(v, k) end)

		function option:PerformLayout(w, h)
			self:SetTall(40)
		end

		local this = self
		option.Paint = function (self, w, h)
		draw.RoundedBox(0, 0, 0, w,h, TLib.Theme.accentalpha)



		if (self:IsHovered()) then			
			TLib.DrawOutlinedBox(nil,0, 0, w, h, TLib.Theme.accent, TLib.Theme.outline, false, false, false,false)
		end


		draw.SimpleText( v, "TLib.Font.Combo", w / 2, h / 2, TLib.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			return true
		end
	end

	local x, y = self:LocalToScreen( 5, self:GetTall() )
	self.Menu:SetMinimumWidth( self:GetWide() - 19 )
	self.Menu:Open( x + 4, y - 1.5, false, self )
	self.Menu:GetChild(1):DockMargin(0,15,0,0)
end


function PANEL:Paint(w, h)
	TLib.DrawOutlinedBox(nil, 0, 0, w, h, TLib.Theme.outline, TLib.Theme.outline )
	
	if (self:IsHovered()) then
	local x, y = self:LocalToScreen()
    BSHADOWS.BeginShadow()
    TLib.DrawOutlinedBox(nil, x, y, w, h, TLib.Theme.accent, TLib.Theme.outline)
    BSHADOWS.EndShadow(1, 2, 2)
	end

	if (self:IsMenuOpen()) then
		TLib.DrawOutlinedBox(nil,0, 0, w, h, TLib.Theme.accent, TLib.Theme.outline)
	end
end

function PANEL:SetupDock(pos, left, top, right, bottom)
	self:Dock(pos)
	self:DockMargin(left or 0, top or 0, right or 0, bottom or 0)
end

function PANEL:SetupTooltip(text)
	self:SetTooltip(text)
	self:SetTooltipPanelOverride("TLib.Tooltip")
end

function PANEL:SetupOptions(options)
	self.Choices = options
end

function PANEL:SetupText(text)
	self:SetText(text)
end

function PANEL:GetValue()
	return self:GetText()
end

-- function PANEL:Text(text)
-- 	self:SetValue(text)
-- end

vgui.Register("TLib.Combo", PANEL, "DComboBox")