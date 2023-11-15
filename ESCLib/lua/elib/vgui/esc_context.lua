local PANEL={}

function PANEL:Init()

	self.clr = esclib.addon:GetColors()

	local parent = self:GetParent()
	local outpnl = vgui.Create("DButton",parent)
	outpnl:SetSize(parent:GetWide(),parent:GetTall())
	outpnl:SetText("")
	outpnl:SetZPos(10)
	outpnl.Paint = nil
	outpnl:SetCursor("arrow")
	self.contextbackground = outpnl
	function outpnl:Close()
		self:SizeTo(1,1,esclib.addon:GetVar("animtime")*1.1,0,-1,function()
			self:Remove()
		end)
	end
	function outpnl.DoClick()
		outpnl:Close()
		if IsValid(self) then self:Close(true) end
	end
	function outpnl.DoRightClick()
		outpnl:Close()
		if IsValid(self) then self:Close(true) end
	end
	parent.contextbg = outpnl

	self.buttonheight = 30
	self.sepheight = 2
	self.spacey = 0

	self.headerfont = "es_esclib_20_500"
	self.buttonfont = "es_esclib_18_500"

	self.player = LocalPlayer()
	self:SetParent(outpnl)

	self:SetSize(100,self.buttonheight)
	self.list = vgui.Create("DIconLayout", self)
	self.list:SetSpaceY(self.spacey)
	self.list:SetSize(self:GetWide(),self:GetSize())
end

function PANEL:SetWide(wide)
	self:SetSize(wide,self:GetTall())
	self.list:SetSize(wide,self:GetTall())
end

function PANEL:Close(anim)
	if anim then
		self:SizeTo(1,1,esclib.addon:GetVar("animtime"),0,-1,function()
			self:Remove()
			if IsValid(self.contextbackground) then self.contextbackground:Remove() end
		end)
	else
		self:Remove()
		if IsValid(self.contextbackground) then self.contextbackground:Remove() end
	end
end

function PANEL:SetPly(ply)
	self.player = ply
end

function PANEL:GetPly(ply)
	return self.player
end

function PANEL:SetPosClamped(posx,posy)
	local x = math.Clamp( posx, 0, esclib.scrw - self:GetWide() )
	local y = math.Clamp( posy, 0, esclib.scrh - self:GetTall() )
	self:SetPos(x,y)
end

function PANEL:E_InvalidateLayout()
	local sizex = 1
	local sizey = 0
	for _,v in ipairs(self.list:GetChildren()) do
		local textsize = {w = 200, h = 100}
		if v.text then
			textsize = esclib.util.GetTextSize(v.text,self.buttonfont)
		end
		if v.icon then
			textsize.w = textsize.w + v:GetTall()*0.35 + 10
		end
		sizex = math.max(sizex,textsize.w+20)
		sizey = sizey + v:GetTall() + self.spacey
	end

	self:SetSize(sizex, sizey )
	self.list:SetSize(self:GetWide(),self:GetSize())
	self.contextbackground:SetZPos(10)

	for _,v in ipairs(self.list:GetChildren()) do
		v:SetWide(sizex)
		if IsValid(v.lbl) then
			v.lbl:Center()
		end
	end
end

function PANEL:AddButton(text,func,icon)
	local button = vgui.Create("DButton",self.list)
	button:SetSize(self.list:GetWide(), self.buttonheight)
	button:SetText("")

	button.TextColor = self.clr.button.text
	button.TextHoverColor = self.clr.button.text_hover
	button.IconColor = self.clr.button.text
	button.IconHoverColor = self.clr.button.text_hover

	button.Color = self.clr.button.main
	button.Color_Hover = self.clr.button.hover
	button.buttonfont = self.buttonfont

	button.text = text
	if icon then
		button.icon = icon 
	end
	local colors = self.clr

	function button:Paint(w,h)
		local hover = self:IsHovered()
		draw.RoundedBox(0,0,0,w,h,hover and self.Color_Hover or self.Color)

		draw.SimpleText(self.text,self.buttonfont,self.icon and h*0.35*2+15 or 10,h*0.5,hover and self.TextHoverColor or self.TextColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

		if self.icon then
			esclib.draw:MaterialCentered(h*0.35+5, h*0.5, h*0.35, hover and self.TextHoverColor or self.TextColor, self.icon)
		end
	end

	function button.DoClick()
		self:Close()
		func(self.player)
	end

	function button:SetTextColor(col)
		if IsColor(col) then self.TextColor = col end
	end

	function button:SetTextHoverColor(col)
		if IsColor(col) then self.TextHoverColor = col end
	end

	function button:SetIconColor(col)
		if IsColor(col) then self.IconColor = col end
	end

	function button:SetIconHoverColor(col)
		if IsColor(col) then self.IconHoverColor = col end
	end

	self:E_InvalidateLayout()
	return button
end

function PANEL:OnClick()
end

function PANEL:AddHeader(text,col)
	local pnl = vgui.Create("DPanel",self.list)
	pnl.TextColor = col or self.clr.frame.text
	pnl:SetSize(self.list:GetWide(), self.buttonheight)
	pnl.text = text
	function pnl.Paint(sel,w,h)
		draw.RoundedBox(0,0,0,w,h,self.clr.frame.accent)
		draw.SimpleText(text, self.headerfont, w*0.5, h*0.5, sel.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function pnl:SetTextColor(col)
		if IsColor(col) then self.TextColor = col end
	end

	self:E_InvalidateLayout()
	return pnl
end

function PANEL:AddSeparator()
	local pnl = vgui.Create("DPanel",self.list)
	pnl.text = ""
	pnl:SetSize(self.list:GetWide(), self.sepheight)
	function pnl:Paint(w,h)
		surface.SetDrawColor(self.clr.frame.text)
		surface.DrawRect(0,0,w,h)
	end
	self:E_InvalidateLayout()
end

function PANEL:Paint(w,h)
	local clr = self.clr.frame.bg
	surface.SetDrawColor(clr.r,clr.g,clr.b,clr.a)
	surface.DrawRect(0,0,w,h)
end


vgui.Register( "esclib.contextmenu", PANEL )