
local sc = VoidUI.Scale

local PANEL = {}

local function CreateWangFunction( self, colindex )
	local function OnValueChanged( ptxt, strvar )
		if ( ptxt.notuserchange ) then return end


		self:GetColor()[ colindex ] = tonumber( strvar ) or 0
		if ( colindex == "a" ) then
			self.Alpha:SetBarColor( ColorAlpha( self:GetColor(), 255 ) )
			self.Alpha:SetValue( self:GetColor().a / 255 )
		else
			self.HSV:SetColor( self:GetColor() )

			local h, s, v = ColorToHSV( self.HSV:GetBaseRGB() )
			self.RGB.LastY = ( 1 - h / 360 ) * self.RGB:GetTall()
		end

		self:UpdateColor( self:GetColor() )
	end


	return OnValueChanged
end

function PANEL:Init()
	self:SetPalette(false)
	self:SetAlphaBar(false)
	self:SetWangs(false)

	self.RGB:Remove()

	self.Palette:Dock(FILL)
	self.Palette:InvalidateLayout()

	
	self.RightPanel = self:Add("Panel")
	self.RightPanel:Dock(RIGHT)
	self.RightPanel:SetWide(self:GetWide() * 0.25)
	self.RightPanel:SDockMargin(2, 2, 2, 2)

	self.ColorIndicator = self.RightPanel:Add("Panel")
	self.ColorIndicator:Dock(TOP)
	self.ColorIndicator:MarginSides(10)
	self.ColorIndicator:SSetTall(40)
	self.ColorIndicator.Paint = function (s, w, h)
		local color = self:GetColor()
		surface.SetDrawColor(color)
		surface.DrawRect(sc(7),sc(5),sc(35),sc(35))
	end
	
	self.WangsPanel = self.RightPanel:Add("Panel")
	self.WangsPanel:SetTall(self:GetTall() * 0.34)
	self.WangsPanel:Dock(BOTTOM)
	
	self.txtR = self.WangsPanel:Add("VoidUI.TextInput")
	self.txtR.entry:SetFont("VoidUI.R18")
	self.txtR.dockL = 2
	self.txtR.dockR = 2
	self.txtR:Dock(TOP)
	self.txtR.entry:SetTextColor(VoidUI.Colors.Gray)
	self.txtR:SSetWide(34)
	self.txtR:MarginLeft(25)

	self.txtG = self.WangsPanel:Add("VoidUI.TextInput")
	self.txtG.entry:SetFont("VoidUI.R18")
	self.txtG.dockL = 2
	self.txtG.dockR = 2
	self.txtG:MarginTop(2)
	self.txtG:Dock(TOP)
	self.txtG.entry:SetTextColor(VoidUI.Colors.Gray)
	self.txtG:SSetWide(34)
	self.txtG:MarginLeft(25)

	self.txtB = self.WangsPanel:Add( "VoidUI.TextInput" )
	self.txtB.entry:SetFont("VoidUI.R18")
	self.txtB.dockL = 2
	self.txtB.dockR = 2
	self.txtB:MarginTop(2)
	self.txtB:Dock(TOP)
	self.txtB:SSetWide(34)
	self.txtB.entry:SetTextColor(VoidUI.Colors.Gray)
	self.txtB:MarginLeft(25)

	local this = self

	self.WangsPanel.Paint = function (self, w, h)
		draw.SimpleText("R", "VoidUI.R20", sc(6), this.txtR.y+1, VoidUI.Colors.LightGray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("G", "VoidUI.R20", sc(6), this.txtG.y+1, VoidUI.Colors.LightGray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("B", "VoidUI.R20", sc(6), this.txtB.y+1, VoidUI.Colors.LightGray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end


	self.txtR.OnValueChange = CreateWangFunction( self, "r" )
	self.txtG.OnValueChange = CreateWangFunction( self, "g" )
	self.txtB.OnValueChange = CreateWangFunction( self, "b" )

	self.RGB = vgui.Create( "DRGBPicker", self )
	self.RGB:Dock(RIGHT)
	self.RGB:SSetWide(26)
	self.RGB:SDockMargin( 4, 0, 0, 0 )
	self.RGB.OnChange = function( ctrl, color )
		self:SetBaseColor( color )
	end

	self:InvalidateLayout()
end

vgui.Register("VoidUI.ColorMixerContent", PANEL, "DColorMixer")

-- color mixer parent

local PANEL = {}

function PANEL:Init()
	self.colorMixer = self:Add("VoidUI.ColorMixerContent")
	self.colorMixer:Dock(FILL)
	self.colorMixer:SDockMargin(7,7,7,7)

end

function PANEL:Paint(w, h)
	draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.InputDark)
end

vgui.Register("VoidUI.ColorMixer", PANEL, "Panel")